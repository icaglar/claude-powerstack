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

---

## Workflow — Ruflo ve Superpowers Birlikte Nasıl Çalışır?

Her phase'de hangi aracın ne yaptığını aşağıda görebilirsin.

### Phase 0 — Bağlam Kur

| Adım | Araç | Komut / Aksiyon |
|------|------|-----------------|
| Geçmiş hafızayı yükle | **Ruflo** | `ruflo memory search --query "<görev anahtar kelimeleri>"` |
| Önceki oturumu geri yükle | **Ruflo** | `ruflo hooks session-restore` |
| Git branch oluştur | Git | `git checkout -b feature/<kısa-açıklama>` |

---

### Phase 1 — Keşif ve Yönlendirme

| Adım | Araç | Komut / Aksiyon |
|------|------|-----------------|
| Hangi agent tipi kullanılmalı? | **Ruflo** | `ruflo hooks route -t "<görev açıklaması>"` |
| Hangi model kullanılmalı? (haiku/sonnet/opus) | **Ruflo** | `ruflo hooks model-route -t "<görev açıklaması>"` |
| Görev karmaşıksa brainstorming yap | **Superpowers** | `/brainstorming` → `docs/superpowers/specs/YYYY-MM-DD-<feature>.md` |

---

### Phase 2 — Planlama ⏸️ ONAY GEREKLİ

| Adım | Araç | Komut / Aksiyon |
|------|------|-----------------|
| Uygulama planı yaz | **Superpowers** | `/writing-plans` → `docs/superpowers/plans/YYYY-MM-DD-<feature>.md` |
| Görevi kaydet | **Ruflo** | `ruflo hooks pre-task -d "<görev>" -t implementation` |
| **ONAY NOKTASI 1** | — | Planı kullanıcıya sun, "evet / devam / go" bekle |

---

### Phase 3 — Uygulama (TDD Sırasıyla)

| Adım | Araç | Komut / Aksiyon |
|------|------|-----------------|
| Swarm oluştur | **Ruflo** | `ruflo swarm init --topology hierarchical --max-agents 6 --strategy specialized` |
| Swarm başlat | **Ruflo** | `ruflo swarm start -o "<hedef>" -s development` |
| Tester agent başlat (ÖNCE) | **Ruflo** | `ruflo agent spawn -t tester` |
| Coder agent başlat | **Ruflo** | `ruflo agent spawn -t coder` |
| Architect agent başlat (büyük görevlerde) | **Ruflo** | `ruflo agent spawn -t architect` |
| Test task oluştur | **Ruflo** | `ruflo task create -t testing -d "failing testleri yaz: <modül>"` |
| Implementation task oluştur | **Ruflo** | `ruflo task create -t implementation -d "backend: <servis yaz>"` |
| Task'ları agent'lara ata | **Ruflo** | `ruflo task assign <id> --agent coder` |
| Agent'ları paralel çalıştır | **Superpowers** | `/dispatching-parallel-agents` |
| İlerlemeyi takip et | **Ruflo** | `ruflo swarm status` · `ruflo task list --all` |
| Hata ayıklama | **Superpowers** | `/systematic-debugging` |

---

### Phase 4 — Code Review

| Adım | Araç | Komut / Aksiyon |
|------|------|-----------------|
| Review başlat | **Superpowers** | `/requesting-code-review` |
| Reviewer agent başlat | **Ruflo** | `ruflo agent spawn -t reviewer` |
| Review bulgularını uygula | **Superpowers** | `/receiving-code-review` |

---

### Phase 5 — Tamamlama ⏸️ ONAY GEREKLİ

| Adım | Araç | Komut / Aksiyon |
|------|------|-----------------|
| Testler + build + lint doğrula | **Superpowers** | `/verification-before-completion` |
| Branch'i düzenle + commit | **Superpowers** | `/finishing-a-development-branch` |
| **ONAY NOKTASI 2** | — | Commit listesi + test sonuçlarını kullanıcıya sun, "evet / push / pr aç" bekle |
| PR oluştur | Git | `gh pr create --title "feat: ..." --body "..."` |
| Görevi kaydet | **Ruflo** | `ruflo hooks post-task -d "<görev>" --outcome success` |
| Öğrendiklerini hafızaya yaz | **Ruflo** | `ruflo memory store --key "<pattern>" --value "<karar>" --namespace patterns` |

---

## Workflow Boyutuna Göre Hızlı Başlangıç

| Görev | Adımlar |
|-------|---------|
| Küçük (tek dosya, <2 saat) | `0c → 1a → 2b → ⏸️ONAY1 → 3b → 4b → 5a → 5b → ⏸️ONAY2 → 5c` |
| Orta (birkaç dosya, 2-8 saat) | `0a → 0c → 1a → 2a → 2b → ⏸️ONAY1 → 3a → 3b → 4a-c → 5a → 5b → ⏸️ONAY2 → 5c → 5e` |
| Büyük (yeni feature, >8 saat) | Tam 5 phase (tüm adımlar) |

## Ruflo Komut Referansı

> Kısa alias: `ruflo` (yoksa `npx @claude-flow/cli@latest`)

### Proje Başlatma

```bash
ruflo init --wizard                   # interaktif proje kurulumu
ruflo doctor --fix                    # sistem sağlığı + otomatik düzeltme
```

### Agent Yönetimi

```bash
ruflo agent spawn -t coder            # coder agent başlat
ruflo agent spawn -t tester           # tester agent (TDD için önce spawn et)
ruflo agent spawn -t reviewer         # code review agent
ruflo agent spawn -t architect        # mimari kararlar için
ruflo agent spawn -t researcher       # codebase araştırma
ruflo agent list                      # çalışan agent'ları listele
ruflo agent metrics                   # performans metrikleri
ruflo agent health                    # agent sağlık durumu
```

### Swarm Orkestrasyon

```bash
ruflo swarm init --topology hierarchical --max-agents 6 --strategy specialized
ruflo swarm start -o "feature hedefi" -s development
ruflo swarm status                    # genel durum, agent sayısı
ruflo swarm shutdown                  # swarm'ı durdur
```

### Task Yönetimi

```bash
ruflo task create -t testing -d "failing testleri yaz: <modül>"
ruflo task create -t implementation -d "backend: <servis yaz>"
ruflo task assign <task-id> --agent coder
ruflo task list --all                 # tüm task'lar ve durumları
ruflo task status <id>                # belirli task detayı
ruflo task retry <id>                 # başarısız task'ı yeniden dene
```

### Routing — Hangi Agent / Model?

```bash
ruflo hooks route       -t "görev açıklaması"   # hangi agent tipi?
ruflo hooks model-route -t "görev açıklaması"   # haiku / sonnet / opus?
```

### Hooks — Task Kayıt

```bash
ruflo hooks pre-task  -d "görev" -t implementation   # görev başlamadan kaydet
ruflo hooks post-task -d "görev" --outcome success   # görev bitince kaydet
ruflo hooks session-restore                          # önceki oturumu geri yükle
```

### Hafıza

```bash
ruflo memory search --query "keywords"                       # geçmiş ara
ruflo memory store  --key "key" --value "value" --namespace patterns
ruflo memory list   --namespace patterns --limit 10
ruflo memory retrieve --key "key" --namespace patterns
```

### Oturum Yönetimi

```bash
ruflo session save    --name "oturum-adı"   # oturumu kaydet
ruflo session list                          # kayıtlı oturumlar
ruflo session restore --name "oturum-adı"  # oturumu geri yükle
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
