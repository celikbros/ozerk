# RFC 0002: Taban Dağıtım Seçimi

**Türkçe** | [English](#english)

- **Durum:** Taslak
- **Tarih:** 2026-08-17
- **Yazar(lar):** OZERK kurucusu

## Özet

Bu RFC, [RFC-0001](0001-karar-kaydi.md)'deki **A2 — Taban dağıtım seçimi** açık kararını karşılar: OZERK OS hangi dağıtımın üzerine kurulacak?

Bu belge bir karar önerisi **değildir**. Adayları dürüstçe karşılaştırır, manifestonun taban dağıtıma yüklediği gereklilikleri açık eder ve kararın hangi ağırlıklandırılmış, test edilebilir ölçütlerle verileceğini tanımlar. Kararın kendisi, bu belgenin tartışma aşaması tamamlandıktan ve §9'daki ölçümler yapıldıktan sonra ayrı bir revizyonla yazılacaktır.

## Motivasyon

Taban dağıtım seçimi, geç değiştirilmesi en pahalı kararlardan biridir. Şunların tamamı bu seçime bağlıdır:

- **Paketleme ve güvenlik güncellemesi akışı.** Hangi paket yöneticisi, hangi güvenlik ekibi, hangi CVE takip süresi.
- **Cihaz desteği.** Aşama 2'nin referans telefonu (manifesto §21) hangi cihaz portu havuzundan seçilebilir.
- **Güncelleme mimarisi.** Manifesto §10.3 beş şey ister: imzalı tam sistem güncellemeleri, A/B sistem bölümü, başarısız güncellemede otomatik geri dönüş, salt okunur temel sistem, doğrulanmış sistem bütünlüğü. Bu beşinin birlikte kurulabilirliği tabana göre çok farklıdır.
- **libc seçimi.** musl mu glibc mi — üçüncü taraf ikili yazılım, Waydroid, kapalı kaynak uygulamalar (manifesto §8.3) ve Flatpak dışı yazılımın tamamı bundan etkilenir.
- **Katkı yolu.** [D3](0001-karar-kaydi.md#d3--upstream-öncelikli-strateji) upstream-öncelikli stratejiyi bağlar: OZERK fork değil, downstream olacaktır. Hangi taban bu duruşu sürdürülebilir kılar?
- **Guard'ın altyapısı.** Manifesto §9.2'nin uygulama-başı ağ denetimi, çekirdek ve init katmanında belirli olanaklar ister.

Karar şimdi alınmazsa Aşama 1 (emülatör ve geliştirici sistemi) bir tabana yaslanmadan başlayamaz; başlarsa da yapılan iş büyük olasılıkla atılır.

Aynı ölçüde önemli olan ikinci nokta: bu karar bir **evlilik değil, ortaklıktır**. OZERK'in katma değeri alt katmanlar değil, üzerine kurulacak kullanıcı egemenliği katmanıdır. Bu nedenle "hangi taban daha iyi" sorusu kadar "hangi tabanda OZERK'in eklemek istediği şey upstream'e geri verilebilir" sorusu da ölçüte girmelidir.

## Tasarım

### 1. Bu belgenin kapsamı ve sınırları

**Kapsam içi:** taban dağıtım (paket yönetimi, init, libc, cihaz portu havuzu, güncelleme mimarisi olanakları, topluluk).

**Kapsam dışı:** kabuk / masaüstü ortamı seçimi (Phosh, Plasma Mobile, GNOME Mobile), tarayıcı motoru (A1 / RFC-0004), uygulama paket formatı (A3 / RFC-0003), referans donanım (A4 / RFC-0006), Guard'ın zorlama mimarisi (A5 / RFC-0005). Bu RFC yalnızca o kararların **önünü açık tutup tutmadığını** değerlendirir.

**Belgedeki tarih damgası:** aşağıdaki tespitler Ağustos 2026 itibarıyla ve büyük ölçüde ikincil kaynaklardan derlenmiştir. Kararın verileceği gün yeniden doğrulanmaları gerekir; hızlı hareket eden bir ekosistemde altı ay eskimiş bir tablo yanıltıcıdır.

### 2. Adayların karşılaştırması

#### 2.1. postmarketOS

| Boyut | Durum |
| --- | --- |
| Taban / paket yönetimi | Alpine Linux; `apk` (v25.12'de beş yıllık geliştirmenin ardından apk3'e geçildi) |
| libc | musl |
| Init | **systemd** — v25.06'dan (Haziran 2025) itibaren varsayılan; OpenRC geleneği geride bırakıldı |
| Cihaz desteği | Mobil Linux'taki en geniş port havuzu. v26.06 duyurusunda `testing` kategorisinde 254 cihaz anılır; `community` kategorisi daha küçüktür. Toplam sayı kaynaklara göre değişir — **doğrulanmalı** |
| Kernel durumu | Karışık: mainline hedeflenir, ancak çok sayıda port hâlâ downstream/vendor kernel ile çalışır. Cihaz bazında değişir |
| Güncelleme mimarisi | **Duranium** (Mart 2026): systemd-sysupdate + systemd-repart + systemd-verity-setup; A/B yuvaları, dm-verity ile salt okunur `/usr`, EROFS, zorunlu LUKS2, başarısız açılışta otomatik geri dönüş. **Deneysel**; Secure Boot / doğrulanmış açılış henüz yok; UEFI (U-Boot) gerektirir; her pmOS cihazında çalışmaz |
| Topluluk | Bağımsız, açık finansal raporlama yapan bir proje; ücretli geliştirici kontratları var. Ekip küçüktür |

**OZERK için avantajlar:** En geniş cihaz havuzu, A4 (referans donanım) kararına en fazla seçenek bırakır. Duranium, §10.3'ün beş maddesinin dördünü tek yerde toplayan bugün bilinen **tek mobil Linux çalışmasıdır**. Mobil-odaklı araç zinciri (pmbootstrap) olgundur. Proje, upstream'e katkıyı fiilen yapar: musl üzerinde systemd desteği upstream systemd'ye taşındı ve v259'da deneysel olarak birleşti; pmOS artık systemd'yi downstream musl yamaları olmadan derliyor — D3'ün canlı örneği.

**OZERK için dezavantajlar:** musl, sistem düzeyinde üçüncü taraf ve kapalı kaynak ikili uyumluluğunu daraltır (§5). Alpine'ın paket havuzu Debian'dan dardır. systemd'nin musl desteği upstream'de **deneyseldir ve uzun bir uyarı listesiyle gelir** — bu bağımlılık zinciri izlenmelidir. Duranium'un cihaz gereksinimleri (UEFI, iki adet ~5 GB yuva) düşük depolamalı eski cihazları eler.

#### 2.2. Mobian

| Boyut | Durum |
| --- | --- |
| Taban / paket yönetimi | Debian; `apt` / `dpkg` |
| libc | glibc |
| Init | systemd (Debian varsayılanı) |
| Cihaz desteği | Dar ve seçici: PinePhone / PinePhone Pro / PineTab, Librem 5, Pixel 3a ve 3a XL, OnePlus 6 / 6T, Poco F1; ayrıca ciddi donanım sınırlarıyla Fairphone 4 / 5, PineTab2, SHIFT6mq |
| Kernel durumu | Mainline öncelikli; yol haritası açıkça mainline'a geçişi hedefler. Desteklenen cihazların çoğu 6.12 sınıfı çekirdek kullanır (Trixie) |
| Güncelleme mimarisi | Klasik `apt`. Yol haritasında immutable / A/B / OSTree / atomik güncelleme **yoktur**. Debian ekosisteminde araçlar mevcuttur (OSTree, RAUC, systemd-sysupdate) ama mobilde bütünleşmiş bir çözüm yoktur — bu iş OZERK'e kalır |
| Topluluk | Debian'ın devasa altyapısı ve güvenlik ekibi; ancak Mobian'ın kendi geliştirici sayısı azdır ve yol haritası bunu açıkça yazar ("sınırlı gönüllü geliştirici") |

**OZERK için avantajlar:** glibc, üçüncü taraf ve kapalı kaynak yazılım uyumluluğunda en az sürtünmeyi verir (manifesto §8.3 kapalı kaynağı teknik olarak yasaklamaz — bu bir uyumluluk yükümlülüğü doğurur). Debian'ın paket havuzu ve güvenlik süreçleri olgundur; kurum ve kamu alımlarında Debian tabanı bilinen bir zemindir (manifesto §15). Mobian'ın açık hedefi Debian'a geri erimektir — yani downstream olmayı yapısal olarak teşvik eder, D3 ile birebir örtüşür.

**OZERK için dezavantajlar:** Cihaz havuzu dardır; A4'ün seçeneklerini erkenden daraltır. §10.3'ün istediği güncelleme mimarisi **sıfırdan kurulacaktır** ve bu, D3'ün "sıfırdan icat etme" ilkesiyle gerilim yaratır: OZERK, Debian mobil için bir görüntü tabanlı güncelleme mimarisini tek başına taşımak zorunda kalabilir. Debian'ın sürüm döngüsü mobil donanım desteğinin hızına göre yavaştır.

#### 2.3. Diğer adaylar

**Fedora (Mobility SIG / Pocketblue).** Güncelleme mimarisi açısından en olgun kavramsal zemin: OCI + OSTree + bootc, yani immutability, atomik güncelleme ve geri dönüş tabanın kendisinde yerleşiktir; uygulamalar Flatpak ile gelir. Cihaz listesi dardır (Xiaomi Pad 5/6, OnePlus 6/6T, Poco F1, Orange Pi 3 LTS sınıfı) ve Pocketblue Red Hat'in ürünü değil, topluluk projesidir; süreklilik riski buradadır. `rpm`/`dnf` ekosistemi OZERK için tanıdık olmayan bir paketleme kültürü getirir. Fedora'nın hızlı sürüm temposu mobilde hem avantaj hem bakım yüküdür.

**Alpine doğrudan (postmarketOS olmadan).** postmarketOS'un sağladığı her şeyi — cihaz portları, `pmbootstrap`, mobil paketler, kabuk entegrasyonu — OZERK'in kendisi üstlenmek zorunda kalır. D3 ile açıkça çelişir; postmarketOS zaten Alpine'ın mobil downstream'idir ve o işi yapmaktadır. Yalnızca postmarketOS ile yollar ayrılırsa gündeme gelmesi anlamlıdır.

**Yocto / Buildroot tabanlı özel imaj.** Gömülü dünyada A/B + salt okunur + doğrulanmış açılış en olgun biçimde burada çözülmüştür (RAUC, SWUpdate, Mender, OSTree, 2026'da 1.0'a ulaşan Rugix Ctrl gibi motorlar). Tam denetim sağlar ve Aşama 6'nın (ticari cihaz) doğal yoludur. Karşılığında: paket havuzu yoktur, genel amaçlı bir dağıtımın güvenlik güncellemesi akışı yoktur, kullanıcı kendi yazılımını kuramaz (manifesto §12 geliştirici hakları ve §17 yakınsak bilgisayar vizyonu ile gerilim), topluluk katkısı zorlaşır. Bir ürün imajı stratejisi olarak sonradan değerlendirilebilir; bir **topluluk işletim sistemi** tabanı olarak bugün uygun değildir.

**Mobile NixOS.** Nix'in üretim (generation) modeli, geri dönüşü ve yeniden üretilebilirliği tabanın doğasına yerleştirir; bu, manifesto §6.4'ün (yeniden üretilebilir paketler, bağımsız build doğrulaması) en doğrudan karşılığıdır. Proje etkin biçimde sürdürülmektedir ("Vanilla Mobile NixOS" çalışması dahil) ancak ekip küçüktür. Nix geri dönüşü **bölüm düzeyinde A/B değildir**: sistem üretimleri arasında geçiştir; başarısız açılışta otomatik geri dönüş ve dm-verity ile doğrulanmış salt okunur taban ayrıca kurulmalıdır (NixOS + systemd-repart + systemd-sysupdate ile yapılabildiğine dair çalışmalar vardır — **doğrulanmalı**). Öğrenme eğrisi diktir ve katkıcı havuzunu daraltır.

### 3. Manifesto §10.3 hangi tabanla nasıl kurulur?

Önce dürüst tespit:

> **Bugün hiçbir mobil Linux dağıtımı, manifesto §10.3'ün beş maddesini birlikte, kararlı (deneysel olmayan) ve geniş cihaz yelpazesinde sunmuyor.** OZERK bu maddeyi bir hazır özellik olarak devralamaz; hangi taban seçilirse seçilsin, bu maddenin bir kısmı yapılacak iştir.

Üç yol vardır:

| Yaklaşım | Nasıl çalışır | Tabanlarla uyum |
| --- | --- | --- |
| **OSTree / bootc** | Dosya sistemi düzeyinde atomik commit'ler, ağaç geçişi, geri dönüş. Blok düzeyi A/B değildir; "A/B bölüm" ifadesini harfiyen karşılamaz ama işlevsel eşdeğerini verir | Fedora'da yerleşik. Debian/Ubuntu üzerine sonradan giydirilebilir (topluluk örnekleri var). Alpine üzerinde bilinen bir mobil entegrasyon yok |
| **RAUC / SWUpdate / Rugix** | Gömülü dünyanın klasik blok düzeyi A/B çözümü; imzalı paket, bootloader ile anlaşma, otomatik geri dönüş | Dağıtımdan bağımsız; Yocto/Buildroot ile en olgun. Debian üzerinde kurulabilir ama bootloader entegrasyonu cihaz başına iştir |
| **systemd-sysupdate + repart + verity** | Blok düzeyi A/B, dm-verity ile doğrulanmış salt okunur bölüm, systemd-boot / gpt-auto ile geri dönüş | Her iki taban da artık systemd kullandığı için ikisinde de mümkün. **postmarketOS'ta Duranium olarak fiilen mevcut** (deneysel). Debian/Mobian'da hazır bir uygulaması yok |

Bu tablonun OZERK için anlamı:

- **postmarketOS + Duranium**, §10.3'ün beş maddesinden dördünü (A/B, salt okunur taban, otomatik geri dönüş, doğrulanmış bütünlük) bugün fiilen sunan tek yoldur. Eksik olan **doğrulanmış açılış** ayağıdır ve bu zaten A4'teki paradoksun (mainline desteği ile kullanıcı denetimli verified boot'un aynı cihazda nadiren bulunması) parçasıdır; bu RFC onu çözmez.
- **Mobian**, §10.3 için bir *yol haritası* değil, bir *boşluk* sunar. OZERK bu boşluğu doldurabilir — ama bunu Debian mobil ekosisteminde tek başına taşımayı göze alarak.
- **Fedora Pocketblue**, kavramsal olarak en temiz zemini sunar ama cihaz desteği ve süreklilik riski nedeniyle bugün taban olarak ağır bir bahistir.

Ayrıca dikkat: Duranium'un mimarisi paket yöneticisini `/usr`'dan çıkarır; yazılım Flatpak ve `coldbrew` (Alpine paketlerini ev dizinine, bubblewrap sandbox'ı içine kuran araç) ile gelir. Bu, A3'ün (uygulama paket formatı) Flatpak üst kümesi önerisiyle **doğal olarak örtüşür** ama manifesto §12'nin geliştirici özgürlüğü ve §17'nin yakınsak kullanım (terminal, derleme araçları, veritabanı istemcileri) beklentileriyle sürtünme üretebilir. Bu sürtünme ölçülmelidir.

### 4. Flatpak ve xdg-desktop-portal

Flatpak ve portallar OZERK için tercih değil, **gereklidir**: A3'ün öne çıkan önerisi Flatpak üst kümesidir ve manifesto §9.1'in "yalnızca seçilen öğelere izin ver" davranışı portal modelinin ta kendisidir.

- Flatpak, hem Alpine/postmarketOS hem Debian/Mobian üzerinde çalışır. `xdg-desktop-portal` ve arka uçları (GTK, KDE, wlr) her iki tarafta da paketlidir.
- **musl'un buradaki etkisi beklenenden küçüktür.** Standart Flatpak runtime'ları (freedesktop-sdk) kendi glibc'lerini taşır; dolayısıyla glibc'ye bağlı bir uygulama musl tabanlı bir konakta Flatpak içinde sorunsuz çalışır. Flatpak, musl konakta glibc yazılımı çalıştırmanın **çözümüdür**, engeli değil.
- Bedeli: Flatpak paketleri, taban sistemin paketleriyle kütüphane çakışması yaşadığı için daha fazla depolama ve RAM tüketir. musl tabanlı bir konakta bu çakışma daha büyüktür, çünkü konak ile runtime arasında hiçbir kütüphane paylaşılamaz. Telefon sınıfı cihazlarda bu maliyet **ölçülmelidir** (§9, Ö3).
- Portal arka uçlarının mobil davranışı (dosya seçici, kişi portalı, konum portalı) her iki tabanda da kabuk seçimine bağlıdır; bu, taban değil kabuk kararıdır.

**Sonuç:** Flatpak/portal ekseninde iki taban arasında niteliksel bir fark yoktur; fark niceliksel ve ölçülebilirdir (bellek/depolama). Bu ölçüt önemlidir ama belirleyici olmamalıdır.

### 5. glibc / musl ve üçüncü taraf uyumluluğu

Manifesto §8.3 kapalı kaynak uygulamaları **teknik olarak yasaklamaz**; onları etiketler. Bu, bilinçli bir özgürlük tercihidir ve teknik bir yükümlülük doğurur: kullanıcı kapalı kaynak bir uygulamayı kurmayı seçtiğinde sistem buna izin verebilmelidir.

- Kapalı kaynak ikili yazılımların ezici çoğunluğu glibc'ye derlenir. musl konakta bunlar **doğrudan** çalışmaz; `gcompat` gibi uyumluluk katmanları kısmi çözümdür ve her durumda yetmez.
- Bu kısıt esas olarak **Flatpak dışında** dağıtılan yazılımı ilgilendirir: sistem hizmetleri, sürücü yardımcı araçları, geliştirici araç zincirleri, tescilli kütüphaneler, bazı kurum içi ikili paketler. Flatpak ile paketlenmiş kapalı kaynak uygulama musl konakta çalışır (§4).
- Waydroid her iki tabanda da çalışır; postmarketOS'ta v21.12'den beri desteklenir ve Duranium'da sysext yoluyla sunulmaktadır (**doğrulanmalı**). Waydroid'in kendisi konteyner içinde Android'in kendi kütüphanelerini taşıdığı için libc seçimi burada belirleyici değildir — ancak konak tarafındaki entegrasyon araçları etkilenebilir; ölçülmelidir.
- musl'un ikinci, daha az konuşulan etkisi **isim çözümlemesindedir**: musl'un NSS (`nsswitch.conf`) desteği yoktur. Guard'ın DNS katmanına yerleşmesi planlanıyorsa (A5), musl konakta bu ancak ağ katmanında yapılabilir; NSS modülü takmak bir seçenek değildir. Bu, mimariyi kısıtlar ama imkânsızlaştırmaz — hatta ağ katmanı zorlaması Guard için zaten daha güçlü seçenektir.

**Dürüst özet:** musl bir engel değil, bir **daraltmadır**. Daralttığı alan, OZERK'in birinci sınıf hedefi olmayan alandır (Flatpak dışı kapalı ikili yazılım). Ancak §8.3'ün "yasaklamıyoruz" vaadi, musl tabanında pratikte "birçok durumda çalışmayacak" anlamına gelir; seçim musl yönünde yapılırsa bu manifesto §6.14 uyarınca kullanıcıya açıkça söylenmelidir.

### 6. Fork değil downstream: hangi taban katkıyı kolaylaştırır?

[D3](0001-karar-kaydi.md#d3--upstream-öncelikli-strateji) bağlayıcıdır: fork son çaredir. Bu ölçütte iki taban da güçlüdür, ama farklı biçimlerde:

- **postmarketOS**, downstream'in downstream'i olmayı zaten yapıyor ve upstream'e katkıyı fiilen kanıtlıyor: musl üzerinde systemd desteğini upstream systemd'ye taşıdılar. `pmaports` yapısı bir dağıtımın üzerine ek paket ağacı koymayı kolaylaştırır. Küçük ve erişilebilir bir topluluk, OZERK'in yamalarının kabul görmesini hızlandırır. Riski: küçük topluluk = az yedek; kritik bakımcı kaybı hissedilir.
- **Mobian**, yapısal olarak "Debian'a geri erimeyi" hedefler; paketleri Debian'a yüklemeyi tercih eder. Bir OZERK katkısı Debian'a girerse etkisi Mobian'ın çok ötesine geçer — bu, D3'ün ruhuna en uygun sonuçtur. Riski: Debian'ın süreçleri yavaştır; mobil-özgü ve deneysel değişiklikler Debian'a kolay girmez, Mobian'da birikir.

Karşıt uçlar: **Alpine doğrudan** ve **Yocto/Buildroot**, upstream'e katkıyı azaltıp bakım yükünü OZERK'e yıkar; ikisi de D3 ile ters yönde çeker.

### 7. Guard için altyapı hazırlığı (nftables / cgroup / namespace)

Guard'ın (A5 / RFC-0005) ihtiyaç duyacağı temel yapı taşları — ağ namespace'leri, cgroup v2, nftables (`socket cgroupv2` eşleşmesi dahil), seccomp, landlock — **çekirdek düzeyinde her iki tabanda da aynıdır**; fark çekirdek yapılandırmasında ve kullanıcı alanı araçlarındadır. Her iki taban artık systemd kullandığından cgroup v2 devri, soket etkinleştirme ve birim başına ağ ayarları da paritededir.

Gerçek farklar şunlardır ve ölçülmelidir:

1. **Cihaz çekirdeklerinin yapılandırması.** Downstream/vendor çekirdeklerinde nftables modülleri, cgroup v2 denetleyicileri veya `CONFIG_NET_CLS_CGROUP` gibi seçenekler kapalı olabilir. Bu, dağıtımdan çok cihaz portuna bağlıdır — geniş cihaz havuzu (postmarketOS) burada hem avantaj hem risk demektir.
2. **İsim çözümleme yolu** (§5): musl'da NSS yok; systemd-resolved kullanımı ve konteyner içi çözümleme davranışı ölçülmelidir.
3. **Salt okunur taban ile politika depolama.** Duranium benzeri bir mimaride Guard'ın kural setleri `/etc` ve `/var`'da yaşamalıdır; `/usr` yazılamaz. Bu bir engel değil, bir tasarım kısıtıdır ve erken bilinmelidir.

### 8. Karar ölçütleri

Karar, aşağıdaki ağırlıklandırılmış ölçütlerle verilecektir. Her ölçüt **0–5** arası puanlanır; puan bir ölçüme veya belgelenmiş bir gözleme dayanmak zorundadır. Gerekçesi yazılmamış puan geçersizdir.

| # | Ölçüt | Ağırlık | Nasıl test edilir (0–5 puanın dayanağı) |
| --- | --- | --- | --- |
| Ö1 | **Cihaz desteği ve port ekosistemi** | 20 | A4 için aday cihazlardan kaçı bu tabanda `community` veya üstü seviyede destekleniyor? Mainline çekirdek oranı? Bir cihaz portunun bakımının canlılığı (son 12 ayda commit)? |
| Ö2 | **Güncelleme mimarisi olgunluğu (§10.3)** | 25 | §10.3'ün beş maddesinden kaçı tabanda **bugün** çalışır durumda? Çalışmayanlar için gereken iş, kişi-ay olarak tahmin edilebiliyor mu? Referans cihazda A/B güncelleme + kasıtlı bozuk güncelleme sonrası otomatik geri dönüş testi geçiyor mu? |
| Ö3 | **Flatpak ve portal desteği** | 15 | Referans cihazda 10 temel Flatpak uygulama kurulup çalışıyor mu? Dosya seçici, kamera ve konum portalları çalışıyor mu? Taban + 10 uygulama için toplam depolama ve boştaki RSS ölçümü |
| Ö4 | **Topluluk sürdürülebilirliği** | 15 | Son 12 ayda etkin katkıcı sayısı; güvenlik güncellemesi ortanca gecikmesi (örneklem CVE'ler üzerinden); finansman şeffaflığı; "otobüs faktörü" tahmini; sürüm takviminin öngörülebilirliği |
| Ö5 | **Katkı kolaylığı / downstream olabilirlik (D3)** | 15 | Deneme yaması: küçük ama gerçek bir mobil hata düzeltmesi gönderilir; ilk yanıt ve birleşme süresi ölçülür. OZERK'in ek paket ağacını taban araçlarıyla taşıyabilme kolaylığı |
| Ö6 | **Guard altyapı hazırlığı** | 10 | Aday cihaz çekirdeğinde nftables + cgroup v2 + ağ namespace desteği doğrulanır; uygulama-başı ağ namespace prototipi kurulur; suspend/resume ve pil etkisi ölçülür |
| | **Toplam** | **100** | |

**Ölçütlerin üzerinde duran kurallar (veto):**

- Hiçbir ağırlıklı toplam, manifestonun kırmızı çizgilerini ve §6 ilkelerini geçersiz kılamaz. Bir taban yalnızca kapalı bileşenlerle çalışabiliyorsa puanı ne olursa olsun elenir.
- D3 ile açıkça çelişen bir seçenek (taban dağıtımı fork etmek) puanlamaya girmez.
- §6.14 uyarınca, seçilen tabanın sınırları — musl'un daralttığı alan veya dar cihaz havuzu — özgürlük envanterinde ve kullanıcı belgelerinde açıkça yazılacaktır. Bu bir puan değil, bir yükümlülüktür.

**Ağırlıklar tartışmaya açıktır.** Yukarıdaki dağılım bir başlangıç önerisidir; Ö2'ye verilen en yüksek ağırlığın gerekçesi, §10.3'ün manifestoda somut ve ölçülebilir tek güvenlik taahhüdü olmasıdır. Ağırlıklar tartışma aşamasında değişebilir ama **karar puanlaması başladıktan sonra değiştirilemez**.

### 9. Ölçüm planı

Puanlamanın anlamlı olması için önce şu işler yapılmalıdır:

1. A4 aday cihaz listesinin kabaca belirlenmesi (kesin karar değil, ölçüm için 2–3 cihaz).
2. Her aday tabanın seçilen cihaz(lar)a kurulması ve §8'deki testlerin koşulması.
3. Ö5 için her iki tabana birer gerçek yama gönderilmesi.
4. Ölçüm sonuçlarının bu RFC'ye ek olarak yayımlanması; puanlar ancak ölçüm yayımlandıktan sonra verilir.

Bu ölçümler yapılmadan verilecek bir karar, manifestonun dürüstlük taahhüdüyle bağdaşmaz: "postmarketOS daha çok cihaz destekliyor" cümlesi, OZERK'in ilgilendiği cihazlarda doğru olmayabilir.

### 10. Doğrulama notu ve kaynaklar

Aşağıdaki tespitler dış kaynaklardan derlenmiştir ve karar günü yeniden doğrulanmalıdır. "**doğrulanmalı**" işaretli her ifade için birincil kaynak (proje deposu, wiki, sürüm notu) aranmalıdır.

- postmarketOS v25.06 ve systemd: [postmarketos.org/blog/2025/06/22/v25.06-release/](https://postmarketos.org/blog/2025/06/22/v25.06-release/)
- postmarketOS v25.12 (Alpine 3.23, apk3, systemd 259): [postmarketos.org/blog/2025/12/23/v25.12-release/](https://postmarketos.org/blog/2025/12/23/v25.12-release/)
- postmarketOS v26.06 (Alpine 3.24, systemd 261, 254 testing cihazı): [postmarketos.org/blog/2026/06/21/v26.06-release/](https://postmarketos.org/blog/2026/06/21/v26.06-release/)
- Duranium: [postmarketos.org/blog/2026/03/17/introducing-duranium/](https://postmarketos.org/blog/2026/03/17/introducing-duranium/)
- systemd'de deneysel musl desteği: [phoronix.com/news/systemd-musl-libc](https://www.phoronix.com/news/systemd-musl-libc), [theregister.com/2025/11/20/rc_systemd_259/](https://www.theregister.com/2025/11/20/rc_systemd_259/)
- Mobian cihaz listesi ve yol haritası: [wiki.debian.org/Mobian/Devices](https://wiki.debian.org/Mobian/Devices), [wiki.debian.org/Teams/Mobian/Roadmap](https://wiki.debian.org/Teams/Mobian/Roadmap)
- Mobian Trixie sürümü: [blog.mobian.org/posts/2025/10/new-stable-rotating-keys/](https://blog.mobian.org/posts/2025/10/new-stable-rotating-keys/)
- Fedora Mobility SIG ve Pocketblue: [fedoraproject.org/wiki/Mobility](https://fedoraproject.org/wiki/Mobility), [gitlab.com/fedora/sigs/mobility](https://gitlab.com/fedora/sigs/mobility)
- Mobile NixOS: [mobile.nixos.org](https://mobile.nixos.org/)
- Alpine'da Flatpak ve glibc programları: [wiki.alpinelinux.org/wiki/Flatpak](https://wiki.alpinelinux.org/wiki/Flatpak), [wiki.alpinelinux.org/wiki/Running_glibc_programs](https://wiki.alpinelinux.org/wiki/Running_glibc_programs)
- postmarketOS Waydroid: [wiki.postmarketos.org/wiki/Waydroid](https://wiki.postmarketos.org/wiki/Waydroid)

## Alternatifler

Bu bölüm adayları değil, **karar stratejilerini** değerlendirir; adaylar §2'de karşılaştırılmıştır.

**S1 — Tek taban seçmek (§8 ölçütleriyle).** Önerilen yol. Kaynakları tek yere yoğunlaştırır, güncelleme mimarisi gibi derin işlerin tamamlanmasını mümkün kılar. Bedeli: yanlış seçimin maliyeti yüksektir ve geri dönüş pahalıdır.

**S2 — İki tabanla paralel yürümek.** [RFC-0001](0001-karar-kaydi.md)'de anılan seçenek. Öğrenme değeri gerçektir, ancak §10.3'ün gerektirdiği güncelleme mimarisi işi iki kez yapılacağı için Aşama 2'nin tamamlanmasını büyük olasılıkla imkânsız kılar. Tek kişilik bir projede bu seçenek dürüst değildir.

**S3 — Tabandan bağımsız katman.** OZERK'in kendi katmanını (Guard, manifest, repository) taban-agnostik yazmak ve taban kararını sonsuza dek ertelemek. Kulağa çekici gelir ama §10.3 taban-agnostik yazılamaz: güncelleme mimarisi tam olarak tabanın kendisidir. Kısmen benimsenebilir — Guard ve SDK taban-agnostik tutulmalıdır — ama taban kararının yerine geçmez.

**S4 — Yocto/Buildroot ile kendi imajını üretmek.** §2.3'te tartışıldı. Aşama 6'nın ticari cihazı için yeniden değerlendirilebilir; Aşama 1–5 için topluluk ve geliştirici erişilebilirliğini kırar.

**S5 — Hiçbir şey yapmamak (kararı ertelemek).** Aşama 0 belgeleri taban kararı olmadan tamamlanabilir; `ozerk` CLI iskeleti de tabandan bağımsızdır (D5). Yani karar bugün *acil* değildir. Ancak Aşama 1'in ilk satırı yazıldığı anda acil hâle gelir ve o noktada ölçüm yapacak zaman kalmaz. Bu nedenle **erteleme yalnızca §9'daki ölçüm planı yürürken savunulabilir**; ölçümsüz erteleme, kararı tesadüfe bırakmaktır.

## Açık Sorular

1. **Ağırlıklar doğru mu?** §8'deki 20/25/15/15/15/10 dağılımı bir öneridir. Güncelleme mimarisine verilen %25 fazla mı? Cihaz desteğine verilen %20 az mı? Tartışılmalıdır.
2. **Duranium ne zaman deneysel olmaktan çıkar?** postmarketOS'un `main` kategorisini yeniden tanımlama çalışmasıyla (pmCR 0009) ilişkisi nedir? OZERK'in takvimiyle örtüşüyor mu? Bu, Ö2'nin en belirsiz girdisidir.
3. **musl'un daralttığı alan pratikte ne kadar büyük?** §8.3'ün kapalı kaynak vaadi musl tabanında ne ölçüde boş bir vaade dönüşür? Kullanıcıların gerçekten ihtiyaç duyduğu Flatpak dışı kapalı ikili yazılım listesi çıkarılmalıdır.
4. **Waydroid'in her iki tabandaki durumu ölçülmedi.** Duranium'un salt okunur `/usr` mimarisinde Waydroid'in çalışma biçimi ve sysext yolu doğrulanmalıdır.
5. **Debian üzerinde §10.3'ü kurmanın maliyeti kişi-ay olarak nedir?** Bu tahmin yapılmadan Mobian ile postmarketOS adil karşılaştırılamaz. Bir Debian mobil A/B prototipi (systemd-sysupdate veya RAUC ile) kurulmalı mıdır?
6. **Taban kararı kabuk (shell) kararını ne kadar kısıtlıyor?** Bu RFC ikisini ayrı tutuyor; ayrı tutulabildikleri doğrulanmalıdır.
7. **Salt okunur taban ile geliştirici özgürlüğü (§12) ve yakınsak kullanım (§17) arasındaki gerilim nasıl çözülecek?** `coldbrew` benzeri bir yol yeterli mi, yoksa OZERK ayrı bir geliştirici modu mu tanımlamalı? Bu, muhtemelen kendi RFC'sini hak eder.
8. **Aday cihazlar kimler?** §9'un ölçüm planı A4'ün cihaz listesine bağımlıdır; iki RFC'nin sırası netleştirilmelidir.
9. **Seçilmeyen taban ne olur?** OZERK'in katmanı ikinci tabanda topluluk tarafından sürdürülebilir mi (desteklenmeyen ama engellenmeyen bir yol), yoksa bu bir dağıtım bölünmesi mi yaratır?

---

## English

# RFC 0002: Base Distribution Choice

> The Turkish text is normative in case of discrepancy.

- **Status:** Draft
- **Date:** 2026-08-17
- **Author(s):** OZERK founder

### Summary

This RFC addresses the open decision **A2 — Base distribution choice** from [RFC-0001](0001-karar-kaydi.md): which distribution will OZERK OS be built on?

This document is **not** a decision proposal. It compares the candidates honestly, surfaces the requirements the manifesto places on the base distribution, and defines the weighted, testable criteria by which the decision will be made. The decision itself will be written in a separate revision, after this document's discussion phase closes and the measurements in §9 have been carried out.

### Motivation

Choosing the base distribution is one of the most expensive decisions to change late. All of the following depend on it:

- **Packaging and the security update pipeline.** Which package manager, which security team, which CVE turnaround.
- **Device support.** Which pool of device ports the Phase 2 reference phone (manifesto §21) can be drawn from.
- **Update architecture.** Manifesto §10.3 asks for five things: signed full-system updates, A/B system partitions, automatic rollback on a failed update, a read-only base system, and verified system integrity. How buildable those five are *together* differs sharply by base.
- **libc choice.** musl or glibc — third-party binaries, Waydroid, closed-source applications (manifesto §8.3), and everything distributed outside Flatpak are affected.
- **The contribution path.** [D3](0001-karar-kaydi.md#d3--upstream-first-strategy) binds the upstream-first strategy: OZERK will be a downstream, not a fork. Which base makes that stance sustainable?
- **Guard's substrate.** The per-application network control of manifesto §9.2 requires specific facilities at the kernel and init layers.

If the decision is not made, Phase 1 (the emulator and developer system) cannot begin against any base; and if it begins anyway, most of that work will be thrown away.

An equally important second point: this decision is a **partnership, not a marriage**. OZERK's added value is not the lower layers but the user-sovereignty layer built on top of them. So alongside "which base is better", the criteria must also ask "on which base can what OZERK adds be given back upstream".

### Design

#### 1. Scope and limits of this document

**In scope:** the base distribution (package management, init, libc, device port pool, update architecture options, community).

**Out of scope:** the shell / desktop environment (Phosh, Plasma Mobile, GNOME Mobile), the browser engine (A1 / RFC-0004), the application package format (A3 / RFC-0003), reference hardware (A4 / RFC-0006), Guard's enforcement architecture (A5 / RFC-0005). This RFC only assesses whether a base **keeps those decisions open**.

**Timestamp on this document:** the findings below are as of August 2026 and are largely compiled from secondary sources. They must be re-verified on the day the decision is made; in a fast-moving ecosystem, a six-month-old table is misleading.

#### 2. Comparing the candidates

##### 2.1. postmarketOS

| Dimension | Status |
| --- | --- |
| Base / package management | Alpine Linux; `apk` (v25.12 moved to apk3 after five years of development) |
| libc | musl |
| Init | **systemd** — the default since v25.06 (June 2025); the systemd-less tradition has been left behind |
| Device support | The largest port pool in mobile Linux. The v26.06 announcement cites 254 devices in the `testing` category; `community` is smaller. Total counts vary by source — **to be verified** |
| Kernel situation | Mixed: mainline is the goal, but many ports still run downstream/vendor kernels. Varies per device |
| Update architecture | **Duranium** (March 2026): systemd-sysupdate + systemd-repart + systemd-verity-setup; A/B slots, read-only `/usr` backed by dm-verity, EROFS, mandatory LUKS2, automatic rollback on a failed boot. **Experimental**; Secure Boot / verified boot not yet present; requires UEFI (U-Boot); does not run on every pmOS device |
| Community | An independent project with public financial reporting and paid developer contracts. The team is small |

**Advantages for OZERK:** The widest device pool, leaving A4 (reference hardware) the most options. Duranium is the only known mobile Linux effort that gathers four of §10.3's five items in one place today. The mobile-focused toolchain (pmbootstrap) is mature. The project actually contributes upstream: musl support for systemd was carried into upstream systemd and landed experimentally in v259; pmOS now builds systemd without downstream musl patches — a live example of D3.

**Disadvantages for OZERK:** musl narrows third-party and closed-source binary compatibility at the system level (§5). Alpine's package pool is narrower than Debian's. systemd's musl support upstream is **experimental and comes with a long list of caveats** — this dependency chain must be watched. Duranium's device requirements (UEFI, two ~5 GB slots) exclude older devices with little storage.

##### 2.2. Mobian

| Dimension | Status |
| --- | --- |
| Base / package management | Debian; `apt` / `dpkg` |
| libc | glibc |
| Init | systemd (the Debian default) |
| Device support | Narrow and selective: PinePhone / PinePhone Pro / PineTab, Librem 5, Pixel 3a and 3a XL, OnePlus 6 / 6T, Poco F1; plus Fairphone 4 / 5, PineTab2 and SHIFT6mq with significant hardware limitations |
| Kernel situation | Mainline-first; the roadmap explicitly targets moving to mainline. Most supported devices run 6.12-class kernels (Trixie) |
| Update architecture | Classic `apt`. The roadmap contains **no** immutable / A/B / OSTree / atomic update items. The tooling exists in the Debian ecosystem (OSTree, RAUC, systemd-sysupdate), but there is no integrated mobile solution — that work would fall to OZERK |
| Community | Debian's vast infrastructure and security team; but Mobian's own developer count is low and the roadmap says so plainly ("limited development volunteers") |

**Advantages for OZERK:** glibc gives the least friction for third-party and closed-source software (manifesto §8.3 does not technically forbid closed source — which creates a compatibility obligation). Debian's package pool and security processes are mature; in institutional and public procurement a Debian base is familiar ground (manifesto §15). Mobian's stated goal is to be absorbed back into Debian — that is, it structurally encourages being a downstream, matching D3 exactly.

**Disadvantages for OZERK:** The device pool is narrow; it constrains A4's options early. The update architecture §10.3 requires would be **built from zero**, which creates tension with D3's "do not reinvent" principle: OZERK could end up carrying an image-based update architecture for Debian mobile largely alone. Debian's release cycle is slow relative to the pace of mobile hardware support.

##### 2.3. Other candidates

**Fedora (Mobility SIG / Pocketblue).** Conceptually the most mature ground for update architecture: OCI + OSTree + bootc, meaning immutability, atomic updates and rollback are built into the base itself, with applications delivered via Flatpak. The device list is narrow (Xiaomi Pad 5/6, OnePlus 6/6T, Poco F1, Orange Pi 3 LTS class), and Pocketblue is a community project, not a Red Hat product; the continuity risk sits there. The `rpm`/`dnf` ecosystem brings a packaging culture unfamiliar to OZERK. Fedora's fast release cadence is both an advantage and a maintenance load on mobile.

**Alpine directly (without postmarketOS).** Everything postmarketOS provides — device ports, `pmbootstrap`, mobile packages, shell integration — would have to be taken on by OZERK itself. This plainly contradicts D3; postmarketOS already *is* Alpine's mobile downstream and already does that work. It only becomes meaningful if the paths with postmarketOS diverge.

**A Yocto / Buildroot-based custom image.** This is where A/B + read-only + verified boot are solved most maturely, in the embedded world (engines such as RAUC, SWUpdate, Mender, OSTree, and Rugix Ctrl which reached 1.0 in 2026). It gives total control and is the natural path for Phase 6 (the commercial device). In return: there is no package pool, no general-purpose distribution's security update pipeline, and users cannot install their own software (tension with manifesto §12 developer rights and §17's convergent computing vision), while community contribution gets harder. It can be revisited later as a *product image* strategy; as the base of a **community operating system** it is not suitable today.

**Mobile NixOS.** Nix's generation model builds rollback and reproducibility into the nature of the base; this is the most direct answer to manifesto §6.4 (reproducible packages, independent build verification). The project is actively maintained (including the "Vanilla Mobile NixOS" effort), but the team is small. Nix rollback is **not block-level A/B**: it switches between system generations; automatic rollback on a failed boot and a dm-verity-verified read-only base must be built separately (there is work showing this is achievable with NixOS + systemd-repart + systemd-sysupdate — **to be verified**). The learning curve is steep and narrows the contributor pool.

#### 3. How can manifesto §10.3 be built, and on which base?

First, the honest finding:

> **No mobile Linux distribution today offers all five items of manifesto §10.3 together, in a stable (non-experimental) form, across a broad range of devices.** OZERK cannot inherit this clause as a finished feature; whichever base is chosen, part of this clause is work to be done.

There are three paths:

| Approach | How it works | Fit with the bases |
| --- | --- | --- |
| **OSTree / bootc** | Atomic commits at the filesystem level, tree switching, rollback. Not block-level A/B; it does not literally satisfy "A/B partition" but gives the functional equivalent | Native on Fedora. Can be retrofitted onto Debian/Ubuntu (community examples exist). No known mobile integration on Alpine |
| **RAUC / SWUpdate / Rugix** | The embedded world's classic block-level A/B solution; signed bundles, bootloader agreement, automatic rollback | Distribution-independent; most mature with Yocto/Buildroot. Can be set up on Debian, but bootloader integration is per-device work |
| **systemd-sysupdate + repart + verity** | Block-level A/B, a dm-verity-verified read-only partition, rollback via systemd-boot / gpt-auto | Possible on both bases, since both now use systemd. **Actually present on postmarketOS as Duranium** (experimental). No ready implementation on Debian/Mobian |

What this table means for OZERK:

- **postmarketOS + Duranium** is the only path that today actually delivers four of §10.3's five items (A/B, read-only base, automatic rollback, verified integrity). The missing leg is **verified boot**, and that is already part of the A4 paradox (mainline support and user-controlled verified boot rarely coexisting on the same device); this RFC does not solve it.
- **Mobian** offers not a *roadmap* for §10.3 but a *gap*. OZERK could fill that gap — but only by accepting that it would carry the work largely alone within the Debian mobile ecosystem.
- **Fedora Pocketblue** offers the cleanest conceptual ground, but as a base today it is a heavy bet because of device support and continuity risk.

Note also: Duranium's architecture removes the package manager from `/usr`; software arrives via Flatpak and `coldbrew` (a tool installing Alpine packages into the home directory inside a bubblewrap sandbox). This **aligns naturally** with A3's Flatpak-superset proposal, but it may create friction with manifesto §12's developer freedom and §17's convergent use (terminal, build tools, database clients). That friction must be measured.

#### 4. Flatpak and xdg-desktop-portal

Flatpak and portals are not a preference for OZERK but a **requirement**: A3's leading proposal is a Flatpak superset, and manifesto §9.1's "allow only selected items" behavior *is* the portal model.

- Flatpak runs on both Alpine/postmarketOS and Debian/Mobian. `xdg-desktop-portal` and its backends (GTK, KDE, wlr) are packaged on both sides.
- **musl's effect here is smaller than expected.** Standard Flatpak runtimes (freedesktop-sdk) carry their own glibc; therefore a glibc-dependent application runs fine inside Flatpak on a musl-based host. Flatpak is the **solution** to running glibc software on a musl host, not an obstacle to it.
- The cost: Flatpak packages consume more storage and RAM because they cannot share libraries with the base system. On a musl host that duplication is larger, since nothing can be shared between host and runtime. On phone-class devices this cost **must be measured** (§9, C3).
- The mobile behavior of portal backends (file chooser, contacts portal, location portal) depends on the shell choice on both bases; that is a shell decision, not a base decision.

**Conclusion:** On the Flatpak/portal axis there is no qualitative difference between the two bases; the difference is quantitative and measurable (memory/storage). This criterion matters but should not be decisive.

#### 5. glibc / musl and third-party compatibility

Manifesto §8.3 does **not** technically forbid closed-source applications; it labels them. That is a deliberate freedom choice, and it creates a technical obligation: when a user chooses to install a closed-source application, the system must be able to allow it.

- The overwhelming majority of closed-source binaries are built against glibc. On a musl host these do **not** run directly; compatibility layers such as `gcompat` are a partial answer and do not always suffice.
- This constraint mainly concerns software distributed **outside Flatpak**: system services, driver utilities, developer toolchains, proprietary libraries, some in-house institutional binaries. A closed-source application packaged as a Flatpak runs on a musl host (§4).
- Waydroid runs on both bases; it has been supported on postmarketOS since v21.12 and is offered on Duranium via sysext (**to be verified**). Because Waydroid carries Android's own libraries inside its container, the libc choice is not decisive there — but host-side integration tooling may be affected; this must be measured.
- musl's second, less-discussed effect is in **name resolution**: musl has no NSS (`nsswitch.conf`) support. If Guard is to sit in the DNS layer (A5), on a musl host that can only be done at the network layer; plugging in an NSS module is not an option. This constrains the architecture but does not make it impossible — indeed, network-layer enforcement is already the stronger option for Guard.

**Honest summary:** musl is not a barrier but a **narrowing**. The area it narrows is not OZERK's first-class target (closed binaries outside Flatpak). Nevertheless, §8.3's "we do not forbid it" promise means, on a musl base, "in many cases it will not work"; if the choice goes toward musl, this must be stated plainly to users under manifesto §6.14.

#### 6. Downstream, not a fork: which base makes contribution easier?

[D3](0001-karar-kaydi.md#d3--upstream-first-strategy) is binding: forking is a last resort. Both bases are strong on this criterion, but in different ways:

- **postmarketOS** already practises being a downstream's downstream, and it has demonstrated upstream contribution in practice: it carried musl support for systemd into upstream systemd. The `pmaports` structure makes it easy to layer an extra package tree over a distribution. A small, approachable community speeds up acceptance of OZERK's patches. The risk: a small community means little redundancy; losing a critical maintainer would be felt.
- **Mobian** structurally aims to "be absorbed back into Debian" and prefers uploading packages to Debian. If an OZERK contribution lands in Debian, its impact reaches far beyond Mobian — the outcome most faithful to D3's spirit. The risk: Debian's processes are slow; mobile-specific and experimental changes do not enter Debian easily and accumulate in Mobian.

At the opposite ends: **Alpine directly** and **Yocto/Buildroot** both reduce upstream contribution and shift the maintenance burden onto OZERK; both pull against D3.

#### 7. Substrate readiness for Guard (nftables / cgroup / namespace)

The basic building blocks Guard (A5 / RFC-0005) will need — network namespaces, cgroup v2, nftables (including `socket cgroupv2` matching), seccomp, landlock — are **identical at the kernel level on both bases**; the differences lie in kernel configuration and userspace tooling. Since both bases now use systemd, cgroup v2 delegation, socket activation and per-unit network settings are also at parity.

The real differences, which must be measured, are:

1. **Device kernel configuration.** On downstream/vendor kernels, nftables modules, cgroup v2 controllers, or options like `CONFIG_NET_CLS_CGROUP` may be disabled. This depends on the device port rather than the distribution — so a wide device pool (postmarketOS) is both an advantage and a risk here.
2. **The name resolution path** (§5): no NSS on musl; the use of systemd-resolved and in-container resolution behavior must be measured.
3. **Policy storage under a read-only base.** In a Duranium-like architecture, Guard's rule sets must live in `/etc` and `/var`; `/usr` is not writable. That is a design constraint rather than a blocker, and it must be known early.

#### 8. Decision criteria

The decision will be made using the weighted criteria below. Each criterion is scored **0–5**; a score must rest on a measurement or a documented observation. A score without a written rationale is invalid.

| # | Criterion | Weight | How it is tested (the basis for a 0–5 score) |
| --- | --- | --- | --- |
| C1 | **Device support and port ecosystem** | 20 | How many of the A4 candidate devices are supported at `community` level or above on this base? Share of mainline kernels? Liveness of a port's maintenance (commits in the last 12 months)? |
| C2 | **Update architecture maturity (§10.3)** | 25 | How many of §10.3's five items work on the base **today**? For those that do not, can the required work be estimated in person-months? On the reference device, does an A/B update plus deliberate-broken-update automatic rollback test pass? |
| C3 | **Flatpak and portal support** | 15 | Do 10 core Flatpak applications install and run on the reference device? Do the file chooser, camera and location portals work? Total storage and idle RSS measured for base + 10 applications |
| C4 | **Community sustainability** | 15 | Active contributors in the last 12 months; median security update latency (over a sample of CVEs); funding transparency; estimated bus factor; predictability of the release calendar |
| C5 | **Ease of contribution / being a downstream (D3)** | 15 | A trial patch: submit a small but real mobile bug fix and measure time to first response and to merge. How easily OZERK's extra package tree can be carried with the base's own tooling |
| C6 | **Guard substrate readiness** | 10 | Verify nftables + cgroup v2 + network namespace support in the candidate device kernel; build a per-application network namespace prototype; measure suspend/resume and battery impact |
| | **Total** | **100** | |

**Rules that override the criteria (veto):**

- No weighted total can override the manifesto's red lines or the §6 principles. A base that can only run with closed components is excluded regardless of its score.
- An option that plainly contradicts D3 (forking the base distribution) does not enter the scoring.
- Under §6.14, the limits of the chosen base — the area musl narrows, or a narrow device pool — will be written plainly in the freedom inventory and in user documentation. This is an obligation, not a score.

**The weights are open to discussion.** The distribution above is a starting proposal; the rationale for giving C2 the highest weight is that §10.3 is the manifesto's only concrete, measurable security commitment. The weights may change during the discussion phase, but **they cannot be changed once decision scoring has begun**.

#### 9. Measurement plan

For the scoring to mean anything, the following must happen first:

1. Roughly determine the A4 candidate device list (not a final decision; 2–3 devices for measurement).
2. Install each candidate base on the chosen device(s) and run the tests in §8.
3. For C5, submit one real patch to each of the two bases.
4. Publish the measurement results as an appendix to this RFC; scores are only assigned after the measurements are published.

A decision made without these measurements would not be compatible with the manifesto's honesty commitment: the sentence "postmarketOS supports more devices" may not be true for the devices OZERK actually cares about.

#### 10. Verification note and sources

The findings below are compiled from external sources and must be re-verified on decision day. For every statement marked "**to be verified**", a primary source (project repository, wiki, release note) must be sought.

- postmarketOS v25.06 and systemd: [postmarketos.org/blog/2025/06/22/v25.06-release/](https://postmarketos.org/blog/2025/06/22/v25.06-release/)
- postmarketOS v25.12 (Alpine 3.23, apk3, systemd 259): [postmarketos.org/blog/2025/12/23/v25.12-release/](https://postmarketos.org/blog/2025/12/23/v25.12-release/)
- postmarketOS v26.06 (Alpine 3.24, systemd 261, 254 testing devices): [postmarketos.org/blog/2026/06/21/v26.06-release/](https://postmarketos.org/blog/2026/06/21/v26.06-release/)
- Duranium: [postmarketos.org/blog/2026/03/17/introducing-duranium/](https://postmarketos.org/blog/2026/03/17/introducing-duranium/)
- Experimental musl support in systemd: [phoronix.com/news/systemd-musl-libc](https://www.phoronix.com/news/systemd-musl-libc), [theregister.com/2025/11/20/rc_systemd_259/](https://www.theregister.com/2025/11/20/rc_systemd_259/)
- Mobian device list and roadmap: [wiki.debian.org/Mobian/Devices](https://wiki.debian.org/Mobian/Devices), [wiki.debian.org/Teams/Mobian/Roadmap](https://wiki.debian.org/Teams/Mobian/Roadmap)
- Mobian Trixie release: [blog.mobian.org/posts/2025/10/new-stable-rotating-keys/](https://blog.mobian.org/posts/2025/10/new-stable-rotating-keys/)
- Fedora Mobility SIG and Pocketblue: [fedoraproject.org/wiki/Mobility](https://fedoraproject.org/wiki/Mobility), [gitlab.com/fedora/sigs/mobility](https://gitlab.com/fedora/sigs/mobility)
- Mobile NixOS: [mobile.nixos.org](https://mobile.nixos.org/)
- Flatpak and glibc programs on Alpine: [wiki.alpinelinux.org/wiki/Flatpak](https://wiki.alpinelinux.org/wiki/Flatpak), [wiki.alpinelinux.org/wiki/Running_glibc_programs](https://wiki.alpinelinux.org/wiki/Running_glibc_programs)
- postmarketOS Waydroid: [wiki.postmarketos.org/wiki/Waydroid](https://wiki.postmarketos.org/wiki/Waydroid)

### Alternatives

This section evaluates not the candidates but the **decision strategies**; the candidates are compared in §2.

**S1 — Choose a single base (using the §8 criteria).** The proposed path. It concentrates resources in one place and makes it possible to finish deep work such as the update architecture. The cost: a wrong choice is expensive and reversing it is costly.

**S2 — Run two bases in parallel.** The option mentioned in [RFC-0001](0001-karar-kaydi.md). The learning value is real, but because the update architecture work required by §10.3 would be done twice, it would most likely make completing Phase 2 impossible. In a one-person project this option is not honest.

**S3 — A base-independent layer.** Write OZERK's own layer (Guard, the manifest, the repository) base-agnostically and defer the base decision indefinitely. It sounds attractive, but §10.3 cannot be written base-agnostically: the update architecture *is* the base. It can be adopted partially — Guard and the SDK should be kept base-agnostic — but it does not substitute for the base decision.

**S4 — Build a custom image with Yocto/Buildroot.** Discussed in §2.3. It can be reconsidered for the Phase 6 commercial device; for Phases 1–5 it breaks community and developer accessibility.

**S5 — Do nothing (defer the decision).** The Phase 0 documents can be completed without a base decision, and the `ozerk` CLI skeleton is base-independent (D5). So the decision is not *urgent* today. But it becomes urgent the moment the first line of Phase 1 is written, and at that point there is no time left to measure. Therefore **deferral is only defensible while the measurement plan in §9 is running**; deferring without measurement means leaving the decision to chance.

### Open Questions

1. **Are the weights right?** The 20/25/15/15/15/10 distribution in §8 is a proposal. Is 25% for the update architecture too much? Is 20% for device support too little? This must be discussed.
2. **When does Duranium stop being experimental?** How does it relate to postmarketOS's work on redefining the `main` category (pmCR 0009)? Does it line up with OZERK's timeline? This is the most uncertain input to C2.
3. **How large is the area musl narrows, in practice?** To what extent does §8.3's closed-source promise become an empty promise on a musl base? A list of the non-Flatpak closed binaries users actually need should be produced.
4. **Waydroid's state on both bases has not been measured.** How Waydroid works under Duranium's read-only `/usr` architecture, and the sysext path, must be verified.
5. **What does building §10.3 on Debian cost in person-months?** Without that estimate, Mobian and postmarketOS cannot be compared fairly. Should a Debian mobile A/B prototype (with systemd-sysupdate or RAUC) be built?
6. **How much does the base decision constrain the shell decision?** This RFC keeps the two apart; that they *can* be kept apart must be verified.
7. **How will the tension between a read-only base and developer freedom (§12) / convergent use (§17) be resolved?** Is a `coldbrew`-like path enough, or should OZERK define a separate developer mode? This probably deserves its own RFC.
8. **Which are the candidate devices?** The measurement plan in §9 depends on A4's device list; the ordering of the two RFCs must be clarified.
9. **What happens to the base that is not chosen?** Can OZERK's layer be maintained on the second base by the community (an unsupported but unobstructed path), or would that create a distribution split?
