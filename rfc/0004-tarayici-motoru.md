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

**En sert bulgu, baştan söylenmelidir.** Bu RFC hazırlanırken yapılan kaynak düzeyindeki inceleme, manifesto 6.6'nın yedi vaadinden ikisinin — **bildirim (sayfa kapalıyken) ve sistem paylaşımı** — WebKitGTK üzerinde bugün karşılanamadığını göstermiştir. Bunlar "henüz eklenmemiş" özellikler değildir: Web Push için WebKitGTK'da bir derleme seçeneği dahi yoktur, `navigator.share` GTK'da mevcut değildir, ve manifesto 18.2'de ayrıca vaat edilen WebAuthn de kapalıdır. Bu boşuklar üzerinde çalışan kimse yoktur.

Bu, önerinin değişmesini gerektirmez — çünkü tek alternatif olan Chromium'un bakım yükü, güvenlik gecikmesi ve telefondaki bellek maliyeti daha ağırdır. Ama **vaadin bugünkü hâliyle karşılanamadığının ilan edilmesini** gerektirir. Seçim, *"eksik ama sürdürülebilir bir motor"* ile *"tam ama sürdürülemez bir motor"* arasındadır; bu RFC birincisini seçer ve eksiği gizlemez.

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

Bu tablodaki "bağımsızlık" sütununun ne kadar ince olduğunu bir rakam gösterir: Mozilla'nın 2024 denetlenmiş mali tablolarına göre **sözleşme gelirinin %86'sı tek bir müşteriden** gelmektedir (2023'te %85). Yani "bağımsız motor" diye anılan Gecko, ticari olarak Blink'in sahibine bağlıdır. ABD'deki arama davasında verilen çare kararı, Google'ın varsayılan arama ödemelerine yasak getirmeyi reddetmiştir; karar temyizdedir ve Adalet Bakanlığı'nın karşı temyizi bu reddin bozulmasını istemektedir. Sonuç 2027'ye kadar belirsizdir.

Üç motorun üçü de tek bir şirketin ticari kararına bu ölçüde bağlıysa, OZERK'in "bağımsızlık" iddiası motor seçimiyle değil, ancak bu bağımlılığın dürüstçe ilan edilmesiyle savunulabilir.

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

- Mobil Linux'ta **gömülebilir** motorlar arasında en yerleşik olan budur. (Dikkat: bu, "mobil Linux'un varsayılan tarayıcısı Epiphany'dir" demek **değildir** — aşağıdaki tablo bu yaygın yanlışı düzeltir.)

  | Dağıtım / kabuk | Varsayılan tarayıcı | Motor |
  |---|---|---|
  | Mobian (Phosh) | `phosh-core` `epiphany-browser`'ı önerir | WebKitGTK |
  | postmarketOS (Phosh) | Meta paket hiçbir tarayıcı dayatmaz; proje wiki'si **masaüstü Firefox + `mobile-config-firefox`** yolunu belgeler | Gecko |
  | postmarketOS (Plasma Mobile) | Angelfish önerilir | QtWebEngine (Blink) |
  | Ubuntu Touch / Lomiri | morph-browser | QtWebEngine (Blink) |
  | Sailfish OS | Sailfish Browser | Gecko (EmbedLite çatalı) |

  Yani mobil Linux dünyası motor konusunda **bölünmüştür** ve WebKitGTK yalnızca bir seçenektir. OZERK'in bu tabloya bakarak öğrenmesi gereken şey, "herkes şunu kullanıyor" diye bir gerçek olmadığıdır.
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

Varsayılan tarayıcının hangisi olacağı bu RFC'de kararlaştırılmaz; taban dağıtım kararına (RFC-0002) ve E2 deneyine bağlıdır. Ancak bugünkü kanıtlar **Firefox'u en ucuz inandırıcı cevap** olarak öne çıkarmaktadır ve bu, katman (a)'nın motorundan farklı olması sakıncalı değil, aksine yararlıdır:

- Firefox 136'dan (Mart 2025) beri resmî aarch64 Linux yapıları yayımlanmaktadır; Linux/AArch64 birinci kademe (Tier-1) derleme hedefidir. Alpine (postmarketOS'un tabanı) aarch64 için paketlemektedir.
- Wayland, Firefox 121'den (Aralık 2023) beri varsayılandır; dokunmatik ve touchpad jestleri desteklenir.
- Mobil arayüz sorununu postmarketOS `mobile-config-firefox` ile çözmektedir (5.4.1, Temmuz 2026); yani bu iş zaten yapılmıştır ve OZERK'in yeniden yapmasına gerek yoktur.
- Web Push masaüstü Linux dahil çalışmaktadır — yani **katman (a)'da eksik olan vaat 5b, katman (b)'de mevcuttur.** Bu, iki katmanı ayırmanın somut bir faydasıdır: kullanıcı, push gerektiren bir hizmeti tarayıcıda kullanabilir.
- Bilinen zayıflık: Firefox'un adres çubuğu Linux'ta ekran klavyesini tetiklememektedir (hata 2017'den beri açık ve sahipsiz). Sayfa içi metin alanları çalışır. Bu, referans cihazda **ölçülmesi** gereken somut bir kullanılabilirlik sorunudur.

Bir tarayıcı paketlemek, motorunu sürdürmek değildir. Katman (b) için Firefox seçmek OZERK'i Mozilla'ya bağımlı kılmaz; kullanıcı başka bir tarayıcı kurabilir ve OZERK deposunda birden fazla tarayıcı bulunabilir.

#### K5 — Motor soyutlama sınırı

Katman (a)'nın geliştiriciye ve sisteme baktığı yüzey (manifest alanları, izin modeli, depolama sözleşmesi, yaşam döngüsü olayları) **motordan bağımsız** tanımlanır. Motora özgü hiçbir kavram bu yüzeye sızdırılmaz.

Amaç saflık değil, ölçülebilir çıkış maliyetidir: motoru değiştirmek gerekirse ekosistemin ne kadarının kırılacağı önceden bilinsin. Bu sınırın gerçekten çalıştığı, aynı runtime'ın ikinci bir backend ile koşturulmasıyla kanıtlanır (Bölüm 9, E6).

#### K6 — PWA boşlukları upstream'e katkı ile kapatılır

D3 (upstream-öncelikli strateji) gereği: eksik bir web platformu yeteneği tespit edildiğinde OZERK'in ilk yolu, yeteneği ilgili portun upstream'ine (WebKitGTK / WPE / Epiphany) katkı olarak göndermektir. Downstream yama taşımak geçici çözümdür ve gerekçesiyle birlikte kayda geçer.

Karşılanamayan boşluklar **gizlenmez**: hangi vaadin hangi cihazda karşılanmadığı Özgürlük Envanterinde ve geliştirici belgelerinde yazılır (manifesto 6.14, 24).

#### K7 — Web Push için süreli bir taahhüt ve adı konmuş bir yedek plan

Web Push, katman (a)'nın tek kritik boşluğudur ve dogmatik olmamak bunu gerektirir: bir tarih verilmeden "upstream'e katkı yapacağız" demek, manifesto 24'ün yasakladığı türden bir vaattir.

Bu nedenle:

1. Web Push + NotificationEvent'in WebKitGTK/WPE'ye kazandırılması, **fonlanmış ve sahibi belli bir iş kalemi** olarak tanımlanır (Bölüm 7, RFC-0008).
2. Bu iş **24 ay içinde upstream'de birleşmezse**, karar yeniden açılır. O noktada üç seçenek değerlendirilir: (i) push gerektiren sınıf D uygulamaları için QtWebEngine tabanlı ikinci bir runtime arka ucu, (ii) vaat 5'in manifesto tadili ile daraltılması, (iii) sürenin gerekçeli olarak uzatılması.
3. O tarihe kadar **vaat 5 karşılanmamış sayılır ve öyle ilan edilir.** Kısmi çözüm olarak, uygulama açıkken sistem bildirimi (Notifications API) desteklenir ve sınırı kullanıcıya açıkça anlatılır.

Yedek planın (i) şıkkının bu RFC'nin K5'iyle uyumlu olması tesadüf değildir: motor soyutlama sınırı tam da bunun için vardır.

---

### 3. Manifesto 6.6'nın yedi vaadi: motor bazlı durum tablosu

Manifesto 6.6, bir web uygulamasının şunları yapabileceğini söyler. Aşağıdaki tablo, her vaadin her motorda **17 Ağustos 2026 itibarıyla** durumunu gösterir.

Gösterim: **✅** destekleniyor · **◐** kısmi · **✕** yok · **?** doğrulanmalı

| # | Vaat (manifesto 6.6) | WebKitGTK 2.52 (+Epiphany) | Chromium (QtWebEngine / CEF) | Gecko (Firefox, Linux) | Servo | Ladybird |
|---|---|---|---|---|---|---|
| 1 | Ana ekrana kurulabilecek | ◐ **Epiphany yapar, motor yapmaz.** `ENABLE_APPLICATION_MANIFEST` GTK'da kapalıdır (yalnızca Cocoa'da açık); Epiphany manifesti kendi enjekte ettiği JS ile okur, manifest yoksa sayfayı "kazıyarak" (scraping) çalışır | ✅ Angelfish (Plasma Mobile) PWA kurulumunu destekler; Chromium `--app` modu | ◐ **Geri geldi:** "Web Apps" (kaynak kodunda Taskbar Tabs) Windows'ta Firefox 143'te (Eylül 2025) varsayılan açık, **Linux'ta Firefox 150'de (Nisan 2026) geldi ama varsayılan kapalı** (`browser.taskbarTabs.enabled`). `.desktop` dosyası üretir, Flatpak/Snap destekler. Mozilla'nın kendi belgesi: "tasarım gereği hâlâ tarayıcı gibi görünür, çoğu PWA uygulamasındaki gibi tamamen ayrı bir uygulama gibi değil" | ✕ | ✕ |
| 2 | Bağımsız uygulama penceresinde çalışabilecek | ✅ | ✅ | ◐ Taskbar Tabs penceresi tam bağımsız değildir (bkz. yukarısı) | ✕ | ✕ |
| 3 | Kendi depolama alanına sahip olacak | ✅ `WebKitNetworkSession` ile ayrı profil/cache dizini; Epiphany her web uygulamasına `<veri-dizini>/<uygulama-kimliği>` verir. IndexedDB, DOM Cache, Service Worker kayıtları ayrı silinebilir. *(Kota belirleme API'si yok.)* | ✅ ayrı profil dizini ile | ◐ profil ayrımı elle yapılır | ◐ `SiteDataManager` gömme API'sinde var; IndexedDB kapalı | ✕ |
| 4 | Çevrimdışı çalışabilecek | ✅ Service Worker WebKitGTK 2.28.0'dan (Mart 2020) beri varsayılan açık; Cache API, IndexedDB mevcut | ✅ | ✅ motor düzeyinde | ✕ **Service Worker varsayılan kapalı ve eksik** (`dom_serviceworker_enabled` bayrağı arkasında). IndexedDB de varsayılan kapalı. Çevrimdışı web uygulaması bugün çalışmaz | ✕ |
| 5a | Bildirim alabilecek — **sayfa açıkken** (Notifications API) | ◐ `WebKitWebView::show-notification` sinyali 2.8'den beri var; ancak GTK yapılarında **varsayılan bildirim sunucusu yoktur** — bildirimi gömen uygulama çizer. Bildirim, sayfa gezinildiğinde veya kapandığında iptal edilir | ✅ | ✅ | ✕ Notification API varsayılan kapalı | ✕ |
| 5b | Bildirim alabilecek — **sayfa/uygulama kapalıyken** (Web Push, RFC 8030/8291/8292) | ✕ **Desteklenmiyor; derleme seçeneği bile yok.** `ENABLE_WEB_PUSH` diye bir CMake seçeneği mevcut değildir; `ENABLE_WEB_PUSH_NOTIFICATIONS` yalnızca macOS/iOS'ta 1'dir; `PushAPIEnabled` tüm portlarda `false`. WebKit'in `webpushd` bileşeni tamamen Objective-C++ ve APNs'e bağlıdır — Linux portu yoktur. Ayrıca `ENABLE_NOTIFICATION_EVENT` = 0 olduğundan **service worker hiç bildirim olayı alamaz** | **?** QtWebEngine'de Push API'nin etkin olup olmadığı doğrulanmalı; ham Chromium'da destekleniyor ama varsayılan uç nokta Google altyapısıdır | ✅ Firefox Web Push'u destekler; IronFox/Fennec çatallarında UnifiedPush'a yönlendirilebildiği belgelenmiştir | ✕ | ✕ |
| 6 | Sistem paylaşım arayüzüne katılabilecek (Web Share API) | ✕ **Desteklenmiyor.** `WebShareEnabled` yalnızca Cocoa'da `true`; `navigator.share` GTK'da mevcut değildir. `ENABLE_WEB_SHARE` diye bir seçenek yoktur; portal bağlaması da yoktur | **?** Linux'ta `navigator.share` desteğinin durumu doğrulanmalı | **?** | ✕ | ✕ |
| 7 | Kullanıcı izinleriyle kamera, mikrofon ve konuma erişebilecek | ◐ Kamera/mikrofon (`getUserMedia`) ✅ — WebKitGTK 2.50'den beri XDG Desktop Portal (`org.freedesktop.portal.Camera` + PipeWire) üzerinden, sandbox istisnası gerekmeden. Ekran paylaşımı ScreenCast portalı üzerinden ✅. Konum ✅ ama portal değil, **GeoClue2** D-Bus üzerinden. ⚠️ **`ENABLE_WEB_RTC` deneysel özelliklere bağlıdır; kararlı yapılarda `RTCPeerConnection` kapalıdır** — görüntülü görüşme web uygulaması çalışmaz | ✅ (portal entegrasyonunun kalitesi **?**) | ✅ | ✕ | ✕ |
| + | *(6.6'da yok, ama çevrimdışı vaadinin pratik tamamlayıcısı)* Background Sync / Periodic Background Sync | ✕ **İlkesel olarak reddedilmiş.** Periodic Background Sync hatası WONTFIX kapatıldı (gerekçe: gizlilik, botnet ve pil riski); Background Sync hatası 2019'dan beri dokunulmamış durumda | ✅ Chromium destekliyor | ✕ **Mozilla da ilkesel olarak reddetmiştir** (standards-positions: negatif; gerekçe kalıcı IP izleme ve botnet riski) | ✕ | ✕ |
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
6. **Background Sync bir "WebKit eksiği" değildir; Chromium'a özgü bir özelliktir.** Hem Apple hem Mozilla bu API'yi ilkesel gerekçelerle (kalıcı IP izleme, botnet riski, pil) reddetmiştir. OZERK'in bu API'yi vaat etmemesi bir eksiklik değil, iki bağımsız motor sağlayıcısıyla aynı gizlilik pozisyonunda durmaktır. Bunun bedeli, yalnızca Chromium'da test edilmiş web uygulamalarının OZERK'te eksik çalışmasıdır — ve bu bedel kullanıcıya açıkça söylenmelidir.
7. **Servo ve Ladybird sütunları pratikte boştur.** Bu, seçimin bugün iki at arasında olduğu anlamına gelir: WebKitGTK/WPE ya da bir Chromium portu. Diğer üç sütun bilgi amaçlıdır, seçenek değildir.

**Bir fırsat.** UnifiedPush belirtimi, şifreleme (RFC 8291) ve VAPID yetkilendirmesi (RFC 8292) gerektirecek biçimde güncellenmiştir; yani UnifiedPush uçları artık açıkça Web Push uçlarıdır. Bu, OZERK Push (RFC-0007) ile katman (a)'nın Web Push desteğinin **aynı altyapıyı paylaşabileceği** anlamına gelir: eksik olan taşıma katmanı değil, motor içindeki Push API ve NotificationEvent uygulamasıdır. Apple'ın `webpushd`'si APNs'e bağlı olduğu için doğrudan kullanılamaz; ancak WebKit'in Push API iskeleti mevcuttur ve GTK/WPE için bir arka uç yazılabilir. Aynı yolun Gecko tarafında işlediği, Firefox çatallarına (IronFox/Fennec) UnifiedPush üzerinden web push eklenmesiyle gösterilmiştir. Bu, K6 kapsamındaki katkının en somut ve en yüksek değerli hedefidir.

---

### 4. Seçeneklerin değerlendirilmesi

Her seçenek şu ölçütlerle değerlendirilmiştir: mobil Linux'ta bugünkü durum · PWA/Service Worker/Web Push/background sync kapsamı · güvenlik yaması temposu ve bakım yükü · gömme (embedding) API kalitesi · Wayland/dokunmatik uyumu · bellek ayak izi · lisans uyumu.

#### Seçenek 1 — WebKitGTK / WPE WebKit

| Ölçüt | Durum |
|---|---|
| Mobil Linux'ta bugünkü durum | **Gömülebilir motorlar arasında en yerleşik yol**, ama tekel değil: Mobian Phosh Epiphany'yi önerir, postmarketOS Firefox belgeler, Plasma Mobile ve Ubuntu Touch QtWebEngine kullanır (K3'teki tablo). Aktif geliştirme sürüyor: WebKitGTK 2.52.5 (9 Temmuz 2026), geliştirme dalı 2.53.90 (7 Ağustos 2026), Epiphany 50.6 (13 Ağustos 2026). |
| PWA kapsamı | **En dar — ve eksikler üzerinde çalışan kimse yok.** Var: Service Worker (2.28.0'dan beri), ayrı depolama oturumu, IndexedDB/Cache API, portal üzerinden kamera/ekran paylaşımı, GeoClue2 üzerinden konum, bubblewrap sandbox. Yok: Web Push (derleme seçeneği bile yok), service worker bildirimleri (`ENABLE_NOTIFICATION_EVENT` = 0), Web App Manifest API, Web Share, WebAuthn, Background Sync, site isolation. Kararlı yapılarda WebRTC de kapalı. |
| Güvenlik temposu | **Ölçülmüş ve genel olarak iyi, ama garantisiz.** Danışmanlık sayısı: 2023'te 12, 2024'te 8, 2025'te 10, 2026'da Temmuz'a kadar 4. WebKitGTK, Apple'ın CVE numaralarını ve metnini birebir kullanır; kapsam her zaman Apple'ın alt kümesidir. 2026'da ölçülen gecikmeler: WSA-2026-0002 **4 gün**, WSA-2026-0004 **11 gün**, WSA-2026-0003 **20 gün**. Vahşi doğada sömürülen bir açıkta (WSA-2025-0010) gecikme **5 gün** olmuştur. ⚠️ **Ancak bu belgenin yazıldığı gün açık bir boşluk vardır:** Safari 26.6, 27 Temmuz 2026'da 10 CVE ile yayımlanmıştır; 17 Ağustos 2026 itibarıyla bunları kapsayan bir WebKitGTK danışmanlığı yoktur — **21 gün ve sayıyor.** Yani Bölüm 6'daki 7 günlük medyan eşiği bugünkü upstream davranışıyla her zaman karşılanmamaktadır. |
| Bakım yükü | Motor bakımı upstream'de (Igalia). OZERK'in yükü: paketleme, runtime entegrasyonu, PWA boşluklarına katkı. Chromium'a göre kat kat düşük. |
| Gömme API kalitesi | WebKitGTK için olgun GObject API; üç API sürümü paralel destekleniyor (webkitgtk-6.0 / webkit2gtk-4.1 / webkit2gtk-4.0). WPE WebKit gömme için özel tasarlanmıştır; WPEPlatform 2.52'de mevcut, 2.54'te varsayılan olması bekleniyor. **Bilinen zayıflık:** dağıtımlar arası API sürümü parçalanması, Tauri gibi WebKitGTK'ya dayanan projelerde belgelenmiş bir sorundur. |
| Wayland / dokunmatik | Wayland yolu birinci sınıftır (WPE zaten "WebKit for Wayland" olarak doğdu) ve olgunlaşmıştır. Dokunmatik 2.52'de belirgin biçimde iyileşti: dokunma girdisi için Pointer Events etkinleştirildi, dokunmadan türetilen fare olaylarının davranışı düzeltildi, Pointer/Touch Events kesirli koordinat kullanmaya başladı. Ekran klavyesi entegrasyonu ve jest kalitesi referans cihazda **ölçülmelidir**. |
| Bellek ayak izi | Chromium'a göre belirgin biçimde düşük olduğu yaygın kabuldür; ancak elimizdeki kaynaklar anekdot düzeyindedir. **Bağımsız ölçüm gerekli** (E3). |
| Lisans | LGPL-2.1 / BSD karışımı; D1 ile uyumlu. |

#### Seçenek 2 — Chromium tabanlı gömme (CEF, QtWebEngine veya doğrudan)

Bu tek bir seçenek değil, maliyet profilleri çok farklı **üç** seçenektir: (2a) Chromium'u kendin paketlemek, (2b) CEF, (2c) QtWebEngine.

| Ölçüt | Durum |
|---|---|
| Mobil Linux'ta bugünkü durum | **Teorik değil, fiilen baskın.** Ubuntu Touch'ın morph-browser'ı ve postmarketOS Plasma Mobile'ın Angelfish'i QtWebEngine (Blink) üzerine kuruludur. Yani OZERK'e en yakın iki proje bu yolu seçmiştir — motoru kendileri sürdürmemek karşılığında gecikmeyi kabul ederek. |
| PWA kapsamı | **En geniş.** Yedi vaadin tamamı, Web Push, Web Share, WebAuthn ve Background Sync dahil Chromium'da mevcuttur. Bunların QtWebEngine/CEF'te etkin olup olmadığı ayrı bir sorudur — **doğrulanmalı** (E2). |
| Güvenlik temposu — (2a) kendi paketleme | Bugün 4 haftalık sürüm döngüsü ve ortalama 6 günde bir güvenlik tazelemesi. ⚠️ **8 Eylül 2026'da, Chrome 153 ile döngü iki haftaya iniyor.** Yani çeyrek başına yeniden derleme olayı ~13'ten ~26'ya çıkacaktır. Google'ın gömücülere tavsiyesi açıktır: "en son kararlı sürümü takip etmek, uzun vadede geriye yama taşımaktan daha az iştir." Tek gerçek rahatlama valfi, gömücüler için sürdürülen **extended-stable** dalıdır (8 haftalık kilometre taşı, iki haftada bir güvenlik) — ancak Chromium'un kendi belgesi uyarır: "site isolation gibi daha büyük güvenlik iyileştirmeleri geriye taşınamayabilir." |
| Güvenlik temposu — (2c) QtWebEngine | **Gecikme ölçülmüştür ve büyüktür.** Qt 6.11.1'in Chromium tabanı 140'tır, güvenlik yamaları 148.0.7778.96 (5 Mayıs 2026) düzeyine kadar getirilmiştir — üstelik upstream kararlı sürüm 11 Ağustos 2026'da 151.0.7922.137 idi. Yani ~3,5 aylık güvenlik gecikmesi ve 11 kilometre taşı motor gecikmesi. Qt 6.8.8 LTS daha da geridedir (taban 134, 17 kilometre taşı). Dikkat çekici tersine dönme: **6.8.8 LTS'in güvenlik düzeyi (27 Mayıs 2026) en yeni Qt'ninkinden (5 Mayıs 2026) daha yenidir** — "en yeni Qt" ile "en yamalı Qt" aynı şey değildir. |
| Bakım yükü | (2a) **taşınamaz:** ~30 GB git önbelleği, en az 100 GB disk, 16+ GB RAM önerisi; ungoogled-chromium'un tam derlemesi CI'da 24 saatten uzun sürüyor ve proje ARM64 Linux ikili dosyası yayımlamıyor — o derleme OZERK'in olurdu. (2b) CEF hazır `linuxarm64` ikili dosyaları yayımlıyor (kararlı: CEF 151.3.18 / Chromium 151.0.7922.138) ve her altıncı dalda ~8 ay ek destekli LTS sunuyor; bu, derleme çiftliği sorununu doğrudan çözer. (2c) QtWebEngine'de yükü Qt taşır. |
| Gömme API kalitesi | CEF olgun ve yaygındır. ⚠️ **Ama üç uyarı:** son bir yılda CEF taahhütlerinin **%84,5'i tek kişiden** gelmiştir (otobüs faktörü 1); belgeler ARM64'ü de Wayland'i de hiçbir yerde anmaz — ARM64 ikilileri fiilen vardır ama taahhüt edilmemiştir; ve **Wayland ana penceresine gömme sorunu 2019'dan beri açıktır** (topluluk yaması Ağustos 2026'da gösterildi, Chromium tarafında da yama gerekiyor). Ayrıca CEF'in iki haftalık döngüye nasıl uyum sağlayacağına dair açılan konu Mart 2026'dan beri **tek yorum almamıştır.** |
| Wayland / dokunmatik | Masaüstü Wayland çözülmüştür: `--ozone-platform-hint=auto` Chrome 140'tan (Ağustos 2025) beri varsayılan, `text-input-v3` 138'den beri açık, touchpad jestleri destekleniyor. ⚠️ Açık hatalar tam da **mobil** tarafta yoğunlaşır: Chromium'un text-input protokol sırasını ihlal etmesi nedeniyle ekran klavyesi açılmayabiliyor; squeekboard tam ekran Chromium'un üstünde görünmüyor. Telefon biçim faktöründe dokunmatik kalitesi için birincil kanıt bulunamadı — **ölçülmeli.** |
| Bellek ayak izi | En yüksek — **ve bu, Bölüm 6'daki en kritik bulguyu doğurur.** Chromium'un düşük bellek kaçış kapıları yalnızca `IS_ANDROID` derlemelerinde çalışır; masaüstü Linux hedefiyle derlenmiş bir Chromium ARM64 telefonda bu kapılara sahip değildir. Ayrıntı Bölüm 6'da. |
| Lisans | Çekirdek BSD-3-Clause ve **GPL-3 ile çatışmaz**; Debian arm64 chromium'u `main`'de dağıtıyor. Özgür olmayan kodekler bir derleme bayrağıdır (`proprietary_codecs`, markasız derlemelerde kapalı) — bunun bedeli markasız yapılarda **H.264 ve AAC olmamasıdır**, ki bu web uyumluluğunda gerçek bir kayıptır. AV1/VP9 telifsizdir. H.264 lisansı yılda 100 bin birime kadar ücretsizdir. ⚠️ **Widevine dağıtılamaz:** lisansı "Commercial"dır, ikili dosya depoda yoktur ve erişim Widevine Ana Lisans Sözleşmesi imzalamayı gerektirir — OZERK'in bunu alıp alamayacağı bilinmiyor. Yani DRM'li video hizmetleri (sınıf D uygulamaları arasında yaygın) çalışmayabilir; bu Chromium'a özgü değil, tüm seçeneklerde geçerli bir sınırdır ve manifesto 24 gereği ilan edilmelidir. |
| Bağımsızlık | Manifesto 1 açısından **en kötü seçenek**: Blink'in yönü Google tarafından belirlenir ve kullanım payı ~%78'dir. OZERK'in bu motoru seçmesi, "tek bir şirkete bağımlı olmama" iddiasını en zayıf noktasından vurur. Ayrıca portabilite uyarısı: postmarketOS'un paket tanımında `# riscv64 blocked by qt6-qtwebengine` notu vardır — QtWebEngine bütün bir mimariyi engelleyebilmektedir. |

#### Seçenek 3 — Gecko / GeckoView

| Ölçüt | Durum |
|---|---|
| Mobil Linux'ta bugünkü durum | **Beklenenden çok daha iyi.** Firefox 136'dan (Mart 2025) beri resmî aarch64 Linux tarball'ları yayımlanıyor; Linux/AArch64 birinci kademe derleme hedefi. Alpine aarch64 için paketliyor. postmarketOS wiki'si masaüstü Firefox'u Phosh ve Plasma Mobile'da varsayılan olarak belgeliyor; mobil arayüzü `mobile-config-firefox` (5.4.1, Temmuz 2026) sağlıyor. Wayland, Firefox 121'den beri varsayılan. ⚠️ Bilinen kusur: adres çubuğu Linux'ta ekran klavyesini tetiklemiyor (hata 2017'den beri açık, sahipsiz); sayfa içi metin alanları `zwp_text_input_v3` üzerinden çalışıyor. |
| PWA kapsamı | Web Push ✅ masaüstü Linux dahil çalışıyor (UnifiedPush'a yönlendirilebildiği Firefox çatallarında gösterilmiştir). Kurulabilir web uygulaması: **kısmen geri geldi** — "Web Apps" Linux'ta Firefox 150'de (Nisan 2026) geldi ama varsayılan kapalı ve Mozilla'nın kendi belgesi bunun "tam ayrı bir uygulama gibi değil, hâlâ tarayıcı gibi" göründüğünü söylüyor. Background Sync ilkesel olarak reddedilmiş. |
| Gömme API kalitesi | **Bu seçeneğin belirleyici zayıflığı.** Mozilla genel amaçlı gömme API'sini 2011'de bıraktı; mozilla-central'da üst düzey `embedding/` dizini yoktur; ilgili tartışma listesi 2015'ten beri ölüdür. GeckoView yalnızca **Android AAR** olarak yayımlanır; mozilla-central'da `mobile/linux` diye bir hedef yoktur. |
| Tek gerçek gömme yolu ve maliyeti | Sailfish OS'un **EmbedLite** çatalı yaşıyor (son itmeler Ağustos 2026) — ama fiyatı ölçülmüştür: taban sürüm Gecko **115.37.0**, üstünde 89 downstream yama; ESR140 portu hâlâ sürüyor. Tek bir ESR sıçraması (ESR78→ESR91) yaklaşık **23 hafta tam zamanlı kodlama + 11 hafta belgeleme** aldı ve ESR102 tümüyle atlandı. Bu, forkun neden reddedildiğinin (K1) rakamla gösterilmiş hâlidir. |
| Güvenlik temposu | Mozilla'nın yama temposu iyidir; ancak paketleme Firefox uygulaması düzeyindedir, gömülebilir kütüphane düzeyinde değildir. EmbedLite yolunda güvenlik, dört ESR nesli geriden gelir. |
| Bakım yükü | Desteklenen bir gömme yolu olmadığı için katman (a) bu motorla kurulamaz. Katman (b) için ise **en düşük yük**: Mozilla'nın resmî aarch64 yapısı paketlenir. |
| Bellek ayak izi | Chromium ile WebKitGTK arasında; **ölçülmeli.** |
| Lisans | MPL-2.0; D1 ile uyumlu. |
| Bağımsızlık | Görünürde en "bağımsız" motor; ancak **2024'te sözleşme gelirinin %86'sı tek bir müşteriden** gelmiştir. Arama davasında ödeme yasağı reddedilmiş, karar temyize gitmiş, Adalet Bakanlığı karşı temyizi bu reddin bozulmasını istemektedir; sözlü duruşma 2026 sonu / 2027 başı beklenmektedir. Yani Gecko'nun mali geleceği bugün açık bir soru işaretidir. |

**Sonuç:** Gecko, katman (b) için **en güçlü aday**dır (bkz. K4). Katman (a) için, desteklenen bir gömme yolu olmadığı sürece uygun değildir — ve EmbedLite'ın ölçülmüş maliyeti, bu yola girmenin K1'i fiilen ihlal edeceğini göstermektedir.

#### Seçenek 4 — Servo

| Ölçüt | Durum |
|---|---|
| Bugünkü durum | **Üretim için hazır değil, ama yön doğru ve hız gerçek.** `servo` crate'i 0.1.0 ile 13 Nisan 2026'da crates.io'ya girdi; 16 Temmuz 2026'da 0.4.0'a ulaştı. Aylık özellik sürümü + altı ayda bir LTS dalı (9 ay destek) uygulanıyor ve LTS gerçekten yama alıyor (0.1.2, Mozilla'nın SpiderMonkey güvenlik bültenlerinden geri taşıma yaptı). |
| Gömme API kalitesi | `ServoBuilder`/`WebViewBuilder`, çoklu webview, `OffscreenRenderingContext`, `SiteDataManager`, `NetworkManager` mevcut. ⚠️ Kendi belgeleri: "Servo'nun nasıl gömüleceğine dair belgeler **yetersizdir**." Kırıcı API değişiklikleri aylık iniyor. ⚠️ Referans gömücü olan **Verso projesi öldü** (Ekim 2025'te arşivlendi; gerekçe: "sınırlı insan gücü ve fon"), geriye yalnızca `servoshell` kaldı. |
| Web platformu kapsamı | WPT: 2025 boyunca skor %48,2 → %61,6, alt testler %69,9 → %93,4 (Servo'nun kendi ölçümü; tüm testler koşturulmuyor). ⚠️ **Karar için belirleyici olan:** Service Worker **varsayılan kapalı ve kısmi**. IndexedDB, Notification, Permissions, Storage, Geolocation, WebRTC, WebGL2 de varsayılan kapalı. Yani çevrimdışı PWA bugün Servo'da çalışmaz. |
| Güvenlik duruşu | ⚠️ **En zayıf yanı.** Varsayılan olarak **tek süreçli** çalışır (`--multiprocess` isteğe bağlı). Sandbox (`gaol`) belgede gelecek zamanla anlatılır. SECURITY.md tek cümledir; yayımlanmış **sıfır** güvenlik danışmanlığı vardır. Bağımsız denetim (NLnet fonlu) yapılmıştır ama kapsamı dardı (CSS float/tablo ve Stylo). Kendi indirme sayfaları der ki: *"Lütfen henüz Servo ile bankanıza girmeyin."* LTS belgesi de açıktır: *"güvenlik garantileri dahil hiçbir garanti verilmez... LTS sürümleri ilgili topluluk üyeleri tarafından en iyi çaba esasıyla sağlanır."* |
| Yönetişim ve fon | Linux Foundation Europe projesi. Igalia fiilî bakımcıdır (2025 taahhütlerinin %27,34'ü). Sovereign Tech Fund, Igalia'ya "masaüstü ve mobil için **kararlı bir WebView gömme API'sini tamamlamak**" dahil ~12 aylık bir hibe verdi (Ekim 2025) — bu doğrudan OZERK'in ihtiyacına denk düşer. ⚠️ Buna karşılık topluluk fonu çok küçüktür: Open Collective'de yıllık ~88 bin dolar, aylık ~7,7 bin dolar düzenli bağış. Servo'nun kendi ölçüsüyle (aylık 10 bin dolar ≈ 1 tam zamanlı geliştirici) bu, **bir tam zamanlı mühendisin altındadır**; yönetim kurulunda ücretli sponsor yoktur. |
| ARM64 / mobil | **Telefonu gerçekten hedefleyen tek aday.** Resmî `servo-aarch64-linux-gnu` gecelik yapısı var; OpenHarmony aarch64 birinci sınıf platform ve gömme belgelerinde **referans uygulama** olarak anılıyor. ⚠️ Ancak aarch64 CI **yok** (tüm WPT koşuları x86-64) ve Wayland destek düzeyi belgesiz; PinePhone Pro / Mobian üzerinde isabet testi (hit-testing) kayması hatası açık — tam olarak OZERK'in donanım sınıfı. |
| Bağımsızlık | Üç motorun hiçbirine bağlı olmayan gerçek bir dördüncü yol adayı. Uzun vadede OZERK'in çıkarına en uygun seçenek budur. |

**Sonuç:** Bugün seçilemez — Service Worker'ın kapalı olması tek başına 6.6'nın dördüncü vaadini imkânsız kılar. Ama **en yakından izlenecek adaydır** ve iki nedenle: Sovereign Tech Fund parası tam da eksik olan gömme API'sine gidiyor, ve Servo telefonu ciddiye alan tek proje. Somut bir işaret: **Kumo**, tam da OZERK'in hedeflediği donanım sınıfına yönelik bir Wayland mobil Linux tarayıcısıdır ve **birincil motor olarak WebKit, isteğe bağlı olarak Servo** kullanır (1.7.0, Nisan 2026) — yani bu RFC'nin önerdiği yolun bir başkası tarafından bağımsızca bulunmuş hâlidir.

#### Seçenek 5 — Ladybird

| Ölçüt | Durum |
|---|---|
| Bugünkü durum | **Alfa henüz çıkmadı** (17 Ağustos 2026). Yayımlanmış hiçbir sürüm yok; indirme sayfası 404. Kendi README'si: *"Ladybird alfa öncesi durumdadır ve yalnızca geliştiricilerin kullanımına uygundur."* Yol haritası: 2026 alfa, 2027 beta (indirilebilir uygulama), **2028 kararlı sürüm**. |
| Bağımsızlık | **En güçlü yanı.** Hiçbir mevcut motorun forku değil; sıfırdan yazılıyor. 501(c)(3) kâr amacı gütmeyen bir kuruluş tarafından, bağış ve sponsorluklarla finanse ediliyor (Platin: FUTO, Shopify, Cloudflare; Altın: Human Rights Foundation, Proton VPN; kurucu ortak Chris Wanstrath'ın ailesi 1 milyon dolar taahhüt etti). Her zaman 18 aylık nakit yolu tutulduğu belirtiliyor. Ekip büyüklüğü ve bütçe yayımlanmamıştır ("finansallar yakında"). |
| Gömme API'si | ✕ **Yok — ve yapma niyeti de beyan edilmemiş.** Belgelerdeki `Porting.md` bir *arayüz portu* eklemeyi anlatır (`WebView::ViewImplementation` türetmek), gömmeyi değil. ⚠️ Yön daralma yönündedir: **GTK portu Temmuz 2026'da silinmiştir** ("The Gtk port is gone"), çabalar Qt portunda toplanıyor. |
| Katkı kanalı | ⚠️ **5 Haziran 2026'da tüm kamuya açık pull request'ler durduruldu** ve o an açık olanlar kapatıldı. Alternatif bir kanal da yok: "Başka yollarla yama göndermek için ayrı bir süreç olmayacaktır." Gerekçe savunulabilirdir (yapay zekâ, büyük bir yamanın anlayış ve sorumluluk taşıdığı varsayımını yok etti; tarayıcı tüm internetten güvenilmeyen girdi çalıştırır). **OZERK açısından sonucu nettir: bir mobil port upstream'e gönderilemez.** Geriye kalıcı ağaç-dışı taşıma ya da sert fork kalır; ikisi de K1 ile çelişir. |
| Güvenlik duruşu | Beklenenden iyi ama yeterli değil. Çok süreçli mimari var (UI + sekme başına WebContent + ImageDecoder + RequestServer) ve **Haziran 2026'da gerçek sandbox indi** (Linux'ta seccomp/Landlock, macOS'ta Seatbelt, varsayılan açık); Temmuz'da profil başına sandbox kuralları eklendi. ⚠️ Ama kendi SECURITY.md'si açıktır: *"web platformunun birçok güvenlik özelliği Ladybird'de henüz uygulanmamıştır"* — CSP, XSS ve çapraz köken sandbox'ı kapsam dışı sayılıyor. Ödül programı yok. |
| ARM64 / mobil Linux | ✕ ARM64 Linux yalnızca bir *sanitizer* CI işi olarak var; **release işi yok**. Kendi ifadeleri: *"Mobil platformlar şu an odağımızda değil."* Android CI'ı x86_64 öykünücüde koşuyor. |

**Sonuç:** Bugün seçilemez ve **yakın gelecekte de seçilemeyecektir.** Üç sert engel vardır: gömme API'si yok ve gelmiyor; dışarıdan katkı kabul edilmiyor, dolayısıyla mobil port yukarı akışa gönderilemez; ve 2027'den önce kullanılabilir bir şey çıkmıyor. Ladybird OZERK'in uzun vadeli çıkarlarıyla en fazla örtüşen projedir ve **izlenmeye ve desteklenmeye değerdir** — ama üzerine bahis oynanamaz. Yeniden değerlendirme koşulu: alfa çıktığında ve bir gömme API'si duyurulursa.

#### Karşılaştırma özeti

| | WebKitGTK/WPE | Chromium (CEF/QtWebEngine) | Gecko | Servo | Ladybird |
|---|---|---|---|---|---|
| Katman (a) için bugün uygun mu? | **Evet — ama vaat 5 ve 6 eksik** | Evet — ama güvenlik ve bellek bedeliyle | ✕ gömme yolu yok | ✕ Service Worker kapalı | ✕ gömme API'si yok |
| Katman (b) için bugün uygun mu? | Evet | Evet | **Evet — en ucuz** | ✕ | ✕ |
| PWA kapsamı | Dar (temel var, etkileşim yok) | **Tam** | Orta (push var, kurulum yarım) | Çok dar | Çok dar |
| OZERK'in bakım yükü | Düşük | Çok yüksek (Eylül 2026'dan sonra iki katı) | Katman (b) için çok düşük | Bilinmiyor | Uygulanamaz |
| Ölçülmüş güvenlik gecikmesi | 4–20 gün (bir açık boşluk: 21 gün) | QtWebEngine ~3,5 ay; kendi paketlemede sürekli | Upstream ile aynı | Danışmanlık süreci yok | Ödül yok, birçok koruma eksik |
| Tek şirkete bağımlılık | Orta (Apple + Igalia) | **Yüksek (Google)** | **Yüksek** (gelirinin %86'sı tek müşteri) | Düşük | **En düşük** |
| Bellek | Düşük | Yüksek (telefonda site isolation kaçış kapısı yok) | Orta | Bilinmiyor | Bilinmiyor |
| Katkı kabul ediyor mu? | Evet (upstream-öncelikli yol açık) | Evet | Evet | Evet | **Hayır** |

**Tablodan çıkan tek cümlelik sonuç:** seçim, *"eksik ama sürdürülebilir bir motor"* ile *"tam ama sürdürülemez bir motor"* arasındadır. Bu RFC birincisini önerir ve eksiği gizlemek yerine ilan etmeyi, kapatmak için fon aramayı ve kapatılamazsa vaadi daraltmayı önerir.

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

Bu RFC yazılırken upstream tarafı kısmen ölçülmüştür (dağıtım tarafı hâlâ ölçülmemiştir — E4). Bulgular:

| WebKitGTK danışmanlığı | Tarih | Upstream'den gecikme |
|---|---|---|
| WSA-2026-0002 | 28 Mart 2026 | **4 gün** |
| WSA-2026-0004 | 10 Temmuz 2026 | **11 gün** |
| WSA-2026-0003 | 2 Haziran 2026 | **20 gün** |
| WSA-2026-0001 | 18 Mart 2026 | 35–310 gün (birikmiş toplu yakalama) |
| WSA-2025-0010 (vahşi doğada sömürülen) | 17 Aralık 2025 | **5 gün** |

Yani upstream tarafı genelde 4–20 gün bandındadır ve aktif sömürülen bir açıkta 5 güne inebilmektedir. **Ancak bu belgenin yazıldığı gün açık bir boşluk vardır:** Safari 26.6, 27 Temmuz 2026'da 10 CVE ile yayımlanmıştır; 17 Ağustos 2026 itibarıyla bunları kapsayan bir WebKitGTK danışmanlığı yayımlanmamıştır — **21 gün ve sayıyor.** Bu, aşağıdaki eşiklerin dilek değil, gerçekten test edilmesi gereken sayılar olduğunu gösterir.

Diğer bulgular:

- Danışmanlık hacmi: 2023'te 12, 2024'te 8, 2025'te 10, 2026'da Temmuz'a kadar 4.
- WebKitGTK, Apple'ın CVE numaralarını ve metnini birebir kullanır ve kapsamı her zaman Apple'ın **alt kümesidir**. Yani WebKitGTK'ya özgü bir açığın Apple tarafında karşılığı yoksa, ayrı bir yol izlenmesi gerekir.
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

Bugünkü durum — ve burada bu RFC'nin en beklenmedik bulgusu vardır:

**Chromium'da** site isolation olgun ve varsayılan açıktır. Düşük bellekli cihazlar için kaçış kapıları da vardır: kısmi izolasyon eşiği **1900 MB**, sıkı izolasyon eşiği **3200 MB** (kaynak koddaki gerekçe: "yaklaşık 2 GB+ ve 4 GB+ cihazlara karşılık gelir"). Süreç başına varsayılan bellek varsayımı **85 MB**'dir (64 bit) ve renderer üst sınırı `(toplam RAM MiB / 2) / 85` formülüyle hesaplanır.

⚠️ **Ancak bu eşiklerin tamamı `#if BUILDFLAG(IS_ANDROID)` bloğunun içindedir. Masaüstü için varsayılan bellek eşiği yoktur.** Bir ARM64 telefonda `target_os = "linux"` ile derlenmiş bir Chromium `IS_ANDROID` değildir — dolayısıyla aynı donanımda Chrome-for-Android'in uyguladığı hiçbir rahatlamaya sahip olmaz ve **koşulsuz olarak site-başına-süreç** çalışır. 3 GB'lık bir telefonda renderer üst sınırı ~17 süreç olur.

Bu, "Chromium daha çok bellek kullanır" cümlesinden farklı ve daha keskin bir sorundur: mobil Linux'ta Chromium, telefon olduğunu bilmez. OZERK'in üç seçeneği olur — kabul etmek, Android semantiğini benimseyen bir yama taşımak (yani downstream fork yükü), ya da site isolation'ı kapatmak (yani Spectre savunmasından vazgeçmek). Üçü de bedellidir ve üçü de ilan edilmelidir.

**WebKit'te** site isolation daha yenidir ve **WebKitGTK'da bugün yoktur**: `SiteIsolationEnabled` tercihi tüm portlarda "unstable" ve varsayılan `false`'tur, ve GTK sürüm notlarında hiç anılmamıştır. Yani WebKitGTK seçilirse, site isolation bir maliyet değil, **bulunmayan bir özelliktir**. Bunun karşılığında bubblewrap sandbox'ı yeni GTK4 API'sinde kapatılamaz biçimde açıktır — daha zayıf ama sıfır olmayan bir savunma.

OZERK'in pozisyonu şu olmalıdır:

1. Site isolation'ın referans cihazdaki bellek maliyeti **ölçülür** (E3), tahmin edilmez.
2. Bellek nedeniyle site isolation kapatılıyorsa, bu **kullanıcıya açıkça bildirilir** ve Özgürlük Envanterine yazılır. Sessizce kapatmak manifesto 24'ün ihlalidir.
3. Katman (a) ve katman (b) farklı politikalara sahip olabilir: az sayıda güvenilen web uygulamasının izole edilmesi, rastgele web gezintisinden farklı bir bellek profiline sahiptir. Bu ayrım, iki katmanlı yapının ölçülebilir bir yan faydasıdır.

#### Sandbox katmanları

Motorun kendi sandbox'ı — WebKitGTK'da bubblewrap tabanlıdır, Linux'ta varsayılan açıktır ve yeni GTK4 (6.0) API'sinde kapatılamaz hâle getirilmiştir — tek savunma hattı olarak kabul edilmez. Katman (a), motorun sandbox'ının **üstüne** OZERK'in kendi katmanlarını koyar:

- Flatpak/portal tabanlı uygulama sandbox'ı (RFC-0003),
- Guard ağ profili (RFC-0005) — bir web uygulamasının hangi alan adlarına çıkabileceği manifestte beyan edilir (manifesto 13),
- uygulama başına ayrı veri alanı, yani bir uygulamanın açığından diğerinin verisine ulaşılamaması.

---

### 7. PWA boşluklarını kapatmanın maliyeti

Aşağıdaki rakamlar **tahmindir**, ölçüm değildir. Karar öncesinde en az bir bağımsız görüşle karşılaştırılmalıdır.

Kalıcı mühendis (FTE) tahmini, önerilen iki katmanlı yol için:

| İş | İlk uygulama (tahmin) | Kalıcı bakım (tahmin) |
|---|---|---|
| Katman (a) runtime'ın kendisi (profil izolasyonu, manifest doğrulama, yaşam döngüsü, Guard bağlaması) | 9–15 ay·mühendis | **1–2 FTE** |
| Web App Manifest API'sinin WebKitGTK'ya eklenmesi (`ENABLE_APPLICATION_MANIFEST` bugün kapalı; Epiphany kendi JS'iyle okuyor) | 3–6 ay·mühendis | 0.25 FTE |
| **Web Push + NotificationEvent'in WebKitGTK/WPE'ye eklenmesi ve UnifiedPush'a bağlanması** — en büyük tek kalem. Apple'ın `webpushd`'si tamamen Objective-C++ ve APNs'e bağlı olduğu için yeniden kullanılamaz; GTK/WPE için sıfırdan arka uç yazılması gerekir. Bugüne dek bu konuda bir hata kaydı bile açılmamıştır | **12–24 ay·mühendis** | **0.5–1 FTE** |
| Web Share API + XDG paylaşım portalı bağlaması (motor tarafında bayrak + `showShareSheet`) | 3–6 ay·mühendis | 0.25 FTE |
| WebAuthn/passkey desteği (manifesto 18.2 gereği; hata 2019'dan beri açık ve sahipsiz) | 9–18 ay·mühendis | 0.5 FTE |
| Katman (b) tarayıcı paketleme + güvenlik yaması takibi (Firefox'un resmî aarch64 yapısı varsa daha ucuz) | 2–4 ay·mühendis | **0.5–1 FTE** |
| **Toplam (önerilen yol)** | **≈ 3–6 yıl·mühendis ilk uygulama** | **≈ 3–5 FTE, kalıcı** |

Karşılaştırma için:

| Yol | Kalıcı FTE tahmini | Dayanak |
|---|---|---|
| Önerilen iki katmanlı yol (WebKitGTK/WPE + paketlenmiş tarayıcı) | ≈ 3–5 | Yukarıdaki kalem dökümü |
| QtWebEngine'e yaslanmak (Angelfish / morph-browser yolu) | ≈ 1–2 | Yükü Qt taşır; bedeli ~3,5 aylık güvenlik gecikmesi ve telefonda koşulsuz site isolation |
| Chromium'u kendi paketlemek (ungoogled dahil) | ≈ 8–15+ | Eylül 2026'dan sonra çeyrekte ~26 yeniden derleme; ≥100 GB disk; CI'da 24+ saat |
| Gecko gömme (EmbedLite yolu) | ≈ 4–8 | Sailfish'in ölçülmüş maliyeti: tek ESR sıçraması ~23 hafta tam zamanlı kodlama + 11 hafta belgeleme |
| Motor forku | İki basamaklı, kalıcı | **Kapsam dışı (K1)** |

Bu tabloda dikkat edilmesi gereken şey şudur: **QtWebEngine yolu, saf FTE sayısıyla bakıldığında önerilen yoldan ucuzdur.** Bu RFC yine de onu önermez; çünkü maliyet FTE cinsinden değil, ölçülmüş güvenlik gecikmesi, telefonda kaçış kapısız site isolation ve manifesto 1 ile çelişki cinsinden ödenir. Ancak bu tercihi "daha ucuz olduğu için" diye sunmak dürüst olmazdı — ve bu RFC öyle sunmuyor.

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

> **Not:** Bu RFC hazırlanırken yapılan kaynak düzeyindeki inceleme E1'in bir bölümünü zaten cevaplamıştır (Web Push, Web Share ve WebAuthn'un WebKitGTK'da bulunmadığı derleme yapılandırmasından okunmuştur). E1 bu nedenle bir keşif değil, **doğrulama ve ölçüm** deneyidir: kodun söylediğinin gerçek cihazda da geçerli olduğunu ve geri kalan vaatlerin gerçekten çalıştığını göstermek içindir. Kaynak okumak ile cihazda koşturmak aynı şey değildir.

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
| Ö1 | Manifesto 6.6'nın yedi vaadi | En az beşi seçilen motorda bugün karşılanıyor; kalanlar için sahibi ve son tarihi belli bir kapatma planı var (K7). **Bugünkü durum: WebKitGTK'da tam karşılanan üç vaat vardır (2, 3, 4); vaat 1 Epiphany katmanındadır, vaat 7 kısmidir, vaat 5 ve 6 yoktur. Yani Ö1 bugün karşılanmamaktadır ve bu, RFC'nin kabulünden önce kapatılması gereken açıktır.** |
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

Reddediliyor: bakım yükü OZERK'in ölçeğinin çok üstündedir ve **8 Eylül 2026'dan sonra iki katına çıkmaktadır** (Bölüm 7); masaüstü Linux hedefiyle derlenmiş Chromium telefonda site isolation kaçış kapısına sahip olmadığından bellek maliyeti referans donanımda ağırdır (Bölüm 6); QtWebEngine'e yaslanmak bu yükü kaldırır ama ~3,5 aylık ölçülmüş bir güvenlik gecikmesi getirir; ve seçenek manifesto 1'in bağımsızlık iddiasını en zayıf noktasından vurur. Kullanım payı ~%78 olan bir motoru varsayılan yapmak, OZERK'in var oluş gerekçesiyle çelişir.

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

1. **Web Push sorusu cevaplanmıştır: bugün etkinleştirilemez** (derleme seçeneği yoktur). Açık kalan soru şudur: bu işi kim, hangi fonla ve hangi tasarımla yapacak? Upstream WebKitGTK/WPE bakımcıları böyle bir katkıyı kabul etmeye istekli midir — ve OZERK bunu sormadan önce mi yoksa sonra mı fon başvurusu yapmalıdır? (D3 gereği: önce sorulur.) Bugüne dek bu konuda bir hata kaydı bile açılmamış olması, hem bir engel hem de bir fırsattır.
2. **WebAuthn boşluğu manifesto 18.2 ile nasıl uzlaştırılacak?** Manifesto 18.2 passkey ve WebAuthn desteğini açıkça vaat eder; WebKitGTK'da bu kapalıdır ve 2019'dan beri üzerinde çalışan yoktur. Bu vaat sistem düzeyinde mi (native uygulamalar için) yoksa web uygulamaları için de mi geçerlidir? İkincisi ise, ya boşluk fonlanmalı ya da manifesto tadil edilmelidir. Bu RFC bir cevap dayatmaz, ama sorunun açık bırakılmasına da izin vermez.
2b. **WebRTC'nin kararlı yapılarda kapalı olması ne kadar önemlidir?** Görüntülü görüşme, günlük mobil ihtiyaçlar arasındadır. Bu, `ENABLE_EXPERIMENTAL_FEATURES` ile açılabilecek bir derleme kararı mıdır, yoksa kararlılık nedeniyle kapalı tutulması mı gerekir? Ölçülmeli.
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

**The hardest finding must be stated up front.** The source-level review carried out while preparing this RFC shows that two of the seven promises in manifesto 6.6 — **notifications (while the app is closed) and system sharing** — cannot be met on WebKitGTK today. These are not features that "haven't been added yet": WebKitGTK has no build option for Web Push at all, `navigator.share` does not exist on GTK, and WebAuthn — separately promised in manifesto 18.2 — is off as well. Nobody is working on these gaps.

This does not change the proposal, because the only alternative, Chromium, carries a heavier maintenance burden, a longer security lag, and a worse memory cost on a phone. But it does require **declaring that the promise cannot be met as currently written**. The choice is between *"an incomplete but sustainable engine"* and *"a complete but unsustainable one"*; this RFC picks the first and does not hide the shortfall.

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

One figure shows how thin the "independence" column really is: according to Mozilla's audited 2024 financial statements, **86% of contract revenue came from a single customer** (85% in 2023). In other words, Gecko — the engine usually called independent — is commercially dependent on the owner of Blink. In the US search case the remedies ruling declined to ban Google's default-search payments; that ruling is on appeal, and the Department of Justice's cross-appeal asks the court to vacate the denial. The outcome is unresolved into 2027.

If all three engines are this dependent on the commercial decisions of a single company, OZERK's independence claim cannot be defended by picking an engine — only by declaring the dependency honestly.

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

- It is the most established of the **embeddable** engines on mobile Linux. (Careful: this does **not** mean "Epiphany is mobile Linux's default browser" — the table below corrects that common error.)

  | Distribution / shell | Default browser | Engine |
  |---|---|---|
  | Mobian (Phosh) | `phosh-core` recommends `epiphany-browser` | WebKitGTK |
  | postmarketOS (Phosh) | The meta-package mandates no browser; the project wiki documents **desktop Firefox + `mobile-config-firefox`** | Gecko |
  | postmarketOS (Plasma Mobile) | Angelfish is recommended | QtWebEngine (Blink) |
  | Ubuntu Touch / Lomiri | morph-browser | QtWebEngine (Blink) |
  | Sailfish OS | Sailfish Browser | Gecko (EmbedLite fork) |

  The mobile Linux world is therefore **split** on engines, and WebKitGTK is only one option. What OZERK should learn from this table is that there is no such fact as "everyone uses X".
- The WebKitGTK and WPE ports are maintained by Igalia. This does not remove dependency on a single large company (the engine itself is WebKit, and WebKit's principal contributor is Apple), but at the **port level** it moves the decision-making outside Apple, to a European worker cooperative. That is a meaningful but limited difference for independence, and it should be presented as such.
- WPE WebKit is the port designed specifically for embedding; the WPEPlatform layer is available in 2.52 and is expected to become the default in 2.54. This is a directly suitable embedding surface for layer (a).
- Its memory footprint is lower than Chromium-based alternatives (widely held; **an independent measurement is required** — Section 9, E3).
- Its source tree and build cost are orders of magnitude smaller than Chromium's; it is sustainable within the base distribution's existing package pipeline (RFC-0002).
- The licensing (a mix of LGPL-2.1 and BSD) is compatible with D1.

Its greatest weakness is equally clear: **its PWA API coverage is the narrowest of the three engines.** The table in Section 3 shows this line by line.

##### K4 — For layer (b): the user chooses; the default is decided separately

The general-purpose browser need not use the same engine as layer (a). OZERK will: offer at least one packaged browser in the official repository; not technically prevent the user from installing another browser (manifesto 6.5); and clearly state which browser uses which engine in the Freedom Inventory (RFC-0006).

Which browser will be the default is not decided in this RFC; it depends on the base distribution decision (RFC-0002) and on experiment E2. Today's evidence, however, makes **Firefox the cheapest credible answer**, and its being a different engine from layer (a)'s is not a drawback but an advantage:

- Official aarch64 Linux tarballs have shipped since Firefox 136 (March 2025); Linux/AArch64 is a Tier-1 build target. Alpine (postmarketOS's base) packages it for aarch64.
- Wayland has been the default since Firefox 121 (December 2023); touch and touchpad gestures are supported.
- The mobile-UI problem is already solved by postmarketOS's `mobile-config-firefox` (5.4.1, July 2026); OZERK does not need to redo that work.
- Web Push works, including on desktop Linux — meaning **promise 5b, missing in layer (a), is present in layer (b).** That is a concrete benefit of separating the layers: the user can use a push-dependent service in the browser.
- Known weakness: Firefox's address bar does not trigger the on-screen keyboard on Linux (bug open and unassigned since 2017). In-page text fields do work. This is a concrete usability issue that must be **measured** on the reference device.

Packaging a browser is not maintaining its engine. Choosing Firefox for layer (b) does not make OZERK dependent on Mozilla: the user can install another browser, and the OZERK repository can carry more than one.

##### K5 — The engine abstraction boundary

The surface layer (a) presents to developers and to the system (manifest fields, permission model, storage contract, lifecycle events) is defined **independently of the engine**. No engine-specific concept leaks into that surface.

The goal is not purity but a measurable exit cost: if the engine has to be changed, we should know in advance how much of the ecosystem will break. That this boundary actually works is proven by running the same runtime on a second backend (Section 9, E6).

##### K6 — PWA gaps are closed by contributing upstream

Per D3 (upstream-first strategy): when a missing web platform capability is identified, OZERK's first route is to submit that capability upstream to the relevant port (WebKitGTK / WPE / Epiphany). Carrying a downstream patch is a temporary measure and is recorded with its rationale.

Gaps that cannot be closed are **not hidden**: which promise is unmet on which device is written into the Freedom Inventory and the developer documentation (manifesto 6.14, 24).

##### K7 — A time-bounded commitment and a named fallback for Web Push

Web Push is layer (a)'s one critical gap, and not being dogmatic requires facing that: saying "we will contribute upstream" without giving a date is exactly the kind of promise manifesto 24 forbids.

Therefore:

1. Bringing Web Push + NotificationEvent to WebKitGTK/WPE is defined as a **funded work item with a named owner** (Section 7, RFC-0008).
2. If that work is **not merged upstream within 24 months**, the decision is reopened. Three options are then weighed: (i) a second, QtWebEngine-based runtime backend for the class D applications that need push, (ii) narrowing promise 5 through a manifesto amendment, (iii) extending the deadline with a stated rationale.
3. Until then **promise 5 counts as unmet and is declared as such.** As a partial measure, system notifications while the application is open (Notifications API) are supported, and the limit is explained clearly to the user.

That fallback option (i) is compatible with this RFC's K5 is not a coincidence: the engine abstraction boundary exists precisely for this.

---

#### 3. The seven promises of manifesto 6.6: status by engine

Manifesto 6.6 says a web application will be able to do the following. The table below shows the status of each promise on each engine **as of 17 August 2026**.

Notation: **✅** supported · **◐** partial · **✕** absent · **?** to be verified

| # | Promise (manifesto 6.6) | WebKitGTK 2.52 (+Epiphany) | Chromium (QtWebEngine / CEF) | Gecko (Firefox, Linux) | Servo | Ladybird |
|---|---|---|---|---|---|---|
| 1 | Installable to the home screen | ◐ **Epiphany does it, the engine does not.** `ENABLE_APPLICATION_MANIFEST` is off on GTK (on only for Cocoa); Epiphany reads the manifest with its own injected JS and falls back to scraping the page when there is none | ✅ Angelfish (Plasma Mobile) supports PWA installation; Chromium `--app` mode | ◐ **It came back:** "Web Apps" (Taskbar Tabs in-source) shipped on Windows in Firefox 143 (Sept 2025) default-on, and **on Linux in Firefox 150 (April 2026) but default-off** (`browser.taskbarTabs.enabled`). Creates `.desktop` files, supports Flatpak/Snap. Mozilla's own docs: "by design, still appear like a browser instead of appearing as a completely separate application" | ✕ | ✕ |
| 2 | Runs in an independent application window | ✅ | ✅ | ◐ the Taskbar Tabs window is not fully independent (see above) | ✕ | ✕ |
| 3 | Has its own storage area | ✅ Separate profile/cache directory via `WebKitNetworkSession`; Epiphany gives each web app `<data-dir>/<app-id>`. IndexedDB, DOM Cache and service worker registrations can be cleared separately. *(No quota-setting API.)* | ✅ via a separate profile directory | ◐ profile separation is manual | ◐ `SiteDataManager` exists in the embedding API; IndexedDB is off | ✕ |
| 4 | Works offline | ✅ Service Workers on by default since WebKitGTK 2.28.0 (March 2020); Cache API and IndexedDB present | ✅ | ✅ at the engine level | ✕ **Service Workers are off by default and partial** (behind `dom_serviceworker_enabled`). IndexedDB is off too. Offline web apps do not work today | ✕ |
| 5a | Receives notifications — **while the page is open** (Notifications API) | ◐ The `WebKitWebView::show-notification` signal has existed since 2.8; but GTK builds ship **no default notification presenter** — the embedder draws it. The notification is cancelled on navigation or close | ✅ | ✅ | ✕ Notification API off by default | ✕ |
| 5b | Receives notifications — **while the page/app is closed** (Web Push, RFC 8030/8291/8292) | ✕ **Not supported; there is not even a build option.** No `ENABLE_WEB_PUSH` CMake option exists; `ENABLE_WEB_PUSH_NOTIFICATIONS` is 1 only on macOS/iOS; `PushAPIEnabled` is `false` on every port. WebKit's `webpushd` is entirely Objective-C++ and bound to APNs — there is no Linux port. And because `ENABLE_NOTIFICATION_EVENT` = 0, **service workers cannot receive notification events at all** | **?** whether the Push API is enabled in QtWebEngine must be verified; raw Chromium supports it but the default endpoint is Google infrastructure | ✅ Firefox supports Web Push; redirecting it to UnifiedPush is documented in the IronFox/Fennec forks | ✕ | ✕ |
| 6 | Participates in the system share interface (Web Share API) | ✕ **Not supported.** `WebShareEnabled` is `true` only on Cocoa; `navigator.share` does not exist on GTK. There is no `ENABLE_WEB_SHARE` option and no portal wiring | **?** the status of `navigator.share` on Linux must be verified | **?** | ✕ | ✕ |
| 7 | Accesses camera, microphone and location with user permission | ◐ Camera/microphone (`getUserMedia`) ✅ — since WebKitGTK 2.50 via XDG Desktop Portal (`org.freedesktop.portal.Camera` + PipeWire), needing no sandbox exception. Screen sharing via the ScreenCast portal ✅. Location ✅ but through **GeoClue2** D-Bus, not a portal. ⚠️ **`ENABLE_WEB_RTC` is tied to experimental features, so `RTCPeerConnection` is off in stable builds** — a video-call web app will not work | ✅ (portal integration quality **?**) | ✅ | ✕ | ✕ |
| + | *(not in 6.6, but the practical complement of the offline promise)* Background Sync / Periodic Background Sync | ✕ **Declined on principle.** The Periodic Background Sync bug was closed WONTFIX (rationale: privacy, botnet and battery risk); the Background Sync bug has been untouched since 2019 | ✅ Supported in Chromium | ✕ **Mozilla declined it on principle too** (standards-positions: negative; rationale: persistent IP tracking and botnet risk) | ✕ | ✕ |
| + | *(promised in manifesto 18.2)* WebAuthn / passkeys | ✕ **Not supported.** `ENABLE_WEB_AUTHN` is off on GTK; the "[WPE][GTK] Support WebAuthn" bug has been open since 2019 with nobody working on it. **Direct conflict with manifesto 18.2** | ✅ | ✅ | ✕ | ✕ |
| + | *(security)* Process sandbox | ✅ **bubblewrap sandbox on by default on Linux**; in the new GTK4 (6.0) API it can no longer be turned off | ✅ | ✅ | **?** | **?** |
| + | *(security)* Site isolation | ✕ `SiteIsolationEnabled` is "unstable" and `false` by default on every port, and is never mentioned in the GTK release notes | ✅ (constrained on low memory) | ◐ | ✕ | ✕ |

**Conclusions — a worse table than the first draft:**

1. **Three of the seven promises are fully met** (2, 3, 4). Promise 1 is an Epiphany feature, not an engine one. Promise 7 is partial (camera/microphone/location yes, but WebRTC off in stable builds). **Promises 5 and 6 are not met.**
2. **Promise 5b (notifications while the app is closed) is not merely a gap but an architectural absence.** There is not even a build option for Web Push, and because `ENABLE_NOTIFICATION_EVENT` is off, service workers cannot receive notification events. The problem is not "a feature that has not been added" but **a capability not implemented in the engine**.
   This has a direct consequence: **the OZERK Web Runtime cannot close this gap with a JS bridge in its own layer.** If the service worker cannot receive the notification event, no amount of shell code compensates. The gap has to be closed inside the engine.
3. **The absence of WebAuthn directly conflicts with manifesto 18.2**, which explicitly promises passkey and WebAuthn support. It does not exist on the chosen engine today and nobody is working on it.
4. **The absence of Web Share invalidates promise 6.** This is a smaller job than the others (the portal exists), but it still requires an `EnabledBySetting` flag and a `showShareSheet` implementation on the engine side.
5. There is good news on the sandbox: bubblewrap cannot be disabled in the new API. Site isolation, however, is absent.
6. **Background Sync is not a "WebKit shortfall"; it is a Chromium-specific feature.** Both Apple and Mozilla declined the API on principle (persistent IP tracking, botnet risk, battery). OZERK not promising this API is not a deficiency but standing in the same privacy position as two independent engine vendors. The price is that web applications tested only against Chromium will work incompletely on OZERK — and that price must be stated plainly to the user.
7. **The Servo and Ladybird columns are effectively empty.** That means the choice today is a two-horse race: WebKitGTK/WPE or a Chromium port. The other three columns are informational, not options.

**One opportunity.** The UnifiedPush specification has been updated to require encryption (RFC 8291) and VAPID authorization (RFC 8292) — meaning UnifiedPush endpoints are now explicitly Web Push endpoints. So OZERK Push (RFC-0007) and layer (a)'s Web Push support could **share the same infrastructure**: what is missing is not the transport but the Push API and NotificationEvent implementation inside the engine. Apple's `webpushd` cannot be reused directly because it is bound to APNs; but WebKit's Push API skeleton exists and a GTK/WPE backend could be written. The same path has been shown to work on the Gecko side, where web push was added to Firefox forks (IronFox/Fennec) over UnifiedPush. This is the most concrete and highest-value target for the contribution work in K6.

---

#### 4. Evaluation of the options

Each option was evaluated against: current state on mobile Linux · PWA/Service Worker/Web Push/background sync coverage · security patch cadence and maintenance burden · embedding API quality · Wayland/touch fit · memory footprint · license compatibility.

##### Option 1 — WebKitGTK / WPE WebKit

| Criterion | Status |
|---|---|
| State on mobile Linux | **The most established of the embeddable engines**, but not a monopoly: Mobian Phosh recommends Epiphany, postmarketOS documents Firefox, Plasma Mobile and Ubuntu Touch use QtWebEngine (see the table in K3). Development is active: WebKitGTK 2.52.5 (9 July 2026), development branch 2.53.90 (7 August 2026), Epiphany 50.6 (13 August 2026). |
| PWA coverage | **The narrowest — and nobody is working on the gaps.** Present: Service Workers (since 2.28.0), a separate storage session, IndexedDB/Cache API, portal-based camera and screen sharing, location via GeoClue2, a bubblewrap sandbox. Absent: Web Push (not even a build option), service-worker notifications (`ENABLE_NOTIFICATION_EVENT` = 0), the Web App Manifest API, Web Share, WebAuthn, Background Sync, site isolation. WebRTC is also off in stable builds. |
| Security cadence | **Measured, generally good, but not guaranteed.** Advisory volume: 12 in 2023, 8 in 2024, 10 in 2025, 4 in 2026 through July. WebKitGTK reuses Apple's exact CVE IDs and text; its scope is always a subset of Apple's. Lags measured in 2026: WSA-2026-0002 **4 days**, WSA-2026-0004 **11 days**, WSA-2026-0003 **20 days**. For a vulnerability exploited in the wild (WSA-2025-0010) the lag was **5 days**. ⚠️ **But there is an open gap on the day this document was written:** Safari 26.6 shipped on 27 July 2026 with 10 CVEs; as of 17 August 2026 no WebKitGTK advisory covers them — **21 days and counting.** So the 7-day median threshold in Section 6 is not always met by current upstream behavior. |
| Maintenance burden | Engine maintenance stays upstream (Igalia). OZERK's burden: packaging, runtime integration, contributions for PWA gaps. Orders of magnitude lower than Chromium. |
| Embedding API quality | A mature GObject API for WebKitGTK; three API versions supported in parallel (webkitgtk-6.0 / webkit2gtk-4.1 / webkit2gtk-4.0). WPE WebKit is designed for embedding; WPEPlatform is available in 2.52 and expected to be the default in 2.54. **Known weakness:** API version fragmentation across distributions is a documented pain point for projects that build on WebKitGTK, such as Tauri. |
| Wayland / touch | Wayland is a first-class path (WPE was literally born as "WebKit for Wayland") and is mature. Touch improved markedly in 2.52: Pointer Events were enabled for touch input, the behavior of mouse events synthesized from touch was fixed, and Pointer/Touch Events moved to fractional coordinates. On-screen keyboard integration and gesture quality **must be measured** on the reference device. |
| Memory footprint | Widely held to be markedly lower than Chromium's; but our sources are anecdotal. **An independent measurement is needed** (E3). |
| License | A mix of LGPL-2.1 and BSD; compatible with D1. |

##### Option 2 — Chromium-based embedding (CEF, QtWebEngine, or direct)

This is not one option but **three**, with very different cost profiles: (2a) packaging Chromium yourself, (2b) CEF, (2c) QtWebEngine.

| Criterion | Status |
|---|---|
| State on mobile Linux | **Not theoretical — in fact dominant.** Ubuntu Touch's morph-browser and postmarketOS Plasma Mobile's Angelfish are both built on QtWebEngine (Blink). The two projects closest to OZERK took this path, accepting the lag in exchange for not maintaining the engine themselves. |
| PWA coverage | **The widest.** All seven promises, plus Web Push, Web Share, WebAuthn and Background Sync, exist in Chromium. Whether they are enabled in QtWebEngine/CEF is a separate question — **to be verified** (E2). |
| Security cadence — (2a) self-packaging | Today a 4-week release cycle with a security refresh roughly every 6 days. ⚠️ **On 8 September 2026, with Chrome 153, the cycle drops to two weeks.** Rebuild events per quarter go from ~13 to ~26. Google's advice to embedders is explicit: "tracking the latest stable upstream is usually less work for greater benefit in the long run than backporting." The one real relief valve is the **extended-stable** branch maintained for embedders (8-week milestones, biweekly security) — but Chromium's own docs warn that "larger features that improve security (e.g. Site Isolation) may not be viable to backport." |
| Security cadence — (2c) QtWebEngine | **The lag is measured and large.** Qt 6.11.1's Chromium base is 140, with security patches carried up to 148.0.7778.96 (5 May 2026) — while upstream stable was 151.0.7922.137 on 11 August 2026. That is a ~3.5-month security lag and an 11-milestone engine lag. Qt 6.8.8 LTS is further behind (base 134, 17 milestones). A striking inversion: **6.8.8 LTS's security level (27 May 2026) is newer than the newest Qt's (5 May 2026)** — "newest Qt" and "most-patched Qt" are not the same thing. |
| Maintenance burden | (2a) **not carriable:** ~30 GB git cache, at least 100 GB of disk, 16+ GB RAM recommended; ungoogled-chromium's full build takes over 24 hours on CI and the project publishes no ARM64 Linux binaries — that build would be OZERK's. (2b) CEF publishes ready-made `linuxarm64` binaries (stable: CEF 151.3.18 / Chromium 151.0.7922.138) and an LTS on every sixth branch with ~8 months of extra fixes; this solves the build-farm problem outright. (2c) With QtWebEngine, Qt carries the burden. |
| Embedding API quality | CEF is mature and widely used. ⚠️ **But three warnings:** **84.5% of CEF commits** over the last year came from a single person (bus factor 1); the documentation mentions neither ARM64 nor Wayland anywhere — the ARM64 binaries exist de facto, not de jure; and **embedding into a Wayland host window has been an open problem since 2019** (a community patch was demonstrated in August 2026 but also needs a Chromium-side change). The issue asking how CEF will adapt to the two-week cycle has had **no comments since March 2026.** |
| Wayland / touch | Desktop Wayland is solved: `--ozone-platform-hint=auto` has been the default since Chrome 140 (August 2025), `text-input-v3` on by default since 138, touchpad gestures supported. ⚠️ The open bugs cluster precisely on the **mobile** side: Chromium violates the text-input protocol ordering, so the on-screen keyboard may fail to appear; squeekboard is not visible over fullscreen Chromium. No primary evidence was found for touch quality on phone form factors — **to be measured.** |
| Memory footprint | The highest — **and it produces the most critical finding in Section 6.** Chromium's low-memory escape hatches only apply in `IS_ANDROID` builds; a Chromium built for desktop Linux on an ARM64 phone does not have them. Details in Section 6. |
| License | The core is BSD-3-Clause and **does not conflict with GPL-3**; Debian ships arm64 chromium in `main`. Non-free codecs are a build flag (`proprietary_codecs`, off in unbranded builds) — the price being that unbranded builds have **no H.264 and no AAC**, a real loss in web compatibility. AV1/VP9 are royalty-free. H.264 licensing is free up to 100k units per year. ⚠️ **Widevine cannot be redistributed:** its license is "Commercial", the binary is not in the tree, and access requires signing the Widevine Master License Agreement — whether OZERK could obtain one is unknown. DRM-protected video services (common among class D applications) may therefore not work; this is not Chromium-specific but a limit across all options, and per manifesto 24 it must be declared. |
| Independence | **The worst option** with respect to manifesto 1: Blink's direction is set by Google and its usage share is ~78%. Choosing this engine strikes the "not dependent on a single company" claim at its weakest point. A portability warning too: postmarketOS's package definition carries the note `# riscv64 blocked by qt6-qtwebengine` — QtWebEngine can block an entire architecture. |

##### Option 3 — Gecko / GeckoView

| Criterion | Status |
|---|---|
| State on mobile Linux | **Far better than expected.** Official aarch64 Linux tarballs have shipped since Firefox 136 (March 2025); Linux/AArch64 is a Tier-1 build target. Alpine packages it for aarch64. The postmarketOS wiki documents desktop Firefox as the default on Phosh and Plasma Mobile, with `mobile-config-firefox` (5.4.1, July 2026) supplying the mobile UI. Wayland has been the default since Firefox 121. ⚠️ Known defect: the address bar does not trigger the on-screen keyboard on Linux (bug open and unassigned since 2017); in-page text fields work via `zwp_text_input_v3`. |
| PWA coverage | Web Push ✅ works, including on desktop Linux (and is shown to be redirectable to UnifiedPush in Firefox forks). Installable web apps: **partially back** — "Web Apps" arrived on Linux in Firefox 150 (April 2026) but is off by default, and Mozilla's own documentation says it "still appears like a browser instead of a completely separate application". Background Sync is declined on principle. |
| Embedding API quality | **The decisive weakness of this option.** Mozilla abandoned the general-purpose embedding API in 2011; mozilla-central has no top-level `embedding/` directory; the relevant discussion list has been dead since 2015. GeckoView is published **only as an Android AAR**; there is no `mobile/linux` target in mozilla-central. |
| The one real embedding path, and its cost | Sailfish OS's **EmbedLite** fork is alive (last pushes August 2026) — but its price has been measured: the base version is Gecko **115.37.0** with 89 downstream patches on top, and the ESR140 port is still in progress. A single ESR bump (ESR78→ESR91) took roughly **23 weeks of full-time coding plus 11 weeks of documentation**, and ESR102 was skipped entirely. This is the numeric demonstration of why forking was rejected (K1). |
| Security cadence | Mozilla's patch cadence is good; but packaging happens at the level of the Firefox application, not an embeddable library. On the EmbedLite path, security arrives four ESR generations late. |
| Maintenance burden | Because there is no supported embedding path, layer (a) cannot be built on this engine. For layer (b), however, it is **the lowest burden**: package Mozilla's official aarch64 build. |
| Memory footprint | Between Chromium and WebKitGTK; **to be measured.** |
| License | MPL-2.0; compatible with D1. |
| Independence | Ostensibly the most "independent" engine; but **86% of contract revenue in 2024 came from a single customer**. In the search case the payment ban was denied, the ruling is on appeal, and the Department of Justice's cross-appeal asks for that denial to be vacated; oral argument is expected in late 2026 / early 2027. Gecko's financial future is an open question today. |

**Conclusion:** Gecko is the **strongest candidate for layer (b)** (see K4). It is unsuitable for layer (a) as long as no supported embedding path exists — and EmbedLite's measured cost shows that taking that route would in practice violate K1.

##### Option 4 — Servo

| Criterion | Status |
|---|---|
| Current state | **Not production-ready, but pointed in the right direction and moving genuinely fast.** The `servo` crate reached crates.io as 0.1.0 on 13 April 2026 and 0.4.0 by 16 July 2026. Monthly feature releases plus a six-monthly LTS branch (9 months of support) are actually being practiced, and the LTS really does get patched (0.1.2 backported fixes from Mozilla's SpiderMonkey advisories). |
| Embedding API quality | `ServoBuilder`/`WebViewBuilder`, multiple webviews, `OffscreenRenderingContext`, `SiteDataManager`, `NetworkManager` all exist. ⚠️ Its own documentation: "The documentation on how to embed Servo is **sparse**." Breaking API changes land roughly monthly. ⚠️ **Verso, the reference embedder, is dead** (archived October 2025; stated reason: "limited manpower and funding"), leaving only `servoshell`. |
| Web platform coverage | WPT: over 2025 the score went 48.2% → 61.6% and subtests 69.9% → 93.4% (Servo's own measurement; not all tests are run). ⚠️ **Decisive for this decision:** Service Workers are **off by default and partial**. IndexedDB, Notification, Permissions, Storage, Geolocation, WebRTC and WebGL2 are also off by default. Offline PWAs therefore do not work on Servo today. |
| Security posture | ⚠️ **Its weakest area.** It runs **single-process by default** (`--multiprocess` is opt-in). The sandbox (`gaol`) is described in the future tense in its own book. SECURITY.md is one sentence; **zero** security advisories have been published. An independent audit (NLnet-funded) was done but narrow in scope (CSS floats/tables and Stylo). Its own download page says: *"Please don't log into your bank with Servo just yet!"* The LTS page is equally frank: *"no specific guarantees are given, including security guarantees… LTS releases are provided on a best-effort basis by interested community members."* |
| Governance and funding | A Linux Foundation Europe project. Igalia is the de-facto maintainer (27.34% of 2025 commits). The Sovereign Tech Fund gave Igalia a ~12-month grant that includes "**completing a stable WebView embedding API for desktop and mobile**" (October 2025) — which maps directly onto OZERK's need. ⚠️ Community funding, by contrast, is very small: roughly $88k a year on Open Collective with about $7.7k a month in recurring donations. By Servo's own yardstick ($10k/month ≈ one full-time developer) that is **under one FTE**; there are no paying sponsors on the governing board. |
| ARM64 / mobile | **The only candidate that genuinely targets phones.** There is an official `servo-aarch64-linux-gnu` nightly; OpenHarmony aarch64 is a first-class platform and is cited as the **reference implementation** in the embedding docs. ⚠️ But there is **no aarch64 CI** (all WPT runs are x86-64), the Wayland support level is undocumented, and a hit-testing offset bug is open on PinePhone Pro / Mobian — exactly OZERK's hardware class. |
| Independence | A genuine fourth-path candidate not tied to any of the three engines. In the long run this is the option best aligned with OZERK's interests. |

**Conclusion:** Cannot be chosen today — Service Workers being off is on its own enough to make promise 4 of 6.6 impossible. But it is the **candidate to watch most closely**, for two reasons: the Sovereign Tech Fund money is going precisely into the missing embedding API, and Servo is the only project taking phones seriously. One concrete signal: **Kumo**, a Wayland mobile Linux browser aimed at exactly the hardware class OZERK targets, uses **WebKit as its primary engine with Servo as an option** (1.7.0, April 2026) — an independent rediscovery of the path this RFC proposes.

##### Option 5 — Ladybird

| Criterion | Status |
|---|---|
| Current state | **The alpha has not shipped** (17 August 2026). There are no published releases; the download page 404s. Its own README: *"Ladybird is in a pre-alpha state, and only suitable for use by developers."* Roadmap: alpha 2026, beta 2027 (a downloadable app), **stable release 2028**. |
| Independence | **Its greatest strength.** Not a fork of any existing engine; written from scratch. Funded by donations and sponsorships through a 501(c)(3) nonprofit (Platinum: FUTO, Shopify, Cloudflare; Gold: Human Rights Foundation, Proton VPN; co-founder Chris Wanstrath's family pledged $1 million). It states that it keeps 18 months of runway at all times. Team size and budget are unpublished ("financials to be published soon"). |
| Embedding API | ✕ **None — and no stated intent to build one.** `Porting.md` describes adding a *UI port* (subclassing `WebView::ViewImplementation`), not embedding. ⚠️ The direction is narrowing, not opening: **the GTK port was deleted in July 2026** ("The Gtk port is gone"), with effort consolidated on the Qt port. |
| Contribution channel | ⚠️ **All public pull requests were stopped on 5 June 2026**, and the then-open ones were closed. There is no alternative channel: "There will not be a separate process for submitting patches by other means." The rationale is defensible (AI has destroyed the assumption that a large patch implies understanding and accountability; a browser runs untrusted input from the entire internet). **For OZERK the consequence is clear: a mobile port cannot be sent upstream.** What remains is permanent out-of-tree carry or a hard fork — both in conflict with K1. |
| Security posture | Better than expected, but not sufficient. There is a multi-process architecture (UI + a WebContent per tab + ImageDecoder + RequestServer), and **real sandboxing landed in June 2026** (seccomp/Landlock on Linux, Seatbelt on macOS, on by default); per-profile sandbox rules followed in July. ⚠️ But its own SECURITY.md is explicit: *"many security features of the web platform are not yet implemented in Ladybird"* — CSP, XSS and cross-origin sandboxing are listed out of scope. There is no bug bounty. |
| ARM64 / mobile Linux | ✕ ARM64 Linux exists only as a *sanitizer* CI job; there is **no release job**. In their own words: *"Mobile platforms are not a current focus."* Android CI runs on an x86_64 emulator. |

**Conclusion:** Cannot be chosen today, and **will not be choosable in the near future.** There are three hard blockers: there is no embedding API and none is coming; outside contributions are not accepted, so a mobile port cannot be sent upstream; and nothing usable ships before 2027. Ladybird is the project whose goals overlap most with OZERK's long-term interests, and it **deserves to be watched and supported** — but it cannot be bet on. Condition for re-evaluation: the alpha shipping, and an embedding API being announced.

##### Comparison summary

| | WebKitGTK/WPE | Chromium (CEF/QtWebEngine) | Gecko | Servo | Ladybird |
|---|---|---|---|---|---|
| Suitable for layer (a) today? | **Yes — but promises 5 and 6 are missing** | Yes — at a security and memory cost | ✕ no embedding path | ✕ Service Workers off | ✕ no embedding API |
| Suitable for layer (b) today? | Yes | Yes | **Yes — the cheapest** | ✕ | ✕ |
| PWA coverage | Narrow (basics yes, engagement no) | **Complete** | Medium (push yes, install half) | Very narrow | Very narrow |
| OZERK's maintenance burden | Low | Very high (doubling after Sept 2026) | Very low for layer (b) | Unknown | Not applicable |
| Measured security lag | 4–20 days (one open gap: 21 days) | QtWebEngine ~3.5 months; continuous if self-packaged | Same as upstream | No advisory process | No bounty, many protections missing |
| Single-company dependence | Medium (Apple + Igalia) | **High (Google)** | **High** (86% of revenue from one customer) | Low | **Lowest** |
| Memory | Low | High (no site-isolation escape hatch on a phone) | Medium | Unknown | Unknown |
| Accepts contributions? | Yes (the upstream-first path is open) | Yes | Yes | Yes | **No** |

**The one-sentence conclusion from this table:** the choice is between *"an incomplete but sustainable engine"* and *"a complete but unsustainable one"*. This RFC proposes the former, and proposes declaring the shortfall rather than hiding it, seeking funding to close it, and narrowing the promise if it cannot be closed.

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

The upstream side was partially measured while writing this RFC (the distribution side is still unmeasured — E4). Findings:

| WebKitGTK advisory | Date | Lag behind upstream |
|---|---|---|
| WSA-2026-0002 | 28 March 2026 | **4 days** |
| WSA-2026-0004 | 10 July 2026 | **11 days** |
| WSA-2026-0003 | 2 June 2026 | **20 days** |
| WSA-2026-0001 | 18 March 2026 | 35–310 days (an accumulated catch-up) |
| WSA-2025-0010 (exploited in the wild) | 17 December 2025 | **5 days** |

So the upstream side usually sits in a 4–20 day band and can drop to 5 days for an actively exploited vulnerability. **But there is an open gap on the day this document was written:** Safari 26.6 shipped on 27 July 2026 with 10 CVEs; as of 17 August 2026 no WebKitGTK advisory covering them has been published — **21 days and counting.** This shows that the thresholds below are not a wish but numbers that genuinely need testing.

Other findings:

- Advisory volume: 12 in 2023, 8 in 2024, 10 in 2025, 4 in 2026 through July.
- WebKitGTK reuses Apple's exact CVE IDs and text, and its scope is always a **subset** of Apple's. So a vulnerability specific to WebKitGTK with no Apple-side counterpart requires a separate route.
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

Current state — and here lies this RFC's most unexpected finding:

**In Chromium**, site isolation is mature and on by default. There are escape hatches for low-memory devices: the partial-isolation threshold is **1900 MB** and the strict-isolation threshold is **3200 MB** (the in-code rationale: "roughly correspond to 2GB+ and 4GB+ devices"). The default assumed memory per renderer process is **85 MB** (64-bit), and the renderer cap is computed as `(total RAM MiB / 2) / 85`.

⚠️ **But all of those thresholds sit inside an `#if BUILDFLAG(IS_ANDROID)` block. Desktop enforces no default memory threshold.** A Chromium built with `target_os = "linux"` running on an ARM64 phone is not `IS_ANDROID` — so on identical hardware it gets none of the relief Chrome-for-Android applies, and runs **strict site-per-process unconditionally**. On a 3 GB phone the renderer cap works out to about 17 processes.

This is a sharper problem than "Chromium uses more memory": on mobile Linux, Chromium does not know it is on a phone. OZERK would have three options — accept it, carry a patch that adopts the Android semantics (i.e. a downstream fork burden), or disable site isolation (i.e. give up the Spectre defense). All three have a price, and all three must be declared.

**In WebKit**, site isolation is newer, and **it does not exist in WebKitGTK today**: the `SiteIsolationEnabled` preference is "unstable" and `false` by default on every port, and is never mentioned in the GTK release notes. So if WebKitGTK is chosen, site isolation is not a cost but a **missing feature**. In exchange, the bubblewrap sandbox is on and non-disableable in the new GTK4 API — a weaker but non-zero defense.

OZERK's position should be:

1. The memory cost of site isolation on the reference device is **measured** (E3), not estimated.
2. If site isolation is disabled for memory reasons, this is **disclosed clearly to the user** and written into the Freedom Inventory. Disabling it silently would violate manifesto 24.
3. Layers (a) and (b) may have different policies: isolating a small number of trusted web applications has a different memory profile from arbitrary web browsing. That distinction is a measurable side benefit of the two-layer structure.

##### Sandbox layers

The engine's own sandbox — in WebKitGTK a bubblewrap-based one, on by default on Linux and made non-disableable in the new GTK4 (6.0) API — is not treated as the sole line of defense. Layer (a) places OZERK's own layers **on top of** the engine's sandbox:

- a Flatpak/portal-based application sandbox (RFC-0003),
- the Guard network profile (RFC-0005) — which domains a web application may reach are declared in the manifest (manifesto 13),
- a separate data area per application, so that a flaw in one application does not reach another's data.

---

#### 7. The cost of closing the PWA gaps

The figures below are **estimates**, not measurements. They must be compared against at least one independent opinion before the decision.

Permanent engineer (FTE) estimate for the proposed two-layer path:

| Work | Initial implementation (est.) | Ongoing maintenance (est.) |
|---|---|---|
| The layer (a) runtime itself (profile isolation, manifest validation, lifecycle, Guard binding) | 9–15 engineer-months | **1–2 FTE** |
| Adding the Web App Manifest API to WebKitGTK (`ENABLE_APPLICATION_MANIFEST` is off today; Epiphany reads it with its own JS) | 3–6 engineer-months | 0.25 FTE |
| **Adding Web Push + NotificationEvent to WebKitGTK/WPE and wiring it to UnifiedPush** — the single largest item. Apple's `webpushd` cannot be reused because it is entirely Objective-C++ and bound to APNs; a backend must be written from scratch for GTK/WPE. To date not even a bug has been filed about this | **12–24 engineer-months** | **0.5–1 FTE** |
| Web Share API + XDG share portal binding (an engine-side flag plus `showShareSheet`) | 3–6 engineer-months | 0.25 FTE |
| WebAuthn/passkey support (required by manifesto 18.2; the bug has been open and unowned since 2019) | 9–18 engineer-months | 0.5 FTE |
| Layer (b) browser packaging + security patch tracking (cheaper if Firefox's official aarch64 build is used) | 2–4 engineer-months | **0.5–1 FTE** |
| **Total (proposed path)** | **≈ 3–6 engineer-years initial** | **≈ 3–5 FTE, permanent** |

For comparison:

| Path | Permanent FTE estimate | Basis |
|---|---|---|
| The proposed two-layer path (WebKitGTK/WPE + a packaged browser) | ≈ 3–5 | The itemization above |
| Leaning on QtWebEngine (the Angelfish / morph-browser route) | ≈ 1–2 | Qt carries the burden; the price is a ~3.5-month security lag and unconditional site isolation on a phone |
| Packaging Chromium in-house (including ungoogled) | ≈ 8–15+ | ~26 rebuilds per quarter after September 2026; ≥100 GB disk; 24+ hours on CI |
| Gecko embedding (the EmbedLite route) | ≈ 4–8 | Sailfish's measured cost: a single ESR bump ≈ 23 weeks full-time coding + 11 weeks documentation |
| Forking an engine | Double digits, permanent | **Out of scope (K1)** |

The thing to notice in this table is that **the QtWebEngine route is cheaper than the proposed path in pure FTE terms.** This RFC nonetheless does not propose it, because the cost is paid not in FTE but in measured security lag, in site isolation without an escape hatch on a phone, and in conflict with manifesto 1. But presenting the choice as "cheaper" would not be honest — and this RFC does not present it that way.

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

> **Note:** the source-level review carried out while preparing this RFC has already answered part of E1 (the absence of Web Push, Web Share and WebAuthn in WebKitGTK was read from the build configuration). E1 is therefore not a discovery experiment but a **confirmation and measurement** one: to show that what the code says also holds on a real device, and that the remaining promises genuinely work. Reading source and running on hardware are not the same thing.

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
| Ö1 | The seven promises of manifesto 6.6 | At least five are met on the chosen engine today; the rest have a closure plan with a named owner and a deadline (K7). **Current state: three promises are fully met on WebKitGTK (2, 3, 4); promise 1 sits in the Epiphany layer, promise 7 is partial, and promises 5 and 6 are absent. So Ö1 is not met today, and that is the gap to close before this RFC is accepted.** |
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

Rejected: the maintenance burden is far above OZERK's scale and **doubles after 8 September 2026** (Section 7); because a Chromium built for desktop Linux has no site-isolation escape hatch on a phone, the memory cost on the reference hardware is heavy (Section 6); leaning on QtWebEngine removes that burden but introduces a measured ~3.5-month security lag; and the option strikes manifesto 1's independence claim at its weakest point. Making an engine with ~78% usage share the default contradicts OZERK's reason for existing.

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

1. **The Web Push question is answered: it cannot be enabled today** (there is no build option). What remains open is: who will do this work, with what funding, and to what design? Are the upstream WebKitGTK/WPE maintainers willing to accept such a contribution — and should OZERK apply for funding before asking them or after? (Per D3: ask first.) That not even a bug has been filed about this to date is both an obstacle and an opportunity.
2. **How will the WebAuthn gap be reconciled with manifesto 18.2?** Manifesto 18.2 explicitly promises passkey and WebAuthn support; it is off in WebKitGTK and nobody has worked on it since 2019. Does that promise apply at the system level (for native applications), or to web applications as well? If the latter, the gap must either be funded or the manifesto amended. This RFC does not impose an answer, but it does not allow the question to be left open either.
2b. **How much does WebRTC being off in stable builds matter?** Video calling is among everyday mobile needs. Is this a build decision that could be flipped via `ENABLE_EXPERIMENTAL_FEATURES`, or should it stay off for stability? To be measured.
3. **Should layers (a) and (b) use the same engine?** The same engine saves memory and maintenance (a shared library). Different engines reduce the single-point-of-failure risk. Which dominates depends on the E3 measurement.
4. **How will remote code change in hosted web applications (class D) be handled?** Manifesto 8.2 D requires that the user be informed. What is the technical expression of that in the runtime — a warning at every launch, Guard's domain control, or content integrity pinning (SRI-like)? To be resolved together with RFC-0003 and RFC-0005.
5. **If site isolation is disabled for memory reasons, what level does isolation between class C and D applications fall to?** Process-group separation (manifesto 6.6) is not the same thing as site isolation; how to explain the difference to the user is a design problem for the Privacy Center (manifesto 9.3).
6. **Is contributing to Servo and Ladybird a correct use of OZERK's resources?** In terms of long-term independence, yes; in terms of the short-term product, no. Should a small but non-zero contribution budget be set aside?
7. **The memory footprint claim must be verified.** That WebKitGTK uses less memory than Chromium is widely held; our sources are anecdotal. E3 must measure it.

---

## Kaynaklar / Sources

Aşağıdaki kaynaklar 17 Ağustos 2026 tarihinde kontrol edilmiştir. Bir iddianın kaynağı burada yoksa, o iddia belgede "doğrulanmalı" olarak işaretlidir.

*The sources below were checked on 17 August 2026. If a claim has no source here, it is marked "to be verified" in the document.*

> **Yöntem notu / method note.** Bu RFC'deki motor yetenek iddiaları blog metinlerinden değil, doğrudan **kaynak ağacındaki yapılandırma dosyalarından** okunmuştur (`Source/cmake/WebKitFeatures.cmake`, `OptionsGTK.cmake`, `Source/WTF/wtf/PlatformEnable*.h`, `Source/WTF/Scripts/Preferences/UnifiedWebPreferences.yaml`) — çünkü WebKit'in özellik durumu sayfası (`webkit.org/status`) emekliye ayrılmıştır. Kaynak okumak ikincil kaynaklardan güvenilirdir; ama cihazda koşturmanın yerini tutmaz (bkz. E1).

**WebKitGTK / WPE WebKit**

- WebKitGTK sürüm haberleri / release news — <https://webkitgtk.org/news.html>
- Dokunmatik ve Pointer Events iyileştirmeleri / touch and Pointer Events improvements (2.52.0) — <https://webkitgtk.org/2026/03/18/webkitgtk2.52.0-released.html>
- WebKit özellik durumu sayfasının emekliye ayrılması / feature status page retired — <https://webkit.org/status/>
- Bug 205350 — [WPE][GTK] Support WebAuthn (2019'dan beri NEW) — <https://bugs.webkit.org/show_bug.cgi?id=205350>
- Bug 204117 — Periodic Background Sync (WONTFIX) — <https://bugs.webkit.org/show_bug.cgi?id=204117>
- Bug 244004 — XDG portal kamera erişimi / portal camera access — <https://bugs.webkit.org/show_bug.cgi?id=244004>
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
- Site isolation genel bakış ve bellek maliyeti / overview and memory overhead — <https://www.chromium.org/Home/chromium-security/site-isolation/>
- **Bellek eşiklerinin yalnızca Android'de geçerli olması** / memory thresholds are Android-only — `components/site_isolation/site_isolation_policy.cc` — <https://chromium.googlesource.com/chromium/src/+/main/components/site_isolation/site_isolation_policy.cc>
- Süreç başına bellek varsayımı ve renderer üst sınırı / per-renderer estimate and cap — `content/browser/renderer_host/render_process_host_impl.cc`
- **İki haftalık sürüm döngüsüne geçiş / move to a two-week release cycle (Chrome 153, 8 Eylül / September 2026)** — <https://developer.chrome.com/blog/chrome-two-week-release>
- Sürüm döngüsü ve extended stable / release cycle and extended stable — <https://chromium.googlesource.com/chromium/src/+/main/docs/process/release_cycle.md>
- Gömücülere güvenlik tavsiyesi / security advice to embedders — <https://chromium.googlesource.com/chromium/src/+/HEAD/docs/security/faq.md>
- Derleme gereksinimleri / build requirements — <https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md>
- CEF dal ve derleme politikası / branches and building — <https://chromiumembedded.github.io/cef/branches_and_building>
- CEF sorun 2804 — Wayland gömülü pencere desteği (2019'dan beri açık) / embedded Ozone-Wayland windows — <https://github.com/chromiumembedded/cef/issues/2804>
- CEF sorun 4114 — iki haftalık döngüye uyum (yorumsuz) / adapting to the two-week cycle — <https://github.com/chromiumembedded/cef/issues/4114>
- Qt WebEngine Chromium sürüm eşlemesi / Chromium version mapping — <https://wiki.qt.io/QtWebEngine/ChromiumVersions>
- Qt WebEngine genel bakış ve yama politikası / overview and patch policy — <https://doc.qt.io/qt-6/qtwebengine-overview.html>
- Markasız Chromium ile Google Chrome farkı (kodekler) / Chromium vs Chrome (codecs) — <https://chromium.googlesource.com/chromium/src/+/main/docs/chromium_browser_vs_google_chrome.md>
- Widevine lisans koşulları / licensing terms — <https://developers.google.com/widevine/access>
- Ubuntu Touch morph-browser (QtWebEngine) — <https://gitlab.com/ubports/development/core/morph-browser>

**WebKit site isolation ve Background Sync / and Background Sync**

- WebKit site isolation belgeleri / documentation — <https://docs.webkit.org/Deep%20Dive/SiteIsolation.html>
- Background Sync WebKit standards-positions #14 — <https://github.com/WebKit/standards-positions/issues/14>
- Web Push ve `webpushd` (Apple platformları / Apple platforms) — <https://webkit.org/blog/12945/meet-web-push/>

**Gecko / Firefox**

- Gecko gömme desteğinin bırakılması / dropping embedding support — <https://lwn.net/Articles/436412/>, <https://www.chrislord.net/2016/03/08/state-of-embedding-in-gecko/>
- GeckoView'ın Android'e bağlı olması / GeckoView is Android-only — <https://wiki.mozilla.org/Mobile/GeckoView>, <https://maven.mozilla.org/maven2/org/mozilla/geckoview/geckoview/>
- Sailfish EmbedLite çatalı / fork — <https://github.com/sailfishos/gecko-dev>
- Bir ESR sıçramasının ölçülmüş maliyeti / measured cost of one ESR bump — <https://www.flypig.co.uk/gecko>
- Resmî aarch64 Linux yapıları / official aarch64 Linux builds (Firefox 136) — <https://www.firefox.com/en-US/firefox/136.0/releasenotes/>
- Desteklenen derleme yapılandırmaları (Tier-1) / supported build configurations — <https://firefox-source-docs.mozilla.org/build/buildsystem/supported-configurations.html>
- postmarketOS'ta Firefox ve `mobile-config-firefox` — <https://wiki.postmarketos.org/wiki/Firefox>, <https://gitlab.postmarketos.org/postmarketOS/mobile-config-firefox>
- Wayland varsayılanı / Wayland by default (Firefox 121) — <https://www.firefox.com/en-US/firefox/121.0/releasenotes/>
- Ekran klavyesi hatası / on-screen keyboard bug 1408653 — <https://bugzilla.mozilla.org/show_bug.cgi?id=1408653>
- Web Apps (Taskbar Tabs) belgeleri / documentation — <https://firefox-source-docs.mozilla.org/browser/components/taskbartabs/docs/index.html>
- Linux desteği / Linux support — <https://bugzilla.mozilla.org/show_bug.cgi?id=1982733>
- Mozilla'nın Background Sync konumu / standards position — <https://github.com/mozilla/standards-positions/issues/173>
- Mozilla 2024 denetlenmiş mali tabloları (%86 tek müşteri) / audited financials — <https://stateof.mozilla.org/pdf/Mozilla%20Fdn%202024%20-%20AuditedFinancials.pdf>
- Mozilla'nın arama davası açıklaması / statement on the search case — <https://blog.mozilla.org/en/mozilla/internet-policy/defending-an-open-web/>

**Servo**

- Servo proje ve hedefler / project and goals — <https://servo.org/about/>, <https://servo.org/>
- crates.io yayımı ve LTS planı / crates.io publication and LTS plan — <https://www.phoronix.com/news/Servo-Embed-Crates-LTS>, <https://servo.org/blog/2026/04/13/servo-0.1.0-release/>
- LTS politikası ve garanti reddi / LTS policy and disclaimer — <https://book.servo.org/embedding/lts-release.html>
- Gömme belgeleri ("yetersiz") / embedding docs ("sparse") — <https://book.servo.org/embedding/overview.html>
- **Varsayılan kapalı özellikler (Service Worker dahil) / experimental (off-by-default) features** — <https://book.servo.org/design-documentation/experimental-features.html>
- Mimari ve sandbox / architecture and sandboxing — <https://book.servo.org/design-documentation/architecture.html>
- WPT istatistikleri ve katkıcı dağılımı / WPT stats and contributor breakdown — <https://blogs.igalia.com/mrego/servo-2025-stats/>
- Bağımsız güvenlik denetimi / independent security audit — <https://servo.org/blog/2025/02/26/servo-security-report/>
- Sovereign Tech Fund hibesi / grant — <https://www.igalia.com/2025/10/09/Igalia,-Servo,-and-the-Sovereign-Tech-Fund.html>
- Sponsorluk düzeyleri ve fon durumu / sponsorship tiers and funding — <https://servo.org/sponsorship/>, <https://opencollective.com/servo>
- İndirme sayfası (aarch64 Linux gecelik; "bankanıza girmeyin") / downloads — <https://servo.org/download/>
- Verso'nun arşivlenmesi / Verso archived — <https://github.com/versotile-org/verso>
- Kumo (WebKit birincil, Servo isteğe bağlı) / Kumo — <https://linmob.net/weekly-update-17-2026/>

**Ladybird**

- Yol haritası ve finansman / roadmap and funding — <https://ladybird.org/>
- SSS ve yol haritası / FAQ and roadmap — <https://github.com/LadybirdBrowser/ladybird/blob/master/Documentation/FAQ.md>
- Güvenlik politikası ve uygulanmamış korumalar / security policy and unimplemented protections — <https://github.com/LadybirdBrowser/ladybird/blob/master/SECURITY.md>
- Sandbox'ın inmesi / sandboxing landed — <https://ladybird.org/newsletter/2026-06-30/>
- GTK portunun silinmesi / GTK port removed — <https://ladybird.org/newsletter/2026-07-31/>
- **Kamuya açık PR'ların durdurulması / public PRs stopped** — <https://ladybird.org/posts/changing-how-we-develop-ladybird/>, <https://github.com/LadybirdBrowser/ladybird/blob/master/CONTRIBUTING.md>

**UnifiedPush / Web Push**

- UnifiedPush belirtiminin RFC 8291 ve RFC 8292 (VAPID) uyumuna güncellenmesi / spec updated for RFC 8291 and RFC 8292 (VAPID) — <https://f-droid.org/2026/01/08/unifiedpush-5-years.html>
- KUnifiedPush ve Web Push — <https://www.volkerkrause.eu/2025/04/18/kde-kunifiedpush-webpush.html>
- UnifiedPush geliştirici belgeleri / developer docs — <https://unifiedpush.org/developers/intro/>

**Motor kullanım payları / Engine usage shares**

- 2026 derlemeleri / 2026 compilations — <https://www.digitalapplied.com/blog/browser-market-share-2026-complete-statistics>, <https://commandlinux.com/statistics/web-browser-market-share/> (StatCounter türevi; yöntem farkları nedeniyle oranlar değişir / StatCounter-derived; figures vary by methodology)
