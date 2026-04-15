# claude-powerstack

**Ruflo + Superpowers** — Claude Code için tam geliştirme iş akışı başlangıç kiti.

Tek kurulumla iki güçlü aracı birlikte çalıştır:

| Araç | Ne yapar? |
|------|-----------|
| [Ruflo (claude-flow)](https://github.com/ruvnet/ruflo) | Swarm orkestrasyon, hafıza, routing, hooks |
| [Superpowers](https://claude.com/plugins/superpowers) | TDD metodolojisi, brainstorming, plan yazma, paralel dispatch |

## Neden İkisi Birlikte?

```
Ruflo = orkestra şefi  (kimler çalışacak, nasıl koordine?)
Superpowers = partisyon  (ne çalınacak, hangi sırayla?)
Claude Code = müzisyenler  (gerçekten yapan)
```

- **Ruflo'suz**: Agent routing, hafıza ve swarm yönetimi yok
- **Superpowers'sız**: Plan formatı ve metodoloji yok — agent'lar ne yapacaklarını bilmiyor

## Kurulum

```bash
git clone https://github.com/icaglar/claude-powerstack
cd claude-powerstack
bash scripts/setup.sh
```

Setup scripti şunları yapar:
1. Ruflo CLI'yı hazır hale getirir (`npx @claude-flow/cli@latest`)
2. Superpowers plugin'ini kurar
3. `/workflow:ruflo` komutunu `~/.claude/commands/workflow/` altına kopyalar
4. Ruflo MCP sunucusunu Claude Code'a kaydeder

### Manuel Kurulum

```bash
# 1. Ruflo
claude mcp add claude-flow -- npx -y @claude-flow/cli@latest

# 2. Superpowers (Claude Code içinden)
/plugin install superpowers@claude-plugins-official

# 3. Workflow komutu
cp .claude/commands/workflow/ruflo.md ~/.claude/commands/workflow/ruflo.md
```

## Kullanım

Claude Code'u aç ve bir görev ver:

```
/workflow:ruflo kullanıcı kimlik doğrulama sistemi
```

Workflow şu aşamaları otomatik çalıştırır:

```
Phase 0: Hafıza yükle → Git branch oluştur
Phase 1: Agent + model routing (Ruflo)
Phase 2: Brainstorm → Plan yaz (Superpowers)
Phase 3: Swarm kur → Agent'ları paralel dispatch et
Phase 4: Code review döngüsü
Phase 5: Doğrulama → Commit → PR
```

## Workflow Boyutuna Göre Hızlı Başlangıç

| Görev | Adımlar |
|-------|---------|
| Küçük (tek dosya, <2 saat) | `0c → 1a → 2b → 3b → 4b → 5a → 5b` |
| Orta (birkaç dosya, 2-8 saat) | `0a → 0c → 1a → 2a → 2b → 3a → 3b → 4a-c → 5a-c` |
| Büyük (yeni feature, >8 saat) | Tam 5 phase |

## Sık Kullanılan Ruflo Komutları

```bash
# Routing — hangi agent, hangi model?
npx @claude-flow/cli@latest hooks route -t "görev"
npx @claude-flow/cli@latest hooks model-route -t "görev"

# Hafıza
npx @claude-flow/cli@latest memory search --query "keywords"
npx @claude-flow/cli@latest memory store --key "key" --value "value"

# Swarm
npx @claude-flow/cli@latest swarm init --topology hierarchical --max-agents 6
npx @claude-flow/cli@latest swarm status

# Sistem sağlığı
npx @claude-flow/cli@latest doctor
```

## Superpowers Skill'leri

Workflow içinde otomatik tetiklenir, manuel de çağırabilirsin:

```
/brainstorming              → Spec dosyası üret
/writing-plans              → Detaylı uygulama planı
/dispatching-parallel-agents → Agent'ları paralel çalıştır
/requesting-code-review     → Review döngüsü başlat
/verification-before-completion → Tamamlama öncesi doğrula
/finishing-a-development-branch → Branch'i kapat, PR hazırla
```

## Lisans

MIT — Ruflo ve Superpowers'ın orijinal lisanslarına uygun olarak.

**Ruflo**: [MIT](https://github.com/ruvnet/ruflo/blob/main/LICENSE) © ruvnet
**Superpowers**: [MIT](https://github.com/obra/superpowers) © Jesse Vincent
