# RFC 0004: Web Uygulama Profili ve Tarayıcı Motoru

**Türkçe** | [English](#english)

| Alan | Değer |
|---|---|
| **RFC** | 0004 |
| **Başlık** | Web Uygulama Profili ve Tarayıcı Motoru |
| **Durum** | Taslak |
| **Tarih** | 2026-08-17 |
| **Yazar(lar)** | OZERK kurucusu |
| **Lisans** | CC BY-SA 4.0 |
| **Karşıladığı açık karar** | [RFC-0001](0001-karar-kaydi.md) — A1 |
| **İlgili manifesto bölümleri** | 1, 6.6, 6.7, 8.2 (C ve D), 10, 13, 18.1, 18.2, 24 |
| **Bağlantılı RFC'ler** | RFC-0002 (taban dağıtım), RFC-0003 (paket formatı), RFC-0005 (Guard ağ modeli), RFC-0007 (bildirim ve suspend) |

> **Doğrulama notu.** Bu belgedeki dış kaynaklı teknik iddialar 17 Ağustos 2026 tarihinde kontrol edilmiştir. Tarayıcı motoru alanı hızlı değişir. Kanıt bulunamayan her satır **"doğrulanmalı"** olarak işaretlenmiştir; bunlar iddia değil, yapılacak iş listesidir. Karar verilmeden önce tüm "doğrulanmalı" satırlar kapatılmalıdır. Bu belgede ölçülmemiş hiçbir sayı ölçülmüş gibi sunulmamıştır; tahminler açıkça "tahmin" diye adlandırılmıştır.

---

## Özet

OZERK, kendi tarayıcı motorunu yazmayacak ve mevcut bir motoru forklamayacaktır. Bunun yerine iki katmanlı bir yapı önerilir:

- **(a) OZERK Web Runtime** — paketlenmiş (sınıf C) ve hosted (sınıf D) web uygulamalarını çalıştıran, sistem düzeyinde, tek bir motora dayanan bir çalışma zamanı. Bugünkü kanıtlar ışığında öne çıkan aday **WebKitGTK / WPE WebKit** ailesidir.
- **(b) Genel amaçlı tarayıcı** — kullanıcının web'de gezinmek için kullandığı, bakımı upstream'de süren mevcut bir tarayıcının paketlenmesi. Bu tarayıcı değiştirilebilir olacak ve (a) katmanının motoruyla aynı olmak zorunda kalmayacaktır.

Bu ayrımın amacı, OZERK'in üstlenmek zorunda olduğu bakım yükünü küçültmek ve motor değiştirmeyi mümkün kılan bir sınır çizmektir.

Bu RFC ayrıca, manifesto Bölüm 24'e (Dürüstlük Taahhüdü) iki madde eklenmesini önerir: OZERK'in web vaadi, yazmadığı ve yazamayacağı bir motora kalıcı olarak bağımlıdır ve bu motor sistemdeki en büyük saldırı yüzeyidir.

---

## Motivasyon

### Üç motor gerçeği

Manifesto 6.6, web'i "birinci sınıf uygulama platformu" ilan eder ve yedi somut vaat verir. Manifesto 1 ise OZERK'in "bir şirkete... bağımlı olmayacağını" söyler.

Bu iki cümle, tarayıcı motoru konusunda birbiriyle en sert biçimde çelişir.

Bugün dünyada bakımı sürdürülen, gerçek web'i açabilen tarayıcı motoru sayısı **üçtür**:

| Motor | Ana finansör | 2026 kullanım payı (yaklaşık) |
|---|---|---|
| Blink (Chromium) | Google | ~%78 |
| WebKit | Apple (ikinci büyük katkıcı: Igalia) | ~%15–19 |
| Gecko | Mozilla (geliri ağırlıkla Google arama anlaşmasına dayanır) | ~%3 |

*Kaynak: StatCounter türevi 2026 derlemeleri; kesin oranlar ölçüm yöntemine göre değişir. Katkıcı dağılımı: Igalia 2019'dan beri WebKit'e ikinci en büyük katkıyı yapan kuruluştur ve WebKitGTK ile WPE portlarının bakımını üstlenir.*

Üçü de dev kaynaklarla sürdürülür. Dördüncü bir seçenek yoktur; olması muhtemel iki aday (Servo, Ladybird) bugün üretim için hazır değildir.

Bu, OZERK'in seçebileceği bir şey değildir. Web'i destekleyen her platform bu üç motordan birine bağımlıdır — Android, iOS, KaiOS, Ubuntu Touch, postmarketOS, hepsi. OZERK'in yapabileceği tek şey, bu bağımlılığı gizlemek yerine adını koymak, en az kötü olanı seçmek ve çıkış maliyetini düşük tutmaktır.

### Neden şimdi karar gerekiyor

- Manifesto 8.2'deki C ve D uygulama sınıflarının tamamı bu karara bağlıdır. Sınıf C (paketlenmiş web uygulamaları) ve sınıf D (hosted web uygulamaları) motor seçimi yapılmadan tanımlanamaz.
- Manifesto 13'teki uygulama manifesti, web uygulamaları için ancak runtime'ın hangi yetkileri zorlayabildiği bilindiğinde yazılabilir.
- OZERK Guard (RFC-0005) uygulama başına ağ denetimi vaat eder. Bir web uygulamasının ağ trafiği motor süreçlerinden geçer; motorun süreç modeli bilinmeden Guard'ın web tarafı tasarlanamaz.
- Bildirim mimarisi (RFC-0007) Web Push'un durumuna bağlıdır. Web Push desteklenmiyorsa web uygulamaları için ayrı bir bildirim yolu tasarlanması gerekir.
- Aşama 1 kabul kriterlerinden biri "web uygulaması kurma"dır (manifesto 21). Bu kriter, motor seçimi yapılmadan karşılanamaz.

Kararın geç alınması, yanlış alınmasından daha pahalıdır: runtime API'si bir kez yayımlandıktan sonra motor değiştirmek uygulama ekosistemini kırar.

---

## Tasarım

### 1. Kapsam ve tanımlar

Bu RFC şunları kapsar:

- OZERK'in hangi tarayıcı motoruna/motorlarına dayanacağı,
- paketlenmiş ve hosted web uygulamalarının hangi çalışma zamanında koşacağı,
- manifesto 6.6'daki yedi vaadin bugünkü karşılanabilirlik durumu,
- bu bağımlılığın güvenlik ve dürüstlük sonuçları.

Bu RFC şunları **kapsamaz** (ayrı RFC'lere bırakılır):

- Web uygulama manifest şemasının alan-alan tanımı (RFC-0003 ile birlikte yürütülür),
- push sunucu protokolü ve suspend etkileşimi (RFC-0007),
- Guard'ın ağ zorlama mekanizması (RFC-0005).

Tanımlar:

| Terim | Anlamı |
|---|---|
| **Motor** | HTML/CSS/JS/WASM işleyen çekirdek (Blink, WebKit, Gecko, Servo, Ladybird motoru). |
| **Port** | Bir motorun belirli bir platform/araç takımı için uyarlaması (WebKitGTK, WPE WebKit, QtWebEngine, CEF). |
| **Web Runtime** | Web uygulamalarını bağımsız uygulama gibi çalıştıran, tarayıcı arayüzü olmayan sistem bileşeni. |
| **Tarayıcı** | Kullanıcının serbestçe gezindiği, sekmeli, adres çubuklu genel amaçlı uygulama. |
| **PWA boşluğu** | Manifesto 6.6'nın vaat ettiği ama seçilen motorda bugün karşılanmayan yetenek. |

### 2. Önerilen kararlar

#### K1 — Motor forklanmayacaktır

[RFC-0001](0001-karar-kaydi.md) A1'de bu seçenek zaten reddedilmiştir. Bu RFC reddi teyit eder ve gerekçesini kayda geçirir:

Bir tarayıcı motorunu sıfırdan yazmanın veya forkladıktan sonra sürdürmenin maliyeti hakkında bugün elimizdeki en dürüst gösterge Ladybird'dür: bağışlarla finanse edilen, tam zamanlı ekibi olan, 501(c)(3) statüsündeki bağımsız bir motor girişimi, 2026 için alfa, 2027 için beta, **2028 için kararlı sürüm** hedefliyor. Karşılaştırma için Mozilla'nın ölçeği dört basamaklı çalışan sayısındadır. OZERK'in bugünkü ölçeği bir kişidir.

Fork, motorun kendisi için reddedilmiştir. Port düzeyinde downstream yama taşımak (bir hata düzeltmesini upstream birleştirene kadar geçici taşımak) fork sayılmaz; ancak bunlar da D3 gereği upstream'e gönderilir ve sayıları kayıt altında tutulur.

#### K2 — İki katmanlı yapı

OZERK, "tek bir motor her şeyi yapar" yaklaşımını benimsemez.

**Katman (a): OZERK Web Runtime.** Sınıf C ve D uygulamaları, tarayıcıdan bağımsız, sistem düzeyinde bir çalışma zamanında koşar. Bu katman OZERK'in kendi kodudur; motoru gömer, ama motoru yazmaz. Sorumlulukları:

- uygulama başına ayrı veri alanı (çerez, cache, IndexedDB, Cache API, localStorage),
- uygulama başına ayrı izin seti ve Guard ağ profili bağlaması,
- uygulama başına ayrı süreç grubu,
- manifest doğrulama (RFC-0003 ile ortak),
- kaldırma işleminde tüm yerel verinin ve arka plan yetkilerinin silinmesi (manifesto 6.6),
- bildirim ve paylaşımın XDG portalları üzerinden sistemle bütünleşmesi.

**Katman (b): Genel amaçlı tarayıcı.** Kullanıcının serbest gezinmesi için, bakımı upstream'de süren mevcut bir tarayıcı paketlenir. OZERK bu tarayıcının motorunu geliştirmez, arayüzünü yeniden yazmaz.

#### K3 — Katman (a) için aday: WebKitGTK / WPE WebKit

Bu RFC, katman (a) için WebKitGTK (veya gömme senaryosunda WPE WebKit) ailesini **öne çıkan aday** olarak önerir; ancak Bölüm 9'daki deneyler tamamlanmadan bunu bağlayıcı karar olarak sunmaz.

Gerekçe özeti:

- Mobil Linux'ta bugün fiilen yerleşik olan yol budur: Phosh/GNOME tabanlı mobil Linux dağıtımlarında sistem tarayıcısı Epiphany'dir ve Epiphany WebKitGTK'ya dayanır.
- WebKitGTK ve WPE portlarının bakımı Igalia'dadır. Bu, tek bir dev şirkete olan bağımlılığı ortadan kaldırmaz (motorun kendisi WebKit'tir ve WebKit'in ana katkıcısı Apple'dır), ama **port düzeyinde** karar merciini Apple dışına, Avrupa merkezli bir işçi kooperatifine taşır. Bu, bağımsızlık açısından anlamlı ama sınırlı bir farktır ve öyle sunulmalıdır.
- WPE WebKit, gömme için özel olarak tasarlanmış porttur; WPEPlatform katmanı 2.52'de mevcuttur ve 2.54'te varsayılan olması beklenmektedir. Bu, katman (a) için doğrudan uygun bir gömme yüzeyidir.
- Bellek ayak izi, Chromium tabanlı alternatiflere göre daha düşüktür (yaygın kanı; **bağımsız ölçüm yapılmalı** — Bölüm 9, E3).
- Kaynak ağacı ve build maliyeti Chromium'a göre kat kat küçüktür; taban dağıtımın (RFC-0002) mevcut paket akışıyla sürdürülebilir.
- Lisans (LGPL-2.1 / BSD karışımı) D1 ile uyumludur.

En büyük zayıflığı da açıktır: **PWA API kapsamı üç motor içinde en dardır.** Bölüm 3'teki tablo bunu satır satır gösterir.

#### K4 — Katman (b) için: kullanıcı seçebilir, varsayılan ayrıca kararlaştırılır

Genel tarayıcı, katman (a) ile aynı motoru kullanmak zorunda değildir. OZERK:

- en az bir tarayıcıyı resmî depoda paketlenmiş olarak sunar,
- kullanıcının başka bir tarayıcı kurmasını teknik olarak engellemez (manifesto 6.5),
- hangi tarayıcının hangi motoru kullandığını Özgürlük Envanterinde (RFC-0006) açıkça yazar.

Varsayılan tarayıcının hangisi olacağı bu RFC'de kararlaştırılmaz; taban dağıtım kararına (RFC-0002) ve E2 deneyine bağlıdır.

#### K5 — Motor soyutlama sınırı

Katman (a)'nın geliştiriciye ve sisteme baktığı yüzey (manifest alanları, izin modeli, depolama sözleşmesi, yaşam döngüsü olayları) **motordan bağımsız** tanımlanır. Motora özgü hiçbir kavram bu yüzeye sızdırılmaz.

Amaç saflık değil, ölçülebilir çıkış maliyetidir: motoru değiştirmek gerekirse ekosistemin ne kadarının kırılacağı önceden bilinsin. Bu sınırın gerçekten çalıştığı, aynı runtime'ın ikinci bir backend ile koşturulmasıyla kanıtlanır (Bölüm 9, E6).

#### K6 — PWA boşlukları upstream'e katkı ile kapatılır

D3 (upstream-öncelikli strateji) gereği: eksik bir web platformu yeteneği tespit edildiğinde OZERK'in ilk yolu, yeteneği ilgili portun upstream'ine (WebKitGTK / WPE / Epiphany) katkı olarak göndermektir. Downstream yama taşımak geçici çözümdür ve gerekçesiyle birlikte kayda geçer.

Karşılanamayan boşluklar **gizlenmez**: hangi vaadin hangi cihazda karşılanmadığı Özgürlük Envanterinde ve geliştirici belgelerinde yazılır (manifesto 6.14, 24).

---

### 3. Manifesto 6.6'nın yedi vaadi: motor bazlı durum tablosu

Manifesto 6.6, bir web uygulamasının şunları yapabileceğini söyler. Aşağıdaki tablo, her vaadin her motorda **17 Ağustos 2026 itibarıyla** durumunu gösterir.

Gösterim: **✅** destekleniyor · **◐** kısmi · **✕** yok · **?** doğrulanmalı

| # | Vaat (manifesto 6.6) | WebKitGTK 2.52 (+Epiphany) | Chromium (QtWebEngine / CEF) | Gecko (Firefox, Linux) | Servo | Ladybird |
|---|---|---|---|---|---|---|
| 1 | Ana ekrana kurulabilecek | ◐ **Epiphany yapar, motor yapmaz.** `ENABLE_APPLICATION_MANIFEST` GTK'da kapalıdır (yalnızca Cocoa'da açık); Epiphany manifesti kendi enjekte ettiği JS ile okur, manifest yoksa sayfayı "kazıyarak" (scraping) çalışır | ✅ Angelfish (Plasma Mobile) PWA kurulumunu destekler; Chromium `--app` modu | ✕ Masaüstü Firefox'ta site-özel tarayıcı / PWA desteği yok (**?** 2026 durumu teyit edilmeli) | ✕ | ✕ |
| 2 | Bağımsız uygulama penceresinde çalışabilecek | ✅ | ✅ | ◐ harici araçlarla (`--kiosk`, üçüncü taraf sarmalayıcılar) | ✕ | ✕ |
| 3 | Kendi depolama alanına sahip olacak | ✅ `WebKitNetworkSession` ile ayrı profil/cache dizini; Epiphany her web uygulamasına `<veri-dizini>/<uygulama-kimliği>` verir. IndexedDB, DOM Cache, Service Worker kayıtları ayrı silinebilir. *(Kota belirleme API'si yok.)* | ✅ ayrı profil dizini ile | ◐ profil ayrımı elle yapılır | **?** | ✕ |
| 4 | Çevrimdışı çalışabilecek | ✅ Service Worker WebKitGTK 2.28.0'dan (Mart 2020) beri varsayılan açık; Cache API, IndexedDB mevcut | ✅ | ✅ motor düzeyinde | **?** Service Worker durumu doğrulanmalı | ✕ |
| 5a | Bildirim alabilecek — **sayfa açıkken** (Notifications API) | ◐ `WebKitWebView::show-notification` sinyali 2.8'den beri var; ancak GTK yapılarında **varsayılan bildirim sunucusu yoktur** — bildirimi gömen uygulama çizer. Bildirim, sayfa gezinildiğinde veya kapandığında iptal edilir | ✅ | ✅ | **?** | ✕ |
| 5b | Bildirim alabilecek — **sayfa/uygulama kapalıyken** (Web Push, RFC 8030/8291/8292) | ✕ **Desteklenmiyor; derleme seçeneği bile yok.** `ENABLE_WEB_PUSH` diye bir CMake seçeneği mevcut değildir; `ENABLE_WEB_PUSH_NOTIFICATIONS` yalnızca macOS/iOS'ta 1'dir; `PushAPIEnabled` tüm portlarda `false`. WebKit'in `webpushd` bileşeni tamamen Objective-C++ ve APNs'e bağlıdır — Linux portu yoktur. Ayrıca `ENABLE_NOTIFICATION_EVENT` = 0 olduğundan **service worker hiç bildirim olayı alamaz** | **?** QtWebEngine'de Push API'nin etkin olup olmadığı doğrulanmalı; ham Chromium'da destekleniyor ama varsayılan uç nokta Google altyapısıdır | ✅ Firefox Web Push'u destekler; IronFox/Fennec çatallarında UnifiedPush'a yönlendirilebildiği belgelenmiştir | ✕ | ✕ |
| 6 | Sistem paylaşım arayüzüne katılabilecek (Web Share API) | ✕ **Desteklenmiyor.** `WebShareEnabled` yalnızca Cocoa'da `true`; `navigator.share` GTK'da mevcut değildir. `ENABLE_WEB_SHARE` diye bir seçenek yoktur; portal bağlaması da yoktur | **?** Linux'ta `navigator.share` desteğinin durumu doğrulanmalı | **?** | ✕ | ✕ |
| 7 | Kullanıcı izinleriyle kamera, mikrofon ve konuma erişebilecek | ◐ Kamera/mikrofon (`getUserMedia`) ✅ — WebKitGTK 2.50'den beri XDG Desktop Portal (`org.freedesktop.portal.Camera` + PipeWire) üzerinden, sandbox istisnası gerekmeden. Ekran paylaşımı ScreenCast portalı üzerinden ✅. Konum ✅ ama portal değil, **GeoClue2** D-Bus üzerinden. ⚠️ **`ENABLE_WEB_RTC` deneysel özelliklere bağlıdır; kararlı yapılarda `RTCPeerConnection` kapalıdır** — görüntülü görüşme web uygulaması çalışmaz | ✅ (portal entegrasyonunun kalitesi **?**) | ✅ | ✕ | ✕ |
| + | *(6.6'da yok, ama çevrimdışı vaadinin pratik tamamlayıcısı)* Background Sync / Periodic Background Sync | ✕ **İlkesel olarak reddedilmiş.** Periodic Background Sync hatası WONTFIX kapatıldı (gerekçe: gizlilik, botnet ve pil riski); Background Sync hatası 2019'dan beri dokunulmamış durumda | ✅ Chromium destekliyor | ✕ Firefox desteklemiyor | ✕ | ✕ |
| + | *(manifesto 18.2'de vaat edilen)* WebAuthn / passkey | ✕ **Desteklenmiyor.** `ENABLE_WEB_AUTHN` GTK'da kapalıdır; "[WPE][GTK] Support WebAuthn" hatası 2019'dan beri açık ve üzerinde çalışan yok. **Manifesto 18.2 ile doğrudan çelişki** | ✅ | ✅ | ✕ | ✕ |
| + | *(güvenlik)* Süreç sandbox'ı | ✅ **bubblewrap sandbox Linux'ta varsayılan açık**; yeni GTK4 (6.0) API'sinde kapatılamaz hâle getirilmiştir | ✅ | ✅ | **?** | **?** |
| + | *(güvenlik)* Site isolation | ✕ `SiteIsolationEnabled` tüm portlarda "unstable" ve varsayılan `false`; GTK sürüm notlarında hiç anılmıyor | ✅ (düşük bellekte kısıtlanır) | ◐ | ✕ | ✕ |

**Tablodan çıkan sonuçlar — ilk taslaktan daha kötü bir tablo:**

1. Yedi vaatten **üçü tam karşılanıyor** (2, 3, 4). Vaat 1 motorun değil Epiphany'nin özelliğidir. Vaat 7 kısmen karşılanıyor (kamera/mikrofon/konum evet, ama kararlı yapılarda WebRTC kapalı). **Vaat 5 ve 6 karşılanmıyor.**
2. **Vaat 5b (uygulama kapalıyken bildirim) yalnızca bir boşluk değil, mimari bir yokluktur.** Web Push için derleme seçeneği bile bulunmamaktadır ve `ENABLE_NOTIFICATION_EVENT` kapalı olduğu için service worker'lar bildirim olayı alamaz. Bu, sorunun "eklenmemiş bir özellik" değil, **motorda uygulanmamış bir yetenek** olduğu anlamına gelir.
   Bunun doğrudan bir sonucu vardır: **OZERK Web Runtime'ın kendi katmanında bir JS köprüsüyle bu boşluğu kapatması mümkün değildir.** Service worker bildirim olayını alamıyorsa, hiçbir kabuk kodu bunu telafi edemez. Boşluk motor içinde kapatılmak zorundadır.
3. **WebAuthn'un yokluğu manifesto 18.2 ile doğrudan çelişir.** Manifesto passkey ve WebAuthn desteğini açıkça vaat eder; seçilen motorda bu bugün yoktur ve üzerinde çalışan kimse yoktur.
4. **Web Share'in yokluğu vaat 6'yı geçersiz kılar.** Bu, diğerlerine göre küçük bir iştir (portal bağlaması mevcuttur), ama motor tarafında bir `EnabledBySetting` bayrağı ve `showShareSheet` uygulaması gerektirir.
5. Sandbox tarafında iyi haber vardır: bubblewrap sandbox'ı yeni API'de kapatılamaz. Site isolation ise yoktur.

**Bir fırsat.** UnifiedPush belirtimi, şifreleme (RFC 8291) ve VAPID yetkilendirmesi (RFC 8292) gerektirecek biçimde güncellenmiştir; yani UnifiedPush uçları artık açıkça Web Push uçlarıdır. Bu, OZERK Push (RFC-0007) ile katman (a)'nın Web Push desteğinin **aynı altyapıyı paylaşabileceği** anlamına gelir: eksik olan taşıma katmanı değil, motor içindeki Push API ve NotificationEvent uygulamasıdır. Apple'ın `webpushd`'si APNs'e bağlı olduğu için doğrudan kullanılamaz; ancak WebKit'in Push API iskeleti mevcuttur ve GTK/WPE için bir arka uç yazılabilir. Aynı yolun Gecko tarafında işlediği, Firefox çatallarına (IronFox/Fennec) UnifiedPush üzerinden web push eklenmesiyle gösterilmiştir. Bu, K6 kapsamındaki katkının en somut ve en yüksek değerli hedefidir.

---

### 4. Seçeneklerin değerlendirilmesi

Her seçenek şu ölçütlerle değerlendirilmiştir: mobil Linux'ta bugünkü durum · PWA/Service Worker/Web Push/background sync kapsamı · güvenlik yaması temposu ve bakım yükü · gömme (embedding) API kalitesi · Wayland/dokunmatik uyumu · bellek ayak izi · lisans uyumu.

#### Seçenek 1 — WebKitGTK / WPE WebKit

| Ölçüt | Durum |
|---|---|
| Mobil Linux'ta bugünkü durum | **En yerleşik yol.** Phosh/GNOME tabanlı mobil Linux dağıtımlarında sistem tarayıcısı Epiphany'dir. Aktif geliştirme sürüyor: WebKitGTK 2.52.5 (9 Temmuz 2026), Epiphany 50.6 (13 Ağustos 2026). |
| PWA kapsamı | **En dar.** Service Worker ✅ (2.28.0'dan beri), ayrı profil ✅, kurulum ✅, kamera/konum portal üzerinden ✅. Web Push **?**, Web Share **?**, Background Sync ✕, WebAuthn **?**. |
| Güvenlik temposu | Güvenlik danışmanlıkları düzenli yayımlanıyor: 2025'te 10 (WSA-2025-0001…0010), 2026'da Temmuz'a kadar 4 (WSA-2026-0001…0004). Kabaca 5–6 haftada bir. Yama, upstream WebKit düzeltmesinden sonra port sürümüne aktarılır; **gecikme süresi ölçülmemiştir** (Bölüm 9, E4). |
| Bakım yükü | Motor bakımı upstream'de (Igalia). OZERK'in yükü: paketleme, runtime entegrasyonu, PWA boşluklarına katkı. Chromium'a göre kat kat düşük. |
| Gömme API kalitesi | WebKitGTK için olgun GObject API; üç API sürümü paralel destekleniyor (webkitgtk-6.0 / webkit2gtk-4.1 / webkit2gtk-4.0). WPE WebKit gömme için özel tasarlanmıştır; WPEPlatform 2.52'de mevcut, 2.54'te varsayılan olması bekleniyor. **Bilinen zayıflık:** dağıtımlar arası API sürümü parçalanması, Tauri gibi WebKitGTK'ya dayanan projelerde belgelenmiş bir sorundur. |
| Wayland / dokunmatik | Wayland yolu birinci sınıftır (WPE zaten "WebKit for Wayland" olarak doğdu). Dokunmatik jest kalitesi ve ekran klavyesi entegrasyonu referans cihazda **ölçülmelidir**. |
| Bellek ayak izi | Chromium'a göre belirgin biçimde düşük olduğu yaygın kabuldür; ancak elimizdeki kaynaklar anekdot düzeyindedir. **Bağımsız ölçüm gerekli** (E3). |
| Lisans | LGPL-2.1 / BSD karışımı; D1 ile uyumlu. |

#### Seçenek 2 — Chromium tabanlı gömme (CEF, QtWebEngine veya doğrudan)

| Ölçüt | Durum |
|---|---|
| Mobil Linux'ta bugünkü durum | Gerçekten kullanılıyor: Plasma Mobile'ın tarayıcısı Angelfish, QtWebEngine (yani Blink) üzerine kuruludur. Yani bu yol mobil Linux'ta teorik değildir. |
| PWA kapsamı | **En geniş.** Yedi vaadin tamamı ve Background Sync dahil çevre API'ler Chromium'da mevcuttur. Ancak bunların QtWebEngine/CEF gibi gömme portlarında etkin olup olmadığı ayrı bir sorudur — **doğrulanmalı**. |
| Güvenlik temposu | Chromium'un yama temposu hızlıdır ve bu bir avantaj değil, bir yükümlülüktür: downstream paketleyicinin aynı tempoda yeniden derlemesi gerekir. QtWebEngine'in taşıdığı Chromium sürümünün upstream'in gerisinde kalması bilinen ve tekrarlayan bir eleştiridir. **Somut gecikme rakamı doğrulanmalı.** |
| Bakım yükü | **En ağır seçenek.** Chromium kaynak ağacı ve build süresi, küçük bir projenin kendi başına sürdürebileceği ölçekte değildir. "ungoogled" bir varyantı sürdürmek, Google bağımlılıklarını ayıklayan yama setini her sürümde yeniden uyarlamak demektir. |
| Gömme API kalitesi | CEF olgun ve yaygındır; QtWebEngine Qt uygulamaları için doğrudan yoldur. ARM64 Linux + Wayland desteğinin bugünkü durumu **doğrulanmalı**. |
| Wayland / dokunmatik | Ozone/Wayland yolu olgunlaşmıştır; dokunmatik ve ekran klavyesi entegrasyonunun mobil kabuklarla (Phosh/Plasma Mobile) uyumu **ölçülmelidir**. |
| Bellek ayak izi | En yüksek. Site isolation açıkken süreç başına ek maliyet, düşük RAM'li telefonda belirleyici olur (Bölüm 6). |
| Lisans | Çekirdek BSD-3-Clause; ancak kodek ve DRM bileşenlerinde özgür olmayan parçalar bulunur. Resmî OZERK Free deposunun yalnızca açık kaynak barındırma kuralıyla (manifesto 14.1) uyum **incelenmelidir**. |
| Bağımsızlık | Manifesto 1 açısından **en kötü seçenek**: Blink'in yönü Google tarafından belirlenir ve kullanım payı ~%78'dir. OZERK'in bu motoru seçmesi, "tek bir şirkete bağımlı olmama" iddiasını en zayıf noktasından vurur. |

#### Seçenek 3 — Gecko / GeckoView

| Ölçüt | Durum |
|---|---|
| Mobil Linux'ta bugünkü durum | Firefox masaüstü Linux'ta çalışır; mobil kabuklar için optimize edilmiş resmî bir yapı yoktur. Dokunmatik ve küçük ekran uyumu **doğrulanmalı**. |
| PWA kapsamı | Web Push ✅ (ve UnifiedPush'a yönlendirilebildiği Firefox çatallarında gösterilmiştir). Ancak **kurulabilir web uygulaması / site-özel tarayıcı desteği masaüstü Firefox'ta yoktur**; Background Sync desteklenmez. Yani 6.6'nın 1., 2. ve 3. vaatleri motor tarafından değil, OZERK tarafından sıfırdan inşa edilmek zorunda kalır. |
| Gömme API kalitesi | **Bu seçeneğin belirleyici zayıflığı.** Mozilla, genel amaçlı Gecko gömme API'sini yıllar önce bıraktı. GeckoView Android'e bağlıdır (Android build sistemi ve JNI). Düz Linux'ta desteklenen bir gömme yolu bulunmamaktadır — **doğrulanmalı, ancak bulunmaması beklenmektedir.** |
| Güvenlik temposu | Mozilla'nın yama temposu iyidir; ancak paketleme Firefox uygulaması düzeyindedir, gömülebilir kütüphane düzeyinde değildir. |
| Bakım yükü | Gömme yolu olmadığı için katman (a) bu motorla kurulamaz; kurulmaya çalışılırsa bakım yükü fork'a yaklaşır. |
| Bellek ayak izi | Chromium ile WebKitGTK arasında; **ölçülmeli.** |
| Lisans | MPL-2.0; D1 ile uyumlu. |
| Bağımsızlık | Görünürde en "bağımsız" motor; ancak Mozilla'nın gelirinin ağırlıkla Google arama anlaşmasına dayanması bu bağımsızlığı sınırlar. ABD'deki arama davası kararlarının bu geliri nasıl etkilediği **2026 itibarıyla doğrulanmalıdır.** |

**Sonuç:** Gecko, katman (b) için (paketlenmiş bir tarayıcı olarak) makul bir seçenektir. Katman (a) için gömme yolu olmadığı sürece uygun değildir.

#### Seçenek 4 — Servo

| Ölçüt | Durum |
|---|---|
| Bugünkü durum | **Üretim için hazır değil, ama yön doğru.** Kısa vadeli hedefi açıkça "araştırma projesinden üretime hazır web motoruna geçmek" olarak tanımlanmıştır. |
| Gömme API kalitesi | Aktif geliştirilen alan. Gömme API'si HTTP proxy, kök sertifikalar, localStorage/sessionStorage ve çerez yönetimini kapsıyor. `servo` crate'i crates.io üzerinden yayımlanmaya başlandı; aylık özellik sürümlerinin yanına altı ayda bir LTS dalı (yaklaşık dokuz ay destek) planlanıyor. |
| Web platformu kapsamı | Kontrollü içerik (belge görüntüleme, HTML/CSS ile kurulmuş arayüzler) için giderek yeterli; **açık internetten gelen rastgele içerik için hâlâ pürüzlü.** Service Worker ve IndexedDB durumu **doğrulanmalı.** |
| Güvenlik duruşu | Sandbox/çok süreçli mimari ve güvenlik yanıt süreci **doğrulanmalı.** Üretim gömme için "API sarmalayıcıları, sandbox ve web API uyumluluk testi" gerektiği kendi belgelerinde yazılıdır. |
| Yönetişim | Linux Foundation Europe altında; Igalia belirleyici rol oynuyor. Tam zamanlı mühendis sayısı **doğrulanmalı.** |
| Bağımsızlık | Üç motorun hiçbirine bağlı olmayan gerçek bir dördüncü yol adayı. Uzun vadede OZERK'in çıkarına en uygun seçenek budur. |

**Sonuç:** Bugün seçilemez. **İzlenecek** ve gözden geçirme takviminde (Bölüm 10) her turda yeniden değerlendirilecektir. Servo'nun gömme API'si OZERK'in katman (a) sözleşmesini karşılayabilir hâle gelirse, K5'teki soyutlama sınırı sayesinde geçiş maliyeti ölçülebilir olacaktır.

#### Seçenek 5 — Ladybird

| Ölçüt | Durum |
|---|---|
| Bugünkü durum | **Olgun değil.** Yol haritası: 2026 alfa (Linux ve macOS, geliştiriciler ve erken benimseyenler için), 2027 beta, **2028 kararlı sürüm**. Alfa öncesinde geliştirme modeli değiştirilmiş, kamuya açık pull request kabulü durdurulmuştur — **tarih ve kapsam doğrulanmalı.** |
| Bağımsızlık | **En güçlü yanı.** Hiçbir mevcut motorun forku değil; sıfırdan yazılıyor. 501(c)(3) kâr amacı gütmeyen bir kuruluş tarafından, bağış ve sponsorluklarla finanse ediliyor (sponsorlar arasında Cloudflare, FUTO, Shopify, 37signals; kurucu ortak Chris Wanstrath'ın ailesi 1 milyon dolar taahhüt etti). |
| Gömme API'si | **Doğrulanmalı;** bugün var olduğuna dair kanıt bulunamadı. |
| Güvenlik duruşu | Sandbox / çok süreçli mimari durumu **doğrulanmalı.** Alfa aşamasındaki bir motorun güvenilmeyen içerikle kullanılması bugün savunulabilir değildir. |
| ARM64 / mobil Linux | **Doğrulanmalı.** |

**Sonuç:** Bugün seçilemez. Ladybird, OZERK'in uzun vadeli çıkarlarıyla en fazla örtüşen projedir ve **desteklenmeye değerdir**; ancak bir işletim sisteminin web platformunu 2026'da alfa bir motora dayandırması, manifesto 24'ün dürüstlük ölçütünü ihlal ederdi.

#### Karşılaştırma özeti

| | WebKitGTK/WPE | Chromium | Gecko | Servo | Ladybird |
|---|---|---|---|---|---|
| Katman (a) için bugün uygun mu? | **Evet (koşullu)** | Evet ama sürdürülemez | Hayır (gömme yolu yok) | Hayır (henüz) | Hayır (henüz) |
| Katman (b) için bugün uygun mu? | Evet | Evet | Evet | Hayır | Hayır |
| PWA kapsamı | Dar | Geniş | Orta | Bilinmiyor | Dar |
| OZERK'in bakım yükü | Düşük | Çok yüksek | Yüksek | Bilinmiyor | Bilinmiyor |
| Tek şirkete bağımlılık | Orta (Apple + Igalia) | **Yüksek (Google)** | Orta (Mozilla, geliri Google'a bağlı) | Düşük | **En düşük** |
| Bellek | Düşük | Yüksek | Orta | Bilinmiyor | Bilinmiyor |

---

### 5. Bağımlılık dürüstlüğü

Bu bölüm zorunludur ve kısaltılamaz.

**Hangi seçenek seçilirse seçilsin, OZERK upstream bir tarayıcı motoruna bağımlı kalacaktır.** Bu bağımlılık:

- **geçici değildir.** Motorun bakımı yıllar boyunca OZERK dışında kalacaktır.
- **kaçınılabilir değildir.** Kaçınmanın tek yolu motor yazmaktır ve bu K1'de reddedilmiştir.
- **hafifletilebilir.** Port düzeyinde Apple dışı bir bakımcı (Igalia), gömme sınırı (K5) ve çıkış planı (Bölüm 10) bağımlılığı yönetilebilir kılar, ama ortadan kaldırmaz.

#### Manifesto 1'deki bağımsızlık iddiası ne anlama gelir

Manifesto 1 şunu söyler: *"OZERK bir şirkete, tek bir uygulama mağazasına, tek bir bulut sağlayıcısına veya tek bir donanım üreticisine bağımlı olmayacaktır."*

Bu cümle, tarayıcı motoru bağlamında şu anlamlara **gelir**:

- Kullanıcı, hangi tarayıcıyı kuracağına kendisi karar verir; sistem tek bir tarayıcıyı dayatmaz (manifesto 6.5).
- Motorun kaynak kodu açıktır, denetlenebilir ve forklanabilir; OZERK forklamayı seçmemiştir, forklayamayacağı için değil, sürdüremeyeceği için.
- Motor sağlayıcısı OZERK kullanıcısı üzerinde ticari bir kaldıraç kuramaz: hesap zorunluluğu yoktur, telemetri OZERK tarafında denetlenir, ağ erişimi Guard tarafından sınırlanır.
- OZERK'in kullanıcıya karşı yükümlülükleri (gizlilik, hesapsız kullanım, veri taşınabilirliği) motor sağlayıcısının politikalarına devredilmez.

Bu cümle şu anlamlara **gelmez**:

- **OZERK'in web platformunun teknik yönünü belirleyebileceği anlamına gelmez.** Hangi web API'sinin uygulanacağına Apple, Google ve Mozilla karar verir. OZERK bu masada bir sandalyeye sahip değildir.
- **OZERK'in bir güvenlik açığını kendi başına kapatabileceği anlamına gelmez.** Kritik bir motor açığında OZERK'in yapabileceği, upstream yamayı beklemek ve hızlıca dağıtmaktır.
- **Motorun geliştirilmesi durursa OZERK'in devralabileceği anlamına gelmez.** Devralma kapasitesi yoktur ve bu RFC bu kapasiteyi kazanmayı planlamaz.
- **OZERK'in web uyumluluğunu garanti edebileceği anlamına gelmez.** Bir site yalnızca Chromium'da çalışacak biçimde yazılmışsa, OZERK bunu düzeltemez.

Kısaca: **OZERK'in bağımsızlık iddiası, kullanıcı ile platform arasındaki ilişkiye dairdir; platform ile web motorunun geliştiricileri arasındaki ilişkiye dair değildir.** Bu ikisini karıştırmak, manifesto 24'ün yasakladığı türden bir abartıdır.

#### Bu bağımlılığın adı konmuş biçimi

OZERK'in web platformu, aşağıdakilerden herhangi biri gerçekleşirse doğrudan zarar görür:

| Risk | Etkisi | Bugünkü değerlendirme |
|---|---|---|
| Igalia'nın WebKitGTK/WPE bakımını bırakması | Katman (a) bakımsız kalır | Düşük olasılık, yüksek etki. İzlenmeli. |
| Apple'ın WebKit'i kapatması veya yönünü değiştirmesi | Portlar upstream'siz kalır | Çok düşük olasılık, çok yüksek etki |
| Web'in Chromium-özgü davranışlara kayması | Web uyumluluğu bozulur, kullanıcı Chromium'a zorlanır | **Orta-yüksek olasılık, yüksek etki. Bugün en gerçek risk budur.** |
| Web Push boşluğunun kapatılmaması | 6.6'nın beşinci vaadi karşılanamaz | Bugün gerçekleşmiş durumda (bkz. Bölüm 3) |

---

### 6. Güvenlik yükü

Bu bölüm de zorunludur.

**Tarayıcı motoru, web-birinci bir platformda en büyük saldırı yüzeyidir.** OZERK'te bu, başka sistemlerden daha ağır bir sonuç doğurur: sınıf C ve D uygulamalarının tamamı aynı motoru paylaşır. Yani motordaki tek bir uzaktan kod çalıştırma açığı, kullanıcının bankacılık web uygulamasını, mesajlaşma web uygulamasını ve tarayıcı sekmelerini **aynı anda** tehdit eder.

Bu tek hata noktasıdır ve manifesto 10.1'in koruma hedefleriyle (uygulamalar arası veri sızıntısı, arka planda gizli veri aktarımı) doğrudan çelişme riski taşır.

#### Yama SLA'sı olmadan vaat verilemez

Bugün elimizde ölçüm yoktur. Elimizde olan:

- WebKitGTK güvenlik danışmanlıkları düzenli yayımlanmaktadır: 2025'te 10, 2026'da Temmuz'a kadar 4.
- Örnek bir gerçek olay: CVE-2025-13947, web sitelerinin sürükle-bırak yoluyla kullanıcının dosya sistemindeki dosyaları dışarı sızdırmasına izin veriyordu; WebKitGTK 2.50.3 ile düzeltildi. Apple platformları etkilenmiyordu — yani **portlara özgü açıklar gerçektir** ve Apple'ın yama temposuna güvenmek yetmez.
- Tarihsel uyarı: Linux dağıtımlarının bakımsız WebKitGTK 2.4 ve QtWebKit sürümlerini yıllarca dağıttığı dönem, mobil Linux'un bu konuda otomatik olarak güvenli olmadığını gösterir. Bu sorun büyük dağıtımlarda çözülmüştür, ancak küçük ve yeni bir dağıtım için otomatik değildir — **OZERK tam olarak böyle bir dağıtımdır.**

Bu nedenle bu RFC, motor kararının **ölçülebilir bir yama SLA'sına bağlanmasını** önerir:

| Ölçüt | Önerilen eşik | Notu |
|---|---|---|
| Upstream WSA yayımından OZERK deposunda güncel pakete kadar geçen süre — medyan | ≤ 7 gün | E4 ile ölçülür |
| Aynı süre — 90. yüzdelik | ≤ 14 gün | |
| Aktif sömürülen açıklar (KEV benzeri) | ≤ 72 saat | |
| Ölçümün kamuya açıklığı | Zorunlu | Ölçüm sonuçları depoda yayımlanır (manifesto 24) |

**Bu eşikler karşılanamıyorsa, seçilen motor değil, OZERK'in kendisi hazır değildir.** O durumda dürüst davranış, web uygulama platformunu erteleyerek yayımlamak değil, sınırı ilan ederek yayımlamaktır.

#### Site isolation'ın kısıtlı RAM'li telefonda maliyeti

Site isolation (farklı sitelerin farklı süreçlerde çalışması) Spectre sınıfı ve süreç-içi kaçış saldırılarına karşı en etkili savunmadır. Maliyeti bellektir: her ek süreç, ek yerleşik bellek demektir.

Bu, OZERK için kritik bir gerilimdir çünkü referans donanım (RFC-0006) muhtemelen 3–6 GB RAM'li ikinci el bir cihaz olacaktır.

Bugünkü durum:

- **Chromium'da** site isolation olgun ve varsayılan açıktır; ancak düşük bellekli Android cihazlarda tam site isolation'ın devre dışı bırakıldığı bilinmektedir. **Eşik değeri ve 2026 politikası doğrulanmalıdır.**
- **WebKit'te** site isolation daha yenidir. 2025 başı itibarıyla proje üç adımlı planının ikinci adımındaydı (site isolation'ın bozduğu işlevleri düzeltmek); üçüncü adım performans gerilemelerinin düzeltilmesiydi. **WebKitGTK/WPE portlarında bugünkü durumu doğrulanmalıdır.**

OZERK'in pozisyonu şu olmalıdır:

1. Site isolation'ın referans cihazdaki bellek maliyeti **ölçülür** (E3), tahmin edilmez.
2. Bellek nedeniyle site isolation kapatılıyorsa, bu **kullanıcıya açıkça bildirilir** ve Özgürlük Envanterine yazılır. Sessizce kapatmak manifesto 24'ün ihlalidir.
3. Katman (a) ve katman (b) farklı politikalara sahip olabilir: az sayıda güvenilen web uygulamasının izole edilmesi, rastgele web gezintisinden farklı bir bellek profiline sahiptir. Bu ayrım, iki katmanlı yapının ölçülebilir bir yan faydasıdır.

#### Sandbox katmanları

Motorun kendi sandbox'ı (WebKitGTK bubblewrap tabanlı bir sandbox kullanır — **doğrulanmalı**) tek savunma hattı olarak kabul edilmez. Katman (a), motorun sandbox'ının **üstüne** OZERK'in kendi katmanlarını koyar:

- Flatpak/portal tabanlı uygulama sandbox'ı (RFC-0003),
- Guard ağ profili (RFC-0005) — bir web uygulamasının hangi alan adlarına çıkabileceği manifestte beyan edilir (manifesto 13),
- uygulama başına ayrı veri alanı, yani bir uygulamanın açığından diğerinin verisine ulaşılamaması.

---

### 7. PWA boşluklarını kapatmanın maliyeti

Aşağıdaki rakamlar **tahmindir**, ölçüm değildir. Karar öncesinde en az bir bağımsız görüşle karşılaştırılmalıdır.

Kalıcı mühendis (FTE) tahmini, önerilen iki katmanlı yol için:

| İş | İlk uygulama (tahmin) | Kalıcı bakım (tahmin) |
|---|---|---|
| Katman (a) runtime'ın kendisi (profil izolasyonu, manifest, yaşam döngüsü, Guard bağlaması) | 9–15 ay·mühendis | **1–2 FTE** |
| Web Push'un WebKitGTK/WPE'ye upstream katkı olarak eklenmesi ve UnifiedPush'a bağlanması | 6–12 ay·mühendis | **0.5 FTE** |
| Web Share API + sistem paylaşım portalı bağlaması | 3–6 ay·mühendis | 0.25 FTE |
| WebAuthn/passkey desteği (manifesto 18.2 gereği) | 6–12 ay·mühendis | 0.5 FTE |
| Katman (b) tarayıcı paketleme + güvenlik yaması takibi | 2–4 ay·mühendis | **0.5–1 FTE** |
| **Toplam (önerilen yol)** | | **≈ 3–4 FTE, kalıcı** |

Karşılaştırma için:

| Yol | Kalıcı FTE tahmini |
|---|---|
| Önerilen iki katmanlı yol (WebKitGTK/WPE) | ≈ 3–4 |
| Chromium tabanı, ungoogled varyantı kendi sürdürerek | ≈ 8–15+ |
| Motor forku | İki basamaklı, kalıcı — **kapsam dışı (K1)** |

**OZERK'in bugünkü kalıcı mühendis sayısı sıfırdır.** Bu rakam, bu RFC'nin en önemli tek bulgusudur ve iki sonucu vardır:

1. Bu iş, gönüllü katkı ve dış fonla (RFC-0008 / A6) finanse edilmeden yapılamaz. Web Push katkısı, NGI0/NLnet türü bileşen bazlı hibeler için doğal bir adaydır: kapsamı dar, çıktısı upstream'e gidiyor, kamu yararı açık.
2. Aşama 1'in "web uygulaması kurma" kriteri, boşlukların tamamı kapatılmadan da karşılanabilir; ancak hangi vaadin karşılanmadığı ilan edilmelidir.

---

### 8. Manifesto Bölüm 24'e önerilen ek

Bu RFC, manifesto 24'ün (Dürüstlük Taahhüdü) listesine aşağıdaki iki maddenin eklenmesini önerir:

> - Web'in birinci sınıf uygulama platformu olması vaadi, OZERK'in yazmadığı ve yazamayacağı bir tarayıcı motoruna kalıcı olarak bağımlıdır; dünyada bakımı sürdürülen motor sayısı üçtür ve üçü de OZERK'ten kat kat büyük kuruluşlarca finanse edilir. Web platformunun teknik yönünü OZERK belirlemez.
> - Tarayıcı motoru, web-birinci bir sistemde en büyük saldırı yüzeyidir ve bütün web uygulamaları onu paylaşır; OZERK bu yüzeyin yamalanmasında upstream'in temposuna bağımlıdır ve ölçülen yama gecikmesini kamuya açıklar.

Manifesto tadilleri [RFC-0000](0000-rfc-sureci.md) gereği RFC ister. Bu RFC'nin kabulü, yukarıdaki iki maddenin manifesto 24'e eklenmesini de kapsar. Tadil metni ayrıca tartışılmak istenirse ayrı bir RFC'ye bölünebilir; bu durumda bu RFC'nin kabulü söz konusu tadili engellemez.

---

### 9. Karar ölçütleri ve sonraki adımlar

#### 9.1. Kararın verilebilmesi için gereken deneyler

Aşağıdaki deneyler tamamlanmadan bu RFC "Kabul" durumuna geçmemelidir. Her deneyin çıktısı depoda yayımlanır.

**E1 — Referans PWA, WebKitGTK üzerinde (en kritik deney).**
Küçük bir referans web uygulaması yazılır: web app manifest + service worker + Cache API + IndexedDB + push aboneliği + `navigator.share` denemesi + kamera/konum erişimi. Epiphany 50.x / WebKitGTK 2.52.x üzerinde, Phosh çalıştıran bir mobil Linux cihazında koşturulur.
Ölçülecekler:
1. Ana ekrana kurulum başarılı mı, ayrı `.desktop` girdisi oluşuyor mu?
2. Kurulan uygulama gerçekten ayrı veri profili kullanıyor mu (çerez ve cache paylaşımı testi)?
3. **Uçak modunda uygulama açılıyor ve çevrimdışı çalışıyor mu?**
4. **Uygulama kapalıyken sunucudan gönderilen bir push mesajı bildirim olarak görünüyor mu?** — Bölüm 3, satır 5b'nin kesin cevabı budur.
5. Uygulama kaldırıldığında yerel veri ve arka plan yetkileri gerçekten siliniyor mu (manifesto 6.6)?
6. `navigator.share` ve WebAuthn çağrıları ne yapıyor?

**E2 — Aynı referans PWA, Chromium tabanlı bir portta.**
Aynı uygulama Angelfish (QtWebEngine) üzerinde koşturulur. Amaç, boşluğun motora mı yoksa porta mı ait olduğunu ayırt etmek ve katman (b) kararına veri sağlamaktır.

**E3 — Bellek ve pil ölçümü.**
Referans donanım adayında (RFC-0006), üç web uygulaması + bir tarayıcı açıkken RSS/PSS ölçülür. Site isolation açık ve kapalı iki koşulda tekrarlanır. Chromium tabanlı port ile karşılaştırılır. Bölüm 4 ve 6'daki "ölçülmeli" işaretlerini bu deney kapatır.

**E4 — Güvenlik yaması gecikmesi ölçümü.**
Son 12 aylık WSA danışmanlıkları ile taban dağıtım adaylarının (RFC-0002) paket güncelleme tarihleri karşılaştırılır. Bölüm 6'daki SLA eşiklerinin gerçekçi olup olmadığı bu ölçümle sınanır.

**E5 — Web Push ↔ OZERK Push köprüsü fizibilitesi.**
UnifiedPush'un RFC 8030/8291/8292 uyumlu uçları ile katman (a)'nın Web Push abonelik akışının bağlanabilirliği incelenir. RFC-0007 ile ortak yürütülür. Çıktı: Web Push desteğinin OZERK Push altyapısı üzerine kurulabileceğine dair evet/hayır cevabı ve iş tahmini.

**E6 — Motor soyutlama sınırı denemesi.**
Katman (a)'nın en küçük çalışan hâli, ikinci bir backend ile (WPE WebKit veya bir Chromium portu) koşturulur. Amaç, K5'teki sınırın gerçek olduğunu ve çıkış maliyetinin ölçülebilir olduğunu göstermektir. Sonuç, "bir gün motor değiştirebiliriz" cümlesinin dilek mi yoksa plan mı olduğunu belirler.

#### 9.2. Karar eşikleri

Bu RFC'nin önerdiği yol, ancak aşağıdakiler sağlanırsa kabul edilmelidir:

| # | Ölçüt | Eşik |
|---|---|---|
| Ö1 | Manifesto 6.6'nın yedi vaadi | En az beşi seçilen motorda bugün karşılanıyor; kalanlar için 12 aylık, sahibi belli bir kapatma planı var |
| Ö2 | Güvenlik yaması gecikmesi | Bölüm 6'daki eşikler E4 ile ölçülmüş ve karşılanabilir bulunmuş |
| Ö3 | Bellek | E3 ölçümü referans cihazın bellek bütçesi içinde kalıyor |
| Ö4 | Bakım yükü | Bölüm 7'deki FTE tahmini, öngörülen fonlama ile karşılanabilir (RFC-0008) |
| Ö5 | Lisans | D1 ile uyumlu, ek özgür olmayan bileşen gerekmiyor |
| Ö6 | Çıkış maliyeti | E6 başarılı; motor değiştirmenin ekosistem maliyeti sayıyla ifade edilebiliyor |

Ö1 veya Ö2 karşılanamıyorsa, doğru davranış motoru değiştirmek değil, **vaadi daraltmak ve daraltmayı ilan etmektir.**

#### 9.3. Sonraki adımlar

1. Bu RFC "Tartışma" durumuna alınır; E1 ve E4 deneyleri başlatılır (en düşük maliyetli, en yüksek bilgi değeri taşıyan ikisi).
2. E1 sonucu Bölüm 3'teki tabloya işlenir; "doğrulanmalı" satırları kapatılır.
3. RFC-0002 (taban dağıtım) kararıyla eşgüdüm sağlanır: paket akışı ve güvenlik güncelleme temposu doğrudan o karara bağlıdır.
4. Web Push boşluğu için upstream'e (WebKitGTK/WPE ve Epiphany) bir tasarım tartışması açılır; D3 gereği önce sorulur, sonra yazılır.
5. RFC-0008 kapsamında, Web Push katkısı için bileşen bazlı hibe başvurusu hazırlanır.
6. Deneyler tamamlandığında bu RFC güncellenir ve karara sunulur.

---

### 10. Gözden geçirme takvimi ve çıkış koşulları

Bu karar kalıcı değildir. Aşağıdaki takvim bağlayıcıdır:

- **Her 12 ayda bir:** Bölüm 3'teki yedi vaat tablosu yeniden ölçülür ve yayımlanır. Değişmeyen bir tablo, ölçülmediğinin işaretidir.
- **Her 24 ayda bir:** Motor kararı bütünüyle gözden geçirilir. Servo ve Ladybird her turda yeniden değerlendirilir; "hazır değil" cevabı gerekçesiyle yazılır.
- **Olay tetiklemeli gözden geçirme:** Bölüm 5'teki risk tablosundaki herhangi bir olay gerçekleşirse, takvimi beklemeden gözden geçirme açılır.

**Çıkış koşulları.** Aşağıdakilerden biri gerçekleşirse motor kararı yeni bir RFC ile yeniden açılır:

1. Seçilen portun bakımı durur veya bakımcı değişir.
2. Bölüm 6'daki yama SLA'sı iki ardışık ölçüm döneminde karşılanamaz.
3. Alternatif bir motor, Ö1–Ö6 ölçütlerinin tamamını seçili motordan daha iyi karşılar hâle gelir.
4. Web uyumluluğu, kullanıcıların günlük ihtiyaçlarını karşılayamayacak kadar bozulur (ölçüt: E1 benzeri bir uyumluluk testinin başarısız olduğu, yaygın kullanılan hizmet sayısı).

---

## Alternatifler

### A. Hiçbir şey yapmamak — kararı ertelemek

Motor kararını Aşama 1'e kadar ertelemek mümkündür. Reddediliyor: sınıf C ve D uygulama sınıfları, uygulama manifesti (manifesto 13) ve Guard'ın web tarafı bu karar olmadan tanımlanamaz. Ayrıca erteleme, kararı "önce yazılan koda uydurma" riskini doğurur; bu, RFC sürecinin varlık sebebine aykırıdır.

Yine de dürüst bir not: bu RFC de kararı tamamen vermemektedir; deneylere bağlamaktadır. Aradaki fark, erteleme ile ölçüme bağlama arasındaki farktır.

### B. Tek motor, tek tarayıcı — sadece Chromium

En geniş web uyumluluğunu ve en eksiksiz PWA kapsamını verir; kullanıcı için bugün en az sürtünmeli deneyimdir.

Reddediliyor: bakım yükü OZERK'in ölçeğinin çok üstündedir (Bölüm 7); bellek maliyeti referans donanımda ağırdır; ve manifesto 1'in bağımsızlık iddiasını en zayıf noktasından vurur. Kullanım payı ~%78 olan bir motoru varsayılan yapmak, OZERK'in var oluş gerekçesiyle çelişir.

Bu seçenek yine de tamamen kapatılmaz: katman (b) için Chromium tabanlı bir tarayıcının depoda bulunması, kullanıcı özgürlüğü açısından uygundur (manifesto 6.5).

### C. Tek motor, tek tarayıcı — sadece WebKitGTK

Katman (a) ve (b)'yi ayırmayıp her şeyi Epiphany'ye dayandırmak en basit yoldur ve bakım yükü en düşüktür.

Reddediliyor: bir tarayıcının web uygulaması modu ile sistem düzeyinde bir web uygulama runtime'ı aynı şey değildir. Guard bağlaması, manifest doğrulama, yaşam döngüsü denetimi ve kaldırmada veri silme, tarayıcı arayüzünün sorumluluğu değildir. Ayrıca bu, kullanıcının farklı bir tarayıcı seçmesini web uygulamalarının çalışmasına bağımlı kılardı.

Bu seçeneğin makul bir zayıf hâli vardır: katman (a)'yı ilk aşamada Epiphany'nin web uygulama moduna dayandırıp, olgunlaştıkça ayırmak. E1 sonucu bu ara yolu destekliyorsa değerlendirilebilir.

### D. Motoru forklamak

**Reddedilmiştir** ([RFC-0001](0001-karar-kaydi.md) A1, bu RFC K1). Bu RFC'de yeniden açılmayacaktır.

### E. Motor-agnostik olmak — birden çok motoru aynı anda desteklemek

Katman (a)'nın hem WebKitGTK hem Chromium backend'iyle çalışabilmesi, bağımlılığı gerçekten azaltırdı.

Bugün için reddediliyor: iki backend'i eşdeğer kalitede sürdürmek, bakım yükünü ikiye katlar ve OZERK'in ölçeği tek backend'i bile zorlamaktadır. Ancak K5'teki soyutlama sınırı ve E6 deneyi, bu seçeneği ileride açık tutmayı amaçlar. Yani bugünkü karar "tek backend", tasarım hedefi "değiştirilebilir backend"dir.

### F. Web'i ikinci sınıf yapmak — manifesto 6.6'yı zayıflatmak

Sınıf C ve D'yi kapsam dışı bırakıp yalnızca native uygulamalara (sınıf B) odaklanmak, bu RFC'nin tüm karmaşıklığını ortadan kaldırırdı.

Reddediliyor: manifesto 6.6 kurucu bir ilkedir ve web, küçük bir ekosistemin uygulama açığını kapatmasının en gerçekçi yoludur. Manifesto 24'teki "iyi fikir tek başına ekosistem oluşturmaz" uyarısı tam da bunu söyler: OZERK'in binlerce native uygulama üretme kapasitesi yoktur, ama web zaten oradadır.

Yine de bu alternatifin dürüst bir çekirdeği vardır: eğer Bölüm 9'daki eşikler karşılanamazsa, 6.6'nın **daraltılması** — vaadin tümden bırakılması değil — meşru bir sonuçtur ve manifesto tadili ile yapılır.

---

## Açık Sorular

1. **Web Push, WebKitGTK/WPE portlarında bugün etkinleştirilebilir mi?** Bölüm 3, satır 5b. E1 ve upstream'e sorulacak tasarım sorusu bunu kapatacaktır. Cevap "hayır" ise, katman (a) için sunucu-tetikli bildirimin motordan bağımsız bir yolu tasarlanmalı mıdır, yoksa vaat mi daraltılmalıdır?
2. **WebAuthn boşluğu manifesto 18.2 ile nasıl uzlaştırılacak?** Manifesto 18.2 passkey ve WebAuthn desteğini açıkça vaat eder. Bu vaat sistem düzeyinde mi (native uygulamalar için) yoksa web uygulamaları için de mi geçerlidir? İkincisi ise ve seçilen motor desteklemiyorsa, manifesto tadili gerekecektir.
3. **Katman (a) ile katman (b) aynı motoru mu kullanmalıdır?** Aynı motor bellek ve bakım açısından tasarrufludur (paylaşılan kütüphane). Farklı motorlar, tek hata noktası riskini azaltır. Hangisinin ağır bastığı E3 ölçümüne bağlıdır.
4. **Hosted web uygulamalarında (sınıf D) uzaktan kod değişikliği nasıl ele alınacak?** Manifesto 8.2 D, kullanıcının bilgilendirilmesini şart koşar. Bunun runtime'da teknik karşılığı nedir — her açılışta uyarı mı, Guard'ın alan adı denetimi mi, yoksa içerik bütünlüğü sabitleme (SRI benzeri) mi? RFC-0003 ve RFC-0005 ile birlikte çözülmelidir.
5. **Site isolation bellek nedeniyle kapatılırsa, sınıf C ve D uygulamaları arasındaki izolasyon hangi düzeye iner?** Süreç grubu ayrımı (manifesto 6.6) site isolation ile aynı şey değildir; farkın kullanıcıya nasıl anlatılacağı Gizlilik Merkezi'nin (manifesto 9.3) tasarım sorunudur.
6. **Servo ve Ladybird'e katkı, OZERK'in kaynaklarının doğru kullanımı mıdır?** Uzun vadeli bağımsızlık açısından evet; kısa vadeli ürün açısından hayır. Küçük ama sıfır olmayan bir katkı bütçesi ayrılmalı mıdır?
7. **Bellek ayak izi iddiası doğrulanmalıdır.** WebKitGTK'nın Chromium'a göre daha az bellek kullandığı yaygın kabuldür; elimizdeki kaynaklar anekdot düzeyindedir. E3 bunu ölçmelidir.

---

## English

> The Turkish text is normative in case of discrepancy.

# RFC 0004: Web Application Profile and Browser Engine

| Field | Value |
|---|---|
| **RFC** | 0004 |
| **Title** | Web Application Profile and Browser Engine |
| **Status** | Draft |
| **Date** | 2026-08-17 |
| **Author(s)** | OZERK founder |
| **License** | CC BY-SA 4.0 |
| **Open decision addressed** | [RFC-0001](0001-karar-kaydi.md) — A1 |
| **Related manifesto sections** | 1, 6.6, 6.7, 8.2 (C and D), 10, 13, 18.1, 18.2, 24 |
| **Related RFCs** | RFC-0002 (base distribution), RFC-0003 (package format), RFC-0005 (Guard network model), RFC-0007 (notification and suspend) |

> **Verification note.** The externally sourced technical claims in this document were checked on 17 August 2026. The browser engine field moves quickly. Every line for which no evidence was found is marked **"to be verified"**; those are not claims, they are a work list. All "to be verified" lines must be closed before the decision is made. No unmeasured number in this document is presented as measured; estimates are explicitly labelled as estimates.

---

### Summary

OZERK will not write its own browser engine and will not fork an existing one. Instead, a two-layer structure is proposed:

- **(a) OZERK Web Runtime** — a system-level runtime, built on a single engine, that runs packaged (class C) and hosted (class D) web applications. Based on today's evidence, the leading candidate is the **WebKitGTK / WPE WebKit** family.
- **(b) A general-purpose browser** — packaging an existing browser whose maintenance stays upstream, for the user's ordinary web browsing. This browser will be replaceable and need not use the same engine as layer (a).

The purpose of this split is to shrink the maintenance burden OZERK has to carry, and to draw a boundary that makes changing engines possible.

This RFC also proposes adding two items to manifesto chapter 24 (Honesty Commitment): OZERK's web promise is permanently dependent on an engine it does not and cannot write, and that engine is the largest attack surface in the system.

---

### Motivation

#### The three-engine reality

Manifesto 6.6 declares the web a "first-class application platform" and makes seven concrete promises. Manifesto 1 says OZERK "will not be dependent on a single company."

On the subject of browser engines, these two sentences conflict more sharply than anywhere else.

Today the number of maintained browser engines in the world capable of rendering the real web is **three**:

| Engine | Principal funder | Approx. 2026 usage share |
|---|---|---|
| Blink (Chromium) | Google | ~78% |
| WebKit | Apple (second-largest contributor: Igalia) | ~15–19% |
| Gecko | Mozilla (revenue predominantly from a Google search deal) | ~3% |

*Source: 2026 compilations derived from StatCounter; exact figures vary with methodology. On contributors: Igalia has been the second-largest contributor to WebKit since 2019 and maintains the WebKitGTK and WPE ports.*

All three are sustained with vast resources. There is no fourth option; the two plausible candidates (Servo, Ladybird) are not production-ready today.

This is not something OZERK gets to choose. Every platform that supports the web depends on one of these three engines — Android, iOS, KaiOS, Ubuntu Touch, postmarketOS, all of them. The only things OZERK can do are: name the dependency instead of hiding it, pick the least bad option, and keep the exit cost low.

#### Why the decision is needed now

- All of application classes C and D in manifesto 8.2 depend on this decision. Class C (packaged web applications) and class D (hosted web applications) cannot be defined before an engine is chosen.
- The application manifest in manifesto 13 can only be written once we know which permissions the runtime is able to enforce.
- OZERK Guard (RFC-0005) promises per-application network control. A web application's traffic goes through engine processes; the web side of Guard cannot be designed without knowing the engine's process model.
- The notification architecture (RFC-0007) depends on the status of Web Push. If Web Push is unsupported, a separate notification path must be designed for web applications.
- One of the Phase 1 acceptance criteria is "installing a web application" (manifesto 21). It cannot be met without an engine decision.

Taking the decision late is more expensive than taking it wrong: once the runtime API is published, changing engines breaks the application ecosystem.

---

### Design

#### 1. Scope and definitions

This RFC covers: which browser engine(s) OZERK will build on; which runtime packaged and hosted web applications will run in; the current attainability of the seven promises in manifesto 6.6; and the security and honesty consequences of this dependency.

This RFC does **not** cover (left to other RFCs): the field-by-field definition of the web application manifest schema (pursued together with RFC-0003); the push server protocol and its interaction with suspend (RFC-0007); Guard's network enforcement mechanism (RFC-0005).

| Term | Meaning |
|---|---|
| **Engine** | The core that processes HTML/CSS/JS/WASM (Blink, WebKit, Gecko, the Servo and Ladybird engines). |
| **Port** | An adaptation of an engine to a particular platform/toolkit (WebKitGTK, WPE WebKit, QtWebEngine, CEF). |
| **Web Runtime** | The system component that runs web applications as independent applications, without browser chrome. |
| **Browser** | The general-purpose, tabbed application with an address bar in which the user browses freely. |
| **PWA gap** | A capability promised by manifesto 6.6 that the chosen engine does not provide today. |

#### 2. Proposed decisions

##### K1 — No engine will be forked

[RFC-0001](0001-karar-kaydi.md) A1 already rejected this option. This RFC confirms the rejection and records its rationale.

The most honest indicator we have today of the cost of writing or maintaining a browser engine is Ladybird: a donation-funded, 501(c)(3) independent engine initiative with a full-time team, targeting an alpha in 2026, a beta in 2027, and a **stable release in 2028**. For comparison, Mozilla's scale is in the four-digit employee range. OZERK's scale today is one person.

The fork is rejected for the engine itself. Carrying a downstream patch at the port level (temporarily carrying a bug fix until upstream merges it) does not count as a fork; but per D3 these are submitted upstream and their number is tracked.

##### K2 — A two-layer structure

OZERK does not adopt a "one engine does everything" approach.

**Layer (a): OZERK Web Runtime.** Class C and D applications run in a system-level runtime that is independent of the browser. This layer is OZERK's own code; it embeds an engine but does not write one. Its responsibilities:

- a separate data area per application (cookies, cache, IndexedDB, Cache API, localStorage),
- a separate permission set and Guard network profile binding per application,
- a separate process group per application,
- manifest validation (jointly with RFC-0003),
- deletion of all local data and background privileges on uninstall (manifesto 6.6),
- integration of notifications and sharing with the system via XDG portals.

**Layer (b): General-purpose browser.** An existing browser whose maintenance stays upstream is packaged for free browsing. OZERK does not develop its engine and does not rewrite its interface.

##### K3 — Candidate for layer (a): WebKitGTK / WPE WebKit

This RFC proposes the WebKitGTK (or, in an embedding scenario, WPE WebKit) family as the **leading candidate** for layer (a); it does not present this as a binding decision before the experiments in Section 9 are complete.

Rationale in brief:

- This is the de facto established path on mobile Linux today: on Phosh/GNOME-based mobile Linux distributions the system browser is Epiphany, and Epiphany is built on WebKitGTK.
- The WebKitGTK and WPE ports are maintained by Igalia. This does not remove dependency on a single large company (the engine itself is WebKit, and WebKit's principal contributor is Apple), but at the **port level** it moves the decision-making outside Apple, to a European worker cooperative. That is a meaningful but limited difference for independence, and it should be presented as such.
- WPE WebKit is the port designed specifically for embedding; the WPEPlatform layer is available in 2.52 and is expected to become the default in 2.54. This is a directly suitable embedding surface for layer (a).
- Its memory footprint is lower than Chromium-based alternatives (widely held; **an independent measurement is required** — Section 9, E3).
- Its source tree and build cost are orders of magnitude smaller than Chromium's; it is sustainable within the base distribution's existing package pipeline (RFC-0002).
- The licensing (a mix of LGPL-2.1 and BSD) is compatible with D1.

Its greatest weakness is equally clear: **its PWA API coverage is the narrowest of the three engines.** The table in Section 3 shows this line by line.

##### K4 — For layer (b): the user chooses; the default is decided separately

The general-purpose browser need not use the same engine as layer (a). OZERK will: offer at least one packaged browser in the official repository; not technically prevent the user from installing another browser (manifesto 6.5); and clearly state which browser uses which engine in the Freedom Inventory (RFC-0006).

Which browser will be the default is not decided in this RFC; it depends on the base distribution decision (RFC-0002) and on experiment E2.

##### K5 — The engine abstraction boundary

The surface layer (a) presents to developers and to the system (manifest fields, permission model, storage contract, lifecycle events) is defined **independently of the engine**. No engine-specific concept leaks into that surface.

The goal is not purity but a measurable exit cost: if the engine has to be changed, we should know in advance how much of the ecosystem will break. That this boundary actually works is proven by running the same runtime on a second backend (Section 9, E6).

##### K6 — PWA gaps are closed by contributing upstream

Per D3 (upstream-first strategy): when a missing web platform capability is identified, OZERK's first route is to submit that capability upstream to the relevant port (WebKitGTK / WPE / Epiphany). Carrying a downstream patch is a temporary measure and is recorded with its rationale.

Gaps that cannot be closed are **not hidden**: which promise is unmet on which device is written into the Freedom Inventory and the developer documentation (manifesto 6.14, 24).

---

#### 3. The seven promises of manifesto 6.6: status by engine

Manifesto 6.6 says a web application will be able to do the following. The table below shows the status of each promise on each engine **as of 17 August 2026**.

Notation: **✅** supported · **◐** partial · **✕** absent · **?** to be verified

| # | Promise (manifesto 6.6) | WebKitGTK (+Epiphany) | Chromium (QtWebEngine / CEF) | Gecko (Firefox, Linux) | Servo | Ladybird |
|---|---|---|---|---|---|---|
| 1 | Installable to the home screen | ✅ Epiphany installs as a "Web App"; generates a `.desktop` entry | ✅ Angelfish (Plasma Mobile) supports PWA installation; Chromium `--app` mode | ✕ Desktop Firefox has no site-specific browser / PWA support (**?** 2026 status to be confirmed) | ✕ | ✕ |
| 2 | Runs in an independent application window | ✅ | ✅ | ◐ via external tooling (`--kiosk`, third-party wrappers) | ✕ | ✕ |
| 3 | Has its own storage area | ✅ Each Epiphany web app uses a separate data profile; cookies and cache are not shared | ✅ via a separate profile directory | ◐ profile separation is manual | **?** | ✕ |
| 4 | Works offline | ✅ Service Workers on by default since WebKitGTK 2.28.0 (March 2020); Cache API and IndexedDB present | ✅ | ✅ at the engine level | **?** Service Worker status to be verified | ✕ |
| 5a | Receives notifications — **while the page is open** (Notifications API) | ✅ via the `WebKitWebView::show-notification` signal | ✅ | ✅ | **?** | ✕ |
| 5b | Receives notifications — **while the page is closed** (Web Push, RFC 8030/8291/8292) | **?** `webpushd` exists in the WebKit core, but no evidence was found that it is enabled in the GTK/WPE ports — **to be verified; the most critical gap** | **?** whether the Push API is enabled in QtWebEngine must be verified; raw Chromium supports it but the default endpoint is Google infrastructure | ✅ Firefox supports Web Push; redirecting it to UnifiedPush is documented in the IronFox/Fennec forks | ✕ | ✕ |
| 6 | Participates in the system share interface (Web Share API) | **?** no evidence found; likely absent | **?** the status of `navigator.share` on Linux must be verified | **?** | ✕ | ✕ |
| 7 | Accesses camera, microphone and location with user permission | ✅ Camera access via XDG Desktop Portal since WebKitGTK 2.50 (November 2025); Epiphany 49 added location portal support | ✅ (portal integration quality **?**) | ✅ | ✕ | ✕ |
| + | *(not in 6.6, but the practical complement of the offline promise)* Background Sync / Periodic Background Sync | ✕ Not supported in any WebKit version; WebKit standards-positions #14 open, "unlikely soon" | ✅ Supported in Chromium | ✕ Not supported in Firefox | ✕ | ✕ |
| + | *(promised in manifesto 18.2)* WebAuthn / passkeys | **?** there are findings that it is unsupported in WebKitGTK — **to be verified; direct risk of conflict with manifesto 18.2** | ✅ | ✅ | ✕ | ✕ |

**Three conclusions from the table:**

1. Five of the seven promises (1, 2, 3, 4, 7) appear attainable on WebKitGTK today. That means most of the "the web is a first-class platform" claim can be carried.
2. **Promise 5b (notifications while closed) is the most critical gap.** A messaging, calendar or email web application is not usable without it. If this gap is not closed, the fifth item of manifesto 6.6 cannot be met as currently written, and per manifesto 24 that has to be stated openly.
3. For promise 6 (system sharing) and for WebAuthn, no reliable Linux evidence was found on any engine; those go onto the verification list as well.

**One opportunity:** the UnifiedPush specification has been updated to require encryption (RFC 8291) and VAPID authorization (RFC 8292) — meaning UnifiedPush endpoints are now explicitly Web Push endpoints. This means OZERK Push (RFC-0007) and layer (a)'s Web Push support could **share the same infrastructure**. The same path has been shown to work on the Gecko side, where web push was added to Firefox forks (IronFox/Fennec) over UnifiedPush. This is the most concrete candidate for the contribution work described in K6.

---

#### 4. Evaluation of the options

Each option was evaluated against: current state on mobile Linux · PWA/Service Worker/Web Push/background sync coverage · security patch cadence and maintenance burden · embedding API quality · Wayland/touch fit · memory footprint · license compatibility.

##### Option 1 — WebKitGTK / WPE WebKit

| Criterion | Status |
|---|---|
| State on mobile Linux | **The most established path.** On Phosh/GNOME-based mobile Linux distributions the system browser is Epiphany. Development is active: WebKitGTK 2.52.5 (9 July 2026), Epiphany 50.6 (13 August 2026). |
| PWA coverage | **The narrowest.** Service Workers ✅ (since 2.28.0), separate profiles ✅, installation ✅, camera/location via portals ✅. Web Push **?**, Web Share **?**, Background Sync ✕, WebAuthn **?**. |
| Security cadence | Advisories are published regularly: 10 in 2025 (WSA-2025-0001…0010), 4 in 2026 through July (WSA-2026-0001…0004). Roughly one every 5–6 weeks. Fixes flow from the upstream WebKit change into a port release; **the lag has not been measured** (Section 9, E4). |
| Maintenance burden | Engine maintenance stays upstream (Igalia). OZERK's burden: packaging, runtime integration, contributions for PWA gaps. Orders of magnitude lower than Chromium. |
| Embedding API quality | A mature GObject API for WebKitGTK; three API versions supported in parallel (webkitgtk-6.0 / webkit2gtk-4.1 / webkit2gtk-4.0). WPE WebKit is designed for embedding; WPEPlatform is available in 2.52 and expected to be the default in 2.54. **Known weakness:** API version fragmentation across distributions is a documented pain point for projects that build on WebKitGTK, such as Tauri. |
| Wayland / touch | Wayland is a first-class path (WPE was literally born as "WebKit for Wayland"). Touch gesture quality and on-screen keyboard integration **must be measured** on the reference device. |
| Memory footprint | Widely held to be markedly lower than Chromium's; but our sources are anecdotal. **An independent measurement is needed** (E3). |
| License | A mix of LGPL-2.1 and BSD; compatible with D1. |

##### Option 2 — Chromium-based embedding (CEF, QtWebEngine, or direct)

| Criterion | Status |
|---|---|
| State on mobile Linux | Genuinely in use: Plasma Mobile's browser, Angelfish, is built on QtWebEngine (i.e. Blink). So this path is not theoretical on mobile Linux. |
| PWA coverage | **The widest.** All seven promises and the surrounding APIs including Background Sync exist in Chromium. Whether they are enabled in embedding ports such as QtWebEngine/CEF is a separate question — **to be verified**. |
| Security cadence | Chromium's patch cadence is fast, and that is a liability rather than an advantage: the downstream packager must rebuild at the same rate. The Chromium version carried by QtWebEngine lagging upstream is a known and recurring criticism. **A concrete lag figure must be verified.** |
| Maintenance burden | **The heaviest option.** The Chromium source tree and build time are not at a scale a small project can sustain on its own. Maintaining an "ungoogled" variant means re-adapting a Google-dependency-stripping patch set on every release. |
| Embedding API quality | CEF is mature and widely used; QtWebEngine is the direct path for Qt applications. The current state of ARM64 Linux + Wayland support **must be verified**. |
| Wayland / touch | The Ozone/Wayland path has matured; how well touch and on-screen keyboard integration fit mobile shells (Phosh/Plasma Mobile) **must be measured**. |
| Memory footprint | The highest. With site isolation on, the per-process overhead becomes decisive on a low-RAM phone (Section 6). |
| License | The core is BSD-3-Clause, but there are non-free parts in codec and DRM components. Compatibility with the official OZERK Free repository's open-source-only rule (manifesto 14.1) **must be examined**. |
| Independence | **The worst option** with respect to manifesto 1: Blink's direction is set by Google and its usage share is ~78%. Choosing this engine strikes the "not dependent on a single company" claim at its weakest point. |

##### Option 3 — Gecko / GeckoView

| Criterion | Status |
|---|---|
| State on mobile Linux | Firefox runs on desktop Linux; there is no official build optimized for mobile shells. Touch and small-screen fit **to be verified**. |
| PWA coverage | Web Push ✅ (and shown to be redirectable to UnifiedPush in Firefox forks). But **installable web app / site-specific browser support does not exist in desktop Firefox**; Background Sync is unsupported. So promises 1, 2 and 3 of 6.6 would have to be built from scratch by OZERK rather than provided by the engine. |
| Embedding API quality | **The decisive weakness of this option.** Mozilla abandoned the general-purpose Gecko embedding API years ago. GeckoView is tied to Android (the Android build system and JNI). There is no supported embedding path on plain Linux — **to be verified, but expected to be absent.** |
| Security cadence | Mozilla's patch cadence is good; but packaging happens at the level of the Firefox application, not an embeddable library. |
| Maintenance burden | Because there is no embedding path, layer (a) cannot be built on this engine; attempting it would push the maintenance burden toward that of a fork. |
| Memory footprint | Between Chromium and WebKitGTK; **to be measured.** |
| License | MPL-2.0; compatible with D1. |
| Independence | Ostensibly the most "independent" engine; but Mozilla's revenue depending predominantly on a Google search deal limits that independence. How the US search-case rulings have affected that revenue **must be verified as of 2026.** |

**Conclusion:** Gecko is a reasonable option for layer (b) (as a packaged browser). It is unsuitable for layer (a) as long as no embedding path exists.

##### Option 4 — Servo

| Criterion | Status |
|---|---|
| Current state | **Not production-ready, but pointed in the right direction.** Its stated short-term goal is explicitly to move from a research project to a production-ready web engine. |
| Embedding API quality | An area of active development. The embedding API covers HTTP proxies, root certificates, localStorage/sessionStorage and cookie management. The `servo` crate has begun to be published on crates.io; alongside monthly feature releases, an LTS branch every six months (with roughly nine months of support) is planned. |
| Web platform coverage | Increasingly adequate for controlled content (rendering documentation, UIs built with HTML/CSS); **still rough for arbitrary content from the open internet.** Service Worker and IndexedDB status **to be verified.** |
| Security posture | Sandboxing/multi-process architecture and the security response process **to be verified.** Its own documentation states that production embedding requires "API wrappers, sandboxing, and Web API compatibility testing." |
| Governance | Under Linux Foundation Europe; Igalia plays a decisive role. Full-time engineer count **to be verified.** |
| Independence | A genuine fourth-path candidate not tied to any of the three engines. In the long run this is the option best aligned with OZERK's interests. |

**Conclusion:** Cannot be chosen today. To be **watched**, and re-evaluated at every round of the review schedule (Section 10). If Servo's embedding API comes to satisfy OZERK's layer (a) contract, the abstraction boundary in K5 will make the migration cost measurable.

##### Option 5 — Ladybird

| Criterion | Status |
|---|---|
| Current state | **Not mature.** Roadmap: alpha in 2026 (Linux and macOS, for developers and early adopters), beta in 2027, **stable release in 2028**. The development model was changed ahead of the alpha and acceptance of public pull requests was stopped — **date and scope to be verified.** |
| Independence | **Its greatest strength.** Not a fork of any existing engine; written from scratch. Funded by donations and sponsorships through a 501(c)(3) nonprofit (sponsors include Cloudflare, FUTO, Shopify and 37signals; co-founder Chris Wanstrath's family pledged $1 million). |
| Embedding API | **To be verified;** no evidence was found that one exists today. |
| Security posture | Sandboxing / multi-process status **to be verified.** Using an alpha-stage engine with untrusted content is not defensible today. |
| ARM64 / mobile Linux | **To be verified.** |

**Conclusion:** Cannot be chosen today. Ladybird is the project whose goals overlap most with OZERK's long-term interests and it **deserves support**; but for an operating system to base its web platform on an alpha engine in 2026 would violate the honesty standard of manifesto 24.

##### Comparison summary

| | WebKitGTK/WPE | Chromium | Gecko | Servo | Ladybird |
|---|---|---|---|---|---|
| Suitable for layer (a) today? | **Yes (conditionally)** | Yes but unsustainable | No (no embedding path) | No (not yet) | No (not yet) |
| Suitable for layer (b) today? | Yes | Yes | Yes | No | No |
| PWA coverage | Narrow | Wide | Medium | Unknown | Narrow |
| OZERK's maintenance burden | Low | Very high | High | Unknown | Unknown |
| Single-company dependence | Medium (Apple + Igalia) | **High (Google)** | Medium (Mozilla, revenue tied to Google) | Low | **Lowest** |
| Memory | Low | High | Medium | Unknown | Unknown |

---

#### 5. Dependency honesty

This section is mandatory and may not be abbreviated.

**Whichever option is chosen, OZERK will remain dependent on an upstream browser engine.** This dependency is:

- **not temporary.** Engine maintenance will stay outside OZERK for years.
- **not avoidable.** The only way to avoid it is to write an engine, and that was rejected in K1.
- **mitigable.** A non-Apple maintainer at the port level (Igalia), the embedding boundary (K5), and the exit plan (Section 10) make the dependency manageable, but do not eliminate it.

##### What the independence claim in manifesto 1 means

Manifesto 1 says: *"OZERK will not be dependent on a single company, a single application store, a single cloud provider, or a single hardware manufacturer."*

In the context of the browser engine, this sentence **does** mean:

- The user decides which browser to install; the system does not impose a single browser (manifesto 6.5).
- The engine's source code is open, auditable and forkable; OZERK has chosen not to fork it — not because it could not, but because it could not sustain it.
- The engine provider cannot build commercial leverage over an OZERK user: there is no mandatory account, telemetry is controlled on OZERK's side, and network access is constrained by Guard.
- OZERK's obligations to the user (privacy, account-free use, data portability) are not delegated to the engine provider's policies.

This sentence **does not** mean:

- **It does not mean OZERK can set the technical direction of the web platform.** Apple, Google and Mozilla decide which web APIs get implemented. OZERK does not have a seat at that table.
- **It does not mean OZERK can close a security hole on its own.** In the event of a critical engine vulnerability, all OZERK can do is wait for the upstream patch and ship it quickly.
- **It does not mean OZERK could take over if development of the engine stopped.** There is no such capacity, and this RFC does not plan to acquire it.
- **It does not mean OZERK can guarantee web compatibility.** If a site is written to work only in Chromium, OZERK cannot fix that.

In short: **OZERK's independence claim is about the relationship between the user and the platform; it is not about the relationship between the platform and the developers of the web engine.** Conflating the two is exactly the kind of overstatement that manifesto 24 forbids.

##### The dependency, named

OZERK's web platform is directly harmed if any of the following occurs:

| Risk | Effect | Assessment today |
|---|---|---|
| Igalia stops maintaining WebKitGTK/WPE | Layer (a) is left unmaintained | Low probability, high impact. To be monitored. |
| Apple closes WebKit or changes its direction | The ports are left without upstream | Very low probability, very high impact |
| The web drifts toward Chromium-specific behavior | Web compatibility degrades; the user is pushed to Chromium | **Medium-to-high probability, high impact. This is the most real risk today.** |
| The Web Push gap is never closed | The fifth promise of 6.6 cannot be met | Already the case (see Section 3) |

---

#### 6. The security burden

This section is mandatory as well.

**The browser engine is the largest attack surface on a web-first platform.** On OZERK this has a heavier consequence than on other systems: all class C and D applications share the same engine. A single remote-code-execution flaw in the engine therefore threatens the user's banking web app, messaging web app and browser tabs **at the same time**.

That is a single point of failure, and it carries a real risk of conflicting with manifesto 10.1's protection goals (inter-application data leakage, covert background data transfer).

##### No promise can be made without a patch SLA

We have no measurement today. What we do have:

- WebKitGTK security advisories are published regularly: 10 in 2025, 4 in 2026 through July.
- A concrete real incident: CVE-2025-13947 allowed websites to exfiltrate files from the user's filesystem via drag-and-drop; it was fixed in WebKitGTK 2.50.3. Apple platforms were unaffected — meaning **port-specific vulnerabilities are real**, and relying on Apple's patch cadence is not sufficient.
- A historical warning: the period in which Linux distributions shipped unmaintained WebKitGTK 2.4 and QtWebKit for years shows that mobile Linux is not automatically safe here. That problem has been resolved on the large distributions, but it is not automatic for a small and new one — and **OZERK is exactly such a distribution.**

For that reason this RFC proposes binding the engine decision to a **measurable patch SLA**:

| Metric | Proposed threshold | Note |
|---|---|---|
| Time from upstream WSA publication to an updated package in the OZERK repository — median | ≤ 7 days | Measured by E4 |
| Same — 90th percentile | ≤ 14 days | |
| Actively exploited vulnerabilities (KEV-like) | ≤ 72 hours | |
| Public disclosure of the measurement | Mandatory | Results are published in the repository (manifesto 24) |

**If these thresholds cannot be met, it is not the chosen engine that is not ready — it is OZERK.** In that case the honest behavior is not to delay shipping the web application platform, but to ship it with the limit declared.

##### The cost of site isolation on a RAM-constrained phone

Site isolation (running different sites in different processes) is the most effective defense against Spectre-class and in-process escape attacks. Its cost is memory: every extra process means extra resident memory.

This is a critical tension for OZERK, because the reference hardware (RFC-0006) will likely be a second-hand device with 3–6 GB of RAM.

Current state:

- **In Chromium**, site isolation is mature and on by default; however it is known that full site isolation is disabled on low-memory Android devices. **The threshold value and the 2026 policy must be verified.**
- **In WebKit**, site isolation is newer. As of early 2025 the project was on step two of a three-step plan (fixing functionality broken by site isolation); step three was fixing performance regressions. **Its current status in the WebKitGTK/WPE ports must be verified.**

OZERK's position should be:

1. The memory cost of site isolation on the reference device is **measured** (E3), not estimated.
2. If site isolation is disabled for memory reasons, this is **disclosed clearly to the user** and written into the Freedom Inventory. Disabling it silently would violate manifesto 24.
3. Layers (a) and (b) may have different policies: isolating a small number of trusted web applications has a different memory profile from arbitrary web browsing. That distinction is a measurable side benefit of the two-layer structure.

##### Sandbox layers

The engine's own sandbox (WebKitGTK uses a bubblewrap-based sandbox — **to be verified**) is not treated as the sole line of defense. Layer (a) places OZERK's own layers **on top of** the engine's sandbox:

- a Flatpak/portal-based application sandbox (RFC-0003),
- the Guard network profile (RFC-0005) — which domains a web application may reach are declared in the manifest (manifesto 13),
- a separate data area per application, so that a flaw in one application does not reach another's data.

---

#### 7. The cost of closing the PWA gaps

The figures below are **estimates**, not measurements. They must be compared against at least one independent opinion before the decision.

Permanent engineer (FTE) estimate for the proposed two-layer path:

| Work | Initial implementation (est.) | Ongoing maintenance (est.) |
|---|---|---|
| The layer (a) runtime itself (profile isolation, manifest, lifecycle, Guard binding) | 9–15 engineer-months | **1–2 FTE** |
| Adding Web Push to WebKitGTK/WPE as an upstream contribution and wiring it to UnifiedPush | 6–12 engineer-months | **0.5 FTE** |
| Web Share API + system share portal binding | 3–6 engineer-months | 0.25 FTE |
| WebAuthn/passkey support (required by manifesto 18.2) | 6–12 engineer-months | 0.5 FTE |
| Layer (b) browser packaging + security patch tracking | 2–4 engineer-months | **0.5–1 FTE** |
| **Total (proposed path)** | | **≈ 3–4 FTE, permanent** |

For comparison:

| Path | Permanent FTE estimate |
|---|---|
| The proposed two-layer path (WebKitGTK/WPE) | ≈ 3–4 |
| A Chromium base, maintaining an ungoogled variant in-house | ≈ 8–15+ |
| Forking an engine | Double digits, permanent — **out of scope (K1)** |

**OZERK's current number of permanent engineers is zero.** That figure is the single most important finding of this RFC, and it has two consequences:

1. This work cannot be done without volunteer contribution and external funding (RFC-0008 / A6). The Web Push contribution is a natural candidate for component-scoped grants of the NGI0/NLnet kind: narrow scope, output going upstream, clear public benefit.
2. The Phase 1 criterion "installing a web application" can be met without closing all the gaps; but which promises are unmet must be declared.

---

#### 8. Proposed addition to manifesto chapter 24

This RFC proposes adding the following two items to the list in manifesto 24 (Honesty Commitment):

> - The promise that the web is a first-class application platform is permanently dependent on a browser engine that OZERK does not and cannot write; the number of maintained engines in the world is three, and all three are funded by organizations many times larger than OZERK. OZERK does not set the technical direction of the web platform.
> - The browser engine is the largest attack surface in a web-first system, and all web applications share it; OZERK depends on upstream's cadence for patching that surface, and publishes the patch delay it measures.

Amendments to the manifesto require an RFC under [RFC-0000](0000-rfc-sureci.md). Acceptance of this RFC includes the addition of the two items above to manifesto 24. If the amendment text is to be discussed separately, it may be split into its own RFC; in that case acceptance of this RFC does not block that amendment.

---

#### 9. Decision criteria and next steps

##### 9.1. Experiments required before the decision can be made

This RFC should not move to "Accepted" before the experiments below are complete. The output of each experiment is published in the repository.

**E1 — Reference PWA on WebKitGTK (the most critical experiment).**
A small reference web application is written: web app manifest + service worker + Cache API + IndexedDB + push subscription + a `navigator.share` attempt + camera/location access. It is run on Epiphany 50.x / WebKitGTK 2.52.x on a mobile Linux device running Phosh.
To measure:
1. Does installation to the home screen succeed, and is a separate `.desktop` entry created?
2. Does the installed application genuinely use a separate data profile (cookie and cache sharing test)?
3. **Does the application open and work offline in airplane mode?**
4. **Does a push message sent from a server appear as a notification while the application is closed?** — this is the definitive answer to row 5b of Section 3.
5. When the application is uninstalled, are local data and background privileges genuinely deleted (manifesto 6.6)?
6. What do `navigator.share` and WebAuthn calls do?

**E2 — The same reference PWA on a Chromium-based port.**
The same application is run on Angelfish (QtWebEngine). The aim is to distinguish whether a gap belongs to the engine or to the port, and to inform the layer (b) decision.

**E3 — Memory and battery measurement.**
On the candidate reference hardware (RFC-0006), RSS/PSS is measured with three web applications plus a browser open. Repeated with site isolation on and off. Compared against a Chromium-based port. This experiment closes the "must be measured" marks in Sections 4 and 6.

**E4 — Security patch delay measurement.**
The WSA advisories of the last 12 months are compared against the package update dates of the candidate base distributions (RFC-0002). This measurement tests whether the SLA thresholds in Section 6 are realistic.

**E5 — Feasibility of a Web Push ↔ OZERK Push bridge.**
The connectability of UnifiedPush's RFC 8030/8291/8292-compliant endpoints to layer (a)'s Web Push subscription flow is examined. Conducted jointly with RFC-0007. Output: a yes/no answer on whether Web Push support can be built on the OZERK Push infrastructure, plus a work estimate.

**E6 — Engine abstraction boundary trial.**
The smallest working form of layer (a) is run on a second backend (WPE WebKit or a Chromium port). The aim is to show that the boundary in K5 is real and that the exit cost is measurable. The result determines whether "we could change engines one day" is a wish or a plan.

##### 9.2. Decision thresholds

The path proposed by this RFC should be accepted only if the following hold:

| # | Criterion | Threshold |
|---|---|---|
| Ö1 | The seven promises of manifesto 6.6 | At least five are met on the chosen engine today; the rest have a 12-month closure plan with a named owner |
| Ö2 | Security patch delay | The thresholds in Section 6 have been measured by E4 and found attainable |
| Ö3 | Memory | The E3 measurement stays within the reference device's memory budget |
| Ö4 | Maintenance burden | The FTE estimate in Section 7 is coverable by the anticipated funding (RFC-0008) |
| Ö5 | License | Compatible with D1; no additional non-free component required |
| Ö6 | Exit cost | E6 succeeds; the ecosystem cost of changing engines can be expressed as a number |

If Ö1 or Ö2 cannot be met, the correct response is not to change the engine but to **narrow the promise and declare the narrowing.**

##### 9.3. Next steps

1. This RFC moves to "Discussion"; experiments E1 and E4 are started (the two with the lowest cost and the highest information value).
2. The E1 result is written into the table in Section 3; the "to be verified" rows are closed.
3. Coordination with the RFC-0002 (base distribution) decision: the package pipeline and the security update cadence depend directly on it.
4. A design discussion for the Web Push gap is opened upstream (WebKitGTK/WPE and Epiphany); per D3, ask first, write second.
5. Under RFC-0008, a component-scoped grant application is prepared for the Web Push contribution.
6. When the experiments are complete, this RFC is updated and put to a decision.

---

#### 10. Review schedule and exit conditions

This decision is not permanent. The following schedule is binding:

- **Every 12 months:** the seven-promise table in Section 3 is re-measured and republished. A table that never changes is a sign that it was not measured.
- **Every 24 months:** the engine decision is reviewed in full. Servo and Ladybird are re-evaluated at every round; a "not ready" answer is written down with its rationale.
- **Event-triggered review:** if any event in the risk table in Section 5 occurs, a review is opened without waiting for the schedule.

**Exit conditions.** The engine decision is reopened with a new RFC if any of the following occurs:

1. Maintenance of the chosen port stops, or the maintainer changes.
2. The patch SLA in Section 6 is missed in two consecutive measurement periods.
3. An alternative engine comes to satisfy all of criteria Ö1–Ö6 better than the chosen one.
4. Web compatibility degrades to the point where users' daily needs cannot be met (metric: the number of widely used services on which an E1-like compatibility test fails).

---

### Alternatives

#### A. Doing nothing — deferring the decision

It is possible to defer the engine decision until Phase 1. Rejected: application classes C and D, the application manifest (manifesto 13) and the web side of Guard cannot be defined without it. Deferral also creates the risk of fitting the decision to code that was written first, which is contrary to the reason the RFC process exists.

An honest note nonetheless: this RFC does not fully take the decision either; it binds it to experiments. The difference is the difference between deferring and conditioning on measurement.

#### B. One engine, one browser — Chromium only

Gives the widest web compatibility and the most complete PWA coverage; it is today's least-friction experience for the user.

Rejected: the maintenance burden is far above OZERK's scale (Section 7); the memory cost is heavy on the reference hardware; and it strikes manifesto 1's independence claim at its weakest point. Making an engine with ~78% usage share the default contradicts OZERK's reason for existing.

The option is nonetheless not closed entirely: having a Chromium-based browser available in the repository for layer (b) is appropriate for user freedom (manifesto 6.5).

#### C. One engine, one browser — WebKitGTK only

Not separating layers (a) and (b) and basing everything on Epiphany is the simplest route and carries the lowest maintenance burden.

Rejected: a browser's web-app mode and a system-level web application runtime are not the same thing. Guard binding, manifest validation, lifecycle control and data deletion on uninstall are not the responsibility of browser chrome. It would also make web applications' operation dependent on the user's choice of browser.

There is a reasonable weaker form of this option: basing layer (a) on Epiphany's web application mode in the first phase and separating it as it matures. If the E1 result supports this intermediate path, it can be considered.

#### D. Forking an engine

**Rejected** ([RFC-0001](0001-karar-kaydi.md) A1, and K1 of this RFC). It will not be reopened in this RFC.

#### E. Being engine-agnostic — supporting several engines at once

Making layer (a) work with both a WebKitGTK and a Chromium backend would genuinely reduce the dependency.

Rejected for today: maintaining two backends at equivalent quality doubles the maintenance burden, and OZERK's scale is strained by even one. However, the abstraction boundary in K5 and experiment E6 aim to keep this option open for later. That is, today's decision is "a single backend" while the design goal is "a replaceable backend."

#### F. Making the web second-class — weakening manifesto 6.6

Dropping classes C and D from scope and focusing only on native applications (class B) would eliminate all the complexity in this RFC.

Rejected: manifesto 6.6 is a founding principle, and the web is the most realistic way for a small ecosystem to close its application gap. The warning in manifesto 24 that "a good idea alone does not create an ecosystem" says exactly this: OZERK does not have the capacity to produce thousands of native applications, but the web is already there.

This alternative does have an honest core, though: if the thresholds in Section 9 cannot be met, **narrowing** 6.6 — not abandoning the promise altogether — is a legitimate outcome, and it is done by amending the manifesto.

---

### Open Questions

1. **Can Web Push be enabled in the WebKitGTK/WPE ports today?** Section 3, row 5b. E1 and a design question to upstream will close this. If the answer is "no", should a non-engine path for server-triggered notification be designed for layer (a), or should the promise be narrowed?
2. **How will the WebAuthn gap be reconciled with manifesto 18.2?** Manifesto 18.2 explicitly promises passkey and WebAuthn support. Does that promise apply at the system level (for native applications), or to web applications as well? If the latter, and the chosen engine does not support it, a manifesto amendment will be required.
3. **Should layers (a) and (b) use the same engine?** The same engine saves memory and maintenance (a shared library). Different engines reduce the single-point-of-failure risk. Which dominates depends on the E3 measurement.
4. **How will remote code change in hosted web applications (class D) be handled?** Manifesto 8.2 D requires that the user be informed. What is the technical expression of that in the runtime — a warning at every launch, Guard's domain control, or content integrity pinning (SRI-like)? To be resolved together with RFC-0003 and RFC-0005.
5. **If site isolation is disabled for memory reasons, what level does isolation between class C and D applications fall to?** Process-group separation (manifesto 6.6) is not the same thing as site isolation; how to explain the difference to the user is a design problem for the Privacy Center (manifesto 9.3).
6. **Is contributing to Servo and Ladybird a correct use of OZERK's resources?** In terms of long-term independence, yes; in terms of the short-term product, no. Should a small but non-zero contribution budget be set aside?
7. **The memory footprint claim must be verified.** That WebKitGTK uses less memory than Chromium is widely held; our sources are anecdotal. E3 must measure it.

---

## Kaynaklar / Sources

Aşağıdaki kaynaklar 17 Ağustos 2026 tarihinde kontrol edilmiştir. Bir iddianın kaynağı burada yoksa, o iddia belgede "doğrulanmalı" olarak işaretlidir.

*The sources below were checked on 17 August 2026. If a claim has no source here, it is marked "to be verified" in the document.*

**WebKitGTK / WPE WebKit**

- WebKitGTK proje sayfası ve sürümler / project page and releases — <https://webkitgtk.org/> (2.52.5, 9 Temmuz / July 2026)
- WebKitGTK güvenlik danışmanlıkları / security advisories (WSA) — <https://webkitgtk.org/security.html>
- WebKitGTK 2.50 öne çıkanlar / highlights (XDG portal kamera erişimi / portal camera access) — <https://webkitgtk.org/2025/11/26/webkitgtk-2.50.html>
- WebKitGTK 2.28.0 (Service Worker varsayılan açık / on by default) — <https://webkitgtk.org/2020/03/10/webkitgtk2.28.0-released.html>
- CVE-2025-13947, sürükle-bırak dosya sızdırma / drag-and-drop file exfiltration — <https://blogs.gnome.org/mcatanzaro/category/webkit/>
- WebKitGTK API sürümleri / API versions — <https://blogs.gnome.org/mcatanzaro/category/webkit/>
- WPE WebKit ve WPEPlatform — <https://www.igalia.com/project/wpe>, <https://wpewebkit.org/about/faq.html>
- Igalia'nın WebKit içindeki rolü / Igalia's role in WebKit — <https://www.igalia.com/technology/browsers>, <https://en.wikipedia.org/wiki/Igalia>
- FOSDEM 2026, "The Web Platform on Linux devices with WebKit: where are we now?" — <https://fosdem.org/2026/schedule/event/8ZL9BZ-web-platform-on-linux-devices-with-webkit/>
- Dağıtımların bakımsız WebKit sürümleri dağıtması (tarihsel) / distros shipping unmaintained WebKit (historical) — <https://lwn.net/Articles/730185/>, <https://blogs.gnome.org/mcatanzaro/2017/08/06/endgame-for-webkit-woes/>
- WebKitGTK'ya dayanan projelerde API sürümü parçalanması / API version fragmentation — <https://github.com/orgs/tauri-apps/discussions/10026>

**Epiphany / GNOME Web**

- Epiphany 50.6 (13 Ağustos / August 2026) ve uygulama bilgisi / app info — <https://apps.gnome.org/Epiphany/>
- Web uygulamalarının ayrı veri profili kullanması / separate data profiles for web apps — <https://wiki.gnome.org/Apps(2f)Web(2f)Docs(2f)Applications.html>, <https://fedoramagazine.org/standalone-web-applications-gnome-web/>
- GNOME 49 Epiphany değişiklikleri (konum portalı, web uygulaması kaldırma) / changes (location portal, web app uninstall) — <https://release.gnome.org/49/>

**Chromium / Blink**

- Angelfish'in QtWebEngine kullanması / Angelfish uses QtWebEngine — <https://invent.kde.org/plasma-mobile/angelfish>, <https://apps.kde.org/angelfish/>
- Chromium süreç modeli ve site isolation / process model and site isolation — <https://chromium.googlesource.com/chromium/src/+/main/docs/process_model_and_site_isolation.md>

**WebKit site isolation ve Background Sync / and Background Sync**

- WebKit site isolation belgeleri / documentation — <https://docs.webkit.org/Deep%20Dive/SiteIsolation.html>
- Background Sync WebKit standards-positions #14 — <https://github.com/WebKit/standards-positions/issues/14>
- Web Push ve `webpushd` (Apple platformları / Apple platforms) — <https://webkit.org/blog/12945/meet-web-push/>

**Servo**

- Servo proje ve hedefler / project and goals — <https://servo.org/about/>, <https://servo.org/>
- crates.io yayımı ve LTS planı / crates.io publication and LTS plan — <https://www.phoronix.com/news/Servo-Embed-Crates-LTS>

**Ladybird**

- Yol haritası ve finansman / roadmap and funding — <https://ladybird.org/>, <https://en.wikipedia.org/wiki/Ladybird_(web_browser)>

**UnifiedPush / Web Push**

- UnifiedPush belirtiminin RFC 8291 ve RFC 8292 (VAPID) uyumuna güncellenmesi / spec updated for RFC 8291 and RFC 8292 (VAPID) — <https://f-droid.org/2026/01/08/unifiedpush-5-years.html>
- KUnifiedPush ve Web Push — <https://www.volkerkrause.eu/2025/04/18/kde-kunifiedpush-webpush.html>
- UnifiedPush geliştirici belgeleri / developer docs — <https://unifiedpush.org/developers/intro/>

**Motor kullanım payları / Engine usage shares**

- 2026 derlemeleri / 2026 compilations — <https://www.digitalapplied.com/blog/browser-market-share-2026-complete-statistics>, <https://commandlinux.com/statistics/web-browser-market-share/> (StatCounter türevi; yöntem farkları nedeniyle oranlar değişir / StatCounter-derived; figures vary by methodology)
