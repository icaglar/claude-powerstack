# Ruflo + Superpowers Full Development Workflow

Tam geliştirme döngüsünü Ruflo ve Superpowers skill'leri ile kusursuz şekilde uygula.

**Announce at start:** "Ruflo + Superpowers workflow başlatılıyor..."

---

## PHASE 0 — Bağlam Kur

### 0a. Geçmiş Hafızayı Yükle
```bash
# Görev anahtar kelimelerini elle yaz (örn: "auth jwt login")
ruflo memory search --query "<görev anahtar kelimeleri>"
ruflo memory search --query "$(git branch --show-current)"
```
Bulunan pattern'ları ve geçmiş kararları not al. Aynı hatayı tekrar yapma.

### 0b. Oturum Geri Yükle (yalnızca yarım kalan görevlerde)
Sadece şu durumda çalıştır:
- Önceki oturumda bu feature için swarm başlatılmıştı ve yarım kaldı
- Yeni görev başlatıyorsan bu adımı **atla**

```bash
ruflo hooks session-restore
```

### 0c. Git Branch Oluştur
```bash
git checkout main && git pull          # daima güncel base'den başla
git checkout -b feature/<kısa-açıklama>
# Karmaşık görevlerde worktree da kullanılabilir (opsiyonel)
```

---

## PHASE 1 — Keşif ve Yönlendirme

### 1a. Brainstorming (Karmaşık / Belirsiz Görevler)
Görev büyükse veya net değilse — routing'den ÖNCE yap:
- Superpowers `/brainstorming` skill'ini uygula
- Çıktı: spec dosyası → `docs/superpowers/specs/YYYY-MM-DD-<feature>.md`
- Basit, net görevlerde bu adımı atla.

### 1b. Agent ve Model Routing
```bash
ruflo hooks route       -t "<görev açıklaması>"
ruflo hooks model-route -t "<görev açıklaması>"
```
Önerilen agent tiplerini ve modeli (haiku/sonnet/opus) not al. Bu öneri Phase 3'te agent spawn ederken kullanılır.

---

## PHASE 2 — Planlama

### 2a. Plan Yaz
Superpowers `/writing-plans` skill'ini uygula:
- Girdi: spec dosyası (1a çıktısı) veya görev açıklaması
- Çıktı: `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`
- Plan dosyasına ekle: `> REQUIRED SUB-SKILL: superpowers:subagent-driven-development`

Plan şunları içermeli:
- Oluşturulacak / değiştirilecek dosya haritası
- Her adım `- [ ]` checkbox formatında (15-30 dakikalık granülarite)
- TDD sırası: test yaz → fail gör → implement → pass gör
- Migration / breaking change uyarıları

---

## ⏸️ ONAY NOKTASI 1 — Plan Onayı (ZORUNLU)

> **DUR — implementasyona geçmeden önce kullanıcıdan onay al.**

Kullanıcıya şunu sun:
1. Plan dosyasının yolunu: `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`
2. Kısa özet: kaç dosya değişecek, hangi riskler var, tahmini kapsam
3. Açık soru: **"Plan uygun mu, Phase 3'e geçilsin mi?"**

Kullanıcı **"evet / devam / go / tamam / olur"** demeden Phase 3'e GEÇİLMEZ.
Kullanıcı değişiklik isterse planı güncelle ve tekrar onay iste.

---

## PHASE 3 — Uygulama (TDD Sırasıyla)

### Pre-Task Kaydı (Phase 3 başında çalıştır)
```bash
ruflo hooks pre-task -d "<görev açıklaması>" --type implementation
```

### 3a. Swarm Kur ve Başlat _(Orta / Büyük görevler — küçük görevlerde atla)_
```bash
ruflo swarm init --topology hierarchical --max-agents 6 --strategy specialized
ruflo swarm start -o "<feature hedefi>" -s development
```

### 3b. Agent'ları Spawn Et
```bash
# Büyük görevlerde mimari karar ÖNCE → architect ÖNCE spawn edilmeli
ruflo agent spawn -t architect  # büyük görevlerde: tasarım kararları için
ruflo agent spawn -t tester     # TDD: test yazan agent daima coderdan önce
ruflo agent spawn -t coder      # bağımsız parçalar için birden fazla olabilir

# Phase 1b routing çıktısına göre modeli seç
# Küçük görev → sadece coder yeterli
```

### 3c. Plan'dan Task'ları Oluştur _(Orta / Büyük görevler)_
Plan dosyasındaki her bağımsız iş bloğu için ruflo task aç:

```bash
# Test görevleri (önce — TDD)
ruflo task create -t testing        -d "failing testleri yaz: <modül>"

# Implementation görevleri (paralel çalışabilir)
ruflo task create -t implementation -d "backend: <servis/endpoint yaz>"
ruflo task create -t implementation -d "frontend: <bileşen yaz>"
ruflo task create -t migration      -d "migration: <tablo/schema>"

# Task'ları ilgili agent'a ata
ruflo task assign <test-task-id>    --agent tester
ruflo task assign <backend-task-id> --agent coder
ruflo task assign <frontend-task-id> --agent coder
```
> **Not**: `ruflo task create` komutunun çıktısındaki ID'yi kopyala, assign komutunda kullan.

### 3d. Paralel Dispatch (Superpowers)
Superpowers `/dispatching-parallel-agents` skill'ini uygula — Claude Code'un
Agent tool'u ile ruflo task'larını paralel olarak gerçekleştir.

**Zorunlu sıra:**
1. architect agent → tasarım kararı (gerekirse, önce bitir)
2. tester agent → failing testler
3. coder agent(lar) → paralel implement

### 3e. İlerlemeyi Takip Et
```bash
ruflo swarm status        # genel durum, agent sayısı
ruflo task list --all     # tüm task'lar ve durumları
ruflo task status <id>    # belirli task detayı
ruflo agent metrics       # agent performans metrikleri
```

**Phase 4'e geçmeden önce tüm task'ların tamamlandığını doğrula:**
```bash
ruflo task list --all | grep -v "completed"
# Çıktı boşsa tüm task'lar tamamlanmış → Phase 4'e geç
```

**Hata durumunda:**
```
1. Superpowers /systematic-debugging uygula
2. ruflo task retry <task-id> ile yeniden dene
3. Aynı hata tekrar ederse: ruflo agent spawn -t architect → kök neden analizi
4. ruflo agent health ile agent sağlığını kontrol et
```

---

## PHASE 4 — Code Review

### 4a. Review İste
Superpowers `/requesting-code-review` uygula.

Reviewer'a şunlara bakmasını söyle:
- `blocker`: güvenlik açığı, veri kaybı riski, test eksikliği
- `suggestion`: performans, okunabilirlik
- `nit`: stil, opsiyonel
- **Plan checkout'u**: 2a'daki plan dosyasındaki tüm checkbox'lar işaretli mi?

### 4b. Reviewer Agent Çalıştır
```bash
ruflo agent spawn -t reviewer
```

### 4c. Review Bulgularını Al ve Uygula
Superpowers `/receiving-code-review` uygula:
- `blocker` → hemen düzelt → **Phase 4a'ya geri dön** (döngü tamamlanana kadar devam)
- `suggestion` → değerlendir, gerekirse uygula
- `nit` → opsiyonel, zaman varsa uygula

---

## PHASE 5 — Tamamlama

### 5a. Doğrulama
Superpowers `/verification-before-completion` uygula:
- [ ] Tüm testler geçiyor (`npm test` / `pytest`)
- [ ] Build temiz (`npm run build` / `tsc --noEmit`)
- [ ] Lint hataları yok (`npm run lint` / `ruff check .`)
- [ ] Plan'daki tüm checkbox'lar işaretli (`docs/superpowers/plans/...` dosyasına bak)
- [ ] Breaking change varsa dokümante edildi
- [ ] Güvenlik açığı yok

### 5b. Branch Commit'lerini Düzenle
Superpowers `/finishing-a-development-branch` uygula:
- Commit'leri düzenle (squash gerekirse)
- Commit mesajları conventional commits formatında
- ⚠️ `git push` bu adımda yapılmaz — ONAY 2 sonrasına bırak

### 5c. PR Oluştur

> **⏸️ ONAY NOKTASI 2 — PR Onayı (ZORUNLU)**
>
> PR açmadan önce kullanıcıya şunu göster:
> - Branch adı ve commit listesi (`git log --oneline main..HEAD`)
> - Test sonuçları (pass/fail özeti)
> - Breaking change var mı?
> - Taslak PR başlığı ve body'si
>
> Kullanıcı **"evet / push / pr aç"** demeden aşağıdakiler ÇALIŞTIRILMAZ.

```bash
git push -u origin <branch>        # onay sonrası önce push
gh pr create --title "<feat|fix>: kısa açıklama" --body "..."
```
PR body şunları içermeli:
- Neyi ve neden değiştirdi
- Test planı
- Breaking change varsa migration adımları

### 5d. Post-Task Kaydı ve Temizlik
```bash
ruflo hooks post-task -d "<görev>" --outcome success
ruflo swarm shutdown                # swarm açıldıysa kapat (kaynak sızıntısını önler)
```

### 5e. Hafızaya Kaydet
```bash
ruflo memory store \
  --key "<feature>-pattern" \
  --value "<öğrenilen pattern, karar, gotcha>" \
  --namespace patterns

ruflo memory store \
  --key "<feature>-decisions" \
  --value "<mimari kararlar ve gerekçeleri>" \
  --namespace decisions
```

---

## Hızlı Referans

### Küçük görev (tek dosya, <2 saat):
```
0a → 0c → 1b → [3b: sadece coder] → 4a-c → 5a → 5b → ⏸️ONAY2 → 5c → 5d → 5e
```

### Orta görev (birkaç dosya, 2-8 saat):
```
0a → 0c → 1a → 1b → 2a → ⏸️ONAY1 → [pre-task] → 3a → 3b → 3c → 3d → 3e → 4a-c → 5a → 5b → ⏸️ONAY2 → 5c → 5d → 5e
```

### Büyük görev (yeni feature, >8 saat):
```
0a → 0b → 0c → 1a → 1b → 2a → ⏸️ONAY1 → [pre-task] → 3a → 3b → 3c → 3d → 3e → 4a-c → 5a → 5b → ⏸️ONAY2 → 5c → 5d → 5e
```

---

## Agent Tipleri (Ruflo)

| Tip | Kullanım |
|-----|----------|
| `architect` | Tasarım kararları — büyük görevlerde önce spawn et |
| `tester` | Test yazma (TDD: architect'ten sonra, coder'dan önce) |
| `coder` | Implementation, refactoring |
| `reviewer` | Code review |
| `researcher` | Codebase araştırma, analiz |
| `security-auditor` | Güvenlik taraması |

## Sık Kullanılan Ruflo Komutları

```bash
ruflo hooks route       -t "görev"               # hangi agent?
ruflo hooks model-route -t "görev"               # haiku/sonnet/opus?
ruflo memory search     --query "keywords"        # geçmiş bul
ruflo memory store      --key "k" --value "v"    # kaydet
ruflo swarm status                               # swarm takip
ruflo task list --all                            # task listesi
ruflo doctor                                     # sistem sağlığı
```
