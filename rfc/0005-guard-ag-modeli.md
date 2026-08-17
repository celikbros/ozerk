# RFC 0005: OZERK Guard Ağ Modeli

**Türkçe** | [English](#english)

- **RFC:** 0005
- **Başlık:** OZERK Guard Ağ Modeli
- **Durum:** Taslak
- **Tarih:** 2026-08-17
- **Yazar(lar):** OZERK kurucusu
- **Lisans:** CC BY-SA 4.0
- **Karşıladığı açık karar:** [RFC-0001](0001-karar-kaydi.md) — A5
- **İlgili manifesto bölümleri:** 5, 6.3, 6.9, 7, 9 (tamamı), 10, 13, 23, 24
- **Bağlantılı RFC'ler:** [RFC-0002](0002-taban-dagitim.md) (taban dağıtım), [RFC-0003](0003-paket-formati.md) (paket formatı ve E/V/B sınıflandırması), [RFC-0004](0004-tarayici-motoru.md) (web runtime)

> **Doğrulama notu.** Bu belgedeki teknik iddialar 17 Ağustos 2026 tarihinde, mümkün olan her yerde **birincil kaynaklardan** doğrulanmıştır: çekirdek belgeleri (`docs.kernel.org`), man sayfaları, çekirdek ve nftables kaynak ağacı, IETF RFC metinleri, proje depoları ve proje SSS'leri. Blog yazıları yalnızca birincil kaynağın olmadığı yerde ve **açıkça ikincil** olarak anılmıştır. Doğrulanamayan her satır **"doğrulanmalı"** işaretlidir; bunlar iddia değil, yapılacak iş listesidir. **Bu belgede ölçülmemiş hiçbir sayı ölçülmüş gibi sunulmamıştır.** Özellikle pasta/passt'in pil ve gecikme maliyeti hakkında yayımlanmış bir ölçüm bulunamamıştır ve bu, uydurulmak yerine bir deney (E1) olarak tanımlanmıştır.

---

## Özet

Bu RFC, manifesto §9.2'nin beş ağ profilinin **hangi Linux mekanizmalarıyla, ne ölçüde zorlanabileceğini** tanımlar ve zorlanamayan kısmı gizlemek yerine adıyla anar.

Öneri üç cümlede:

1. **Guard ikiye ayrılır.** *Sert sınır*: uygulamanın ağa erişip erişemeyeceği — çekirdek düzeyinde ağ namespace izolasyonuyla zorlanır ve kararlı bir saldırgana karşı da geçerlidir. *Yumuşak sınır*: uygulamanın **kime** eriştiği — gözleme ve sistemin denetlediği isim çözümlemesine dayanır, kaçınılabilir ve garanti edilemez.
2. **Zorlama mimarisi: uygulama başına ağ namespace'i + `pasta` (passt) + sistemin denetlediği çözümleyici + çözümleyici-çapalı (resolver-anchored) nftables IP kümesi.** İzin verilen tek IP kümesi, Guard'ın kendi çözümleyicisinin izinli adlar için döndürdüğü adreslerdir. Bu tasarım, sabit IP literallerini ve uygulama içi DoH'u profil 1–3 için **yapısal olarak** etkisizleştirir.
3. **Model, "zorlayıcı içerik denetimi" değildir.** Manifesto §9.2 sahte kök sertifika yerleştirmeyi yasaklar; bu doğru karardır ve bedeli şudur: Guard **akış metaverisini** görür, içeriği görmez. Dolayısıyla Guard'ın dürüst adı şudur: **dürüst uygulamaları şeffaflaştırır, tembel kötüleri etkisizleştirir; kararlı bir saldırganı durdurmaz.**

Bu üçüncü cümle bu belgenin omurgasıdır ve pazarlama diline çevrilmesi yasaktır.

**En sert bulgu baştan söylenmelidir.** Aynı işi ticari olarak yapan, eBPF tabanlı bir ürün — Little Snitch for Linux — kendi sayfasında şunu yazar: *"Little Snitch for Linux is built for privacy, not security, and that distinction matters."* ve *"Under heavy traffic, cache tables can overflow, which makes it impossible to reliably tie every network packet to a process or a DNS name."* ve *"reconstructing which hostname was originally looked up for a given IP address requires heuristics rather than certainty"* ve *"For hardening a system against a determined adversary, it's not the right tool."*

OZERK'in bu ürüne göre **iki yapısal üstünlüğü** vardır ve yalnızca bu ikisi iddia edilebilir: (a) Guard uygulamayı kendisi başlatır, dolayısıyla süreç↔bağlantı eşlemesini çıkarımla değil **doğuştan** bilir; (b) uygulama zaten bir sandbox içindedir, dolayısıyla ağ namespace'i kurmak sonradan giydirilen bir katman değil, var olan sandbox'ın bir alanıdır. Bunların dışında, yukarıdaki cümleler OZERK için de aynen geçerlidir.

---

## Motivasyon

Manifesto §9.2 beş ağ profili tanımlar ve kullanıcıya beş şey vaat eder (bağlanılan alan adı, bağlantı zamanı, veri miktarı, engellenen istekler, yeni hedefler). **Uygulama mekanizmasını hiç tartışmaz.** [RFC-0003](0003-paket-formati.md) bu boşluğu bilerek bıraktı ve şu dürüst tespiti yaptı:

> **bugün Flatpak ile 1 ve 4 gerçek, 2 ve 3 vaattir.**

Bu RFC o boşluğu kapatmak zorundadır, çünkü:

- **Guard projenin amiral özelliğidir.** [RFC-0001](0001-karar-kaydi.md) A5: "zorlanamayan bir vaat, manifestonun dürüstlük taahhüdünü ihlal eder." Değerlendirmede tespit edilen en büyük itibar riski tam da budur: Guard'ı olduğundan güçlü göstermek.
- **Yol haritası bir tarih vermiştir.** Ay 4–8 dönemi, D2 demo kapısıyla kapanır: *"Guard'ın canlı bir gösterimde, seçilen bir uygulamanın belirli bir alan adına erişimini engellemesi ve bu olayın günlükte görünmesi."* Bu gösterimin hangi mekanizmayla yapılacağı ve neyi **kanıtlamadığı** önceden yazılmalıdır.
- **Karar geciktikçe yanlış mimari yerleşir.** Uygulama başına ağ namespace'i ile nftables/cgroup filtresi arasındaki seçim, uygulamanın nasıl başlatıldığını belirler; bu, sonradan değiştirilmesi en pahalı karardır.
- **Taban dağıtım kararı buna bağlıdır.** [RFC-0002](0002-taban-dagitim.md) Ö6 ölçütü ("Guard altyapı hazırlığı") ancak Guard'ın hangi çekirdek özelliklerine ihtiyaç duyduğu yazıldıktan sonra puanlanabilir.

Ve en önemlisi: **§9.2'nin sahte sertifika yasağı, modelin ne olabileceğini baştan sınırlar.** Bu yasak doğrudur — kullanıcı cihazına bir kök sertifika yerleştirip HTTPS'i çözmek, kırmızı çizgi 15'in ("kullanıcıyı cihazının kiracısına dönüştürmek") teknik hâlidir, saldırı yüzeyini devasa büyütür ve sertifika sabitlemesi (pinning) kullanan her uygulamayı kırar. Ama bedeli açıktır: **Guard'ın görebildiği şey akış metaverisidir; içerik değildir.** Bu RFC bu düşüşü kabul eder ve modeli bu gerçeğin üzerine kurar.

---

## Tasarım

### 1. Tehdit ve kapsam modeli

Bu bölüm belgenin omurgasıdır. Guard'ın neye karşı koruduğu ile neye karşı korumadığı arasındaki ayrım, mimarinin geri kalanını belirler.

#### 1.1. İki farklı sınır

Guard tek bir şey değildir. İki farklı güç sınıfına sahip iki mekanizmadır ve bunlar arayüzde de belgede de **asla aynı ağırlıkta sunulamaz**.

| | **Sert sınır** | **Yumuşak sınır** |
|---|---|---|
| Soru | Uygulama ağa erişebilir mi? | Uygulama **kime** erişebilir? |
| Mekanizma | Çekirdek düzeyinde ağ namespace izolasyonu | İsim çözümlemesinin denetimi + IP düzeyinde filtre |
| Dayanağı | Uygulamanın erişebileceği bir ağ arayüzü yoktur | Uygulamanın hedefi tahmin edilir; tahmin doğru olmayabilir |
| Kaçınılabilir mi? | **Hayır.** Çekirdek açığı gerektirir. | **Evet.** §4'te sayılan vektörlerle. |
| Kime karşı geçerli | Kararlı saldırgan dahil herkes | Yalnızca kaçınmaya çalışmayan yazılım |
| Manifesto profili | 1 (ve 4'ün "yok" hâli) | 2, 3 |

#### 1.2. Guard neye karşı koruma sağlar

Manifesto §10.1'in listesinden Guard'ın gerçekten karşıladığı kısım:

1. **Kullanıcının bilgisi dışında veri gönderen meşru-görünümlü uygulama.** Uygulama kötü niyetli değildir; yalnızca beyan etmediği bir sunucuya bağlanır. Guard bunu görür, kaydeder, profil 2–3'te engeller ve beyanla çelişkiyi (§13) tespit edilebilir kılar. **Guard'ın birincil hedefi budur.**
2. **Reklam ve izleme SDK'ları.** Bunlar gizlenmeye çalışmaz; bilinen uç noktalara, bilinen adlarla, düz DNS ile bağlanırlar. Guard'ın etkili olduğu ikinci alan budur.
3. **Arka planda sessiz aktarım.** Uygulama kapalıyken veya ekran kapalıyken yapılan bağlantılar; zaman damgalı kayıt bunları görünür kılar.
4. **Kaza eseri geniş yetki.** Bir kütüphanenin, geliştiricinin haberi olmadan bir telemetri uç noktasına bağlanması. Guard bunu geliştiriciye de gösterir; bu, `ozerk` araç zincirinin bir özelliğidir.
5. **Ağa hiç ihtiyacı olmayan uygulamanın ağa erişmesi.** Profil 1. Bu, listedeki tek **sert** korumadır ve en değerlisidir: bir hesap makinesi, bir okuyucu, bir yerel not uygulaması için ağ erişimi hiç yoktur ve bu iddia mutlaktır.

#### 1.3. Guard neye karşı koruma SAĞLAMAZ

Bu liste manifesto §10.2'nin ("açıkça kabul edilen sınırlar") ağ karşılığıdır ve arayüzde erişilebilir olmak zorundadır (§9.4).

1. **Kararlı biçimde kaçınmaya çalışan kötü niyetli uygulama.** Uygulama profil 2'de izinli bir adrese bağlanıp oradan vekil (proxy) kullanabilir; verisini DNS sorgularına gömebilir; izinli bir CDN IP'sinin arkasındaki başka bir kiracıya ulaşabilir. **Guard bunu durduramaz ve durdurabileceğini iddia etmez.**
2. **İçerik.** Bir bağlantının olduğu, hedefi, zamanı ve boyutu görülür; **ne gönderildiği görülmez.** Sahte sertifika yasağının doğrudan sonucudur (§9.2, [RFC-0003](0003-paket-formati.md) §6/Sınıf B).
3. **Sunucu tarafındaki davranış.** Veri alıcıya ulaştıktan sonra ne yapıldığı gözlemlenemez.
4. **Sistem uygulamaları dışındaki dolaylı yollar.** Uygulama, kendisi ağa çıkmak yerine ağ erişimi olan başka bir bileşene iş yaptırabilir. Bu, Android'de belgelenmiş bir gerçektir (NetGuard SSS 19) ve GrapheneOS'un "doğrudan **ve dolaylı** erişim" tasarımının varlık nedenidir. OZERK bu tasarımı benimser (§8.4) ama kapsamı, portalların ve D-Bus politikasının kapsadığı kadardır.
5. **Guard'ın başlatmadığı süreçler.** Guard'ın gücü, uygulamayı **kendisinin başlatmasından** gelir. Kullanıcının terminalden çalıştırdığı bir ikili, geliştirici modundaki bir süreç veya bir sistem hizmeti Guard'ın uygulama-başı modelinin dışındadır. Bu, NetGuard'ın "erken açılışta koruma yoktur" sınırının OZERK'teki karşılığıdır ve gizlenmez.
6. **Çekirdek ve firmware.** Manifesto §10.2 zaten kabul eder; Guard bir istisna getirmez.

#### 1.4. Net cevap

> **Guard, dürüst uygulamaları şeffaf ve tembel kötüleri etkisiz kılar. Kararlı bir saldırganı durdurduğunu iddia etmez.**
>
> Tek istisna profil 1'dir: ağ erişimi olmayan bir uygulama, kararlı olsa da ağa çıkamaz. Bu, Guard'ın verdiği **tek mutlak** güvencedir ve tam da bu yüzden en çok teşvik edilmesi gereken profildir.

Bu cümle, mağazada, Gizlilik Merkezi'nde ve tanıtım metinlerinde **kısaltılmadan** kullanılabilir olmalıdır. Kısaltılırsa yanlış olur.

---

### 2. Zorlama mimarisi: somut Linux mekanizmaları

Bu bölüm, uygulama başına ağ izolasyonunun bugün hangi mekanizmalarla kurulabileceğini karşılaştırır. Her mekanizma için: hangi profili zorlayabilir, çekirdek gereksinimi, maliyet, Flatpak ile ilişkisi.

#### 2.1. Ağ namespace'i + kullanıcı alanı ağ geçidi (pasta / passt)

**Nedir.** Uygulama kendi ağ namespace'inde başlatılır. Namespace'in dışarıyla bağlantısı, ayrıcalık gerektirmeyen bir kullanıcı alanı ağ geçidiyle kurulur.

`pasta`, `passt` ikilisinin ikinci komut adıdır. Proje kendini şöyle tanımlar: passt *"a translation layer between a Layer-2 network interface and native Layer-4 sockets"*; pasta ise *"equivalent functionality, for network namespaces"*. `pasta(1)`'e göre: *"A tap device within the network namespace is created to provide network connectivity"* ve *"For local TCP and UDP traffic only, pasta also implements a bypass path directly mapping Layer-4 sockets between init and target namespaces, for performance reasons"* — bu yol TCP için `splice(2)`, UDP için `recvmmsg(2)`/`sendmmsg(2)` kullanır.

**Ayrıcalık gereksinimi — bu mimarinin belirleyici özelliğidir.** Tap cihazı namespace'in **içinde** oluşur; proje bunu *"without the need to create further interfaces on the host, hence not requiring any capabilities or privileges"* diye yazar. passt/pasta ayrıca `CAP_NET_RAW` olmadan çalışır ve `CAP_NET_BIND_SERVICE` dışındaki tüm yetenekleri bırakır. Dinamik bellek ayırma seccomp ile engellenir; AppArmor ve SELinux profilleri projeyle birlikte gelir.

Bu, [RFC-0003](0003-paket-formati.md)'ün Flatpak tabanına doğrudan oturur ve xdg-desktop-portal tartışmasındaki tıkanıklığın çözümüdür. Flatpak bakımcısı `mwleeds`, ağ izni ayrıntılandırmasının neden yapılamadığını şöyle açıklamıştı: *"kernel APIs require root to do network namespacing, and Flatpak runs unprivileged."* `smcv` ise gerekli mimariyi tarif etmişti: *"unsharing the network namespace, having some sort of bridge (slirp4netns or similar) between the app's netns and the host machine's netns, and then having that bridge be remote-controllable so it will selectively block or allow traffic under xdg-desktop-portal's control."* **pasta tam olarak bu köprüdür ve ayrıcalık gerektirmez.**

**DNS kancası ücretsiz gelir.** `pasta(1)`: `--dns-forward addr` — *"Map addr … as seen from guest or namespace to the nameserver … specified by the --dns-host option. Maps only UDP and TCP traffic to port 53 or port 853"*. Yani uygulama-başı DNS yakalama, ayrı bir NAT kuralı yazmadan, L4 sınırında yapısal olarak elde edilir. **Bu, isnat (attribution) sorununu çıkarımla değil mimariyle çözer** — OpenSnitch'in `/proc` taraması ve libc uprobe'larıyla uğraştığı şey burada tanım gereği bilinmektedir.

**Olgunluk.** Podman, pasta'yı **v4.4.0**'da seçenek olarak ekledi, **v5.0.0**'da köksüz (rootless) konteynerlerin **varsayılanı** yaptı: *"The default tool for rootless networking has been swapped from `slirp4netns` to `pasta` for improved performance."* (Podman 5.3'te varsayılan olduğu iddiası yanlıştır; birincil kaynak 5.0.0'dır.) Resmî paketleri olan dağıtımlar arasında Alpine, Debian, Fedora, openSUSE, Ubuntu, Arch, Gentoo, Void bulunur — yani hem postmarketOS hem Mobian tabanında hazırdır.

**Maliyet — ölçülmemiştir.** Projenin kendi iddiası *"4 to 50 times IPv4 TCP throughput of existing, conceptually similar solutions depending on MTU"*'dur. **Bu bir oran iddiasıdır ve karşılaştırma tabanı slirp benzeri çözümlerdir, veth/bridge değildir.** Yani "pasta veth'e göre %X pahalıdır" demek için kullanılamaz. Projenin veya Podman'ın yayımladığı, veth/bridge'e karşı bir karşılaştırma tablosu **bulunamamıştır**; ARM üzerinde kullanıcı alanı TCP'nin CPU maliyetine dair güvenilir bir ölçüm de **bulunamamıştır**. Podman izleyicisinde pasta CPU yükü hakkında açık raporlar vardır ancak bunlar ölçüm değil, hata kaydıdır ve sayı olarak alıntılanamaz. **Bu bir boşluktur ve E1 deneyiyle kapatılacaktır. Bu RFC bu konuda hiçbir sayı vermez.**

**slirp4netns karşılaştırması.** slirp4netns, namespace içinde bir tap arkasında libslirp'in tam kullanıcı alanı TCP/IP yığınını çalıştırır ve NAT yapar; her paket öykünülmüş bir yığından geçer. pasta konağın adresleme ve yönlendirmesini namespace'e yansıtır (NAT yok) ve yerel trafiği `splice()` ile kısa devre eder. İkisi de ayrıcalıksızdır. OZERK için pasta tercih edilir; slirp4netns yedek yoldur.

**veth + bridge (klasik yol).** Çekirdek veri yolu, en düşük CPU maliyeti. Ama `CAP_NET_ADMIN` gerektirir, yani ayrıcalıklı bir yardımcı süreç demektir. Bu, Flatpak'ın ayrıcalıksız çalışma modelini bozar ve saldırı yüzeyini büyütür. **Reddedilir**; ancak Guard'ın kendi sistem hizmetleri (A sınıfı) için değerlendirilebilir.

| Boyut | Değerlendirme |
|---|---|
| Zorlayabildiği profiller | **1, 2, 3, 4** — hepsi |
| Çekirdek gereksinimi | Kullanıcı ve ağ namespace'leri (`CONFIG_USER_NS`, `CONFIG_NET_NS`); Flatpak zaten bunları kullanır |
| Ayrıcalık | Yok |
| Flatpak ile | Doğal: uygulama zaten bwrap ile başlatılıyor; `--unshare-net` verilip ağ geçidi namespace'e bağlanır |
| Maliyet | **Ölçülmemiş** (E1). Kullanıcı alanı veri yolu; suspend/resume davranışı da ölçülmelidir |
| Ek kazanç | Uygulama-başı DNS yakalama (`--dns-forward`); konak abstract unix soketlerine erişimin kapanması (aşağı bakınız) |

**Yan fayda: Flatpak'ın localhost deliği kapanır.** Flatpak belgeleri şu dipnotu taşır: *"Giving network access also grants access to all host services listening on abstract Unix sockets (due to how network namespaces work), and these have no permission checks."* xdg-desktop-portal tartışmasında `swick` bunu somutlaştırır: *"the big issue with flatpak networking right now is that it has the exact same access as the host and can connect and expose tcp and udp services on all of localhost … all flatpak'ed apps can access, and man-in-the-middle it as well."* Uygulama başına ayrı bir ağ namespace'i bu sınıf sorunu **tasarım gereği** çözer. Bu tek başına, maliyeti ne olursa olsun, mimariyi savunmak için yeterli bir gerekçedir.

#### 2.2. cgroup v2 + nftables `socket cgroupv2` eşleşmesi

**Sözdizimi** (`nft(8)`, SOCKET EXPRESSION bölümünden birebir):

```
table inet x {
    chain y {
        type filter hook input priority filter; policy accept;
        socket cgroupv2 level 1 "user.slice" counter
    }
}
```

**Seviye anlamı** (`nft(8)`'den birebir): *"You can also use it to match on the socket cgroupv2 at a given ancestor level, e.g. if the socket belongs to cgroupv2 a/b, ancestor level 1 checks for a matching on cgroup a and ancestor level 2 checks for a matching on cgroup b."* Yani seviye, verilen yolun kök'ten itibaren kaç bileşenli olduğudur ve yol dizgisindeki bölüm sayısına eşit olmalıdır.

**Sürümler.** Çekirdek tarafı **5.13** (Pablo Neira Ayuso, "netfilter: nft_socket: add support for cgroupsv2", `NFTA_SOCKET_LEVEL`). Kullanıcı alanı **nftables 0.9.9** (sürüm duyurusunda "cgroupsv2 support" olarak listelenir; 0.9.4'te yoktur).

**Üç ciddi kısıt — ikisi man sayfasında yazmaz, kaynaktan okunmuştur:**

1. **Yol→kimlik çözümlemesi kullanıcı alanında, kural yüklenirken yapılır.** nftables `src/datatype.c`, cgroup yolunu `stat()` ile açar ve **inode numarasını** kurala gömer; çekirdek yalnızca 64 bitlik sayısal bir cgroup kimliğini karşılaştırır. Sonuçları:
   - Kural yüklenirken cgroup **var olmak zorundadır**, yoksa yükleme `cgroupv2 path fails: No such file or directory` ile başarısız olur.
   - **cgroup silinip yeniden oluşturulursa yeni bir inode numarası alır ve yüklenmiş kural sessizce eşleşmeyi bırakır.** Kural hâlâ ölü kimliği gösterir. Bu kısıt `nft(8)`'de belgelenmemiştir.
2. **Kancalar yalnızca PREROUTING, INPUT ve OUTPUT'tur.** Çekirdekte `nft_socket_validate()`, bu üçü dışındaki kancaları `-EOPNOTSUPP` ile reddeder. FORWARD ve POSTROUTING kullanılamaz — yönlendirilen paketin yerel soketi olmadığı için bu doğrudur.
3. Soketin çözülebilmesi ve namespace'in eşleşmesi gerekir; eşleşmezse kural `NFT_BREAK` verir. Seviye numaralandırması, geçerli cgroup namespace'inin köküne göre yeniden temellendirilir.

**Bu kısıtların OZERK için anlamı — kritik.** Flatpak, systemd varken uygulama süreçlerini geçici (transient) bir systemd kapsamına koyar. Flatpak belgeleri kalıbı şöyle verir: *"When systemd is available, Flatpak tries to put app processes in a scope such as `app-flatpak-com.brave.Browser-*.scope`"* — yıldız *"replaced by an arbitrary suffix"*. Yani **her uygulama örneği için cgroup yolu farklıdır ve her başlatmada yeniden oluşturulur.**

Sonuç: `socket cgroupv2` kuralları **statik olarak yazılamaz**. Guard, her uygulama başlatmasında kuralı yeniden yüklemek zorundadır ve kapsamın oluşturulmasıyla kuralın yüklenmesi arasında bir **yarış penceresi** vardır; o pencerede uygulama zaten bağlantı kurabilir. Bu pencere ölçülmelidir (E2). Bu, mekanizmayı elemez ama **tek başına yeterli olmadığını** gösterir: uygulama başına namespace'te böyle bir yarış yoktur, çünkü namespace uygulama var olmadan önce kurulur.

| Boyut | Değerlendirme |
|---|---|
| Zorlayabildiği profiller | 1 (zayıf biçimde), 2, 4 — IP/port düzeyinde |
| Çekirdek gereksinimi | 5.13+, `nft_socket`, cgroup v2 |
| Kullanıcı alanı | nftables ≥ 0.9.9 |
| Ayrıcalık | Kural yüklemek için `CAP_NET_ADMIN` (sistem hizmeti) |
| Flatpak ile | Kapsam adı örnek başına rastgeledir → kurallar başlatma başına yüklenmeli; yarış penceresi var |
| Maliyet | Düşük; çekirdek veri yolu |
| En büyük tehlike | Yeniden oluşturulan cgroup'ta kuralın **sessizce** eşleşmeyi bırakması |

#### 2.3. eBPF cgroup kancaları

Doğrulanmış kanca–sürüm eşlemesi (`docs.kernel.org/bpf/libbpf/program_types.html` ve kernelnewbies sürüm notları):

| ELF bölümü | Program türü | Attach türü | Çekirdek |
|---|---|---|---|
| `cgroup/sock_create` | `BPF_PROG_TYPE_CGROUP_SOCK` | `BPF_CGROUP_INET_SOCK_CREATE` | 4.10 |
| `sockops` | `BPF_PROG_TYPE_SOCK_OPS` | `BPF_CGROUP_SOCK_OPS` | 4.13 |
| `sk_skb` | `BPF_PROG_TYPE_SK_SKB` | (sockmap) | 4.14 |
| `cgroup/bind4` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_INET4_BIND` | 4.17 |
| `cgroup/connect4` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_INET4_CONNECT` | 4.17 |
| `cgroup/connect6` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_INET6_CONNECT` | 4.17 |
| `cgroup/sendmsg4` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_UDP4_SENDMSG` | 4.18 |
| `cgroup/skb` | `BPF_PROG_TYPE_CGROUP_SKB` | `BPF_CGROUP_INET_{INGRESS,EGRESS}` | 4.10 |

**Bu kancalar yalnızca izin/ret değildir; adres yeniden yazabilirler.** Özgün yama kapak yazısı, kancaların *"let bpf prog look and modify 'struct sockaddr' provided by user space"* olduğunu söyler. Yani `connect4`/`connect6`, hedef IP ve portu şeffaf biçimde değiştirebilir (Cilium'un hizmet yük dengelemesinin mekanizması budur) ve `sendmsg4/6` aynısını bağlantısız UDP için yapar. **Guard için anlamı: uygulamanın ayarını değiştirmeden, uygulamayı yerel bir vekile yönlendirmek mümkündür.** `sock_create` ise izin/ret ve sınırlı soket alanı değişikliğidir, adres çevirisi değildir.

**systemd bu kancaları zaten sarmalar** (`systemd.resource-control(5)`):

| Seçenek | systemd'nin kendi ifadesi | Sürüm |
|---|---|---|
| `IPAddressAllow=` / `IPAddressDeny=` | *"Turn on network traffic filtering for IP packets sent and received over AF_INET and AF_INET6 sockets"* | **v235** |
| `SocketBindAllow=` / `SocketBindDeny=` | *"The feature is implemented with cgroup/bind4 and cgroup/bind6 cgroup-bpf hooks."* | **v249** |
| `RestrictNetworkInterfaces=` | *"The feature is implemented with cgroup/sock_create cgroup-bpf hooks."* | **v250** |

**Ve bu, Flatpak ile doğrudan birleşir.** Flatpak belgeleri, uygulama başına kalıcı kaynak denetimini şöyle tarif eder: `~/.config/systemd/user/app-flatpak-com.brave.Browser-.scope.d/memory.conf` oluşturulur ve `systemctl --user daemon-reload` sonrası *"those `systemd.resource-control(5)` parameters will apply to all instances of that app."*

> **Bulgu.** Guard, **kendi eBPF programını yazmadan**, uygulama kimliği başına bir systemd scope drop-in dosyası üreterek `IPAddressAllow=`/`IPAddressDeny=` ile uygulama-başı IP filtrelemesi uygulayabilir. Bu, §2.2'deki geçici-kapsam yarışını da çözer, çünkü drop-in dosyası kapsam adının **sabit önekine** yazılır ve her örneğe uygulanır.

Bu, Guard v1 için en düşük maliyetli, en az yeni kod gerektiren zorlama yoludur ve D3 (upstream-öncelik) ile tam uyumludur.

**Sınırlar.** systemd man sayfası bu seçenekler için **hiçbir asgari çekirdek sürümü belirtmez**; yalnızca *"these settings might not be supported on some systems (for example if eBPF control group support is not enabled in the underlying kernel…)"* der. `CONFIG_CGROUP_BPF`, `BPF_SYSCALL` ve `NET`'e bağlıdır. Satıcı (vendor) çekirdeklerinde kapalı olabilir — bu, [RFC-0002](0002-taban-dagitim.md) §7'nin 1. maddesinin tam olarak işaret ettiği risktir ve E6 ile ölçülecektir. Ayrıca `IPAddressAllow=` yalnızca **IP** düzeyindedir; alan adı sözlüğü yoktur.

#### 2.4. Landlock

**Doğrulanmış ABI tablosu** (`landlock(7)` ve `docs.kernel.org/userspace-api/landlock.html`):

| ABI | Çekirdek | Eklenen |
|---|---|---|
| 1 | 5.13 | Dosya sistemi hakları |
| 2 | 5.19 | `LANDLOCK_ACCESS_FS_REFER` |
| 3 | 6.2 | `LANDLOCK_ACCESS_FS_TRUNCATE` |
| **4** | **6.7** | **`LANDLOCK_ACCESS_NET_BIND_TCP`, `LANDLOCK_ACCESS_NET_CONNECT_TCP`** |
| 5 | 6.10 | `LANDLOCK_ACCESS_FS_IOCTL_DEV` |
| 6 | 6.12 | `LANDLOCK_SCOPE_ABSTRACT_UNIX_SOCKET`, `LANDLOCK_SCOPE_SIGNAL` |
| 7 | 6.15 | Denetim (audit) / günlükleme bayrakları |
| 8 | 7.0 | `LANDLOCK_RESTRICT_SELF_TSYNC` (iş parçacıkları arası zorlama) |
| 9 | 7.1 | `LANDLOCK_ACCESS_FS_RESOLVE_UNIX` |
| 10 | 7.2 | `LANDLOCK_ACCESS_NET_BIND_UDP`, `LANDLOCK_ACCESS_NET_CONNECT_SEND_UDP` |

> **Sorunun cevabı: Landlock'un TCP bind/connect desteği Linux 6.7'de, Landlock ABI 4 ile geldi.** UDP desteği önerilmiş değil, **inmiştir**: ABI 10. Çekirdek belgesi birebir: *"`LANDLOCK_ACCESS_NET_BIND_UDP`: Bind UDP sockets to the given local port. Support added in Landlock ABI version 10."*
>
> ABI 8–10 satırları çekirdek 7.x belgelerinden okunmuştur; bu sürümlerin hedef cihaz çekirdeklerinde bulunup bulunmadığı **doğrulanmalıdır** (E6).

**Ve Guard için belirleyici sınır:** *Landlock'ta ağ kuralının nesnesi bir **porttur**, bir adres değil.* Yapı `struct landlock_net_port_attr { __u64 allowed_access; __u64 port; }` — **adres alanı yoktur.** Çekirdek belgesi: *"For these rules, the object is a TCP or UDP port."* Dolayısıyla Landlock ile:

- ✅ "Bu uygulama hiçbir portu dinleyemez" ifade edilebilir,
- ✅ "Bu uygulama yalnızca 443'e bağlanabilir" ifade edilebilir,
- ❌ "Bu uygulama yalnızca `sync.example.org`'a bağlanabilir" **ifade edilemez** — IP yok, CIDR yok, ad yok, DNS farkındalığı yok.

UDP'de ayrıca bir asimetri vardır: **alma (receive) hakkı yoktur** ve bağlanma hakkı "connect-or-send" olarak tanımlıdır. Ham soketler için çekirdek belgesinde açık bir cümle **yoktur**; yalnızca dört TCP/UDP hakkı tanımlı olduğu için ham soketler yapı gereği kapsam dışıdır, ama bu kaynakta yazılı bir ifade değildir — **doğrulanmalı**. Ayrıca çekirdek belgesindeki "Current limitations" bölümünde **ağa özgü bir alt başlık yoktur**; yani tavanı örtük, belgelenmemiş bir tavandır.

**Sonuç:** Landlock, Guard'ın ana zorlama mekanizması **olamaz**. Ama iki yerde değerlidir: (a) derinlemesine savunma olarak, uygulamanın port dinlemesini yasaklamak; (b) ABI 6'nın `LANDLOCK_SCOPE_ABSTRACT_UNIX_SOCKET` kapsamlaması, §2.1'de anılan Flatpak localhost/abstract-soket deliğine namespace'ten bağımsız ikinci bir kilit koyar.

#### 2.5. seccomp kullanıcı bildirimi — reddedilir

Görünüşte cazip bir yol vardır: `connect(2)` çağrısını seccomp kullanıcı bildirimi (`seccomp_unotify`) ile yakalayıp kullanıcıya sormak. **Bu yol elenmiştir ve gerekçesi man sayfasının kendisindedir.**

`seccomp_unotify(2)`, CAVEATS bölümünde birebir:

> *"It should thus be absolutely clear that the seccomp user-space notification mechanism **can not** be used to implement a security policy!"*

ve

> *"this mechanism must not be used to make security policy decisions about the system call, which would be inherently race-prone"*

ve `SECCOMP_USER_NOTIF_FLAG_CONTINUE` için:

> *"there is a time-of-check, time-of-use race here, since an attacker could exploit the interval of time where the target is blocked waiting on the 'continue' response to do things such as rewriting the system call arguments."*

`connect()`, hedefi bir `struct sockaddr` **işaretçisiyle** alır. Denetleyici işaretçiyi okuyup karar verdikten sonra, hedef süreç aynı belleği değiştirebilir. Yol yapısal olarak yarış içerir. **Guard bu mekanizmayı zorlama için kullanmayacaktır.** (Gözlem/telemetri amaçlı kullanımı teorik olarak mümkündür ama aynı yarış nedeniyle günlüğün doğruluğunu bozar; bu yüzden hiç kullanılmaz.)

#### 2.6. Zorunlu yerel çözümleyici ve vekil

**Yönlendirme.** nftables ile 53/853 yeniden yönlendirmesi standart bir tekniktir; nftables wiki'si yerel üretilen trafik için örneği verir: `nft add rule nat output tcp dport 853 redirect to 10053`. `redirect` *"is a special form of dnat"* ve *"only makes sense in prerouting and output chains of NAT type"*.

Üç kısıt belgelenmiştir:

- **Conntrack.** `nft(8)`: *"Only the first packet of a connection actually traverses this chain"* — yani politika değişikliği, kurulmuş akışlara uygulanmaz; politikayı çevirdiğinizde conntrack girdilerini temizlemek zorundasınız. Kullanıcıya "engelle" dedikten sonra akışın devam etmesi kabul edilemez bir dürüstlük hatasıdır.
- **`route_localnet`.** 127.0.0.0/8 hedefine arayüz sınırı aşarak yönlendirme yapılacaksa `net.ipv4.conf.*.route_localnet` gerekir; varsayılan kapalıdır.
- **Kapsam.** Yönlendirme yalnızca 53/853'ü kapsar. DoH'u (443/TCP, 443/UDP) kapsamaz (§4.1).

**Hangi çözümleyici uygulama-başı politika taşıyabilir?** Uygulama başına namespace kullanıldığında her uygulamanın kaynak IP'si farklıdır; bu, kaynak-IP tabanlı görünümleri (view) uygulanabilir kılar.

| Çözümleyici | Uygulama-başı politika | Kanıt |
|---|---|---|
| **unbound** | **Evet, gerçek kaynak-IP görünümleri.** `access-control-view` + `view:` bloğu; görünüm başına `local-zone`. `log-queries`: *"Prints one line per query to the log, with the log timestamp and IP address, name, type and class."* | `unbound.conf` belgeleri |
| **knot-resolver** | **Evet**, `view:addr()` — *"Views and ACLs allow to specify per-client policies"*. **Kritik uyarı:** *"the cache is shared by all requests"*; istemciye göre **farklı yanıt vermek** desteklenmez ve beklenmedik davranışa yol açar. Yalnızca **izin/ret** güvenlidir. | knot-resolver belgeleri |
| **dnsmasq** | **Hayır** (kaynak-IP değil; DHCP etiketleri üzerinden). Ama günlüğü iyidir: `--log-queries=extra`, sorguya bir seri numarası ve *"the IP address of the requestor"* ekler. | `dnsmasq` man |
| **systemd-resolved** | **Hayır.** Yalnızca bağlantı (link) başına yapılandırma; istemci başına politika seçeneği ve sorgu günlüğü seçeneği yoktur. `resolvectl monitor` *"a continuous stream of local client resolution queries and their responses"* gösterir ama **isteyen istemciyi/süreci tanımlamaz.** | `resolved.conf(5)`, `resolvectl(1)` |

**Karar:** OZERK, Guard'ın çözümleyici katmanı için **unbound**'u öne alır (görünüm başına `local-zone` ile izin/ret, istemci IP'li sorgu günlüğü); knot-resolver'ın paylaşımlı önbellek uyarısı nedeniyle yalnızca izin/ret semantiği kullanılır. systemd-resolved sistem çözümleyicisi olarak kalabilir ama **Guard'ın politika noktası olamaz.**

**musl / NSS bağlantısı — [RFC-0002](0002-taban-dagitim.md) §5'in devralınması.** RFC-0002 şunu tespit etmişti: *"musl'un NSS (`nsswitch.conf`) desteği yoktur. Guard'ın DNS katmanına yerleşmesi planlanıyorsa (A5), musl konakta bu ancak ağ katmanında yapılabilir; NSS modülü takmak bir seçenek değildir."*

Bu RFC bu tespiti **doğrular ve sonucunu yazar**: Guard zaten NSS modülü takmayacaktır. Hem `pasta --dns-forward` hem nftables 53/853 yönlendirmesi **ağ katmanında** çalışır ve libc'den bağımsızdır. Dolayısıyla:

> **musl'un NSS eksikliği bu mimari için bir engel değildir; hatta doğru mimariyi seçmeye zorlayan bir kısıttır.** Bir NSS modülü zaten yalnızca `getaddrinfo()` kullanan uygulamaları yakalardı; kendi çözümleyicisini taşıyan (Go, Rust, statik bağlı) her ikili onu atlardı. Ağ katmanı zorlaması bu ayrımı ortadan kaldırır.

Bu, RFC-0002'nin Ö6 puanlamasına doğrudan girer: **libc seçimi Guard mimarisini kısıtlamaz.**

#### 2.7. Mekanizma karşılaştırma tablosu

| Mekanizma | Profil 1 | Profil 2 | Profil 3 | Profil 4 | Profil 5 | Çekirdek | Ayrıcalık | Flatpak uyumu |
|---|---|---|---|---|---|---|---|---|
| netns + pasta | ✅ sert | ✅ | ✅ | ✅ | kısmi | userns+netns | yok | doğal |
| netns + veth/bridge | ✅ sert | ✅ | ✅ | ✅ | kısmi | netns | `CAP_NET_ADMIN` | ayrıcalıklı yardımcı gerekir |
| nftables `socket cgroupv2` | zayıf | IP düzeyi | IP düzeyi | ✅ | ❌ | 5.13 / nft 0.9.9 | `CAP_NET_ADMIN` | geçici kapsam yarışı |
| systemd `IPAddressAllow=` (eBPF) | zayıf | IP düzeyi | IP düzeyi | ✅ | ❌ | `CONFIG_CGROUP_BPF` | sistem hizmeti | **scope drop-in ile doğal** |
| eBPF `cgroup/connect4` (özgün) | ✅ | IP düzeyi + yönlendirme | ✅ | ✅ | ❌ | 4.17+ | `CAP_BPF` | mümkün |
| Landlock ağ hakları | ❌ | ❌ (adres yok) | ❌ | ❌ | port düzeyi | 6.7 (ABI 4) | yok | doğal, derinlemesine savunma |
| seccomp unotify | — | — | — | — | — | — | — | **reddedildi** (§2.5) |
| Zorunlu çözümleyici/vekil | ❌ | ✅ (isim kararı) | ✅ | gözlem | ❌ | — | sistem hizmeti | netns ile birleşir |

**Önerilen bileşim (Guard v1):**

```
Uygulama başına ağ namespace'i (bwrap --unshare-net)
        + pasta (ayrıcalıksız ağ geçidi, --dns-forward ile DNS yakalama)
        + unbound görünümü (uygulama başına izin/ret, istemci IP'li günlük)
        + çözümleyici-çapalı nftables IP kümesi (varsayılan ret)
        + Landlock ağ hakları (derinlemesine savunma: port kısıtı, abstract soket kapsamı)
        + systemd scope drop-in (A sınıfı ve netns'in pahalı olduğu durumlar için yedek yol)
```

**Çözümleyici-çapalı allowlist (bu RFC'nin merkezî tasarım fikri).** Uygulamanın namespace'inde nftables varsayılan politikası **ret**tir. İzin verilen tek hedef kümesi, **Guard'ın kendi çözümleyicisinin, o uygulama için izinli adlara karşılık döndürdüğü IP'lerdir**; bu IP'ler TTL süresince nftables kümesine eklenir. Bunun iki sonucu vardır ve ikisi de §4'te ayrıntılanır:

- **Sabit IP literalleri profil 1–3'te işe yaramaz.** Uygulama bir IP'yi doğrudan denerse, o IP kümede yoktur ve bağlantı düşer. Bu, NetGuard'ın SSS 48'de anlattığı klasik "IP tabanlı engelleme" modelinin **tersidir**: orada varsayılan izindir ve engellenecekler listelenir; burada varsayılan rettir ve izin verilecekler isimden türetilir.
- **Uygulama içi DoH profil 1–3'te işe yaramaz.** Uygulama `1.1.1.1`'e bağlanmak isterse, o adres izinli bir adın çözümünden gelmediği için kümede değildir.

Bunun bedeli de açıktır ve saklanamaz: **paylaşımlı CDN IP'leri** (§4.4). Aynı IP hem izinli hem izinsiz adları barındırdığında, IP'yi açmak ikisini birden açar.

---

### 3. Beş profilin gerçekçi karşılığı

Bu bölüm [RFC-0003](0003-paket-formati.md) §4'ün tablosunu **devralır ve derinleştirir**. RFC-0003'ün tespitleriyle çelişmez; onları mekanizmayla doldurur.

#### 3.1. Profil 1 — Ağ erişimi yok (`none`)

| | |
|---|---|
| **Bugün zorlanabilir mi?** | **Evet, tam.** |
| **Mekanizma** | `bwrap --unshare-net`; Flatpak'ta `--share=network` verilmemesi |
| **Sınıf ([RFC-0003](0003-paket-formati.md) §6)** | **E — Zorlanan** |
| **Kaçınma vektörü** | Yok. Çekirdek açığı gerekir. |

Bu, Guard'ın verdiği tek mutlak güvencedir. bubblewrap belgeleri, `--unshare-net`'in **localhost dahil** her ağ erişimini kestiğini belirtir; ayrıca konak abstract unix soketlerine erişim de kapanır.

**Açık kalan boşluk — dolaylı erişim.** Uygulama, ağ erişimi olan başka bir bileşene iş yaptırabilir: bir portal, bir D-Bus hizmeti, bir yardımcı uygulama. GrapheneOS bu sorunu adıyla anar ve tasarımını buna göre kurar: ağ izni *"disallowing both direct and indirect access to any of the available networks"* olarak tanımlanır ve dolaylı erişim *"via OS components and apps enforcing the INTERNET permission, such as DownloadManager"* engellenir. **OZERK bu kuralı devralır:** ağ erişimi olmayan bir uygulama için, ağ yapan portallar ve D-Bus hizmetleri de reddeder. Bu, portal ve `xdg-dbus-proxy` politikasının Guard tarafından okunan ağ profiliyle tutarlı kurulmasını gerektirir.

**GrapheneOS'tan alınan ikinci kural — hata biçimi.** GrapheneOS: *"GrapheneOS pretends that the Network is down for most APIs when the Network permission is disabled"* — böylece uygulamalar sonsuz yeniden deneme döngüsüne girip pil yakmaz. **OZERK aynısını yapar:** profil 1'de hata "bağlantı reddedildi" değil, "ağ yok"tur. Bu bir uyumluluk kararı değil, bir **pil kararıdır** ve manifesto §21/Aşama 5'in pil hedefiyle doğrudan ilgilidir.

#### 3.2. Profil 2 — Yalnızca izin verilen alan adları (`allowlist`)

| | |
|---|---|
| **Bugün zorlanabilir mi?** | **Kısmen — ve bu "kısmen" tanımlanmak zorundadır.** |
| **Mekanizma** | netns + pasta + Guard çözümleyicisi + çözümleyici-çapalı nftables kümesi (varsayılan ret) |
| **Sınıf** | Guard v1'den sonra **E**, ama **kapsam notuyla**: zorlanan şey "yalnızca bu adlar"dan çok "yalnızca bu adların çözümlendiği adresler"dir |
| **Kaçınma vektörleri** | Paylaşımlı CDN (§4.4); izinli bir adın vekil olarak kullanılması (§4.6); DNS üzerinden sızdırma (§4.7) |

Dürüst formülasyon şudur ve arayüzde bu şekilde geçmelidir:

> Guard, uygulamanın **yalnızca beyan edilen adların çözümlendiği IP adreslerine** bağlanmasına izin verir. Bu, adın kendisini garanti etmez: aynı adrese başka adlar da işaret ediyorsa uygulama onlara da ulaşabilir.

Bu formülasyon, NetGuard'ın SSS 48'de yıllardır yazdığı gerçeğin OZERK diline çevrilmesidir: *"NetGuard blocks traffic based on the IP addresses an application is trying to connect to. If more than one domain name is on the same IP, they cannot be distinguished."* Fark şudur: NetGuard varsayılan-izin modelinde çalışır ve engellemeye çalışır; OZERK varsayılan-ret modelinde çalışır ve izin verir. **Aynı belirsizlik, ters yönde çalışır** — OZERK'te belirsizlik "fazla engelleme" değil, "fazla izin verme" yönündedir. Bu ayrım kullanıcıya söylenmelidir.

Ek olarak, TTL kayması gerçek bir sorundur (NetGuard SSS 48 aynı yerde kaydeder). Guard, kendi çözümleyicisi olduğu için TTL'i kendi bilir; ama uygulamanın kendi önbelleği Guard'ın kümesinden daha uzun yaşayabilir. Çözüm: küme girdileri TTL + kısa bir tolerans kadar tutulur; tolerans süresi **ölçülmelidir** (E3).

#### 3.3. Profil 3 — Yeni alan adlarında sor (`ask`)

| | |
|---|---|
| **Bugün zorlanabilir mi?** | Mekanizma olarak profil 2 ile aynıdır; **kullanılabilirlik olarak saf hâliyle kullanılamaz** (§5). |
| **Mekanizma** | Profil 2 + karar bekleyen hedefler için kuyruk + toplu onay akışı |
| **Sınıf** | **E**, ama yalnızca §5'teki gruplama ve ön-onay uygulanırsa |
| **Kaçınma vektörleri** | Profil 2'nin tümü + **izin yorgunluğu**: kullanıcı hepsine "izin ver" demeye alışırsa profil 4'e dönüşür |

Profil 3'ün asıl tehlikesi teknik değildir. Android'in izin modelinin sicili bir uyarıdır ([RFC-0003](0003-paket-formati.md) Alternatif 6): ekosistem "her şeyi iste, kullanıcı zaten kabul eder" dengesine oturur. **İzin yorgunluğu, profil 3'ün başarısızlık biçimidir ve mimariye baştan işlenmelidir** (§5).

#### 3.4. Profil 4 — Genel internet erişimi (`full`)

| | |
|---|---|
| **Bugün zorlanabilir mi?** | Zorlanacak bir şey yoktur. |
| **Mekanizma** | `--share=network` (veya netns + pasta, kısıtsız politika) |
| **Sınıf** | Kısıtlama yok; kayıt **gözlemdir**, sınıf E değildir |
| **Kaçınma vektörü** | Kaçınmaya gerek yok. Ama **gözlem** kaçınılabilir: uygulama DoH kullanırsa Guard hedef adları göremez (§4.1) |

Bu, RFC'nin en çok yanlış anlaşılabilecek satırıdır. Profil 4'te Guard'ın ürettiği liste bir **kısıtlama listesi değil, bir gözlem kaydıdır** ve arayüz bunu ayrı bir görsel dille göstermek zorundadır (§9).

Ayrıca: **profil 4'te gözlemin kendisi de garanti değildir.** Uygulama kendi DoH çözümleyicisini kullanıyorsa Guard yalnızca IP'leri görür, adları göremez. Bu durumda Gizlilik Merkezi "bu uygulamanın hedeflerini çözümleyemiyoruz" demek zorundadır — boş bir liste göstermek yalandır.

#### 3.5. Profil 5 — Ham ağ erişimi (`raw`)

[RFC-0003](0003-paket-formati.md) §4 tespiti devralınır: *"Flatpak sandbox'ı `CAP_NET_RAW` bırakmaz. Sandbox içinde verilemez."*

Derinleştirme — bu bir düzeltme değil, bir incelik:

- pasta'nın kendisi `CAP_NET_RAW` **olmadan** çalışır; yani ham soket, ağ geçidi katmanı için gerekli değildir.
- Bir kullanıcı namespace'i içinde süreç, o namespace'e göre `CAP_NET_RAW` taşıyabilir ve **kendi** ağ namespace'inde ham soket açabilir. Anlamı: profil 5, uygulama başına namespace mimarisinde **anlamını yitirir** — uygulama yalnızca kendi izole ağını görür, konağın trafiğini koklayamaz. Bu, profil 5'i "yüksek riskli yetki" olmaktan çıkarıp "izole bir ağda ham soket"e indirger. **Bu davranış doğrulanmalıdır** (E6); doğrulanırsa profil 5'in tanımı daraltılarak yeniden yazılmalıdır.
- Gerçek ham ağ ihtiyacı (VPN istemcisi, ağ tanılama, paket koklama) konağın ağ namespace'ine erişim gerektirir; bu, sandbox'ın dışına çıkmaktır. Bu yüzden profil 5 A sınıfı sistem uygulamalarına ve kullanıcının açıkça onayladığı istisnalara ayrılır; normal depoda kabul edilmez.

#### 3.6. Özet — RFC-0003'ün E/V/B sınıflandırmasına katkı

[RFC-0003](0003-paket-formati.md) §6, ağ profili 2 ve 3'ü *"Kısmen ve gelecekte — Guard'a bağlı"* olarak işaretlemişti. Bu RFC o satırı şöyle netleştirir:

| Beyan | RFC-0003'teki durum | Guard v1 sonrası | Not |
|---|---|---|---|
| Profil 1 (`none`) | E | **E** | Değişmez; tek mutlak güvence |
| Profil 2 (`allowlist`) | Kısmen / gelecekte | **E (kapsam notlu)** | "Adların çözümlendiği adresler" — ad değil |
| Profil 3 (`ask`) | Kısmen / gelecekte | **E (kapsam notlu)** | Yalnızca §5 uygulanırsa |
| Profil 4 (`full`) | E (kısıtlama yokluğu) | **Gözlem** | Sınıf E değildir; öyle etiketlenemez |
| Profil 5 (`raw`) | Verilemez | **Verilemez** (A sınıfı hariç) | §3.5'teki incelik doğrulanmalı |
| Alan adı amaç açıklamaları | B | **B** | Değişmez; doğrulanamaz |
| Telemetri niteliği | B | **B** | Değişmez; içerik görülemez |

---

### 4. Kaçınma vektörleri — dürüst envanter

Her vektör için üç satır: **nasıl çalışır**, **Guard ne yapabilir**, **kalan boşluk**. Bu bölüm eksiksiz olmak zorundadır; bir vektörün burada yazılmaması onun var olmadığı anlamına gelmez ve bu bölüm yeni vektörler bulundukça güncellenir.

#### 4.1. Uygulama içi DoH / DoT

**Nasıl çalışır.** Uygulama sistem çözümleyicisini hiç kullanmaz; kendi DoH istemcisiyle 443/TCP (veya QUIC ile 443/UDP) üzerinden bir çözümleyiciye bağlanır. RFC 8484 §8.1 bunu bir **tasarım hedefi** olarak yazar: *"the use of the HTTPS default port 443 and the ability to mix DoH traffic with other HTTPS traffic on the same connection can deter unprivileged on-path devices from interfering with DNS operations."* §10 sonucu söyler: *"Filtering or inspection systems that rely on unsecured transport of DNS will not function in a DNS over HTTPS environment."*

Tarayıcılarda bu varsayılan hâle gelmiştir: Firefox DoH'u ABD'de **25 Şubat 2020**'de (Cloudflare ve NextDNS ile), Kanada'da **8 Temmuz 2021**'de (CIRA ile) varsayılan yaptı. Chrome "Secure DNS"i **Chrome 83** (19 Mayıs 2020) ile getirdi, ancak farklı bir modelle: *"auto-upgrading to the current DNS provider's DoH server which offers the same features"* — yani kullanıcının çözümleyicisini değiştirmez, aynı sağlayıcının DoH ucuna yükseltir. Tarayıcı dışı uygulamaların kendi DoH istemcilerini gömdüğüne dair birincil kaynaklı bir örnek **bulunamamıştır**; bu iddia bu belgede yapılmaz (**doğrulanmalı**).

**Guard ne yapabilir.**

- **Profil 1–3'te vektör yapısal olarak kapanır.** Çözümleyici-çapalı varsayılan-ret kümesi nedeniyle, uygulamanın DoH çözümleyicisinin IP'si kümede olmadığı için bağlantı kurulamaz. Uygulama ya Guard'ın çözümleyicisine düşer ya da hiç çözümleyemez.
- **Yumuşak sinyaller.** Firefox'un kanarya alan adı `use-application-dns.net.` (Firefox kaynağında `const GLOBAL_CANARY = "use-application-dns.net.";` olarak doğrulanmıştır) NXDOMAIN döndürülerek DoH kapatılabilir. **Ama sınırı Mozilla'nın kendi belgesindedir:** *"The canary domain only applies to users who have DoH enabled as the default option. It does not apply for users who have made the choice to turn on DoH by themselves."* Bugzilla 1614751 bunu kod değil **belge değişikliğiyle** kapatmıştır. Chrome kanaryayı **hiç tanımaz**.
- **Standart yol: RFC 9462 (DDR).** Ağın bildirdiği belirlenmiş çözümleyici (DNR) göstergeleri, `resolver.arpa` ile keşfedilenlere göre *"SHOULD take precedence"*. Yerel bir işletim sistemi çözümleyicisinin meşru kaldıracı budur ve OZERK bunu kullanmalıdır.
- **Guard kendi yukarı akışında DoH kullanır.** Uygulamadan Guard'a düz DNS, Guard'dan internete şifreli DNS. Kullanıcının gizliliği ağ operatörüne karşı korunur; uygulamanın gizliliği kullanıcıya karşı korunmaz. Bu takas açıkça yazılmalıdır.

**Kalan boşluk.** **Profil 4'te vektör tamamen açıktır ve gözlemi kör eder.** Ayrıca kanarya alan adı mekanizması tek satıcıya ait, standart olmayan ve Mozilla'nın kendi ifadesiyle *"a limited-time measure"* olan bir yamadır; ona dayanan hiçbir güvence verilemez.

#### 4.2. Sabit IP literalleri

**Nasıl çalışır.** Uygulama hiç DNS sorgusu yapmaz; IP'yi ikilisine gömer. Bu, isim tabanlı her denetimi atlar ve NetGuard/Lockdown sınıfı çözümlerin bilinen kör noktasıdır.

**Guard ne yapabilir.** **Profil 1–3'te bu vektör kapalıdır** — çözümleyici-çapalı varsayılan-ret kümesinde o IP yoktur. Bu, önerilen mimarinin DNS tabanlı engelleyicilere göre en somut üstünlüğüdür ve mimarinin böyle seçilmesinin nedenidir.

**Kalan boşluk.** Profil 4'te tamamen açıktır. Ayrıca izinli bir adın IP'si zaten kümedeyse uygulama o IP'ye adı hiç sormadan da bağlanabilir — ama hedef aynı olduğu için bu anlamlı bir kaçınma değildir.

#### 4.3. Encrypted Client Hello (ECH)

**Durum — doğrulanmıştır ve yaygın kanıdan farklıdır.**

- ECH artık taslak değildir: **RFC 9849, "TLS Encrypted Client Hello", Mart 2026, Standards Track.** Kaynak taslak `draft-ietf-tls-esni-25`. DNS önyükleme belgesi **RFC 9848** (`ech` SvcParam), taşıyıcı kayıt **RFC 9460** (SVCB/HTTPS RR, Kasım 2023).
- **Cloudflare hiçbir zaman "tüm bölgelerde varsayılan" yapmadı.** Duyuru 29 Eylül 2023'tü; **11 Ekim 2023'te küresel olarak kapatıldı** (Cloudflare topluluk gönderisi: *"We have sadly had to disable both of these features globally whilst we address a number of issues with them"*). Yeniden açılışın 16 Ağustos 2024 civarında başladığı yalnızca topluluk gözlemine dayanır; resmî bir duyuru **bulunamamıştır** (**doğrulanmalı**). Bugünkü belgelenmiş durum: *"ECH is enabled by default on Free zones. Other plans can turn it on or off."*
- **Firefox 119** (24 Ekim 2023) varsayılan açtı; **Firefox 129**'dan itibaren HTTPS RR işletim sistemi çözümleyicisinden alınabildiği için DoH artık şart değildir — **macOS hariç** (bug 1882856). **Chrome 117** (Eylül 2023) gönderdi ve DoH şartı koşmaz.
- **Ölçülmüş yaygınlık.** Tek güvenilir pasif ölçüm: Trevisan & Mellia, *"Encrypted Client Hello Is Coming: A View from Passive Measurements"*, **Network 5(3):29, 2025**. Bulgu: **QUIC akışlarının %59'u bir ECH uzantısı taşır — ama bu ezici çoğunlukla GREASE ECH'dir** (ossifikasyonu önlemek için zorunlu, anlamsız dolgu). **Gerçek ECH, Cloudflare'a giden bağlantıların yalnızca %1,96'sındadır** ve ECH destekleyen tek sağlayıcı Cloudflare olarak tespit edilmiştir. Ölçüm noktası tek bir İtalyan üniversite kampüsüdür (~35.000 kullanıcı, Şubat 2025, 106 milyon QUIC bağlantısı, 95.500 benzersiz alan adı); yazarlar sonuçların *"may not fully generalize"* olduğunu açıkça belirtir.
- Dolaşımdaki "ilk 10K sitenin %4,2'si" türü rakamlar bir güvenlik satıcısı belgesinden gelir, kendi içinde tutarsızdır ve **ölçüm olarak alıntılanmamalıdır**. Cloudflare Radar bir ECH benimseme metriği **yayımlamamaktadır**.

**Guard ne yapabilir.** Doğru cevap şudur: **OZERK'in modeli SNI'ya zaten dayanmıyor.** Karar noktası isim çözümlemesidir, TLS el sıkışması değil. ECH, SNI'yı gizler; Guard'ın kararını değil, kararın **bağımsız doğrulanmasını** zorlaştırır. RFC 9849 §10.7'nin kendi cümlesi Guard'ın lehinedir: *"ECH requires encrypted DNS to be an effective privacy protection mechanism."* Uygulama, profil 1–3'te Guard'ın çözümleyicisine mahkûm olduğu için ECH tek başına adı gizleyemez. RFC 9849 §1 aynı şeyi söyler: *"The target domain may also be visible through other channels, such as plaintext client DNS queries or visible server IP addresses."*

**Kalan boşluk.** Profil 4'te DoH + ECH birlikte kullanıldığında Guard'ın hedef adı görme yeteneği **sıfırdır**; yalnızca IP kalır. Ayrıca bağımsız bir denetçinin Guard'ın günlüğünü ağdan doğrulaması artık mümkün değildir — güven, cihazdaki bileşene kayar. Bu, ECH'nin OZERK açısından asıl maliyetidir ve bir kayıp olarak yazılmalıdır.

#### 4.4. Paylaşımlı CDN — profil 2'nin en büyük sınırı

**Nasıl çalışır.** Tek bir IP adresinin arkasında binlerce ilgisiz alan adı bulunur; ayrım yalnızca TLS SNI veya HTTP `Host` başlığıyla yapılır. İzleyici ile meşru içerik aynı adreste olabilir.

**Ölçülmüş büyüklükler** (her satırın kaynağı vardır):

| Bulgu | Değer | Kaynak |
|---|---|---|
| Bir IP'yi paylaşan alan adı sayısı, medyan | Cloudflare **16**; Akamai 3; Google 5; Amazon (AS16509) 5; Squarespace 705; Automattic 110 | Hoang vd., ACM ASIACCS '20 (ölçüm Şub–Nis 2019) |
| IPv4 dağılımı | **%70**'i tek alan adı barındırır; **~%95**'i 15'ten az; alan adlarının **%81**'i çok-barındırmalıdır | aynı |
| Cloudflare'ın kendi oranı | **255.315.270** benzersiz ad → **~16 milyon** IP; **~16×** küresel, **~24×** Avrupa | Cloudflare blog, 16 Aralık 2022 |
| Gerçek engelleme olayında yoğunluk | 2.218 Cloudflare IP'sinde **501.305** alan adı ≈ **226 alan adı/IP**; tek en kötü durum **18.592 alan adı tek IP'de** | OONI, LALIGA raporu, 30 Haziran 2026 |
| Aşırı engelleme ölçeği | 1 saatlik pencerede 4–20 IP'nin engellenmesi **400.000'den fazla** benzersiz alan adını etkiledi | aynı |

Cloudflare'ın kendi ifadesi konuyu kapatır: *"The IP address is the only one of the blocking options that has no attachment to the domain name — the website domain name is not required for routing and delivery of data packets; in fact it is fully ignored."* Ve: *"Cloudflare has several IP address ranges which are shared by all proxied hostnames."* Fastly'de paylaşımlı TLS yapılandırmaları *"use shared IP address space"* kullanır; ayrılmış IP **ücretli bir üründür**. Cloudflare'da da ayrılmış/statik IP'ler Enterprise katmanındadır ve statik IP'lerde bile *"multiple zones can share the same static IPs."*

**Guard ne yapabilir.**

- **IP katmanında hiçbir şey.** Bu, mimarinin kabul etmesi gereken sınırdır.
- **Söyleyebilir.** Guard, bir izin verdiğinde o IP'nin kaç başka adla ilişkilendirildiğini kendi çözümleyici geçmişinden bilir ve kullanıcıya *"bu adres paylaşımlıdır"* diyebilir. Bu bir çözüm değil, bir **dürüstlük** önlemidir.
- **C ve D sınıfında çözebilir.** [RFC-0003](0003-paket-formati.md) §4'ün tespiti burada devreye girer: web uygulamalarında isteği yapan taraf OZERK'in kendi web runtime'ıdır ve **origin** düzeyinde karşılaştırma yapabilir; bu, şifrelemenin **üstünde** bir denetimdir ve sahte sertifika gerektirmez. Yani paylaşımlı CDN sorunu **C/D sınıfında yoktur, B sınıfında vardır.** Bu, RFC-0003'ün "web uygulamalarını teşvik etme" gerekçesini güçlendiren ikinci ve daha somut argümandır.

**Kalan boşluk.** B sınıfı uygulamalarda, izinli bir adın paylaşımlı bir CDN'de olması o IP'deki her şeye kapıyı açar. Bu, profil 2'nin **yapısal** sınırıdır ve §9'daki metinle söylenmek zorundadır.

**Etik ve hukuki not.** IP tabanlı engellemenin yan hasarı hukuki bir eşik de aşmıştır: AİHM, *Vladimir Kharitonov / Rusya* (10795/14, 23 Haziran 2020), bir sitenin yalnızca hedef siteyle aynı IP'yi paylaştığı için engellenmesinin *"amounts to arbitrary interference"* olduğuna ve İHAS madde 10'u ihlal ettiğine hükmetti. OZERK'in modeli **engelleme değil izin verme** yönünde çalıştığı için bu doğrudan uygulanmaz; ancak IP'nin ad için kötü bir vekil olduğunu gösteren en güçlü kayıt budur.

#### 4.5. QUIC / HTTP-3

**Nasıl çalışır.** Taşıma UDP/443'tür. TCP'nin bağlantı semantiği yoktur; conntrack'in "yeni bağlantı" kavramı UDP'de daha zayıftır; bağlantı göçü sayesinde akış, IP değişse de sürebilir; 0-RTT ile ilk uçuşta veri gider.

**Guard ne yapabilir.** Çözümleyici-çapalı IP kümesi QUIC'i de kapsar; karar noktası taşıma katmanının üstündedir. Landlock tarafında UDP hakları ancak ABI 10 ile geldiği için derinlemesine savunma amaçlı UDP kısıtı yeni çekirdekler gerektirir. nftables ve eBPF tarafında 5'li (5-tuple) hâlâ görülür.

**Kalan boşluk.** Politika değişikliğinin canlı akışlara uygulanması TCP'ye göre zordur; conntrack temizliği zorunludur (§2.6). 0-RTT, "engelle" kararı verilmeden önce veri gitmiş olabileceği anlamına gelir — izin kuyruğunun (§5) **varsayılan olarak ret** ile çalışmasının nedeni budur.

#### 4.6. Vekil zincirleme

**Nasıl çalışır.** Uygulama, izin verilen bir adrese bağlanır ve o adres genel amaçlı bir vekil/aktarıcı sunar. Allowlist bütünüyle anlamsızlaşır. Bu, profil 2'ye karşı **en ucuz ve en etkili** kaçınmadır.

**Guard ne yapabilir.** Teknik olarak hiçbir şey. Trafik hacminde anormallik gözlemlenebilir (bir "yardım belgeleri" alan adına sürekli megabaytlar gitmesi) ama bu bir sezgidir, kanıt değildir.

**Kalan boşluk.** Tamamen açıktır. **Yaptırım teknik değil, depo politikasıdır** — [RFC-0003](0003-paket-formati.md) §6'nın üçüncü bağlayıcı kuralı burada da geçerlidir: beyanla gözlem çeliştiğinde sonuç, uygulamanın etiketlenmesi ve gerekirse depodan çıkarılmasıdır.

#### 4.7. DNS üzerinden veri sızdırma

**Nasıl çalışır.** Veri, sorgu adının (QNAME) içine kodlanır ve saldırganın yetkili sunucusuna gider. Yalnızca DNS'e izin veren her sistem bu kanalı açık bırakır.

**Kapasite — ölçülmüş.** Teorik tavan RFC 1035 §2.3.4'tedir: etiketler ≤ 63 sekizli, adlar ≤ 255 sekizli, UDP iletileri ≤ 512 sekizli. Kodlama ve taban alan adı payı düşüldüğünde sorgu başına kullanılabilir yük 255 bayttan azdır; **tek bir evrensel "sorgu başına N bayt" rakamı verilemez.** Gerçek ölçüm iodine'in kendi README'sindedir: dizüstü → WiFi AP → ev sunucusu → DSL → veri merkezi yolunda **56,7 kbit/s yukarı, 367,0 kbit/s aşağı**; kablolu yerel ağda **677,2 kbit/s yukarı, 2464,1 kbit/s aşağı**. Bu, "yavaş bir kanal" değil, **kullanışlı bir kanaldır**.

**Guard ne yapabilir.** Guard **çözümleyicinin kendisidir**; bu, NIST'in pasif araçlar için gösterdiği kör noktanın dışında olmak demektir. NIST SP 800-81 Rev. 3 (19 Mart 2026) §4.2.4: *"Organizations should establish controls to detect and block unauthorized applications from tunneling data within DNS packets. Signature-based systems can detect well-known DNS tunneling tools, but customized DNS data exfiltration tools should also be considered."* Önerdiği sinyaller: anormal sorgu hacmi, değişen sorgu kalıpları, *"Queries for seemingly odd QNAMES (detected by taking entropy measurements of QNAMEs)"*, tehdit istihbaratı eşleşmeleri. Aynı belge şifreli DNS'in pasif araçları körleştirdiğini, *"unless the tool is configured to act as a proxy or forwarder"* diyerek Guard'ın konumunu doğrular.

Guard'ın uygulayacağı somut denetimler: uygulama başına sorgu hızı sınırı, QNAME entropi eşiği, izinli alan adları dışındaki yetkili sunuculara yapılan sorguların profil 2–3'te zaten reddedilmesi.

**Kalan boşluk.** Kararlı bir saldırgan hızı düşürerek eşiklerin altında kalabilir. Profil 2'de izinli bir alan adının **kendi alt alanlarına** yapılan sorgular meşrudur; tünel oraya kurulabilir. **Guard bu vektörü kapatamaz; yalnızca pahalılaştırır.**

#### 4.8. Uygulama içi WebView

**Nasıl çalışır.** Uygulama bir web görünümü açar; sayfa içeriğinin yaptığı istekler işletim sistemi açısından **uygulamanın** istekleridir. Kullanıcı "Notlar uygulaması `ads.example.net`'e bağlandı" satırını görüp uygulamayı suçlar; oysa istek uygulamanın gösterdiği bir sayfadan gelmiştir. Tersi de olur: uygulama kendi telemetrisini bir WebView içine saklayabilir.

**Guard ne yapabilir.** İki katman ayrılmalıdır. Apple'ın App Privacy Report'u bunu tam olarak ayırır ve iyi bir öncüldür: *"App Network Activity shows domains that have been contacted either directly or from content within an app"* ile *"Website Network Activity shows domains that have been contacted by websites you've visited within apps"* ayrı bölümlerdir. **OZERK aynı ayrımı yapar:** Gizlilik Merkezi "uygulamanın kendi bağlantıları" ile "uygulama içinde açılan sayfaların bağlantıları"nı ayrı gösterir.

Bu ayrımın teknik dayanağı yalnızca OZERK web runtime'ında vardır ([RFC-0004](0004-tarayici-motoru.md) katman (a)): runtime, isteği hangi origin'in yaptığını bilir. Kendi WebView'ını paketleyen bir B sınıfı uygulamada bu ayrım **yapılamaz**.

**Kalan boşluk.** B sınıfı uygulamalarda WebView, isnat katmanını çökertir. Bu, RFC-0003'ün C sınıfını teşvik etme gerekçesine üçüncü bir argüman ekler. Kısmi çözüm: `ozerk.toml`'a WebView kullanımının beyan edilmesi zorunluluğu (§6.3).

#### 4.9. Vektör özeti

| Vektör | Profil 1 | Profil 2–3 | Profil 4 | Guard'ın en iyi cevabı |
|---|---|---|---|---|
| Uygulama içi DoH/DoT | kapalı | **kapalı** (çapalı küme) | açık; gözlemi kör eder | RFC 9462 DDR; kanarya (zayıf) |
| Sabit IP literali | kapalı | **kapalı** (çapalı küme) | açık (gözlem: adsız IP) | varsayılan-ret mimarisi |
| ECH | ilgisiz | karar etkilenmez; **doğrulama zorlaşır** | adı tamamen gizler | karar noktasını DNS'te tutmak |
| Paylaşımlı CDN | ilgisiz | **açık — yapısal sınır** | ilgisiz | C/D'de origin denetimi; B'de dürüst uyarı |
| QUIC / HTTP-3 | kapalı | kapalı (politika akışın üstünde) | açık | conntrack temizliği; varsayılan-ret |
| Vekil zincirleme | kapalı | **açık** | açık | depo politikası (§13) |
| DNS tüneli | kapalı | kısmen açık (alt alanlar) | açık | hız sınırı + entropi (NIST 800-81r3) |
| WebView | kapalı | isnat çöker (B sınıfı) | isnat çöker | C/D'de origin ayrımı; B'de beyan |

---

### 5. İzin yorgunluğu — profil 3'ün kullanılabilir hâli

#### 5.1. Sorun

Profil 3 saf hâliyle kullanılamaz. Sıradan bir uygulama tek bir açılışta onlarca alan adına bağlanır: bir CDN, bir yazı tipi sağlayıcısı, bir çökme raporu ucu, bir A/B test hizmeti, bir harita karo sunucusu. Her biri için modal bir soru sormak, kullanıcıyı üç dakikada "hepsine izin ver" davranışına iter ve profil 3 fiilen profil 4'e dönüşür.

Bu itiraz teorik değildir; upstream'de bir GNOME tasarımcısı tarafından, ağ izni portalı tartışmasında (`xdg-desktop-portal` #1166) tam olarak dile getirilmiştir:

> *"from a UX perspective I have some fairly major concerns … network access requests are not something that people are used to on other platforms … Network access is also a technical implementation detail … legitimate reasons for using the network will not be apparent to users, and could be difficult to explain. Access to files or a camera is something that people readily understand. Network access is rather different."*

Bu itiraz doğrudur ve bu RFC ona **kaçmadan** cevap vermek zorundadır. Cevap şudur: **kullanıcıya "alan adı" sorulmaz.** Sorulan şey, kullanıcının anlayabileceği bir şeydir ve teknik ayrıntı ancak istendiğinde açılır.

#### 5.2. Beş katmanlı çözüm

**Katman 1 — Manifest beyanından kurulum sırasında ön-onay (en önemlisi).**

[RFC-0003](0003-paket-formati.md) §4 zaten her `[[network.allowed]]` girdisine bir `purpose` alanı zorunlu kılar. Bunun sonucu şudur: **iyi beyan edilmiş bir uygulamada profil 3'ün soru listesi kurulumda bir kez gösterilir ve çalışma zamanında boştur.** Soru, "yeni alan adı" için değil, **"beyan dışı hedef"** için sorulur.

Bu tek karar, soru sayısını uygulamanın *dürüstlük açığı* kadarına indirir. Dürüst bir uygulama hiç soru üretmez. Bu, aynı zamanda geliştirici için doğru teşviktir: eksik beyan, kullanıcıyı rahatsız eden bir uygulama demektir.

**Katman 2 — eTLD+1 (yayıncı) gruplaması.**

Hedefler, Public Suffix List kullanılarak kayıt sınırına (eTLD+1) toplanır. `a.cdn.example.com`, `b.cdn.example.com`, `img.example.com` tek bir satır olur: `example.com`.

PSL gerçekleri (doğrulanmış): lisans **MPL 2.0** (listenin kendi başlığında yazılıdır), dağıtım tek bir `.dat` dosyası, başlıkta `VERSION:` ve `COMMIT:` damgası, güncelleme *"a few times per week"*, indirme sıklığı önerisi **günde birden fazla değil**. Projenin kendi uyarısı bağlayıcıdır: *"please do not bake static copies of the PSL into your software without update mechanisms that are frequently checking for updates and incorporating them"* ve geçerlilik denetimi için kullanımı hakkında *"This is dangerous."* Uygulama: `libpsl` (MIT), liste verisini paketleme yoluyla ayrı güncelleyen bir tasarıma sahiptir; OZERK bunu kullanır ve **listeyi ikiliye gömmez.**

> **PSL'in kendi sayfasında "güvenlik sınırı olarak kullanmayın" biçiminde açık bir cümle yoktur**; yayımlanmış uyarılar bayatlama ve alan adı geçerliliği hakkındadır. Bu belge PSL'e böyle bir feragat atfetmez.

**PSL'in yetmediği yer — açıkça yazılmalıdır.** eTLD+1 bir **kayıt** sınırıdır, bir **mülkiyet** sınırı değildir:

- Tek bir sahip birden çok eTLD+1 kullanır: `doubleclick.net`, `google-analytics.com`, `googlesyndication.com` üç ayrı satır olarak görünür.
- Tek bir eTLD+1 binlerce ilgisiz tarafı barındırır: `cloudfront.net`, `github.io`, `s3.amazonaws.com` — hepsi PSL'in PRIVATE bölümündedir.

Yani gruplama gürültüyü azaltır ama "kim" sorusunu cevaplamaz.

**Katman 3 — Kuruluş (entity) eşlemesi ve izleyici listeleri: lisans engeli.**

"Kim" sorusunu cevaplamak için bir mülkiyet veri kümesi gerekir. Adaylar denetlendi ve sonuç **projenin lisans modelini doğrudan ilgilendirir** ([RFC-0001](0001-karar-kaydi.md) D1: sistem bileşenleri GPL-3.0-or-later, dokümanlar CC BY-SA 4.0):

| Liste | Doğrulanmış lisans | Bakım | OZERK'te kullanılabilir mi? |
|---|---|---|---|
| **EasyPrivacy** | **Çift: GPLv3-or-later VE CC BY-SA 3.0-or-later** (easylist.to/pages/licence.html) | Çok etkin; liste başlığı gün içinde birden çok kez güncellenir | ✅ **Evet — tek temiz seçenek.** Çift lisans, projenin iki yarısına (GPL bileşen + CC BY-SA doküman) birebir oturur |
| **oisd** | **GPL-3.0** (oisd.nl/faq) | *"At least once every 24 hours"* | ⚠️ Bileşende evet; **CC BY-SA dokümanda hayır** |
| **Steven Black hosts** | **MIT** sarmalayıcı, ama **karma lisanslı upstream listelerin** derlemesi | Etkin | ⚠️ Yeniden dağıtımdan önce upstream karışımı denetlenmeli |
| **DuckDuckGo Tracker Radar** | **Veri: CC BY-NC-SA 4.0** (kod Apache-2.0). README: *"If you'd like to license the list for commercial use, please reach out."* | Etkin, aylık sürümler | ❌ **Hayır.** NC koşulu GPL-3.0 ile (kullanım alanı kısıtı yasağı) ve CC BY-SA ile bağdaşmaz |
| **Disconnect** | **CC BY-NC-SA 4.0** — GPL-3.0 **değildir** (deponun LICENSE dosyası) | Etkin | ❌ **Hayır.** Aynı NC engeli |

> **Bu, bu RFC'nin en somut politika bulgusudur ve yaygın bir yanlış inancı düzeltir.** Disconnect listesi GPL-3.0 sanılır; **değildir.** Mozilla'nın Disconnect listesini dağıtabilmesi, Mozilla ile Disconnect arasındaki ticari bir düzenlemeye dayanır ve bu düzenleme üçüncü taraflara uzanmaz. (Mozilla'nın kendi wiki'si upstream'i `disconnectme/disconnect-tracking-protection` → `services.json`, dağıttığı anlık görüntüyü `mozilla-services/shavar-prod-lists` olarak belgeler.)

**Karar:** OZERK, izleyici sınıflandırması için **EasyPrivacy'yi taban alır**. NC lisanslı listeler OZERK ile **dağıtılmaz**. Kullanıcı isterse kendi liste kaynağını ekleyebilir; bu, kullanıcı egemenliğinin (§6.1) bir gereğidir ama varsayılan dağıtımın parçası değildir. Kuruluş eşlemesi için OZERK'in kendi, açık lisanslı ve topluluk katkılı bir eşleme tablosu tutması gerekebilir — bu, kapsamı ve maliyeti ölçülmemiş bir iştir (**Açık Soru 4**).

**Katman 4 — İlk çalıştırmada öğrenme modu.**

Uygulamanın ilk çalıştırılmasında (öneri: ilk açılış veya ilk 10 dakika; süre **ölçülmeli**, E4) Guard soru sormaz: gözlemler, gruplar ve sonunda **tek bir özet** gösterir:

> *Notlar ilk çalıştırmasında 3 yayıncıya bağlandı: example.com (senkronizasyon — beyan edildi), fonts.example.net (yazı tipleri — **beyan edilmedi**), metrics.example.io (**bilinen izleme hizmeti, beyan edilmedi**). Ne yapmak istersiniz?*

Bu, N modal soruyu 1 karara indirir ve kullanıcıya karar için gereken bağlamı verir.

**Katman 5 — Kesme yasağı ve kuyruk.**

Bağlayıcı arayüz kuralları:

1. **Uygulama açılışı sırasında modal soru sorulmaz.** Karar bekleyen hedefler kuyruğa alınır ve varsayılan **rettir** (§4.5'teki 0-RTT gerekçesi).
2. Kuyruk, kullanıcının seçtiği bir anda **tek bir özet ekranında** sunulur; bildirim çubuğunda sessiz bir sayaç durur.
3. Bir yayıncı için verilen karar, o yayıncının tüm alt alanlarını kapsar; her alt alan için tekrar sorulmaz.
4. "Bu uygulama için bir daha sorma" seçeneği **profil 4'e geçiş anlamına gelir** ve öyle etiketlenir — gizli bir yükseltme yoktur ([RFC-0003](0003-paket-formati.md) §6, kural 2 ile tutarlı).
5. Guard hiçbir koşulda kullanıcıyı "izin ver"e alıştıracak bir tempoda soru sormaz. **Ölçüt E4'tedir ve eşiği aşan bir tasarım gönderilmez.**

#### 5.3. OpenSnitch'ten alınan ters ders

OpenSnitch, bağlantı başına modal soru modelinin en gelişmiş uygulamasıdır ve Linux'ta en yakın öncüldür. Ama bu model bir masaüstü uzmanı içindir; telefon için değildir. **OZERK bu modeli birincil arayüz olarak benimsemez.** OpenSnitch'ten alınan şey mekanizma bilgisi ve dürüstlüktür, etkileşim modeli değildir.

---

### 6. Manifest ile ilişki

#### 6.1. Guard `ozerk.toml` beyanını nasıl okur ve zorlar

[RFC-0003](0003-paket-formati.md) §2 üç kopya tanımlar. Guard için önemli olan, **uygulama açılmadan ve paket açılmadan** okunabilen kopyadır: Flatpak `metadata` dosyasındaki `[X-OZERK*]` grupları.

Zorlama boru hattı:

```
1. Guard, kurulu paketin metadata dosyasından okur:
     [X-OZERK] network-mode, manifest-digest
     [X-OZERK Network] allowed=...
2. /app/share/ozerk/manifest.toml'un kanonik özetini hesaplar ve
   manifest-digest ile karşılaştırır.
     -> Çelişki varsa uygulama ÇALIŞTIRILMAZ (RFC-0003 §2).
3. network-mode'a göre bir politika nesnesi üretir.
4. Uygulama başlatılırken:
     - bwrap --unshare-net
     - pasta (--dns-forward ile Guard çözümleyicisine)
     - unbound görünümü: yalnızca allowed listesindeki adlar
     - nftables kümesi: boş; yalnızca çözümlenen adresler eklenir
     - Landlock: port kısıtları (derinlemesine savunma)
5. Çalışma boyunca her karar, iki katmanlı günlüğe yazılır (§7).
```

**Uyarı — [RFC-0003](0003-paket-formati.md) Açık Soru 5 burada bloke edicidir.** `[X-OZERK*]` gruplarının `flatpak build-commit-from`, `build-bundle` ve ayna işlemlerinden **korunarak** geçtiği ölçülerek doğrulanmalıdır. Korunmuyorsa Guard'ın açılış-öncesi okuma adımı çalışmaz ve tek kaynak `/app/share/ozerk/manifest.toml` olur; bu, paketi açmayı gerektirir ve akışı yavaşlatır. **Bu, Guard v1'in ön koşuludur** (E6'ya eklenmiştir).

#### 6.2. Beyan ile gözlenen davranış farkı (§13) pratikte nasıl tespit edilir

Manifesto §13: *"Beyan ile gözlenen davranış arasında fark varsa kullanıcı ve repository yöneticileri uyarılacaktır."* Bunun pratik karşılığı profile göre değişir ve bu ayrım yazılmazsa §13 boş bir cümledir:

| Profil | Fark nasıl görünür | Tespitin gücü |
|---|---|---|
| 1 (`none`) | Bağlantı **denemesi** bile olmaz; sistem çağrısı düzeyinde reddedilir | Fark kavramı yoktur |
| 2 (`allowlist`) | Beyan dışı bir ad çözümlenmeye çalışılır → Guard reddeder ve **deneme kaydedilir** | **En güçlü.** Niyet, gerçekleşmeden yakalanır |
| 3 (`ask`) | Aynı; ek olarak kullanıcıya sorulur | Güçlü |
| 4 (`full`) | Beyan yoktur; **fark kavramı yoktur** | **Yok.** §13 burada işlemez |
| 5 (`raw`) | A sınıfı; ifşa, kısıtlama değil | Yok |

> **Sonuç, dürüstçe:** manifesto §13'ün "beyanla gözlem çelişkisi" mekanizması **yalnızca profil 2 ve 3'te dişlidir.** Profil 4'te beyan edilecek bir sınır olmadığı için çelişki de tanımsızdır. Bu, profil 2'yi teşvik etmenin üçüncü gerekçesidir ve mağaza sıralamasına yansımalıdır.

Depoya giden geri bildirim, kullanıcı verisinin cihazdan çıkmasını gerektirmez ve **gerektirmemelidir** (§7.3). Depo, aynı gözlemi kendi otomatik analiz ortamında (uygulamayı izole bir ortamda çalıştırarak) üretir; kullanıcı isterse tek tek olayları gönüllü olarak bildirebilir, ama bu **hiçbir zaman otomatik değildir.**

#### 6.3. Önerilen şema eklentileri

Bu RFC, [RFC-0003](0003-paket-formati.md) §9'daki `[network]` bölümüne üç alan eklenmesini önerir. Bunlar RFC-0003 ile çelişmez; onu tamamlar.

```toml
[network]
mode = "allowlist"

# YENİ: Uygulama kendi DNS çözümleyicisini mi taşıyor?
# "system" (varsayılan) | "embedded"
# "embedded" beyan eden uygulama, profil 1-3'te yine de Guard'ın
# çözümleyicisine düşer; beyan yalnızca kullanıcıya gösterilir.
resolver = "system"

# YENİ: Uygulama içinde web içeriği gösteriliyor mu? (§4.8)
# false | "own-webview" | "ozerk-runtime"
# "own-webview" beyan edilirse, ağ günlüğünde isnat ayrımının
# yapılamadığı kullanıcıya SÖYLENİR.
embeds_web_content = false

# YENİ: Uygulamanın bağlanacağı yetkili DNS bölgeleri (varsa).
# Boş bırakılırsa, izinli adların alt alanlarına yapılan sorgular
# hız sınırına ve entropi eşiğine tabidir (§4.7).
dns_zones = []
```

#### 6.4. D sınıfı (hosted web uygulamaları) — RFC-0003'ün açık bıraktığı soru

[RFC-0003](0003-paket-formati.md) §5/D, D sınıfının `network.mode`'unun en az `allowlist` olmasını ve listede `web.origin` ile beyan edilmiş yardımcı origin'lerin bulunmasını şart koşar. Ama D sınıfı, tanımı gereği geniş erişim ister: uzak sunucu istediği alt kaynağı yükleyebilir.

Bu RFC'nin cevabı:

**1. D sınıfında zorlama noktası ağ katmanı değil, web runtime'ıdır.** [RFC-0003](0003-paket-formati.md) §4'ün tespiti burada belirleyicidir: isteği yapan taraf OZERK'in kendi runtime'ıdır ve origin karşılaştırması şifrelemenin **üstünde** yapılır. Bu, sahte sertifika gerektirmez ve §9.2 yasağını ihlal etmez. Dolayısıyla D sınıfında paylaşımlı CDN sorunu (§4.4) **yoktur** — runtime, IP'ye değil origin'e bakar.

**2. Bunun bedeli: allowlist hareketli bir hedeftir.** RFC-0003 §5/D zaten kaydeder: *"hosted uygulamanın davranışı, paketin sürümü hiç değişmeden değişebilir."* Ağ beyanı için sonucu şudur: bugün üç origin'e bağlanan bir hosted uygulama yarın on origin'e bağlanabilir ve paket sürümü değişmez.

**3. Öneri: origin kümesini sürümlenmiş hâle getirmek.** D sınıfı manifesti bir `web.csp` tabanı taşır (RFC-0003 §5/C-D). Bu RFC, `connect-src` / `img-src` / `script-src` origin kümesinin **manifestte beyan edilmesini ve runtime tarafından zorlanmasını** önerir. Uzak sunucu kümenin dışına çıkmak isterse, sayfa çalışmaz ve kullanıcıya *"bu uygulama beyan etmediği bir sunucuya bağlanmaya çalıştı"* denir. Genişleme, **paket güncellemesi** gerektirir — böylece hareketli hedef, sürümlenmiş bir hedefe dönüşür ve §10.3'ün izin farkı akışına girer.

**4. Dürüst sınır.** Bu, D sınıfını B sınıfından **daha** denetlenebilir kılar, ama D sınıfının temel belirsizliğini kaldırmaz: çalışan kod hâlâ uzaktadır ve sunucu, izinli origin'lerin içinde istediğini yapabilir. D sınıfı için ağ modeli bir **kapsam** güvencesidir, bir **davranış** güvencesi değildir.

**5. Bu RFC, RFC-0003 Açık Soru 2'yi (D sınıfı OZERK Free'de yer alabilir mi) kapatmaz.** Buradaki katkı yalnızca şudur: ağ modeli açısından D sınıfı **zorlanabilirdir**, dolayısıyla "zorlanamaz olduğu için dışlansın" argümanı geçersizdir. Karar, kaynak koddan derlenebilirlik ekseninde verilmelidir ve o eksen bu RFC'nin dışındadır.

---

### 7. Gizlilik Merkezi'nin veri kaynağı

Manifesto §9.3, "son 24 saatte engellenen bağlantılar", "en fazla veri gönderen uygulamalar", "bilinen takip hizmetlerine yapılan bağlantılar" gibi bilgiler vaat eder. Bu bölüm, o verinin nerede durduğunu ve **neden en tehlikeli veri olduğunu** tanımlar.

#### 7.1. Kritik tespit: bu kaydın kendisi hassas veridir

Guard'ın günlüğü, kullanıcının **tüm ağ geçmişidir**: hangi uygulamayı ne zaman kullandığı, hangi hizmetlere bağlandığı, hangi saatte uyandığı, hangi kişilerle hangi platformda konuştuğu. Manifesto §6.3 sistemin "kullanım geçmişini merkezi sunucuya göndermeyeceğini", "kullanıcı profili oluşturmayacağını" ve "konum geçmişi tutmayacağını" taahhüt eder.

> **Guard'ın günlüğü, doğru tasarlanmazsa, OZERK'in reddettiği profilin ta kendisini üretir.** Gizlilik için tutulan bir kaydın, gizliliğin en büyük tehdidine dönüşmesi bu tasarımın birincil riskidir.

#### 7.2. İki katmanlı depolama

| Katman | İçerik | Saklama | Boyut davranışı |
|---|---|---|---|
| **Ayrıntı halkası** (ring buffer) | Zaman damgası, uygulama, hedef (tam ad), karar (izin/ret), yön, bayt | **24 saat**, sabit üst sınırlı halka | Sabit tavan; taşarsa en eskisi düşer |
| **Toplam katmanı** | Uygulama × eTLD+1 × gün: bağlantı sayısı, engellenen sayısı, gönderilen/alınan bayt | **7 gün** (varsayılan) | Gün ve yayıncı sayısıyla doğrusal |

Manifesto §9.3 "son 24 saat" ister; bu **asgari**dir. Varsayılan 7 gündür ve kullanıcı **kapalı / 24 saat / 7 gün** arasında seçim yapabilir. Öncül dayanağı: Android Gizlilik Panosu Android 12'de 24 saat, Android 13+'te 7 gün tutar; iOS App Privacy Report **7 gün** tutar ve ağ etkinliğini üç ayrı bölümde gösterir. Yani 7 gün, sektörün yakınsadığı penceredir.

**Boyut.** Bu RFC **hiçbir MB rakamı vermez.** Günlük boyutu uygulama sayısına, kullanım yoğunluğuna ve QUIC/HTTP-3 bağlantı desenlerine bağlıdır; ölçülmeden verilecek bir sayı uydurma olur. Ölçüm **E5**'tedir. Tasarım kuralı ise ölçümden bağımsızdır: **ayrıntı halkasının bayt cinsinden sabit bir üst sınırı vardır ve bu sınır yazıcı tarafından uygulanır**, sonradan çalışan bir temizlik işi tarafından değil. Temizlik işi başarısız olabilir; halka olamaz.

#### 7.3. Bağlayıcı tasarım kuralları

Aşağıdakiler öneri değil, **kabul kriteridir**. Biri ihlal edilirse Gizlilik Merkezi gönderilmez.

1. **Bu kayıt cihazdan ASLA çıkmaz.** Senkronizasyon yok, varsayılan yedeklemeye dahil değil, buluta gitmez, çökme raporuna girmez, telemetriye girmez, depoya otomatik gönderilmez. Bu, kırmızı çizgi 3 ve 4'ün doğrudan uygulamasıdır ve istisnası yoktur.
2. **Kullanıcının şifreli alanında durur.** `~/.local/state/ozerk/guard/` altında, kullanıcının şifrelenmiş ev dizinindedir; ilk açılıştan önce okunabilir değildir.
3. **systemd-journald'a yazılmaz.** Journal iletilebilir (`ForwardToSyslog`, `systemd-journal-remote`), kök tarafından okunabilir ve kendi saklama politikası vardır. Guard günlüğü journal'a **girmez**.
4. **Hiçbir uygulama okuyamaz.** "Ağ geçmişini oku" diye bir izin **yoktur** ve tanımlanmayacaktır. Yalnızca Gizlilik Merkezi (A sınıfı) okur. Bir uygulama kendi kaydını bile okuyamaz.
5. **Kullanıcı silebilir; silme tam ve anında olur.** Tek düğme; onay dışında hiçbir sürtünme yoktur. Silme "güvenlik gerekçesiyle" engellenemez — bu, kırmızı çizgi 15'in ("kullanıcıyı cihazının kiracısına dönüştürmek") ihlali olurdu. Silme yolu bir **kabul testidir**.
6. **Dışa aktarım yalnızca açık ve tekil kullanıcı eylemiyle.** Kullanıcı hakları bildirgesi madde 9 ("verilerini açık formatlarda dışa aktarma hakkı") bunu gerektirir. Öncül: Apple'ın "Save App Activity" akışı, kaydı JSON olarak dışa aktarır. OZERK aynısını yapar; ama dışa aktarım **hiçbir zaman otomatik değildir** ve dışa aktarılan içerik gönderilmeden önce kullanıcıya gösterilir.
7. **Uzun katmanda tam ad tutulmaz.** Toplam katmanı yalnızca eTLD+1 tutar. Tam QNAME yalnızca 24 saatlik halkadadır. Böylece uzun vadeli kayıt, bir gezinme geçmişi değil, bir yayıncı istatistiğidir.
8. **Kayıt biçimi belgelenir.** Kullanıcının kendi verisini kendi aracıyla okuyabilmesi §6.11'in (veri taşınabilirliği) gereğidir.
9. **Varsayılan olarak açıktır ama kapatılabilir.** Kapatmak, Guard'ın **zorlamasını** kapatmaz — yalnızca kaydı kapatır. Bu ayrım arayüzde nettir: zorlama bir güvenlik özelliğidir, kayıt bir şeffaflık özelliğidir.

#### 7.4. Manifesto §6.3 ile çelişmemesi için gereken kural

§6.3, sistemin "kullanım geçmişi" tutmamasını taahhüt eder. Guard'ın günlüğü teknik olarak bir kullanım geçmişidir. Çelişkiyi çözen ayrım şudur ve belgelenmelidir:

> §6.3'ün yasakladığı şey, **kullanıcının denetiminde olmayan ve cihazdan çıkan** bir geçmiştir. Guard'ın günlüğü kullanıcının kendi denetimindedir, cihazdan çıkmaz, kullanıcı tarafından silinebilir ve sınırlı süre saklanır. Bu, §6.3'ün ihlali değil, §7'nin 6. ve 7. maddelerinin ("uygulamanın hangi sunucularla iletişim kurduğunu görebilme hakkı", "kamera, mikrofon ve konum kullanım geçmişini inceleme hakkı") gereğidir.

Bu ayrım incedir ve kötüye kullanıma açıktır. Bu yüzden §7.3'ün dokuz kuralı bağlayıcıdır: onlar olmadan bu paragraf bir bahaneye dönüşür.

---

### 8. Mevcut çözümlerden ne öğrenilebilir

Bu bölümün amacı öykünme değil, **başkalarının kendi belgelerinde itiraf ettiği sınırları devralmaktır.** Her satırın kaynağı projenin kendi metnidir.

#### 8.1. Karşılaştırma

| Çözüm | Mekanizma | Granülerlik | Projenin kendi itirafı |
|---|---|---|---|
| **OpenSnitch** (GPL-3.0, Linux) | NFQUEUE + süreç eşlemesi (eBPF / audit / procfs) | Süreç, UID, IP/ağ, port, alan adı (regex ve liste) | *"when we reach to this point, the process may have already exited, or the socket being closed. **It's not accurate**"* |
| **Little Snitch** (tescilli, macOS) | v5'ten beri `NEFilterDataProvider` (kext değil) | Süreç (kod imzası kimliğiyle), alan adı listesi, port, protokol, yön | *"Incoming connections cannot be matched by name or domain because the remote name is never known reliably."* |
| **Little Snitch for Linux** (eBPF GPL-2.0, arka plan hizmeti tescilli) | eBPF, çekirdek 6.12+ ve BTF | Süreç, alan adı | *"built for privacy, not security, and that distinction matters"* |
| **Android INTERNET izni** | `protectionLevel="normal"`; eskiden `AID_INET` GID, bugün eBPF traffic controller | UID başına ikili | Kurulumda otomatik verilir, **kullanıcı geri alamaz** |
| **GrapheneOS ağ izni** | INTERNET izninin üstünde, doğrudan **ve dolaylı** erişimi kapatan bir anahtar | Uygulama (UID) ve profil başına ikili | *"a packet-based firewall would only block direct access so our approach is much more complete"* |
| **RethinkDNS** (Apache-2.0, Android) | `VpnService` TUN + Go kullanıcı alanı yığını (firestack) | Uygulama, alan adı/IP listeleri, kategori, ekran/şebeke durumu | *"Rethink DNS is ways off being a bullet-proof content blocker"* |
| **NetGuard** (GPL-3.0, Android) | `VpnService` sinkhole, kök gerektirmez | UID + adres/ana bilgisayar adı | SSS 48 (aşağıda); SSS 64: DoH/DoT *"not possible … which is the whole point"* |
| **Lockdown** (GPL-3.0 istemci, iOS) | `NEPacketTunnelProvider` + dnscrypt-proxy + yerel HTTP vekili | **Yalnızca alan adı, cihaz genelinde** — uygulama başına değil | Tek VPN yuvası: *"Lockdown is incompatible with many third-party VPNs"* |

#### 8.2. Her birinden alınan ders

**OpenSnitch — mekanizma dersi, etkileşim uyarısı.** OpenSnitch, isnatı **çıkarımla** kurar: NFQUEUE paketi → soket inode'u → `/proc/*/fd/` taraması → PID. Kendi wiki'si bu yolun ne zaman başarısız olduğunu sayar: süreç çok hızlı bağlantı açıyorsa, sistem yükü yüksekse, netlink bağlantıyı döndürmezse, inode `/proc/<PID>/fd/` altında yoksa, "PID aslında bir TID" ise, konteyner içindeyse. UDP için ayrıca: *"In many occasions, when you parse `/proc/net/udp` the connection is already gone."* Ad eşlemesi için üç yol kullanır: düz UDP/53 yanıtlarını ayrıştırma, libc üzerinde `getaddrinfo`/`gethostbyname` uprobe'ları, ve systemd-resolved varlink izleme. eBPF yolu çekirdek ≥ 5.5 ister ve bazı çekirdeklerde (xanmod, liquorix) çalışmaz. Engelleme listeleri için ayrıca: *"This feature may not work if your system uses `systemd-resolved`."*

> **OZERK'in devraldığı ders:** isnatı çıkarımla kurma. Guard uygulamayı **kendisi başlatır**; cgroup ve ağ namespace'i sürecin varlığından öncedir. Bu, OpenSnitch'in tüm yarış listesini ortadan kaldırır ve OZERK'in bu alandaki tek gerçek mimari üstünlüğüdür.
>
> **Kaçınılacak hata:** bağlantı başına modal soru modelini birincil arayüz yapmak (§5.3).

**Little Snitch (macOS) — platform istisnası dersi.** macOS 11.0, `ContentFilterExclusionList` ile yaklaşık 50 Apple uygulamasını (iCloud, Harita, App Store, `softwareupdate`) üçüncü taraf ağ filtrelerinden **muaf tuttu**; liste macOS 11.2 beta 2'de kaldırıldı.

> **OZERK kuralı:** hiçbir sistem uygulaması Guard'ın **kaydından** muaf değildir. A sınıfı bileşenler sandbox'ın dışındadır ([RFC-0003](0003-paket-formati.md) §5/A) ve bu bir **ifşadır**, bir muafiyet değil. Guard'ın kendi trafiği de dahil, her sistem bileşeni Gizlilik Merkezi'nde görünür. Bir platformun kendi uygulamalarını kendi filtresinden muaf tutması, güvencenin tamamını yok eder.

Ayrıca Little Snitch'in DNS şifreleme belgesi, OZERK'in de kabul etmesi gereken bir sınırı yazar: *"Your computer may still leak server name information, e.g. in the Server Name Indication extension to TLS."* (ECH bunu kapatır — ve o zaman da §4.3'teki doğrulama sorunu doğar.)

**Little Snitch for Linux — en dürüst öncül.** eBPF tabanlı, çekirdek 6.12+ ve BTF gerektiren ticari bir üründür; eBPF programı ve web arayüzü GPL-2.0, arka plan hizmeti tescillidir. Kendi sayfasındaki dört cümle bu RFC'nin §1'ini bağımsız olarak doğrular: *"built for privacy, not security"*; *"Under heavy traffic, cache tables can overflow, which makes it impossible to reliably tie every network packet to a process or a DNS name"*; *"reconstructing which hostname was originally looked up for a given IP address requires heuristics rather than certainty"*; *"For hardening a system against a determined adversary, it's not the right tool."*

> **Ders:** aynı işi ticari olarak yapan bir ekip, iddiasını "gizlilik aracı" olarak sınırlıyor. OZERK daha büyük bir iddiada bulunacaksa **gerekçesini göstermek zorundadır** — ve gösterebileceği tek gerekçe, uygulamayı kendisinin başlatması ve sandbox'a sahip olmasıdır.

**Android INTERNET izni — negatif ders.** İzin `protectionLevel="normal"`tir; kurulumda otomatik verilir, kullanıcıya sorulmaz ve stok Android'de geri alınamaz. Zorlama mekanizması, satıcı çekirdek yaması `CONFIG_ANDROID_PARANOID_NETWORK`/`AID_INET` (3003) modelinden AOSP'nin eBPF traffic controller'ına taşınmıştır (kesin sürüm eşiği **doğrulanmalı**). NetGuard'ın SSS 7'si sonucu özetler: *"Internet permission can be granted with each application update without user consent."* Veri Tasarrufu (Data Saver) bir güvenlik sınırı değildir: yalnızca ölçülü (metered) ağlarda ve yalnızca arka planda çalışır.

> **Ders:** kurulumda otomatik verilen bir izin, izin değildir. OZERK'te ağ profili **kurulum öncesi gösterilir ve kullanıcı tarafından daraltılabilir**; genişletme güncellemeyi durdurur (§10.3).

**GrapheneOS — modelde en yakın akraba.** Ağ izni, INTERNET izninin üstüne inşa edilmiştir; GrapheneOS bunu bir avantaj olarak yazar: *"builds upon the standard non-resettable INTERNET permission, so it's already fully adopted by the app ecosystem."* Doğrudan erişimi soket düzeyinde, dolaylı erişimi ise INTERNET iznini zorlayan işletim sistemi bileşenleri üzerinden kapatır; localhost'u da kapsar. Sınırları da nettir: ikili, uygulama başına, alan adı yok, IP yok, günlük yok; ve dolaylı engelleme, bileşenlerin *"marked appropriately"* olmasına bağlıdır.

> **OZERK'e en yakın olan budur** — çünkü ikisi de işletim sisteminin sahibidir ve izni soket katmanında uygular, paket filtresi olarak değil. **OZERK üç kuralı doğrudan devralır:** (a) dolaylı erişim de kapanır (§3.1); (b) hata biçimi "ağ yok"tur, pil için (§3.1); (c) mevcut ekosistem sözlüğünün üstüne inşa et, yenisini icat etme — OZERK'te bu, Flatpak'ın `--share=network`'ünün üstüne inşa etmek demektir ([RFC-0003](0003-paket-formati.md) §1).
>
> **OZERK'in eklediği:** GrapheneOS'ta olmayan alan adı katmanı ve günlük. Ama bu ekleme, GrapheneOS'un ikili izninin **gücünü azaltmaz**; yanına konur. Profil 1, GrapheneOS'un ağ izniyle aynı sertliktedir.

**RethinkDNS — kapsam dersi.** Android 10+'ta bağlantı sahibini `ConnectivityService`'ten alır; altında `/proc/net/*` okur *"like NetGuard or OpenSnitch do"*. Kendi README'si kapsamını dürüstçe daraltır: *"not a feature-rich traditional firewall: It is more in-line with Little Snitch than IP tables"* ve *"Deep Packet Inspection remains a credible threat that can't be mitigated with just encrypted DNS."* DNS izleme Android 11 ve altında *"a rough heuristic"*tir.

> **Ders:** kapsamı ürünün kendi sayfasında daraltmak, güveni azaltmaz — artırır. §9'un tamamı bu dersin uygulamasıdır.

**NetGuard — en değerli tek cümle.** SSS 48: *"NetGuard blocks traffic based on the IP addresses an application is trying to connect to. If more than one domain name is on the same IP, they cannot be distinguished. If you set different rules for 2 domains which resolve to the same IP, both will be blocked."* Ayrıca SSS 63: *"NetGuard allows all DNS traffic"*; SSS 19: uygulamalar başka sistem bileşenleri üzerinden internete erişebilir; SSS 31: Android uygulamaları UID'de gruplar, ayırt edilemezler; SSS 1: VpnService kısıtı nedeniyle *"it will not offer protection during early boot-up."*

> **Ders:** OZERK'in VpnService kısıtı yoktur — sandbox'a sahiptir. Ama **eşdeğer** bir kısıtı vardır ve gizlenmemelidir: **Guard'ın zorlaması, uygulamayı Guard'ın başlatmasıyla başlar.** Guard'ın başlatmadığı hiçbir süreç bu modelin içinde değildir (§1.3, madde 5).
>
> **Kaçınılacak hata:** IP düzeyindeki engellemeyi alan adı güvencesi gibi sunmak. NetGuard bunu yapmıyor; birçok ticari ürün yapıyor. OZERK yapmayacak (§9.2).

**Lockdown — kapalı platform dersi.** Yerel bir `NEPacketTunnelProvider` içinde dnscrypt-proxy ve bir HTTP vekili çalıştırır; engelleme **alan adı düzeyinde ve cihaz genelindedir**, uygulama başına değildir. Üçüncü tarafların iOS'ta uygulama başına filtre yazması, denetimli/MDM cihazlarla sınırlıdır (**Apple belgesiyle doğrulanmalı**).

> **Ders:** kapalı bir platformda üçüncü taraf, ancak DNS düzeyinde ve cihaz genelinde iş yapabilir. **OZERK'in var olma nedeni tam olarak budur:** platformun sahibi olmak, uygulama başına denetimi mümkün kılan tek şeydir. Bu, manifesto §5'in ("bir uygulama, kullanıcıdan habersiz başka şirketlere veri gönderememelidir") teknik ön koşuludur.

#### 8.3. Linux masaüstü tarafında bugün ne var: hiçbir şey

Flatpak ve xdg-desktop-portal'da uygulama başına ağ denetimi **yoktur** ve her girişim aynı yerde tıkanmıştır:

| Kayıt | Konu | Durum |
|---|---|---|
| `flatpak/flatpak#1202` | "Network restriction fine tuning?" (port + hedef) | **Açık** (2017'den beri); kanonik yinelenme hedefi |
| `flatpak/flatpak#3054` | Ağ izni granülerliği (LAN / dış) | Kapalı, #1202'nin yinelenmesi |
| `flatpak/flatpak#4996` | Ağ erişimini dinamik izin yapmak | Kapalı (2025-08-11), yinelenme |
| `flatpak/xdg-desktop-portal#1166` | "Network permission portal" | **Açık tartışma; seçilmiş cevap yok, uygulama yok** |

Bakımcı ifadeleri §2.1'de alıntılanmıştır. Özet: mimari tıkanıklık, ayrıcalıksız Flatpak'ın ağ namespace'i açamamasıdır ve önerilen çözüm slirp4netns/pasta köprüsüdür — yani **bu RFC'nin önerdiği mimarinin ta kendisi.**

> **D3 (upstream-öncelik) gereği bu bir fırsattır, bir fork gerekçesi değildir.** OZERK, çalışan bir uygulamayla #1166'ya katkı vermelidir. Guard v2'nin (§10) ana upstream hedefi budur: OZERK'in Guard'ı, xdg-desktop-portal'ın ağ portalı önerisinin referans uygulaması olabilir. Bu, [RFC-0001](0001-karar-kaydi.md) D3'ün en somut uygulama alanıdır ve RFC-0008 (finansman ve sürdürülebilirlik) fon başvurusu için de en güçlü bileşendir.

---

### 9. Kullanıcıya ne söylenir

Manifesto §9.3: *"OZERK yalnızca gözlemleyebildiğini ve doğrulayabildiğini söyleyecektir."* Bu bölüm o cümleyi arayüz kurallarına ve somut metne çevirir.

#### 9.1. Dört etiket

[RFC-0003](0003-paket-formati.md) §6, üç sınıf tanımlar (Zorlanan / Doğrulanan / Beyan) ve bunların arayüzde **görsel olarak ayrılmasını** zorunlu kılar. Ağ modeli dördüncü bir durumu gerektirir:

| Etiket | Anlamı | Ağ modelinde nerede |
|---|---|---|
| **Zorlanıyor** | Sistem, aksini teknik olarak engeller | Profil 1; Guard v1 sonrası profil 2 ve 3 (kapsam notuyla) |
| **Doğrulandı** | Yayımdan önce bağımsız sınandı | Build doğrulaması; ağ modelinde doğrudan karşılığı yok |
| **Gözlemlendi** | Guard bunu gördü; bir kısıtlama değildir | Profil 4'ün hedef listesi; tüm trafik istatistikleri |
| **Beyan** | Geliştirici söyledi; sistem ne engelleyebilir ne doğrulayabilir | Amaç açıklamaları, telemetri niteliği, reklam beyanı |

**Bağlayıcı kural:** "Gözlemlendi" ile "Zorlanıyor" aynı renkte, aynı simgeyle, aynı ağırlıkta gösterilemez. Profil 4'ün hedef listesi bir kısıtlama listesi gibi görünürse, arayüz yalan söylemiş olur.

#### 9.2. Somut metin önerileri

Aşağıdaki metinler taslaktır ama **anlam** bağlayıcıdır. Kısaltılmaları, süslenmeleri veya "daha güven verici" hâle getirilmeleri yasaktır.

**Profil 1 — uygulama ekranı:**

> **Ağ erişimi yok.** Bu uygulama internete bağlanamaz. Kısıtlama çekirdek düzeyinde uygulanır; uygulama onu aşamaz.

**Profil 2 — uygulama ekranı:**

> **Yalnızca izin verilen adresler.** Bu uygulama yalnızca aşağıdaki sunuculara bağlanabilir.
>
> *Sınır:* Guard, bu adların çözümlendiği IP adreslerine izin verir. Aynı IP adresini paylaşan başka siteler varsa uygulama onlara da ulaşabilir. **Guard, bağlantının içeriğini göremez.**

**Profil 3 — özet kararı ekranı (§5.2, katman 4):**

> **Notlar, beyan etmediği 2 yayıncıya bağlanmak istiyor.**
>
> · `fonts.example.net` — beyan edilmedi
> · `metrics.example.io` — beyan edilmedi · **bilinen izleme hizmeti**
>
> [Bu oturum için izin ver] [Her zaman izin ver] [Reddet] [Ayrıntılar]

**Profil 4 — uygulama ekranı:**

> **Ağ erişimi kısıtlı değil.** Bu uygulama internetteki her adrese bağlanabilir.
>
> Aşağıdaki liste bir kısıtlama değil, **gözlem kaydıdır**. Uygulama kendi DNS çözümleyicisini kullanıyorsa bu liste eksik olabilir.

**Engellenen olay satırı:**

> 13:42 — Notlar, `tracking.example.net` adresine bağlanmayı denedi. **Engellendi.**

**Tracker ifadesi — manifesto §9.3'ün lafzı:**

> **Bilinen takip hizmetine bağlantı görülmedi.**
>
> Bu, uygulamanın izleme yapmadığı anlamına **gelmez**. Guard yalnızca tanıdığı adresleri tanır ve bağlantıların içeriğini göremez.

**Paylaşımlı adres uyarısı (§4.4):**

> `cdn.example.com`, binlerce başka siteyle aynı adresi paylaşıyor. Bu adrese izin vermek, o adresteki diğer sitelere de izin vermek anlamına gelebilir.

**Çözümlenemeyen hedef (§4.1):**

> Bu uygulama kendi DNS çözümleyicisini kullanıyor. Bağlandığı adreslerin adlarını **çözümleyemiyoruz**; yalnızca IP adreslerini görüyoruz.

#### 9.3. Guard'ın ASLA söylemeyeceği cümleler

- "Bu uygulama güvenlidir."
- "Verileriniz korunuyor." / "%100 korumalı."
- Tek bir gizlilik puanı, harf notu veya yüzde (manifesto §9.3 bunu açıkça yasaklar).
- "Veri sızıntısı yok."
- "Bu uygulama sizi izlemiyor."
- "Tüm bağlantılar denetim altında."

#### 9.4. "Guard neyi göremez" sayfası

Gizlilik Merkezi'nde, her uygulama ekranından tek dokunuşla erişilen kalıcı bir sayfa bulunur. İçeriği §1.3 ve §4'ün kullanıcı diline çevrilmiş hâlidir ve en az şunları söyler:

> **Guard neyi göremez**
>
> · **Ne gönderildiğini.** Guard bağlantıyı görür, içeriğini görmez. OZERK, içeriği okumak için cihazınıza sahte güvenlik sertifikası yerleştirmez.
> · **Paylaşımlı adreslerin arkasını.** Bugün birçok site aynı IP adresini paylaşır; Guard hangisine bağlanıldığını her zaman ayıramaz.
> · **Kendi DNS'ini kullanan uygulamaların hedeflerini** (kısıtlanmamış uygulamalarda).
> · **İzin verilen bir adresin aktarıcı olarak kullanılmasını.**
> · **Sunucuya ulaştıktan sonra verinize ne olduğunu.**
>
> Guard, **dürüst uygulamaları şeffaflaştırmak** için tasarlandı. Kararlı biçimde gizlenmeye çalışan bir uygulamayı durduracağını iddia etmiyoruz. Tek istisna: ağ erişimi olmayan bir uygulama gerçekten bağlanamaz.

Bu sayfa arayüzden kaldırılamaz ve bir "ayarlar" alt menüsüne gömülemez.

---

### 10. Aşamalı uygulama planı

Aşamalar yol haritasıyla (`docs/yol-haritasi.md`) ve manifesto §21 Aşama 3 ile hizalıdır.

#### 10.1. Guard v0 — Ay 4–8, emülatörde, D2 kapısı

Yol haritasının tanımı bağlayıcıdır: *"Uygulama başına ağ erişimini aç/kapa ve uygulamaların bağlandığı alan adlarının günlüğü … v0 bir prototiptir ve güvenlik garantisi iddia etmez."*

**Kapsam:**

- Uygulama başına ağ aç/kapa: `flatpak override --unshare=network <app-id>` (Flatpak belgeleri `--unshare=NAME` bayrağını, çalışma zamanı metadata'sı veya `override` ile verilmiş bir izni açıkça reddetmek için tanımlar).
- Tek bir sistem çözümleyicisi (unbound) + istemci IP'li sorgu günlüğü.
- **En az bir uygulama için** uygulama başına ağ namespace'i + pasta + çözümleyici-çapalı küme — D2 gösteriminin çalışacağı yol budur.
- Gizlilik Merkezi v0: ham günlük görüntüleyici; §7.3'ün kuralları **v0'da da geçerlidir** (cihazdan çıkmaz, silinebilir).

**Gerçekten zorlanan profiller: 1 ve 4.** Profil 2, yalnızca gösterim yapılan uygulamada ve prototip kalitesinde. Profil 3 yok.

**D2 gösteriminin dürüst çerçevesi.** Gösterim, seçilen bir uygulamanın belirli bir alan adına erişiminin engellendiğini ve olayın günlükte göründüğünü kanıtlar. **Kanıtlamadığı şey:** aynı uygulamanın başka yollarla o hedefe ulaşamayacağı. Bu cümle, gösterimin yayımlanan kaydına eklenmelidir. Yol haritasının "ölçülü iddia" ilkesi (*"Prototip prototip olarak … adlandırılır"*) bunu zaten gerektirir.

#### 10.2. Guard v1 — Aşama 3'ün çekirdeği

**Kapsam:**

- Tüm B sınıfı uygulamalar için uygulama başına ağ namespace'i + pasta, varsayılan yol olarak.
- Çözümleyici-çapalı allowlist → **profil 2 sınıf E'ye geçer** (kapsam notuyla).
- §5'in beş katmanı → **profil 3 kullanılabilir hâle gelir.**
- İki katmanlı günlük (§7) ve Gizlilik Merkezi'nin tam hâli; "Guard neyi göremez" sayfası (§9.4).
- `[X-OZERK*]` okuma boru hattı (§6.1) ve `manifest-digest` doğrulaması.
- EasyPrivacy tabanlı izleyici sınıflandırması (§5.3).
- Portal ve D-Bus politikasının ağ profiliyle tutarlılığı → dolaylı erişimin kapanması (§3.1).

**Ön koşullar:** E1 (maliyet kabul edilebilir), E3 (çapalı allowlist gerçek trafikte çalışıyor), E4 (soru sayısı eşiğin altında), E6 (çekirdek özellikleri hedef cihazda var), [RFC-0003](0003-paket-formati.md) Açık Soru 5 kapanmış.

#### 10.3. Guard v2 — olgunlaşma ve upstream

- **Alternatif düşük maliyetli yol:** netns maliyetinin kabul edilemez olduğu cihazlarda systemd scope drop-in + `IPAddressAllow=` (§2.3). Bu yol profil 2'yi IP düzeyinde verir ama uygulama başına DNS isnatını vermez; **hangi cihazda hangi yolun kullanıldığı özgürlük envanterinde yazılır** (manifesto §6.14).
- Landlock ağ hakları derinlemesine savunma olarak (port kısıtı; ABI 6 abstract soket kapsamı).
- **Upstream:** `xdg-desktop-portal#1166`'ya çalışan bir uygulamayla katkı; Flatpak tarafında ağ izninin ayrıntılandırılması için tasarım önerisi. D3 gereği önce sorulur, sonra yazılır.
- C ve D sınıfı için web runtime origin zorlaması (§6.4) ve WebView isnat ayrımı (§4.8).

#### 10.4. Aşama özeti

| | v0 (Ay 4–8) | v1 (Aşama 3) | v2 |
|---|---|---|---|
| Profil 1 | ✅ zorlanır | ✅ zorlanır + dolaylı erişim | ✅ |
| Profil 2 | prototip (tek uygulama) | ✅ **sınıf E** (kapsam notlu) | ✅ + C/D'de origin düzeyi |
| Profil 3 | yok | ✅ **§5 ile kullanılabilir** | ✅ |
| Profil 4 | gözlem | gözlem + iki katmanlı günlük | gözlem |
| Profil 5 | yok | A sınıfı istisna | A sınıfı istisna |
| Gizlilik Merkezi | ham görüntüleyici | tam (§7, §9) | + WebView ayrımı |
| Upstream | — | tasarım tartışması açılır | referans uygulama sunulur |

---

### 11. Karar ölçütleri ve deneyler

[RFC-0004](0004-tarayici-motoru.md) §9'un yöntemi izlenir: bu RFC, deneyler tamamlanmadan **"Kabul" durumuna geçmemelidir.** Her deneyin çıktısı depoda yayımlanır; başarısız sonuçlar da yayımlanır.

**E1 — Uygulama başına ağ namespace'inin maliyeti (en kritik deney).**
Aday referans cihazda (RFC-0006, referans donanım) ve emülatörde, aynı uygulama üç koşulda çalıştırılır: (a) konak ağı (taban), (b) netns + pasta, (c) netns + slirp4netns.
Ölçülecekler: TCP bağlantı kurma gecikmesi (medyan ve p95), ilk bayta kadar geçen süre, sürekli aktarım hızı, CPU zamanı, ve **24 saatlik karışık kullanımda pil tüketimi**. Ayrıca suspend/resume sonrası bağlantıların davranışı.
*Gerekçe:* pasta'nın veth/bridge'e karşı yayımlanmış bir karşılaştırması **yoktur**; projenin "4 ilâ 50 kat" iddiası slirp sınıfı çözümlere karşıdır ve bu soruyu cevaplamaz. ARM üzerinde kullanıcı alanı TCP'nin CPU maliyetine dair güvenilir bir ölçüm de bulunamamıştır. **Bu boşluk uydurulmayacak, ölçülecektir.**
*Eşik:* Ö1'de tanımlıdır.

**E2 — `socket cgroupv2` ve Flatpak geçici kapsamları.**
Bir Flatpak uygulaması art arda 100 kez başlatılıp durdurulur. Ölçülecekler: (a) kapsam cgroup'unun oluşturulmasıyla nftables kuralının yüklenmesi arasındaki gecikme (yarış penceresi), (b) o pencerede kurulabilen bağlantı sayısı, (c) yeniden oluşturulan cgroup'ta eski kuralın gerçekten sessizce eşleşmeyi bırakıp bırakmadığı.
*Gerekçe:* §2.2'deki inode kısıtı kaynaktan okunmuştur ama davranışsal sonucu ölçülmemiştir. Sonuç, bu yolun yedek yol mu yoksa hiç kullanılmayacak bir yol mu olduğunu belirler.

**E3 — Çözümleyici-çapalı allowlist'in gerçek trafikte doğruluğu.**
Seçilen 10 çekirdek uygulama bir hafta boyunca profil 2 altında çalıştırılır. Ölçülecekler: (a) Guard'ın çözümleyicisinin döndürdüğü IP'lere yapılan bağlantı oranı ile literal IP denemelerinin oranı, (b) izin verilen IP'lerin kaçının izin verilmemiş adlarla da ilişkili olduğu (**gerçek trafikte CDN ortak-kiracılık oranı**), (c) TTL toleransının hangi değerde yanlış-ret üretmediği.
*Gerekçe:* §4.4'teki literatür rakamları 2019–2026 arası ölçümlerdir ve OZERK'in çekirdek uygulama setine ait değildir. Profil 2'nin gerçek gücü bu deneyle belirlenir.

**E4 — Soru sayısı (profil 3'ün gönderilebilirlik testi).**
Aynı 10 uygulama, profil 3 altında iki koşulda bir hafta çalıştırılır: (a) ham "yeni alan adında sor", (b) §5'in beş katmanı etkin.
Ölçülecek: uygulama başına haftalık kullanıcı kararı sayısı.
*Eşik:* Ö3'te tanımlıdır. **Eşik aşılırsa profil 3 gönderilmez** — daraltılır veya ertelenir, ama zayıflatılmış hâliyle "çalışıyor" diye sunulmaz.

**E5 — Günlük boyutu, saklama ve silme.**
Gerçek kullanımda günlük başına bayt ölçülür (uygulama başına ve toplam). Ayrıca: halka tavanının gerçekten uygulandığı, 24 saat/7 gün pencerelerinin doğru düştüğü ve **silme işleminin diskte gerçekten iz bırakmadığı** doğrulanır.
*Gerekçe:* §7.2 bilinçli olarak hiçbir boyut rakamı vermemektedir; bu deney o boşluğu kapatır. Silme testi bir **kabul kriteridir**, bir performans ölçümü değil.

**E6 — Hedef cihaz çekirdek özellik envanteri.**
Aday cihazlarda ([RFC-0002](0002-taban-dagitim.md) Ö6, RFC-0006) doğrulanacaklar: `CONFIG_USER_NS`, `CONFIG_NET_NS`, `CONFIG_CGROUP_BPF`, `BPF_SYSCALL`, `nft_socket` modülü, nftables sürümü, çekirdeğin bildirdiği **Landlock ABI sürümü**, `CONFIG_INET`. Ayrıca §3.5'teki kullanıcı namespace'i içinde `CAP_NET_RAW` davranışı ve [RFC-0003](0003-paket-formati.md) Açık Soru 5 (`[X-OZERK*]` gruplarının araç zincirinden korunarak geçmesi).
*Gerekçe:* satıcı çekirdeklerinde bu seçeneklerin kapalı olması gerçek bir risktir ([RFC-0002](0002-taban-dagitim.md) §7). Guard'ın hangi yolu kullanacağı cihaza göre değişebilir ve bu, özgürlük envanterine yazılacak bir gerçektir.

**E7 — DoH ve ECH davranışı.**
Bir tarayıcı ve DoH kullanan bir uygulama, profil 2 altında çalıştırılır. Ölçülecekler: (a) uygulama Guard'ın çözümleyicisine gerçekten düşüyor mu yoksa çevrimdışı mı davranıyor, (b) `use-application-dns.net` kanaryasının etkisi, (c) RFC 9462 DDR göstergelerinin etkisi, (d) ECH etkin bir hedefte Guard'ın günlüğünün ne kadar eksik kaldığı.
*Gerekçe:* §4.1 ve §4.3'ün iddiaları mantıksal çıkarımdır; cihazda sınanmamıştır.

**E8 — Dürüstlük testi (kullanıcı çalışması).**
Küçük bir katılımcı grubuyla (en az 5 kişi), Gizlilik Merkezi kullanıldıktan sonra şu sorular sorulur: "Guard bu uygulamanın ne yaptığını görebilir mi?", "Guard bunu engelleyebilir mi?", "Guard içeriği okuyabilir mi?"
*Eşik:* Ö5'te tanımlıdır. **Bu deney, projenin en büyük itibar riskinin denetimidir.** Kullanıcı Guard'ı olduğundan güçlü sanıyorsa, arayüz başarısızdır — mekanizma ne kadar iyi olursa olsun.

#### 11.1. Karar eşikleri

| # | Ölçüt | Eşik |
|---|---|---|
| Ö1 | **Maliyet** (E1) | netns + pasta yolu, taban duruma göre bağlantı gecikmesinde ve 24 saatlik pil tüketiminde **kabul edilebilir** bir artış üretir. Eşiğin sayısal değeri E1'in taban ölçümü yapıldıktan sonra, ölçüme bakarak belirlenecektir — **şimdi bir sayı yazmak uydurma olur.** Eşik, ölçüm yayımlandığı gün ve puanlama başlamadan önce yazılır. |
| Ö2 | **Profil 2'nin gerçek gücü** (E3) | Literal IP denemeleri reddediliyor; CDN ortak-kiracılığı ölçülmüş ve arayüzde §9.2'deki metinle doğru anlatılıyor |
| Ö3 | **Soru sayısı** (E4) | §5 etkinken uygulama başına haftalık kullanıcı kararı sayısı, ham koşula göre en az bir büyüklük mertebesi düşük **ve** günlük yaşamda rahatsız edici bulunmayan bir düzeyde |
| Ö4 | **Çekirdek hazırlığı** (E6) | Seçilen taban ve aday cihazda gerekli tüm çekirdek özellikleri mevcut; değilse yedek yol (§10.3) belgelenmiş |
| Ö5 | **Dürüstlük** (E8) | Katılımcılar, Guard'ın **içeriği göremediğini** ve profil 4'ün bir kısıtlama olmadığını doğru ifade edebiliyor |
| Ö6 | **Günlük gizliliği** (E5) | §7.3'ün dokuz kuralının tamamı otomatik testle doğrulanıyor; silme testi geçiyor |
| Ö7 | **Lisans** (§5.3) | Dağıtılan tüm liste verileri [RFC-0001](0001-karar-kaydi.md) D1 ile uyumlu; NC lisanslı hiçbir veri dağıtımda yok |

Ö5 veya Ö6 karşılanamıyorsa doğru davranış özelliği zayıflatarak göndermek değil, **vaadi daraltmak ve daraltmayı ilan etmektir** — [RFC-0004](0004-tarayici-motoru.md) §9.2'nin aynı kuralı.

#### 11.2. Gözden geçirme ve çıkış koşulları

- **Her 12 ayda bir:** §4'ün kaçınma vektörü envanteri yeniden ölçülür ve yayımlanır. Özellikle ECH yaygınlığı ve CDN yoğunluğu rakamları eskir; değişmeyen bir tablo ölçülmediğinin işaretidir.
- **Olay tetiklemeli:** Yeni bir kaçınma vektörü bulunduğunda §4 ve §9.4 aynı sürümde güncellenir. Kullanıcıya söylenen sınırlar, bilinen sınırların gerisinde kalamaz.
- **Çıkış koşulları:** (a) E1 ölçümü netns yolunu telefon sınıfı donanımda taşınamaz gösterirse mimari yeniden açılır; (b) upstream'de bir ağ portalı kabul edilirse OZERK'in özel yolu terk edilip portala geçilir (D3); (c) §4'teki bir vektör profil 2'yi anlamsız kılacak ölçüde yaygınlaşırsa profil 2 sınıf E'den çıkarılır ve kullanıcıya bildirilir.

---

## Alternatifler

**A1 — Hiçbir şey yapmamak; kararı ertelemek.** Savunulabilir: platform kodu henüz yoktur ve Guard v0 zaten yol haritasında tanımlıdır. Reddedilme gerekçesi: v0'ın hangi mekanizmayla kurulacağı, sonradan değiştirilmesi en pahalı karardır. Uygulama başına namespace ile cgroup filtresi arasındaki seçim, uygulamanın **nasıl başlatıldığını** belirler; D2 gösterimi bir yol seçmeden yapılamaz. Ayrıca [RFC-0002](0002-taban-dagitim.md)'nin Ö6 puanlaması bu belgeye bağımlıdır.

**A2 — Yalnızca gözlem; hiç zorlama yok.** Little Snitch for Linux'un konumu budur ve dürüsttür: *"built for privacy, not security."* Guard yalnızca kaydeder, hiçbir şeyi engellemez. Avantajı: kaçınma vektörlerinin hiçbiri bir güvence iddiasını çürütmez, çünkü güvence yoktur; ayrıca hiçbir uygulamayı kırmaz. Reddedilme gerekçesi: manifesto §9.2 beş **profil** tanımlar, beş rapor türü değil; ve profil 1 zaten bugün Flatpak ile zorlanmaktadır — zorlamayı bırakmak var olan bir yeteneği geri almak olur. Yine de bu alternatifin özü benimsenmiştir: **profil 4'te Guard tam olarak budur ve öyle etiketlenir.**

**A3 — Yalnızca ikili izin (GrapheneOS modeli).** Ağ ya vardır ya yoktur; alan adı katmanı hiç kurulmaz. Avantajları gerçektir: kırılmaz bir güvence, sıfır izin yorgunluğu, düşük maliyet, kaçınma vektörlerinin çoğu konu dışı kalır. Reddedilme gerekçesi: manifesto §5'in ikinci maddesi ("kullanıcı, bir uygulamanın yalnızca hangi sensörlere değil, **hangi sunuculara** eriştiğini de görebilmelidir") ve §7'nin 6. hakkı bunu gerektirir; ikili izin bu vaadi karşılamaz. **Ancak bu alternatifin en değerli kısmı benimsenmiştir:** profil 1, GrapheneOS'un ağ izniyle aynı sertlikte kurulur ve teşvik edilen varsayılan odur. Alan adı katmanı, ikili iznin yerine değil **yanına** konur.

**A4 — TLS araya girme (sahte kök sertifika).** İçerik denetimi tek bu yolla mümkündür ve "izleyici tespiti" iddiasını gerçekten kanıtlanabilir kılardı. **Manifesto §9.2 tarafından açıkça yasaklanmıştır** ve bu RFC yasağı desteklemektedir. Gerekçeler: (a) kırmızı çizgi 15'in teknik hâlidir — kullanıcının cihazına, kullanıcının denetlemediği bir güven çapası konur; (b) saldırı yüzeyini devasa büyütür; Guard'ın bir açığı, tüm TLS trafiğinin açığı olur; (c) sertifika sabitlemesi kullanan her uygulamayı kırar; (d) uygulamanın gizliliğini kırmak için kullanıcının güvenlik modelini kırmayı gerektirir. **Bu seçenek RFC'de yeniden açılmayacaktır.**

**A5 — Yalnızca DNS düzeyinde, cihaz genelinde engelleme (Lockdown / hosts dosyası modeli).** En ucuz yol: tek bir çözümleyici, bir engelleme listesi, uygulama başına hiçbir şey. Reddedilme gerekçesi: manifesto §9.2 **uygulama başına** profil ister; cihaz geneli bir liste "hangi uygulama kiminle konuşuyor" sorusunu cevaplamaz. Ayrıca sabit IP ve uygulama içi DoH ile kolayca atlanır — bu RFC'nin çözümleyici-çapalı varsayılan-ret mimarisinin var olma nedeni tam olarak budur.

**A6 — Flatpak'ı forklamak.** Ağ izni granülerliğini doğrudan Flatpak'a eklemek, upstream'i beklemeden. Reddedilme gerekçesi: [RFC-0001](0001-karar-kaydi.md) D3 forku son çare sayar ve burada gerek yoktur — pasta tabanlı mimari, **Flatpak'ı değiştirmeden**, `bwrap` çağrısının etrafında çalışır. Ayrıca upstream tartışması (`xdg-desktop-portal#1166`) açıktır ve bakımcıların tarif ettiği çözüm bu mimarinin aynısıdır; fork yerine katkı, hem D3'e hem fon stratejisine uygundur.

**A7 — Zorunlu HTTP(S) vekili + uygulamalara vekil ayarı.** Uygulama trafiği bir yerel vekile yönlendirilir; vekil `CONNECT` hedefini görür ve isim düzeyinde karar verir. Cazip görünür çünkü ad, IP'den önce görülür. Reddedilme gerekçeleri: (a) uygulamalar vekil ayarını yok sayabilir — zorlanamayan bir kural kuraldır değil; (b) şeffaf vekilleme TLS'i kırmadan hedefi göremez, kırmak ise A4'tür; (c) `CONNECT` yalnızca HTTP ailesini kapsar, QUIC ve diğer protokolleri kapsamaz. **Yalnızca C ve D sınıfında geçerlidir** ve orada zaten daha temiz bir yolla (runtime origin denetimi) yapılır.

**A8 — seccomp kullanıcı bildirimiyle `connect()` yakalama.** §2.5'te man sayfası alıntısıyla elenmiştir: mekanizma, işaretçi argümanlı sistem çağrılarında güvenlik politikası uygulamak için **kullanılamaz**.

---

## Açık Sorular

1. **Uygulama başına ağ namespace'inin pil maliyeti telefon sınıfı donanımda kabul edilebilir mi?** Bu, RFC'nin tek en büyük belirsizliğidir. Yayımlanmış hiçbir ölçüm yoktur (§2.1). E1 cevaplamazsa Guard v1'in mimarisi değişir. Ö1'in sayısal eşiği de E1'in taban ölçümünden sonra yazılacaktır.
2. **Profil 2 hangi noktada "sınıf E" sayılmayı hak eder?** Çözümleyici-çapalı allowlist, adı değil adresi zorlar. E3'ün CDN ortak-kiracılık ölçümü belirli bir eşiği aşarsa (ör. izin verilen adreslerin büyük bir bölümü paylaşımlıysa), profil 2'yi "zorlanan" diye etiketlemek dürüst olmayabilir. Eşik kim tarafından, hangi veriyle belirlenecek?
3. **[RFC-0003](0003-paket-formati.md) Açık Soru 1'in cevabı ne olmalı?** Guard hazır olmadan profil 2 ve 3 beyan eden paketler depoda kabul edilmeli mi? Bu RFC "evet" eğilimindedir (beyanın denetim değeri zorlamadan bağımsızdır) ama karar RFC-0003'e aittir ve iki belge birlikte kapatılmalıdır.
4. **Kuruluş (entity) eşlemesi nereden gelecek?** Tracker Radar ve Disconnect'in CC BY-NC-SA lisansı bunları dışarıda bırakıyor (§5.3). EasyPrivacy izleyici **tespiti** için yeterli ama **sahiplik** eşlemesi taşımıyor. OZERK kendi açık lisanslı eşleme tablosunu mu tutacak, yoksa bu katman hiç olmayacak mı? Maliyeti ölçülmemiştir.
5. **Uygulamayı Guard'ın başlatmadığı durumlar nasıl ele alınacak?** Geliştirici modu, terminal, `coldbrew` benzeri araçlar ([RFC-0002](0002-taban-dagitim.md) §3). Bunlar modelin dışındadır (§1.3/5) — kullanıcıya nasıl gösterilecek ve Gizlilik Merkezi'nde nasıl temsil edilecek?
6. **Profil 5'in tanımı daraltılmalı mı?** §3.5'teki gözlem doğrulanırsa (kullanıcı namespace'i içinde ham soket, yalnızca kendi izole ağını görür), "ham ağ erişimi — özel yüksek riskli yetki" tanımı manifesto §9.2'de olduğu gibi kalamaz. Manifesto tadili mi gerekir, yoksa RFC düzeyinde bir yorum yeterli mi?
7. **Guard'ın kendi yukarı akış DNS'i kimin olacak?** Guard, uygulamalar adına şifreli DNS yapacaksa bir çözümleyici seçmek zorundadır. Varsayılan bir sağlayıcı seçmek, tüm kullanıcıların sorgularını tek bir tarafa yönlendirmek demektir — bu, manifesto §6.12'nin ("bulut isteğe bağlıdır") ruhuyla gerilim yaratır. Varsayılan hiç olmamalı mı (yalnızca ağın verdiği çözümleyici), yoksa kullanıcı ilk kurulumda mı seçmeli?
8. **`[X-OZERK*]` grupları Flatpak araç zincirinden korunarak geçiyor mu?** [RFC-0003](0003-paket-formati.md) Açık Soru 5, Guard v1 için **bloke edicidir** (§6.1). Ölçülmeden v1 planlanamaz.
9. **Günlük saklama süresi varsayılanı 7 gün mü olmalı, 24 saat mi?** Manifesto §9.3 "son 24 saat" der. 7 gün daha yararlıdır ve sektör oradadır (Android 13+, iOS), ama daha fazla veri daha fazla risktir (§7.1). Varsayılanı uzun tutup kullanıcıya kısaltma imkânı vermek mi, yoksa kısa tutup uzatma imkânı vermek mi daha doğru?
10. **Guard'ın kendi kaynak kodu ve kural seti kullanıcı tarafından denetlenebilir mi?** Manifesto §6.4 açık kaynağı garanti eder, ama Guard'ın **çalışan** kural setinin (nftables kümesi, çözümleyici görünümü) kullanıcıya gösterilip gösterilmeyeceği kararlaştırılmamıştır. Gösterilirse bu, "gözlemlenen"i doğrulamanın tek yoludur; gösterilmezse Guard bir kara kutudur.
11. **Salt okunur taban ile politika depolaması** ([RFC-0002](0002-taban-dagitim.md) §7/3). Duranium benzeri bir mimaride Guard'ın kural setleri `/etc` ve `/var`'da yaşamalıdır. Kullanıcıya ait politika (`~/.config`) ile sistem politikası arasındaki öncelik sırası tanımlanmamıştır: kullanıcı, bir uygulamanın beyan ettiğinden **daha geniş** ağ erişimi verebilmeli midir?

---

## English

# RFC 0005: The OZERK Guard Network Model

> The Turkish text is normative in case of discrepancy.

- **RFC:** 0005
- **Title:** The OZERK Guard Network Model
- **Status:** Draft
- **Date:** 2026-08-17
- **Author(s):** OZERK founder
- **License:** CC BY-SA 4.0
- **Open decision addressed:** [RFC-0001](0001-karar-kaydi.md) — A5
- **Related manifesto chapters:** 5, 6.3, 6.9, 7, 9 (all), 10, 13, 23, 24
- **Related RFCs:** [RFC-0002](0002-taban-dagitim.md), [RFC-0003](0003-paket-formati.md), [RFC-0004](0004-tarayici-motoru.md)

> **Verification note.** The technical claims in this document were checked on 17 August 2026, wherever possible against **primary sources**: kernel documentation (`docs.kernel.org`), man pages, the kernel and nftables source trees, IETF RFC texts, project repositories and project FAQs. Blog posts are cited only where no primary source exists, and are marked as secondary. Every line that could not be verified is marked **"to be verified"**; those are not claims but a work list. **No unmeasured number is presented as measured in this document.** In particular, no published measurement of pasta/passt's battery and latency cost was found; rather than invent one, this is defined as an experiment (E1).

### Summary

This RFC defines **which Linux mechanisms can enforce manifesto §9.2's five network profiles, and to what extent**, and names the unenforceable part rather than hiding it.

The proposal in three sentences:

1. **Guard splits in two.** A *hard boundary*: whether an application may reach the network at all — enforced by kernel-level network namespace isolation, and valid even against a determined adversary. A *soft boundary*: **whom** it reaches — resting on observation and on system-controlled name resolution; evadable, and not guaranteeable.
2. **The enforcement architecture is: a per-application network namespace + `pasta` (passt) + a system-controlled resolver + a resolver-anchored nftables IP set.** The only permitted destination set is the addresses Guard's own resolver returned for that application's declared names. This design **structurally** neutralizes hardcoded IP literals and in-app DoH for profiles 1–3.
3. **The model is not coercive content inspection.** Manifesto §9.2 forbids planting fake root certificates; this is the right decision, and its price is that Guard sees **flow metadata**, not content. Guard's honest name is therefore: **it makes honest applications transparent and lazy bad actors ineffective; it does not stop a determined adversary.**

That third sentence is the spine of this document and may not be translated into marketing language.

**The hardest finding must be stated up front.** A commercial, eBPF-based product doing the same job — Little Snitch for Linux — writes on its own page: *"Little Snitch for Linux is built for privacy, not security, and that distinction matters."*; *"Under heavy traffic, cache tables can overflow, which makes it impossible to reliably tie every network packet to a process or a DNS name."*; *"reconstructing which hostname was originally looked up for a given IP address requires heuristics rather than certainty"*; *"For hardening a system against a determined adversary, it's not the right tool."*

OZERK has **two structural advantages** over that product, and only these two may be claimed: (a) Guard launches the application itself, so it knows the process↔connection binding by construction rather than by inference; (b) the application is already inside a sandbox, so the network namespace is a field of an existing sandbox rather than a layer bolted on afterwards. Beyond those two, the sentences above apply to OZERK verbatim.

### Motivation

Manifesto §9.2 defines five network profiles and promises the user five things (the domain contacted, the time, the volume of data, blocked requests, newly added destinations). **It never discusses the enforcement mechanism.** [RFC-0003](0003-paket-formati.md) deliberately left this gap and made the honest finding: *"with Flatpak today, 1 and 4 are real; 2 and 3 are promises."*

This RFC must close that gap, because:

- **Guard is the project's flagship feature.** [RFC-0001](0001-karar-kaydi.md) A5: "a promise that cannot be enforced violates the manifesto's honesty commitment." The single largest reputational risk identified in review is exactly this: making Guard look stronger than it is.
- **The roadmap has already committed to a date.** Months 4–8 close with demo gate D2: *"In a live demonstration, Guard blocks a chosen application's access to a specific domain name, and the event appears in the log."* Which mechanism performs that demonstration — and what it does **not** prove — must be written in advance.
- **Delay entrenches the wrong architecture.** The choice between a per-application network namespace and a cgroup filter determines how the application is launched; that is the most expensive decision to reverse.
- **The base distribution decision depends on it.** [RFC-0002](0002-taban-dagitim.md)'s criterion Ö6 ("Guard infrastructure readiness") cannot be scored until Guard's kernel requirements are written down.

And most importantly: **§9.2's ban on fake certificates bounds what the model can be from the outset.** The ban is correct — installing a root certificate on the user's device to decrypt HTTPS is the technical form of red line 15 ("turning the user into a tenant of their own device"), it enormously enlarges the attack surface, and it breaks every application that pins certificates. But the price is plain: **what Guard can see is flow metadata, not content.** This RFC accepts that reduction and builds the model on top of it.

### Design

#### 1. Threat and scope model

##### 1.1. Two different boundaries

Guard is not one thing. It is two mechanisms in two different power classes, and they may **never be presented with equal weight**, in the interface or in the documentation.

| | **Hard boundary** | **Soft boundary** |
|---|---|---|
| Question | May the app reach the network? | **Whom** may the app reach? |
| Mechanism | Kernel-level network namespace isolation | Control of name resolution + IP-level filtering |
| Basis | The app has no network interface to reach | The app's destination is inferred; the inference may be wrong |
| Evadable? | **No.** Requires a kernel vulnerability. | **Yes.** By the vectors in §4. |
| Valid against | Everyone, determined adversaries included | Only software that is not trying to evade |
| Manifesto profile | 1 (and the "off" state of 4) | 2, 3 |

##### 1.2. What Guard protects against

The part of manifesto §10.1's list that Guard genuinely covers:

1. **A legitimate-looking application sending data without the user's knowledge.** The app is not malicious; it simply connects to a server it did not declare. Guard sees it, records it, blocks it under profiles 2–3, and makes the declaration/behaviour divergence (§13) detectable. **This is Guard's primary target.**
2. **Advertising and tracking SDKs.** These do not try to hide; they connect to known endpoints, under known names, over plain DNS. This is Guard's second effective area.
3. **Silent background transfer.** Connections made while the app is closed or the screen is off; a timestamped record makes them visible.
4. **Accidentally broad reach.** A library connecting to a telemetry endpoint without the developer's knowledge. Guard shows this to the developer too; that is a feature of the `ozerk` toolchain.
5. **An application that needs no network reaching the network.** Profile 1. This is the only **hard** protection on the list and the most valuable one: for a calculator, a reader, a local notes app, network access simply does not exist, and that claim is absolute.

##### 1.3. What Guard does NOT protect against

This list is the network counterpart of manifesto §10.2 ("limits explicitly accepted") and must be reachable from the interface (§9.4).

1. **A malicious application that persistently tries to evade.** Under profile 2 it can connect to a permitted address and proxy through it; it can embed data in DNS queries; it can reach another tenant behind a permitted CDN IP. **Guard cannot stop this and does not claim it can.**
2. **Content.** That a connection exists, its destination, time and size are visible; **what was sent is not.** This is the direct consequence of the fake-certificate ban (§9.2; [RFC-0003](0003-paket-formati.md) §6/Class B).
3. **Server-side behaviour.** What happens to the data after it reaches the recipient is unobservable.
4. **Indirect paths through other components.** An application can make a component that does have network access do the work for it. This is a documented reality on Android (NetGuard FAQ 19) and the reason GrapheneOS designs for "direct **and indirect** access". OZERK adopts that design (§8.2), but its coverage extends only as far as the portal and D-Bus policy reaches.
5. **Processes Guard did not launch.** Guard's power comes from **launching the application itself**. A binary the user runs from a terminal, a process in developer mode, or a system service is outside the per-application model. This is OZERK's equivalent of NetGuard's "no protection during early boot-up" limit, and it is not hidden.
6. **Kernel and firmware.** Manifesto §10.2 already accepts this; Guard makes no exception.

##### 1.4. The clear answer

> **Guard makes honest applications transparent and lazy bad actors ineffective. It does not claim to stop a determined adversary.**
>
> The single exception is profile 1: an application with no network access cannot reach the network, however determined it is. This is the **only absolute** assurance Guard gives, and precisely for that reason it is the profile to be encouraged most.

This sentence must be usable **unabridged** in the store, in the Privacy Center and in promotional text. Abridged, it becomes false.

#### 2. Enforcement architecture: concrete Linux mechanisms

##### 2.1. Network namespace + a userspace network gateway (pasta / passt)

**What it is.** The application is launched in its own network namespace. Its connection to the outside is provided by an unprivileged userspace gateway.

`pasta` is the second command name of the `passt` binary. The project describes passt as *"a translation layer between a Layer-2 network interface and native Layer-4 sockets"*, and pasta as *"equivalent functionality, for network namespaces"*. Per `pasta(1)`: *"A tap device within the network namespace is created to provide network connectivity"*, and *"For local TCP and UDP traffic only, pasta also implements a bypass path directly mapping Layer-4 sockets between init and target namespaces, for performance reasons"* — using `splice(2)` for TCP and `recvmmsg(2)`/`sendmmsg(2)` for UDP.

**Privilege requirement — the decisive property.** The tap device is created **inside** the namespace; the project writes *"without the need to create further interfaces on the host, hence not requiring any capabilities or privileges."* passt/pasta also runs without `CAP_NET_RAW` and drops every capability other than `CAP_NET_BIND_SERVICE`. Dynamic allocation is blocked with seccomp; AppArmor and SELinux profiles ship with the project.

This lands directly on [RFC-0003](0003-paket-formati.md)'s Flatpak base, and it is the resolution of the deadlock in the xdg-desktop-portal discussion. Flatpak maintainer `mwleeds` explained why network permission granularity had not been done: *"kernel APIs require root to do network namespacing, and Flatpak runs unprivileged."* `smcv` described the architecture required: *"unsharing the network namespace, having some sort of bridge (slirp4netns or similar) between the app's netns and the host machine's netns, and then having that bridge be remote-controllable so it will selectively block or allow traffic under xdg-desktop-portal's control."* **pasta is exactly that bridge, and it needs no privilege.**

**The DNS hook comes for free.** `pasta(1)`: `--dns-forward addr` — *"Map addr … as seen from guest or namespace to the nameserver … specified by the --dns-host option. Maps only UDP and TCP traffic to port 53 or port 853"*. Per-application DNS interception is thus obtained structurally at the L4 boundary, with no separate NAT rule. **This solves attribution by architecture rather than by inference** — the thing OpenSnitch fights for with `/proc` scanning and libc uprobes is known here by construction.

**Maturity.** Podman added pasta as an option in **v4.4.0** and made it the **default** for rootless containers in **v5.0.0**: *"The default tool for rootless networking has been swapped from `slirp4netns` to `pasta` for improved performance."* (Claims that it became default in Podman 5.3 are wrong; the primary source says 5.0.0.) Distributions with official packages include Alpine, Debian, Fedora, openSUSE, Ubuntu, Arch, Gentoo and Void — so it is available on both the postmarketOS and Mobian bases.

**Cost — unmeasured.** The project's own claim is *"4 to 50 times IPv4 TCP throughput of existing, conceptually similar solutions depending on MTU"*. **That is a ratio claim whose baseline is slirp-like solutions, not veth/bridge**, so it cannot be used to say "pasta costs X% more than veth". No comparison table against veth/bridge published by the project or by Podman **was found**, and no credible measurement of the CPU cost of userspace TCP on ARM was found either. There are open reports about pasta CPU load in the Podman tracker, but those are bug reports, not measurements, and no number may be quoted from them. **This is a gap, and it will be closed by experiment E1. This RFC gives no number on the subject.**

**slirp4netns comparison.** slirp4netns runs libslirp's full userspace TCP/IP stack behind a tap inside the namespace and performs NAT; every packet traverses an emulated stack. pasta mirrors the host's addressing and routing into the namespace (no NAT) and short-circuits local traffic with `splice()`. Both are unprivileged. OZERK prefers pasta; slirp4netns is the fallback.

**veth + bridge (the classic path).** Kernel datapath, lowest CPU cost. But it needs `CAP_NET_ADMIN`, i.e. a privileged helper process. That breaks Flatpak's unprivileged model and enlarges the attack surface. **Rejected**, though it may be considered for Guard's own system services (class A).

| Dimension | Assessment |
|---|---|
| Profiles enforceable | **1, 2, 3, 4** — all |
| Kernel requirement | User and network namespaces (`CONFIG_USER_NS`, `CONFIG_NET_NS`); Flatpak already uses these |
| Privilege | None |
| With Flatpak | Natural: the app is already launched via bwrap; `--unshare-net` is given and the gateway attached to the namespace |
| Cost | **Unmeasured** (E1). Userspace datapath; suspend/resume behaviour must also be measured |
| Bonus | Per-app DNS interception (`--dns-forward`); closes access to host abstract unix sockets (below) |

**Side benefit: Flatpak's localhost hole closes.** The Flatpak documentation carries this footnote: *"Giving network access also grants access to all host services listening on abstract Unix sockets (due to how network namespaces work), and these have no permission checks."* In the portal discussion `swick` makes it concrete: *"the big issue with flatpak networking right now is that it has the exact same access as the host and can connect and expose tcp and udp services on all of localhost … all flatpak'ed apps can access, and man-in-the-middle it as well."* A separate network namespace per application solves this class of problem **by design**. On its own, whatever the cost, this is sufficient justification for the architecture.

##### 2.2. cgroup v2 + the nftables `socket cgroupv2` match

**Syntax** (verbatim from `nft(8)`, SOCKET EXPRESSION):

```
table inet x {
    chain y {
        type filter hook input priority filter; policy accept;
        socket cgroupv2 level 1 "user.slice" counter
    }
}
```

**Level semantics** (verbatim from `nft(8)`): *"You can also use it to match on the socket cgroupv2 at a given ancestor level, e.g. if the socket belongs to cgroupv2 a/b, ancestor level 1 checks for a matching on cgroup a and ancestor level 2 checks for a matching on cgroup b."* The level is the depth of the path component named, counted from the cgroup root, and must equal the number of segments in the string.

**Versions.** Kernel side **5.13** (Pablo Neira Ayuso, "netfilter: nft_socket: add support for cgroupsv2", `NFTA_SOCKET_LEVEL`). Userspace **nftables 0.9.9** (its release announcement lists "cgroupsv2 support"; absent in 0.9.4).

**Three serious constraints — two of which are not in the man page and were read from source:**

1. **Path→id resolution happens in userspace, at ruleset load.** nftables `src/datatype.c` opens the cgroup path with `stat()` and embeds the **inode number** in the rule; the kernel only ever compares a 64-bit numeric cgroup id. Consequences: the cgroup **must exist** at load time, otherwise the load fails with `cgroupv2 path fails: No such file or directory`; and **if the cgroup is deleted and recreated it gets a new inode number, so the loaded rule silently stops matching.** This constraint is not documented in `nft(8)`.
2. **Hooks are PREROUTING, INPUT and OUTPUT only.** In the kernel, `nft_socket_validate()` rejects any other hook with `-EOPNOTSUPP`. FORWARD and POSTROUTING cannot be used — correct, since a forwarded packet has no local socket.
3. The socket must resolve and the namespace must match, otherwise the rule yields `NFT_BREAK`. Level numbering is rebased on the current cgroup namespace's root.

**What this means for OZERK — critical.** When systemd is available, Flatpak places app processes in a transient systemd scope. The Flatpak documentation gives the pattern: *"When systemd is available, Flatpak tries to put app processes in a scope such as `app-flatpak-com.brave.Browser-*.scope`"*, the asterisk being *"replaced by an arbitrary suffix."* So **the cgroup path differs for every app instance and is recreated on every launch.**

Therefore `socket cgroupv2` rules **cannot be written statically**. Guard would have to reload the rule on every launch, and there is a **race window** between scope creation and rule load in which the app can already connect. That window must be measured (E2). This does not eliminate the mechanism, but it shows it is **not sufficient on its own**: with a per-application namespace there is no such race, because the namespace exists before the application does.

##### 2.3. eBPF cgroup hooks

Verified hook↔version mapping (`docs.kernel.org/bpf/libbpf/program_types.html` and kernelnewbies release notes):

| ELF section | Program type | Attach type | Kernel |
|---|---|---|---|
| `cgroup/sock_create` | `BPF_PROG_TYPE_CGROUP_SOCK` | `BPF_CGROUP_INET_SOCK_CREATE` | 4.10 |
| `sockops` | `BPF_PROG_TYPE_SOCK_OPS` | `BPF_CGROUP_SOCK_OPS` | 4.13 |
| `sk_skb` | `BPF_PROG_TYPE_SK_SKB` | (sockmap) | 4.14 |
| `cgroup/bind4` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_INET4_BIND` | 4.17 |
| `cgroup/connect4` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_INET4_CONNECT` | 4.17 |
| `cgroup/connect6` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_INET6_CONNECT` | 4.17 |
| `cgroup/sendmsg4` | `BPF_PROG_TYPE_CGROUP_SOCK_ADDR` | `BPF_CGROUP_UDP4_SENDMSG` | 4.18 |
| `cgroup/skb` | `BPF_PROG_TYPE_CGROUP_SKB` | `BPF_CGROUP_INET_{INGRESS,EGRESS}` | 4.10 |

**These hooks are not allow/deny only; they can rewrite addresses.** The original patch cover letter states they *"let bpf prog look and modify 'struct sockaddr' provided by user space"*. So `connect4`/`connect6` can transparently rewrite the destination IP and port (this is how Cilium does service load balancing), and `sendmsg4/6` does the same for unconnected UDP. **For Guard this means an application can be redirected to a local proxy without changing its configuration.** `sock_create` is allow/deny plus limited socket-field modification, not address translation.

**systemd already wraps these hooks** (`systemd.resource-control(5)`):

| Option | systemd's own wording | Version |
|---|---|---|
| `IPAddressAllow=` / `IPAddressDeny=` | *"Turn on network traffic filtering for IP packets sent and received over AF_INET and AF_INET6 sockets"* | **v235** |
| `SocketBindAllow=` / `SocketBindDeny=` | *"The feature is implemented with cgroup/bind4 and cgroup/bind6 cgroup-bpf hooks."* | **v249** |
| `RestrictNetworkInterfaces=` | *"The feature is implemented with cgroup/sock_create cgroup-bpf hooks."* | **v250** |

**And this composes directly with Flatpak.** The Flatpak documentation describes persistent per-app resource control: create `~/.config/systemd/user/app-flatpak-com.brave.Browser-.scope.d/memory.conf`, and after `systemctl --user daemon-reload` *"those `systemd.resource-control(5)` parameters will apply to all instances of that app."*

> **Finding.** Guard can apply per-application IP filtering with `IPAddressAllow=`/`IPAddressDeny=` by generating one systemd scope drop-in per application id, **without writing any eBPF of its own**. This also resolves the transient-scope race of §2.2, because the drop-in is written against the **stable prefix** of the scope name and applies to every instance.

This is the lowest-cost, least-new-code enforcement path for Guard v1, and it is fully aligned with D3 (upstream-first).

**Limits.** The systemd man page states **no minimum kernel version** for these options; it only says *"these settings might not be supported on some systems (for example if eBPF control group support is not enabled in the underlying kernel…)"*. It depends on `CONFIG_CGROUP_BPF`, `BPF_SYSCALL` and `NET`. These may be off in vendor kernels — exactly the risk [RFC-0002](0002-taban-dagitim.md) §7 item 1 points at, to be measured by E6. Also, `IPAddressAllow=` is **IP-level only**; there is no domain vocabulary.

##### 2.4. Landlock

**Verified ABI table** (`landlock(7)` and `docs.kernel.org/userspace-api/landlock.html`):

| ABI | Kernel | Added |
|---|---|---|
| 1 | 5.13 | Filesystem rights |
| 2 | 5.19 | `LANDLOCK_ACCESS_FS_REFER` |
| 3 | 6.2 | `LANDLOCK_ACCESS_FS_TRUNCATE` |
| **4** | **6.7** | **`LANDLOCK_ACCESS_NET_BIND_TCP`, `LANDLOCK_ACCESS_NET_CONNECT_TCP`** |
| 5 | 6.10 | `LANDLOCK_ACCESS_FS_IOCTL_DEV` |
| 6 | 6.12 | `LANDLOCK_SCOPE_ABSTRACT_UNIX_SOCKET`, `LANDLOCK_SCOPE_SIGNAL` |
| 7 | 6.15 | Audit / logging flags |
| 8 | 7.0 | `LANDLOCK_RESTRICT_SELF_TSYNC` |
| 9 | 7.1 | `LANDLOCK_ACCESS_FS_RESOLVE_UNIX` |
| 10 | 7.2 | `LANDLOCK_ACCESS_NET_BIND_UDP`, `LANDLOCK_ACCESS_NET_CONNECT_SEND_UDP` |

> **The answer to the question: Landlock's TCP bind/connect support arrived in Linux 6.7, with Landlock ABI 4.** UDP support is not proposed but **landed**: ABI 10. Kernel documentation verbatim: *"`LANDLOCK_ACCESS_NET_BIND_UDP`: Bind UDP sockets to the given local port. Support added in Landlock ABI version 10."*
>
> The ABI 8–10 rows were read from kernel 7.x documentation; whether those versions are present on candidate device kernels **must be verified** (E6).

**And the decisive limit for Guard:** *in Landlock, the object of a network rule is a **port**, not an address.* The structure is `struct landlock_net_port_attr { __u64 allowed_access; __u64 port; }` — **there is no address field.** Kernel documentation: *"For these rules, the object is a TCP or UDP port."* Therefore with Landlock:

- ✅ "this application may not listen on any port" is expressible,
- ✅ "this application may connect only to 443" is expressible,
- ❌ "this application may connect only to `sync.example.org`" **is not expressible** — no IP, no CIDR, no name, no DNS awareness.

There is also an asymmetry in UDP: there is **no receive right**, and the connect right is defined as "connect-or-send". For raw sockets the kernel documentation contains **no explicit statement**; only the four TCP/UDP rights exist, so raw sockets are out of scope by construction, but that is not written anywhere — **to be verified**. The "Current limitations" section of the kernel documentation also has **no network-specific subsection**, meaning the ceiling is implicit and undocumented.

**Conclusion:** Landlock **cannot** be Guard's main enforcement mechanism. It is valuable in two places: (a) as defence in depth, forbidding the application to listen on ports; (b) ABI 6's `LANDLOCK_SCOPE_ABSTRACT_UNIX_SOCKET` adds a second lock, independent of namespaces, on the Flatpak localhost/abstract-socket hole noted in §2.1.

##### 2.5. seccomp user notification — rejected

There is a superficially attractive path: intercept `connect(2)` with seccomp user notification (`seccomp_unotify`) and ask the user. **This path is eliminated, and the reason is in its own man page.**

`seccomp_unotify(2)`, CAVEATS, verbatim:

> *"It should thus be absolutely clear that the seccomp user-space notification mechanism **can not** be used to implement a security policy!"*

and

> *"this mechanism must not be used to make security policy decisions about the system call, which would be inherently race-prone"*

and for `SECCOMP_USER_NOTIF_FLAG_CONTINUE`:

> *"there is a time-of-check, time-of-use race here, since an attacker could exploit the interval of time where the target is blocked waiting on the 'continue' response to do things such as rewriting the system call arguments."*

`connect()` takes its destination as a **pointer** to a `struct sockaddr`. After the supervisor reads the pointer and decides, the target process can change that memory. The path is structurally racy. **Guard will not use this mechanism for enforcement.** (Using it purely for observation is theoretically possible but the same race would corrupt the log's accuracy, so it is not used at all.)

##### 2.6. A mandatory local resolver and proxy

**Redirection.** Redirecting 53/853 with nftables is a standard technique; the nftables wiki gives the locally-generated case: `nft add rule nat output tcp dport 853 redirect to 10053`. `redirect` *"is a special form of dnat"* and *"only makes sense in prerouting and output chains of NAT type"*.

Three documented constraints:

- **Conntrack.** `nft(8)`: *"Only the first packet of a connection actually traverses this chain"* — a policy change does not apply to established flows; conntrack entries must be flushed when policy flips. Telling the user "blocked" while the flow continues is an unacceptable honesty failure.
- **`route_localnet`.** Redirecting to 127.0.0.0/8 across an interface boundary requires `net.ipv4.conf.*.route_localnet`, which defaults to off.
- **Scope.** Redirection covers only 53/853. It does not cover DoH (§4.1).

**Which resolver can carry per-application policy?** With a per-application namespace, every application has a distinct source IP, which makes source-IP views viable.

| Resolver | Per-app policy | Evidence |
|---|---|---|
| **unbound** | **Yes, genuine source-IP views.** `access-control-view` + `view:` clause; per-view `local-zone`. `log-queries`: *"Prints one line per query to the log, with the log timestamp and IP address, name, type and class."* | `unbound.conf` docs |
| **knot-resolver** | **Yes**, `view:addr()` — *"Views and ACLs allow to specify per-client policies"*. **Critical caveat:** *"the cache is shared by all requests"*; serving **different answers** per client is unsupported and produces unexpected behaviour. Only **allow/deny** is safe. | knot-resolver docs |
| **dnsmasq** | **No** (DHCP tags, not source IP). But its logging is good: `--log-queries=extra` adds a serial number and *"the IP address of the requestor"*. | `dnsmasq` man |
| **systemd-resolved** | **No.** Per-link configuration only; no per-client policy option and no query-log option. `resolvectl monitor` shows *"a continuous stream of local client resolution queries and their responses"* but **does not identify the requesting client or process.** | `resolved.conf(5)`, `resolvectl(1)` |

**Decision:** OZERK prefers **unbound** for Guard's resolver layer (per-view `local-zone` allow/deny, query logging with client IP); because of knot-resolver's shared-cache caveat, only allow/deny semantics are used. systemd-resolved may remain the system resolver but **cannot be Guard's policy point.**

**The musl / NSS connection — inheriting [RFC-0002](0002-taban-dagitim.md) §5.** RFC-0002 found: *"musl has no NSS support. If Guard is meant to sit in the DNS layer (A5), on a musl host this can only be done at the network layer; installing an NSS module is not an option."*

This RFC **confirms that finding and writes its consequence**: Guard was never going to install an NSS module. Both `pasta --dns-forward` and nftables 53/853 redirection operate **at the network layer** and are independent of libc. Therefore:

> **musl's lack of NSS is not an obstacle for this architecture; if anything it is a constraint that forces the right architecture.** An NSS module would only have caught applications using `getaddrinfo()`; every binary carrying its own resolver (Go, Rust, statically linked) would have bypassed it. Network-layer enforcement erases that distinction.

This feeds directly into RFC-0002's Ö6 scoring: **the libc choice does not constrain Guard's architecture.**

##### 2.7. Mechanism comparison

| Mechanism | Profile 1 | 2 | 3 | 4 | 5 | Kernel | Privilege | Flatpak fit |
|---|---|---|---|---|---|---|---|---|
| netns + pasta | ✅ hard | ✅ | ✅ | ✅ | partial | userns+netns | none | natural |
| netns + veth/bridge | ✅ hard | ✅ | ✅ | ✅ | partial | netns | `CAP_NET_ADMIN` | needs privileged helper |
| nftables `socket cgroupv2` | weak | IP-level | IP-level | ✅ | ❌ | 5.13 / nft 0.9.9 | `CAP_NET_ADMIN` | transient-scope race |
| systemd `IPAddressAllow=` (eBPF) | weak | IP-level | IP-level | ✅ | ❌ | `CONFIG_CGROUP_BPF` | system service | **natural via scope drop-in** |
| custom eBPF `cgroup/connect4` | ✅ | IP-level + redirect | ✅ | ✅ | ❌ | 4.17+ | `CAP_BPF` | possible |
| Landlock network rights | ❌ | ❌ (no address) | ❌ | ❌ | port-level | 6.7 (ABI 4) | none | natural, defence in depth |
| seccomp unotify | — | — | — | — | — | — | — | **rejected** (§2.5) |
| Mandatory resolver/proxy | ❌ | ✅ (name decision) | ✅ | observation | ❌ | — | system service | composes with netns |

**Proposed composition (Guard v1):**

```
Per-application network namespace (bwrap --unshare-net)
        + pasta (unprivileged gateway, DNS capture via --dns-forward)
        + unbound view (per-app allow/deny, query log with client IP)
        + resolver-anchored nftables IP set (default deny)
        + Landlock network rights (defence in depth: port limits, abstract-socket scoping)
        + systemd scope drop-in (fallback path for class A and where netns is too costly)
```

**The resolver-anchored allowlist (this RFC's central design idea).** In the application's namespace, the nftables default policy is **deny**. The only permitted destination set is **the IPs Guard's own resolver returned for that application's permitted names**; those IPs are added to an nftables set for the duration of the TTL. Two consequences, detailed in §4:

- **Hardcoded IP literals do not work under profiles 1–3.** If the app tries an IP directly, it is not in the set and the connection is dropped. This is the **inverse** of the classic IP-blocking model NetGuard describes in FAQ 48: there the default is allow and blocks are listed; here the default is deny and permits are derived from names.
- **In-app DoH does not work under profiles 1–3.** If the app tries to reach `1.1.1.1`, that address did not come from resolving a permitted name, so it is not in the set.

The price is equally plain and cannot be concealed: **shared CDN IPs** (§4.4). When one IP hosts both permitted and non-permitted names, opening the IP opens both.

#### 3. What the five profiles really amount to

This section **inherits and deepens** the table in [RFC-0003](0003-paket-formati.md) §4. It does not contradict RFC-0003's findings; it fills them in with mechanism.

**Profile 1 — no network access (`none`).** Enforceable today, fully, via `bwrap --unshare-net` / withholding `--share=network`. Class **E**. No evasion vector; a kernel vulnerability would be required. bubblewrap documentation notes that `--unshare-net` cuts **all** network access including localhost, and access to host abstract unix sockets closes too.

*Remaining gap — indirect access.* The application can have another component do the work: a portal, a D-Bus service, a helper app. GrapheneOS names this problem and designs for it: the network permission is defined as *"disallowing both direct and indirect access to any of the available networks"*, with indirect access blocked *"via OS components and apps enforcing the INTERNET permission, such as DownloadManager"*. **OZERK adopts this rule:** for an application with no network access, network-performing portals and D-Bus services also refuse. This requires portal and `xdg-dbus-proxy` policy to be constructed consistently with the network profile Guard reads.

*A second rule taken from GrapheneOS — the failure mode.* GrapheneOS: *"GrapheneOS pretends that the Network is down for most APIs when the Network permission is disabled"*, so apps do not spin in retry loops burning battery. **OZERK does the same:** under profile 1 the error is "no network", not "connection refused". This is a **battery** decision as much as a compatibility one, and it bears directly on the Phase 5 battery goal.

**Profile 2 — allowed domains only (`allowlist`).** Partially enforceable, and the "partially" must be defined. Mechanism: netns + pasta + Guard's resolver + resolver-anchored nftables set (default deny). Class **E after Guard v1, with a scope note**: what is enforced is less "only these names" than "only the addresses these names resolve to". Evasion vectors: shared CDN (§4.4), a permitted name used as a proxy (§4.6), DNS exfiltration (§4.7).

The honest formulation, which must appear in the interface:

> Guard permits the application to connect **only to the IP addresses the declared names resolve to**. This does not guarantee the name itself: if other names point at the same address, the application can reach them too.

This is the OZERK-language translation of what NetGuard has documented for years in FAQ 48: *"NetGuard blocks traffic based on the IP addresses an application is trying to connect to. If more than one domain name is on the same IP, they cannot be distinguished."* The difference: NetGuard operates default-allow and tries to block; OZERK operates default-deny and grants. **The same ambiguity runs in the opposite direction** — in OZERK the ambiguity is toward over-permitting, not over-blocking. That distinction must be told to the user.

TTL drift is a real problem (NetGuard FAQ 48 records it in the same place). Guard knows the TTL because it is the resolver; but the app's own cache may outlive Guard's set. Remedy: set entries are held for TTL plus a short tolerance, whose value **must be measured** (E3).

**Profile 3 — ask on new domains (`ask`).** Mechanically identical to profile 2; **in its raw form it is unusable** (§5). Class **E only if §5's grouping and pre-approval are implemented.** Evasion vectors: all of profile 2's, plus **permission fatigue** — if the user learns to tap "allow", profile 3 becomes profile 4. Android's permission model is the standing warning ([RFC-0003](0003-paket-formati.md) Alternative 6): the ecosystem settles on "ask for everything, the user will accept anyway". **Permission fatigue is profile 3's failure mode and must be designed against from the start.**

**Profile 4 — general internet access (`full`).** There is nothing to enforce. The list Guard produces is **not a restriction list but an observation record**, and the interface must render it in a different visual language (§9). Moreover, **under profile 4 even the observation is not guaranteed**: if the application uses its own DoH resolver, Guard sees only IPs. In that case the Privacy Center must say "we cannot resolve this application's destinations" — showing an empty list would be a lie.

**Profile 5 — raw network access (`raw`).** [RFC-0003](0003-paket-formati.md) §4's finding is inherited: *"the Flatpak sandbox does not leave `CAP_NET_RAW`. It cannot be granted inside the sandbox."* A refinement, not a correction: pasta itself runs **without** `CAP_NET_RAW`, so raw sockets are not needed by the gateway layer; and inside a user namespace a process may hold `CAP_NET_RAW` relative to that namespace and open raw sockets in **its own** network namespace — meaning profile 5 **loses its meaning** under a per-application namespace architecture: the app sees only its own isolated network and cannot sniff host traffic. **This behaviour must be verified** (E6); if confirmed, profile 5's definition should be narrowed and rewritten. Genuine raw-network needs (VPN client, network diagnostics, packet capture) require the host network namespace, i.e. stepping outside the sandbox; profile 5 therefore stays reserved for class A system applications and explicitly user-approved exceptions.

**Contribution to RFC-0003's E/V/B classification.** [RFC-0003](0003-paket-formati.md) §6 marked profiles 2 and 3 as *"Partially and in future — depends on Guard"*. This RFC sharpens that:

| Declaration | In RFC-0003 | After Guard v1 | Note |
|---|---|---|---|
| Profile 1 (`none`) | E | **E** | Unchanged; the only absolute assurance |
| Profile 2 (`allowlist`) | Partial / future | **E (with scope note)** | "the addresses the names resolve to" — not the name |
| Profile 3 (`ask`) | Partial / future | **E (with scope note)** | Only if §5 is implemented |
| Profile 4 (`full`) | E (absence of restriction) | **Observation** | Not class E; must not be labelled so |
| Profile 5 (`raw`) | Cannot be granted | **Cannot be granted** (except class A) | §3.5's refinement to be verified |
| Domain purpose strings | B | **B** | Unchanged; unverifiable |
| Nature of telemetry | B | **B** | Unchanged; content is invisible |

#### 4. Evasion vectors — an honest inventory

For each vector: **how it works**, **what Guard can do**, **what gap remains**. This section must be exhaustive; the absence of a vector here does not mean it does not exist, and this section is updated as new vectors are found.

**4.1. In-app DoH / DoT.** The app never uses the system resolver; it reaches a resolver over 443/TCP (or QUIC on 443/UDP) with its own DoH client. RFC 8484 §8.1 states this as a **design goal**: *"the use of the HTTPS default port 443 and the ability to mix DoH traffic with other HTTPS traffic on the same connection can deter unprivileged on-path devices from interfering with DNS operations."* §10 states the consequence: *"Filtering or inspection systems that rely on unsecured transport of DNS will not function in a DNS over HTTPS environment."* In browsers this is now default: Firefox made DoH default in the US on **25 February 2020** (Cloudflare and NextDNS) and in Canada on **8 July 2021** (CIRA). Chrome shipped "Secure DNS" in **Chrome 83** (19 May 2020) on a different model: *"auto-upgrading to the current DNS provider's DoH server which offers the same features"* — it does not switch the user's resolver. **No primary-sourced example of a non-browser application embedding its own DoH client was found**; that claim is not made here (**to be verified**).

*What Guard can do.* **Under profiles 1–3 the vector closes structurally**, because the DoH resolver's IP is not in the resolver-anchored default-deny set: the app either falls back to Guard's resolver or resolves nothing. *Soft signals:* Firefox's canary domain `use-application-dns.net.` (verified in Firefox source as `const GLOBAL_CANARY = "use-application-dns.net.";`) can disable DoH via NXDOMAIN, **but its limit is in Mozilla's own documentation**: *"The canary domain only applies to users who have DoH enabled as the default option. It does not apply for users who have made the choice to turn on DoH by themselves."* Bugzilla 1614751 was closed by a **documentation change, not code**. Chrome does not honour the canary at all. *The standards path:* **RFC 9462 (DDR)** — network-signalled designated resolver (DNR) indications *"SHOULD take precedence"* over those discovered via `resolver.arpa`. That is a local OS resolver's legitimate lever and OZERK should use it. *Upstream:* Guard uses DoH on its own upstream — plain DNS from app to Guard, encrypted DNS from Guard to the internet. The user's privacy is protected against the network operator; the application's privacy is not protected against the user. This trade must be written down.

*Remaining gap.* **Under profile 4 the vector is wide open and blinds observation.** And the canary-domain mechanism is a single-vendor, non-standard patch that Mozilla itself calls *"a limited-time measure"*; no assurance may rest on it.

**4.2. Hardcoded IP literals.** The app makes no DNS query and embeds the IP in its binary, bypassing every name-based control — the known blind spot of NetGuard/Lockdown-class solutions. *What Guard can do:* **under profiles 1–3 this vector is closed** — that IP is not in the resolver-anchored default-deny set. This is the proposed architecture's most concrete advantage over DNS-based blockers and the reason it was chosen. *Remaining gap:* wide open under profile 4.

**4.3. Encrypted Client Hello (ECH).** Status — verified, and different from the common belief:

- ECH is no longer a draft: **RFC 9849, "TLS Encrypted Client Hello", March 2026, Standards Track.** Source draft `draft-ietf-tls-esni-25`. Its DNS bootstrap companion is **RFC 9848** (the `ech` SvcParam); the carrier record is **RFC 9460** (SVCB/HTTPS RR, November 2023).
- **Cloudflare never enabled it by default for all zones.** The announcement was 29 September 2023; it was **globally disabled on 11 October 2023** (Cloudflare community post: *"We have sadly had to disable both of these features globally whilst we address a number of issues with them"*). Re-enablement starting around 16 August 2024 rests on community observation only; no official announcement **was found** (**to be verified**). Today's documented state: *"ECH is enabled by default on Free zones. Other plans can turn it on or off."*
- **Firefox 119** (24 October 2023) turned it on by default; since **Firefox 129** the HTTPS RR can come from the OS resolver, so DoH is no longer strictly required — **except on macOS** (bug 1882856). **Chrome 117** (September 2023) shipped it and imposes no DoH requirement.
- **Measured adoption.** The only credible passive measurement: Trevisan & Mellia, *"Encrypted Client Hello Is Coming: A View from Passive Measurements"*, **Network 5(3):29, 2025**. Finding: **59% of QUIC flows carry an ECH extension — but overwhelmingly GREASE ECH** (mandatory, semantically meaningless padding to prevent ossification). **Real ECH appeared in only 1.96% of connections to Cloudflare**, and Cloudflare was the only ECH-supporting provider identified. The vantage point is a single Italian university campus (~35,000 users, February 2025, 106 million QUIC connections, 95,500 unique domains); the authors state the results *"may not fully generalize."*
- Circulating figures of the "4.2% of the top 10K" kind come from a security vendor document, are internally inconsistent, and **must not be cited as measurement**. Cloudflare Radar publishes no ECH adoption metric.

*What Guard can do.* The correct answer: **OZERK's model never depended on SNI.** The decision point is name resolution, not the TLS handshake. ECH hides SNI; it does not change Guard's decision, it makes that decision harder to **verify independently**. RFC 9849 §10.7 works in Guard's favour: *"ECH requires encrypted DNS to be an effective privacy protection mechanism."* Since the application is confined to Guard's resolver under profiles 1–3, ECH alone cannot hide the name. RFC 9849 §1 says the same: *"The target domain may also be visible through other channels, such as plaintext client DNS queries or visible server IP addresses."*

*Remaining gap.* Under profile 4, with DoH and ECH together, Guard's ability to see the destination name is **zero**; only the IP remains. And an independent auditor can no longer verify Guard's log from the network — trust shifts to the on-device component. That is ECH's real cost for OZERK and must be recorded as a loss.

**4.4. Shared CDNs — profile 2's largest limit.** Thousands of unrelated domains sit behind one IP, distinguished only by TLS SNI or the HTTP `Host` header. A tracker and legitimate content can share an address. Measured magnitudes (every row sourced):

| Finding | Value | Source |
|---|---|---|
| Median domains sharing one IP | Cloudflare **16**; Akamai 3; Google 5; Amazon (AS16509) 5; Squarespace 705; Automattic 110 | Hoang et al., ACM ASIACCS '20 (measured Feb–Apr 2019) |
| IPv4 distribution | **70%** host a single domain; **~95%** host fewer than 15; **81%** of domains are multi-hosted | ibid. |
| Cloudflare's own ratio | **255,315,270** unique names → **~16 million** IPs; **~16×** globally, **~24×** in Europe | Cloudflare blog, 16 December 2022 |
| Density during a real blocking event | **501,305** domains on 2,218 Cloudflare IPs ≈ **226 domains/IP**; single worst case **18,592 domains on one IP** | OONI, LALIGA report, 30 June 2026 |
| Scale of overblocking | Blocking 4–20 IPs in a one-hour window affected **over 400,000** unique domains | ibid. |

Cloudflare's own words close the matter: *"The IP address is the only one of the blocking options that has no attachment to the domain name — the website domain name is not required for routing and delivery of data packets; in fact it is fully ignored."* And: *"Cloudflare has several IP address ranges which are shared by all proxied hostnames."* At Fastly, shared TLS configurations *"use shared IP address space"* and dedicated IPs are a **paid product**; at Cloudflare, dedicated/static IPs are Enterprise-tier and even static IPs note *"multiple zones can share the same static IPs."*

*What Guard can do.* **Nothing at the IP layer** — this is the limit the architecture must accept. It **can say so**: when granting, Guard knows from its own resolver history how many other names that IP is associated with, and can tell the user *"this address is shared."* That is not a solution but an **honesty** measure. And it **can solve it for classes C and D**: per [RFC-0003](0003-paket-formati.md) §4, for web applications the party making the request is OZERK's own web runtime, which can compare at the **origin** level — control **above** encryption, needing no fake certificate. So the shared-CDN problem **does not exist in classes C and D; it exists in class B.** This is the second and more concrete argument strengthening RFC-0003's case for encouraging web applications.

*Remaining gap.* In class B applications, a permitted name sitting on a shared CDN opens the door to everything on that IP. This is profile 2's **structural** limit and must be stated with the copy in §9.

*Ethical and legal note.* The collateral damage of IP-based blocking has also crossed a legal threshold: the ECtHR, in *Vladimir Kharitonov v. Russia* (10795/14, 23 June 2020), held that blocking a site merely because it shared an IP with a targeted site *"amounts to arbitrary interference"* and violated Article 10. OZERK's model runs toward **permitting rather than blocking**, so this does not apply directly; but it is the strongest available record that IP is a poor proxy for name.

**4.5. QUIC / HTTP-3.** Transport is UDP/443; there is no TCP connection semantics, conntrack's "new connection" notion is weaker for UDP, connection migration lets a flow survive an IP change, and 0-RTT sends data in the first flight. *What Guard can do:* the resolver-anchored IP set covers QUIC too, because the decision point sits above the transport. On the Landlock side, UDP rights only arrive with ABI 10, so defence-in-depth UDP limits need newer kernels. nftables and eBPF still see the 5-tuple. *Remaining gap:* applying a policy change to live flows is harder than with TCP; conntrack flushing is mandatory (§2.6). 0-RTT means data may have left before a "block" decision is made — which is why the permission queue (§5) must operate **default-deny**.

**4.6. Proxy chaining.** The app connects to a permitted address that offers a general-purpose proxy/relay, and the allowlist becomes entirely meaningless. This is the **cheapest and most effective** evasion against profile 2. *What Guard can do:* technically nothing. An anomaly in traffic volume may be observable (continuous megabytes to a "help documents" domain) but that is an intuition, not evidence. *Remaining gap:* wide open. **The sanction is not technical but repository policy** — [RFC-0003](0003-paket-formati.md) §6's third binding rule applies: where declaration and observation conflict, the outcome is labelling the application and, if necessary, removing it from the repository.

**4.7. Exfiltration over DNS.** Data is encoded in the query name (QNAME) and sent to the attacker's authoritative server. Any system that permits DNS leaves this channel open. *Capacity — measured.* The theoretical ceiling is RFC 1035 §2.3.4: labels ≤ 63 octets, names ≤ 255 octets, UDP messages ≤ 512 octets. After encoding and the base-domain share, usable payload per query is under 255 bytes; **no single universal "N bytes per query" figure can be given.** The real measurement is in iodine's own README: on a laptop → WiFi AP → home server → DSL → datacenter path, **56.7 kbit/s up, 367.0 kbit/s down**; on a wired LAN, **677.2 kbit/s up, 2464.1 kbit/s down**. This is not "a slow channel" but **a useful one**.

*What Guard can do.* Guard **is the resolver**, which places it outside the blind spot NIST identifies for passive tools. NIST SP 800-81 Rev. 3 (19 March 2026) §4.2.4: *"Organizations should establish controls to detect and block unauthorized applications from tunneling data within DNS packets. Signature-based systems can detect well-known DNS tunneling tools, but customized DNS data exfiltration tools should also be considered."* Its suggested signals: abnormal query volume, changing query patterns, *"Queries for seemingly odd QNAMES (detected by taking entropy measurements of QNAMEs)"*, threat-intelligence matches. The same document confirms Guard's position by noting encrypted DNS blinds passive tools *"unless the tool is configured to act as a proxy or forwarder."* Concrete controls Guard will apply: per-application query rate limits, a QNAME entropy threshold, and the fact that queries to authoritative servers outside the permitted domains are already refused under profiles 2–3.

*Remaining gap.* A determined adversary can slow down and stay under the thresholds. Under profile 2, queries to **subdomains of a permitted domain** are legitimate, and a tunnel can be built there. **Guard cannot close this vector; it can only make it expensive.**

**4.8. In-app WebView.** The app opens a web view, and requests made by page content are, from the OS's point of view, **the application's** requests. The user sees "the Notes app connected to `ads.example.net`" and blames the app, though the request came from a page it displayed. The inverse also holds: an app can hide its own telemetry inside a WebView. *What Guard can do:* two layers must be separated. Apple's App Privacy Report does exactly this and is a good precedent: *"App Network Activity shows domains that have been contacted either directly or from content within an app"* and *"Website Network Activity shows domains that have been contacted by websites you've visited within apps"* are separate sections. **OZERK makes the same split:** the Privacy Center shows "the application's own connections" separately from "connections made by pages opened inside the application". The technical basis exists only in the OZERK web runtime ([RFC-0004](0004-tarayici-motoru.md) layer (a)), which knows which origin made the request. In a class B application bundling its own WebView, this split **cannot be made**. *Remaining gap:* in class B applications a WebView collapses the attribution layer. This adds a third argument to RFC-0003's case for encouraging class C. Partial remedy: requiring WebView use to be declared in `ozerk.toml` (§6.3).

**Vector summary**

| Vector | Profile 1 | Profiles 2–3 | Profile 4 | Guard's best answer |
|---|---|---|---|---|
| In-app DoH/DoT | closed | **closed** (anchored set) | open; blinds observation | RFC 9462 DDR; canary (weak) |
| Hardcoded IP literal | closed | **closed** (anchored set) | open (observed: nameless IP) | default-deny architecture |
| ECH | irrelevant | decision unaffected; **verification harder** | hides the name entirely | keep the decision point at DNS |
| Shared CDN | irrelevant | **open — structural limit** | irrelevant | origin control in C/D; honest warning in B |
| QUIC / HTTP-3 | closed | closed (policy above the flow) | open | conntrack flush; default-deny |
| Proxy chaining | closed | **open** | open | repository policy (§13) |
| DNS tunnel | closed | partly open (subdomains) | open | rate limit + entropy (NIST 800-81r3) |
| WebView | closed | attribution collapses (class B) | attribution collapses | origin split in C/D; declaration in B |

#### 5. Permission fatigue — making profile 3 usable

**The problem.** Profile 3 is unusable in its raw form. An ordinary application connects to dozens of domains in a single launch: a CDN, a font provider, a crash-report endpoint, an A/B testing service, a map tile server. A modal prompt for each pushes the user into "allow everything" within three minutes, and profile 3 effectively becomes profile 4.

The objection is not theoretical; it was raised upstream by a GNOME designer in the network permission portal discussion (`xdg-desktop-portal` #1166):

> *"from a UX perspective I have some fairly major concerns … network access requests are not something that people are used to on other platforms … Network access is also a technical implementation detail … legitimate reasons for using the network will not be apparent to users, and could be difficult to explain. Access to files or a camera is something that people readily understand. Network access is rather different."*

The objection is correct and this RFC must answer it without evading. The answer: **the user is not asked about a "domain".** What is asked is something the user can understand, with technical detail available only on request.

**A five-layer solution.**

*Layer 1 — pre-approval at install time from the manifest declaration (the most important one).* [RFC-0003](0003-paket-formati.md) §4 already requires a `purpose` field on every `[[network.allowed]]` entry. The consequence: **for a well-declared application, profile 3's list is shown once at install and is empty at runtime.** The question is asked not for a "new domain" but for **a destination outside the declaration**. This single decision reduces the prompt count to the size of the application's *honesty gap*. An honest application produces no prompts at all. It is also the right developer incentive: incomplete declaration means an application that annoys the user.

*Layer 2 — eTLD+1 (publisher) grouping.* Destinations are collapsed to the registration boundary using the Public Suffix List. `a.cdn.example.com`, `b.cdn.example.com`, `img.example.com` become one row: `example.com`. PSL facts (verified): license **MPL 2.0** (stated in the list's own header), distributed as a single `.dat` file with `VERSION:` and `COMMIT:` stamps in the header, updated *"a few times per week"*, with a recommended download frequency of **no more than once per day**. The project's own warning is binding: *"please do not bake static copies of the PSL into your software without update mechanisms that are frequently checking for updates and incorporating them"*, and on using it for validity checking, *"This is dangerous."* Implementation: `libpsl` (MIT) is designed to update its list data separately through packaging; OZERK uses it and **does not embed the list in a binary**.

> **The PSL's own site contains no explicit "do not use as a security boundary" sentence**; the published warnings concern staleness and domain-validity misuse. This document attributes no such disclaimer to the PSL.

*Where the PSL is not enough — stated plainly.* eTLD+1 is a **registration** boundary, not an **ownership** boundary. One owner uses many eTLD+1s (`doubleclick.net`, `google-analytics.com`, `googlesyndication.com` appear as three separate rows), and one eTLD+1 hosts thousands of unrelated parties (`cloudfront.net`, `github.io`, `s3.amazonaws.com` — all in the PSL's PRIVATE section). Grouping reduces noise but does not answer "who".

*Layer 3 — entity mapping and tracker lists: a licensing obstacle.* Answering "who" needs an ownership dataset. Candidates were checked, and the result bears directly on the project's license model ([RFC-0001](0001-karar-kaydi.md) D1: system components GPL-3.0-or-later, documents CC BY-SA 4.0):

| List | Verified license | Maintenance | Usable in OZERK? |
|---|---|---|---|
| **EasyPrivacy** | **Dual: GPLv3-or-later AND CC BY-SA 3.0-or-later** (easylist.to/pages/licence.html) | Very active; the list header updates several times a day | ✅ **Yes — the only clean choice.** The dual license maps exactly onto the project's two halves |
| **oisd** | **GPL-3.0** (oisd.nl/faq) | *"At least once every 24 hours"* | ⚠️ Yes for the component; **no for CC BY-SA documents** |
| **Steven Black hosts** | **MIT** wrapper over a **mixed-license** set of upstream lists | Active | ⚠️ Audit the upstream mix before redistribution |
| **DuckDuckGo Tracker Radar** | **Data: CC BY-NC-SA 4.0** (code Apache-2.0). README: *"If you'd like to license the list for commercial use, please reach out."* | Active, roughly monthly releases | ❌ **No.** The NC clause is incompatible with GPL-3.0 (which forbids field-of-use restrictions) and with CC BY-SA |
| **Disconnect** | **CC BY-NC-SA 4.0** — **not** GPL-3.0 (the repository's LICENSE file) | Active | ❌ **No.** Same NC obstacle |

> **This is the most concrete policy finding in this RFC, and it corrects a widespread misconception.** The Disconnect list is assumed to be GPL-3.0; **it is not.** Mozilla can distribute it because of a commercial arrangement between Mozilla and Disconnect, and that arrangement does not extend to third parties. (Mozilla's own wiki documents the upstream as `disconnectme/disconnect-tracking-protection` → `services.json`, and the snapshot it ships as `mozilla-services/shavar-prod-lists`.)

**Decision:** OZERK bases tracker classification on **EasyPrivacy**. NC-licensed lists are **not distributed** with OZERK. Users may add their own list sources — that is a requirement of user sovereignty — but such lists are not part of the default distribution. Entity mapping may require OZERK to maintain its own openly licensed, community-contributed mapping table; the scope and cost of that are unmeasured (**Open Question 4**).

*Layer 4 — a learning mode on first run.* On an application's first run (proposal: the first launch or the first 10 minutes; the duration **must be measured**, E4) Guard asks nothing: it observes, groups, and finally shows **one summary**:

> *On its first run, Notes connected to 3 publishers: example.com (sync — declared), fonts.example.net (fonts — **not declared**), metrics.example.io (**known tracking service, not declared**). What would you like to do?*

This turns N modal prompts into 1 decision and gives the user the context needed to make it.

*Layer 5 — a ban on interruption, plus a queue.* Binding interface rules: (1) **no modal prompt during application startup** — pending destinations are queued and the default is **deny** (the 0-RTT rationale of §4.5); (2) the queue is presented **on one summary screen** at a moment the user chooses, with a silent counter in the notification area; (3) a decision for a publisher covers all of its subdomains; (4) "don't ask again for this app" **means switching to profile 4** and is labelled as such — there is no silent upgrade ([RFC-0003](0003-paket-formati.md) §6, rule 2); (5) Guard never prompts at a cadence that trains the user to tap "allow" — **the criterion is E4, and a design that exceeds the threshold is not shipped.**

*The inverse lesson from OpenSnitch.* OpenSnitch is the most developed implementation of the per-connection modal prompt model and the closest Linux precedent. But that model is for a desktop expert, not for a phone. **OZERK does not adopt it as the primary interface.** What is taken from OpenSnitch is mechanism knowledge and honesty, not the interaction model.

#### 6. Relationship to the manifest

**6.1. How Guard reads and enforces `ozerk.toml`.** [RFC-0003](0003-paket-formati.md) §2 defines three copies. The one that matters for Guard is the copy readable **without launching or unpacking the app**: the `[X-OZERK*]` groups in the Flatpak `metadata` file.

```
1. Guard reads from the installed package's metadata:
     [X-OZERK] network-mode, manifest-digest
     [X-OZERK Network] allowed=...
2. It computes the canonical digest of /app/share/ozerk/manifest.toml and
   compares it with manifest-digest.
     -> On mismatch the application IS NOT RUN (RFC-0003 §2).
3. It builds a policy object from network-mode.
4. At launch:
     - bwrap --unshare-net
     - pasta (--dns-forward to Guard's resolver)
     - unbound view: only the names in the allowed list
     - nftables set: empty; only resolved addresses are added
     - Landlock: port restrictions (defence in depth)
5. Throughout the run, every decision is written to the two-tier log (§7).
```

**Warning — [RFC-0003](0003-paket-formati.md) Open Question 5 is a blocker here.** It must be measured whether `[X-OZERK*]` groups survive `flatpak build-commit-from`, `build-bundle` and mirroring operations **intact**. If they do not, Guard's pre-launch read step does not work and the only source becomes `/app/share/ozerk/manifest.toml`, which requires unpacking and slows the flow. **This is a precondition for Guard v1** (added to E6).

**6.2. How declaration/behaviour divergence (§13) is detected in practice.** Manifesto §13: *"If there is a difference between the declaration and the observed behavior, the user and the repository maintainers shall be warned."* Its practical meaning varies by profile, and without this distinction §13 is an empty sentence:

| Profile | How divergence appears | Strength of detection |
|---|---|---|
| 1 (`none`) | There is not even an attempt; refused at syscall level | The notion of divergence does not apply |
| 2 (`allowlist`) | An undeclared name is submitted for resolution → Guard refuses and **the attempt is logged** | **Strongest.** Intent is caught before it happens |
| 3 (`ask`) | Same, plus the user is asked | Strong |
| 4 (`full`) | There is no declaration; **divergence is undefined** | **None.** §13 does not operate here |
| 5 (`raw`) | Class A; a disclosure, not a restriction | None |

> **The honest conclusion:** manifesto §13's "declaration versus observation" mechanism **has teeth only under profiles 2 and 3.** Under profile 4 there is no declared boundary, so divergence is undefined. This is the third reason to encourage profile 2, and it should be reflected in store ranking.

Feedback to the repository does not, and **must not**, require user data to leave the device (§7.3). The repository produces the same observation in its own automated analysis environment by running the application in isolation; a user may voluntarily report individual events, but this is **never automatic**.

**6.3. Proposed schema additions.** This RFC proposes three fields be added to [RFC-0003](0003-paket-formati.md) §9's `[network]` section. They do not contradict RFC-0003; they complete it.

```toml
[network]
mode = "allowlist"

# NEW: does the application carry its own DNS resolver?
# "system" (default) | "embedded"
# An application declaring "embedded" still falls back to Guard's
# resolver under profiles 1-3; the declaration is shown to the user.
resolver = "system"

# NEW: does the application display web content in-process? (§4.8)
# false | "own-webview" | "ozerk-runtime"
# If "own-webview" is declared, the user IS TOLD that attribution
# cannot be split in the network log.
embeds_web_content = false

# NEW: authoritative DNS zones the application will query, if any.
# If left empty, queries to subdomains of permitted names are subject
# to the rate limit and entropy threshold (§4.7).
dns_zones = []
```

**6.4. Class D (hosted web applications) — the question RFC-0003 left open.** [RFC-0003](0003-paket-formati.md) §5/D requires class D's `network.mode` to be at least `allowlist`, with `web.origin` and any declared auxiliary origins in the list. But class D by definition wants broad access: the remote server may load whatever subresource it likes.

This RFC's answer:

1. **In class D the enforcement point is not the network layer but the web runtime.** [RFC-0003](0003-paket-formati.md) §4's finding is decisive: the party making the request is OZERK's own runtime, and the origin comparison happens **above** encryption. It needs no fake certificate and does not violate the §9.2 ban. So the shared-CDN problem (§4.4) **does not exist** in class D — the runtime looks at origins, not IPs.
2. **The price: the allowlist is a moving target.** RFC-0003 §5/D already records that *"a hosted application's behavior can change without the package version changing at all."* For the network declaration this means: an app connecting to three origins today may connect to ten tomorrow with no version change.
3. **Proposal: make the origin set versioned.** The class D manifest carries a `web.csp` baseline (RFC-0003 §5/C–D). This RFC proposes that the `connect-src` / `img-src` / `script-src` origin set be **declared in the manifest and enforced by the runtime**. If the remote server steps outside the set, the page does not work and the user is told *"this application tried to reach a server it did not declare."* Expansion then requires a **package update**, turning a moving target into a versioned one that enters the permission-diff flow of §10.3.
4. **The honest limit.** This makes class D **more** auditable than class B, but it does not remove class D's fundamental uncertainty: the running code is still remote, and the server can do as it pleases within the permitted origins. For class D the network model is a **scope** assurance, not a **behaviour** assurance.
5. **This RFC does not close RFC-0003 Open Question 2** (may class D applications appear in OZERK Free). Its only contribution is this: from the network model's standpoint class D **is enforceable**, so the argument "exclude it because it cannot be enforced" is invalid. The decision must be made on the source-buildability axis, which is outside this RFC.

#### 7. The Privacy Center's data source

Manifesto §9.3 promises information such as "connections blocked in the last 24 hours", "the applications sending the most data", "connections made to known tracking services". This section defines where that data lives and **why it is the most dangerous data on the device**.

**7.1. The critical finding: the record itself is sensitive data.** Guard's log is the user's **entire network history**: which application was used when, which services were contacted, at what hour the user woke, with whom they spoke on which platform. Manifesto §6.3 commits that the system will not "send usage history to a central server", will not "create a user profile", and will not "keep location history".

> **If designed wrongly, Guard's log produces exactly the profile OZERK rejects.** A record kept for privacy turning into privacy's greatest threat is this design's primary risk.

**7.2. Two-tier storage.**

| Tier | Content | Retention | Size behaviour |
|---|---|---|---|
| **Detail ring** | Timestamp, application, destination (full name), decision (allow/deny), direction, bytes | **24 hours**, fixed-cap ring | Hard ceiling; oldest is dropped on overflow |
| **Aggregate tier** | Application × eTLD+1 × day: connection count, blocked count, bytes sent/received | **7 days** (default) | Linear in days and publishers |

Manifesto §9.3 asks for "the last 24 hours"; that is the **minimum**. The default is 7 days, and the user may choose **off / 24 hours / 7 days**. Precedent: Android's Privacy Dashboard retains 24 hours on Android 12 and 7 days on Android 13+; iOS's App Privacy Report retains **7 days** and splits network activity into three sections. 7 days is where the industry has converged.

**Size.** This RFC gives **no MB figure**. Log size depends on the number of applications, usage intensity, and QUIC/HTTP-3 connection patterns; a number given without measurement would be invented. Measurement is **E5**. The design rule, however, is independent of measurement: **the detail ring has a fixed byte ceiling enforced by the writer**, not by a cleanup job that runs later. A cleanup job can fail; a ring cannot.

**7.3. Binding design rules.** These are not suggestions but **acceptance criteria**. If one is violated, the Privacy Center does not ship.

1. **This record NEVER leaves the device.** No sync, not included in default backup, never to the cloud, never in a crash report, never in telemetry, never automatically sent to the repository. This is the direct application of red lines 3 and 4, and there is no exception.
2. **It lives in the user's encrypted area**, under `~/.local/state/ozerk/guard/`, in the user's encrypted home; it is not readable before first unlock.
3. **It is not written to systemd-journald.** The journal can be forwarded (`ForwardToSyslog`, `systemd-journal-remote`), is root-readable, and has its own retention policy. Guard's log does **not** go into the journal.
4. **No application can read it.** There **is** no "read network history" permission and none will be defined. Only the Privacy Center (class A) reads it. An application cannot even read its own record.
5. **The user can delete it; deletion is complete and immediate.** One button, no friction beyond confirmation. Deletion may not be blocked "for security reasons" — that would violate red line 15. The deletion path is an **acceptance test**.
6. **Export only by an explicit, single user action.** Right 9 of the user rights declaration requires it. Precedent: Apple's "Save App Activity" flow exports the record as JSON. OZERK does the same; but export is **never automatic**, and the exported content is shown to the user before it leaves.
7. **Full names are not kept in the long tier.** The aggregate tier keeps only eTLD+1. Full QNAMEs live only in the 24-hour ring. The long-term record is thus a publisher statistic, not a browsing history.
8. **The record format is documented.** Being able to read one's own data with one's own tool is a requirement of §6.11 (data portability).
9. **On by default, but disableable.** Disabling it does **not** disable Guard's **enforcement**; it disables only the record. The interface states this clearly: enforcement is a security feature, the record is a transparency feature.

**7.4. The rule required for this not to contradict manifesto §6.3.** §6.3 commits that the system will not keep a "usage history". Guard's log is technically a usage history. The distinction that resolves the contradiction, and which must be documented:

> What §6.3 forbids is a history that is **outside the user's control and leaves the device**. Guard's log is under the user's own control, does not leave the device, can be deleted by the user, and is kept for a limited time. This is not a violation of §6.3 but a requirement of rights 6 and 7 of chapter 7 ("the right to see which servers an application communicates with", "the right to review camera, microphone and location usage history").

The distinction is subtle and open to abuse. That is why §7.3's nine rules are binding: without them this paragraph becomes an excuse.

#### 8. What can be learned from existing solutions

The point is not imitation but **inheriting the limits other projects admit in their own documentation.** Every line is sourced from the project's own text.

| Solution | Mechanism | Granularity | The project's own admission |
|---|---|---|---|
| **OpenSnitch** (GPL-3.0, Linux) | NFQUEUE + process mapping (eBPF / audit / procfs) | Process, UID, IP/net, port, domain (regex and lists) | *"when we reach to this point, the process may have already exited, or the socket being closed. **It's not accurate**"* |
| **Little Snitch** (proprietary, macOS) | `NEFilterDataProvider` since v5 (no kext) | Process (by code-signing identity), domain lists, port, protocol, direction | *"Incoming connections cannot be matched by name or domain because the remote name is never known reliably."* |
| **Little Snitch for Linux** (eBPF GPL-2.0, daemon proprietary) | eBPF, kernel 6.12+ with BTF | Process, domain | *"built for privacy, not security, and that distinction matters"* |
| **Android INTERNET permission** | `protectionLevel="normal"`; formerly the `AID_INET` GID, now the eBPF traffic controller | Binary, per UID | Auto-granted at install; **the user cannot revoke it** |
| **GrapheneOS Network permission** | A toggle above INTERNET closing direct **and indirect** access | Binary, per app (UID) and per profile | *"a packet-based firewall would only block direct access so our approach is much more complete"* |
| **RethinkDNS** (Apache-2.0, Android) | `VpnService` TUN + Go userspace stack (firestack) | App, domain/IP lists, category, screen/network state | *"Rethink DNS is ways off being a bullet-proof content blocker"* |
| **NetGuard** (GPL-3.0, Android) | `VpnService` sinkhole, no root | UID + address/hostname | FAQ 48 (below); FAQ 64: DoH/DoT *"not possible … which is the whole point"* |
| **Lockdown** (GPL-3.0 client, iOS) | `NEPacketTunnelProvider` + dnscrypt-proxy + local HTTP proxy | **Domain only, device-wide** — not per app | Single VPN slot: *"Lockdown is incompatible with many third-party VPNs"* |

**OpenSnitch — a mechanism lesson and an interaction warning.** OpenSnitch builds attribution **by inference**: NFQUEUE packet → socket inode → `/proc/*/fd/` scan → PID. Its own wiki enumerates when this fails: the process opens connections too fast, system load is high, netlink does not return the connection, the inode is absent from `/proc/<PID>/fd/`, "the PID is a TID in reality", the process is in a container. For UDP it adds: *"In many occasions, when you parse `/proc/net/udp` the connection is already gone."* For name mapping it uses three paths: parsing plaintext UDP/53 responses, libc uprobes on `getaddrinfo`/`gethostbyname`, and systemd-resolved varlink monitoring. Its eBPF path requires kernel ≥ 5.5 and does not work on some kernels (xanmod, liquorix). For blocklists it also warns: *"This feature may not work if your system uses `systemd-resolved`."*

> **The lesson OZERK inherits:** do not build attribution by inference. Guard **launches the application itself**; the cgroup and network namespace precede the process's existence. This eliminates OpenSnitch's entire list of races and is OZERK's only genuine architectural advantage in this area.
>
> **The mistake to avoid:** making the per-connection modal prompt model the primary interface.

**Little Snitch (macOS) — the platform-exemption lesson.** macOS 11.0 shipped a `ContentFilterExclusionList` exempting roughly 50 Apple applications (iCloud, Maps, App Store, `softwareupdate`) from third-party network filters; the list was removed in macOS 11.2 beta 2.

> **OZERK rule:** no system application is exempt from Guard's **record**. Class A components live outside the sandbox ([RFC-0003](0003-paket-formati.md) §5/A) and that is a **disclosure**, not an exemption. Every system component, Guard's own traffic included, appears in the Privacy Center. A platform exempting its own applications from its own filter destroys the assurance entirely.

Little Snitch's DNS encryption documentation also states a limit OZERK must accept: *"Your computer may still leak server name information, e.g. in the Server Name Indication extension to TLS."* (ECH closes that — and then §4.3's verification problem arises.)

**Little Snitch for Linux — the most honest precedent.** An eBPF-based commercial product requiring kernel 6.12+ with BTF; its eBPF program and web UI are GPL-2.0 and its daemon is proprietary. Four sentences on its own page independently corroborate §1 of this RFC: *"built for privacy, not security"*; *"Under heavy traffic, cache tables can overflow, which makes it impossible to reliably tie every network packet to a process or a DNS name"*; *"reconstructing which hostname was originally looked up for a given IP address requires heuristics rather than certainty"*; *"For hardening a system against a determined adversary, it's not the right tool."*

> **Lesson:** a team doing this commercially bounds its claim to "a privacy tool". If OZERK is going to claim more, it **must show its reasoning** — and the only reasoning it can show is that it launches the application itself and owns the sandbox.

**Android's INTERNET permission — a negative lesson.** The permission is `protectionLevel="normal"`: auto-granted at install, never shown to the user, and not revocable on stock Android. Enforcement moved from the vendor kernel patch `CONFIG_ANDROID_PARANOID_NETWORK` / `AID_INET` (3003) to AOSP's eBPF traffic controller (the exact version threshold **to be verified**). NetGuard FAQ 7 sums up the result: *"Internet permission can be granted with each application update without user consent."* Data Saver is not a security boundary: it applies only on metered networks and only in the background.

> **Lesson:** a permission auto-granted at install is not a permission. In OZERK the network profile is **shown before installation and can be narrowed by the user**; widening it halts the update (§10.3).

**GrapheneOS — the closest relative in model.** The network permission is built on top of INTERNET, which GrapheneOS presents as an advantage: *"builds upon the standard non-resettable INTERNET permission, so it's already fully adopted by the app ecosystem."* It closes direct access at the socket level and indirect access via OS components enforcing INTERNET; it covers localhost too. Its limits are equally clear: binary, per app, no domains, no IPs, no logging; and indirect blocking depends on components being *"marked appropriately"*.

> **This is OZERK's closest relative** — both own the operating system and implement the permission at the socket layer rather than as a packet filter. **OZERK adopts three rules directly:** (a) indirect access closes too (§3); (b) the failure mode is "network down", for battery (§3); (c) build on the existing ecosystem vocabulary rather than inventing a new one — in OZERK that means building on Flatpak's `--share=network` ([RFC-0003](0003-paket-formati.md) §1).
>
> **What OZERK adds:** the domain layer and the log, which GrapheneOS does not have. But this addition does **not weaken** the binary permission; it sits beside it. Profile 1 is exactly as hard as GrapheneOS's network permission.

**RethinkDNS — a scoping lesson.** On Android 10+ it obtains the connection owner from `ConnectivityService`; below that it reads `/proc/net/*` *"like NetGuard or OpenSnitch do"*. Its README narrows its own scope honestly: *"not a feature-rich traditional firewall: It is more in-line with Little Snitch than IP tables"*, and *"Deep Packet Inspection remains a credible threat that can't be mitigated with just encrypted DNS."* DNS tracking on Android 11 and below is *"a rough heuristic"*.

> **Lesson:** narrowing your scope on your own product page does not reduce trust — it increases it. All of §9 is an application of this lesson.

**NetGuard — the single most valuable sentence.** FAQ 48: *"NetGuard blocks traffic based on the IP addresses an application is trying to connect to. If more than one domain name is on the same IP, they cannot be distinguished. If you set different rules for 2 domains which resolve to the same IP, both will be blocked."* Also FAQ 63: *"NetGuard allows all DNS traffic"*; FAQ 19: applications can reach the internet through other system components; FAQ 31: Android groups applications by UID and they cannot be told apart; FAQ 1: because of the VpnService constraint *"it will not offer protection during early boot-up."*

> **Lesson:** OZERK has no VpnService constraint — it owns the sandbox. But it has an **equivalent** constraint that must not be hidden: **Guard's enforcement begins when Guard launches the application.** No process Guard did not launch is inside this model (§1.3, item 5).
>
> **The mistake to avoid:** presenting IP-level blocking as a domain-level guarantee. NetGuard does not do this; many commercial products do. OZERK will not (§9).

**Lockdown — the closed-platform lesson.** It runs dnscrypt-proxy and an HTTP proxy inside a local `NEPacketTunnelProvider`; blocking is **domain-level and device-wide**, not per application. Third parties writing per-application filters on iOS are limited to supervised/MDM devices (**to be verified against Apple documentation**).

> **Lesson:** on a closed platform a third party can only work at the DNS level and device-wide. **This is exactly why OZERK exists:** owning the platform is the only thing that makes per-application control possible. It is the technical precondition for manifesto §5's promise that "an application must not be able to send data to other companies without the user's knowledge".

**What exists on the Linux desktop today: nothing.** There is no per-application network control in Flatpak or xdg-desktop-portal, and every attempt has stalled at the same point:

| Record | Topic | Status |
|---|---|---|
| `flatpak/flatpak#1202` | "Network restriction fine tuning?" (ports + destinations) | **Open** (since 2017); the canonical duplicate target |
| `flatpak/flatpak#3054` | Network permission granularity (LAN / external) | Closed as a duplicate of #1202 |
| `flatpak/flatpak#4996` | Making network access a dynamic permission | Closed (2025-08-11), duplicate |
| `flatpak/xdg-desktop-portal#1166` | "Network permission portal" | **Open discussion; no chosen answer, no implementation** |

Maintainer statements are quoted in §2.1. In summary: the architectural blocker is that an unprivileged Flatpak cannot unshare the network namespace, and the proposed solution is a slirp4netns/pasta bridge — that is, **precisely the architecture this RFC proposes.**

> **Under D3 (upstream-first) this is an opportunity, not grounds for a fork.** OZERK should contribute to #1166 with a working implementation. That is Guard v2's main upstream goal: OZERK's Guard could be the reference implementation of the xdg-desktop-portal network portal proposal. It is D3's most concrete field of application and the strongest component for a grant application.

#### 9. What the user is told

Manifesto §9.3: *"OZERK shall state only what it can observe and verify."* This section translates that sentence into interface rules and concrete copy.

**Four labels.** [RFC-0003](0003-paket-formati.md) §6 defines three classes (Enforced / Verified / Declaration) and requires them to be **visually separated** in the interface. The network model requires a fourth state:

| Label | Meaning | Where in the network model |
|---|---|---|
| **Enforced** | The system technically prevents the contrary | Profile 1; after Guard v1, profiles 2 and 3 (with scope note) |
| **Verified** | Independently tested before publication | Build verification; no direct network counterpart |
| **Observed** | Guard saw this; it is not a restriction | Profile 4's destination list; all traffic statistics |
| **Declaration** | The developer said so; the system can neither prevent nor verify it | Purpose strings, nature of telemetry, advertising declaration |

**Binding rule:** "Observed" and "Enforced" may not be shown in the same colour, with the same icon, at the same weight. If profile 4's destination list looks like a restriction list, the interface has lied.

**Concrete copy proposals.** The wording below is draft, but the **meaning** is binding. Abridging it, decorating it, or making it "more reassuring" is forbidden.

*Profile 1:* **No network access.** This application cannot connect to the internet. The restriction is applied at kernel level; the application cannot bypass it.

*Profile 2:* **Allowed addresses only.** This application can connect only to the servers below. *Limit:* Guard permits the IP addresses these names resolve to. If other sites share the same IP address, the application can reach them too. **Guard cannot see the contents of the connection.**

*Profile 3 (summary decision screen):* **Notes wants to connect to 2 publishers it did not declare.** · `fonts.example.net` — not declared · `metrics.example.io` — not declared · **known tracking service**. [Allow for this session] [Always allow] [Deny] [Details]

*Profile 4:* **Network access is not restricted.** This application can connect to any address on the internet. The list below is not a restriction but an **observation record**. If the application uses its own DNS resolver, this list may be incomplete.

*A blocked event:* 13:42 — Notes tried to connect to `tracking.example.net`. **Blocked.**

*The tracker statement — the letter of manifesto §9.3:* **No connection to a known tracking service was seen.** This does **not** mean the application does not track. Guard recognizes only the addresses it knows, and cannot see the contents of connections.

*Shared-address warning (§4.4):* `cdn.example.com` shares its address with thousands of other sites. Allowing this address may mean allowing the other sites at that address.

*Unresolvable destination (§4.1):* This application uses its own DNS resolver. We **cannot resolve** the names of the addresses it connects to; we see only IP addresses.

**Sentences Guard will NEVER say:** "This application is safe." · "Your data is protected." / "100% protected." · Any single privacy score, letter grade or percentage (manifesto §9.3 forbids this explicitly). · "No data leakage." · "This application does not track you." · "All connections are under control."

**The "What Guard cannot see" page.** A permanent page in the Privacy Center, reachable in one tap from every application screen. Its content is §1.3 and §4 translated into user language, and it states at least:

> **What Guard cannot see**
>
> · **What was sent.** Guard sees the connection, not its contents. OZERK does not install fake security certificates on your device in order to read content.
> · **What lies behind shared addresses.** Many sites today share an IP address; Guard cannot always tell which one was contacted.
> · **The destinations of applications using their own DNS** (in unrestricted applications).
> · **A permitted address being used as a relay.**
> · **What happens to your data after it reaches the server.**
>
> Guard was designed to **make honest applications transparent**. We do not claim it will stop an application that persistently tries to hide. The single exception: an application with no network access genuinely cannot connect.

This page cannot be removed from the interface and cannot be buried in a settings submenu.

#### 10. Phased implementation plan

**Guard v0 — months 4–8, in the emulator, demo gate D2.** The roadmap's definition is binding: *"per-application network on/off and a log of the domains applications connect to … v0 is a prototype and claims no security guarantee."*

Scope: per-application network on/off via `flatpak override --unshare=network <app-id>` (the Flatpak documentation defines `--unshare=NAME` as the flag for explicitly denying a permission granted through runtime metadata or overrides); a single system resolver (unbound) with client-IP query logging; **for at least one application**, a per-application network namespace + pasta + resolver-anchored set — the path on which the D2 demonstration will run; Privacy Center v0 as a raw log viewer, with §7.3's rules applying **already in v0**.

**Profiles genuinely enforced: 1 and 4.** Profile 2 only on the demonstrated application, at prototype quality. Profile 3 absent.

*Honest framing of the D2 demonstration.* The demonstration proves that a chosen application's access to a specific domain was blocked and that the event appears in the log. **What it does not prove:** that the same application could not reach that destination by other means. This sentence must be attached to the published record of the demonstration. The roadmap's "measured claims" principle already requires it.

**Guard v1 — the core of Phase 3.** Per-application network namespace + pasta as the default path for all class B applications; the resolver-anchored allowlist, making **profile 2 class E** (with scope note); §5's five layers, making **profile 3 usable**; the two-tier log (§7) and the full Privacy Center, including the "What Guard cannot see" page (§9); the `[X-OZERK*]` read pipeline (§6.1) with `manifest-digest` verification; EasyPrivacy-based tracker classification (§5); portal and D-Bus policy consistent with the network profile, closing indirect access (§3).

*Preconditions:* E1 (cost acceptable), E3 (the anchored allowlist works on real traffic), E4 (prompt count under threshold), E6 (kernel features present on the target device), and [RFC-0003](0003-paket-formati.md) Open Question 5 closed.

**Guard v2 — maturation and upstream.** An alternative low-cost path for devices where the netns cost is unacceptable: systemd scope drop-ins + `IPAddressAllow=` (§2.3). That path gives profile 2 at IP level but not per-application DNS attribution; **which device uses which path is written into the freedom inventory** (manifesto §6.14). Landlock network rights as defence in depth (port limits; ABI 6 abstract-socket scoping). **Upstream:** contributing a working implementation to `xdg-desktop-portal#1166`, and a design proposal for network permission granularity on the Flatpak side — per D3, ask first, then write. Web runtime origin enforcement for classes C and D (§6.4) and the WebView attribution split (§4.8).

| | v0 (months 4–8) | v1 (Phase 3) | v2 |
|---|---|---|---|
| Profile 1 | ✅ enforced | ✅ enforced + indirect access | ✅ |
| Profile 2 | prototype (one app) | ✅ **class E** (with scope note) | ✅ + origin level in C/D |
| Profile 3 | absent | ✅ **usable via §5** | ✅ |
| Profile 4 | observation | observation + two-tier log | observation |
| Profile 5 | absent | class A exception | class A exception |
| Privacy Center | raw viewer | full (§7, §9) | + WebView split |
| Upstream | — | design discussion opened | reference implementation offered |

#### 11. Decision criteria and experiments

[RFC-0004](0004-tarayici-motoru.md) §9's method is followed: this RFC **must not move to "Accepted"** before the experiments are complete. Every experiment's output is published in the repository, failed results included.

**E1 — the cost of a per-application network namespace (the most critical experiment).** On the candidate reference device (RFC-0006) and in the emulator, the same application is run in three conditions: (a) host networking (baseline), (b) netns + pasta, (c) netns + slirp4netns. Measured: TCP connection setup latency (median and p95), time to first byte, sustained throughput, CPU time, and **battery consumption over 24 hours of mixed use**; plus connection behaviour after suspend/resume. *Rationale:* there is **no published comparison** of pasta against veth/bridge; the project's "4 to 50 times" claim is against slirp-class solutions and does not answer this question, and no credible measurement of the CPU cost of userspace TCP on ARM was found. **This gap will be measured, not invented.**

**E2 — `socket cgroupv2` and Flatpak transient scopes.** A Flatpak application is started and stopped 100 times in succession. Measured: (a) the delay between scope cgroup creation and nftables rule load (the race window), (b) how many connections can be established inside that window, (c) whether a rule against a recreated cgroup really does silently stop matching. *Rationale:* §2.2's inode constraint was read from source but its behavioural consequence is unmeasured. The result determines whether this is a fallback path or one never used at all.

**E3 — the accuracy of the resolver-anchored allowlist on real traffic.** The ten chosen core applications run for a week under profile 2. Measured: (a) the ratio of connections to IPs returned by Guard's resolver versus literal IP attempts, (b) how many permitted IPs are also associated with non-permitted names (**the CDN co-tenancy rate on real traffic**), (c) the TTL tolerance value at which no false denials occur. *Rationale:* §4.4's literature figures are measurements from 2019–2026 and do not describe OZERK's core application set. Profile 2's real strength is determined by this experiment.

**E4 — prompt count (profile 3's shippability test).** The same ten applications run for a week under profile 3 in two conditions: (a) raw "ask on new domain", (b) §5's five layers enabled. Measured: user decisions per application per week. *Threshold:* defined in Ö3. **If exceeded, profile 3 is not shipped** — it is narrowed or deferred, but never presented as "working" in a weakened form.

**E5 — log size, retention and deletion.** Bytes per day are measured on real usage (per application and in total). Also verified: that the ring ceiling is genuinely enforced, that the 24-hour and 7-day windows expire correctly, and that **deletion genuinely leaves no trace on disk**. *Rationale:* §7.2 deliberately gives no size figure; this experiment closes that gap. The deletion test is an **acceptance criterion**, not a performance measurement.

**E6 — kernel feature inventory on target devices.** On the candidate devices ([RFC-0002](0002-taban-dagitim.md) Ö6): `CONFIG_USER_NS`, `CONFIG_NET_NS`, `CONFIG_CGROUP_BPF`, `BPF_SYSCALL`, the `nft_socket` module, the nftables version, the **Landlock ABI version reported by the kernel**, `CONFIG_INET`. Plus §3.5's `CAP_NET_RAW` behaviour inside a user namespace, and [RFC-0003](0003-paket-formati.md) Open Question 5 (whether `[X-OZERK*]` groups survive the toolchain). *Rationale:* these options being disabled in vendor kernels is a real risk ([RFC-0002](0002-taban-dagitim.md) §7). Which path Guard uses may vary by device, and that is a fact for the freedom inventory.

**E7 — DoH and ECH behaviour.** A browser and a DoH-using application are run under profile 2. Measured: (a) whether the application really falls back to Guard's resolver or behaves as if offline, (b) the effect of the `use-application-dns.net` canary, (c) the effect of RFC 9462 DDR indications, (d) how incomplete Guard's log becomes against an ECH-enabled destination. *Rationale:* §4.1's and §4.3's claims are logical inference and have not been tested on a device.

**E8 — the honesty test (a user study).** With a small group (at least 5 participants), after using the Privacy Center: "Can Guard see what this application is doing?", "Can Guard block it?", "Can Guard read the content?" *Threshold:* defined in Ö5. **This experiment is the control on the project's largest reputational risk.** If users believe Guard is stronger than it is, the interface has failed — however good the mechanism.

**Decision thresholds**

| # | Criterion | Threshold |
|---|---|---|
| Ö1 | **Cost** (E1) | The netns + pasta path produces an **acceptable** increase in connection latency and 24-hour battery consumption relative to baseline. The numeric value of the threshold will be set after E1's baseline measurement, by looking at the measurement — **writing a number now would be invention.** It is written on the day the measurement is published and before scoring begins. |
| Ö2 | **Profile 2's real strength** (E3) | Literal IP attempts are refused; CDN co-tenancy has been measured and is correctly explained in the interface with §9's copy |
| Ö3 | **Prompt count** (E4) | With §5 enabled, weekly user decisions per application are at least an order of magnitude below the raw condition **and** at a level not found intrusive in daily life |
| Ö4 | **Kernel readiness** (E6) | All required kernel features are present on the chosen base and candidate device; otherwise the fallback path (v2) is documented |
| Ö5 | **Honesty** (E8) | Participants can correctly state that Guard **cannot see content** and that profile 4 is not a restriction |
| Ö6 | **Log privacy** (E5) | All nine rules of §7.3 are verified by automated test; the deletion test passes |
| Ö7 | **Licensing** (§5) | All distributed list data is compatible with [RFC-0001](0001-karar-kaydi.md) D1; no NC-licensed data ships |

If Ö5 or Ö6 cannot be met, the correct behaviour is not to ship a weakened feature but to **narrow the promise and announce the narrowing** — the same rule as [RFC-0004](0004-tarayici-motoru.md) §9.2.

**Review and exit conditions.** *Every 12 months:* §4's evasion vector inventory is re-measured and published; ECH adoption and CDN density figures age particularly fast, and an unchanged table is a sign that nothing was measured. *Event-triggered:* when a new evasion vector is found, §4 and §9's "What Guard cannot see" page are updated in the same release — the limits told to the user may never lag behind the limits known. *Exit conditions:* (a) if E1 shows the netns path is not viable on phone-class hardware, the architecture is reopened; (b) if a network portal is accepted upstream, OZERK abandons its private path and moves to the portal (D3); (c) if a vector in §4 becomes widespread enough to make profile 2 meaningless, profile 2 is removed from class E and users are told.

### Alternatives

**A1 — Do nothing; defer the decision.** Defensible: there is no platform code yet, and Guard v0 is already defined in the roadmap. Rejected because the mechanism v0 is built on is the most expensive decision to reverse: the choice between a per-application namespace and a cgroup filter determines **how the application is launched**, and the D2 demonstration cannot be made without choosing a path. [RFC-0002](0002-taban-dagitim.md)'s Ö6 scoring also depends on this document.

**A2 — Observation only; no enforcement at all.** This is Little Snitch for Linux's position, and it is honest: *"built for privacy, not security."* Guard would only record. Advantages: no evasion vector refutes a guarantee, because there is no guarantee; and nothing breaks. Rejected because manifesto §9.2 defines five **profiles**, not five report types, and because profile 1 is already enforced today with Flatpak — abandoning enforcement would take back an existing capability. The essence of this alternative is nevertheless adopted: **under profile 4 Guard is exactly this, and is labelled as such.**

**A3 — Binary permission only (the GrapheneOS model).** Network is on or off; no domain layer is built at all. Its advantages are real: an unbreakable assurance, zero permission fatigue, low cost, and most evasion vectors become irrelevant. Rejected because manifesto §5's second bullet ("the user must be able to see not only which sensors but **which servers** an application accesses") and right 6 of chapter 7 require more; a binary permission does not meet that promise. **But the most valuable part of this alternative is adopted:** profile 1 is built to exactly GrapheneOS's hardness and is the encouraged default. The domain layer sits **beside** the binary permission, not in place of it.

**A4 — TLS interception (a fake root certificate).** Content inspection is possible only this way, and it would make the "tracker detection" claim genuinely provable. **It is explicitly forbidden by manifesto §9.2**, and this RFC supports the ban: (a) it is the technical form of red line 15 — a trust anchor the user does not control is placed on the user's device; (b) it enormously enlarges the attack surface, since a flaw in Guard becomes a flaw in all TLS traffic; (c) it breaks every application that pins certificates; (d) it requires breaking the user's security model in order to break the application's privacy. **This option will not be reopened in this RFC.**

**A5 — DNS-level, device-wide blocking only (the Lockdown / hosts-file model).** The cheapest path: one resolver, one blocklist, nothing per application. Rejected because manifesto §9.2 asks for **per-application** profiles; a device-wide list does not answer "which application is talking to whom". It is also easily bypassed by hardcoded IPs and in-app DoH — which is precisely why this RFC's resolver-anchored default-deny architecture exists.

**A6 — Fork Flatpak.** Add network permission granularity directly to Flatpak without waiting for upstream. Rejected because [RFC-0001](0001-karar-kaydi.md) D3 treats forking as a last resort and it is unnecessary here: the pasta-based architecture works **without modifying Flatpak**, around the `bwrap` invocation. The upstream discussion (`xdg-desktop-portal#1166`) is open and the solution maintainers describe is this same architecture; contributing rather than forking suits both D3 and the funding strategy.

**A7 — A mandatory HTTP(S) proxy plus proxy settings in applications.** Application traffic is routed to a local proxy that sees the `CONNECT` target and decides at the name level. Attractive because the name is seen before the IP. Rejected because (a) applications can ignore proxy settings — a rule that cannot be enforced is not a rule; (b) transparent proxying cannot see the destination without breaking TLS, and breaking it is A4; (c) `CONNECT` covers only the HTTP family, not QUIC or other protocols. **It is valid only for classes C and D**, and there it is already done more cleanly through runtime origin control.

**A8 — Intercepting `connect()` with seccomp user notification.** Eliminated in §2.5 with a quotation from the man page: the mechanism **cannot** be used to implement a security policy for syscalls with pointer arguments.

### Open Questions

1. **Is the battery cost of a per-application network namespace acceptable on phone-class hardware?** This is the single largest uncertainty in the RFC. No published measurement exists (§2.1). If E1 does not answer it, Guard v1's architecture changes. Ö1's numeric threshold will also be written only after E1's baseline measurement.
2. **At what point does profile 2 deserve to be called "class E"?** The resolver-anchored allowlist enforces the address, not the name. If E3's CDN co-tenancy measurement exceeds some threshold (e.g. if most permitted addresses are shared), labelling profile 2 "enforced" may not be honest. Who sets that threshold, and on what data?
3. **What should the answer to [RFC-0003](0003-paket-formati.md) Open Question 1 be?** Should packages declaring profiles 2 and 3 be accepted in the repository before Guard exists? This RFC leans "yes" (a declaration has audit value independent of enforcement), but the decision belongs to RFC-0003 and the two documents should be closed together.
4. **Where will entity mapping come from?** The CC BY-NC-SA licensing of Tracker Radar and Disconnect rules them out (§5). EasyPrivacy is sufficient for tracker **detection** but carries no **ownership** mapping. Will OZERK maintain its own openly licensed mapping table, or will this layer simply not exist? The cost is unmeasured.
5. **How are cases where Guard did not launch the application handled?** Developer mode, terminals, `coldbrew`-like tools ([RFC-0002](0002-taban-dagitim.md) §3). These are outside the model (§1.3/5) — how are they shown to the user and represented in the Privacy Center?
6. **Should profile 5's definition be narrowed?** If §3.5's observation is confirmed (a raw socket inside a user namespace sees only its own isolated network), the definition "raw network access — a special high-risk privilege" cannot stand as written in manifesto §9.2. Does this require a manifesto amendment, or is an RFC-level interpretation sufficient?
7. **Whose resolver will Guard's own upstream DNS be?** If Guard performs encrypted DNS on applications' behalf it must choose a resolver. Choosing a default provider means directing all users' queries to a single party — in tension with the spirit of manifesto §6.12 ("the cloud is optional"). Should there be no default at all (only the network-provided resolver), or should the user choose during first-run setup?
8. **Do `[X-OZERK*]` groups survive the Flatpak toolchain?** [RFC-0003](0003-paket-formati.md) Open Question 5 is a **blocker** for Guard v1 (§6.1). v1 cannot be planned before it is measured.
9. **Should the default log retention be 7 days or 24 hours?** Manifesto §9.3 says "the last 24 hours". Seven days is more useful and where the industry sits (Android 13+, iOS), but more data is more risk (§7.1). Is it better to default long and let the user shorten, or default short and let the user extend?
10. **Can Guard's own source code and live ruleset be audited by the user?** Manifesto §6.4 guarantees open source, but whether Guard's **running** ruleset (the nftables set, the resolver view) is shown to the user has not been decided. Shown, it is the only way to verify "observed"; hidden, Guard is a black box.
11. **Policy storage on a read-only base** ([RFC-0002](0002-taban-dagitim.md) §7/3). In a Duranium-like architecture Guard's rulesets must live in `/etc` and `/var`. The precedence between user policy (`~/.config`) and system policy is undefined: should the user be able to grant an application **broader** network access than it declared?

---

## Kaynaklar / Sources

Aşağıdaki kaynaklar 17 Ağustos 2026 tarihinde kontrol edilmiştir. Bir iddianın kaynağı burada yoksa, o iddia belgede "doğrulanmalı" olarak işaretlidir.

*The sources below were checked on 17 August 2026. If a claim has no source here, it is marked "to be verified" in the document.*

> **Yöntem notu / method note.** Bu RFC'deki çekirdek yeteneği iddiaları blog metinlerinden değil, **çekirdek belgelerinden, man sayfalarından ve kaynak ağacından** okunmuştur: `nft_socket.c`'nin `nft_socket_validate()` kancası, nftables `src/datatype.c`'nin `stat()` çağrısı, Landlock ABI tablosu, `seccomp_unotify(2)`'nin CAVEATS bölümü. Ölçüm iddiaları için hakemli yayın veya projenin kendi ölçümü aranmıştır; bulunamadığında **hiçbir sayı verilmemiş**, bir deney tanımlanmıştır. *Kernel capability claims here were read from kernel documentation, man pages and the source tree, not from blog posts; where a measurement could not be sourced, no number is given and an experiment is defined instead.*

**Çekirdek mekanizmaları / Kernel mechanisms**

- Landlock kullanıcı alanı API'si, ABI tablosu ve ağ hakları / userspace API, ABI table and network rights — <https://docs.kernel.org/userspace-api/landlock.html>, <https://man7.org/linux/man-pages/man7/landlock.7.html>
- Landlock ağ desteğinin geldiği sürüm (6.7, ABI 4) / kernel release adding network support — <https://kernelnewbies.org/Linux_6.7>
- Landlock ABI 8 / 9 / 10 (7.0 / 7.1 / 7.2) — <https://www.kernel.org/doc/html/v7.0/userspace-api/landlock.html>, <https://www.kernel.org/doc/html/v7.1/userspace-api/landlock.html>, <https://www.kernel.org/doc/html/v7.2/userspace-api/landlock.html>
- `seccomp_unotify(2)` CAVEATS — güvenlik politikası için kullanılamaz / cannot implement a security policy — <https://www.man7.org/linux/man-pages/man2/seccomp_unotify.2.html>
- nftables `socket cgroupv2` sözdizimi ve seviye anlamı / syntax and level semantics — <https://man.archlinux.org/man/nft.8.en>, <https://manpages.debian.org/unstable/nftables/nft.8.en.html>
- `socket cgroupv2` çekirdek yaması (5.13) / kernel patch — <https://patchwork.ozlabs.org/project/netfilter-devel/patch/20210426171056.345271-3-pablo@netfilter.org/>
- `nft_socket_validate()` kanca kısıtı / hook restriction — <https://sources.debian.org/src/linux/latest/net/netfilter/nft_socket.c/>
- nftables `src/datatype.c` — cgroup yolunun `stat()` ile inode'a çözülmesi / path resolved to an inode via `stat()` — <https://sources.debian.org/src/nftables/latest/src/datatype.c/>
- nftables 0.9.9 sürüm duyurusu (cgroupsv2 desteği) / release announcement — <https://lwn.net/Articles/857369/>; 0.9.4 karşılaştırması / comparison — <https://lwn.net/Articles/816528/>
- eBPF program türleri ve attach türleri / program and attach types — <https://docs.kernel.org/bpf/libbpf/program_types.html>
- `CGROUP_SOCK_ADDR` kancalarının `struct sockaddr`'ı değiştirebilmesi / hooks can modify `struct sockaddr` — <https://lwn.net/Articles/750296/>
- Çekirdek sürümleri / kernel versions — <https://kernelnewbies.org/Linux_4.10>, <https://kernelnewbies.org/Linux_4.13>, <https://kernelnewbies.org/Linux_4.14>, <https://kernelnewbies.org/Linux_4.17>, <https://kernelnewbies.org/Linux_4.18>
- `CONFIG_CGROUP_BPF` bağımlılıkları / dependencies — <https://cateee.net/lkddb/web-lkddb/CGROUP_BPF.html>
- systemd `IPAddressAllow=`, `SocketBindAllow=`, `RestrictNetworkInterfaces=` — <https://man.archlinux.org/man/systemd.resource-control.5.en>
- nftables NAT / `redirect` ve conntrack kısıtı / and the conntrack constraint — <https://wiki.nftables.org/wiki-nftables/index.php/Performing_Network_Address_Translation_(NAT)>
- `route_localnet` — <https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt>

**passt / pasta ve namespace ağ geçitleri / and namespace gateways**

- passt/pasta proje tanımı, mimari ve performans iddiası / project description, architecture and performance claim — <https://passt.top/passt/about/>
- `pasta(1)` — tap cihazı, yerel bypass, `--dns-forward` — <https://passt.top/builds/latest/web/passt.1.html>, <https://manpages.debian.org/unstable/passt/pasta.1.en.html>
- Podman v4.4.0 (pasta seçeneği eklendi / pasta added) — <https://github.com/containers/podman/releases/tag/v4.4.0>
- Podman v5.0.0 (köksüz varsayılan / rootless default) — <https://github.com/containers/podman/releases/tag/v5.0.0>
- Podman ağ modları / networking modes — <https://docs.podman.io/en/stable/markdown/podman-run.1.html>

**Flatpak, bubblewrap ve portallar / and portals**

- Flatpak sandbox izinleri; ağ izninin abstract unix soketlerine erişim vermesi / network access grants abstract Unix socket access — <https://docs.flatpak.org/en/latest/sandbox-permissions.html>
- Flatpak systemd kapsamları ve uygulama başına kaynak denetimi / systemd scopes and per-app resource control — <https://docs.flatpak.org/en/latest/tips-and-tricks.html>
- bubblewrap `--unshare-net` — <https://github.com/containers/bubblewrap>
- Ağ izni granülerliği talepleri / network permission granularity requests — <https://github.com/flatpak/flatpak/issues/1202>, <https://github.com/flatpak/flatpak/issues/3054>, <https://github.com/flatpak/flatpak/issues/4996>
- Ağ izni portalı tartışması (bakımcı ifadeleri, UX itirazı) / network permission portal discussion — <https://github.com/flatpak/xdg-desktop-portal/discussions/1166>

**DNS, DoH, ECH**

- RFC 8484 — DNS Queries over HTTPS — <https://www.rfc-editor.org/rfc/rfc8484.html>
- RFC 9462 — Discovery of Designated Resolvers (DDR) — <https://www.rfc-editor.org/rfc/rfc9462.html>
- RFC 1035 §2.3.4 — boyut sınırları / size limits — <https://www.rfc-editor.org/rfc/rfc1035>
- RFC 9849 — TLS Encrypted Client Hello (Mart / March 2026) — <https://datatracker.ietf.org/doc/rfc9849/>
- RFC 9848 — SVCB ile ECH önyükleme / bootstrapping ECH with SVCB — <https://datatracker.ietf.org/doc/rfc9848/>
- RFC 9460 — SVCB ve HTTPS kayıtları / SVCB and HTTPS RRs — <https://datatracker.ietf.org/doc/rfc9460/>
- `draft-ietf-tls-esni` taslak geçmişi / draft history — <https://datatracker.ietf.org/doc/draft-ietf-tls-esni/>
- Cloudflare ECH duyurusu / announcement (29 Eylül / September 2023) — <https://blog.cloudflare.com/announcing-encrypted-client-hello/>
- **Cloudflare ECH'nin küresel olarak kapatılması / global disable (11 Ekim / October 2023)** — <https://community.cloudflare.com/t/early-hints-and-encrypted-client-hello-ech-are-currently-disabled-globally/567730>
- Cloudflare ECH bugünkü durum / current state (Free bölgeler / zones) — <https://developers.cloudflare.com/ssl/edge-certificates/ech/>
- Firefox 119 ECH — <https://www.firefox.com/en-US/firefox/119.0/releasenotes/>, <https://bugzilla.mozilla.org/show_bug.cgi?id=1856928>, <https://wiki.mozilla.org/Security/Encrypted_Client_Hello>
- Chrome 117 ECH (Intent to Ship) — <https://chromestatus.com/feature/6196703843581952>
- **ECH yaygınlığı ölçümü / adoption measurement:** Trevisan, M. & Mellia, M., "Encrypted Client Hello Is Coming: A View from Passive Measurements", *Network* 5(3):29, 2025 — <https://www.mdpi.com/2673-8732/5/3/29>
- Firefox DoH ABD / US (2020) — <https://blog.mozilla.org/en/firefox/firefox-continues-push-to-bring-dns-over-https-by-default-for-us-users/>; Kanada / Canada (2021) — <https://blog.mozilla.org/en/mozilla/news/firefox-by-default-dns-over-https-rollout-in-canada/>
- Kanarya alan adı / canary domain `use-application-dns.net` — <https://support.mozilla.org/en-US/kb/canary-domain-use-application-dnsnet>, <https://bugzilla.mozilla.org/show_bug.cgi?id=1614751>
- Firefox DoH sezgisel kuralları / heuristics — <https://wiki.mozilla.org/Security/DNS_Over_HTTPS/Heuristics>
- Chrome Secure DNS ve otomatik yükseltme modeli / auto-upgrade model — <https://blog.chromium.org/2020/05/a-safer-and-more-private-browsing-DoH.html>, <https://www.chromium.org/developers/dns-over-https/>
- Çözümleyiciler / resolvers: unbound — <https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html>; knot-resolver görünümleri ve paylaşımlı önbellek uyarısı / views and shared-cache caveat — <https://knot-resolver.readthedocs.io/en/stable/modules-view.html>; dnsmasq — <https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html>; systemd-resolved — <https://man.archlinux.org/man/systemd-resolved.service.8.en>, <https://man.archlinux.org/man/resolved.conf.5.en>, <https://man.archlinux.org/man/resolvectl.1.en>
- DNS tüneli ölçümü / DNS tunnel measurement (iodine README) — <https://github.com/yarrick/iodine>
- NIST SP 800-81 Rev. 3, §4.2.4 (19 Mart / March 2026) — <https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-81r3.pdf>

**CDN ortak-kiracılığı / CDN co-tenancy**

- Hoang, N. P. vd. / et al., "Assessing the Privacy Benefits of Domain Name Encryption", ACM ASIACCS '20 — <https://arxiv.org/pdf/1911.00563>
- Cloudflare, "The consequences of IP blocking" (16 Aralık / December 2022) — <https://blog.cloudflare.com/consequences-of-ip-blocking/>
- Cloudflare paylaşımlı IP aralıkları / shared IP ranges — <https://developers.cloudflare.com/fundamentals/concepts/cloudflare-ip-addresses/>
- Fastly ayrılmış IP adresleri / dedicated IP addresses — <https://docs.fastly.com/products/dedicated-ip-addresses>
- OONI, "Collateral Damage of IP-Based Blocking During LALIGA Football Streaming in Spain" (30 Haziran / June 2026) — <https://ooni.org/post/2026-laliga-collateral/>
- AİHM / ECtHR, *Vladimir Kharitonov v. Russia*, 10795/14 (23 Haziran / June 2020) — <https://hudoc.echr.coe.int/eng?i=001-203177>

**Alan adı gruplaması ve izleyici listeleri / Domain grouping and tracker lists**

- Public Suffix List — liste, uyarılar ve lisans / list, warnings and license — <https://publicsuffix.org/list/>, <https://publicsuffix.org/learn/>, <https://publicsuffix.org/list/public_suffix_list.dat>, <https://github.com/publicsuffix/list>
- `libpsl` — <https://github.com/rockdaboot/libpsl>
- **EasyPrivacy lisansı (GPLv3+ ve CC BY-SA 3.0+ çift lisans) / license (dual)** — <https://easylist.to/pages/licence.html>, <https://easylist.to/easylist/easyprivacy.txt>
- **Disconnect lisansı: CC BY-NC-SA 4.0 (GPL-3.0 DEĞİL) / license: CC BY-NC-SA 4.0 (NOT GPL-3.0)** — <https://github.com/disconnectme/disconnect-tracking-protection>
- **DuckDuckGo Tracker Radar veri lisansı: CC BY-NC-SA 4.0 / data license** — <https://github.com/duckduckgo/tracker-radar>, <https://spreadprivacy.com/duckduckgo-tracker-radar/>
- Mozilla'nın izleme koruması liste kaynağı / tracking protection list source — <https://wiki.mozilla.org/Security/Tracking_protection>
- oisd lisansı (GPL-3.0) ve güncelleme sıklığı / license and update cadence — <https://oisd.nl/faq>
- Steven Black hosts (MIT sarmalayıcı / wrapper) — <https://github.com/StevenBlack/hosts>

**Mevcut çözümler / Existing solutions**

- OpenSnitch — <https://github.com/evilsocket/opensnitch>; isnat sınırları / attribution limits — <https://github.com/evilsocket/opensnitch/wiki/Why-OpenSnitch-does-not-intercept-application-XXX>; SSS / FAQ — <https://github.com/evilsocket/opensnitch/wiki/FAQs>; eBPF izleme yöntemi / monitor method — <https://github.com/evilsocket/opensnitch/wiki/monitor-method-ebpf>; LWN incelemesi / review — <https://lwn.net/Articles/988401/>
- Little Snitch (macOS) — kurallar / rules — <https://help.obdev.at/littlesnitch6/concepts-rules>; DNS şifreleme ve SNI uyarısı / DNS encryption and the SNI warning — <https://help.obdev.at/littlesnitch6/concepts-dnsencryption>; kext'ten NetworkExtension'a geçiş / migration off kexts — <https://obdev.at/blog/little-snitch-and-the-deprecation-of-kernel-extensions/>
- **Little Snitch for Linux — "built for privacy, not security"** — <https://obdev.at/products/littlesnitch-linux/index.html>
- macOS 11 `ContentFilterExclusionList` — <https://mjtsai.com/blog/2020/10/22/apple-apps-exempt-from-network-filters-and-vpns/>
- Android INTERNET izni (`protectionLevel="normal"`) / permission — <https://android.googlesource.com/platform/frameworks/base/+/refs/heads/main/core/res/AndroidManifest.xml>, <https://developer.android.com/guide/topics/permissions/overview>
- Android eBPF trafik izleme / traffic monitoring — <https://source.android.com/docs/core/data/ebpf-traffic-monitor>
- Android Data Saver — <https://developer.android.com/develop/connectivity/network-ops/data-saver>
- GrapheneOS ağ izni / Network permission — <https://grapheneos.org/features>, <https://grapheneos.org/faq>
- RethinkDNS — <https://github.com/celzero/rethink-app>, <https://rethinkdns.com/faq>, <https://docs.rethinkdns.com/firewall/>
- NetGuard SSS / FAQ (özellikle / especially 1, 19, 31, 48, 63, 64) — <https://github.com/M66B/NetGuard/blob/master/FAQ.md>
- Lockdown (iOS) — <https://github.com/confirmedcode/lockdown-ios>, <https://lockdownprivacy.com/faq>

**Cihaz üzeri gizlilik kayıtları — öncüller / On-device privacy records — precedents**

- Apple, App Privacy Report (7 gün, cihazda şifreli, JSON dışa aktarım / 7 days, encrypted on device, JSON export) — <https://support.apple.com/en-us/102188>, <https://developer.apple.com/news/?id=n5jlz7ox>
- Android Gizlilik Panosu (24 saat / 7 gün) / Privacy dashboard (24 h / 7 days) — <https://support.google.com/android/answer/13530434>

**OZERK belgeleri / OZERK documents**

- Manifesto §5, §6.3, §6.9, §7, §9, §10, §13, §21, §23, §24 — [`docs/OZERK_Proje_Manifestosu.md`](../docs/OZERK_Proje_Manifestosu.md)
- Yol haritası, D2 kapısı / roadmap, gate D2 — [`docs/yol-haritasi.md`](../docs/yol-haritasi.md)
- [RFC-0001](0001-karar-kaydi.md) (A5, D1, D3), [RFC-0002](0002-taban-dagitim.md) (§5 musl/NSS, §7 Guard altyapısı / Guard infrastructure), [RFC-0003](0003-paket-formati.md) (§4 beş profil / five profiles, §6 E/V/B, Açık Sorular / Open Questions 1, 2, 5), [RFC-0004](0004-tarayici-motoru.md) (deney yöntemi / experiment method, web runtime)


