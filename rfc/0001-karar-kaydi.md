# OZERK RFC-0001: Karar Kaydı ve Açık Kararlar

**Türkçe** | [English](#english)

- **RFC:** 0001
- **Başlık:** Karar Kaydı ve Açık Kararlar
- **Durum:** Kabul (yaşayan belge)
- **Tarih:** 2026-08-17
- **Lisans:** CC BY-SA 4.0

---

## 1. Bu belge hakkında

Bu belge, OZERK projesinin alınmış kurucu kararlarını ve henüz alınmamış kritik kararları tek yerde kayıt altına alır.

Bu bir yaşayan belgedir:

- Alınmış bir karar ancak yeni bir RFC ile değiştirilebilir; değişiklik bu kayda işlenir.
- Açık bir karar, ilgili RFC kabul edildiğinde "Alınmış Kararlar" bölümüne taşınır.
- Aşağıda anılan gelecek RFC numaraları taslaktır; ilgili RFC yazılana kadar bağlayıcı değildir.

Bu belge, manifestonun (`docs/OZERK_Proje_Manifestosu.md`) yerine geçmez; manifesto ile çelişen hiçbir karar geçerli değildir.

---

## 2. Alınmış Kararlar

### D1 — Lisans modeli: karma

- **Karar:** OZERK karma lisans modeli kullanır. Sistem ve işletim sistemi bileşenleri GPL-3.0-or-later, SDK / CLI / kütüphaneler Apache-2.0, dokümanlar CC BY-SA 4.0 ile lisanslanır. Tam lisans metinleri `LICENSES/` dizinindedir.
- **Tarih:** 2026-08-17
- **Gerekçe:** Copyleft, sistem bileşenlerinin kapalı türevlerle özgürlüğünü yitirmesini engeller. Geliştiricinin uygulamasına gömeceği SDK ve kütüphanelerde ise izinli lisans, ticari kullanım dahil benimsenme engelini düşürür. Dokümanlarda CC BY-SA, kurucu metinlerin açık kalmasını ve türevlerinin de açık kalmasını sağlar.

### D2 — Dil politikası: iki dilli eşit, çelişkide Türkçe normatif

- **Karar:** Her kurucu belge hem Türkçe hem İngilizce içerir; iki dil içerik olarak eşdeğerdir. Çelişki hâlinde Türkçe metin bağlayıcıdır.
- **Tarih:** 2026-08-17
- **Gerekçe:** Projenin kökü Türkçedir; uluslararası katkı ise İngilizce olmadan mümkün değildir. Tek bir normatif dil belirlemek, yorum uyuşmazlıklarını baştan önler. Çeviri hatası bulunduğunda düzeltilir; anlam Türkçe metinden alınır.

### D3 — Upstream-öncelikli strateji

- **Karar:** OZERK, mevcut açık kaynak yapıtaşlarını yeniden kullanır: postmarketOS / Mobian, Phosh / Plasma Mobile, Flatpak ve portallar, F-Droid araç zinciri, UnifiedPush, Waydroid ve benzerleri. Sıfırdan icat edilmez; fork son çaredir ve ancak upstream'e katkı yolu tükendiğinde düşünülür. Değişiklikler mümkün olduğunca upstream'e gönderilir.
- **Tarih:** 2026-08-17
- **Gerekçe:** Mobil Linux ekosisteminde yıllardır olgunlaşan bileşenler vardır; bunları yeniden yazmak projenin kaynaklarını aşar ve topluluğu böler. OZERK'in katma değeri alt katmanları yeniden icat etmek değil, kullanıcı egemenliği katmanını (Guard, manifest standardı, repository modeli) bu yapıtaşlarının üzerine kurmaktır.

### D4 — Monorepo başlangıcı

- **Karar:** Geliştirme, GitHub üzerinde `celikbros/ozerk` monorepo'sunda açık yürütülür. Bileşenler büyüyüp bağımsız yaşam döngüsü kazandığında ayrı depolara bölünebilir.
- **Tarih:** 2026-08-17
- **Gerekçe:** Aşama 0'da içerik ağırlıkla belge ve küçük araçlardan oluşur; tek depo koordinasyon maliyetini düşürür, standartların ve kodun birlikte sürümlenmesini kolaylaştırır. Bölünme kararı ihtiyaç doğduğunda verilir; baştan parçalamak erken optimizasyondur.

### D5 — İlk hedef: Aşama 0 dokümanları ve erken görünür demo

- **Karar:** İlk hedef, Aşama 0 kurucu dokümanlarının tamamlanması ve erken görünür bir demodur: `ozerk` CLI iskeleti (manifestodaki geliştirici akışının çalışan başlangıcı).
- **Tarih:** 2026-08-17
- **Gerekçe:** Yalnızca metin üreten bir proje güven vermez; yalnızca kod üreten bir proje ise yönünü kaybeder. Küçük ama çalışan bir CLI iskeleti, standartların uygulanabilirliğini erken test eder ve projenin durumu hakkında dürüst bir gösterge sunar: henüz platform kodu yoktur ve bu gizlenmez.

---

## 3. Açık Kararlar

Aşağıdaki kararlar alınmamıştır. Her biri kendi RFC'sinde tartışılıp karara bağlanacaktır.

### A1 — Tarayıcı motoru stratejisi

- **Soru:** "Web birinci sınıf uygulama platformudur" vaadinin (manifesto 6.6) üzerine kurulacağı motor ve tarayıcı hangisi olacak?
- **Neden kritik:** Paketlenmiş ve hosted web uygulamaları (uygulama sınıfları C ve D) doğrudan bu karara bağlıdır. Yanlış seçim, ya sürdürülemez bir bakım yükü ya da zayıf bir web deneyimi anlamına gelir.
- **Seçenekler:**
  - WebKitGTK tabanlı web uygulama runtime'ı + sistem tarayıcısı olarak mevcut, bakımı süren bir tarayıcının paketlenmesi (örn. GNOME Web). Mobil Linux'ta en olgun gömme yolu; motor bakımı upstream'de kalır.
  - Chromium tabanı (örn. ungoogled varyant): en geniş web uyumluluğu; ancak build maliyeti ve Google bağımlılığını ayıklama yükü ağırdır.
  - Gecko tabanı: bağımsızlık açısından değerli; ancak mobil Linux'ta gömme (embedding) desteği zayıftır.
  - Motor fork'u: **reddedilmiştir.** Bir tarayıcı motorunu sürdürme maliyeti bu projenin ölçeğinin tamamen dışındadır; bu seçenek RFC'de yeniden açılmayacaktır.
- **Ertelendiği RFC:** [RFC-0004 — Web Uygulama Profili ve Tarayıcı Motoru](0004-tarayici-motoru.md) (taslak yazıldı)

### A2 — Taban dağıtım seçimi

- **Soru:** OZERK OS hangi dağıtımın üzerine kurulacak: postmarketOS (Alpine, musl) mi, Mobian (Debian, glibc) mi?
- **Neden kritik:** Paketleme, güvenlik güncellemesi akışı, cihaz desteği, musl/glibc uyumluluğu (Waydroid ve bazı ikili yazılımlar dahil) ve build altyapısının tamamı bu tabana bağlıdır. Geç değiştirmek pahalıdır.
- **Seçenekler:**
  - postmarketOS: en geniş cihaz portu topluluğu, küçük taban sistem, mobil odaklı araçlar; musl kaynaklı uyumluluk sınırları.
  - Mobian: Debian'ın paket zenginliği ve glibc uyumluluğu; desteklenen cihaz sayısı daha dar.
  - İkisiyle birden başlayıp ölçüm sonrası daraltma: öğrenme değeri yüksek, ancak süreklilik maliyeti iki katına çıkar.
- **Ertelendiği RFC:** [RFC-0002 — Taban Dağıtım Seçimi](0002-taban-dagitim.md) (taslak yazıldı)

### A3 — Uygulama paket formatı

- **Soru:** OZERK App standardı hangi paket formatı üzerine kurulacak?
- **Neden kritik:** Manifesto Bölüm 13, her uygulamanın ağ erişim modelini ve telemetri beyanını kurulumdan önce ilan etmesini gerektirir. Mevcut formatlar bu beyanları ifade etmez. Format kararı sandbox modelini, mağazayı ve SDK'yı belirler.
- **Seçenekler:**
  - Flatpak üst kümesi (**öne çıkan öneri**): Flatpak paketleri ve portalları aynen kullanılır; manifeste OZERK eklentileri (ağ profili, telemetri beyanı, build doğrulama alanları) eklenir. OZERK eklentilerini tanımayan sistemlerde paket sıradan Flatpak olarak çalışır.
  - Saf Flatpak + ayrı politika dosyası: standarda dokunmaz, ancak beyan ile paket birbirinden kopar.
  - Özgün format: manifesto ihtiyaçlarını en doğrudan karşılar; upstream-öncelikli stratejiyle (D3) çelişir ve ekosistem sıfırdan başlar.
- **Ertelendiği RFC:** [RFC-0003 — Uygulama Paket Formatı ve Manifest Standardı](0003-paket-formati.md) (taslak yazıldı)

### A4 — Referans donanım yolu

- **Soru:** İlk referans cihaz ne olacak: mainline Linux desteği olgun mevcut bir cihaza port mu (örn. SDM845 sınıfı cihazlar veya PinePhone Pro), yoksa özel donanım mı?
- **Neden kritik:** Aşama 2'nin tamamı bu cihaza bağlıdır. Ayrıca çözülmesi gereken bir paradoks vardır: mainline Linux desteği iyi olan cihazlarda kullanıcı denetimli verified boot genellikle yoktur; verified boot altyapısı güçlü cihazlar ise nadiren mainline'dadır. Manifesto hem doğrulanmış açılışı (6.10) hem donanım gerçeklerinin gizlenmemesini (6.14) ister — referans cihazın özgürlük envanteri bu gerilimi dürüstçe belgelemek zorundadır.
- **Seçenekler:**
  - SDM845 sınıfı port: güçlü mainline desteği, ucuz ve bulunabilir ikinci el cihazlar; verified boot ve batarya ömrü sınırları.
  - PinePhone Pro: Linux-öncelikli tasarım, açık topluluk; performans ve kamera sınırları.
  - Özel donanım: uzun vadeli hedef; Aşama 2 için maliyeti ve riski bugün karşılanamaz.
- **Ertelendiği RFC:** RFC-0006 — Referans Donanım ve Özgürlük Envanteri (taslak numara)

### A5 — OZERK Guard ağ modeli zorlama mimarisi

- **Soru:** Uygulama-başı ağ denetimi (manifesto 9.2) teknik olarak nasıl zorlanacak ve sınırları kullanıcıya nasıl anlatılacak?
- **Neden kritik:** Guard, platformun temel farklılaştırıcısıdır; zorlanamayan bir vaat, manifestonun dürüstlük taahhüdünü ihlal eder. DoH, ECH ve büyük CDN'ler alan adı düzeyinde gözlemi belirsizleştirir: "gözlemlenen" ile "garanti edilen" arasındaki ayrım mimariye baştan işlenmelidir. Manifesto 9.2 ayrıca kullanıcı cihazına sahte sertifika yerleştirmeyi yasaklar; TLS içi gözetim bir çözüm yolu değildir.
- **Seçenekler:**
  - Uygulama-başı ağ namespace + sistem denetimindeki DNS/proxy katmanı: en güçlü zorlama; suspend, performans ve karmaşıklık maliyeti ölçülmelidir.
  - nftables tabanlı uygulama-başı filtreleme (cgroup/uid eşlemesiyle): daha hafif; alan adı düzeyinde kesinliği daha düşük.
  - Karma model: profil 1–2 (ağ yok / yalnızca izinli alan adları) sıkı zorlanır; profil 3–4'te gözlemlenen davranış raporlanır ve garanti iddia edilmez.
- **Ertelendiği RFC:** [RFC-0005 — OZERK Guard Ağ Modeli](0005-guard-ag-modeli.md) (taslak yazıldı)

### A6 — Finansman yolu

- **Soru:** Hangi bileşen hangi fon kaynağına, hangi sırayla başvurulacak?
- **Neden kritik:** Kullanıcı verisi gelir modeli değildir (kırmızı çizgi 3); sürdürülebilirlik dış fon ve ürün gelirleri üzerine kurulmak zorundadır. Fon başvuruları bileşen bazında hazırlık ister ve takvimleri projenin yol haritasını etkiler.
- **Seçenekler:**
  - NGI0 / NLnet: bileşen bazlı küçük hibeler (örn. Guard ağ modeli, manifest standardı, push altyapısı); açık kaynak şartı D1 ile uyumludur.
  - Sovereign Tech Fund: kritik açık kaynak altyapının bakımı; upstream katkı stratejisiyle (D3) örtüşür.
  - Horizon Europe: büyük ölçek, konsorsiyum gerektirir; erken aşama için ağırdır.
  - TÜBİTAK 1507 / 1512: Türkiye'de KOBİ ve girişim destekleri; ticari cihaz ve yerelleştirme ayaklarına uygundur.
- **Ertelendiği RFC:** RFC-0008 — Finansman ve Sürdürülebilirlik Planı (taslak numara)

### A7 — Marka ve isim stratejisi

- **Soru:** "OZERK" markası nasıl tescil edilecek ve uluslararası kullanıma nasıl taşınacak?
- **Neden kritik:** "Özerk" Türkçede yaygın bir sözcüktür; TÜRKPATENT nezdinde ayırt edicilik değerlendirmesi belirsizdir. Uluslararası tescil (Madrid Protokolü) sınıf ve ülke seçimi maliyetlidir ve geri alınamaz izler bırakır. "OZERK" yazımının uluslararası söylenebilirliği ve karışıklık riski değerlendirilmemiştir. Marka kullanım ilkesi (manifesto Bölüm 20) tescilsiz zorlanamaz.
- **Seçenekler:**
  - TÜRKPATENT başvurusu + seçilmiş sınıflarda Madrid tescili; sözcük + logo bileşimiyle ayırt edicilik güçlendirilebilir.
  - Yalnızca Türkiye tescili ile başlayıp uluslararası tescili fonlama sonrasına ertelemek.
  - Uluslararası kullanım için ek bir ayırt edici öge (ör. tam yazımın sabitlenmesi) belirlemek; isim değişikliği son çaredir.
- **Ertelendiği RFC:** RFC-0009 — Yönetişim, Marka ve İsim (taslak numara)

### A8 — Push ve suspend mimarisi

- **Soru:** Sağlayıcıdan bağımsız push (OZERK Push, UnifiedPush tabanlı) ile gerçek suspend (Aşama 2 kabul kriteri) aynı cihazda nasıl bağdaştırılacak?
- **Neden kritik:** UnifiedPush kalıcı bir bağlantı ister; gerçek suspend bu bağlantıyı koparır. Merkezî ticari push hizmetleri bu sorunu baseband-tetikli özel yollarla çözer; OZERK'in bu yolu yoktur. Çözülmezse ya pil ömrü ya bildirim güvenilirliği feda edilir — ikisi de kullanıcıya dürüstçe açıklanması gereken sonuçlardır.
- **Seçenekler:**
  - TCP keepalive ayarlı kalıcı bağlantı + modem uyandırması (wake-on-WWAN benzeri mekanizmalar): donanım desteğine bağlıdır.
  - Zamanlanmış uyanma pencereleri: pil dostu; bildirim gecikmesi kullanıcıya açıkça bildirilmelidir.
  - Yedek kanal olarak SMS tetiklemeli uyandırma: operatör bağımlılığı ve maliyeti vardır.
  - Cihaz bazlı karma politika: donanımın desteklediği en iyi yol seçilir; sınırlar özgürlük envanterinde belgelenir.
- **Ertelendiği RFC:** RFC-0007 — Bildirim ve Suspend Mimarisi (taslak numara)

---

## English

> The Turkish text is normative in case of discrepancy.

**OZERK RFC-0001: Decision Record and Open Decisions**

- **RFC:** 0001
- **Title:** Decision Record and Open Decisions
- **Status:** Accepted (living document)
- **Date:** 2026-08-17
- **License:** CC BY-SA 4.0

### 1. About this document

This document records, in one place, the founding decisions the OZERK project has taken and the critical decisions it has not yet taken.

This is a living document:

- A taken decision can only be changed by a new RFC; the change is recorded here.
- An open decision moves to "Decisions Taken" when its RFC is accepted.
- The future RFC numbers referenced below are tentative; they are not binding until the corresponding RFC is written.

This document does not replace the manifesto (`docs/OZERK_Proje_Manifestosu.md`); no decision that contradicts the manifesto is valid.

### 2. Decisions Taken

#### D1 — License model: mixed

- **Decision:** OZERK uses a mixed license model. System and operating system components are licensed GPL-3.0-or-later, SDK / CLI / libraries Apache-2.0, and documents CC BY-SA 4.0. Full license texts live in the `LICENSES/` directory.
- **Date:** 2026-08-17
- **Rationale:** Copyleft prevents system components from losing their freedom through closed derivatives. For the SDK and libraries that developers embed in their applications, a permissive license lowers the adoption barrier, including for commercial use. CC BY-SA for documents keeps the founding texts open and keeps their derivatives open as well.

#### D2 — Language policy: bilingual and equal, Turkish normative on conflict

- **Decision:** Every founding document contains both Turkish and English; the two languages are equivalent in content. In case of discrepancy, the Turkish text is binding.
- **Date:** 2026-08-17
- **Rationale:** The project's roots are Turkish; international contribution is impossible without English. Designating a single normative language prevents interpretation disputes from the start. When a translation error is found it is corrected; meaning is taken from the Turkish text.

#### D3 — Upstream-first strategy

- **Decision:** OZERK reuses existing open source building blocks: postmarketOS / Mobian, Phosh / Plasma Mobile, Flatpak and portals, the F-Droid toolchain, UnifiedPush, Waydroid, and similar. Nothing is reinvented from scratch; forking is a last resort, considered only when the path of contributing upstream is exhausted. Changes are submitted upstream wherever possible.
- **Date:** 2026-08-17
- **Rationale:** The mobile Linux ecosystem contains components that have matured over many years; rewriting them exceeds the project's resources and fragments the community. OZERK's added value is not reinventing the lower layers but building the user-sovereignty layer (Guard, the manifest standard, the repository model) on top of these building blocks.

#### D4 — Monorepo start

- **Decision:** Development proceeds in the open, in the `celikbros/ozerk` monorepo on GitHub. Components may be split into separate repositories once they grow and acquire independent lifecycles.
- **Date:** 2026-08-17
- **Rationale:** In Phase 0 the content is mostly documents and small tools; a single repository lowers coordination cost and makes it easy to version standards and code together. The decision to split is made when the need arises; splitting up front is premature optimization.

#### D5 — First target: Phase 0 documents and an early visible demo

- **Decision:** The first target is completing the Phase 0 founding documents plus an early visible demo: the `ozerk` CLI skeleton (a working beginning of the developer flow described in the manifesto).
- **Date:** 2026-08-17
- **Rationale:** A project that produces only text does not inspire confidence; a project that produces only code loses its direction. A small but working CLI skeleton tests the applicability of the standards early and gives an honest indicator of the project's state: there is no platform code yet, and this is not hidden.

### 3. Open Decisions

The following decisions have not been taken. Each will be discussed and decided in its own RFC.

#### A1 — Browser engine strategy

- **Question:** Which engine and browser will the promise "the web is a first-class application platform" (manifesto 6.6) be built on?
- **Why critical:** Packaged and hosted web applications (application classes C and D) depend directly on this decision. The wrong choice means either an unsustainable maintenance burden or a weak web experience.
- **Options:**
  - A WebKitGTK-based web application runtime + packaging an existing, actively maintained browser (e.g. GNOME Web) as the system browser. The most mature embedding path on mobile Linux; engine maintenance stays upstream.
  - A Chromium base (e.g. an ungoogled variant): the widest web compatibility; but the build cost and the burden of stripping Google dependencies are heavy.
  - A Gecko base: valuable for independence; but embedding support on mobile Linux is weak.
  - Forking an engine: **rejected.** The cost of maintaining a browser engine is entirely outside this project's scale; this option will not be reopened in the RFC.
- **Deferred to:** [RFC-0004 — Web Application Profile and Browser Engine](0004-tarayici-motoru.md) (draft written)

#### A2 — Base distribution choice

- **Question:** Which distribution will OZERK OS be built on: postmarketOS (Alpine, musl) or Mobian (Debian, glibc)?
- **Why critical:** Packaging, the security update pipeline, device support, musl/glibc compatibility (including Waydroid and some binary software), and the entire build infrastructure depend on this base. Changing it late is expensive.
- **Options:**
  - postmarketOS: the largest device-port community, a small base system, mobile-focused tooling; compatibility limits stemming from musl.
  - Mobian: Debian's package richness and glibc compatibility; a narrower set of supported devices.
  - Starting with both and narrowing down after measurement: high learning value, but the maintenance cost doubles.
- **Deferred to:** [RFC-0002 — Base Distribution Choice](0002-taban-dagitim.md) (draft written)

#### A3 — Application package format

- **Question:** Which package format will the OZERK App standard be built on?
- **Why critical:** Manifesto chapter 13 requires every application to declare its network access model and telemetry statement before installation. Existing formats do not express these declarations. The format decision determines the sandbox model, the store, and the SDK.
- **Options:**
  - A Flatpak superset (**the leading proposal**): Flatpak packages and portals are used as-is; OZERK extensions (network profile, telemetry declaration, build verification fields) are added to the manifest. On systems that do not recognize the OZERK extensions, the package works as an ordinary Flatpak.
  - Pure Flatpak + a separate policy file: leaves the standard untouched, but decouples the declaration from the package.
  - An original format: meets the manifesto's needs most directly; contradicts the upstream-first strategy (D3) and starts the ecosystem from zero.
- **Deferred to:** [RFC-0003 — Application Package Format and Manifest Standard](0003-paket-formati.md) (draft written)

#### A4 — Reference hardware path

- **Question:** What will the first reference device be: a port to an existing device with mature mainline Linux support (e.g. SDM845-class devices or the PinePhone Pro), or custom hardware?
- **Why critical:** All of Phase 2 depends on this device. There is also a paradox to resolve: devices with good mainline Linux support usually lack user-controlled verified boot, while devices with strong verified boot infrastructure are rarely mainlined. The manifesto demands both verified boot (6.10) and that hardware realities not be hidden (6.14) — the reference device's freedom inventory must document this tension honestly.
- **Options:**
  - An SDM845-class port: strong mainline support, cheap and available second-hand devices; limits in verified boot and battery life.
  - PinePhone Pro: Linux-first design, an open community; limits in performance and camera.
  - Custom hardware: the long-term goal; its cost and risk cannot be carried today for Phase 2.
- **Deferred to:** RFC-0006 — Reference Hardware and Freedom Inventory (tentative number)

#### A5 — OZERK Guard network model enforcement architecture

- **Question:** How will per-application network control (manifesto 9.2) be technically enforced, and how will its limits be explained to the user?
- **Why critical:** Guard is the platform's core differentiator; a promise that cannot be enforced violates the manifesto's honesty commitment. DoH, ECH, and large CDNs blur observation at the domain level: the distinction between "observed" and "guaranteed" must be built into the architecture from the start. Manifesto 9.2 also forbids planting fake certificates on the user's device; inspecting inside TLS is not an available solution.
- **Options:**
  - Per-application network namespaces + a system-controlled DNS/proxy layer: the strongest enforcement; its cost in suspend behavior, performance, and complexity must be measured.
  - nftables-based per-application filtering (via cgroup/uid mapping): lighter; lower certainty at the domain level.
  - A hybrid model: profiles 1–2 (no network / allowed domains only) are strictly enforced; in profiles 3–4 observed behavior is reported and no guarantee is claimed.
- **Deferred to:** [RFC-0005 — OZERK Guard Network Model](0005-guard-ag-modeli.md) (draft written)

#### A6 — Funding path

- **Question:** Which component will apply to which funding source, and in what order?
- **Why critical:** User data is not a revenue model (red line 3); sustainability must be built on external funding and product revenue. Funding applications require per-component preparation, and their timelines affect the project's roadmap.
- **Options:**
  - NGI0 / NLnet: small per-component grants (e.g. the Guard network model, the manifest standard, the push infrastructure); the open source requirement aligns with D1.
  - Sovereign Tech Fund: maintenance of critical open source infrastructure; overlaps with the upstream contribution strategy (D3).
  - Horizon Europe: large scale, requires a consortium; heavy for the early stage.
  - TÜBİTAK 1507 / 1512: SME and startup grants in Türkiye; suitable for the commercial device and localization tracks.
- **Deferred to:** RFC-0008 — Funding and Sustainability Plan (tentative number)

#### A7 — Brand and name strategy

- **Question:** How will the "OZERK" mark be registered and carried into international use?
- **Why critical:** "Özerk" is a common Turkish word (meaning "autonomous"); its distinctiveness assessment before TÜRKPATENT is uncertain. International registration (Madrid Protocol) involves costly class and country choices that leave irreversible traces. The international pronounceability of the "OZERK" spelling and the risk of confusion have not been assessed. The brand usage principle (manifesto chapter 20) cannot be enforced without registration.
- **Options:**
  - A TÜRKPATENT application + Madrid registration in selected classes; distinctiveness can be strengthened with a word + logo combination.
  - Starting with registration in Türkiye only and deferring international registration until after funding.
  - Defining an additional distinguishing element for international use (e.g. fixing the exact spelling); a name change is the last resort.
- **Deferred to:** RFC-0009 — Governance, Brand and Name (tentative number)

#### A8 — Push and suspend architecture

- **Question:** How will provider-independent push (OZERK Push, based on UnifiedPush) be reconciled with real suspend (a Phase 2 acceptance criterion) on the same device?
- **Why critical:** UnifiedPush requires a persistent connection; real suspend severs that connection. Centralized commercial push services solve this through private baseband-triggered paths; OZERK does not have that path. Left unsolved, either battery life or notification reliability is sacrificed — both are consequences that must be explained honestly to the user.
- **Options:**
  - A persistent connection with tuned TCP keepalive + modem wakeup (wake-on-WWAN-like mechanisms): depends on hardware support.
  - Scheduled wake windows: battery-friendly; the notification delay must be clearly disclosed to the user.
  - SMS-triggered wakeup as a fallback channel: carries operator dependency and cost.
  - A per-device hybrid policy: the best path the hardware supports is chosen; the limits are documented in the freedom inventory.
- **Deferred to:** RFC-0007 — Notification and Suspend Architecture (tentative number)
