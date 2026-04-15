#!/usr/bin/env bash
# claude-powerstack — kurulum scripti
# Ruflo (claude-flow) + Superpowers'ı birlikte kurar

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════╗${NC}"
echo -e "${CYAN}║      claude-powerstack setup   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════╝${NC}"
echo ""

# 1. Ruflo (claude-flow CLI)
echo -e "${YELLOW}[1/4]${NC} Ruflo (claude-flow) kuruluyor..."
if command -v npx &>/dev/null; then
    npx @claude-flow/cli@latest doctor --fix 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Ruflo hazır: $(npx @claude-flow/cli@latest --version 2>/dev/null || echo 'kuruldu')"
else
    echo "⚠️  Node.js bulunamadı. https://nodejs.org adresinden kurun."
    exit 1
fi

# 2. Superpowers plugin
echo -e "${YELLOW}[2/4]${NC} Superpowers plugin kuruluyor..."
if command -v claude &>/dev/null; then
    claude plugin install superpowers@claude-plugins-official 2>/dev/null || \
        echo "  (Superpowers zaten kurulu veya manuel kurulum gerekiyor)"
    echo -e "${GREEN}✓${NC} Superpowers hazır"
else
    echo "  ⚠️  Claude Code CLI bulunamadı — Superpowers'ı manuel kur:"
    echo "  claude plugin install superpowers@claude-plugins-official"
fi

# 3. Workflow command kopyala
echo -e "${YELLOW}[3/5]${NC} /workflow:ruflo komutu kuruluyor..."
CLAUDE_DIR="${HOME}/.claude"
COMMANDS_DIR="${CLAUDE_DIR}/commands/workflow"
mkdir -p "${COMMANDS_DIR}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cp "${REPO_DIR}/.claude/commands/workflow/ruflo.md" "${COMMANDS_DIR}/ruflo.md"
echo -e "${GREEN}✓${NC} /workflow:ruflo komutu ${COMMANDS_DIR}/ruflo.md konumuna kopyalandı"

# 4. Superpowers skill'lerini kopyala
echo -e "${YELLOW}[4/5]${NC} Superpowers skill'leri kuruluyor..."
if [ -d "${REPO_DIR}/superpowers/skills" ]; then
    SKILLS_DEST="${CLAUDE_DIR}/plugins/superpowers/skills"
    mkdir -p "${SKILLS_DEST}"
    cp -r "${REPO_DIR}/superpowers/skills/." "${SKILLS_DEST}/"
    SP_VERSION=$(cat "${REPO_DIR}/superpowers/VERSION" 2>/dev/null || echo "bundled")
    echo -e "${GREEN}✓${NC} Superpowers skill'leri kopyalandı (v${SP_VERSION}) → ${SKILLS_DEST}"
else
    echo "  ⚠️  Superpowers skill dizini bulunamadı, atlanıyor"
fi

# 5. Ruflo MCP bağlantısı
echo -e "${YELLOW}[5/5]${NC} Ruflo MCP sunucusu kaydediliyor..."
claude mcp add claude-flow -- npx -y @claude-flow/cli@latest 2>/dev/null && \
    echo -e "${GREEN}✓${NC} MCP sunucu kaydedildi" || \
    echo "  (Zaten kayıtlı veya manuel kurulum: claude mcp add claude-flow -- npx -y @claude-flow/cli@latest)"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  claude-powerstack kurulumu tamamlandı  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Kullanım:"
echo "  Claude Code içinde: /workflow:ruflo <görev açıklaması>"
echo ""
echo "Örnek:"
echo "  /workflow:ruflo kullanıcı kimlik doğrulama sistemi"
