# RFC 0003: Uygulama Paket Formatı ve Manifest Standardı

**Türkçe** | [English](#english)

- **Durum:** Taslak
- **Tarih:** 2026-08-17
- **Yazar(lar):** OZERK kurucusu
- **Karşıladığı açık karar:** [RFC-0001](0001-karar-kaydi.md) A3 — Uygulama paket formatı
- **Lisans:** CC BY-SA 4.0

## Özet

OZERK App standardı **Flatpak'ı taban alır ve onu genişletir**; yeni bir paket formatı icat etmez. Uygulama, olduğu gibi geçerli bir Flatpak paketidir; OZERK'e özgü beyanlar (ağ erişim profili, izin verilen alan adları ve amaçları, telemetri, reklam, build doğrulama durumu, kaynak ve lisans) geliştiricinin yazdığı bir `ozerk.toml` dosyasından üretilir ve pakete iki yerde gömülür: Flatpak `metadata` dosyasındaki `[X-OZERK*]` grupları ve uygulama ağacındaki `/app/share/ozerk/manifest.toml`. Her ikisi de OSTree commit'inin içindedir; dolayısıyla depo imzası bu beyanları da kapsar. OZERK eklentilerini tanımayan bir sistemde paket sıradan bir Flatpak olarak çalışır.

Bu RFC ayrıca, manifesto §13'ün "beyan edilmeyen yetki sessizce kullanılamaz" kuralını uygulanabilir hâle getirmek için beyanları üç sınıfa ayırır — **zorlanan**, **build zamanında doğrulanan**, **yalnızca beyan** — ve bu ayrımın arayüzde gizlenmesini yasaklar.

## Motivasyon

Manifesto §13, her uygulamanın kurulumdan önce ağ erişim modelini, izin verilen alan adlarını, telemetri ve reklam durumunu, build doğrulama durumunu ilan etmesini şart koşar. Bugün kullanılan hiçbir Linux paket formatı bu alanları taşımaz. Flatpak'ın izin modeli sensör ve dosya erişimine odaklanır; ağ erişimi ise ikili bir anahtardır — vardır ya da yoktur. Manifesto §9.2'nin beş seviyeli ağ modelinin ikinci ve üçüncü seviyeleri (yalnızca izin verilen alan adları / yeni alan adlarında sor) Flatpak sözlüğünde ifade edilemez.

Karar şimdi alınmalıdır çünkü:

- `sdk/cli/templates/ozerk.toml` bugün geliştiriciye bir şema gösteriyor. Bu şema resmîleştirilmezse, ilk uygulamalar yazıldıktan sonra yapılacak her değişiklik kırıcı olacaktır.
- Paket formatı sandbox modelini, depoyu, mağaza arayüzünü ve SDK'yı birlikte belirler. Geç değiştirmek dört bileşeni birden yeniden yazmak demektir.
- Manifest modelinin en büyük tehdidi teknik değil, kavramsaldır: uygulama çalışırken kod indirip çalıştırabiliyorsa, kurulum öncesi beyan ilk günden anlamsızlaşır. Bu politikanın formatla birlikte tanımlanması gerekir.

Bu RFC'nin çözmediği iki şey vardır ve bunlar bilinçli olarak dışarıda bırakılmıştır: ağ zorlamasının teknik mimarisi ([RFC-0005](0001-karar-kaydi.md), A5) ve web uygulamalarının çalışacağı tarayıcı motoru ([RFC-0004](0001-karar-kaydi.md), A1). Bu RFC yalnızca **neyin beyan edileceğini ve nerede duracağını** tanımlar; **nasıl zorlanacağını** değil.

## Tasarım

### 1. Temel karar

> **OZERK App = Flatpak paketi + OZERK beyan katmanı.**

Bu, [RFC-0001](0001-karar-kaydi.md) D3'ün (upstream-öncelikli strateji) doğrudan uygulamasıdır. Flatpak'ın bize hazır verdiği şeyler yeniden yazılmayacak kadar değerlidir:

- bubblewrap tabanlı sandbox ve seccomp filtreleri,
- xdg-desktop-portal ile kullanıcı aracılı, çalışma zamanı izin modeli,
- D-Bus proxy (`xdg-dbus-proxy`) ile isim düzeyinde IPC denetimi,
- OSTree tabanlı, delta güncellemeli, imzalı depo modeli,
- runtime/SDK ayrımı ve paylaşılan bağımlılıklar,
- yıllardır saldırı yüzeyi incelenmiş, CVE geçmişi kamuya açık bir kod tabanı.

OZERK'in eksiği bunların hiçbiri değildir. Eksik olan **metadata**dır. Bir konteyner formatını yeniden icat ederek eksik bir metadata alanını doldurmak, yanlış katmanda çalışmaktır.

Bunun sonucu olarak kural şudur: **OZERK, bir Flatpak paketinin çalışması için gereken hiçbir alanı değiştirmez, kaldırmaz veya yeniden anlamlandırmaz.** OZERK yalnızca ekler. Bir OZERK paketi, OZERK olmayan bir masaüstünde `flatpak install` ile kurulur ve çalışır; OZERK beyanları orada yalnızca kullanılmayan veridir. Bu, manifesto §12'deki "uygulamasını Linux masaüstünde de çalıştırma" hakkının teknik karşılığıdır.

### 2. Beyan nerede durur

Üç yer arasında seçim yapmak yerine, her birine farklı bir rol verilir:

| Konum | İçerik | Kim yazar / okur |
|---|---|---|
| `ozerk.toml` (kaynak deposunda) | **Normatif kaynak.** Geliştiricinin elle yazdığı, gözden geçirilebilir, diff'lenebilir beyan. | Geliştirici yazar; `ozerk build` okur; kod inceleyicisi okur. |
| Flatpak `metadata` → `[X-OZERK*]` grupları | Türetilmiş, makine okuru özet. Uygulama açılmadan, paket açılmadan okunabilir. | `ozerk build` üretir; Guard ve kurulum akışı okur. |
| `/app/share/ozerk/manifest.toml` | `ozerk.toml`'un kanonik, çözülmüş (resolved) kopyası + `ozerk.lock` özeti. | `ozerk build` üretir; mağaza, denetçi ve `ozerk verify` okur. |

Üçü de OSTree commit'inin içindedir. Bu, "ayrı politika dosyası" alternatifine karşı belirleyici argümandır: **depo imzası beyanı da imzalar.** Ayrı bir dosya, ayrıca imzalanmadıkça bir ayna tarafından çıkarılabilir veya değiştirilebilir; ve paket ile beyan arasında sürüm kayması kaçınılmaz olur.

Tutarlılık şöyle sağlanır: `/app/share/ozerk/manifest.toml`'un kanonik serileştirmesinin SHA-256 özeti `[X-OZERK]` grubuna `manifest-digest` olarak yazılır. İki kopya çelişirse paket **geçersizdir**; Guard uygulamayı çalıştırmaz ve kullanıcıya paketin bozuk veya kurcalanmış olduğu söylenir. Sessizce birini tercih etmek yoktur.

Teknik dayanak: Flatpak'ın `metadata` dosyası `.desktop` benzeri bir anahtar-değer dosyasıdır ve `flatpak build-finish --metadata=GRUP=ANAHTAR=DEĞER` ile herhangi bir grup yazılabilir. Flatpak'ın kendisi de aynı yolu `X-DConf` için kullanır; `X-` önekli gruplar bu ekosistemde yerleşik bir uzatma noktasıdır. Aynı şekilde flatpak-builder manifestlerinde `x-` önekli özellikler build tarafından yok sayılır (`x-checker-data` bu konvansiyonun bilinen örneğidir), dolayısıyla build manifestine iz bırakmak da mümkündür.

### 3. Flatpak ve portalların manifesto §9.1'i ne kadar karşıladığı

Manifesto §9.1 altı seçenek ister. Karşılıklar dürüstçe şöyledir:

| §9.1 seçeneği | Bugünkü karşılığı | Değerlendirme |
|---|---|---|
| **Reddet** | İzin `finish-args`'ta hiç verilmez; portal isteği permission store'da `no` olarak saklanır. | **Karşılanıyor.** |
| **Her zaman izin ver** | Permission store'da `yes`. | **Karşılanıyor.** |
| **Yalnızca seçilen öğelere izin ver** | Dosyalar için belge portalı (document portal) tam olarak budur: uygulama dosya sistemini görmez, kullanıcının seçtiği dosya için bir handle alır. | **Dosyada karşılanıyor.** Kişiler ve takvim için upstream'de portal **yoktur**; bugün tek denetim, `org.gnome.evolution.dataserver.*` gibi D-Bus adlarına erişimi topluca vermek veya vermemektir. Yani "seçilen kişiler" seviyesi yoktur. |
| **Bir defa izin ver** | Dosya seçici ve OpenURI doğaları gereği tek seferliktir. Kamera ve konum için portal kararı kalıcı kayda yazma eğilimindedir. | **Kısmen.** Genel bir "bu çağrı için bir kez" semantiği portal API'sinin tamamında yoktur. |
| **Yalnızca uygulama açıkken izin ver** | ScreenCast portalında geçici (transient) izin kavramı vardır: oturum yalnızca uygulama çalıştığı sürece geri yüklenebilir. | **Kısmen.** Bu, tek bir portalda var olan bir davranıştır; tüm hassas portallar için ortak bir "ömrü uygulama örneğine bağlı izin" kavramı tanımlı değildir. |
| **Belirli süre izin ver** | Yok. Süre sınırlı / kendiliğinden sönen izinler upstream'de açık bir istek olarak durmaktadır (xdg-desktop-portal issue #981). | **Karşılanmıyor.** |

Sonuç: portal modeli, manifesto §9.1'in **omurgasını** doğru kurar — izin, paketin talep ettiği statik bir liste değil, kullanıcı aracılığıyla verilen dinamik bir haktır ve uygulama izni kendi arayüzünde soramaz. Eksik olan, izne **zaman ve kapsam boyutu** eklemektir.

OZERK'in yapması gereken, D3 gereği, bu eksiği kendi başına doldurmak değil, upstream'e taşımaktır. Bu RFC şunu önerir:

- **Kısa vade:** izin ömrü (`once` / `while-running` / `until` / `always`) OZERK tarafında permission store girdilerine yazılan bir OZERK uzantısı olarak tutulur ve OZERK'in portal backend'i tarafından uygulanır. Bu, protokolü değiştirmeden çalışır çünkü izin kararını veren taraf zaten backend'dir.
- **Orta vade:** aynı model, süre alanı ve geçici izin semantiği olarak xdg-desktop-portal'a önerilir. Kabul edilirse OZERK uzantısı kaldırılır.
- **Kişiler ve takvim:** bir Contacts ve bir Calendar portalı önerisi hazırlanır. Bunlar hazır olana kadar `permissions.contacts` ve `permissions.calendar` alanları **kaba taneli** olarak zorlanır (D-Bus adı verilir veya verilmez) ve manifest bu kabalığı açıkça belirtir. "Seçilen kişiler" iddiası, portal olmadan **edilmez**.

### 4. Ağ erişimi: §9.2'nin beş seviyesi

Flatpak'ta ağ ikili bir izindir: `--share=network` verilirse uygulama tüm internete erişir, verilmezse ağ namespace'i izole edilir. Alan adı düzeyinde bir kısıtlama sözlüğü yoktur ve bu bilinen bir sınırdır. Dolayısıyla eşleme şudur:

| §9.2 profili | `ozerk.toml` değeri | Flatpak karşılığı | Zorlama durumu |
|---|---|---|---|
| 1 — Ağ erişimi yok | `none` | `--share=network` **verilmez** | **Tam zorlanır.** Çekirdek düzeyinde namespace izolasyonu; en güçlü garanti. |
| 2 — Yalnızca izin verilen alan adları | `allowlist` | Flatpak'ta karşılığı yok | Guard'a bağlı ([RFC-0005](0001-karar-kaydi.md)). Bu RFC yalnızca beyanı tanımlar. |
| 3 — Yeni alan adlarında sor | `ask` | Flatpak'ta karşılığı yok | Guard'a bağlı. |
| 4 — Genel internet erişimi | `full` | `--share=network` | Zorlanır (kapı ya açıktır ya kapalı); ama bir kısıtlama değil, kısıtlamanın yokluğudur. |
| 5 — Ham ağ erişimi | `raw` | Flatpak sandbox'ı `CAP_NET_RAW` bırakmaz | **Sandbox içinde verilemez.** Bu profil yalnızca A sınıfı sistem uygulamalarına ve kullanıcının açıkça onayladığı istisnalara (ör. VPN, ağ tanılama) açıktır; normal uygulama deposunda kabul edilmez. |

Bunun dürüst özeti: **bugün Flatpak ile 1 ve 4 gerçek, 2 ve 3 vaattir.** Bu RFC 2 ve 3'ü manifest sözlüğüne yazar ki Guard hazır olduğunda uygulamalar zaten doğru beyanı taşısın; ama arayüz, Guard gelene kadar bu profilleri "beyan edilmiş, henüz zorlanmıyor" olarak göstermek zorundadır. Aksi hâli, manifestonun dürüstlük taahhüdünün ihlalidir.

İki ek tasarım kararı:

**Alan adı beyanı amaç taşır.** `allowed_domains` yalnızca bir liste değil, her girdisi bir amaç açıklaması olan bir tablodur. "api.example.com" tek başına kullanıcıya hiçbir şey anlatmaz; "api.example.com — hesap girişi ve senkronizasyon" anlatır. Bu açıklama mağazada ve Gizlilik Merkezi'nde gösterilir.

**C ve D sınıfı için allowlist TLS'i kırmadan zorlanabilir.** Web uygulamaları için ağ isteklerini yapan taraf, OZERK'in kendi web runtime'ıdır. Runtime, isteği kurmadan önce hedef origin'i beyan listesiyle karşılaştırabilir. Bu, şifrelemenin **üstünde** bir denetimdir; sahte sertifika gerektirmez ve manifesto §9.2'nin yasağını ihlal etmez. Native uygulamalarda böyle bir kaldıraç yoktur — bu, C sınıfının B sınıfına göre ölçülebilir bir güvenlik avantajıdır ve bu RFC bunu web uygulamalarını teşvik etmek için bir gerekçe olarak kaydeder.

### 5. Dört uygulama sınıfının tek formatta temsili

`app.class` alanı manifesto §8.2'nin dört sınıfını taşır. Ortak sözlük değişmez; değişen, alanların hangisinin anlamlı olduğu ve zorlamanın nerede gerçekleştiğidir.

**A — Sistem uygulaması (`system`).** İşletim sistemi imajıyla dağıtılır; Flatpak olarak paketlenmeyebilir. Buna rağmen `ozerk.toml` taşımak **zorundadır** ve Gizlilik Merkezi'nde diğerleriyle aynı sözlükle görünür. Fark açıkça yazılır: sistem uygulamasının manifesti bir **kısıtlama** değil, bir **ifşa**dır — bu bileşenler güvenilen hesaplama tabanının parçasıdır ve kendilerini sınırlayan sandbox'ın dışındadır. Sayılarının sınırlı tutulması (§8.2/A) bu yüzden bir güvenlik kuralıdır, estetik bir tercih değil.

**B — Native sandbox uygulaması (`native`).** Temel durum. `ozerk.toml` → Flatpak `finish-args` + `[X-OZERK*]`. Anlatılacak özel bir şey yoktur; format bu sınıf için tasarlanmıştır.

**C — Paketlenmiş web uygulaması (`web-packaged`).** Paket, HTML/CSS/JS/Wasm varlıklarını içeren bir Flatpak'tır; Flatpak `runtime` alanı OZERK web runtime'ını gösterir (hangi motor olduğu A1/[RFC-0004](0001-karar-kaydi.md)'e bağlıdır). Manifest ek olarak şunları söyler:

- `web.entrypoint` — paket içindeki başlangıç belgesi (uzak bir URL **olamaz**),
- `web.remote_code = false` — çalıştırılan kodun tamamı pakettedir,
- `web.csp` — runtime'ın zorlayacağı içerik güvenlik politikası tabanı,
- `web.allow_eval` — `eval` / `new Function` kullanımı beyanı.

`web.remote_code = false` beyanı **zorlanabilir**: runtime, paket dışı origin'lerden betik yüklenmesini reddeder. Bu, C sınıfının "bağımsız doğrulanabilir" (§8.2/C) olma iddiasının teknik dayanağıdır.

**D — Hosted web uygulaması (`web-hosted`).** Paket, uzak bir origin'e işaret eden ince bir profildir. Manifest şunları taşımak zorundadır:

- `web.origin` — uygulamanın bağlı olduğu tek origin,
- `web.remote_code = true` — **bu alan D sınıfında değiştirilemez; `false` yazılamaz**,
- `build.verification = "not-applicable"` — çalışan kod bu pakette olmadığı için yeniden üretilebilirlik kavramı burada anlamsızdır ve öyle olduğu yazılır,
- `network.mode` en az `allowlist`, listede `web.origin` ve varsa açıkça beyan edilmiş yardımcı origin'ler.

Manifesto §8.2/D'nin "kodun uzak sunucu tarafından değiştirilebildiği kullanıcıya açıkça bildirilir" şartı şöyle karşılanır: `web.remote_code = true` beyanı, mağaza sayfasında ve **ilk açılışta uygulamanın kendi penceresi içinde** kalıcı bir uyarı üretir; bu uyarı uygulama tarafından bastırılamaz. Ayrıca güncelleme akışında bir tuhaflık kaydedilmelidir: hosted uygulamanın davranışı, paketin sürümü hiç değişmeden değişebilir. Dolayısıyla D sınıfı uygulamalar için "sürüm" kullanıcıya bir güvence olarak sunulamaz; mağaza bunu açıkça söyler.

Buna bağlı bir depo sorusu açıktır (aşağıya bakınız): §14.1 OZERK Free "kaynak koddan derlenebilirlik" ister; hosted bir uygulamada derlenen şey kabuktur, hizmet değildir. Bu RFC, D sınıfı uygulamaların OZERK Free'de yer alıp alamayacağını karara bağlamaz.

### 6. §13'ün zorlanabilirlik ayrımı

Bu, RFC'nin en önemli bölümüdür. Manifesto §13 "beyan edilmeyen yetki sessizce kullanılamaz" der. Bu cümle, ancak hangi beyanların gerçekten zorlanabildiği açıkça ayrıldığında dürüst kalır. Beyanlar üç sınıfa ayrılır:

**Sınıf E — Zorlanan (Enforced).** Sistem, beyan edilmemiş davranışı teknik olarak engeller. Uygulama, beyanını aşarak bunu yapamaz.

| Alan | Zorlama mekanizması |
|---|---|
| Ağ profili 1 (`none`) | Ağ namespace izolasyonu |
| Ağ profili 4 (`full`) | `--share=network` verilmesi/verilmemesi |
| Dosya sistemi erişimi | Flatpak `filesystems` + belge portalı |
| Kamera, mikrofon, ekran | Portal + PipeWire; cihaz düğümü sandbox'ta yok |
| Konum hassasiyeti | Konum portalı; `none`/`country`/`city`/`neighborhood`/`street`/`exact` seviyeleri protokolde tanımlıdır |
| Bildirim | Bildirim portalı |
| D-Bus erişimi (kişi/takvim dahil, kaba taneli) | `xdg-dbus-proxy` isim politikası |
| Cihazlar (dri, usb, input) | Flatpak `devices` |
| Paketlenmiş web uygulamasında uzak betik | Web runtime CSP zorlaması |
| Ağ profili 2 ve 3 | **Kısmen ve gelecekte** — Guard'a bağlı; DoH, ECH ve paylaşımlı CDN'ler alan adı kesinliğini sınırlar ([RFC-0005](0001-karar-kaydi.md)) |
| Arka planda çalışma | **Kısmen** — Background portalı + cgroup denetimi; tam bir garanti değildir |

**Sınıf V — Build zamanında doğrulanan (Verified).** Çalışma zamanında zorlanmaz; yayımdan önce bağımsız olarak sınanır ve sonucu kaydedilir.

- Build doğrulama durumu (yeniden üretilebilirlik — §8),
- Kaynak kodu adresinin yayımlanan ikiliye karşılık gelmesi,
- Yazılım malzeme listesi (SBOM) ve bağımlılık kapanışı,
- Bilinen takip kütüphanelerinin ikilide bulunup bulunmadığı (statik tarama),
- Lisans beyanının kaynak ağacıyla tutarlılığı.

**Sınıf B — Yalnızca beyan (Beyan).** Sistem bunları ne engelleyebilir ne doğrulayabilir. Yalnızca **çelişkisi gözlemlenebilir**.

- **Telemetrinin niteliği:** hangi veri toplanıyor, ne amaçla, ne kadar saklanıyor, kiminle paylaşılıyor. OZERK bir bağlantının olduğunu, hedefini ve boyutunu görebilir; **içeriğini göremez** — çünkü §9.2 sahte sertifika yerleştirmeyi yasaklar. Bu bilinçli bir takastır ve sonucu budur.
- **Reklam beyanı:** bilinen reklam uç noktalarına yapılan bağlantı gözlemlenebilir; ancak reklamın *olmadığı* kanıtlanamaz.
- **Üçüncü taraflarla veri paylaşımı** ve sunucu tarafındaki her davranış.
- **Amaç açıklamaları:** bir alan adının beyan edilen amacının doğru olup olmadığı.

Bu ayrımdan çıkan üç bağlayıcı kural:

1. **Arayüz üç sınıfı görsel olarak ayırmak zorundadır.** "Zorlanıyor", "Doğrulandı", "Beyan" etiketleri aynı ağırlıkta gösterilemez. Manifesto §9.3'ün "OZERK yalnızca gözlemleyebildiğini ve doğrulayabildiğini söyleyecektir" ilkesi, burada somut bir arayüz kuralına dönüşür.
2. **Otomatik güncelleme kuralı sınıfa göre değişir.** Sınıf E beyanlarında genişleme (yeni izin, daha geniş ağ profili, yeni alan adı) otomatik güncellemeyi **durdurur** ve kullanıcıya izin farkı gösterilir (§10.3). Sınıf B beyanlarındaki değişiklik (ör. telemetri metninin değişmesi) güncellemeyi durdurmaz ama kullanıcıya bildirilir ve kayda geçer.
3. **Sınıf B'de yalancılığın yaptırımı teknik değil, depo politikasıdır.** Beyanla gözlenen davranış çeliştiğinde (§13 son cümlesi) sonuç, uygulamanın etiketlenmesi ve gerekirse depodan çıkarılmasıdır. Bu yaptırımın süreci bu RFC'nin kapsamında değildir; depo yönetişimine aittir.

### 7. Çalışma zamanında kod indirme ve çalıştırma

Bu politika olmadan manifest modeli ilk günden delinir: uygulama hiçbir şey beyan etmez, küçük bir yükleyici gönderir, ilk açılışta asıl yükünü indirir. Kurulum öncesi beyanın tamamı buharlaşır.

Önerilen kurallar:

**7.1. Paket dışı yerel kod çalıştırma yasaktır ve teknik olarak engellenir.** Flatpak'ta `/app` zaten salt okunurdur. OZERK buna ek olarak uygulamanın yazılabilir dizinlerini (`~/.var/app/<id>` karşılıkları ve sandbox içi geçici alanlar) **`noexec`** ile bağlar. Böylece indirilen bir ELF ikilisi `exec` edilemez.

**7.2. Bu engelin sınırı açıkça yazılır.** `noexec`, **yorumlanan kodu durdurmaz**: indirilen bir Python, Lua veya JavaScript dosyası, uygulamanın zaten paketlediği yorumlayıcı tarafından çalıştırılabilir. JIT derleyicileri (her JavaScript motoru dahil) `PROT_EXEC` bellek eşlemesi kullanır; genel bir W^X politikası web runtime'ını da çalışamaz hâle getirir. Dolayısıyla OZERK **"uygulama yeni kod indiremez" demeyecektir.** Diyeceği şudur: *paketlenmemiş yerel ikili çalıştıramaz ve paketlenmiş web uygulamasında uzak betik yükleyemez.*

**7.3. Beyan alanı: `code_delivery`.** Üç değer alır:

- `package-only` — çalıştırılan tüm kod pakettedir. En güçlü beyan; C sınıfında zorlanabilir, B sınıfında kısmen.
- `interpreted-extensions` — uygulama, kullanıcının açıkça kurduğu eklenti/betik yükleyebilir (metin düzenleyiciler, geliştirici araçları). Eklenti kaynağı ve kullanıcı onayı akışı beyan edilir.
- `remote` — uygulama uzaktan kod alır. Bu değer, uygulamayı sınıfından bağımsız olarak **hosted uyarı sınıfına** sokar: kullanıcıya, çalışan kodun mağazada incelenen kod olmayabileceği söylenir.

Beyan edilmemişse varsayılan `package-only`'dir ve aksi gözlemlenirse §13 ihlali sayılır.

**7.4. `extra-data` sınırlı olarak kabul edilir.** Flatpak'ın `extra-data` mekanizması, kurulum sırasında indirilecek veriyi **SHA-256 ile sabitler** — dolayısıyla "keyfi kod" değildir; indirilen şey belirlidir ve değişirse kurulum başarısız olur. OZERK Free'de `extra-data` yalnızca (a) yeniden dağıtılamayan varlıklar (ör. lisanslı yazı tipi, model dosyası) için ve (b) çalıştırılabilir kod içermemek şartıyla kabul edilir. Her `extra-data` girdisi manifestte amacı ve kaynağı ile listelenir.

**7.5. Sistem uygulamaları istisna değildir.** A sınıfı bileşenler de `code_delivery` beyan eder. İstisna, güncelleme mekanizmasının kendisidir; o da imzalı sistem güncellemesi yoluyla çalışır (§10.3).

### 8. İmzalama, depo ve yeniden üretilebilirlik

**8.1. Depo modeli.** OZERK depoları OSTree `archive-z2` biçiminde tutulur ve Flathub'ın da kullandığı **flat-manager** ile işletilir. Bu, delta güncellemeleri, çoklu mimari ve federe depo (§14.3: herkes kendi deposunu çalıştırabilir) gereksinimlerini karşılayan, üretimde denenmiş bir yoldur.

**8.2. İmza zinciri.** OSTree her commit'i ve özet (summary) dosyasını imzalar. Bugün stok `flatpak` istemcisiyle çalışan yol GPG'dir. OSTree ayrıca `ostree sign` ile ed25519 destekler ve bunun Flatpak tarafındaki karşılığı upstream'de yıllardır süren bir çalışmadır (`flatpak/flatpak#4170` hâlâ açıktır). Karar:

- OZERK **GPG ile başlar**, çünkü değiştirilmemiş bir Flatpak istemcisiyle uyumluluk D3'ün gereğidir;
- ed25519 desteği upstream'de tamamlanana kadar OZERK **fork tutmaz**, katkı verir;
- geçiş, imza türü paketin kendisinde değil depo yapılandırmasında yaşadığı için formatı kırmaz.

Beyanlar commit'in içinde olduğundan (§2), bu imza zinciri beyanları da kapsar. Ayrı bir "manifest imzası" kavramına gerek yoktur.

**8.3. Şeffaflık kaydı.** §14.4'ün istediği şeffaflık kaydı, ekleme-yapılabilir (append-only) bir kayıt olarak tanımlanır. Her yayım için en az: uygulama kimliği, sürüm, OSTree commit özeti, `manifest-digest`, sınıf E beyanlarının kanonik özeti. Bu kayıt, izin farkı (§10.3) hesaplamasının ve "bu sürüm gerçekten yayımlandı mı" sorusunun tek doğruluk kaynağıdır.

**8.4. Yeniden üretilebilirlik bir boole değildir.** Mevcut `sdk/cli/templates/ozerk.toml` taslağındaki `reproducible = false` alanı yetersizdir. flatpak-builder genel olarak yeniden üretilebilir değildir; çözülmüş bağımlılık kapanışını sabitleyen bir kilit dosyası kavramı yoktur ve uzantılar tam commit'e sabitlenmez. Bu gerçeği bir `true/false` alanıyla gizlemek yerine, beş kademeli bir durum tanımlanır:

| `build.verification` | Anlamı |
|---|---|
| `reproducible` | Bağımsız ikinci build, uygulama ağacının bit düzeyinde aynısını üretti. |
| `equivalent` | İkinci build yalnızca belgelenmiş, anlam taşımayan farklarla (zaman damgaları, build yolları, build-id) ayrıldı; normalleştirilmiş ağaç özeti eşleşti. Normalleştirme kuralları kamuya açıktır. |
| `source-built` | Depo, yayımlanan kaynaktan izole ortamda derledi; bağımsız ikinci build yok. |
| `unverified` | İkili geliştirici tarafından sağlandı. |
| `not-applicable` | Çalışan kod pakette değil (D sınıfı). |

Bu alan **geliştirici tarafından yazılmaz**; depo tarafından üretilir ve `ozerk.toml`'daki değer yalnızca bir hedef beyanıdır. Manifestte `build.verification` alanı `[build]` içinde geliştiricinin *talebi*, `[X-OZERK]` içinde deponun *tespiti* olarak ayrı taşınır.

**8.5. Zor durumlar dürüstçe kaydedilir.** Yeniden üretilebilirlik teknoloji seçimine göre çok değişir:

- **Rust ve Go:** görece iyi; sabit araç zinciri sürümü ve `--remap-path-prefix` benzeri önlemlerle `reproducible` erişilebilir hedeftir.
- **C/C++ (özellikle autotools):** zaman damgaları, `__FILE__` yolları ve bağlayıcı sırası nedeniyle çoğunlukla `equivalent` seviyesinde kalır.
- **Wasm:** araç zinciri sabitlendiğinde çıktı deterministiktir; asıl zorluk motorun kendisi değil, npm/cargo bağımlılık kapanışını sabitlemektir. Kilit dosyası zorunluluğu bu yüzden vardır.
- **Flutter:** en zoru. Kendi motorunu paketler, AOT snapshot'ları build ortamına duyarlıdır ve araç zinciri sürüm sabitleme pratiği zayıftır. Bu RFC, Flutter uygulamalarının başlangıçta gerçekçi olarak `source-built` veya `equivalent` seviyesinde kalacağını **kabul eder ve yazar**; "yeniden üretilebilir" etiketi ölçülmeden verilmez.

Bunun sonucu olarak `ozerk build`, çözülmüş bağımlılık kapanışını `ozerk.lock` dosyasına yazmak zorundadır; bu dosya olmadan hiçbir uygulama `reproducible` veya `equivalent` etiketi alamaz.

### 9. Taslak şema

Aşağıdaki örnek, `sdk/cli/templates/ozerk.toml` ile alan adları bakımından uyumludur ve onu tamamlar. Bu şema **taslaktır**; RFC kabul edilene kadar bağlayıcı değildir.

```toml
# SPDX-License-Identifier: Apache-2.0
# ozerk.toml — OZERK uygulama manifesti / OZERK application manifest
# Şema sürümü. Kırıcı değişikliklerde artar.
schema = 1

[app]
id      = "org.example.notlar"          # ters alan adı; Flatpak app id ile aynıdır
version = "1.4.0"
name    = "Notlar"                       # görünen ad; ayrıntı AppStream metainfo'dadır
source  = "https://git.example.org/notlar"
license = "GPL-3.0-or-later"             # SPDX tanımlayıcısı

# Manifesto §8.2'deki dört sınıf:
# "system" (A) | "native" (B) | "web-packaged" (C) | "web-hosted" (D)
class = "native"

[runtime]
# B sınıfı için Flatpak runtime; C/D için OZERK web runtime'ı.
base    = "org.gnome.Platform"
version = "48"
sdk     = "org.gnome.Sdk"

# ---------------------------------------------------------------------------
# İZİNLER — hepsi varsayılan olarak kapalıdır. (Sınıf E: zorlanır)
# ---------------------------------------------------------------------------
[permissions]
# Dosya erişimi. "none" önerilir: uygulama dosya sistemini görmez,
# kullanıcının seçtiği dosyayı belge portalı üzerinden alır.
# "none" | "portal" | "xdg-documents" | "home" | "host"
files = "none"

camera     = false
microphone = false

# Kişi ve takvim: bugün yalnızca KABA TANELİ zorlanır (D-Bus adı verilir/verilmez).
# "Seçilen kişiler" seviyesi upstream'de portal olmadığı için İDDİA EDİLMEZ.
contacts = false
calendar = false

# Konum hassasiyeti; konum portalının seviyeleriyle birebir eşleşir.
# "none" | "country" | "city" | "neighborhood" | "street" | "exact"
location = "none"

notifications = false

# Arka planda çalışma. Kısmen zorlanır (Background portalı + cgroup).
background = false

# İzin ömrü tercihleri: uygulamanın KABUL EDEBİLECEĞİ en dar ömür.
# Kullanıcı her zaman daha darını seçebilir; uygulama daha genişini dayatamaz.
# "once" | "while-running" | "timed" | "always"
lifetime_hint = "while-running"

# Doğrudan cihaz erişimi (nadiren gerekir).
devices = []                              # örn. ["dri"]

# D-Bus adları; her biri gerekçesiyle listelenir.
[[permissions.dbus]]
name   = "org.freedesktop.secrets"
access = "talk"                           # "see" | "talk" | "own"
reason = "Parolaları sistem anahtarlığında saklamak için."

# ---------------------------------------------------------------------------
# AĞ — manifesto §9.2'nin beş profili
# ---------------------------------------------------------------------------
[network]
# "none"      (1) — zorlanır: ağ namespace'i yok
# "allowlist" (2) — Guard'a bağlı (RFC-0005); bugün beyan düzeyinde
# "ask"       (3) — Guard'a bağlı
# "full"      (4) — zorlanır: kısıtlama yok
# "raw"       (5) — sandbox içinde verilemez; yalnızca sistem/istisna
mode = "allowlist"

# Her hedef bir amaç açıklamasıyla birlikte listelenir. Açıklama,
# mağazada ve Gizlilik Merkezi'nde kullanıcıya gösterilir.
[[network.allowed]]
domain  = "sync.example.org"
purpose = "Notların hesaplar arası eşitlenmesi."

[[network.allowed]]
domain  = "example.org"
purpose = "Yardım belgeleri ve sürüm notları."

# Uygulama LAN/mDNS keşfi yapıyorsa ayrıca beyan edilir.
local_discovery = false

# ---------------------------------------------------------------------------
# KOD TESLİMİ — §7
# ---------------------------------------------------------------------------
[code]
# "package-only" | "interpreted-extensions" | "remote"
delivery = "package-only"

# Kurulum sırasında indirilen, SHA-256 ile sabitlenmiş veri (varsa).
# Çalıştırılabilir kod içeremez.
extra_data = []

# ---------------------------------------------------------------------------
# WEB — yalnızca class = "web-packaged" veya "web-hosted" iken
# ---------------------------------------------------------------------------
# [web]
# entrypoint  = "index.html"    # C sınıfı: paket içi; uzak URL olamaz
# origin      = ""              # D sınıfı: tek uzak origin; C sınıfında boş
# remote_code = false           # D sınıfında zorunlu olarak true
# csp         = "default-src 'self'; connect-src 'self' https://sync.example.org"
# allow_eval  = false

# ---------------------------------------------------------------------------
# BEYANLAR — Sınıf B: zorlanamaz, yalnızca çelişkisi gözlemlenebilir.
# Arayüz bunları "Beyan" etiketiyle, zorlanan izinlerden AYRI gösterir.
# ---------------------------------------------------------------------------
[declarations]
# "none" | "crash-only" | "usage" | "personal"
telemetry = "crash-only"

# telemetry != "none" ise aşağıdakiler zorunludur.
[declarations.telemetry_detail]
endpoint    = "sync.example.org"          # network.allowed içinde olmalıdır
data        = "Çökme yığın izi, uygulama sürümü, işletim sistemi sürümü."
identifier  = "none"                      # "none" | "random-per-install" | "account"
optional    = true                        # kullanıcı kapatabilir mi?
default_off = true                        # varsayılan kapalı mı?
retention   = "90 gün"

# "none" | "static" | "personalized"
ads = "none"

# Üçüncü taraflarla veri paylaşımı beyanı.
third_party_sharing = "none"

# ---------------------------------------------------------------------------
# BUILD — [build] geliştiricinin HEDEFİ; gerçek durum depo tarafından
# üretilir ve pakete [X-OZERK] içinde yazılır. İkisi karıştırılmaz.
# ---------------------------------------------------------------------------
[build]
# "reproducible" | "equivalent" | "source-built" | "unverified" | "not-applicable"
verification_target = "equivalent"
source_ref = "v1.4.0"                     # imzalı etiket önerilir
lockfile   = "ozerk.lock"                 # kilit dosyası olmadan doğrulama iddiası edilemez
sbom       = "sbom.spdx.json"
```

Bu dosyadan üretilen Flatpak `metadata` özeti şu biçimdedir (`flatpak build-finish --metadata=GRUP=ANAHTAR=DEĞER` ile yazılır):

```ini
[Context]
shared=network
sockets=wayland;fallback-x11;
filesystems=

[Session Bus Policy]
org.freedesktop.secrets=talk

[X-OZERK]
schema=1
class=native
network-mode=allowlist
code-delivery=package-only
manifest-digest=sha256:6f1c…
build-verification=equivalent          # depo tarafından yazılır

[X-OZERK Network]
allowed=sync.example.org;example.org;

[X-OZERK Declarations]
telemetry=crash-only
ads=none
```

`[Context]` içindeki `shared=network`, profil 2'nin bugün Flatpak sözlüğünde karşılığı olmadığı içindir; gerçek kısıtlama `X-OZERK` bilgisine dayanarak Guard tarafından uygulanır. Bu kayma bilinçlidir ve belgelenmiştir: OZERK olmayan bir sistemde uygulama tam ağ erişimiyle çalışır, çünkü orada Guard yoktur ve OZERK bu sistemler adına bir güvence veremez. Mağaza, `allowlist` beyanının yalnızca OZERK üzerinde zorlandığını yazar.

### 10. Uyumluluk ve araçlar

- `ozerk init` bu şemayı üretir; `ozerk permissions` beyan ile üretilen `finish-args`'ı yan yana gösterir.
- `ozerk build` `ozerk.toml` → Flatpak manifesti + `metadata` + `/app/share/ozerk/manifest.toml` + `ozerk.lock` üretir.
- `ozerk verify` üç kopyanın tutarlılığını, `manifest-digest`'i, kilit dosyasını ve mümkünse ikinci build'i sınar.
- Mevcut bir Flatpak uygulaması OZERK'e `ozerk.toml` eklenerek taşınır; kod değişikliği gerekmez. Bu, ekosistemi sıfırdan başlatmama argümanının pratik karşılığıdır.
- `ozerk.toml` içermeyen bir Flatpak da kurulabilir; ancak mağaza ve Gizlilik Merkezi onu "beyan yok" olarak etiketler ve en dar varsayılanlarla çalıştırır. Yasaklamak yerine etiketlemek, §8.3'ün yaklaşımıyla tutarlıdır.

## Alternatifler

**1. Sıfırdan özgün bir format.** Manifesto ihtiyaçlarını en doğrudan karşılayan yol budur ve tasarım özgürlüğü tamdır. Reddedilme gerekçesi: D3 ile doğrudan çelişir; ve daha önemlisi, yanlış sorunu çözer. Eksik olan konteyner değil metadata'dır. Özgün format, sandbox'ı, portal modelini, depo altyapısını, delta güncellemeyi ve on yıllık bir güvenlik geçmişini yeniden yazmayı gerektirir; ekosistem sıfır uygulamayla başlar ve geliştirici Linux masaüstünde de çalışabilme hakkını (§12) kaybeder.

**2. Saf Flatpak + ayrı politika dosyası.** Standarda hiç dokunmaz, en az sürtünmeli yoldur. Reddedilme gerekçesi: beyan ile paket birbirinden kopar. Ayrı dosya, ayrıca imzalanmadıkça bir aynada değiştirilebilir veya düşürülebilir; sürüm kayması kaçınılmazdır; ve "paketle birlikte gelen beyan" fikri, kurulum öncesi güvencenin özüdür. `[X-OZERK*]` yolu aynı düşük sürtünmeyi, imza kapsamını kaybetmeden verir.

**3. Snap.** Sıkı sınırlama, ticari destekli araç zinciri ve olgun bir güncelleme altyapısı sunar. Reddedilme gerekçesi: mağaza ve dağıtım katmanı pratikte tek bir şirketin denetimindedir; federe, herkesin kendi deposunu çalıştırabildiği bir model (§14.3) Snap'in tasarım varsayımı değildir. Ayrıca sınırlama AppArmor'a dayanır ve dağıtımdan dağıtıma değişir. Kullanıcı egemenliği iddiasında bulunan bir platform için dağıtım katmanındaki merkezîlik kabul edilemez.

**4. AppImage.** Tek dosya, kurulum yok, taşınabilir. Reddedilme gerekçesi: varsayılan bir sandbox'ı, standart bir imza ve güncelleme altyapısı, bir izin sözlüğü yoktur. Manifesto §13'ün istediği her şeyin sıfırdan inşa edilmesi gerekir — yani seçenek 1'e, üstelik daha zayıf bir tabandan geri dönülür.

**5. OCI / konteyner imajı.** Ciddiye alınmayı hak eder: araç zinciri her yerde, kayıt defteri altyapısı olgundur ve Flatpak zaten OCI üzerinden dağıtımı destekler. Reddedilme gerekçesi: OCI bir **taşıma** biçimidir, masaüstü uygulaması modeli değildir. Portal entegrasyonu, oturum bütünleşmesi, kullanıcı aracılı izin, delta güncelleme ve OSTree'nin dosya düzeyinde tekilleştirmesi yoktur; katman tabanlı imajlar sınırlı depolamaya sahip bir telefonda ciddi israf yaratır. Buna karşılık **taşıma seçeneği olarak korunur**: kurumsal veya hava boşluklu dağıtımda OCI kayıt defteri üzerinden dağıtım, format değişmeden mümkündür.

**6. Android APK benzeri bir format.** Kurulum öncesi izin beyanı fikri tam olarak §13'ün istediği şeydir ve APK bu fikrin en yaygın örneğidir. İki nedenle reddedilir. Birincisi: benimsemek, Android çalışma zamanını da benimsemek demektir; oysa manifesto §11 Android'i bir misafir olarak konumlandırır ve uyumluluk ihtiyacı zaten Bridge/Waydroid ile karşılanır. İkincisi ve daha önemlisi: APK izin modelinin sicili bir uyarıdır, örnek değil. İzinler kaba tanelidir, büyük bölümü yalnızca beyan düzeyindedir ve ekosistem "her şeyi iste, kullanıcı zaten kabul eder" dengesine oturmuştur. OZERK'in ayrımı (§6) tam olarak bu sonucu engellemek içindir.

**7. Hiçbir şey yapmamak — kararı ertelemek.** Savunulabilir bir seçenektir: platform kodu henüz yoktur ve erken şema hataları pahalıdır. Reddedilme gerekçesi: CLI bugün geliştiriciye bir `ozerk.toml` üretiyor. Karar ertelendikçe, resmîleştirilmemiş bir şema fiilî standarda dönüşür — kararı ertelemek onu almamak değil, belgelemeden almaktır.

## Açık Sorular

1. **Ağ profili 2 ve 3, Guard'dan önce arayüzde nasıl gösterilecek?** "Beyan edildi, henüz zorlanmıyor" ifadesi dürüsttür ama kullanıcı için anlamsız olabilir. Bu profiller Guard hazır olana kadar depoda kabul edilmeli mi, yoksa yalnızca 1 ve 4 mü kabul edilmeli?
2. **D sınıfı uygulamalar OZERK Free'de yer alabilir mi?** §14.1 "kaynak koddan derlenebilirlik" ister; hosted uygulamada derlenen şey yalnızca kabuktur. Ayrı bir depo katmanı mı gerekir?
3. **İzin ömrü (`once` / `while-running` / `timed`) uzantısı permission store'da nasıl temsil edilecek?** Mevcut şema `yes`/`no`/`ask` dizgelerini taşır; ek durumu geriye dönük uyumlu biçimde kodlamanın en temiz yolu nedir ve bu upstream'e nasıl önerilir?
4. **Contacts ve Calendar portalı önerisi kim tarafından, hangi takvimle upstream'e taşınacak?** Bunlar hazır olana kadar `permissions.contacts = true` beyanının kullanıcıya nasıl anlatılacağı (kaba taneli olduğu) netleşmelidir.
5. **`[X-OZERK*]` grupları Flatpak araç zincirinden geçerken korunuyor mu?** `flatpak build-commit-from`, `build-bundle` ve ayna işlemlerinde bilinmeyen metadata gruplarının aynen taşındığı ölçülerek doğrulanmalıdır. Taşınmıyorsa `/app/share/ozerk/manifest.toml` tek kaynak olur ve tasarım buna göre sadeleşir.
6. **ed25519 imzalamaya geçiş takvimi.** Upstream çalışması yıllardır açıktır. OZERK, GPG ile ne kadar süre yetinecek ve upstream tıkanırsa (D3'ün "fork son çaredir" kuralı çerçevesinde) ne yapacak?
7. **`equivalent` seviyesinin normalleştirme kuralları.** Hangi farklar "anlam taşımaz" sayılır? Bu liste kötüye kullanıma açıktır; kim tanımlar ve nasıl denetlenir?
8. **AppStream metainfo ile ilişki.** Mağaza arayüzü OZERK beyanlarını okumak için Flatpak metadata'sını mı çözecek, yoksa beyanların bir özeti AppStream'in `<custom>` alanlarına da yazılmalı mı? İkincisi arayüz için pratiktir ama üçüncü bir kopya demektir.
9. **Şema sürümlemesi ve geriye uyumluluk.** `schema = 1` alanı tanımlıdır; ancak eski `schema` sürümlü paketlerin ne kadar süre kabul edileceği ve kırıcı değişikliğin nasıl ilan edileceği kararlaştırılmamıştır.
10. **`noexec` politikasının pratik maliyeti.** Yazılabilir dizinleri `noexec` ile bağlamak, meşru bazı uygulamaları (geliştirici araçları, betik çalıştıran uygulamalar) kırabilir. İstisna mekanizması gerekiyorsa nasıl beyan edilecek ve kullanıcıya nasıl gösterilecek?

---

## English

# RFC 0003: Application Package Format and Manifest Standard

> The Turkish text is normative in case of discrepancy.

- **Status:** Draft
- **Date:** 2026-08-17
- **Author(s):** OZERK founder
- **Open decision addressed:** [RFC-0001](0001-karar-kaydi.md) A3 — Application package format
- **License:** CC BY-SA 4.0

### Summary

The OZERK App standard **takes Flatpak as its base and extends it**; it does not invent a new package format. An application is a valid Flatpak package as-is; the OZERK-specific declarations (network access profile, allowed domains and their purposes, telemetry, advertising, build verification status, source and license) are generated from an `ozerk.toml` written by the developer and embedded in the package in two places: `[X-OZERK*]` groups in the Flatpak `metadata` file, and `/app/share/ozerk/manifest.toml` inside the application tree. Both are part of the OSTree commit, so the repository signature covers the declarations too. On a system that does not recognize the OZERK extensions, the package runs as an ordinary Flatpak.

This RFC also makes manifesto §13's rule — "no undeclared capability may be used silently" — actionable, by splitting declarations into three classes: **enforced**, **verified at build time**, and **declaration only**; and it forbids hiding that distinction in the user interface.

### Motivation

Manifesto §13 requires every application to declare, before installation, its network access model, allowed domains, telemetry and advertising status, and build verification status. No Linux package format in use today carries these fields. Flatpak's permission model focuses on sensors and files; network access is a binary switch — on or off. Levels two and three of manifesto §9.2's five-level network model (allowed domains only / ask on new domains) cannot be expressed in Flatpak's vocabulary.

The decision must be made now because:

- `sdk/cli/templates/ozerk.toml` already shows developers a schema today. If it is not formalized, every change made after the first applications are written will be breaking.
- The package format determines the sandbox model, the repository, the store UI and the SDK together. Changing it late means rewriting four components at once.
- The greatest threat to the manifest model is conceptual, not technical: if an application can download and run code at runtime, pre-installation declaration becomes meaningless on day one. That policy must be defined together with the format.

Two things are deliberately out of scope: the technical architecture of network enforcement ([RFC-0005](0001-karar-kaydi.md), A5) and the browser engine that web applications will run on ([RFC-0004](0001-karar-kaydi.md), A1). This RFC defines only **what is declared and where it lives**, not **how it is enforced**.

### Design

#### 1. The core decision

> **OZERK App = a Flatpak package + an OZERK declaration layer.**

This is a direct application of [RFC-0001](0001-karar-kaydi.md) D3 (upstream-first strategy). What Flatpak already gives us is too valuable to rewrite:

- a bubblewrap-based sandbox with seccomp filters,
- a user-mediated, runtime permission model via xdg-desktop-portal,
- name-level IPC control via the D-Bus proxy (`xdg-dbus-proxy`),
- an OSTree-based, delta-updated, signed repository model,
- the runtime/SDK split and shared dependencies,
- a codebase whose attack surface has been studied for years, with a public CVE history.

None of these is what OZERK lacks. What is missing is **metadata**. Reinventing a container format in order to fill a missing metadata field is working at the wrong layer.

The resulting rule: **OZERK never changes, removes or redefines any field a Flatpak package needs in order to run.** OZERK only adds. An OZERK package installs and runs on a non-OZERK desktop via `flatpak install`; the OZERK declarations are simply unused data there. This is the technical form of the "run the application on the Linux desktop too" right in manifesto §12.

#### 2. Where the declaration lives

Rather than choosing between three locations, each is given a distinct role:

| Location | Content | Who writes / reads |
|---|---|---|
| `ozerk.toml` (in the source repository) | **Normative source.** The hand-written, reviewable, diffable declaration. | Written by the developer; read by `ozerk build` and by code reviewers. |
| Flatpak `metadata` → `[X-OZERK*]` groups | A derived, machine-readable summary. Readable without launching or unpacking the app. | Generated by `ozerk build`; read by Guard and the install flow. |
| `/app/share/ozerk/manifest.toml` | The canonical, resolved copy of `ozerk.toml` plus the `ozerk.lock` digest. | Generated by `ozerk build`; read by the store, auditors and `ozerk verify`. |

All three are inside the OSTree commit. This is the decisive argument against the "separate policy file" alternative: **the repository signature signs the declaration too.** A separate file can be stripped or altered by a mirror unless separately signed, and version drift between package and declaration becomes inevitable.

Consistency is maintained as follows: the SHA-256 digest of the canonical serialization of `/app/share/ozerk/manifest.toml` is written into the `[X-OZERK]` group as `manifest-digest`. If the two copies disagree, the package is **invalid**; Guard refuses to run it and tells the user the package is corrupt or tampered with. There is no silent preference for one copy.

Technical basis: Flatpak's `metadata` file is a `.desktop`-style key-value file, and any group can be written into it with `flatpak build-finish --metadata=GROUP=KEY=VALUE`. Flatpak itself uses this path for `X-DConf`; `X-`-prefixed groups are an established extension point in this ecosystem. Likewise, `x-`-prefixed properties in flatpak-builder manifests are ignored by the build (`x-checker-data` is the well-known example of this convention), so leaving a trace in the build manifest is possible as well.

#### 3. How far Flatpak and portals satisfy manifesto §9.1

Manifesto §9.1 asks for six options. The honest mapping:

| §9.1 option | Today's equivalent | Assessment |
|---|---|---|
| **Deny** | The permission is never granted in `finish-args`; a portal request is stored as `no` in the permission store. | **Satisfied.** |
| **Always allow** | `yes` in the permission store. | **Satisfied.** |
| **Allow only selected items** | For files, the document portal is exactly this: the app never sees the filesystem, it receives a handle for the file the user picked. | **Satisfied for files.** There is **no** upstream portal for contacts or calendar; today the only control is granting or withholding access to D-Bus names such as `org.gnome.evolution.dataserver.*` wholesale. There is no "selected contacts" level. |
| **Allow once** | The file chooser and OpenURI are inherently one-shot. For camera and location the portal decision tends to be written to persistent storage. | **Partial.** A general "just for this call" semantic does not exist across the whole portal API. |
| **Allow only while the app is open** | The ScreenCast portal has a transient permission concept: the session can be restored only for as long as the app runs. | **Partial.** This is behavior in a single portal; there is no common "permission whose lifetime is bound to the app instance" concept across all sensitive portals. |
| **Allow for a specific duration** | Absent. Time-limited / self-expiring permissions remain an open upstream request (xdg-desktop-portal issue #981). | **Not satisfied.** |

Conclusion: the portal model gets the **backbone** of manifesto §9.1 right — permission is not a static list requested by the package but a dynamic right granted through the user, and the app cannot ask for it in its own UI. What is missing is a **time and scope dimension**.

Per D3, OZERK's job is not to fill that gap alone but to carry it upstream. This RFC proposes:

- **Short term:** permission lifetime (`once` / `while-running` / `until` / `always`) is kept as an OZERK extension written into permission store entries and applied by OZERK's portal backend. This works without changing the protocol, because the backend is already the party that decides.
- **Medium term:** the same model is proposed to xdg-desktop-portal as a duration field and transient-permission semantics. If accepted, the OZERK extension is removed.
- **Contacts and calendar:** a Contacts and a Calendar portal proposal is prepared. Until they exist, `permissions.contacts` and `permissions.calendar` are enforced **coarsely** (the D-Bus name is granted or not) and the manifest states that coarseness explicitly. Without a portal, the "selected contacts" claim is **not made**.

#### 4. Network access: the five levels of §9.2

In Flatpak, network is a binary permission: with `--share=network` the app reaches the entire internet; without it, the network namespace is isolated. There is no vocabulary for domain-level restriction, and this is a known limitation. The mapping is therefore:

| §9.2 profile | `ozerk.toml` value | Flatpak equivalent | Enforcement status |
|---|---|---|---|
| 1 — No network access | `none` | `--share=network` **not given** | **Fully enforced.** Kernel-level namespace isolation; the strongest guarantee. |
| 2 — Allowed domains only | `allowlist` | none in Flatpak | Depends on Guard ([RFC-0005](0001-karar-kaydi.md)). This RFC defines only the declaration. |
| 3 — Ask on new domains | `ask` | none in Flatpak | Depends on Guard. |
| 4 — General internet access | `full` | `--share=network` | Enforced (the door is either open or shut); but it is the absence of a restriction, not a restriction. |
| 5 — Raw network access | `raw` | the Flatpak sandbox does not leave `CAP_NET_RAW` | **Cannot be granted inside the sandbox.** This profile is open only to class A system applications and to exceptions the user explicitly approves (e.g. VPN, network diagnostics); it is not accepted in the ordinary app repository. |

The honest summary: **with Flatpak today, 1 and 4 are real; 2 and 3 are promises.** This RFC puts 2 and 3 into the manifest vocabulary so that applications already carry the right declaration when Guard is ready; but until then, the interface must show these profiles as "declared, not yet enforced". Anything else violates the manifesto's honesty commitment.

Two additional design decisions:

**Domain declarations carry a purpose.** `allowed_domains` is not a bare list but a table whose every entry has a purpose string. "api.example.com" alone tells the user nothing; "api.example.com — account sign-in and sync" does. This text is shown in the store and in the Privacy Center.

**For classes C and D, the allowlist can be enforced without breaking TLS.** For web applications, the party making network requests is OZERK's own web runtime. The runtime can compare the target origin against the declared list before establishing the request. This is control **above** encryption; it needs no fake certificate and does not violate the prohibition in manifesto §9.2. Native applications offer no such leverage — this is a measurable security advantage of class C over class B, and this RFC records it as a reason to encourage web applications.

#### 5. Representing the four application classes in one format

The `app.class` field carries the four classes of manifesto §8.2. The shared vocabulary does not change; what changes is which fields are meaningful and where enforcement happens.

**A — System application (`system`).** Shipped with the OS image; may not be packaged as a Flatpak. It **must** nevertheless carry an `ozerk.toml` and appear in the Privacy Center with the same vocabulary as everything else. The difference is stated plainly: a system application's manifest is a **disclosure**, not a **restriction** — these components are part of the trusted computing base and sit outside the sandbox that constrains them. Keeping their number limited (§8.2/A) is therefore a security rule, not an aesthetic preference.

**B — Native sandboxed application (`native`).** The base case. `ozerk.toml` → Flatpak `finish-args` + `[X-OZERK*]`. There is nothing special to say; the format was designed for this class.

**C — Packaged web application (`web-packaged`).** The package is a Flatpak containing HTML/CSS/JS/Wasm assets; the Flatpak `runtime` field points at the OZERK web runtime (which engine that is depends on A1/[RFC-0004](0001-karar-kaydi.md)). The manifest additionally states:

- `web.entrypoint` — the start document inside the package (it **cannot** be a remote URL),
- `web.remote_code = false` — all executed code is in the package,
- `web.csp` — the content security policy baseline the runtime will enforce,
- `web.allow_eval` — a declaration about `eval` / `new Function` usage.

The `web.remote_code = false` declaration is **enforceable**: the runtime refuses to load scripts from origins outside the package. This is the technical basis for class C's claim to be "independently verifiable" (§8.2/C).

**D — Hosted web application (`web-hosted`).** The package is a thin profile pointing at a remote origin. The manifest must carry:

- `web.origin` — the single origin the application is bound to,
- `web.remote_code = true` — **this field is immutable for class D; it cannot be set to `false`**,
- `build.verification = "not-applicable"` — since the running code is not in this package, reproducibility is meaningless here, and it is written as such,
- `network.mode` at least `allowlist`, with `web.origin` and any explicitly declared auxiliary origins in the list.

Manifesto §8.2/D's requirement that "the user is clearly informed that the code can be changed by the remote server" is met as follows: the `web.remote_code = true` declaration produces a persistent warning on the store page and **inside the application's own window on first launch**; the application cannot suppress it. One oddity must also be recorded in the update flow: a hosted application's behavior can change without the package version changing at all. Therefore "version" cannot be presented to the user as a guarantee for class D applications, and the store says so explicitly.

A related repository question is left open (see below): §14.1 requires OZERK Free packages to be buildable from source; in a hosted application, what is built is the shell, not the service. This RFC does not decide whether class D applications may appear in OZERK Free.

#### 6. The enforceability split in §13

This is the most important section of the RFC. Manifesto §13 says no undeclared capability may be used silently. That sentence stays honest only if it is made clear which declarations are actually enforceable. Declarations fall into three classes:

**Class E — Enforced.** The system technically blocks undeclared behavior. The application cannot exceed its declaration.

| Field | Enforcement mechanism |
|---|---|
| Network profile 1 (`none`) | Network namespace isolation |
| Network profile 4 (`full`) | Presence/absence of `--share=network` |
| Filesystem access | Flatpak `filesystems` + document portal |
| Camera, microphone, screen | Portal + PipeWire; the device node is absent from the sandbox |
| Location accuracy | Location portal; the `none`/`country`/`city`/`neighborhood`/`street`/`exact` levels are defined in the protocol |
| Notifications | Notification portal |
| D-Bus access (including contacts/calendar, coarse-grained) | `xdg-dbus-proxy` name policy |
| Devices (dri, usb, input) | Flatpak `devices` |
| Remote scripts in a packaged web app | Web runtime CSP enforcement |
| Network profiles 2 and 3 | **Partially, and in the future** — depends on Guard; DoH, ECH and shared CDNs limit domain-level certainty ([RFC-0005](0001-karar-kaydi.md)) |
| Background execution | **Partially** — Background portal + cgroup control; not a full guarantee |

**Class V — Verified at build time.** Not enforced at runtime; tested independently before publication and the result recorded.

- Build verification status (reproducibility — §8),
- Correspondence between the declared source address and the published binary,
- Software bill of materials (SBOM) and the dependency closure,
- Presence or absence of known tracking libraries in the binary (static scanning),
- Consistency of the license declaration with the source tree.

**Class B — Declaration only.** The system can neither block nor verify these. Only a **contradiction** can be observed.

- **The nature of telemetry:** what data is collected, for what purpose, how long it is kept, with whom it is shared. OZERK can see that a connection happened, its destination and its size; it **cannot see the content** — because §9.2 forbids planting fake certificates. This is a deliberate trade-off, and this is its consequence.
- **The advertising declaration:** connections to known ad endpoints can be observed; but the *absence* of advertising cannot be proven.
- **Third-party data sharing** and all server-side behavior.
- **Purpose statements:** whether a domain's declared purpose is truthful.

Three binding rules follow from this split:

1. **The interface must visually separate the three classes.** "Enforced", "Verified" and "Declared" labels cannot be shown with equal weight. Manifesto §9.3's principle — "OZERK will state only what it can observe and verify" — becomes a concrete UI rule here.
2. **The automatic-update rule differs by class.** An expansion in a class E declaration (a new permission, a broader network profile, a new domain) **halts** automatic updates and shows the user the permission diff (§10.3). A change in a class B declaration (e.g. new telemetry wording) does not halt the update but is reported to the user and recorded.
3. **In class B, the sanction for lying is repository policy, not technology.** When declared and observed behavior conflict (§13's last sentence), the outcome is labeling the application and, if necessary, removing it from the repository. The process for that sanction is out of scope here; it belongs to repository governance.

#### 7. Downloading and executing code at runtime

Without this policy the manifest model is punctured on day one: the application declares nothing, ships a small loader, and downloads its real payload on first launch. The entire pre-installation declaration evaporates.

Proposed rules:

**7.1. Executing native code from outside the package is forbidden and technically blocked.** In Flatpak, `/app` is already read-only. OZERK additionally mounts the application's writable directories (the equivalents of `~/.var/app/<id>` and in-sandbox temporary areas) **`noexec`**. A downloaded ELF binary therefore cannot be `exec`'d.

**7.2. The limits of that block are stated plainly.** `noexec` **does not stop interpreted code**: a downloaded Python, Lua or JavaScript file can be run by an interpreter the application already ships. JIT compilers (including every JavaScript engine) use `PROT_EXEC` memory mappings; a general W^X policy would also break the web runtime. Therefore OZERK **will not say "an application cannot download new code".** What it will say is: *it cannot execute unpackaged native binaries, and in a packaged web application it cannot load remote scripts.*

**7.3. The declaration field: `code_delivery`.** It takes three values:

- `package-only` — all executed code is in the package. The strongest declaration; enforceable in class C, partially in class B.
- `interpreted-extensions` — the application can load plugins/scripts the user explicitly installs (text editors, developer tools). The plugin source and the user-consent flow are declared.
- `remote` — the application receives code remotely. Regardless of class, this value puts the application into the **hosted warning class**: the user is told that the running code may not be the code reviewed in the store.

If undeclared, the default is `package-only`, and observed behavior to the contrary counts as a §13 violation.

**7.4. `extra-data` is accepted with limits.** Flatpak's `extra-data` mechanism **pins the data to be downloaded at install time with a SHA-256** — so it is not "arbitrary code"; what is downloaded is determined, and installation fails if it changes. In OZERK Free, `extra-data` is accepted only (a) for non-redistributable assets (e.g. licensed fonts, model files) and (b) on condition that it contains no executable code. Every `extra-data` entry is listed in the manifest with its purpose and source.

**7.5. System applications are not exempt.** Class A components also declare `code_delivery`. The exception is the update mechanism itself, which works through signed system updates (§10.3).

#### 8. Signing, repository and reproducibility

**8.1. Repository model.** OZERK repositories are kept in the OSTree `archive-z2` format and operated with **flat-manager**, the same software Flathub uses. This is a production-tested path that satisfies delta updates, multi-architecture support and the federated-repository requirement (§14.3: anyone can run their own repository).

**8.2. Signature chain.** OSTree signs every commit and the summary file. The path that works with a stock `flatpak` client today is GPG. OSTree also supports ed25519 via `ostree sign`, and the corresponding work on the Flatpak side has been in progress upstream for years (`flatpak/flatpak#4170` is still open). The decision:

- OZERK **starts with GPG**, because compatibility with an unmodified Flatpak client is what D3 requires;
- OZERK **does not maintain a fork** until ed25519 support lands upstream; it contributes;
- the transition does not break the format, because the signature type lives in the repository configuration, not in the package.

Since the declarations are inside the commit (§2), this signature chain covers them too. No separate "manifest signature" concept is needed.

**8.3. Transparency log.** The transparency record required by §14.4 is defined as an append-only log. For each publication, at minimum: application id, version, OSTree commit digest, `manifest-digest`, and a canonical digest of the class E declarations. This log is the single source of truth for computing the permission diff (§10.3) and for answering "was this version actually published?".

**8.4. Reproducibility is not a boolean.** The `reproducible = false` field in the current `sdk/cli/templates/ozerk.toml` draft is inadequate. flatpak-builder is not reproducible in general; there is no lockfile concept pinning the resolved dependency closure, and extensions are not pinned to exact commits. Rather than hiding that fact behind a `true/false` field, a five-step status is defined:

| `build.verification` | Meaning |
|---|---|
| `reproducible` | An independent second build produced a bit-identical application tree. |
| `equivalent` | The second build differed only by documented, semantically meaningless differences (timestamps, build paths, build-ids); the normalized tree digest matched. The normalization rules are public. |
| `source-built` | The repository built it from published source in an isolated environment; no independent second build. |
| `unverified` | The binary was supplied by the developer. |
| `not-applicable` | The running code is not in the package (class D). |

This field is **not written by the developer**; it is produced by the repository, and the value in `ozerk.toml` is only a stated target. The `build.verification` field is carried separately: in `[build]` as the developer's *request*, in `[X-OZERK]` as the repository's *finding*.

**8.5. Hard cases are recorded honestly.** Reproducibility varies enormously with the technology chosen:

- **Rust and Go:** relatively good; with a pinned toolchain version and measures like `--remap-path-prefix`, `reproducible` is an attainable target.
- **C/C++ (especially autotools):** usually stays at `equivalent`, because of timestamps, `__FILE__` paths and link ordering.
- **Wasm:** output is deterministic once the toolchain is pinned; the real difficulty is not the engine but pinning the npm/cargo dependency closure. This is why a lockfile is mandatory.
- **Flutter:** the hardest. It bundles its own engine, its AOT snapshots are sensitive to the build environment, and toolchain version pinning practice is weak. This RFC **accepts and states** that Flutter applications will realistically remain at `source-built` or `equivalent` initially; the "reproducible" label is not awarded without measurement.

Consequently, `ozerk build` must write the resolved dependency closure into an `ozerk.lock` file; without it, no application can receive the `reproducible` or `equivalent` label.

#### 9. Draft schema

The example below is consistent in field naming with `sdk/cli/templates/ozerk.toml` and completes it. This schema is **draft**; it is not binding until the RFC is accepted. (See the Turkish section above for the full commented example; the field names are identical and the comments are the normative explanation.)

```toml
schema = 1

[app]
id      = "org.example.notes"
version = "1.4.0"
name    = "Notes"
source  = "https://git.example.org/notes"
license = "GPL-3.0-or-later"
# "system" (A) | "native" (B) | "web-packaged" (C) | "web-hosted" (D)
class = "native"

[runtime]
base    = "org.gnome.Platform"
version = "48"
sdk     = "org.gnome.Sdk"

# PERMISSIONS — everything off by default. (Class E: enforced)
[permissions]
# "none" | "portal" | "xdg-documents" | "home" | "host"
files      = "none"
camera     = false
microphone = false
# Contacts/calendar are enforced COARSELY today (a D-Bus name is granted or not).
# No "selected contacts" claim is made, because no upstream portal exists.
contacts = false
calendar = false
# Matches the location portal's levels one-to-one.
# "none" | "country" | "city" | "neighborhood" | "street" | "exact"
location      = "none"
notifications = false
background    = false
# The narrowest lifetime the app can accept; the user may always choose narrower.
# "once" | "while-running" | "timed" | "always"
lifetime_hint = "while-running"
devices       = []

[[permissions.dbus]]
name   = "org.freedesktop.secrets"
access = "talk"                    # "see" | "talk" | "own"
reason = "To store passwords in the system keyring."

# NETWORK — the five profiles of manifesto §9.2
[network]
# "none" (1, enforced) | "allowlist" (2, Guard) | "ask" (3, Guard)
# | "full" (4, enforced) | "raw" (5, not grantable inside the sandbox)
mode = "allowlist"

[[network.allowed]]
domain  = "sync.example.org"
purpose = "Syncing notes across accounts."

[[network.allowed]]
domain  = "example.org"
purpose = "Help documents and release notes."

local_discovery = false

# CODE DELIVERY — §7
[code]
# "package-only" | "interpreted-extensions" | "remote"
delivery   = "package-only"
extra_data = []                    # SHA-256-pinned; no executable code

# WEB — only when class = "web-packaged" or "web-hosted"
# [web]
# entrypoint  = "index.html"       # class C: in-package; cannot be a remote URL
# origin      = ""                 # class D: the single remote origin
# remote_code = false              # necessarily true for class D
# csp         = "default-src 'self'; connect-src 'self' https://sync.example.org"
# allow_eval  = false

# DECLARATIONS — Class B: unenforceable; only contradictions are observable.
# The UI shows these labeled "Declared", SEPARATE from enforced permissions.
[declarations]
telemetry = "crash-only"           # "none" | "crash-only" | "usage" | "personal"

[declarations.telemetry_detail]
endpoint    = "sync.example.org"   # must appear in network.allowed
data        = "Crash stack trace, application version, OS version."
identifier  = "none"               # "none" | "random-per-install" | "account"
optional    = true
default_off = true
retention   = "90 days"

ads                 = "none"       # "none" | "static" | "personalized"
third_party_sharing = "none"

# BUILD — [build] is the developer's TARGET; the real status is produced by
# the repository and written into [X-OZERK]. The two are never conflated.
[build]
# "reproducible" | "equivalent" | "source-built" | "unverified" | "not-applicable"
verification_target = "equivalent"
source_ref = "v1.4.0"
lockfile   = "ozerk.lock"
sbom       = "sbom.spdx.json"
```

The Flatpak `metadata` summary generated from this file (written with `flatpak build-finish --metadata=GROUP=KEY=VALUE`):

```ini
[Context]
shared=network
sockets=wayland;fallback-x11;
filesystems=

[Session Bus Policy]
org.freedesktop.secrets=talk

[X-OZERK]
schema=1
class=native
network-mode=allowlist
code-delivery=package-only
manifest-digest=sha256:6f1c…
build-verification=equivalent          # written by the repository

[X-OZERK Network]
allowed=sync.example.org;example.org;

[X-OZERK Declarations]
telemetry=crash-only
ads=none
```

`shared=network` appears in `[Context]` because profile 2 has no equivalent in Flatpak's vocabulary today; the actual restriction is applied by Guard on the basis of the `X-OZERK` information. This gap is deliberate and documented: on a non-OZERK system the application runs with full network access, because there is no Guard there and OZERK cannot make guarantees on those systems' behalf. The store states that the `allowlist` declaration is enforced on OZERK only.

#### 10. Compatibility and tooling

- `ozerk init` generates this schema; `ozerk permissions` shows the declaration side by side with the generated `finish-args`.
- `ozerk build` produces the Flatpak manifest + `metadata` + `/app/share/ozerk/manifest.toml` + `ozerk.lock` from `ozerk.toml`.
- `ozerk verify` checks consistency across the copies, the `manifest-digest`, the lockfile, and where possible a second build.
- An existing Flatpak application is ported to OZERK by adding an `ozerk.toml`; no code change is required. This is the practical form of the "do not restart the ecosystem from zero" argument.
- A Flatpak without an `ozerk.toml` can still be installed; but the store and Privacy Center label it "no declaration" and run it with the narrowest defaults. Labeling rather than banning is consistent with the approach in §8.3.

### Alternatives

**1. An original format from scratch.** This is the path that most directly satisfies the manifesto's needs, with full design freedom. Rejected because: it directly contradicts D3; and, more importantly, it solves the wrong problem. What is missing is the metadata, not the container. An original format would require rewriting the sandbox, the portal model, the repository infrastructure, delta updates and a decade of security history; the ecosystem would start with zero applications, and developers would lose the right to also run their application on the Linux desktop (§12).

**2. Pure Flatpak + a separate policy file.** Touches the standard not at all; the lowest-friction path. Rejected because: it decouples the declaration from the package. A separate file can be altered or dropped by a mirror unless separately signed; version drift is inevitable; and "the declaration ships with the package" is the essence of a pre-installation guarantee. The `[X-OZERK*]` route gives the same low friction without losing signature coverage.

**3. Snap.** Offers strict confinement, a commercially maintained toolchain and a mature update infrastructure. Rejected because: the store and distribution layer is in practice controlled by a single company; a federated model in which anyone can run their own repository (§14.3) is not Snap's design assumption. Confinement also relies on AppArmor and varies between distributions. For a platform claiming user sovereignty, centralization at the distribution layer is unacceptable.

**4. AppImage.** A single file, no installation, portable. Rejected because: it has no default sandbox, no standard signing and update infrastructure, and no permission vocabulary. Everything manifesto §13 asks for would have to be built from scratch — which returns to option 1, from a weaker base.

**5. OCI / container image.** Deserves serious consideration: the toolchain is everywhere, the registry infrastructure is mature, and Flatpak already supports distribution over OCI. Rejected because: OCI is a **transport** format, not a desktop application model. It has no portal integration, no session integration, no user-mediated permissions, no delta updates and none of OSTree's file-level deduplication; layer-based images waste a great deal on a phone with limited storage. It is, however, **retained as a transport option**: for enterprise or air-gapped distribution, delivery over an OCI registry is possible without changing the format.

**6. An Android APK-like format.** The idea of declaring permissions before installation is exactly what §13 asks for, and APK is its most widespread example. Rejected for two reasons. First: adopting it means adopting the Android runtime, whereas manifesto §11 positions Android as a guest and the compatibility need is already met by Bridge/Waydroid. Second and more important: the track record of the APK permission model is a warning, not an example. Permissions are coarse-grained, a large share are declaration-only, and the ecosystem has settled into "ask for everything, users accept anyway". OZERK's three-class split (§6) exists precisely to prevent that outcome.

**7. Do nothing — defer the decision.** A defensible option: there is no platform code yet, and early schema mistakes are expensive. Rejected because: the CLI already emits an `ozerk.toml` to developers today. The longer the decision is deferred, the more an unformalized schema becomes the de facto standard — deferring the decision is not avoiding it, it is taking it without documenting it.

### Open Questions

1. **How will network profiles 2 and 3 be presented in the UI before Guard exists?** "Declared, not yet enforced" is honest but may be meaningless to users. Should these profiles be accepted in the repository before Guard is ready, or should only 1 and 4 be accepted?
2. **Can class D applications appear in OZERK Free?** §14.1 requires buildability from source; in a hosted application only the shell is built. Is a separate repository tier needed?
3. **How will the permission lifetime extension (`once` / `while-running` / `timed`) be represented in the permission store?** The current schema carries the strings `yes`/`no`/`ask`; what is the cleanest backward-compatible way to encode the extra state, and how is it proposed upstream?
4. **Who will carry the Contacts and Calendar portal proposals upstream, and on what timeline?** Until they exist, how `permissions.contacts = true` is explained to the user (that it is coarse-grained) must be settled.
5. **Are `[X-OZERK*]` groups preserved as they pass through the Flatpak toolchain?** Whether unknown metadata groups survive `flatpak build-commit-from`, `build-bundle` and mirroring operations must be verified by measurement. If they do not, `/app/share/ozerk/manifest.toml` becomes the single source and the design simplifies accordingly.
6. **The timeline for moving to ed25519 signing.** The upstream work has been open for years. How long will OZERK settle for GPG, and what does it do if upstream stalls (within D3's "forking is a last resort" rule)?
7. **The normalization rules for the `equivalent` level.** Which differences count as "semantically meaningless"? That list is open to abuse; who defines it and how is it audited?
8. **Relationship with AppStream metainfo.** Will the store UI parse the Flatpak metadata to read OZERK declarations, or should a summary also be written into AppStream's `<custom>` fields? The latter is practical for the UI but means a third copy.
9. **Schema versioning and backward compatibility.** The `schema = 1` field is defined; but how long packages with older `schema` versions will be accepted, and how a breaking change is announced, has not been decided.
10. **The practical cost of the `noexec` policy.** Mounting writable directories `noexec` may break some legitimate applications (developer tools, script-running applications). If an exception mechanism is needed, how is it declared and how is it shown to the user?
