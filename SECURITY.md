# Güvenlik Politikası

**Türkçe** | [English](#english)

## Kapsam ve mevcut durum

OZERK **Aşama 0**'dadır: bu depoda kurucu belgeler, RFC taslakları ve `ozerk` CLI iskeleti bulunur. **Henüz çalışan bir işletim sistemi, cihaz üzerinde çalışan bir bileşen veya son kullanıcı ürünü yoktur.** Dolayısıyla bugün bildirilebilecek açıklar pratikte şu alanlarla sınırlıdır:

- `sdk/cli` içindeki kod ve bağımlılıkları,
- depo altyapısı ve CI iş akışları,
- kurucu belgelerdeki güvenlik açısından yanıltıcı veya hatalı ifadeler.

Manifesto §10.2 hangi tehditlere karşı mutlak güvenlik iddia edilmediğini açıkça sayar; §19.3 ise ileride ayrı bir **Güvenlik Müdahale Süreci** RFC'si öngörür. Bu belge, o RFC yazılana kadar geçerli olan geçici ve asgari politikadır.

## Açık bildirimi

Güvenlik açıklarını **herkese açık issue olarak açmayın.**

Bildirim için GitHub'ın özel güvenlik danışmanlığı (private security advisory) akışını kullanın:
**[Security → Report a vulnerability](https://github.com/celikbros/ozerk/security/advisories/new)**

Bildiriminizde mümkünse şunlara yer verin: etkilenen dosya veya bileşen, yeniden üretme adımları, etkinin ne olduğu ve varsa önerdiğiniz düzeltme.

## Ne bekleyebilirsiniz

Proje şu an tek kişilik ve gönüllü emekle yürütülmektedir; kurumsal bir müdahale ekibi yoktur. Bu nedenle **hizmet düzeyi taahhüdü (SLA) verilmez.** Gerçekçi beklenti:

- Bildirimin alındığına dair yanıt: birkaç gün içinde.
- Değerlendirme ve düzeltme: sorunun ciddiyetine ve mevcut zamana göre değişir.
- Düzeltme yayımlandığında, isterseniz bildirimde adınıza yer verilir.

Bu sınırları gizlemek yerine açıkça yazıyoruz; manifesto §24 (Dürüstlük Taahhüdü) bunu gerektirir.

## Kapsam dışı

- Üçüncü taraf projelerdeki açıklar (postmarketOS, Flatpak, clap gibi upstream bileşenler) — lütfen doğrudan ilgili projeye bildirin.
- Henüz var olmayan bileşenler hakkında varsayımsal senaryolar. Bunlar için issue veya RFC tartışması daha uygundur.

---

## English

*The Turkish text is normative in case of discrepancy.*

### Scope and current status

OZERK is at **Phase 0**: this repository contains founding documents, RFC drafts and the `ozerk` CLI skeleton. **There is no working operating system, no on-device component and no end-user product yet.** In practice, the vulnerabilities that can be reported today are limited to:

- the code and dependencies in `sdk/cli`,
- the repository infrastructure and CI workflows,
- statements in the founding documents that are misleading or wrong from a security standpoint.

Manifesto §10.2 explicitly lists the threats against which no absolute security is claimed; §19.3 foresees a separate **Security Response Process** RFC. This document is the interim, minimal policy in force until that RFC is written.

### Reporting a vulnerability

**Do not open a public issue for security vulnerabilities.**

Use GitHub's private security advisory flow:
**[Security → Report a vulnerability](https://github.com/celikbros/ozerk/security/advisories/new)**

Where possible, include: the affected file or component, reproduction steps, the impact, and any fix you would suggest.

### What to expect

The project is currently run by a single person on volunteer time; there is no corporate response team. Therefore **no service level agreement (SLA) is offered.** A realistic expectation:

- Acknowledgement of your report: within a few days.
- Assessment and fix: depends on severity and available time.
- When a fix is published, you will be credited if you wish.

We state these limits openly rather than hiding them; Manifesto §24 (Commitment to Honesty) requires it.

### Out of scope

- Vulnerabilities in third-party projects (upstream components such as postmarketOS, Flatpak, clap) — please report those to the project concerned.
- Hypothetical scenarios about components that do not exist yet. An issue or RFC discussion is a better place for those.
