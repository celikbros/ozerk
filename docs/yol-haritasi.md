**Türkçe** | [English](#english)

# OZERK Yol Haritası

**Kurucu Metin — Sürüm 0.1 (Taslak)**
**17 Ağustos 2026**

> **Telefon senin. Veri senin. Karar senin.**

---

## 1. Amaç ve Kapsam

Bu belge, [OZERK Proje Manifestosu](OZERK_Proje_Manifestosu.md) §21'de tanımlanan uygulama aşamalarını korur ve yalnızca **ilk 12 ayı** somutlaştırır. Aşamaların sırası ve içeriği değişmez; bu yol haritası, o aşamaların ilk adımlarının hangi dönemde, hangi kanıtla atılacağını tanımlar.

Bu yol haritası bir taahhüt değil, bir niyet ve çalışma planıdır. Proje tek kişiyle başlamaktadır; hedefler bu gerçeğe göre boyutlandırılmıştır. Plan gerçeklikle çeliştiğinde plan güncellenir ve değişiklik açıkça yayımlanır.

## 2. Çalışma İlkeleri

- **Upstream'e yaslan:** postmarketOS/Mobian, Phosh, Flatpak ve portallar, UnifiedPush, Waydroid gibi mevcut özgür yapıtaşları yeniden kullanılır. Sıfırdan icat edilmez; OZERK'in katkısı bütünleştirme, standartlaştırma ve kullanıcı-egemenlik katmanıdır.
- **Hayatta olma kanıtı:** Her dönem, çalışır durumda gösterilebilen bir demo kapısıyla (D1, D2, D3) kapanır. Demo yoksa dönem kapanmış sayılmaz.
- **Açık geliştirme:** Tüm çalışma GitHub'da `celikbros/ozerk` monorepo'sunda açık yürütülür. Başarısız denemeler de notlarıyla birlikte depoda kalır.
- **Ölçülü iddia:** Prototip prototip olarak, taslak taslak olarak adlandırılır. Çalışmayan hiçbir şey çalışıyor gibi sunulmaz.

## 3. Ay 0–2 — Kurucu Temel

Manifesto §21 karşılığı: Aşama 0.

Hedefler:

- **Kurucu dokümanlar (bu depo):** Manifesto, yol haritası, lisans yapısı (`LICENSES/`), katkı ve yönetişim taslağı — hepsi iki dilli.
- **Üç taslak RFC:**
  - RFC-0002 — Taban dağıtım seçimi (postmarketOS / Mobian karşılaştırması, karar ölçütleri),
  - RFC-0003 — Uygulama paket formatı (Flatpak ve portal modeli merkezli değerlendirme),
  - RFC-0004 — Tarayıcı motoru seçimi (mobil Linux'ta gerçekçi seçenekler ve ödünleşimler).
- **`ozerk` CLI iskeleti (Rust):** Komut ağacı, `--help`, sürümleme, CI. Bu aşamada komutlar gerçek iş yapmaz; iskelet olduğu belgede açıkça yazılır.
- **QEMU'da taban dağıtım denemeleri:** postmarketOS ve Mobian imajlarının QEMU'da açılışı, Phosh oturumu, gözlem notlarının depoda yayımlanması.

Dönem çıktısı: yayımlanmış kurucu dokümanlar, üç RFC taslağı, derlenen CLI iskeleti, tekrarlanabilir QEMU açılış notları.

## 4. Ay 2–4 — İlk Görünür İmaj

Manifesto §21 karşılığı: Aşama 1'in başlangıcı.

Hedefler:

- **Markalı shell konseptiyle QEMU imajı:** Seçilen taban dağıtım üzerine Phosh tabanlı, OZERK kimliği taşıyan bir imaj. İlk açılışta **hesapsız kurulum akışı**: dil, ağ, şifreleme — hiçbir adımda hesap istenmez.
- **Flatpak portal sandbox denemesi:** Örnek bir uygulamanın dosya ve kamera portallarıyla sınırlandırılması; iznin reddedildiğinde ne olduğunun belgelenmesi.
- **`ozerk init` ve `ozerk build` ilk gerçek işlev:** `init` bir uygulama proje şablonu üretir; `build` Flatpak manifest'inden kurulabilir paket çıkarır.

**Demo kapısı D1 — hayatta olma kanıtı:** QEMU'da açılan, hesap istemeyen, kurulum akışı baştan sona tamamlanabilen imaj. Ekran kaydı ve imajı yeniden üretme talimatı depoda yayımlanır.

## 5. Ay 4–8 — Guard v0 ve Çekirdek Uygulamalar

Manifesto §21 karşılığı: Aşama 3'ün emülatörde çalışan öncüsü ve Aşama 4'ün ilk tohumu.

Hedefler:

- **OZERK Guard v0 (emülatörde):** Uygulama başına ağ erişimini aç/kapa ve uygulamaların bağlandığı alan adlarının günlüğü. Mevcut Linux mekanizmaları (nftables, cgroup, DNS günlüğü) üzerine kurulur; v0 bir prototiptir ve güvenlik garantisi iddia etmez.
- **Gizlilik Merkezi v0 taslağı:** Tasarım dokümanı ve basit bir arayüz taslağı; Guard günlüklerinin kullanıcıya nasıl gösterileceği.
- **3–5 çekirdek uygulamanın seçimi ve paketlenmesi:** Tarayıcı, mesajlaşma, dosyalar, takvim/e-posta gibi adaylar mevcut özgür ekosistemden (GNOME/Phosh çevresi) seçilir, `ozerk build` ile paketlenir. Sıfırdan uygulama yazılmaz.

**Demo kapısı D2 — hayatta olma kanıtı:** Guard'ın canlı bir gösterimde, seçilen bir uygulamanın belirli bir alan adına erişimini engellemesi ve bu olayın günlükte görünmesi.

## 6. Ay 8–12 — İmzalı Depo v0 ve Gerçek Cihaz

Manifesto §21 karşılığı: Aşama 2'nin ilk adımı ve Aşama 4'ün altyapı öncüsü.

Hedefler:

- **İmzalı yazılım deposu v0:** F-Droid sunucu araçları veya OSTree tabanlı bir Flatpak deposu ile kriptografik olarak imzalı yayın; anahtar yönetimi ve imza doğrulama süreci belgelenir.
- **İlk gerçek cihaz denemesi:** Mainline Linux desteği olgun, postmarketOS/Mobian'ın iyi desteklediği bir cihaz seçilir (seçim ayrı bir RFC ile gerekçelendirilir) ve OZERK imajı bu cihazda açılır.
- **İç dogfood:** Kurucu, cihazı ikinci cihaz olarak günlük hayatta taşır. Çalışan ve çalışmayan özellikler tablosu, pil gözlemleri ve hata kayıtları **yayımlanmış metrikler** olarak depoda tutulur.

**Demo kapısı D3 — hayatta olma kanıtı:** Gerçek cihazda mobil şebeke üzerinden bir telefon araması. Modem ve cihaz desteği buna izin vermezse bu açıkça raporlanır ve D3, cihazda çalışan Wi-Fi + Guard gösterimiyle daraltılmış olarak tanımlanır; daralma gizlenmez.

## 7. Demo Kapıları Özeti

| Kapı | Dönem sonu | Kanıt |
|------|-----------|-------|
| D1 | Ay 4 | QEMU'da açılan, hesap istemeyen, kurulumu tamamlanabilen imaj |
| D2 | Ay 8 | Guard'ın bir alan adını canlı engellemesi ve günlükte göstermesi |
| D3 | Ay 12 | Gerçek cihazda arama (veya açıkça raporlanmış daraltılmış kapsam) |

## 8. 12 Ay Sonunda Ölçülebilir Durum

Abartısız hedef: 12 ayın sonunda OZERK'in elinde şunlar olmalıdır.

- İki dilli kurucu dokümanlar ve en az üç karara bağlanmış RFC,
- `init` ve `build` komutları gerçek iş yapan bir `ozerk` CLI,
- Hesapsız kurulum akışına sahip, yeniden üretilebilir bir QEMU imajı,
- Emülatörde çalışan Guard v0 ve 3–5 paketlenmiş çekirdek uygulama,
- İmzalı bir depo v0 ve en az bir gerçek cihazda açılan sistem,
- Yayımlanmış dogfood metrikleri — iyi ve kötü sonuçlarıyla.

Bu liste bir başarı ilanı değil, bir ölçüm çubuğudur. Eksik kalan her madde, gerekçesiyle birlikte raporlanır.

## 9. Uzun Vade — Manifesto §21 ile Bağ

İlk 12 ayın ötesi, manifestodaki sırayı izler ve bu belgede süre verilmez; ilerleme **kaynak bulundukça** olacaktır:

- **Aşama 2 — Referans telefon:** D3 cihazı üzerinde telefonculuk, güç yönetimi, şifreli kullanıcı verisi ve güvenli güncellemenin olgunlaştırılması.
- **Aşama 3 — OZERK Guard:** Guard v0'ın portallar, arka plan bütçeleri ve Gizlilik Merkezi ile tam modele taşınması.
- **Aşama 4 — Uygulama ekosistemi:** Depo v0'ın federatif resmî depoya, paket setinin yaklaşık 25 temel uygulamaya genişletilmesi; sağlayıcıdan bağımsız push (UnifiedPush).
- **Aşama 5 — Kullanıcı pilotu:** Kurucu dışındaki gerçek kullanıcılarla günlük kullanım testleri.
- **Aşama 6 — Ticari cihaz:** Donanım ortaklığı; yalnızca önceki aşamalar gerçek kullanımda kendini kanıtlarsa.

Tek kişilik bir başlangıcın bu aşamaların tamamını tek başına taşıyamayacağı bilinmektedir. Katkıcı ve kaynak bulmak, ilk 12 ayın örtük hedeflerinden biridir; ancak hiçbir dönem hedefi başkasının katılımına bağlı planlanmamıştır.

## 10. Riskler ve Dürüst Varsayımlar

- Tek kişi çalışması: hastalık, iş yükü ve öncelik değişimleri takvimi doğrudan etkiler.
- Upstream bağımlılığı: taban dağıtım ve Phosh'taki değişiklikler yeniden çalışma gerektirebilir.
- Donanım gerçeği: mobil Linux'ta modem, kamera ve güç yönetimi en kırılgan alanlardır; D3'ün daraltılma ihtimali bu yüzden baştan tanımlanmıştır.
- Bu belge canlıdır: her dönem sonunda gözden geçirilir; sapmalar silinmez, kayıt altına alınır.

---

<a id="english"></a>

# OZERK Roadmap

**Founding Document — Version 0.1 (Draft)**
**17 August 2026**

> **Your phone. Your data. Your decision.**

> The Turkish text is normative in case of discrepancy.

## 1. Purpose and Scope

This document preserves the implementation stages defined in [OZERK Project Manifesto](OZERK_Proje_Manifestosu.md) §21 and makes only the **first 12 months** concrete. The order and content of the stages do not change; this roadmap defines in which period, and with what proof, the first steps of those stages will be taken.

This roadmap is not a commitment but a statement of intent and a working plan. The project starts with one person; the goals are sized to that reality. When the plan conflicts with reality, the plan is updated and the change is published openly.

## 2. Working Principles

- **Lean on upstream:** Existing free building blocks such as postmarketOS/Mobian, Phosh, Flatpak and portals, UnifiedPush, and Waydroid are reused. Nothing is reinvented from scratch; OZERK's contribution is the integration, standardization, and user-sovereignty layer.
- **Proof of life:** Each period closes with a working, demonstrable demo gate (D1, D2, D3). Without the demo, the period does not count as closed.
- **Open development:** All work is done in the open in the `celikbros/ozerk` monorepo on GitHub. Failed attempts also remain in the repository together with their notes.
- **Measured claims:** A prototype is called a prototype, a draft a draft. Nothing that does not work is presented as working.

## 3. Months 0–2 — Founding Groundwork

Manifesto §21 correspondence: Phase 0.

Goals:

- **Founding documents (this repository):** Manifesto, roadmap, license structure (`LICENSES/`), contribution and governance draft — all bilingual.
- **Three draft RFCs:**
  - RFC-0002 — Base distribution choice (postmarketOS / Mobian comparison, decision criteria),
  - RFC-0003 — Application package format (evaluation centered on Flatpak and the portal model),
  - RFC-0004 — Browser engine choice (realistic options and trade-offs on mobile Linux).
- **`ozerk` CLI skeleton (Rust):** Command tree, `--help`, versioning, CI. At this stage the commands do no real work; the documentation states plainly that it is a skeleton.
- **Base distribution trials in QEMU:** Booting postmarketOS and Mobian images in QEMU, a Phosh session, and publishing the observation notes in the repository.

Period output: published founding documents, three RFC drafts, a compiling CLI skeleton, reproducible QEMU boot notes.

## 4. Months 2–4 — First Visible Image

Manifesto §21 correspondence: the beginning of Phase 1.

Goals:

- **QEMU image with a branded shell concept:** A Phosh-based image carrying OZERK identity on top of the chosen base distribution. On first boot, an **account-free setup flow**: language, network, encryption — no step asks for an account.
- **Flatpak portal sandbox trial:** Constraining a sample application through the file and camera portals; documenting what happens when permission is denied.
- **First real functionality for `ozerk init` and `ozerk build`:** `init` generates an application project template; `build` produces an installable package from a Flatpak manifest.

**Demo gate D1 — proof of life:** An image that boots in QEMU, asks for no account, and whose setup flow can be completed end to end. A screen recording and instructions to reproduce the image are published in the repository.

## 5. Months 4–8 — Guard v0 and Core Applications

Manifesto §21 correspondence: a precursor of Phase 3 running in the emulator, and the first seed of Phase 4.

Goals:

- **OZERK Guard v0 (in the emulator):** Per-application network on/off switching and a log of the domain names applications connect to. Built on existing Linux mechanisms (nftables, cgroups, DNS logging); v0 is a prototype and claims no security guarantees.
- **Privacy Center v0 draft:** A design document and a simple interface mockup; how Guard logs will be shown to the user.
- **Selection and packaging of 3–5 core applications:** Candidates such as browser, messaging, files, calendar/e-mail are chosen from the existing free ecosystem (the GNOME/Phosh environment) and packaged with `ozerk build`. No applications are written from scratch.

**Demo gate D2 — proof of life:** In a live demonstration, Guard blocks a chosen application's access to a specific domain name, and the event appears in the log.

## 6. Months 8–12 — Signed Repository v0 and Real Hardware

Manifesto §21 correspondence: the first step of Phase 2 and an infrastructure precursor of Phase 4.

Goals:

- **Signed software repository v0:** Cryptographically signed publishing using F-Droid server tools or an OSTree-based Flatpak repository; key management and signature verification are documented.
- **First real-device trial:** A device with mature mainline Linux support, well supported by postmarketOS/Mobian, is selected (the choice is justified in a separate RFC) and the OZERK image is booted on it.
- **Internal dogfooding:** The founder carries the device as a secondary daily device. A table of working and non-working features, battery observations, and bug records are kept in the repository as **published metrics**.

**Demo gate D3 — proof of life:** A phone call over the mobile network on real hardware. If modem and device support do not allow this, it is reported openly and D3 is redefined in narrowed form as Wi-Fi plus a Guard demonstration on the device; the narrowing is not hidden.

## 7. Demo Gate Summary

| Gate | End of period | Proof |
|------|---------------|-------|
| D1 | Month 4 | An image that boots in QEMU, asks for no account, and completes setup |
| D2 | Month 8 | Guard blocking a domain name live and showing it in the log |
| D3 | Month 12 | A phone call on real hardware (or an openly reported narrowed scope) |

## 8. Measurable State After 12 Months

The unexaggerated goal: at the end of 12 months, OZERK should have the following.

- Bilingual founding documents and at least three decided RFCs,
- An `ozerk` CLI whose `init` and `build` commands do real work,
- A reproducible QEMU image with an account-free setup flow,
- Guard v0 running in the emulator and 3–5 packaged core applications,
- A signed repository v0 and a system booting on at least one real device,
- Published dogfood metrics — with both the good and the bad results.

This list is not a declaration of success but a measuring stick. Every item left incomplete is reported together with its reason.

## 9. Long Term — Connection to Manifesto §21

Everything beyond the first 12 months follows the order in the manifesto, and this document assigns no durations; progress will happen **as resources are found**:

- **Phase 2 — Reference phone:** Maturing telephony, power management, encrypted user data, and secure updates on the D3 device.
- **Phase 3 — OZERK Guard:** Carrying Guard v0 to the full model with portals, background budgets, and the Privacy Center.
- **Phase 4 — Application ecosystem:** Expanding repository v0 into the federated official repository and the package set toward roughly 25 essential applications; provider-independent push (UnifiedPush).
- **Phase 5 — User pilot:** Daily-use testing with real users beyond the founder.
- **Phase 6 — Commercial device:** A hardware partnership; only if the earlier stages prove themselves in real use.

It is understood that a one-person start cannot carry all of these stages alone. Finding contributors and resources is one of the implicit goals of the first 12 months; however, no period goal is planned to depend on anyone else's participation.

## 10. Risks and Honest Assumptions

- One-person effort: illness, workload, and shifting priorities directly affect the schedule.
- Upstream dependency: changes in the base distribution and Phosh may require rework.
- Hardware reality: on mobile Linux, the modem, camera, and power management are the most fragile areas; this is why the possible narrowing of D3 is defined from the start.
- This document is alive: it is reviewed at the end of each period; deviations are not erased, they are recorded.
