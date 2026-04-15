# Ruflo + Superpowers Full Development Workflow

Tam geliştirme döngüsünü Ruflo ve Superpowers skill'leri ile kusursuz şekilde uygula.

**Announce at start:** "Ruflo + Superpowers workflow başlatılıyor..."

---

## PHASE 0 — Bağlam Kur

### 0a. Geçmiş Hafızayı Yükle
```bash
ruflo memory search -q "$TASK_KEYWORDS"
ruflo memory search -q "$(git branch --show-current)"
```
Bulunan pattern'ları ve geçmiş kararları not al. Aynı hatayı tekrar yapma.

### 0b. Oturum Geri Yükle (varsa)
```bash
ruflo hooks session-restore
```

### 0c. Git Branch / Worktree Oluştur
- Branch adı: `feature/<kısa-açıklama>` veya `fix/<kısa-açıklama>`
- Karmaşık görevlerde worktree kullan: `/using-git-worktrees`
```bash
git checkout -b feature/<feature-name>
```

---

## PHASE 1 — Keşif ve Yönlendirme

### 1a. Agent ve Model Routing
```bash
ruflo hooks route       -t "<görev açıklaması>"
ruflo hooks model-route -t "<görev açıklaması>"
```
Önerilen agent tiplerini ve modeli (haiku/sonnet/opus) not al.

### 1b. Brainstorming (Karmaşık / Belirsiz Görevler)
Görev büyükse veya net değilse:
- Superpowers `/brainstorming` skill'ini uygula
- Çıktı: spec dosyası → `docs/superpowers/specs/YYYY-MM-DD-<feature>.md`
- Basit görevlerde bu adımı atla.

---

## PHASE 2 — Planlama

### 2a. Plan Yaz
Superpowers `/writing-plans` skill'ini uygula:
- Girdi: spec dosyası veya görev açıklaması
- Çıktı: `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`
- Plan dosyasına ekle: `> REQUIRED SUB-SKILL: superpowers:subagent-driven-development`

Plan şunları içermeli:
- Oluşturulacak / değiştirilecek dosya haritası
- Her adım `- [ ]` checkbox formatında (2-5 dakikalık granülarite)
- TDD sırası: test yaz → fail gör → implement → pass gör
- Migration / breaking change uyarıları

### 2b. Pre-Task Kaydı
```bash
ruflo hooks pre-task -d "<görev açıklaması>" -t implementation
```

---

## PHASE 3 — Uygulama (TDD Sırasıyla)

### 3a. Swarm Kur ve Başlat
```bash
# Swarm oluştur
ruflo swarm init --topology hierarchical --max-agents 6 --strategy specialized

# Hedefe göre swarm'ı başlat
ruflo swarm start -o "<feature hedefi>" -s development
```

### 3b. Agent'ları Spawn Et
```bash
# TDD sırası: tester ÖNCE
ruflo agent spawn -t tester
ruflo agent spawn -t coder      # bağımsız parçalar için birden fazla olabilir
ruflo agent spawn -t architect  # büyük görevlerde mimari kararlar için
```

### 3c. Plan'dan Ruflo Task'ları Oluştur
Plan dosyasındaki her bağımsız iş bloğu için ruflo task aç:

```bash
# Test görevleri (önce)
ruflo task create -t testing      -d "failing testleri yaz: <modül>"
ruflo task create -t testing      -d "failing testleri yaz: <modül2>"

# Implementation görevleri (paralel çalışabilir)
ruflo task create -t implementation -d "backend: <servis/endpoint yaz>"
ruflo task create -t implementation -d "frontend: <bileşen yaz>"
ruflo task create -t implementation -d "migration: <tablo/schema>"

# Her task'ı ilgili agent'a ata
ruflo task assign <test-task-id>    --agent tester
ruflo task assign <backend-task-id> --agent coder
ruflo task assign <frontend-task-id> --agent coder
```

### 3d. Paralel Dispatch (Superpowers)
Superpowers `/dispatching-parallel-agents` skill'ini uygula — Claude Code'un
Agent tool'u ile ruflo task'larını paralel olarak gerçekleştir.

**Sıra:**
1. tester agent → failing testler (ruflo task: testing)
2. coder agent(lar) → paralel implement (ruflo task: implementation)
3. architect agent → tasarım kararı gerekirse

### 3e. İlerlemeyi Takip Et
```bash
ruflo swarm status        # genel durum, agent sayısı
ruflo task list --all     # tüm task'lar ve durumları
ruflo task status <id>    # belirli task detayı
ruflo agent metrics       # agent performans metrikleri
```

**Task tamamlanınca:**
```bash
ruflo task list --all | grep "completed"
```

**Hata durumunda:**
- Superpowers `/systematic-debugging` uygula
- `ruflo task retry <task-id>` ile yeniden dene
- `ruflo agent health` ile agent sağlığını kontrol et

---

## PHASE 4 — Code Review

### 4a. Review İste
Superpowers `/requesting-code-review` uygula.

Reviewer'a şunlara bakmasını söyle:
- `blocker`: güvenlik açığı, veri kaybı riski, test eksikliği
- `suggestion`: performans, okunabilirlik
- `nit`: stil, opsiyonel

### 4b. Reviewer Agent Çalıştır
```bash
ruflo agent spawn -t reviewer
```

### 4c. Review Bulgularını Al ve Uygula
Superpowers `/receiving-code-review` uygula:
- `blocker` → hemen düzelt, review döngüsünü tekrarla
- `suggestion` → değerlendir, gerekirse uygula
- `nit` → opsiyonel, zaman varsa uygula

---

## PHASE 5 — Tamamlama

### 5a. Doğrulama
Superpowers `/verification-before-completion` uygula:
- [ ] Tüm testler geçiyor (`npm test` / `pytest`)
- [ ] Build temiz (`npm run build` / `tsc --noEmit`)
- [ ] Lint hataları yok
- [ ] Plan'daki tüm checkbox'lar işaretli
- [ ] Breaking change varsa dokümante edildi
- [ ] Güvenlik açığı yok

### 5b. Branch Hazırla
Superpowers `/finishing-a-development-branch` uygula:
- Commit'leri düzenle (squash gerekirse)
- Commit mesajları conventional commits formatında
- `git push -u origin <branch>`

### 5c. PR Oluştur
```bash
gh pr create --title "<feat|fix>: kısa açıklama" --body "..."
```
PR body şunları içermeli:
- Neyi ve neden değiştirdi
- Test planı
- Breaking change varsa migration adımları

### 5d. Post-Task Kaydı ve Öğrenme
```bash
ruflo hooks post-task -d "<görev>" --outcome success
```

### 5e. Hafızaya Kaydet
```bash
ruflo memory store \
  -k "<feature>-pattern" \
  -v "<öğrenilen pattern, karar, gotcha>" \
  --namespace patterns

ruflo memory store \
  -k "<feature>-decisions" \
  -v "<mimari kararlar ve gerekçeleri>" \
  --namespace decisions
```

---

## Hızlı Referans

### Küçük görev (tek dosya, <2 saat):
```
0c → 1a → 2b → 3b (sadece coder) → 4b → 5a → 5b → 5e
```

### Orta görev (birkaç dosya, 2-8 saat):
```
0a → 0c → 1a → 2a → 2b → 3a → 3b → 4a-c → 5a → 5b → 5c → 5e
```

### Büyük görev (yeni feature, >8 saat):
```
0a → 0b → 0c → 1a → 1b → 2a → 2b → 3a → 3b → 4a-c → 5a → 5b → 5c → 5d → 5e
```

---

## Agent Tipleri (Ruflo)

| Tip | Kullanım |
|-----|----------|
| `coder` | Implementation, refactoring |
| `tester` | Test yazma (TDD önce) |
| `reviewer` | Code review |
| `researcher` | Codebase araştırma, analiz |
| `architect` | Tasarım kararları |
| `security-auditor` | Güvenlik taraması |

## Sık Kullanılan Ruflo Komutları

```bash
ruflo hooks route       -t "görev"          # hangi agent?
ruflo hooks model-route -t "görev"          # haiku/sonnet/opus?
ruflo memory search     -q "keywords"       # geçmiş bul
ruflo memory store      -k "key" -v "value" # kaydet
ruflo swarm status                          # swarm takip
ruflo doctor                                # sistem sağlığı
```
