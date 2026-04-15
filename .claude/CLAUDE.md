# claude-powerstack — Agent Konfigürasyonu

Bu repo Ruflo + Superpowers ikilisini tek kurulumla sunan bir başlangıç kiti.

## Kurulu Araçlar

| Araç | Rol | Komut |
|------|-----|-------|
| Ruflo (claude-flow) | Swarm orkestrasyon, hafıza, routing | `npx @claude-flow/cli@latest` |
| Superpowers | Geliştirme metodolojisi, skill'ler | `/skill <skill-adı>` |

## Workflow Başlatma

```
/workflow:ruflo <görev açıklaması>
```

Bu komut şu aşamaları otomatik çalıştırır:
- Phase 0: Hafıza yükle + git branch
- Phase 1: Agent + model routing
- Phase 2: Plan yaz (Superpowers)
- Phase 3: Swarm kur + paralel dispatch
- Phase 4: Code review döngüsü
- Phase 5: Doğrulama + commit + PR

## Agent Tipleri

```bash
npx @claude-flow/cli@latest agent spawn -t coder
npx @claude-flow/cli@latest agent spawn -t tester
npx @claude-flow/cli@latest agent spawn -t reviewer
```

## Hafıza

```bash
npx @claude-flow/cli@latest memory store --key "pattern" --value "..."
npx @claude-flow/cli@latest memory search --query "keywords"
```
