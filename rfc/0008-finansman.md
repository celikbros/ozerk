# RFC 0008: Finansman ve Sürdürülebilirlik Planı

**Türkçe** | [English](#english)

- **RFC:** 0008
- **Başlık:** Finansman ve Sürdürülebilirlik Planı
- **Durum:** Taslak
- **Tarih:** 2026-08-17
- **Yazar(lar):** OZERK kurucusu
- **Lisans:** CC BY-SA 4.0
- **Karşıladığı açık karar:** [RFC-0001](0001-karar-kaydi.md) — A6
- **İlgili manifesto bölümleri:** 15, 19, 20, 21, 22, 23, 24
- **İlgili belgeler:** [GOVERNANCE.md](../GOVERNANCE.md), [docs/yol-haritasi.md](../docs/yol-haritasi.md)
- **Bağlantılı RFC'ler:** [RFC-0002](0002-taban-dagitim.md), [RFC-0003](0003-paket-formati.md), [RFC-0004](0004-tarayici-motoru.md), [RFC-0005](0005-guard-ag-modeli.md)

> **Doğrulama notu.** Bu belgedeki fon programı bilgileri 17 Ağustos 2026 tarihinde, mümkün olan her yerde **programın kendi resmî sayfasından** kontrol edilmiştir; her iddianın yanında erişim tarihi vardır. Fon programları sık değişir: kapanmış bir programı açıkmış gibi yazmak bu belgeyi zararlı yapar. Bu yüzden doğrulanamayan her tutar, tarih ve uygunluk şartı **"doğrulanmalı"** işaretlidir ve resmî sayfaya bağlanmıştır. **Bu belgede uydurulmuş hiçbir rakam, tarih veya program adı yoktur.** Kişi-ay ve para tahminleri ölçüm değil **planlama varsayımıdır** ve varsayımları açıkça yazılmıştır.
>
> **Bu belge hukuki veya mali tavsiye değildir.** Şirket kuruluşu, vergi, yurt dışından gelir ve sözleşme konularında **mali müşavire ve gerektiğinde hukukçuya danışılmalıdır.** Bu belgedeki mevzuat atıfları yalnızca hangi soruların sorulması gerektiğini göstermek içindir.

---

## Özet

Bu RFC, OZERK'in **gelir öncesi çok yıllık dönemini** — Aşama 0'dan Aşama 5'e kadar geçen, ürünün ve dolayısıyla manifesto §15'teki gelir kalemlerinin **henüz var olmadığı** dönemi — nasıl finanse edeceğini tanımlar.

Öneri dört cümlede:

1. **Taban senaryo fonsuzdur.** Yol haritasının ilk 12 ayı yaklaşık **19–34 kişi-ay** iş içerir; tek kişinin gönüllü kapasitesi 12 ayda yaklaşık **3–5 kişi-ay**'dır. Bu açık kapatılmazsa D1 gecikir, D2 daralır, D3 gerçekleşmez. Plan bu gerçeğin üzerine kurulur; fon bir bonus olarak eklenir, bir varsayım olarak değil.
2. **Fon, proje bütünü için değil, bileşen bazında aranır.** OZERK'in tamamı için tek başvuru yapmak, tek kişilik bir projeyi anlatılamaz büyüklükte bir vaade sokar. Bunun yerine belge, projeyi **bağımsız fonlanabilir paketlere** böler (Guard, manifest standardı, eksik upstream portallar, push, erişilebilirlik) ve her paketi uygun fon türüne eşler.
3. **Hangi paranın alınmayacağı, hangisinin alınacağından daha önemlidir.** Manifesto §23'ün kırmızı çizgileri fon sözleşmelerini de bağlar; belge reddedilecek fon türlerini adlarıyla sayar ve fonun karar yetkisi satın alamayacağını kural hâline getirir.
4. **Tüzel kişilik geciktirilerek değil, sırasıyla kurulur ve varlıklar baştan bağımsız tutulur.** Varlıkların kurucu şirketinde birikip sonra devredilmesi tarihsel olarak nadiren zamanında gerçekleşir; bu belge devri geciktirmeyen bir sıra ve beş emniyet kuralı önerir.

Bu belge iyimserlik satmaz. Projenin en kırılgan yanı finansmandır ve bugün **hiçbir gelir kaynağı, hiçbir tüzel kişilik ve hiçbir taahhüt edilmiş fon yoktur.**

---

## Motivasyon

Manifesto §15 ("Ekonomik Özgürlük") OZERK'in gelir kaynaklarını sayar: cihaz satışı, aksesuar, uzun dönem destek, kurumsal cihaz yönetimi, isteğe bağlı şifreli bulut, teknik destek, güvenli barındırma, donanım ortaklığı, düşük maliyetli ödeme altyapısı, kamu ve kurum projeleri.

Bu listenin tamamının ortak özelliği şudur: **hepsi ürün çıktıktan sonra gelir.** Cihaz satmak için cihaz, destek satmak için desteklenecek bir sistem, kurumsal yönetim satmak için kurumların kurabileceği bir platform gerekir. Yol haritasına göre bunların en erkeni Aşama 6'dadır ve [yol haritası](../docs/yol-haritasi.md) §9 bu aşamalara **bilerek süre vermez**: "ilerleme kaynak bulundukça olacaktır."

Dolayısıyla manifestoda tanımlanmamış bir boşluk vardır ve bu RFC o boşluğu kapatır:

> **Aşama 0 ile Aşama 5 arasındaki, muhtemelen çok yıllık, gelir öncesi dönem nasıl finanse edilecek?**

Bu sorunun bugünkü cevabı tek kelimedir: **gönüllü emek.** Bu cevap yanlış değildir — özgür yazılımın büyük kısmı böyle üretilmiştir — ama tek başına bir plan değildir, çünkü:

- **Ölçülebilir bir açık vardır.** §2'deki tahmin, yol haritasının 12 aylık planının tek kişinin gönüllü kapasitesinin yaklaşık dört katı olduğunu gösterir. Bu açık yazılı hâle getirilmezse, yol haritası her dönem sonunda "gecikti" diye raporlanır ve gecikmenin nedeni yanlış yere — motivasyona veya yeteneğe — yazılır. Nedeni kapasitedir.
- **Fon takvimleri projenin takviminden bağımsızdır.** Bir çağrı kaçırıldığında bedeli genellikle 6–12 aydır. Karar ertelenirse kaçırma kaçınılmazdır.
- **Fonun kendisi bir risktir.** Parayı kabul etmenin koşulları vardır ve bu koşullar manifesto §23'ü ihlal edebilir. Hangi koşulun reddedileceği, teklif masaya geldiğinde değil **önceden** yazılmalıdır; aksi hâlde karar, ihtiyacın en yüksek olduğu anda verilir. Bu, kırmızı çizgilerin tam olarak nasıl aşındığıdır (§5).
- **Şeffaflık sonradan kurulamaz.** İlk fon alındıktan sonra "bundan sonra açıklayacağız" demek, o ana kadarki her şeyi şüpheli kılar. Kural ilk kuruştan önce yazılmalıdır (§6).

[RFC-0001](0001-karar-kaydi.md) A6 bu kararı zaten açık ilan etmiştir. Bu RFC A6'yı karşılar.

---

## Tasarım

### 1. Durum tespiti — bugün elde ne var, ne yok

Bu bölüm bir özet değil, belgenin temelidir. Aşağıdaki tablo bugünün gerçeğidir ve §2–§8'in tamamı bu tablonun üzerine kurulur.

| Soru | Bugünkü cevap |
|---|---|
| Tüzel kişilik var mı? | **Hayır.** Ne dernek, ne vakıf, ne şirket. |
| Banka hesabı / ödeme kanalı var mı? | **Hayır.** Proje adına açılmış hiçbir kanal yok. |
| Gelir var mı? | **Hayır.** Bağış, sponsorluk, satış — hiçbiri yok. |
| Taahhüt edilmiş fon var mı? | **Hayır.** Başvurulmuş bir hibe de yok. |
| Ekip var mı? | **Hayır.** Bir kişi. Düzenli katkıcı sayısı: 0. |
| Ürün var mı? | **Hayır.** [README](../README.md): "henüz kullanılabilir bir ürün veya platform kodu yoktur." |
| Marka tescili var mı? | **Hayır.** ([RFC-0001](0001-karar-kaydi.md) A7'de açık karar.) |
| Ne var? | Kurucu belgeler, beş RFC taslağı, bir CLI iskeleti, bir yol haritası ve gönüllü emek. |

Bu tablo bir başarısızlık beyanı değildir; Aşama 0'da bulunması **beklenen** durumdur. Ancak fon konuşmasının başlangıç noktası budur ve bu belge boyunca hiçbir cümle bu tabloyla çelişemez.

**Bir kalibrasyon çapası.** OZERK'in kendini kıyaslayabileceği en yakın proje postmarketOS'tur: on yıldan uzun süredir çalışan, geniş katkıcı topluluğu olan, tanınmış bir mobil Linux projesi. Kendi yayımladığı 2025 mali raporuna göre postmarketOS 2025'te **38.038,59 €** bağış almış ve **39.908,66 €** harcamıştır; 2026 bütçesi **62.400 €** gelir / **68.918,88 €** gider olarak onaylanmıştır (postmarketOS, 11 Mart 2026; erişim 17 Ağustos 2026).

Bu rakam iki yönlü okunmalıdır ve ikisi de ayıklayıcıdır:

- **Üst sınır olarak:** Bu ölçekteki, tanınmış bir projenin yıllık bütçesi bile yaklaşık **bir tam zamanlı mühendisin** yıllık maliyeti düzeyindedir. Bağışla iki-üç kişilik ekip fonlamak bu ekosistemde gerçekçi değildir.
- **Alt sınır olarak:** OZERK bugün tanınmıyor ve ürünü yok. Bağış gelirinin planlanabilir bir bütçe kalemi olarak varsayılması **yanlış olur.** Bu belgede bağış, bir bütçe kalemi değil, bir kanal olarak ele alınır.

### 2. Ne kadar kaynağa ihtiyaç var — Ay 0–12

#### 2.1. Varsayımlar (açıkça yazılmıştır)

Aşağıdaki her rakam bu varsayımlara bağlıdır. Varsayım değişirse rakam değişir.

| # | Varsayım | Not |
|---|---|---|
| **V1** | **1 kişi-ay = 150 üretken mühendislik saati.** Toplantı, idari iş, fon başvurusu ve öğrenme eğrisi bunun dışındadır ve ayrı kalem olarak sayılır. | Planlama varsayımı. |
| **V2** | **Fonlanan bir kişi-ayın projeye brüt maliyeti 1.500–3.000 €.** Bu bir piyasa araştırması değil, projenin kendi planlama bandıdır; işveren yükleri, muhasebe, banka ve kur maliyetlerini kabaca içerir. | **Doğrulanmalı** — gerçek rakam mali müşavirle hesaplanmalıdır. |
| **V3** | **Bütçe euro cinsinden tutulur; TL karşılığı bu belgede verilmez.** TL bütçesi, başvuru anındaki kurla ve çok yıllı planlarda enflasyon revizyonuyla yeniden hesaplanır. | 12 ay önceden yazılmış bir TL rakamı yanıltıcı olurdu; bu bir kaçınma değil, §24 gereğidir. |
| **V4** | **Kurucunun sürdürülebilir gönüllü kapasitesi haftada 10–15 saattir** (aylık ~45–65 saat ≈ 0,3–0,45 kişi-ay). | Varsayım; gerçekleşme ölçülmeli ve yol haritası gözden geçirmelerinde raporlanmalıdır. |
| **V5** | Donanım, alan adı ve altyapı gibi nakit kalemler ayrı sayılır; CI bugün ücretsiz katmanla yürümektedir. | Ücretsiz katman değişirse bu kalem büyür. |

#### 2.2. Yol haritası kalemlerinin kişi-ay tahmini

Tahminler [yol haritası](../docs/yol-haritasi.md) §3–§6'daki kalemlere birebir karşılık gelir. Belirsizlik sütunu, tahmine ne kadar güvenilebileceğini söyler; **yüksek** olanlar tahmin değil, tahmin denemesidir.

| Kalem | Dönem | Kişi-ay | Belirsizlik |
|---|---|---|---|
| Kurucu belgeler + RFC taslakları (0002–0005) | Ay 0–2 | 2–3 | Düşük (büyük kısmı yapıldı) |
| `ozerk` CLI iskeleti + CI | Ay 0–2 | 0,5–1 | Düşük |
| QEMU'da taban dağıtım denemeleri ve notlar | Ay 0–2 | 0,5–1 | Orta |
| Markalı QEMU imajı + hesapsız kurulum akışı (**D1**) | Ay 2–4 | 2–4 | Orta-yüksek |
| Flatpak portal sandbox denemesi | Ay 2–4 | 0,5–1 | Düşük |
| `ozerk init` / `ozerk build` gerçek işlev | Ay 2–4 | 1–2 | Orta |
| **Guard v0** — [RFC-0005](0005-guard-ag-modeli.md) mimarisi, emülatörde (**D2**) | Ay 4–8 | 4–7 | **Yüksek** (E1 ölçülmedi) |
| Gizlilik Merkezi v0 tasarım taslağı | Ay 4–8 | 0,5–1 | Düşük |
| 3–5 çekirdek uygulamanın paketlenmesi | Ay 4–8 | 1–2 | Orta |
| İmzalı depo v0 + anahtar yönetimi belgeleri | Ay 8–12 | 2–3 | Orta |
| İlk gerçek cihaz bring-up (**D3**) | Ay 8–12 | 3–6 | **Çok yüksek** |
| Dogfood, metrik toplama ve yayımlama | Ay 8–12 | 0,5–1 | Düşük |
| Proje yürütme: issue, PR, iletişim, çeviri, fon başvuruları | Süreklilik | 1–2 | Orta |
| **Toplam** | **Ay 0–12** | **19–34** | — |

Orta nokta yaklaşık **26 kişi-ay**'dır. Bu, 12 takvim ayına yayıldığında **yaklaşık 1,6–2,8 tam zamanlı kişi** demektir.

Bu sayı, yol haritasının kendi dürüstlük notunu doğrular: yol haritası §9 "tek kişilik bir başlangıcın bu aşamaların tamamını tek başına taşıyamayacağı bilinmektedir" der. §2.3 bunu ölçülü hâle getirir.

#### 2.3. Üç senaryo

| | **(a) Yalnız gönüllü emek** | **(b) Bir kişinin yarı zamanlı fonlanması** | **(c) 2–3 kişilik çekirdek ekip** |
|---|---|---|---|
| Kapasite (12 ay) | ~3–5 kişi-ay | ~7–9 kişi-ay | ~25 kişi-ay (30 brüt − ~%15 koordinasyon) |
| İhtiyacın karşılanma oranı | **%12–25** | **%25–45** | **%75–100** |
| Nakit ihtiyacı | ~150–500 € (cihaz, alan adı; kurucunun cebinden) | **~10.000–20.000 €** | **~50.000–95.000 €** |
| Nakdin kaynağı | Yok | Tek bir küçük hibe yeterli olabilir | Birden çok hibe veya tek büyük araç |
| **D1** (Ay 4) | Gerçekleşir ama **gecikir** — gerçekçi tahmin Ay 7–10 | **Ay 4–6**'da gerçekleşir | Ay 3–4'te gerçekleşir |
| **D2** (Ay 8) | **Gerçekleşmez.** En iyi ihtimalle Guard'ın profil 1 (ağ yok) sert sınırı gösterilebilir; alan adı günlüğü ve engelleme 12 ayda yetişmez | **Daraltılmış hâlde gerçekleşir** (Ay 10–12): profil 1 zorlaması + alan adı günlüğü; profil 2 allowlist muhtemelen yetişmez | **Ay 8**'de tam kapsamda gerçekleşir |
| **D3** (Ay 12) | **Gerçekleşmez.** Ne imzalı depo v0 ne cihaz bring-up bu kapasiteye sığar | **Gerçekleşmez.** İmzalı depo v0 kısmen yapılabilir; cihaz bring-up sonraki yıla kayar | **Riskli biçimde gerçekleşebilir.** Yol haritasının kendi tanımladığı daraltma (Wi-Fi + Guard gösterimi) devrede kalır |
| 12 ay sonunda [yol haritası §8](../docs/yol-haritasi.md) listesi | 6 maddenin 2–3'ü | 6 maddenin 3–4'ü | 6 maddenin 5–6'sı |

**Bu tablonun en önemli satırı D2'dir.** Guard, manifesto §5 ve §9'un temel farklılaştırıcısıdır ve [RFC-0005](0005-guard-ag-modeli.md)'in mimarisi 4–7 kişi-ay'lık bir iştir. Senaryo (a)'da bu iş 12 aya sığmaz. Yani **fon bulunmazsa gecikecek olan şey, projenin en ayırt edici bileşenidir.** Bu, fon aramanın gerekçesini yol haritasının içinden verir.

**Senaryo (a) taban senaryodur.** Fon gelmezse geçerli plan budur; belge (b) veya (c) gerçekleşecekmiş gibi yazılmamıştır. Yol haritası, (a) gerçekleştiğinde **güncellenir ve gecikme gerekçesiyle yayımlanır** — gizlenmez (yol haritası §10).

**Senaryo (c) hakkında bir uyarı.** İki-üç kişilik ekip, kişi-ay toplamını artırdığı kadar yönetim yükü de getirir: işe alma, koordinasyon, ödeme ve raporlama. Tek kişilik bir projede bu yük doğrudan kurucunun mühendislik zamanından düşer. Ayrıca ücretli ve gönüllü katkıcıların bir arada bulunması topluluk dinamiğini etkiler; postmarketOS bunu kendi katkıcı ödeme planında açıkça bir risk olarak yazar ("The plan may affect community dynamics by creating distinctions between compensated and non-compensated contributors"; pmCR 0004, erişim 17 Ağustos 2026). OZERK bu riski §6'daki şeffaflık kuralıyla ele alır, yok saymaz.

#### 2.4. Nakit kalemler (kişi-ay dışında)

| Kalem | Tahmin | Not |
|---|---|---|
| İlk gerçek cihaz (mainline destekli, ikinci el) + yedek | 150–400 € | [RFC-0001](0001-karar-kaydi.md) A4 kararına bağlı; fiyat piyasaya göre değişir |
| Alan adı ve temel altyapı | 20–60 €/yıl | |
| İkinci cihaz, kablo, seri/UART adaptör, SD kart vb. | 50–150 € | Bring-up için pratikte gerekir |
| Build/CI (ücretsiz katman aşılırsa) | 0–600 €/yıl | Bugün 0 |
| Marka tescili | **Doğrulanmalı** | [RFC-0001](0001-karar-kaydi.md) A7'ye aittir; bu belgede rakam verilmez |
| Muhasebe / tüzel kişilik yürütme | **Doğrulanmalı** | Yalnızca tüzel kişilik kurulursa doğar; mali müşavire danışılmalı |

### 3. Fon kaynakları — doğrulanmış envanter

Bu bölümdeki her program **kendi resmî sayfasından** 17 Ağustos 2026 tarihinde kontrol edilmiştir. Bağlantılar §Kaynaklar bölümündedir.

> **Uyarı — bu bölüm çabuk eskir.** Aşağıdaki takvimlerin çoğu 2026 sonbaharına aittir. Bu belgeye altı ay sonra bakan biri, başvuru yapmadan önce **her programın kendi sayfasını yeniden kontrol etmelidir.** Bu bölüm bir referans değil, bir başlangıç noktasıdır.

#### 3.1. NLnet / NGI Zero → "Open Internet Stack" — **en uygun kaynak, ama tam bir geçiş anındayız**

**Bulgu (kritik).** NGI (Next Generation Internet) programı **sonlanma aşamasındadır** ve NLnet, Avrupa Komisyonu'nun Tech Sovereignty paketi kapsamındaki **"Open Internet Stack"** çatısına geçmektedir. NLnet'in 12 Haziran 2026 tarihli kendi duyurusuyla: *"As NGI is in a concluding phase, after the summer the regular application process will be opened with three new programmes under the new Open Internet Stack umbrella."* NGI Zero'nun en kapsamlı fonu olan **Commons Fund'ın son çağrısı 1 Haziran 2026'da kapanmıştır**; NGI Zero Core'un son çağrısı 1 Ekim 2024'te, Entrust'ın son çağrısı 1 Aralık 2023'te kapanmıştır.

Yani 2024'te dolaşan "AB, NGI fonlamasını kesiyor" haberleri NGI Zero'nun bir anda yok olmasıyla sonuçlanmamıştır; ama **NGI Zero bu hâliyle bitmiştir** ve devamı yeni programlardır: **Restack**, **CodeSupply**, **ELFA**.

**Bugünkü durum (17 Ağustos 2026):** NLnet'in `propose` sayfası şunu yazar: *"At the moment it is not possible to submit proposals to NLnet Foundation. New calls for several funds will open up **September 3rd 2026** with a deadline of **November 3rd 2026 12:00 CEST**."* Başvuru formundaki çağrı seçicisi "There are currently no calls open." demektedir. NLnet ayrıca son başvuru ritmini **çift ayların 1'inden tek ayların 3'üne** taşımıştır.

**Bu, bu belgenin en zaman-duyarlı bulgusudur:** OZERK için en uygun fon kapısı, bu RFC'nin yazıldığı tarihten **17 gün sonra** açılmakta ve **2,5 ay** açık kalmaktadır (§8).

| Konu | Doğrulanan durum |
|---|---|
| Ne fonlar | Özgür/açık internet altyapısı; yazılım, donanım, standart, belge |
| Tutar | **5.000–50.000 €** (tipik bant, Restack ve CodeSupply/ELFA sayfalarında açıkça yazılı) |
| Restack özel kuralı | **İlk öneri en fazla 50 k€.** Daha büyüğü için önce daha küçük bir projenin başarıyla tamamlanmış olması **şart**. Öneri başına tavan 150 k€; bir tarafa programın ömrü boyunca toplam tavan 500 k€ |
| Restack programı | 1 Haziran 2026 – 30 Mayıs 2030, 7 M€; "In principle there are continuous open calls" |
| CodeSupply / ELFA | Açık çağrılar için ayrılan bütçe: sırasıyla 400 k€ ve 300 k€; ikisi de "first call will open up soon" |
| **Birey başvurabilir mi** | **Evet, açıkça.** Restack SSS: *"You can apply as an individual, or as a formal or informal organisation of any type."* Uygunluk sayfası: *"There are no categorical exclusions of persons who may not receive support."* |
| **Tüzel kişilik şartı** | **Yok** |
| **Türkiye'den başvuru** | **Evet — üstelik öncelikli grupta.** NLnet: *"Given equal proposals, inhabitants of the EU and countries associated to Horizon Europe are given priority."* Türkiye Horizon Europe'a **asosiye ülkedir** (§3.3) → istisna kategorisinde değil, öncelik kategorisindedir |
| Lisans şartı | *"releasing software, hardware and content under libre/open licenses ... transversal requirements for all."* Restack: yazılım ve donanım **tamamen** tanınmış bir açık kaynak lisansıyla yayımlanmalı; ikili lisanslama serbest |
| **D1 karma lisans modeliyle uyum** | **Uyumlu.** GPL-3.0-or-later ve Apache-2.0 tanınmış özgür lisanslardır. **Ancak NLnet lisansları ada ada saymaz** — "recognised free/libre/open source license" der. Belgeler için CC BY-SA'nın kabulü de ada ada doğrulanmamıştır → **doğrulanmalı** (NLnet lisans danışmanlığı sunar; başvuruda sorulabilir) |
| Ek yükümlülük | Restack çıktıları için **WCAG uyumu**; 50 k€ üzeri projelerde bağımsız güvenlik denetimi |

**Doğrulanmalı:** 3 Eylül 2026'da hangi fonların açılacağı sayfa sayfa ilan edilmemiştir ("several funds"); Restack/CodeSupply/ELFA çağrılarının 3 Kasım son tarihini paylaşıp paylaşmayacağı da netleşmemiştir. **Çağrı açıldığında kapsam metni okunmadan başvuru paketi kesinleştirilmemelidir.**

#### 3.2. Sovereign Tech Agency (Almanya) — **bugün OZERK için uygun değil, ve nedeni öğreticidir**

**Kurumsal ev doğrulandı:** Sovereign Tech Agency, **SPRIND'in (Federal Agency for Disruptive Innovation) bir yan kuruluşudur** ve **Alman Federal Dijital Dönüşüm ve Devlet Modernizasyonu Bakanlığı** tarafından finanse edilir (eski adı Sovereign Tech Fund; tüzel kişilik: Sovereign Tech Agency GmbH).

| Program | Durum (17 Ağustos 2026) | Not |
|---|---|---|
| **Sovereign Tech Fund** (yatırım) | **Açık — sürekli başvuru** | Aşağıdaki iki eleme kriterine dikkat |
| **Sovereign Tech Resilience** | **Açık — sürekli başvuru** | Para değil **hizmet** verir: doğrudan katkı, bug bounty (YesWeHack), kod denetimi (OSTIF) |
| **Sovereign Tech Fellowship** | **Kapalı.** *"The application period ended on April 6, 2026."* | Yeniden açılacağı söylenmiş, **tarih yayımlanmamış → doğrulanmalı** |
| **Sovereign Tech Standards** | Kapalı; pilot Haziran 2026 – Haziran 2027 | |
| **Sovereign Tech Challenge** | Kapalı/atıl (son tarih 6 Temmuz 2023) | |

**Coğrafya bir engel değildir.** Kurum kendi sayfasında *"we invest globally"* der ve SSS'de "Almanya veya AB dışındaki projeler" sorusuna *"we work with people, companies, and FOSS communities everywhere"* cevabını verir. **Türkiye'den bir bakımcı dışlanmaz.**

**Engel başka yerdedir ve OZERK'i bugün doğrudan eler:**

1. **"We do not finance the development of prototypes."** OZERK'in Ay 0–12 çıktılarının tamamı — Guard v0 dahil — yol haritasının kendi diliyle **prototiptir**.
2. **"We are currently not looking for user-facing applications, such as messaging apps or file storage services."** OZERK bir kullanıcı ürünüdür.
3. **Alt sınır:** *"The cost of the work described in the application must exceed €50,000."* Bu bir **taban**dır, tavan değil — NLnet'in tavanı burada eşiktir. Senaryo (b) bütçesi bu eşiğin altında kalır.
4. **Kamu fonu çakışma yasağı:** Aynı faaliyet için başka bir kamu kurumundan hibe/yatırım almış projeler uygun değildir. **Bu, NLnet ve STA'ya aynı iş paketiyle başvurmayı engeller.** Paketleme yaparken (§4) bu kural bağlayıcıdır.

**Dolayısıyla STA, OZERK için Aşama 0–1 kaynağı değildir.** İki dolaylı yolu vardır ve ikisi de gerçekçi olarak **Aşama 3 ve sonrasına** aittir:

- **Upstream bakımcılığı üzerinden:** OZERK'in dayandığı temel bileşenler (portallar, UnifiedPush, paket araç zinciri) STA'nın tanımına uyar. Ancak başvuran, o bileşenin bakımcısı olmalıdır. OZERK'in [D3 upstream-öncelikli stratejisi](0001-karar-kaydi.md) yıllar içinde bunu mümkün kılabilir; bugün kılmaz.
- **Fellowship üzerinden (serbest çalışan):** Serbest çalışan seçeneği **dünya çapında** açıktır (istihdam seçeneği yalnızca Almanya'da oturma ve çalışma izni olanlara). Ancak uygunluk eşiği *en az üç FOSS projesine katkı ve en az birinde bakımcılık (merge/release yetkisi)* ister. **Kurucu bugün bu eşiği karşılamamaktadır.**

**Lisans uyumu — burada net bir cevap var.** STA'nın ölçütü açıkça yazılıdır: *"OSI-approved or FSF Free/Libre licenses are acceptable for code. Creative-Commons-like licenses for documentation may not include non-commercial or 'no derivative' clauses."* Buna göre **GPL-3.0**, **Apache-2.0** ve belgeler için **CC BY-SA 4.0** (NC ve ND içermez) ölçüte uygundur. D1 karma lisans modeli STA ile **uyumludur**. Sorun lisans değil, olgunluktur.

#### 3.3. Horizon Europe — **Türkiye asosiyedir; ama araç bu ölçeğe uygun değildir**

**Belirleyici olgu doğrulandı: Türkiye, Horizon Europe'a (2021–2027) tam asosiye ülkedir.** Avrupa Komisyonu'nun resmî ülke sayfası: *"Türkiye became fully associated member to Horizon Europe in January 2021."* Asosiyasyon sayfası 22 asosiye ülkeyi sayar ve Türkiye bu listededir. Asosiyasyonun anlamı resmî sayfada şöyle tanımlanır: asosiye ülke kuruluşları programa *"on equal terms with entities of EU countries"* katılır; AB üyesi kuruluşlarla **aynı hak ve yükümlülüklere** sahiptir.

**Bu olgunun asıl değeri Horizon başvurusu değildir** — dolaylı etkisidir: NLnet'in öncelik ölçütü (§3.1) doğrudan bu listeye bağlıdır. **Türkiye'nin asosiye statüsü, OZERK'i NLnet'in öncelik grubuna sokar.** Bu belgedeki en değerli tek olgu budur.

Doğrudan Horizon başvurusuna gelince:

- **Konsorsiyum şartı:** Çağrıların çoğu için *"at least 3 partner organisations from 3 different EU or associated countries"* ve bunlardan en az biri AB ülkesinden. Tek kişilik bir proje bu yapıyı kuramaz.
- **Tüzel kişilik:** Program tüzel kişilikler üzerine kuruludur. Gerçek kişilerin yararlanıcı olabildiği REA sayfasında **açıkça belirtilmemiştir → doğrulanmalı** (çağrı bazında uygunluk koşulları okunmalıdır).
- **EIC Accelerator** (tek yararlanıcılı): hibe **2,5 M€'ya kadar**, öz sermaye 0,5–10 M€; 2026 bütçesi Open için 414 M€, Challenges için 220 M€. Ancak kurulmuş bir KOBİ/girişim ve **TRL 6–8** olgunluk ister. **OZERK bugün uygun değildir.**
- **ERC Starting Grant:** tek araştırmacı, ama **doktora** (2026 çağrısı için savunma 1 Ocak 2019 – 31 Aralık 2023) ve bir **ev sahibi kurum** şarttır. Bağımsız, akademi dışı bir geliştirici için yol değildir.
- **Fikri mülkiyet ve açık kaynak:** Sonuçların mülkiyeti üreten yararlanıcıdadır; açık bilim zorunludur ("as open as possible, as closed as necessary") ve hakemli yayınlar için **CC BY** yükümlülüğü vardır. **Yazılımın açık kaynak yayımlanmasına dair genel bir zorunluluk resmî sayfalarda doğrulanamamıştır → doğrulanmalı** (Model Hibe Sözleşmesi Ek 5 ve çağrı metni okunmalıdır).
- **FP10 / sonraki çerçeve:** Komisyon 16 Temmuz 2025'te bir sonraki çerçeve programı önerisini sunmuştur ("Horizon Europe (2028–2034)", önerilen bütçe 175 milyar €, 409 milyar €'luk European Competitiveness Fund içinde). **Durum: yalnızca öneri**; kurumlar arası müzakereler sürmektedir. Plan yapılamaz.

**Sonuç:** Horizon Europe, OZERK için doğrudan bir Aşama 0–2 aracı değildir. Değeri, (a) Türkiye'nin asosiye statüsünün NLnet ve benzeri fonlardaki türev etkisi, (b) ileride bir konsorsiyuma **ortak** olarak katılma ihtimalidir — koordinatör olarak değil.

#### 3.4. TÜBİTAK — **tümü tüzel kişilik veya akademik kadro istiyor; tek istisnası koşullu**

| Program | Durum | Tüzel kişilik / kadro şartı | Rakam (resmî sayfadan) |
|---|---|---|---|
| **1507** KOBİ Ar-Ge Başlangıç | Aktif; 2026-2 çağrısı açık | **Türkiye'de kurulu, KOBİ ölçeğinde sermaye şirketi.** Birey başvuramaz | Destek oranı %75, geri ödemesiz; **proje bütçe üst sınırı 3.000.000 TL**; süre en fazla 18 ay; yılda iki çağrı |
| **1501** Sanayi Ar-Ge | Aktif; 2026-2 çağrısı açık | Sermaye şirketi | %75 sabit, geri ödemesiz; İngilizce sayfada *"There is no budget limit"*; en fazla 36 ay |
| **1512 BiGG** Girişimcilik | Aktif ama **yeniden yapılandırıldı** | Ön lisans/lisans/yüksek lisans/doktora **öğrenciliği veya yakın mezuniyet** şartı; **Aşama 2'de şirket kurmak zorunlu** | **Destek tutarı resmî 1512 sayfasında yazılı değil → doğrulanmalı.** Yaş sınırı da sayfada yazılı değil |
| **1812 BiGG Yatırım** | Aktif — **hibe değil, öz sermaye** | Şirket kurmak zorunlu | Aşama 2 (Ön Tohum) 2026-1: **%3 pay karşılığı 1.350.000 TL**, ek 1.350.000 TL'ye kadar takip yatırımı; Aşama 2'de azami pay %5, Aşama 3'te (BiGG+) azami %10 |
| **1002** Hızlı Destek | Aktif, sürekli başvuru | **Üniversite/araştırma kurumu kadrosu şart** | 1 Şubat 2026 itibarıyla **yıllık 150.000 TL** üst sınır; en fazla 12 ay |
| **2244** Sanayi Doktora | Aktif | **Başvuran üniversitedir**, birey değil | İlgisiz |

**En sert bulgu:** TÜBİTAK'ta **açık kaynak yazılıma özel bir destek programı bulunamamıştır.** Resmî sayfalarda böyle bir program yoktur.

**Tek gerçekçi giriş kapısı 1512/1812 BiGG'dir** ve üç koşulu vardır: (a) üniversite öğrenciliği veya yakın mezuniyet, (b) Aşama 2'de şirket kurma zorunluluğu, (c) 1812'de **%3–5 öz sermaye devri.**

Bu üçüncü koşul bu RFC için ayrıca değerlendirilmelidir: 1812 bir hibe değil **yatırımdır**. OZERK'in kurucu şirketinde bir kamu fonunun pay sahibi olması, GOVERNANCE.md §3'teki gün batımı taahhüdüyle ve manifesto §19.2 ile doğrudan gerilim yaratır — varlıkların ileride bağımsız bir yapıya devri, artık kurucunun tek taraflı kararı olmaktan çıkar. **Bu, §7'deki tuzağın somut hâlidir.**

**Doğrulanmalı (kritik):** 1512/1812 uygulama esaslarının **fikri mülkiyet ve lisanslama** hükümleri okunamamıştır (PDF metni çıkarılamadı). Açık kaynak bir proje için bu belirleyicidir: **destek alan çıktının açık kaynak yayımlanmasına bir kısıt var mı?** Başvuru düşünülüyorsa bu soru başvurudan **önce** cevaplanmalıdır.

#### 3.5. KOSGEB — **önce şirket, sonra destek**

KOSGEB'in girişimcilik destekleri yeniden yapılandırılmıştır: eski "Geleneksel Girişimci Destek Programı" **yürürlükten kaldırılan destekler** bölümündedir; bugünkü ana araç **Girişimci Destek Programı (GDP)**'dir.

| Bileşen | Tutar | Geri ödemeli mi | Şart |
|---|---|---|---|
| **İş Kurma Desteği** | Kuruluş gideri: gerçek kişi işletme **10.000 TL**, sermaye şirketi **20.000 TL**; genç/kadın/engelli/gazi/şehit yakını için **+10.000 TL**; ayrıca personel desteği | **Geri ödemesiz (%100)** | **İşletme 0–1 yaşında olmalı** — yani şirket **önce** kurulur, destek sonra alınır. Sürekli başvuru |
| **İş Geliştirme Desteği** | Üst sınır **1.500.000 TL** (+150.000 TL ek) | **%80, geri ödemeli** | İşletme 0–3 yaşında; bilgisayar programcılığı dahil sektörler; **dönemsel çağrı** |
| **Faiz/kâr payı desteği** | 1.000.000 TL kredi tavanı, %50'si karşılanır | Geri ödemesiz kısım faiz desteğidir | Yalnızca genç veya kadın girişimci, jüri puanı 50+ |

**Ar-Ge, Ür-Ge ve İnovasyon Destek Programı** ayrı bir kalemdir (üst sınır 1.100.000 TL, Başkanlık kararıyla 6.000.000 TL'ye kadar çıkabilir) ve sayfasında "işletmeler/girişimciler" ifadesi geçer — yani **şirketi henüz kurmamış bir girişimcinin başvurabilirliği belirsizdir → doğrulanmalı.** Ayrıca bu program güncel aktif program dizininde görünmemektedir; **yürürlükte olup olmadığı doğrulanmalıdır.**

**Sonuç:** Doğrulanan her KOSGEB aracı, KOSGEB veri tabanında kayıtlı **aktif bir işletmeye** bağlıdır. KOSGEB, kayıtlı işi olmayan bir gerçek kişiyi fonlamaz. Ayrıca İş Geliştirme Desteği'nin **geri ödemeli** olduğu gözden kaçırılmamalıdır: bu bir hibe değil, borçtur ve gelirsiz bir projeye borç almak §1'deki tabloyla bağdaşmaz.

**Doğrulanmalı:** KOSGEB'in fikri mülkiyet/açık kaynak hükümleri erişilebilir sayfalarda bulunamamıştır. "Sınai mülkiyet hakları" gider kalemi patent/tescil yönelimini ima eder; açık kaynak yayıma **kısıt olduğu da doğrulanmamıştır.**

#### 3.6. Topluluk fonlaması — **Türkiye'den ödeme almanın kendisi bir kısıttır**

Bu alt bölümün bulgusu beklenenden serttir: **sorun bağış toplamak değil, toplanan parayı Türkiye'ye almaktır.** İki büyük ödeme altyapısı Türkiye'ye kapalıdır ve platformların çoğu bu ikisinden birine dayanır:

- **Stripe:** Türkiye, Stripe'ın hesap açılabilen ülkeler listesinde yoktur. Stripe'ın kendi belgesi sınır ötesi ödemeleri *"Platforms based in the United States, United Kingdom, EEA, Canada, and Switzerland can transfer funds to connected accounts located in any of these same regions"* diye sınırlar; Türkiye AEA'da değildir.
- **PayPal:** PayPal Türkiye'deki faaliyetlerini **Haziran 2016'da durdurmuştur**; kendi Türkçe sayfasıyla: *"PayPal'ın Türkiye'deki müşterileri para gönderemez veya alamaz..."*
- **Wise:** Türkiye adresli müşteri Wise **hesabı tutamaz** ve Wise hesabına para **alamaz**; ancak başkaları Wise üzerinden **Türkiye'deki banka hesabına** TRY gönderebilir. Yani Wise bir cüzdan olarak kapalı, bir **raylı hat** olarak açıktır.

Bu üç olgu aşağıdaki tabloyu belirler:

| Kanal | Türkiye'den ödeme alınabilir mi | Ödeme yolu | Kesinti | Not |
|---|---|---|---|---|
| **NLnet hibesi** | **Evet** | **Doğrudan EUR banka havalesi** (Stichting NLnet) | **%0** | Örnek MoU'da alıcı *"an individual domiciled in..."* olarak kurgulanmıştır; ödeme aracısı yoktur, dolayısıyla Stripe/PayPal engeli işlemez. Bu, en temiz yoldur |
| **GitHub Sponsors** | **Evet — Türkiye resmî listede** | Stripe Connect **veya** bir mali sponsor (fiscal host) | Bireysel sponsorluklarda **%0**; kurumsal sponsorluklarda %6'ya kadar | **Çelişki:** GitHub Türkiye'yi destekli sayar ama Stripe kendi listesinde saymaz; **Türkiye ödemesinin fiilen nasıl yürüdüğü doğrulanamamıştır.** Mali sponsor yolu daha güvenlidir ve **yalnızca kayıt anında** seçilebilir |
| **Open Collective + Open Source Collective** | **Evet (çıkarım)** | Host, **Wise ile Türk IBAN'ına** gönderir (PayPal yolu kapalı ve 600 USD ile sınırlı) | OSC host ücreti **%10**; OC Europe %8–10 | OSC ülke listesi yayımlamaz → "Türkiye çalışır" iki resmî kaynaktan **çıkarımdır, OSC'nin beyanı değildir → doğrulanmalı.** Ayrıca OSC, çok projeli **bireyler** için GitHub Sponsors'ı önerir |
| **Patreon** | **Evet** | **Payoneer** üzerinden banka havalesi, USD→TRY | %10 platform (4 Ağustos 2025 sonrası) + işlem + %2,5 kur | PayPal yolu Türkiye'ye kapalı. Açık kaynağa özgü değil, genel içerik platformu |
| **Polar** | **Evet — Türkiye listede** | Stripe Connect Express; Polar "merchant of record" | %5 + 50¢ (ücretsiz katman) | Stripe'ın kendi belgeleri bunu doğrulamaz → **doğrulanmalı.** TRY cinsinden gerçek bir Türk banka hesabı gerekir |
| **Liberapay** | **Hayır** | Stripe + PayPal | — | Liberapay'in üç destek katmanının **hiçbirinde Türkiye yoktur**: *"If you don't live or have a registered business in one of the territories listed above, then you currently can't use Liberapay to receive donations."* |
| **Buy Me a Coffee** | **Hayır** | Stripe Express | — | Ülke listesinde Türkiye yok; *"we can only offer payouts in countries supported by Stripe"* |
| **Ko-fi** | **Fiilen hayır (çıkarım)** | Yalnızca Stripe veya PayPal | — | Ko-fi kendi ülke listesini yayımlamaz, tamamen Stripe/PayPal'a devreder |
| **thanks.dev** | Listede TR var | Stripe Connect / GH Sponsors / Open Collective | Bakımcıdan %0 | Kaynak güvenilirliği düşük (SPA paketinden okundu) → **doğrulanmalı** |
| **Software Freedom Conservancy** | **Doğrulanamadı** | Belgelenmemiş | %10 | Bireyleri değil **projeleri** himaye eder; birey ancak himaye edilen projeye **yüklenici** olarak ödeme alır ve iş *"must already be on your project's road map"* olmalıdır. Uygunluk eşiği ("vibrant, diverse community", tipik olarak ≥1 yıl geliştirme) OZERK'in bugün karşılamadığı bir eşiktir |

**OZERK için pratik sonuç:** Bugün gerçekçi olarak açılabilecek kanallar **GitHub Sponsors** ve — proje eşiği karşılanırsa — **Open Collective/OSC**'dir; NLnet ise bir bağış kanalı değil, hibe kanalıdır ve ödeme yolu en temiz olanıdır. Ancak §1'deki kalibrasyon burada tekrar edilmelidir: **bağış geliri bir bütçe kalemi olarak varsayılamaz.** Bir kanal açmanın değeri paradan çok görünürlüktür; sıfır gelirle açılmış bir bağış sayfası da dürüst bir sinyaldir.

> **Vergi ve mevzuat boyutu vardır ve bu belge onu çözmez.** Yurt dışından gerçek kişi olarak gelir almanın Türkiye'de **gelir vergisi, kambiyo ve beyan** boyutları vardır; ayrıca bu platformların bir kısmı ABD stopaj formu (**W-8BEN**) ister. Paranın "bağış", "serbest meslek kazancı" veya "hibe" olarak nitelenmesi sonucu değiştirebilir ve niteleme, seçilen ödeme yoluna göre farklılaşabilir. **Herhangi bir kanal açılmadan önce mali müşavire danışılmalıdır** — tercihen kanallar arasında seçim yapmadan önce. Bu belge bu kuralları yazmaz ve tahmin etmez.

#### 3.7. İkincil kaynaklar — biri açık ve önemli, çoğu kapalı

**Open Technology Fund (OTF, ABD) — açık, birey başvurabilir; ama koşulları §5.2 ile çarpışıyor.**

OTF 2025'te ciddi bir kesinti krizi yaşamıştır: kendi duyurusuyla, 21 Mart 2025'te USAGM ve OMB aleyhine dava açmış, USAGM'nin 15 Mart 2025 tarihli fon sonlandırmasının hukuka aykırı olduğunu savunmuştur. **Davanın sonucu resmî sayfalardan doğrulanamamıştır → doğrulanmalı.** Ancak kurum bugün çalışmaktadır: başvuru portalı açıktır ve 2026 tarihli çağrılar yayımlanmıştır.

| Fon | Durum | Tutar | Uygunluk |
|---|---|---|---|
| **Internet Freedom Fund** | **Açık, sürekli başvuru** | 10.000–900.000 $; *"Ideal applicants seek funding between $50,000 and $200,000"* | *"Individuals or organizations (for-profit or nonprofit) of all ages irrespective of nationality... are eligible to apply"*; tek coğrafi engel OFAC yaptırım listesidir |
| **Rapid Response Fund** | Açık | 1–50.000 $, ≤6 ay | Acil, devlet kaynaklı dijital tehditler için — OZERK'e uygun değil |
| **FOSS Sustainability Fund** | **Kapalı** — *"Not currently accepting applications"* | Açıkken ~150.000–400.000 $ | Tek bakımcılı projeleri de kapsıyordu; yeniden açılırsa izlenmeli |
| **Information Controls Research** | **Açık: 27 Temmuz – 7 Eylül 2026** | Aylık 7.000 $ stipend | Sansür **araştırması**; OZERK geliştirmesi değil |

Tutarlar OZERK'in ihtiyacına birebir oturmaktadır ve birey başvurabilmektedir. **Buna rağmen bu RFC OTF'yi öncelikli kapı olarak önermez** ve nedeni ideolojik değil, sözleşmeseldir:

1. **Hibe değil sözleşme.** OTF kendi başvuru kılavuzunda: *"we do not provide grants to our supported projects. Rather, OTF administers deliverable-based contracts."*
2. **Fikri mülkiyet devri.** FOSS Sustainability çağrı metnindeki hüküm: *"all Work Product produced under the contract, if awarded, will be the sole property of OTF."* Bu, **§5.2/6'ya doğrudan çarpar.**
3. **Yayın onayı şartı.** *"Applicants shall not issue, or permit to be issued... publicity in any form respecting the work hereunder... unless such publicity is first approved in writing by OTF."* Bu, **§5.2/7'ye doğrudan çarpar** ve yol haritasının "açık geliştirme" ilkesiyle bağdaşmaz.
4. **Yasal görev tanımı.** OTF'nin kongre görevi (22 U.S.C. §309A), kurumun *"maintain the technological advantage of the United States Government over authoritarian governments"* amacına hizmet etmesini içerir. Bu, §5.3'teki konumlandırma geriliminin en keskin hâlidir — bir devletin teknolojik üstünlük hedefiyle tanımlanmış bir fon, "bağımsız ve kullanıcı-egemen" iddiasına gölge düşürür.

**Karar önerisi:** OTF kapatılmaz, ama ancak (a) yukarıdaki IP ve yayın maddelerinin **fiilen sözleşmede olup olmadığı** her fon için ayrıca doğrulandıktan ve (b) §5.2'yi ihlal etmeyen bir metin müzakere edilebildikten sonra başvurulur. Doğrulanmadan başvurmak, kabul edilmesi hâlinde reddetmek zorunda kalmak demektir; bu da hem zaman kaybı hem de karşı tarafa saygısızlıktır.

**Prototype Fund (Almanya) — uygun değil, ve nedeni nettir.** Program yaşamaktadır (Open Knowledge Foundation Deutschland e.V. yürütür; BMFTR finanse eder) ve tutarı bilinen en cömert küçük hibelerden biridir: **bireyler için 6 ayda 47.500 €'ya kadar** (ikinci aşamayla 10 ayda 79.167 €). Sıradaki çağrı: **1 Ekim – 30 Kasım 2026.** Ancak uygunluk şartı açıktır: *"As an individual developer, you are a resident of Germany, self-employed, or a freelancer and pay your taxes here."* Ekipler için istisna yalnızca **AB ülkelerinde** ikamet eden üyeleri kapsar. **Türkiye'de ikamet eden bir başvuran uygun değildir.** Bu program bu belgede yalnızca "denenmemeli" diye kayda geçirilmiştir.

**FUTO — küçük ama erişilebilir ve ilkeleri örtüşüyor.** Başvuru açıktır ve tek yol e-postadır (`grantapps@futo.org`); form, son tarih veya döngü yoktur. İki katman vardır: *Legendary Grants* — *"generally reserved for established entities we trust"* (OZERK bugün değil) — ve **mikro hibeler: 1.000–5.000 $.** Fonlanan projelerden beklenenler manifestoyla dikkat çekici biçimde örtüşür: *"All FUTO-funded projects are expected to remain fiercely independent"*, *"'The users are our product' revenue models are strictly prohibited"*, *"All FUTO-funded projects are expected to be open source or develop a plan to eventually become so."* **FUTO'nun kendi "Source First" lisansını benimseme zorunluluğu resmî sayfalarda yoktur** — şart açık kaynak olmaktır, belirli bir lisans değil. Tutar küçüktür (bir kişi-ay bile etmeyebilir); değeri paradan çok ilk dış onaydır.

**Kapalı olanlar — kayda geçirilmesi zaman kazandırır:**

- **Mozilla:** MOSS sayfası kendi ifadesiyle *"the MOSS program is on indefinite hiatus and is not currently accepting applications."* Mozilla Technology Fund'ın sayfaları genel bir hibe sayfasına yönlenmektedir; son kohort 2024'tür. Mozilla Foundation hibe sayfasında bugün **açık çağrı yoktur.** Mozilla Fellowship 2026 kapalıdır ve Track I ülke listesinde Türkiye yoktur.
- **Internet Society Foundation:** Programların çoğu kuruluşun **kendi adına banka hesabı** ister ve 501(c)(3) veya eşdeğeri tescil arar; 2026 pencereleri kapanmıştır.
- **Ford Foundation / Digital Infrastructure Insights:** *"We are not soliciting grant proposals at this time."* Ayrıca yalnızca **araştırmayı** fonlamıştı, geliştirmeyi değil.
- **GNOME Foundation / KDE e.V. / Linux Foundation / Alpha-Omega:** Dış projelere açık hibe programı bulunamamıştır. LFX Mentorship parayı **mentee'ye** öder, projeye değil.

**Katkıcı kapasitesi — para değil, insan (ve bazen maliyet):**

- **Google Summer of Code:** Mentor kuruluş şartı *"an active open source project with a solid community that has already released software under an OSI-approved license"*'dır. **OZERK bugün bu eşiği karşılamaz.** Kuruluş başvuru penceresi tipik olarak Ocak'tadır (2026'da 19 Ocak – 3 Şubat; **2027 tarihleri henüz yayımlanmamıştır → doğrulanmalı**). Not: kurucu, kendi projesine katkıcı olarak katılamaz.
- **Outreachy:** Bu bir gelir kalemi **değil, gider kalemidir**: topluluk stajyer başına en az **8.000 $ bağışlamak** zorundadır. Sonraki son tarih 11 Eylül 2026'dır. Bu belgede yalnızca yanlış anlaşılmayı önlemek için anılmıştır.



#### 3.8. Kurumsal ve kamu pilotları — gelir değil, gerilim kaynağı

Manifesto §15 "kamu ve kurum projeleri"ni bir gelir kalemi olarak sayar. Türkiye'de bunun somut gerekçesi vardır: KVKK (6698 sayılı Kanun) kapsamında **kişisel verilerin yurt dışına aktarımı** rejimi 7499 sayılı Kanunla değiştirilmiş (Resmî Gazete 12 Mart 2024; 9. maddedeki değişiklik 1 Haziran 2024'te yürürlüğe girmiş), standart sözleşme ve bağlayıcı şirket kuralları mekanizmaları getirilmiş, usul ve esaslar yönetmeliği 10 Temmuz 2024'te yayımlanmıştır. Veri egemenliği kaygısı taşıyan bir kurumun, hesap zorunluluğu olmayan ve telemetrisi beyan edilmiş bir mobil platforma ilgi duyması makul bir varsayımdır.

**Ama bu, Aşama 0–2 için bir gelir kaynağı değildir ve öyle sunulmamalıdır.** Nedeni basittir: pilot yapılacak bir platform yoktur. D3 gerçekleşmeden kurumsal pilot konuşulması, manifesto §24'ün ("gerçekleşmemiş özellikleri varmış gibi pazarlamama") ihlali olur.

Gerilimin kendisi de kayda geçirilmelidir. Bir kurum pilotu şunları getirir: (a) kurumun kendi gereksinimleri (cihaz yönetimi, uzaktan denetim, kayıt tutma) manifesto §23'ün kırmızı çizgileriyle çakışabilir; (b) tek bir büyük müşteri, yol haritasını fiilen belirleyen taraf hâline gelebilir; (c) "bağımsız ve kullanıcı-egemen" konumlandırma, kurumsal bir müşterinin gölgesinde zayıflar. **Kurumsal cihaz yönetimi manifestoda meşru bir gelir kalemidir; ancak kurumun cihaz üzerindeki yetkisinin kullanıcıya görünür olması şarttır** (kırmızı çizgi 4 ve 15). Bu, bir pilot sözleşmesinin müzakere edilemez maddesidir.

Sonuç: kurumsal/kamu pilotu bu RFC'de **Aşama 5 sonrası** bir kalem olarak konumlandırılır ve §5'teki kabul edilmeyen koşullar listesi bu pilotlar için de aynen geçerlidir.

#### 3.9. Özet — tek tabloda

| Kaynak | Durum (17 Ağu 2026) | Birey? | Türkiye? | Tutar | OZERK için bugün |
|---|---|---|---|---|---|
| **NLnet** (Restack / CodeSupply / ELFA) | **3 Eylül 2026'da açılıyor**, son tarih 3 Kasım 2026 12:00 CEST | **Evet**, tüzel kişilik gerekmez, doğrudan ödenir | **Öncelik grubunda** | 5–50 k€ (ilk öneri) | **Birinci hedef** |
| **FUTO** mikro hibe | Açık, e-postayla | Evet | Belirtilmemiş | 1–5 k$ | Düşük maliyetli ikinci deneme |
| **OTF** Internet Freedom Fund | Açık, sürekli | Evet, her uyruk | OFAC dışı → engel yok | 10–900 k$ | **Koşullu** — IP ve yayın maddeleri §5.2'ye çarpıyor |
| **Sovereign Tech Fund** | Açık, sürekli | Belirsiz → doğrulanmalı | Evet | >50 k€ (taban) | **Uygun değil** — prototip ve kullanıcı-yüzlü elemesi |
| **Sovereign Tech Fellowship** | Kapalı (6 Nis 2026) | Evet (serbest çalışan, dünya çapında) | Evet | Müzakereli | Eşik karşılanmıyor (3 FOSS projesi) |
| **Prototype Fund** | 1 Eki – 30 Kas 2026 | Evet | **Hayır — Almanya ikameti şart** | 47,5 k€ / 6 ay | **Uygun değil** |
| **Horizon Europe** | Açık (çağrı bazlı) | Hayır | Evet (asosiye) | Büyük | Konsorsiyum gerekir; bugün değil |
| **TÜBİTAK 1507 / 1501** | Açık | Hayır | Evet | 1507: 3 M TL tavan | Sermaye şirketi şartı |
| **TÜBİTAK 1512 / 1812** | Açık | Aşama 1'de evet | Evet | 1812: %3 pay ↔ 1,35 M TL | Şirket + öz sermaye devri (S3) |
| **TÜBİTAK 1002** | Açık, sürekli | Hayır | Evet | 150 k TL/yıl | Akademik kadro şartı |
| **KOSGEB GDP** | Açık | Hayır | Evet | İş Geliştirme 1,5 M TL (**geri ödemeli**) | Önce şirket şartı |
| **GitHub Sponsors** | Açık | Evet | **Evet** (mekanizma doğrulanmalı) | Bağış | Kanal olarak açılabilir |
| **Open Collective / OSC** | Açık | Evet (host üzerinden) | Evet (Wise → TR IBAN) | Bağış, %8–10 kesinti | Proje eşiği doğrulanmalı |
| **Liberapay / Buy Me a Coffee / Ko-fi** | — | — | **Hayır** | — | Kullanılamaz |
| **Mozilla / ISOC / Ford** | **Kapalı** | — | — | — | Yok |
| **GSoC / Outreachy** | Döngüsel | Katkıcı kapasitesi | Evet | Outreachy **gider** (8 k$/stajyer) | Eşik karşılanmıyor |


### 4. Fonlanabilir birimlere ayırma

#### 4.1. Neden tek başvuru yapılmaz

"OZERK'i fonlayın" diye bir başvuru yazılamaz. Üç nedeni vardır ve üçü de §1'deki tablodan çıkar:

1. **Ölçek uyuşmazlığı.** OZERK'in tamamı 19–34 kişi-ay'lık bir iştir (§2.2); NLnet'in ilk hibe tavanı 50 k€'dur, yani yaklaşık 17–33 kişi-ay değil, **17–33 kişi-ay'ın küçük bir bölümüdür.** Tek başvuru, hiçbir fonun büyüklüğüne oturmaz.
2. **Değerlendirilebilirlik.** Fonlar somut, teslim edilebilir kilometre taşları ister. "Bir mobil işletim sistemi kuracağım" cümlesi, tek kişilik ve ürünsüz bir projeden geldiğinde değerlendirilemez. "Flatpak uygulamaları için uygulama-başı ağ zorlaması ve bunun portal önerisi" cümlesi değerlendirilebilir.
3. **Bağımsız değer.** Aşağıdaki paketlerin çoğu, **OZERK başarısız olsa bile** ekosisteme kalır. Bu, hem başvurunun gücüdür hem de manifesto §24 ile tutarlı tek dürüst çerçevedir: fon veren tarafa "bu para, OZERK tutmasa da boşa gitmez" denebilmelidir.

**Bağlayıcı kural — çakışma yasağı.** Sovereign Tech Agency, aynı faaliyet için başka bir kamu kurumundan destek almış projeleri uygun görmez (§3.2). Ayrıca aynı işi iki fona sunmak, hangi fon olursa olsun etik değildir. Bu nedenle paketler **ayrık** tanımlanır ve bir paket yalnızca bir fona sunulur; hangi paketin nereye sunulduğu `FUNDING.md`'de kayıt altına alınır (§6).

#### 4.2. Paketler

| # | Paket | Kapsam | Kişi-ay | Uygun fon | Bağımsız değeri |
|---|---|---|---|---|---|
| **P1** | **Guard ağ modeli zorlama katmanı** ([RFC-0005](0005-guard-ag-modeli.md)) | Uygulama-başı ağ namespace'i + `pasta` + sistem denetimli çözümleyici + çözümleyici-çapalı nftables kümesi; RFC-0005'in E1 pil/gecikme ölçümü; Flatpak'ı **değiştirmeden** `bwrap` çevresinde çalışan katman | 4–7 | **NLnet** (Restack / CodeSupply) | Herhangi bir Flatpak tabanlı sistemde çalışır; `xdg-desktop-portal#1166`'daki açık talebe cevap verir. OZERK'e bağımlı değildir |
| **P2** | **OZERK App manifest standardı ve doğrulayıcı** ([RFC-0003](0003-paket-formati.md)) | Flatpak üst kümesi olarak ağ profili + telemetri beyanı alanları; `ozerk` CLI doğrulayıcısı; şema ve belgeler; `[X-OZERK*]` alanlarının araç zincirinden korunarak geçtiğinin ölçülmesi | 2–4 | **NLnet** (standart işi olarak) | Bir **standart** önerisidir; kabul görmese bile beyan modeli tartışmaya katkıdır |
| **P3** | **Eksik upstream portallar: Contacts ve Calendar** | Portal spesifikasyonu önerisi + `xdg-desktop-portal` arka ucu + veri sağlayıcı tarafı. Bugün Linux'ta "seçilen kişiler" düzeyi **yoktur**; tek denetim `org.gnome.evolution.dataserver.*` gibi bir D-Bus adının topluca verilip verilmemesidir ([RFC-0003](0003-paket-formati.md)) | 3–6 | **NLnet** — tam hedefi | **En yüksek bağımsız değer.** Kabul edilirse tüm masaüstü ve mobil Linux ekosistemine gider; değeri OZERK'in başarısına hiç bağlı değildir |
| **P4** | **Push ve suspend bağdaştırması** (A8, UnifiedPush) | UnifiedPush'un gerçek suspend ile bir arada çalışması: uyanma pencereleri, modem uyandırma, ölçülmüş pil/gecikme tablosu | 3–5 (+donanım) | **NLnet** | Mobil Linux'un tamamının çözülmemiş sorunudur |
| **P5** | **Erişilebilirlik** | Mobil Linux'ta (Phosh/GNOME çevresi) erişilebilirlik durumunun envanteri ve seçilmiş iyileştirmeler | 2–4 | **NLnet** — Restack çıktılar için **WCAG uyumu ister**, yani burada erişilebilirlik ek yük değil, uyum kalemidir | Ekosistem geneline gider |
| **P6** | **Güncelleme mimarisi katkıları** ([RFC-0002](0002-taban-dagitim.md) §10.3) | A/B güncelleme ve bozuk güncellemeden otomatik geri dönüşün taban dağıtımda çalışır hâle getirilmesi | 2–4 | NLnet — **ancak önce çakışma kontrolü** | postmarketOS'un değiştirilemez imaj + A/B OTA prototipi **zaten NGI Zero kapsamında fonlanmıştır**; aynı işi tekrar sunmak yanlış olur |

#### 4.3. Sıralama ve gerekçesi

**Önerilen ilk başvuru: P3 (Contacts/Calendar portalı), ikinci: P1 (Guard).**

Bu sıra sezgiye aykırıdır — Guard projenin ayırt edici bileşenidir — ve gerekçesi şudur:

- **P3'ün değerlendirilmesi OZERK'e bakmayı gerektirmez.** Boşluk somut, dar ve doğrulanabilirdir; başvuran tanınmıyor olsa bile boşluk gerçektir. Tek kişilik ve ürünsüz bir projeden gelen başvuru için bu, en yüksek kabul şansıdır.
- **P3, D3 upstream-öncelikli stratejisini nakde çevirir.** Kabul edilirse kurucu, bir upstream projeye katkı geçmişi kazanır — bu da §3.2'de görülen Sovereign Tech Fellowship eşiğine (*en az üç FOSS projesine katkı, en az birinde bakımcılık*) giden **tek gerçekçi yoldur.** Yani P3, sonraki fon kapılarını açan pakettir.
- **P1 daha büyüktür ve daha risklidir.** RFC-0005 kendi E1 deneyini "RFC'nin tek en büyük belirsizliği" olarak tanımlar. Ölçülmemiş bir pil maliyetinin üzerine kurulmuş bir başvuru, reddedilirse hem parayı hem zamanı kaybettirir. P1, P3'ten sonra ve tercihen E1'in ilk ölçümü yapıldıktan sonra sunulmalıdır.

**Yol haritasıyla bağ.** P1 doğrudan **D2**'yi finanse eder. P3, P4, P5 yol haritasının 12 aylık planında **yoktur** — bunlar Aşama 3–4 işleridir. Bu, kabul edilmesi gereken bir ödünleşimdir ve gizlenmemelidir: **fon almak, yol haritasının sırasını değiştirir.** Bir portal işi kabul edilirse kurucunun zamanı D1/D2'den o işe kayar. Bu ödünleşim §6 uyarınca ilan edilir ve yol haritası güncellenir; yol haritası zaten "ilerleme kaynak bulundukça olacaktır" der. Ancak bu esneklik sınırsız değildir: **hiçbir fon, projenin aşama sırasını manifesto §21'in dışına çıkaracak biçimde değiştiremez.**

---

### 5. Karşılığında ne vaat edilir, ne edilmez

#### 5.1. Vaat edilebilecekler

- Belirli, ölçülebilir teknik çıktılar ve bunların **açık lisansla** yayımı (D1 lisans modeli).
- Değişikliklerin upstream'e sunulması (D3).
- Fon verene **görünürlük ve atıf** — depoda, sürüm notlarında ve `FUNDING.md`'de.
- Sözleşmede tanımlı **raporlama ve denetim**.
- Bir bileşene öncelik verilmesi ve bunun kamuya ilan edilmesi (§4.3).
- Kurucunun emeği ve zamanı.

#### 5.2. Kabul edilmeyecek koşullar — bağlayıcı liste

Aşağıdaki koşullardan **herhangi birini** içeren fon, tutarı ne olursa olsun ve proje ne kadar ihtiyaç içinde olursa olsun **reddedilir.** Her madde manifesto §23'teki bir kırmızı çizgiye bağlıdır.

1. **Kullanıcı verisine erişim veya veri paylaşımı isteyen sponsorluk.** (Kırmızı çizgi 3.) "Anonimleştirilmiş", "toplulaştırılmış" veya "yalnızca istatistiksel" nitelemeleri bu maddeyi değiştirmez.
2. **Ürüne arka kapı, anahtar emaneti (key escrow) veya gizli/zorunlu telemetri koşulu.** (Kırmızı çizgi 4 ve 15.) Ölçüm yapılacaksa açık, beyan edilmiş ve kapatılabilir olmak zorundadır.
3. **Varsayılan yerleştirme karşılığı gelir:** varsayılan arama sağlayıcısı, varsayılan mağaza, varsayılan hesap veya önyüklü uygulama karşılığı ödeme. (Kırmızı çizgi 1, 2, 5, 6.)
4. **Münhasırlık:** bir bileşenin yalnızca belirli bir cihazda, altyapıda veya mağazada çalışması şartı. (Kırmızı çizgi 5 ve 13; manifesto §19.2: *"Hiçbir şirket, platformun tek sahibi veya tek dağıtım kapısı olamaz."*)
5. **Marka devri veya marka üzerinde veto.** OZERK adı bir fon sözleşmesinin konusu olamaz (manifesto §20; A7).
6. **Telif devri (copyright assignment) şartı** veya sonradan lisansı kapatmaya izin veren bir hak devri. (D1.)
7. **Yayın kısıtı:** sonucun yayımlanmasını engelleyen, geciktiren veya kaynak kodun açık yayımını koşula bağlayan maddeler. (Manifesto §24; yol haritası §2 "açık geliştirme".)
8. **Karar yetkisi:** fon veren tarafa RFC sürecinin dışında karar, onay veya veto yetkisi tanıyan her düzenleme. **Para, oy satın alamaz.** (GOVERNANCE.md §2.)

Bu liste, teklif masaya geldiğinde değil **bugün** yazılmıştır ve nedeni budur: kırmızı çizgiler, ihtiyacın en yüksek olduğu anda aşınır.

Bunun en iyi belgelenmiş örneği Canonical'ın kendi cümlesidir. Ubuntu 12.10'da Unity Dash aramalarının Amazon sonuçlarıyla birleştirilmesini açıklarken Canonical şunu yazmıştır (12 Ekim 2012):

> *"Keeping the Ubuntu project sustainable requires the development of services that continuously improve the user experience and can at the same time be 'monetized'."*

Cümlenin kendisi makuldür — sürdürülebilirlik gerçek bir sorundur. Sonucu ise şudur: özellik gizlilik tartışmasına yol açmış, 2013'te ICO'ya resmî şikâyet yapılmış ve çevrim içi Dash sonuçları **Ubuntu 16.04'te varsayılan olarak kapatılmıştır.** Ders, Canonical'ın kötü niyetli olduğu değildir; **sürdürülebilirlik baskısının, ilkelerin aşındığı yer olduğudur.**

#### 5.3. Kamu fonunun gerilimi ve Pardus dersi

Kamu fonu — ulusal ya da yabancı — bu belgede reddedilmez. Ama iki gerilimi vardır ve ikisi de yazılmalıdır.

**Birincisi konumlandırmadır.** "Bağımsız ve kullanıcı-egemen" iddiası, projenin yönünü bir kurumun önceliklerine bağladığı ölçüde zayıflar. Bu, ulusal fon için de yabancı fon için de geçerlidir; AB, Alman veya ABD kaynaklı fonlar simetrik bir algı sorunu üretir. Dürüst çözüm kaynağı gizlememek, kaynak çeşitliliği hedeflemek ve **hiçbir tek fonun projenin devamı için zorunlu olmamasıdır.**

**İkincisi yapısaldır ve adı Pardus'tur.** Pardus, TÜBİTAK tarafından geliştirilen ulusal bir Linux dağıtımıdır. Kendi resmî tarihçesine göre: proje 2004–2011 arasında TÜBİTAK UEKAE tarafından yürütülmüş, **2012'de proje hedefleri gözden geçirilerek yönetim ULAKBİM'e devredilmiş**, **2013'te Pardus'un Debian GNU/Linux tabanlı olarak devam etmesine karar verilmiş** ve Ekim 2024 itibarıyla proje TÜBİTAK BİLGEM YTE bünyesinde sürmektedir. 2013 dönüşümü, yıllarca geliştirilmiş özgün yığının (PiSi paket yöneticisi ve çevresi) terk edilmesi anlamına gelmiştir.

Buradaki ders **teknik değildir** — Debian tabanına geçmek savunulabilir bir mühendislik kararıdır ve OZERK'in kendi [RFC-0002](0002-taban-dagitim.md)'si benzer bir soruyu tartışmaktadır. Ders **yapısaldır**:

> **Projenin yaşadığı yer bir kurumsa, projenin teknik yönü ve sürekliliği o kurumun öncelikleriyle birlikte değişir. Kurumsal ev değiştiğinde teknik yön de değişebilir ve topluluğun bu değişimde söz hakkı, yönetişim yapısı ne kadar bağımsızsa o kadardır.**

OZERK için bunun karşılığı üç kuraldır:

- **K1** — Kamu fonu **proje bazında ve çıktı bazında** alınır; projenin kendisi bir kurumun içine taşınmaz.
- **K2** — Hiçbir fon sözleşmesi RFC sürecinin dışında karar yetkisi yaratamaz (§5.2/8).
- **K3** — Fonun bitmesi projeyi durdurmamalıdır: her fonlu iş paketi, fon kesilse bile depoda kullanılabilir bir durumda bırakılacak biçimde kilometre taşlarına bölünür.

**Tek kaynak eşiği (öneri).** Bir takvim yılında tek bir fon kaynağı, projenin toplam nakit gelirinin **%60'ını** aşarsa, bu durum `FUNDING.md`'de açık bir **risk** olarak yazılır ve bir sonraki yıl için çeşitlendirme hedefi ilan edilir. Eşik tartışmaya açıktır (Açık Soru 5); eşiğin **var olması** tartışmaya açık değildir.

---

### 6. Şeffaflık taahhüdü

Manifesto §24 dürüstlüğü ürün iddiaları için taahhüt eder. Bu RFC aynı taahhüdü **paraya** genişletir. Kural şudur:

#### 6.1. `FUNDING.md`

Depo kökünde `FUNDING.md` adlı, iki dilli, kamuya açık bir kayıt tutulur. Her fon girişi için **en az** şunlar yazılır:

| Alan | İçerik |
|---|---|
| Kaynak | Fonu veren kişi/kurum/program adı |
| Tutar | Para birimiyle, gerçek tutar (bant değil) |
| Tarih / dönem | Alındığı tarih ve kapsadığı dönem |
| Karşılık | Hangi iş paketi veya kilometre taşı için |
| Koşullar | Varsa; sözleşmenin kamuya açıklanabilir özeti veya tam metnine bağlantı |
| Bitiş | Fonun sona erdiği tarih |

Ek kurallar:

- **Kurucunun kendi cebinden yaptığı harcamalar da görünür.** Cihaz, alan adı, altyapı — bunlar "gönüllü emek ve kurucu harcaması" kalemi olarak yazılır. Aşama 0'da `FUNDING.md`'nin ilk hâli muhtemelen yalnızca bu kalemden ve **sıfır dış gelirden** oluşacaktır. Sıfır olması, dosyayı oluşturmamak için gerekçe değildir; sıfır da bir bilgidir.
- **Reddedilen fonlar da kaydedilir.** §5.2 uyarınca reddedilen bir teklif, ret gerekçesiyle birlikte yazılır. Teklif sahibinin adı ancak izin varsa yazılır; izin yoksa koşulun kendisi anonim olarak kaydedilir. Bu, RFC sürecinin "karar izi" ilkesinin ([RFC-0000](0000-rfc-sureci.md)) paraya uygulanmış hâlidir.
- **Gizlilik şartı bir eleme ölçütüdür.** Koşulları kamuya açıklanamayan bir fon **kabul edilmez.** Bu kural, alınmış fonlar içindir; başvuru sürecinin kendisi (değerlendirme aşamasındaki gizlilik) bu kuralın dışındadır.
- **Yıllık özet.** Her takvim yılı için gelir–gider özeti yayımlanır. Rakamlar küçük olacaktır; küçük olmaları yayımlamamak için gerekçe değildir. postmarketOS'un kendi mali raporlarını yayımlaması bu uygulamanın çalıştığını gösteren yakın bir örnektir (§1).
- **Ücretli çalışma açıklanır.** İleride biri projede ücretli çalışırsa (kurucu dahil), bu durum kimin hangi iş paketi için ödendiği düzeyinde açıklanır. Bunun topluluk dinamiğini etkilediği bilinmektedir (§2.3); şeffaflık bu etkiyi ortadan kaldırmaz ama tartışılabilir kılar.

> **Not:** GitHub'ın `.github/FUNDING.yml` dosyası bu belgenin yerine geçmez; o yalnızca bir bağış düğmesi yapılandırmasıdır. Şeffaflık kaydı `FUNDING.md`'dir.

`FUNDING.md`, ilk kuruş girmeden **önce** oluşturulur (§8, Ay 1).

---

### 7. Tüzel kişilik sırası

#### 7.1. Bugün tüzel kişilik yoktur ve bu doğru sıradır

Kurulmuş ama boş bir tüzel kişilik, yıllık yükümlülük (beyanname, muhasebe, olası denetim) getirir ve bugün karşılığında hiçbir kapı açmaz — çünkü **bugün başvurulabilecek en uygun fon (NLnet) tüzel kişilik istememektedir** (§3.1). Tüzel kişilik, ihtiyaç doğduğunda kurulur.

#### 7.2. Türkiye'deki üç seçenek ve sert gerçekleri

| Yapı | Eşik | Değerlendirme |
|---|---|---|
| **Vakıf** | 2026 yılı için yeni vakıfların kuruluşunda amaçlarına özgülenecek **asgari mal varlığı 5.000.000 TL**'dir (Vakıflar Genel Müdürlüğü; Vakıflar Meclisi'nin 22.12.2025 tarih ve 819/790 sayılı kararı) | **Aşama 0–2 için erişilemez.** Manifesto §19.1'deki "OZERK Foundation" hedefi bu eşik nedeniyle uzun vadelidir ve Türkiye'de vakıf olmak zorunda da değildir |
| **Dernek** | Türk Medeni Kanunu m.56: dernekler **en az yedi** gerçek veya tüzel kişinin oluşturduğu kişi topluluklarıdır | **Bugün kurulamaz** — proje tek kişiliktir. GOVERNANCE.md §3'teki teknik komite eşiği (kurucu dışında ≥3 düzenli katkıcı) ile dernek eşiği (7 kurucu) **aynı değildir**; dernek daha geç bir aşamadır |
| **Şirket (tek ortaklı limited)** | 6102 sayılı Türk Ticaret Kanunu m.573 uyarınca limited şirket **bir veya daha çok** gerçek veya tüzel kişi tarafından kurulabilir; yani tek kişiyle kurulabilir. *(Kanun metni bu belgenin yazımı sırasında `mevzuat.gov.tr` üzerinden doğrudan alınamadı; madde numarası ikincil hukuk kaynaklarından teyit edilmiştir → **birincil metinden doğrulanmalı**.)* Usul, maliyet ve yıllık yükümlülükler için **mali müşavire danışılmalıdır** | Hibe ve pilot sözleşmesi için en hızlı yol. **Ve tuzağın kurulduğu yer burasıdır** (§7.3) |

**Dördüncü seçenek — ve bu belgenin önerisi:** **mali sponsorluk (fiscal host).** Open Collective belgeleri bunu açıkça tanımlar: *"Fiscal hosting enables Collectives to transact without needing to legally incorporate."* Open Source Collective ve Open Collective Europe açık kaynak projelerini himaye eder; GitHub Sponsors da bu iki hostu tanır (§3.6). **Şirket kurmadan hibe ve bağış alabilmenin en ucuz ve tuzağı en az olan yolu budur.** Bedeli host ücretidir (%8–10) ve proje uygunluk eşiğidir.

#### 7.3. Tuzak: varlıkların kurucu şirkette birikmesi

Tespit edilen tuzak şudur: **marka, telif, imza anahtarları ve alan adları kurucunun şirketinde birikirse, sonradan bağımsız bir yapıya devir tarihsel olarak nadiren ve geç gerçekleşir.**

Adı konmuş örnek: **Oracle / OpenOffice.org.** OpenOffice.org, Sun Microsystems'in Oracle tarafından satın alınmasıyla Oracle'a geçmiştir. Topluluk 2010'da projeyi **LibreOffice** olarak ayırmış ve The Document Foundation'ı kurmuştur. Oracle, OpenOffice.org varlıklarını Apache Software Foundation'a ancak **Haziran 2011'de** bağışlamıştır — yani devir, topluluk zaten ayrıldıktan **sonra** gelmiştir. The Document Foundation'ın 1 Haziran 2011 tarihli açıklaması iki projenin yeniden birleşmesini memnuniyetle karşılayacağını yazmış, ancak lisans, üyelik ve norm farklarını da not etmiştir. İki proje bir daha birleşmemiştir.

Ders şudur: **devir "sonra yaparız" denerek ertelenirse, devir gerçekleştiğinde devredilecek topluluk kalmamış olabilir.**

Bu tuzağın Türkiye'ye özgü bir keskinleştiricisi de vardır: **TÜBİTAK 1812 BiGG**, kurulacak şirkette **%3–5 pay** alır (§3.4). Kamu fonunun kurucu şirketinde pay sahibi olması, varlıkların ileride bağımsız bir yapıya devrini kurucunun tek taraflı kararı olmaktan çıkarır ve GOVERNANCE.md §3'ün gün batımı taahhüdüyle doğrudan gerilim yaratır.

#### 7.4. Önerilen sıra

- **Aşama A — bugün → ilk hibe.** Tüzel kişilik yok. Bireysel başvurulabilen hibeler (NLnet) ve bireysel alınabilen topluluk fonlaması denenir.
- **Aşama B — tüzel kişilik gereken ilk fırsat.** **Önce mali sponsorluk denenir** (§7.2). Ancak mali sponsorluk mümkün değilse ve fon gerçekten şirket istiyorsa, şirket kurulur — §7.5'teki emniyet kuralları **kuruluşla eşzamanlı** yazılı hâle getirilmek şartıyla.
- **Aşama C — topluluk oluştuğunda.** Dernek (≥7 kurucu) veya mevcut uluslararası bir vakfın şemsiyesi; GOVERNANCE.md §3/2'deki teknik komiteye geçişle eşgüdümlü.
- **Aşama D — uzun vade.** OZERK Foundation (manifesto §19.1).

#### 7.5. Emniyet kuralları — bugünden bağlayıcı

- **E1 — Marka.** OZERK markası hangi tüzel kişilik adına tescil edilirse edilsin, Foundation kurulduğunda ona devredileceği **yazılı taahhüdüyle** tutulur. Hiçbir ticari şirket markayı münhasır kullanamaz (manifesto §19.2, §20).
- **E2 — İmza anahtarları.** Depo imza anahtarları hiçbir zaman tek bir ticari şirketin denetiminde tutulamaz. Bugün kurucunun elindedir; bu durum açıkça yazılır ve teknik komite kurulduğunda anahtar yönetiminin devri **ayrı bir RFC** ile düzenlenir.
- **E3 — Telif.** Katkıcılardan **telif devri istenmez**; telif katkıcıda kalır. Bu, tek bir sahibin lisansı sonradan kapatmasını yapısal olarak zorlaştırır — Oracle dersinin teknik karşılığı budur.
- **E4 — Alan adları ve hesaplar.** Proje alan adları ve depo/organizasyon hesapları en az iki kişinin erişebildiği bir yedeklilikle tutulmalıdır. **Bugün bu koşul sağlanmamaktadır** ve bu, kayıt altına alınan bir risktir (Açık Soru 8).
- **E5 — Devir takvimi.** Bir tüzel kişilik kurulursa, varlıkların Foundation'a devri hedefi kuruluşla birlikte kamuya yazılır ve **her yıllık raporda devir durumu raporlanır.** "Henüz devredilmedi" cevabı da bir cevaptır ve her yıl tekrarlanması bir uyarıdır.

---

### 8. Somut sonraki adımlar — önümüzdeki 3 ay

Bu bölüm tek kişilik bir projeye göre boyutlandırılmıştır. **Başvuru yazmanın kendisi bir maliyettir** (§2.2'deki "proje yürütme" kalemi): iyi bir hibe başvurusu 3–10 gün emek yer ve bu emek doğrudan yol haritasından düşer. Bu nedenle 12 ayda **en fazla 3–4 başvuru** hedeflenir, 3 ayda **en fazla bir tanesi** yazılır.

| Ne zaman | Adım | Neden şimdi |
|---|---|---|
| **Ay 1 (Ağustos–Eylül 2026)** | **`FUNDING.md` oluşturulur** — sıfır gelirle, kurucu harcamaları kalemiyle ve §6'daki kurallarla | Kural ilk kuruştan önce yazılmalıdır |
| **Ay 1** | **3 Eylül 2026'da NLnet'in açılan çağrıları okunur** ve hangi fonların açıldığı, kapsam metni ve son tarih `FUNDING.md`'ye/issue'ya not edilir | §3.1'deki "doğrulanmalı" maddesi ancak o gün kapanır |
| **Ay 1** | **P3 (Contacts/Calendar portalı) için teknik ön çalışma:** `xdg-desktop-portal` "New Portals" tartışma kategorisinde konunun daha önce açılıp açılmadığı taranır; açılmamışsa bir tartışma açılır | Başvuru öncesi upstream'e sorulmamış bir öneri zayıftır. Ayrıca bu adım **fon alınmasa da** değerlidir |
| **Ay 1–2** | **Mali müşavir görüşmesi — yalnızca bilgi toplama.** Sorular: yurt dışından gerçek kişi olarak hibe/bağış almanın nitelenmesi; W-8BEN'in etkisi; hangi eşikten sonra tüzel kişilik gerekir | Kanal açmadan **önce** sorulmalıdır (§3.6) |
| **Ay 2 (Ekim 2026)** | **Tek bir başvuru yazılır: P3.** Kilometre taşları K3'e uygun bölünür (fon kesilse bile kullanılabilir çıktı). Başvuru metninin kendisi depoda açık tutulur | Son tarih **3 Kasım 2026 12:00 CEST**; Ekim'de yazmak tampon bırakır |
| **Ay 2** | **Mali sponsorluk araştırması** (Open Source Collective / Open Collective Europe uygunluk eşikleri) — başvurulmaz, yalnızca eşikler ve ücretler kayda geçirilir | §7.2'deki dördüncü seçeneğin gerçek olup olmadığı ölçülmeli |
| **Ay 3 (Kasım 2026)** | **Başvuru gönderilir (3 Kasım 12:00 CEST'ten önce).** Ardından **GitHub Sponsors** kurulumu değerlendirilir; kurulursa **mali sponsor seçeneği kayıt anında** kararlaştırılmalıdır (sonradan değiştirmek destek talebi gerektirir) | Tek somut takvim penceresi budur |
| **Ay 3** | **Düşük maliyetli ikinci deneme: FUTO'ya kısa bir e-posta** (`grantapps@futo.org`). Form ve son tarih yoktur; maliyeti bir saattir. Beklenti mikro hibe bandındadır (1–5 k$) ve reddedilme ihtimali yüksektir — bu nedenle **hiçbir plan buna dayandırılmaz** | Maliyeti neredeyse sıfır, ilkeleri örtüşüyor (§3.7) |
| **Ay 3** | Yol haritası gözden geçirilir; V4 varsayımı (haftada 10–15 saat) gerçekleşmeyle karşılaştırılır ve **sapma yayımlanır** | §2.1'deki varsayım ölçülmezse §2'nin tamamı çürür |

**Bu üç ayda yapılmayacaklar** (bilinçli olarak):

- Şirket kurulmaz (§7.1).
- TÜBİTAK/KOSGEB'e başvurulmaz — hepsi tüzel kişilik veya akademik kadro ister (§3.4, §3.5).
- Sovereign Tech Agency'ye başvurulmaz — prototip ve kullanıcı-yüzlü uygulama elemeleri nedeniyle bugün uygun değildir (§3.2).
- İkinci bir fona aynı iş paketiyle başvurulmaz (§4.1).
- Kitle fonlaması kampanyası açılmaz — ortada ürün yoktur.

---

## Alternatifler

**S1 — Hiç dış fon aramamak; tamamen gönüllü emekle yürümek.** Bağımsızlık en yüksek, koşul sıfır, idari yük sıfırdır. **Bu alternatif tamamen reddedilmemiştir:** §2.3'teki senaryo (a) taban senaryodur ve fon gelmezse yürürlükte olan plandır. Ancak *tek* strateji olarak reddedilmesinin gerekçesi §2.3'tedir: projenin en ayırt edici bileşeni (Guard) 12 aya sığmaz. Ayrıca bu alternatif bir karar değil, karar vermemektir — fon takvimleri beklemez.

**S2 — Şirket kurup risk sermayesi (VC) aramak.** Reddedilme gerekçesi: ürün yoktur; kırmızı çizgi 3 veri gelir modelini kapatır; yatırımcı çıkış bekler ve çıkış beklentisi manifesto §19.2 ile ("hiçbir şirket platformun tek sahibi olamaz") doğrudan çelişir. Aşama 6'nın ticari cihazı için yeniden değerlendirilebilir; Aşama 0–5 için değil.

**S3 — TÜBİTAK 1812 BiGG yoluna girmek.** Türkiye'den bir bireyin girebileceği tek TÜBİTAK kapısıdır ve gerçek paradır. Reddedilme gerekçesi: şirket kurma zorunluluğu + **%3–5 öz sermaye devri**, §7.3'teki tuzağı kurar ve gün batımı taahhüdünü zayıflatır; ayrıca uygulama esaslarının açık kaynak lisanslamaya etkisi **doğrulanamamıştır.** Bu seçenek kapatılmamıştır ama **ancak §7.5'teki emniyet kuralları sözleşmeye yazılabilirse** ve lisans şartları doğrulandıktan sonra yeniden açılabilir.

**S4 — Ürün öncesi kitle fonlaması / cihaz ön satışı.** Reddedilme gerekçesi: manifesto §24. Ortada ürün yokken ön satış, gerçekleşmemiş bir özelliğin satılmasıdır.

**S5 — Tek büyük fonun (Horizon Europe) peşine düşmek.** Reddedilme gerekçesi: konsorsiyum şartı ve idari yük, tek kişilik bir projenin mühendislik zamanını tüketir (§3.3). İleride **ortak** olarak katılmak açık bırakılmıştır.

**S6 — Tek bir kurumsal sponsora dayanmak.** İlkeli kurumsal sponsorluk mümkündür; reddedilen, **tek kaynağa bağımlılıktır** (§5.3, %60 eşiği).

**S7 — Kararı ertelemek.** Reddedilme gerekçesi: NLnet penceresi 3 Eylül – 3 Kasım 2026'dır. Ertelemenin bedeli, bir sonraki döngüye kadar beklemektir.

---

## Açık Sorular

1. **3 Eylül 2026'da hangi fonlar açılacak ve kapsamları ne olacak?** NLnet yalnızca "several funds" demektedir. Restack, CodeSupply ve ELFA'nın çağrı metinleri okunmadan P1–P5 paketlerinin hangisinin nereye uyduğu kesinleşemez. **Bu, §8'in tamamını bekleten sorudur.**
2. **NLnet, CC BY-SA 4.0'ı belgeler için açıkça kabul ediyor mu?** GPL-3.0 ve Apache-2.0'ın tanınmış özgür lisanslar olduğu tartışmasızdır; ancak NLnet lisansları ada ada saymaz. D1'in belge lisansı için doğrudan teyit alınmalıdır.
3. **TÜBİTAK 1512/1812 uygulama esasları, desteklenen çıktının açık kaynak yayımlanmasına kısıt getiriyor mu?** Bu soru cevaplanmadan S3 yeniden açılamaz.
4. **Türkiye'den GitHub Sponsors ödemesi fiilen hangi yolla yürüyor?** GitHub Türkiye'yi destekli listede sayar; Stripe kendi listesinde saymaz. Bu çelişki çözülmeden kanal açmak, parayı alamama riski taşır.
5. **Tek kaynak eşiği %60 mı olmalı?** Eşiğin varlığı tartışmaya kapalı, değeri açıktır. Çok düşük bir eşik erken aşamada anlamsızdır (ilk fon zaten gelirin %100'ü olacaktır); çok yüksek bir eşik uyarı işlevini kaybeder. Belki eşik, "ikinci fondan itibaren" işlemelidir.
6. **Fon, yol haritasının sırasını ne kadar değiştirebilir?** §4.3 "manifesto §21'in aşama sırası dışına çıkamaz" der; ancak dönem hedeflerinin (D1/D2/D3) ertelenmesi nereye kadar kabul edilebilir? Bu, bir sonraki yol haritası revizyonunda ölçülmelidir.
7. **Mali sponsorluk (fiscal host) OZERK için gerçekten erişilebilir mi?** Open Source Collective, "vibrant community" benzeri eşiklerden söz eder ve çok projeli bireyler için GitHub Sponsors'ı önerir. OZERK bugün bu eşiği karşılamıyor olabilir. Karşılamıyorsa §7.4'ün Aşama B'si zayıflar.
8. **Alan adları ve hesaplarda yedeklilik (E4) bugün nasıl sağlanacak?** Tek kişilik bir projede "en az iki kişi" koşulu, henüz ikinci kişi yokken nasıl karşılanır? Bir vekâlet/kurtarma mekanizması (ör. güvenilir bir üçüncü tarafta mühürlü kurtarma bilgisi) tanımlanmalı mıdır?
9. **Kurucunun kendi emeğini fonlaması etik olarak nasıl çerçevelenecek?** Senaryo (b) fiilen "kurucuya maaş" demektir. postmarketOS bunu üst sınırlar (haftalık taban/tavan, saat ücreti tavanı) ve şeffaflıkla çözer. OZERK'in eşdeğer kuralları ne olmalıdır ve bunlar bu RFC'de mi yoksa ayrı bir RFC'de mi tanımlanmalıdır?
10. **`FUNDING.md`'de reddedilen tekliflerin kaydı, teklif sahiplerini caydırır mı?** Şeffaflık ile teklif alabilme arasındaki bu gerilim ölçülmemiştir.
11. **Aşama 5 sonrası için ürün gelirlerine geçiş planı ne zaman yazılacak?** Bu RFC yalnızca gelir öncesi dönemi kapsar. Manifesto §15'teki kalemlerin hangisinin önce geleceği ayrı bir RFC'ye aittir.

---

## English

# RFC 0008: Funding and Sustainability Plan

> The Turkish text is normative in case of discrepancy.

- **RFC:** 0008
- **Title:** Funding and Sustainability Plan
- **Status:** Draft
- **Date:** 2026-08-17
- **Author(s):** OZERK founder
- **License:** CC BY-SA 4.0
- **Open decision addressed:** [RFC-0001](0001-karar-kaydi.md) — A6
- **Related manifesto chapters:** 15, 19, 20, 21, 22, 23, 24
- **Related documents:** [GOVERNANCE.md](../GOVERNANCE.md), [docs/yol-haritasi.md](../docs/yol-haritasi.md)
- **Related RFCs:** [RFC-0002](0002-taban-dagitim.md), [RFC-0003](0003-paket-formati.md), [RFC-0004](0004-tarayici-motoru.md), [RFC-0005](0005-guard-ag-modeli.md)

> **Verification note.** The funding-programme information in this document was checked on 17 August 2026, wherever possible **against each programme's own official page**, with the access date recorded. Funding programmes change often: presenting a closed programme as open would make this document harmful. Every amount, date and eligibility condition that could not be verified is therefore marked **"to be verified"** and linked to the official page. **No invented figure, date or programme name appears in this document.** The person-month and money estimates are not measurements but **planning assumptions**, and their assumptions are stated explicitly.
>
> **This document is not legal or financial advice.** On company formation, taxation, receiving income from abroad and contracts, **a certified public accountant (mali müşavir) and, where necessary, a lawyer must be consulted.** The statutory references here exist only to show which questions must be asked.

### Summary

This RFC defines how OZERK will finance its **multi-year pre-revenue period** — the span from Phase 0 to Phase 5, during which the product, and therefore every revenue item in manifesto §15, **does not yet exist**.

The proposal in four sentences:

1. **The baseline scenario is unfunded.** The first 12 months of the roadmap contain roughly **19–34 person-months** of work; one person's volunteer capacity over 12 months is about **3–5 person-months**. If that gap is not closed, D1 slips, D2 narrows, and D3 does not happen. The plan is built on that reality; funding is added as a bonus, not assumed as a premise.
2. **Funding is sought per component, not for the project as a whole.** A single application for all of OZERK would commit a one-person project to an unpresentable promise. Instead this document splits the project into **independently fundable packages** (Guard, the manifest standard, missing upstream portals, push, accessibility) and maps each to a suitable funder.
3. **Which money will be refused matters more than which will be taken.** The red lines of manifesto §23 bind funding contracts too; this document names the categories of funding that will be refused and makes it a rule that funding cannot buy decision authority.
4. **A legal entity is created in sequence rather than deferred, and assets are kept independent from the start.** Assets accumulating in a founder's company and being transferred "later" historically rarely happens on time; this document proposes a sequence that does not delay the transfer, plus five safeguard rules.

This document does not sell optimism. Funding is the project's most fragile aspect, and today there is **no revenue source, no legal entity and no committed funding.**

### Motivation

Manifesto §15 ("Economic Freedom") lists OZERK's possible revenue sources: device sales, accessories, long-term support, enterprise device management, optional encrypted cloud, technical support, secure hosting, hardware partnership, low-cost payment infrastructure, public-sector and institutional projects.

All of them share one property: **they all arrive after the product exists.** Selling devices requires a device; selling support requires a system to support. The earliest of these sits at Phase 6, and [the roadmap](../docs/yol-haritasi.md) §9 deliberately assigns no durations to those phases: "progress will happen as resources are found."

There is therefore a gap the manifesto does not define, and this RFC closes it:

> **How will the — probably multi-year — pre-revenue period between Phase 0 and Phase 5 be financed?**

Today's answer is one word: **volunteer labour.** That answer is not wrong — most free software was produced that way — but on its own it is not a plan, because:

- **There is a measurable gap.** The estimate in §2 shows that the 12-month roadmap is roughly four times one person's volunteer capacity. If that is not written down, every period will be reported as "late" and the lateness will be attributed to the wrong cause — motivation or ability. The cause is capacity.
- **Funding calendars are independent of the project's calendar.** Missing a call typically costs 6–12 months.
- **Funding is itself a risk.** Accepting money comes with conditions, and those conditions may violate manifesto §23. Which conditions will be refused must be written **in advance**, not when the offer is on the table — otherwise the decision is made at the moment of greatest need. That is exactly how red lines erode (§5).
- **Transparency cannot be retrofitted.** Saying "we will disclose from now on" after the first money arrives casts doubt on everything before it. The rule must be written before the first coin (§6).

[RFC-0001](0001-karar-kaydi.md) A6 already declared this an open decision. This RFC addresses A6.

### Design

#### 1. Where things actually stand

| Question | Answer today |
|---|---|
| Is there a legal entity? | **No.** No association, no foundation, no company. |
| Is there a bank account or payment channel? | **No.** None opened in the project's name. |
| Is there revenue? | **No.** No donations, sponsorship or sales. |
| Is there committed funding? | **No.** No grant has even been applied for. |
| Is there a team? | **No.** One person. Regular contributors: 0. |
| Is there a product? | **No.** [README](../README.md): "there is no usable product or platform code yet." |
| Is the trademark registered? | **No.** (Open decision A7 in [RFC-0001](0001-karar-kaydi.md).) |
| What does exist? | Founding documents, five draft RFCs, a CLI skeleton, a roadmap, and volunteer labour. |

**A calibration anchor.** The nearest comparable project is postmarketOS: over a decade old, with a broad contributor community. Per its own published 2025 financial report, postmarketOS received **€38,038.59** in donations in 2025 and spent **€39,908.66**; its 2026 budget was approved at **€62,400** income / **€68,918.88** expenses (postmarketOS, 11 March 2026; accessed 17 August 2026). Read as a ceiling, even a well-known project of that scale runs on roughly one full-time engineer's annual cost. Read as a floor, OZERK is unknown and has no product — **donation income must not be assumed as a budget line.**

#### 2. How much is needed — months 0–12

**Assumptions.** **V1:** 1 person-month = 150 productive engineering hours. **V2:** the gross cost to the project of one funded person-month is **€1,500–3,000** — the project's own planning band, not a market survey; **to be verified with an accountant.** **V3:** budgets are kept in euro; no lira figure is given here, because a lira figure written 12 months in advance would mislead — the lira budget is recomputed at the exchange rate on the application date, with inflation revision for multi-year plans. **V4:** the founder's sustainable volunteer capacity is 10–15 hours per week (~0.3–0.45 person-months per month); this must be measured against reality and reported. **V5:** hardware, domain and infrastructure are counted separately; CI runs on a free tier today.

**Estimate by roadmap item:** founding documents and draft RFCs 2–3; CLI skeleton and CI 0.5–1; QEMU base-distribution trials 0.5–1; branded QEMU image with account-free setup (**D1**) 2–4; Flatpak portal sandbox trial 0.5–1; real `ozerk init`/`build` 1–2; **Guard v0 per [RFC-0005](0005-guard-ag-modeli.md) (D2) 4–7 (high uncertainty)**; Privacy Center v0 draft 0.5–1; packaging 3–5 core applications 1–2; signed repository v0 with key management 2–3; first real-device bring-up (**D3**) 3–6 (very high uncertainty); dogfooding and metrics 0.5–1; project running (issues, PRs, communication, grant applications) 1–2. **Total: 19–34 person-months**, midpoint about 26 — i.e. roughly **1.6–2.8 full-time people** across 12 calendar months.

**Three scenarios:**

| | **(a) Volunteer only** | **(b) One person funded half-time** | **(c) A 2–3 person core team** |
|---|---|---|---|
| Capacity over 12 months | ~3–5 person-months | ~7–9 person-months | ~25 person-months (30 gross − ~15% coordination) |
| Share of the need met | **12–25%** | **25–45%** | **75–100%** |
| Cash required | ~€150–500 (device, domain; from the founder's pocket) | **~€10,000–20,000** | **~€50,000–95,000** |
| **D1** (month 4) | Happens but **late** — realistically months 7–10 | **Months 4–6** | Months 3–4 |
| **D2** (month 8) | **Does not happen.** At best a profile-1 (no network) hard boundary can be shown; the domain log and blocking do not fit in 12 months | **Happens in narrowed form** (months 10–12): profile-1 enforcement plus domain logging; the profile-2 allowlist probably does not make it | **Happens at month 8** in full scope |
| **D3** (month 12) | **Does not happen** | **Does not happen.** Signed repository v0 partly; device bring-up slips to the next year | **May happen, at risk.** The roadmap's own narrowing (Wi-Fi + Guard demo) stays available |
| Roadmap §8 checklist after 12 months | 2–3 of 6 items | 3–4 of 6 | 5–6 of 6 |

**The most important row is D2.** Guard is the core differentiator of manifesto §5 and §9, and [RFC-0005](0005-guard-ag-modeli.md)'s architecture is 4–7 person-months of work. In scenario (a) it does not fit into 12 months. In other words, **what gets delayed for lack of funding is precisely the project's most distinctive component.**

**Scenario (a) is the baseline.** If no funding arrives, it is the plan in force; this document is not written as though (b) or (c) will happen. **Scenario (c) carries a warning:** management overhead comes out of the founder's engineering time, and mixing paid and volunteer contributors affects community dynamics — postmarketOS states this plainly in its own contributor compensation plan ("The plan may affect community dynamics by creating distinctions between compensated and non-compensated contributors"; pmCR 0004, accessed 17 August 2026). §6 addresses this with transparency rather than ignoring it.

**Cash items besides labour:** first real device (mainline-supported, second-hand) plus a spare €150–400; domain and basic infrastructure €20–60/year; cables, UART adapter, SD cards €50–150; CI €0–600/year (today €0); trademark registration **to be verified** (belongs to A7); accounting and entity upkeep **to be verified**, and only if an entity is created.

#### 3. Funding sources — verified inventory

> **Warning — this section ages quickly.** Most of the calendars below belong to autumn 2026. Anyone reading this six months later **must recheck each programme's own page before applying.**

**3.1. NLnet / NGI Zero → "Open Internet Stack" — the best fit, but we are exactly at a transition.**

**Critical finding.** The NGI (Next Generation Internet) programme **is in a concluding phase** and NLnet is transitioning to the **Open Internet Stack** umbrella within the European Commission's Tech Sovereignty package. In NLnet's own words (12 June 2026): *"As NGI is in a concluding phase, after the summer the regular application process will be opened with three new programmes under the new Open Internet Stack umbrella."* The **NGI Zero Commons Fund's final call closed on 1 June 2026**; NGI Zero Core's last call closed 1 October 2024; Entrust's closed 1 December 2023. So the 2024 reports that the EU was dropping NGI did not result in NGI Zero vanishing overnight — but **NGI Zero as such has ended**, and the successors are **Restack**, **CodeSupply** and **ELFA**.

**Status today (17 August 2026):** NLnet's propose page states: *"At the moment it is not possible to submit proposals to NLnet Foundation. New calls for several funds will open up **September 3rd 2026** with a deadline of **November 3rd 2026 12:00 CEST (noon)**."* NLnet has also shifted its deadline rhythm from the 1st of even months to the 3rd of odd months.

**This is the most time-sensitive finding in this document:** the best-fitting funding door for OZERK opens **17 days after** this RFC's date and stays open for **2.5 months** (§8).

Amounts: **€5,000–50,000** is the standard band. Restack's specific rules: a **first proposal may request up to €50k**; anything larger **must** be preceded by a successfully concluded smaller project; the maximum per proposal is €150k, and the maximum per third party over the programme's lifetime is €500k. Restack runs 1 June 2026 – 30 May 2030 with €7M in grants and "in principle... continuous open calls"; CodeSupply and ELFA reserve €400k and €300k respectively for open calls, both "coming soon."

**Individuals may apply, explicitly:** *"You can apply as an individual, or as a formal or informal organisation of any type."* And: *"There are no categorical exclusions of persons who may not receive support."* **No legal entity is required**, grants are milestone-based, each person or entity in a grant *"can be paid directly by us"*, and payment is by **direct EUR wire transfer** — so the Stripe/PayPal blockade described in §3.6 does not apply.

**Applying from Türkiye: yes — and in the priority tier.** NLnet: *"Given equal proposals, inhabitants of the EU and countries associated to Horizon Europe are given priority."* Türkiye is an associated country (§3.3), so a Türkiye-based applicant is not in the exceptional-case tier. A "European dimension" is a knock-out criterion.

**Licensing:** *"releasing software, hardware and content under libre/open licenses... are transversal requirements for all"*; Restack requires software and hardware to be published under a recognised open source licence **in its entirety**; dual licensing is permitted. **This is compatible with D1.** However, **NLnet never enumerates licences by name**, so acceptance of CC BY-SA 4.0 for documents is **to be verified**. Restack additionally requires **WCAG compliance** for software artefacts, and an independent security audit above €50k.

**To be verified:** exactly which funds open on 3 September 2026 ("several funds"), and whether Restack/CodeSupply/ELFA share the 3 November deadline.

**3.2. Sovereign Tech Agency (Germany) — not a fit today, and the reason is instructive.**

The Agency is **a subsidiary of SPRIND** and is financed by the **German Federal Ministry for Digital Transformation and Government Modernisation** (formerly the Sovereign Tech Fund; the legal vehicle is Sovereign Tech Agency GmbH). Status: **Sovereign Tech Fund — open, rolling; Sovereign Tech Resilience — open, rolling (services, not cash); Fellowship — closed** (*"The application period ended on April 6, 2026"*, next round undated, **to be verified**); Standards — closed (pilot June 2026 – June 2027); Challenge — dormant since 2023.

**Geography is not the obstacle:** *"we invest globally"*, and the FAQ answers the non-Germany question with *"we work with people, companies, and FOSS communities everywhere."*

The obstacles are elsewhere, and they eliminate OZERK today: (1) *"We do not finance the development of prototypes"* — everything OZERK produces in months 0–12, Guard v0 included, is by the roadmap's own language a prototype; (2) *"We are currently not looking for user-facing applications, such as messaging apps or file storage services"* — OZERK is a user-facing product; (3) *"The cost of the work described in the application must exceed €50,000"* — a **floor**, not a ceiling, and scenario (b) falls below it; (4) a **public-funding exclusion**: projects already funded by another public body for the same activities are ineligible, which **rules out submitting the same work package to both NLnet and STA** (§4.1).

Two indirect routes exist, both realistically Phase 3 and later: via **upstream maintainership** of a base component, or via the **Fellowship's freelance track**, which is worldwide-eligible but requires contributions to at least three FOSS projects with maintainership (merge or release rights) on at least one — a bar the founder does not meet today.

**Licensing here is unambiguous:** *"OSI-approved or FSF Free/Libre licenses are acceptable for code. Creative-Commons-like licenses for documentation may not include non-commercial or 'no derivative' clauses."* GPL-3.0, Apache-2.0 and CC BY-SA 4.0 all satisfy this. **D1 is compatible with STA; the problem is maturity, not licensing.**

**3.3. Horizon Europe — Türkiye is associated, but the instrument does not fit this scale.**

**The decisive fact is verified: Türkiye is fully associated to Horizon Europe (2021–2027).** The European Commission's official country page states: *"Türkiye became fully associated member to Horizon Europe in January 2021."* Association means entities participate *"on equal terms with entities of EU countries"*, with the same rights and obligations.

**The main value of this fact is not a Horizon application** — it is the knock-on effect: NLnet's priority criterion (§3.1) links directly to this list. **Türkiye's associated status places OZERK in NLnet's priority group.** That is the single most valuable fact in this document.

As for applying directly: most calls require *"at least 3 partner organisations from 3 different EU or associated countries"*; whether natural persons may be beneficiaries is **not stated explicitly on the REA page → to be verified**. **EIC Accelerator** (grant up to €2.5M; 2026 budgets €414M Open and €220M Challenges) requires an incorporated SME and TRL 6–8 — OZERK is not eligible. **ERC Starting Grant** requires a PhD (defended 1 January 2019 – 31 December 2023 for the 2026 call) and a host institution. On IP: results are owned by the beneficiary that generates them; open science is mandatory ("as open as possible, as closed as necessary") with a **CC BY** obligation for peer-reviewed publications, while a general obligation to open-source software **could not be verified → to be verified**. On the successor programme: the Commission tabled its proposal on 16 July 2025 ("Horizon Europe (2028–2034)", proposed €175 billion within a €409 billion European Competitiveness Fund) — **a proposal only**; negotiations are ongoing and nothing can be planned on it.

**3.4. TÜBİTAK — everything requires a legal entity or an academic post; the single exception is conditional.**

**1507 (SME R&D Start-up):** active, 2026-2 call open; **requires an SME-scale capital company established in Türkiye** — an individual cannot apply; 75% non-refundable; **project budget ceiling 3,000,000 TL**; max 18 months; two calls a year. **1501 (Industrial R&D):** active, capital company required, 75% fixed, "no budget limit" per the English page, max 36 months. **1512 BiGG:** active but restructured — requires enrolment in or recent graduation from a higher-education programme, and **founding a company at Stage 2**; the **support amount and the call cycle are not stated on the official 1512 page → to be verified**. **1812 BiGG Investment:** this is **equity, not a grant** — the 2026-1 pre-seed call invests **1,350,000 TL for a 3% stake**, with up to a further 1,350,000 TL follow-on; maximum 5% at Stage 2 and 10% at Stage 3. **1002 (Rapid Support):** rolling, but **requires a university or research-institute post**; ceiling **150,000 TL per year** as of 1 February 2026. **2244 (Industrial PhD):** the applicant is the university, not an individual — not relevant.

**The hardest finding: no TÜBİTAK support programme dedicated to open source software was found on official pages.**

The only realistic entry point is **1512/1812 BiGG**, conditional on (a) university enrolment or a recent degree, (b) founding a company at Stage 2, and (c) ceding **3–5% equity** under 1812. That third condition deserves separate weight: a public fund holding shares in the founder's company creates direct tension with GOVERNANCE.md §3's sunset commitment and manifesto §19.2, because transferring assets to an independent body later stops being the founder's unilateral decision. **This is the concrete form of the trap described in §7.**

**To be verified (critical):** the intellectual-property and licensing provisions of the 1512/1812 implementation principles could not be read (the PDF text could not be extracted). For an open source project this is decisive: **is there any restriction on publishing the funded output as open source?** The question must be answered *before* any application.

**3.5. KOSGEB — company first, support second.**

KOSGEB's entrepreneurship supports were restructured: the former "Geleneksel Girişimci Destek Programı" now sits under repealed supports, and the current instrument is the **Girişimci Destek Programı (GDP)**. **Business Establishment Support:** 10,000 TL for a sole proprietorship, 20,000 TL for a capital company, plus 10,000 TL for young/female/disabled/veteran/martyr's-relative entrepreneurs, plus personnel support; 100% non-refundable; **the enterprise must be 0–1 years old — i.e. the company is founded first**; rolling applications. **Business Development Support:** ceiling **1,500,000 TL** (+150,000 TL), **80% and repayable** — a loan, not a grant; enterprise aged 0–3 years; periodic calls. The separate **R&D, Product Development and Innovation Programme** (ceiling 1,100,000 TL, raisable to 6,000,000 TL) uses the wording "enterprises/entrepreneurs", so whether a pre-company individual may apply is **unclear → to be verified**; it also does not appear in the current active-programme index, so **whether it is still in force must be verified.**

Every verified KOSGEB instrument is tied to an enterprise registered and active in the KOSGEB database. **KOSGEB does not fund a natural person with no registered business.** KOSGEB's IP/open-source provisions could not be found on accessible pages → **to be verified**.

**3.6. Community funding — receiving money in Türkiye is itself the constraint.**

The finding here is harsher than expected: **the problem is not raising donations but getting them into Türkiye.** **Stripe:** Türkiye is not on the list of countries where accounts can be created, and cross-border payouts are limited to *"the United States, United Kingdom, EEA, Canada, and Switzerland"*. **PayPal:** ceased operations in Türkiye in **June 2016** — *"PayPal's customers in Türkiye cannot send or receive money."* **Wise:** a Türkiye-resident cannot hold or receive into a Wise account, but others **can** send TRY into a Turkish bank account via Wise — closed as a wallet, open as a rail.

| Channel | Can a Türkiye resident be paid? | Rail | Cut |
|---|---|---|---|
| **NLnet grant** | **Yes** | **Direct EUR bank wire** | **0%** |
| **GitHub Sponsors** | **Yes — Türkiye is officially listed** | Stripe Connect **or** a fiscal host | 0% from personal sponsors; up to 6% from organisations |
| **Open Collective + Open Source Collective** | **Yes (inferred)** | Host sends via **Wise to a Turkish IBAN** | 10% OSC; 8–10% OC Europe |
| **Patreon** | **Yes** | **Payoneer** bank transfer, USD→TRY | 10% platform + processing + 2.5% FX |
| **Polar** | **Yes — Türkiye listed** | Stripe Connect Express, Polar as merchant of record | 5% + 50¢ on the free tier |
| **Liberapay** | **No** | Stripe + PayPal | — |
| **Buy Me a Coffee** | **No** | Stripe Express | — |
| **Ko-fi** | **Effectively no (inferred)** | Stripe or PayPal only | — |
| **Software Freedom Conservancy** | **Unverified** | Not documented | 10% |

Two caveats are load-bearing: GitHub lists Türkiye as supported while Stripe does not, and **how Turkish payouts actually execute is undocumented → to be verified** (the fiscal-host route is safer, and it can **only** be chosen at signup); and "Wise to a Turkish IBAN works" for Open Source Collective is an **inference from two official sources, not an OSC statement → to be verified**.

> **There is a tax and regulatory dimension, and this document does not resolve it.** Receiving income from abroad as an individual in Türkiye carries income-tax, foreign-exchange and declaration implications, and several platforms require a **W-8BEN**. Whether money is characterised as a donation, self-employment income or a grant can change the outcome, and that characterisation can depend on the rail chosen. **A certified public accountant must be consulted before opening any channel** — preferably before choosing between them.

**3.7. Secondary sources — one open and important, most closed.**

**Open Technology Fund (OTF, USA) — open, individuals eligible, but its terms collide with §5.2.** OTF's 2025 funding crisis is documented on its own site: on 21 March 2025 it sued USAGM and OMB over the 15 March 2025 termination of its grant. **The outcome of that litigation could not be verified → to be verified.** The organisation is operating today: the application portal is live and 2026 calls have been published. The **Internet Freedom Fund** is **open on a rolling basis**, awards run **$10,000–$900,000** (*"Ideal applicants seek funding between $50,000 and $200,000"*), and eligibility is explicit: *"Individuals or organizations (for-profit or nonprofit) of all ages irrespective of nationality, creed, or sex are eligible to apply"*, with OFAC sanctions as the only geographic bar. The **FOSS Sustainability Fund** is **closed** (*"Not currently accepting applications"*); the **Information Controls Research Program** is open 27 July – 7 September 2026 ($7,000/month) but funds censorship *research*, not OS development.

The amounts fit and individuals may apply. **This RFC nevertheless does not propose OTF as the priority door**, for contractual rather than ideological reasons: OTF states *"we do not provide grants... Rather, OTF administers deliverable-based contracts"*; its solicitation text includes an IP clause — *"all Work Product produced under the contract, if awarded, will be the sole property of OTF"* — which **collides directly with §5.2/6**; and a publicity clause — *"Applicants shall not issue, or permit to be issued... publicity in any form respecting the work hereunder... unless such publicity is first approved in writing by OTF"* — which **collides directly with §5.2/7**. Its congressional remit (22 U.S.C. §309A) includes maintaining *"the technological advantage of the United States Government over authoritarian governments"* — the sharpest form of the positioning tension in §5.3. **Recommendation:** OTF is not ruled out, but an application is made only after verifying whether those clauses actually appear in the relevant contract and whether a text that does not violate §5.2 can be negotiated.

**Prototype Fund (Germany) — not eligible, and the reason is clear.** The programme is alive (hosted by Open Knowledge Foundation Deutschland e.V., funded by the BMFTR) and generous: **up to €47,500 over six months for individuals** (€79,167 over ten months with the second stage); the next window is **1 October – 30 November 2026**. But: *"As an individual developer, you are a resident of Germany, self-employed, or a freelancer and pay your taxes here"*, and the team exception reaches only **EU-resident** members. **An applicant residing in Türkiye is not eligible.** Recorded here so it is not attempted.

**FUTO — small but reachable, and its principles align.** Applications are open by email only (`grantapps@futo.org`); no form, no deadline. Legendary Grants are *"generally reserved for established entities we trust"*; **microgrants are $1,000–$5,000**. Expectations of funded projects overlap strikingly with the manifesto: *"remain fiercely independent"*, *"'The users are our product' revenue models are strictly prohibited"*, *"expected to be open source or develop a plan to eventually become so."* **No official page requires adopting FUTO's own Source First licence** — the condition is being open source, not a specific licence.

**Closed — recording this saves time:** **Mozilla** — MOSS states *"the MOSS program is on indefinite hiatus and is not currently accepting applications"*; the Technology Fund's pages redirect and its last cohort was 2024; the grantmaking page lists no open calls; Fellowship 2026 is closed and Track I's country list does not include Türkiye. **Internet Society Foundation** — most programmes require an organisation's own bank account and 501(c)(3)-equivalent registration; 2026 windows have closed. **Ford Foundation / Digital Infrastructure Insights** — *"We are not soliciting grant proposals at this time"*, and it only ever funded research. **GNOME Foundation, KDE e.V., Linux Foundation, Alpha-Omega** — no open grant programme for outside projects; LFX Mentorship pays mentees, not projects.

**Contributor capacity — people, not money (and sometimes a cost):** **Google Summer of Code** requires a mentoring organisation to be *"an active open source project with a solid community that has already released software under an OSI-approved license"* — **OZERK does not meet that bar today**; the org window is typically January (19 January – 3 February in 2026; **2027 dates not yet published → to be verified**), and the founder cannot be a contributor to their own project. **Outreachy is an expense, not income**: communities must donate at least **$8,000 per intern**; the next deadline is 11 September 2026.

**3.8. Institutional and public pilots — not revenue, but tension.** Manifesto §15 lists "public and institutional projects" as a revenue item, and there is a concrete rationale in Türkiye: the regime for transferring personal data abroad under KVKK (Law 6698) was amended by Law 7499 (Official Gazette 12 March 2024; the Article 9 amendment in force 1 June 2024), introducing standard contractual clauses and binding corporate rules, with the implementing regulation published 10 July 2024. **But this is not a Phase 0–2 revenue source and must not be presented as one:** there is no platform to pilot. Discussing institutional pilots before D3 would violate manifesto §24. The tension must also be recorded: an institution's own requirements (device management, remote control, logging) may collide with the red lines; a single large customer can end up setting the roadmap; and the "independent, user-sovereign" position weakens in the shadow of an institutional customer. **Enterprise device management is a legitimate revenue item in the manifesto, but the institution's authority over the device must be visible to the user** (red lines 4 and 15). That is a non-negotiable clause in any pilot contract. Institutional and public pilots are therefore positioned here as **post-Phase 5**, and the refusal list in §5 applies to them unchanged.

**3.9. Summary.** NLnet (opening 3 September 2026, deadline 3 November 2026; individuals, no entity, priority tier, €5–50k) is the **first target**. FUTO microgrants ($1–5k, by email) are a low-cost second attempt. OTF is **conditional** on its IP and publicity clauses. Sovereign Tech Fund is **not a fit** (prototype and user-facing exclusions); its Fellowship is closed and its bar unmet. Prototype Fund is **not eligible** (German residency). Horizon Europe needs a consortium. TÜBİTAK 1507/1501 and all of KOSGEB need a company; TÜBİTAK 1002 needs an academic post; TÜBİTAK 1812 costs equity. GitHub Sponsors and Open Collective are usable channels; Liberapay, Buy Me a Coffee and Ko-fi are not. Mozilla, ISOC and Ford are closed. GSoC and Outreachy are capacity, not cash — and Outreachy costs money.

#### 4. Splitting into fundable units

**Why not one application.** (1) **Scale mismatch:** all of OZERK is 19–34 person-months; NLnet's first-grant ceiling is €50k. (2) **Assessability:** "I will build a mobile operating system", from a one-person project with no product, cannot be assessed; "per-application network enforcement for Flatpak applications, and the portal proposal for it" can. (3) **Independent value:** most of the packages below survive even if OZERK fails — which is both the strength of the application and the only honest framing under manifesto §24.

**Binding rule — no double submission.** The Sovereign Tech Agency excludes projects already publicly funded for the same activities (§3.2), and submitting the same work to two funders is wrong regardless. Packages are therefore defined **disjointly**, each goes to only one funder, and which package went where is recorded in `FUNDING.md` (§6).

| # | Package | Person-months | Suitable funder | Independent value |
|---|---|---|---|---|
| **P1** | **Guard network enforcement layer** ([RFC-0005](0005-guard-ag-modeli.md)): per-app network namespace + `pasta` + system-controlled resolver + resolver-anchored nftables set; the E1 battery/latency measurement; works around the `bwrap` invocation **without modifying Flatpak** | 4–7 | **NLnet** (Restack / CodeSupply) | Works on any Flatpak-based system; answers the open request in `xdg-desktop-portal#1166` |
| **P2** | **OZERK App manifest standard and validator** ([RFC-0003](0003-paket-formati.md)): network profile and telemetry declaration as a Flatpak superset; CLI validator; schema and docs; measuring whether `[X-OZERK*]` survives the toolchain | 2–4 | **NLnet** (as standards work) | It is a **standard** proposal; even unadopted, the declaration model contributes |
| **P3** | **Missing upstream portals: Contacts and Calendar**: portal specification proposal + `xdg-desktop-portal` backend + data-provider side. On Linux today there is **no** "selected contacts" level; the only control is granting or withholding a D-Bus name wholesale | 3–6 | **NLnet** — squarely its target | **Highest independent value.** If accepted it benefits the whole desktop and mobile Linux ecosystem; its value does not depend on OZERK at all |
| **P4** | **Push and suspend reconciliation** (A8, UnifiedPush): wake windows, modem wakeup, a measured battery/latency table | 3–5 (+hardware) | **NLnet** | An unsolved problem for all of mobile Linux |
| **P5** | **Accessibility**: inventory of accessibility on mobile Linux (Phosh/GNOME) and selected improvements | 2–4 | **NLnet** — Restack **requires WCAG compliance**, so accessibility is a compliance item here, not overhead | Benefits the whole ecosystem |
| **P6** | **Update-architecture contributions** ([RFC-0002](0002-taban-dagitim.md) §10.3): A/B updates and automatic rollback from a broken update | 2–4 | NLnet — **but check for overlap first** | postmarketOS's immutable-image + A/B OTA prototype **has already been funded under NGI Zero**; resubmitting the same work would be wrong |

**Ordering: P3 first, P1 second.** This is counter-intuitive — Guard is the distinctive component — and the reasons are: (a) **assessing P3 does not require looking at OZERK**; the gap is concrete, narrow and verifiable even if the applicant is unknown, which gives the highest acceptance chance for a one-person, product-less project; (b) **P3 converts the upstream-first strategy (D3) into cash** and gives the founder an upstream contribution record — the only realistic route to the Sovereign Tech Fellowship bar seen in §3.2; (c) **P1 is bigger and riskier**: RFC-0005 calls its own E1 experiment "the single largest uncertainty", and an application built on an unmeasured battery cost loses both money and time if rejected.

**Link to the roadmap.** P1 directly finances **D2**. P3, P4 and P5 are **not in** the 12-month plan — they are Phase 3–4 work. This is a trade-off that must not be hidden: **taking funding changes the roadmap's order.** Any such shift is announced under §6 and the roadmap is updated; the roadmap already says progress happens "as resources are found". But the flexibility is bounded: **no funding may reorder the project outside the phase sequence of manifesto §21.**

#### 5. What is promised in return, and what is not

**Can be promised:** specific, measurable technical deliverables published under open licences (D1); upstreaming of changes (D3); visibility and attribution for the funder in the repository, release notes and `FUNDING.md`; contractual reporting and audit; prioritising a component and announcing it publicly (§4.3); the founder's labour and time.

**Refused, regardless of amount or need — binding list.** Each item maps to a red line in manifesto §23:

1. **Sponsorship seeking access to, or sharing of, user data.** (Red line 3.) "Anonymised", "aggregated" or "statistics only" do not change this.
2. **Any backdoor, key-escrow or hidden/mandatory telemetry condition.** (Red lines 4 and 15.) Measurement, if any, must be open, declared and switchable.
3. **Revenue for default placement:** default search provider, default store, default account or preloaded applications. (Red lines 1, 2, 5, 6.)
4. **Exclusivity:** requiring a component to run only on a particular device, infrastructure or store. (Red lines 5 and 13; manifesto §19.2: *"No company may become the sole owner or sole distribution gateway of the platform."*)
5. **Transfer of, or veto over, the trademark.** The OZERK name cannot be the subject of a funding contract (manifesto §20; A7).
6. **Copyright assignment**, or any transfer of rights permitting the licence to be closed later. (D1.)
7. **Publication restrictions:** clauses that prevent, delay or condition publishing results or source code. (Manifesto §24; roadmap §2 "open development".)
8. **Decision authority:** any arrangement granting the funder decision, approval or veto power outside the RFC process. **Money cannot buy a vote.** (GOVERNANCE.md §2.)

This list is written **today**, not when an offer arrives, and that is precisely the point: red lines erode at the moment of greatest need. The best-documented example is Canonical's own sentence when explaining the Amazon results in Ubuntu 12.10's Unity Dash (12 October 2012): *"Keeping the Ubuntu project sustainable requires the development of services that continuously improve the user experience and can at the same time be 'monetized'."* The sentence itself is reasonable — sustainability is a real problem. The outcome was a privacy controversy, a formal ICO complaint in 2013, and online Dash results **disabled by default in Ubuntu 16.04**. The lesson is not that Canonical acted in bad faith; it is that **sustainability pressure is where principles erode.**

**The tension of public funding, and the Pardus lesson.** Public funding — national or foreign — is not refused here. But it carries two tensions. The first is **positioning**: a claim to be "independent and user-sovereign" weakens to the extent the project's direction is tied to an institution's priorities; this applies symmetrically to EU, German and US sources. The honest answer is to never hide the source, to diversify, and to ensure **no single fund is required for the project to continue.**

The second is **structural, and its name is Pardus.** Pardus is a national Linux distribution developed by TÜBİTAK. Per its own official history: the project was run by TÜBİTAK UEKAE from 2004 to 2011; **in 2012 the project's objectives were revised and management transferred to ULAKBİM**; **in 2013 it was decided that Pardus would continue as a Debian GNU/Linux-based distribution**; and as of October 2024 it continues under TÜBİTAK BİLGEM YTE. The 2013 shift meant abandoning the original stack (the PiSi package manager and its surroundings) built over many years.

The lesson is **not technical** — moving to a Debian base is a defensible engineering decision, and OZERK's own [RFC-0002](0002-taban-dagitim.md) debates a similar question. The lesson is **structural**:

> **If the project lives inside an institution, its technical direction and continuity change with that institution's priorities. When the institutional home changes, the technical direction can change too — and the community's say in that change is only as strong as the governance structure is independent.**

Three rules follow: **R1** — public funding is taken per project and per deliverable; the project itself is not moved inside an institution. **R2** — no funding contract may create decision authority outside the RFC process. **R3** — the end of funding must not stop the project: every funded work package is split into milestones such that, if funding stops, what remains in the repository is still usable.

**Single-source threshold (proposal).** If in any calendar year a single funding source exceeds **60%** of the project's total cash income, that fact is recorded in `FUNDING.md` as an explicit **risk**, together with a diversification target for the following year. The value is open to debate (Open Question 5); that a threshold **exists** is not.

#### 6. Transparency commitment

Manifesto §24 commits to honesty about product claims. This RFC extends the same commitment to **money**.

**`FUNDING.md`** is kept at the repository root, bilingual and public. Each entry records at minimum: the **source**; the **amount** with currency (the real figure, not a band); the **date/period**; **what it was for** (which work package or milestone); the **conditions**, if any, with a publishable summary of or link to the contract; and the **end date**.

Additional rules:

- **The founder's own out-of-pocket spending is visible too** — device, domain, infrastructure — as a "volunteer labour and founder spending" line. In Phase 0 the first version of `FUNDING.md` will likely consist of that line and **zero external income**. Zero is not a reason not to create the file; zero is information.
- **Refused funding is recorded**, with the reason. The offeror is named only with permission; otherwise the condition is recorded anonymously. This is the RFC process's "decision trail" principle ([RFC-0000](0000-rfc-sureci.md)) applied to money.
- **A confidentiality requirement is a disqualifier.** Funding whose conditions cannot be disclosed publicly **is not accepted.** This applies to accepted funding; confidentiality during an application's evaluation is outside the rule.
- **An annual summary** of income and expenses is published each calendar year. The figures will be small; being small is not a reason not to publish. postmarketOS publishing its own financial reports shows the practice works (§1).
- **Paid work is disclosed.** If anyone — the founder included — is ever paid by the project, who is paid for which work package is disclosed. This is known to affect community dynamics (§2); transparency does not remove the effect but makes it discussable.

> **Note:** GitHub's `.github/FUNDING.yml` does not replace this document; it is only a donate-button configuration. The transparency record is `FUNDING.md`.

`FUNDING.md` is created **before** the first coin arrives (§8, month 1).

#### 7. Legal entity sequence

**There is no legal entity today, and that is the right order.** An empty legal entity creates annual obligations (filings, accounting, possible audit) and opens no door today — because **the best-fitting funder available now (NLnet) does not require one** (§3.1).

**The three Turkish options and their hard facts:** A **foundation (vakıf)** requires, for 2026, a **minimum dedicated asset of 5,000,000 TL** (General Directorate of Foundations; Foundations Council decision of 22.12.2025, no. 819/790) — **out of reach for Phases 0–2**; the manifesto §19.1 "OZERK Foundation" goal is therefore long-term, and need not be a Turkish vakıf. An **association (dernek)** requires **at least seven** real or legal persons (Turkish Civil Code art. 56) — **cannot be formed today**; note that the technical-committee threshold in GOVERNANCE.md §3 (≥3 regular contributors besides the founder) is **not the same** as the association threshold of seven founders. A **single-member limited company** is possible under Turkish Commercial Code art. 573 (*the statutory text could not be retrieved directly from `mevzuat.gov.tr` while writing this document; the article number is corroborated by secondary legal sources → **to be verified against the primary text***; procedure, cost and annual obligations must be discussed with an accountant) — the fastest route for grants and pilot contracts, **and the place where the trap is set.**

**A fourth option, and this document's recommendation: fiscal hosting.** Open Collective's documentation states it plainly: *"Fiscal hosting enables Collectives to transact without needing to legally incorporate."* Open Source Collective and Open Collective Europe host open source projects, and GitHub Sponsors recognises both (§3.6). **This is the cheapest way to receive grants and donations without founding a company, and the one that sets the fewest traps.** The cost is the host fee (8–10%) and the project eligibility bar.

**The trap: assets accumulating in the founder's company.** If the trademark, copyrights, signing keys and domains accumulate in the founder's company, transfer to an independent body later historically happens rarely and late. The named example is **Oracle / OpenOffice.org**: OpenOffice.org passed to Oracle with the Sun acquisition; the community forked it as **LibreOffice** in 2010 and founded The Document Foundation; Oracle donated the OpenOffice.org assets to the Apache Software Foundation only in **June 2011** — that is, the transfer came **after** the community had already left. The Document Foundation's statement of 1 June 2011 welcomed the prospect of reunification while noting differences in licensing, membership and norms. The two projects never reunited. **The lesson: if transfer is postponed with "we'll do it later", by the time it happens there may be no community left to transfer to.** Türkiye adds a sharpener: **TÜBİTAK 1812 BiGG takes 3–5% equity** in the company that must be founded (§3.4).

**Proposed sequence.** **Stage A (today → first grant):** no legal entity; pursue grants open to individuals (NLnet) and individually receivable community funding. **Stage B (first opportunity requiring an entity):** **try fiscal hosting first**; only if that is impossible and the funder genuinely requires a company is a company formed — and only with the safeguards below written down **at the same time**. **Stage C (once a community exists):** an association (≥7 founders) or the umbrella of an existing international foundation, coordinated with the transition to a technical committee under GOVERNANCE.md §3. **Stage D (long term):** the OZERK Foundation (manifesto §19.1).

**Safeguards — binding from today.** **S1 — Trademark:** whichever entity registers the OZERK mark holds it under a **written commitment** to transfer it to the Foundation once that exists; no commercial company may use it exclusively (manifesto §19.2, §20). **S2 — Signing keys:** repository signing keys may never sit under the control of a single commercial company; today they are with the founder, this is stated openly, and the transfer of key management once a technical committee exists is governed by **a separate RFC**. **S3 — Copyright:** **no copyright assignment** is requested from contributors; copyright stays with them. This structurally impedes a single owner from closing the licence later — the technical form of the Oracle lesson. **S4 — Domains and accounts:** project domains and repository/organisation accounts should be held with redundancy such that at least two people can access them. **This condition is not met today**, and that is a recorded risk (Open Question 8). **S5 — Transfer timetable:** if an entity is created, the goal of transferring assets to the Foundation is published alongside its formation, and **every annual report states the transfer status.** "Not yet transferred" is also an answer, and repeating it every year is a warning.

#### 8. Concrete next steps — the coming three months

Sized for a one-person project. **Writing an application is itself a cost:** a good grant application takes 3–10 days of effort, taken directly out of the roadmap. Therefore at most **3–4 applications** per 12 months, and at most **one** in these three months.

| When | Step | Why now |
|---|---|---|
| **Month 1 (Aug–Sep 2026)** | **Create `FUNDING.md`** — with zero income, the founder-spending line, and the §6 rules | The rule must exist before the first coin |
| **Month 1** | **Read NLnet's calls when they open on 3 September 2026** and record which funds opened, their scope text and deadlines | This is the only way to close the "to be verified" item in §3.1 |
| **Month 1** | **Technical groundwork for P3 (Contacts/Calendar portal):** search the `xdg-desktop-portal` "New Portals" discussion category for prior art; if none, open a discussion | An application for something never raised upstream is weak — and this step has value **even if no funding follows** |
| **Month 1–2** | **Meet an accountant — information gathering only.** Questions: how a grant/donation received from abroad by an individual is characterised; the effect of W-8BEN; at what threshold an entity becomes necessary | Must be asked **before** opening any channel (§3.6) |
| **Month 2 (Oct 2026)** | **Write one application: P3.** Milestones split per R3 (usable output even if funding stops). The application text is kept openly in the repository | The deadline is **3 November 2026 12:00 CEST**; writing in October leaves a buffer |
| **Month 2** | **Research fiscal hosting** (Open Source Collective / Open Collective Europe eligibility bars and fees) — no application, just record the thresholds | §7's fourth option must be tested for reality |
| **Month 3 (Nov 2026)** | **Submit before 3 November 12:00 CEST.** Then consider setting up **GitHub Sponsors**; if set up, the fiscal-host option must be decided **at signup** (changing it later requires support) | This is the one concrete calendar window |
| **Month 3** | **A low-cost second attempt: a short email to FUTO** (`grantapps@futo.org`). No form, no deadline; cost is about an hour. Expect the microgrant band ($1–5k) and a high chance of rejection — so **no plan depends on it** | Near-zero cost, aligned principles (§3.7) |
| **Month 3** | Review the roadmap; compare assumption V4 (10–15 h/week) against reality and **publish the deviation** | If V4 is never measured, all of §2 collapses |

**Deliberately not done in these three months:** no company is formed (§7); no application to TÜBİTAK or KOSGEB — all require an entity or an academic post (§3.4, §3.5); no application to the Sovereign Tech Agency — the prototype and user-facing exclusions rule it out today (§3.2); no submitting the same work package to a second funder (§4.1); no crowdfunding campaign — there is no product.

### Alternatives

**A1 — Seek no external funding; proceed purely on volunteer labour.** Maximum independence, zero conditions, zero administration. **This alternative is not fully rejected:** scenario (a) in §2 is the baseline and remains the plan in force if no funding arrives. It is rejected only as the *sole* strategy, for the reason in §2: the project's most distinctive component (Guard) does not fit into 12 months. It is also not a decision but the absence of one — funding calendars do not wait.

**A2 — Form a company and seek venture capital.** Rejected: there is no product; red line 3 closes the data revenue model; investors expect an exit, and that expectation conflicts directly with manifesto §19.2. Reconsiderable for the Phase 6 commercial device, not for Phases 0–5.

**A3 — Enter the TÜBİTAK 1812 BiGG track.** The only TÜBİTAK door an individual in Türkiye can enter, and it is real money. Rejected because the mandatory company formation plus **3–5% equity transfer** sets the trap in §7 and weakens the sunset commitment, and because the effect of its implementation principles on open source licensing **could not be verified.** Not closed permanently: it may be reopened **only if** the §7 safeguards can be written into the contract and the licensing terms are verified.

**A4 — Pre-product crowdfunding or device pre-sales.** Rejected under manifesto §24: pre-selling with no product is selling a feature that does not exist.

**A5 — Chase one large fund (Horizon Europe).** Rejected: the consortium requirement and administrative load would consume a one-person project's engineering time (§3.3). Joining later as a **partner** remains open.

**A6 — Depend on a single corporate sponsor.** Principled corporate sponsorship is possible; what is rejected is **single-source dependency** (§5, the 60% threshold).

**A7 — Defer the decision.** Rejected: the NLnet window is 3 September – 3 November 2026. Deferral costs a full cycle.

### Open Questions

1. **Which funds open on 3 September 2026, and with what scope?** NLnet says only "several funds". Until the Restack, CodeSupply and ELFA call texts are read, which of P1–P5 fits where cannot be settled. **This blocks all of §8.**
2. **Does NLnet explicitly accept CC BY-SA 4.0 for documents?** GPL-3.0 and Apache-2.0 are indisputably recognised free licences, but NLnet never enumerates licences by name.
3. **Do the TÜBİTAK 1512/1812 implementation principles restrict open-source publication of funded output?** A3 cannot be reopened until this is answered.
4. **By what mechanism does a GitHub Sponsors payout to Türkiye actually execute?** GitHub lists Türkiye as supported; Stripe does not. Opening the channel before resolving this risks being unable to receive the money.
5. **Should the single-source threshold be 60%?** That a threshold exists is settled; its value is not. A very low threshold is meaningless early (the first grant will be 100% of income); a very high one loses its warning function. Perhaps it should apply only from the second grant onward.
6. **How far may funding reorder the roadmap?** §4 says it may not leave the phase sequence of manifesto §21 — but how much deferral of D1/D2/D3 is acceptable?
7. **Is fiscal hosting actually available to OZERK?** Open Source Collective speaks of thresholds like a "vibrant community" and steers multi-project individuals toward GitHub Sponsors. If OZERK does not clear that bar, Stage B of §7 weakens.
8. **How is redundancy for domains and accounts (S4) achieved today?** In a one-person project, how is "at least two people" satisfied when there is no second person? Should a recovery mechanism (e.g. sealed recovery material held by a trusted third party) be defined?
9. **How should the founder funding their own labour be framed ethically?** Scenario (b) means, in effect, a salary for the founder. postmarketOS handles this with caps (weekly floor/ceiling, an hourly-rate cap) and transparency. What are OZERK's equivalent rules, and do they belong in this RFC or a separate one?
10. **Does recording refused offers in `FUNDING.md` deter offers?** This tension between transparency and receiving offers has not been measured.
11. **When will the transition plan to product revenue after Phase 5 be written?** This RFC covers only the pre-revenue period; which of manifesto §15's items comes first belongs to a separate RFC.

---

## Kaynaklar / Sources

Aşağıdaki kaynakların tamamı **17 Ağustos 2026** tarihinde kontrol edilmiştir. Bir iddianın kaynağı burada yoksa, o iddia belgede "doğrulanmalı" olarak işaretlidir.

*All sources below were checked on **17 August 2026**. If a claim has no source here, it is marked "to be verified" in the document.*

> **Yöntem notu / method note.** Her fon iddiası **programın kendi resmî sayfasından** okunmuştur; haber siteleri ve ikinci el özetler kaynak olarak kullanılmamıştır. Bir sayfa erişilemediğinde (403, sertifika hatası, metni çıkarılamayan PDF) bu durum belgede açıkça yazılmış ve iddia **doğrulanmalı** olarak işaretlenmiştir. Tutar, son tarih ve uygunluk şartlarında **hiçbir sayı tahmin edilmemiştir.** *Every funding claim was read from the programme's own official page; news sites and second-hand summaries were not used as sources. Where a page could not be accessed, this is stated and the claim is marked "to be verified". **No amount, deadline or eligibility condition was guessed.***

**NLnet / NGI Zero / Open Internet Stack**

- Başvuru durumu ve 3 Eylül 2026 / 3 Kasım 2026 takvimi / application status and calendar — <https://nlnet.nl/propose/>
- NGI'den Open Internet Stack'e geçiş duyurusu / transition announcement (12.06.2026) — <https://nlnet.nl/news/2026/20260612-NGIZero-stocktaking.html>
- Yeni son tarih dizisi / new deadline sequence (03.08.2026) — <https://nlnet.nl/news/2026/20260803-phaseshift.html>
- Restack programı, başvuru kılavuzu, uygunluk ve SSS / programme, guide for applicants, eligibility, FAQ — <https://nlnet.nl/restack/>, <https://nlnet.nl/restack/guideforapplicants/>, <https://nlnet.nl/restack/eligibility/>, <https://nlnet.nl/restack/faq/>
- Restack duyurusu / announcement (FOSDEM 2026) — <https://nlnet.nl/news/2026/20260131-restack.html>
- CodeSupply, ELFA — <https://nlnet.nl/codesupply/>, <https://nlnet.nl/ELFA/>
- NGI Zero Commons Fund (son çağrı 01.06.2026 / final call), uygunluk — <https://nlnet.nl/commonsfund/>, <https://nlnet.nl/commonsfund/eligibility/>
- NGI Zero Core (son çağrı 01.10.2024), NGI Zero Entrust — <https://nlnet.nl/core/>, <https://nlnet.nl/entrust/>
- Genel fon koşulları, birey uygunluğu, kilometre taşı ödemesi, lisans şartı / general terms, individual eligibility, milestone payments, licence requirement — <https://nlnet.nl/funding.html>
- Örnek mutabakat metni (bireye doğrudan havale) / sample MoU (direct wire to an individual) — <https://nlnet.nl/foundation/request/sample_MoU.pdf>
- Fonlanmış emsal projeler / funded precedents: UnifiedPush (NGI Zero Core, 2024-12) — <https://nlnet.nl/project/UnifiedPush-LinuxMobile/>; postmarketOS — <https://nlnet.nl/project/postmarketOS/>, <https://nlnet.nl/project/pmOS-25-26/>; phosh-mobile-settings — <https://nlnet.nl/project/MobileSettings/>

**Sovereign Tech Agency (Almanya / Germany)**

- Kurumsal ev, SPRIND bağlılığı, coğrafya SSS / institutional home, SPRIND, geography FAQ — <https://www.sovereign.tech/faq>
- Programlar / programmes — <https://www.sovereign.tech/programs>
- Sovereign Tech Fund: kapsam, 50.000 € tabanı, prototip ve kullanıcı-yüzlü elemeleri, kamu fonu çakışma yasağı, lisans ölçütü / scope, €50k floor, prototype and user-facing exclusions, public-funding exclusion, licence criterion — <https://www.sovereign.tech/programs/fund>
- Fellowship (06.04.2026'da kapandı / closed), serbest çalışan dünya çapında / freelance worldwide — <https://www.sovereign.tech/programs/fellowship>
- Sovereign Tech Resilience ölçütleri / criteria — <https://www.sovereign.tech/programs/bug-resilience/criteria>

**Avrupa Birliği / European Union**

- Türkiye'nin Horizon Europe asosiyasyonu / Türkiye's association — <https://research-and-innovation.ec.europa.eu/strategy/strategy-research-and-innovation/europe-world/international-cooperation/association-horizon-europe/turkiye_en>
- Asosiye ülkeler listesi ve asosiyasyonun anlamı / list of associated countries and what association means — <https://research-and-innovation.ec.europa.eu/strategy/strategy-research-and-innovation/europe-world/international-cooperation/association-horizon-europe_en>
- Katılımcı ülkeler resmî listesi (V4.0, 31.07.2026) / official list of participating countries — <https://ec.europa.eu/info/funding-tenders/opportunities/docs/2021-2027/common/guidance/list-3rd-country-participation_horizon-euratom_en.pdf>
- Kimler başvurabilir; üç ortak / konsorsiyum şartı / who should apply; three-partner rule — <https://rea.ec.europa.eu/horizon-europe-who-should-apply_en>
- Açık bilim yükümlülükleri / open science obligations — <https://rea.ec.europa.eu/open-science_en>
- EIC Accelerator — <https://eic.ec.europa.eu/eic-funding-opportunities/eic-accelerator_en>
- ERC Starting Grant — <https://erc.europa.eu/apply-grant/starting-grant>
- Sonraki çerçeve programı önerisi (16.07.2025) / next framework programme proposal — <https://research-and-innovation.ec.europa.eu/news/all-research-and-innovation-news/horizon-europe-2028-2034-twice-bigger-simpler-faster-and-more-impactful-2025-07-16_en>

**TÜBİTAK**

- 1507 KOBİ Ar-Ge Başlangıç — <https://tubitak.gov.tr/en/funds/industrial/national-support-programs/1507-tubitak-sme-rd-start-support-program>
- 1501 Sanayi Ar-Ge — <https://tubitak.gov.tr/en/funds/industrial/national-support-programs/1501-industrial-rd-projects-grant-programme>
- 1512 Girişimcilik Destek Programı — <https://tubitak.gov.tr/en/funds/sanayi/ulusal-destek-programlari/1512-entrepreneurship-support-program>
- 1812 Yatırım Tabanlı Girişimcilik (BiGG Yatırım) ve 2026-1 Ön Tohum çağrısı / and the 2026-1 pre-seed call — <https://tubitak.gov.tr/en/funds/industrial/national-support-programs/1812-investment-based-entrepreneurship-support-program-bigg-investment>, <https://tubitak.gov.tr/en/announcement/1812-investment-based-entrepreneurship-support-program-2026-1-pre-seed-investment-call-open-applications>
- 1512 uygulama esasları (metni çıkarılamadı / text could not be extracted) — <https://tubitak.gov.tr/tr/node/5967>
- 1002 Hızlı Destek — <https://tubitak.gov.tr/en/funds/academic/national-support-programs/1002-short-term-support-module>
- 2244 Sanayi Doktora — <https://tubitak.gov.tr/en/scholarships/lisansustu/egitim-burs-programlari/2244-industrial-phd-fellowship-program>
- Akademik ulusal destek programları dizini / academic national support programme index — <https://tubitak.gov.tr/en/funds/academic/national-support-programs>

**KOSGEB**

- Destek programları dizini / support programme index — <https://www.kosgeb.gov.tr/site/tr/genel/destekler/3/destek-programlari>
- Girişimci Destek Programı — <https://www.kosgeb.gov.tr/site/tr/genel/destekdetay/1231/girisimci-destek-programi>
- Geleneksel Girişimci Destek Programı (yürürlükten kaldırılan destekler / repealed supports) — <https://www.kosgeb.gov.tr/site/tr/genel/destekdetay/7391/geleneksel-girisimci-destek-programi>
- Ar-Ge, Ür-Ge ve İnovasyon Destek Programı (durumu doğrulanmalı / status to be verified) — <https://www.kosgeb.gov.tr/site/tr/genel/destekdetay/7664/arge-urge-ve-inovasyon-destek-programi>

**Topluluk fonlaması ve ödeme altyapısı / community funding and payment rails**

- GitHub Sponsors: desteklenen bölgeler (Türkiye listede), ücretler / supported regions (Turkey listed), fees — <https://docs.github.com/en/sponsors/getting-started-with-github-sponsors/about-github-sponsors>
- GitHub Sponsors: ikamet ve banka hesabı eşleşmesi / residence and bank account must match — <https://docs.github.com/en/sponsors/receiving-sponsorships-through-github-sponsors/setting-up-github-sponsors-for-your-personal-account>
- GitHub Sponsors: mali sponsorlar, yalnızca kayıt anında seçilir / fiscal hosts, chosen only at signup — <https://docs.github.com/en/sponsors/receiving-sponsorships-through-github-sponsors/using-a-fiscal-host-to-receive-github-sponsors-payouts>
- Stripe: hesap açılabilen ülkeler / supported countries — <https://stripe.com/global>; sınır ötesi ödemeler / cross-border payouts — <https://docs.stripe.com/connect/cross-border-payouts>
- PayPal Türkiye duyurusu (Haziran 2016'dan beri faaliyet yok) / Türkiye notice — <https://www.paypal.com/tr/webapps/mpp/home>
- Wise: Türkiye'deki müşteriler için kısıtlar / restrictions for customers in Türkiye — <https://wise.com/help/articles/18ewShSmFf7tJ7mm2Zp6H7/restrictions-for-customers-based-in-turkiye>; TRY transferleri / TRY transfers — <https://wise.com/help/articles/2932348/try-transfers>
- Open Collective: mali sponsorluk tanımı ve tüzel kişilik gerektirmemesi / fiscal hosting definition — <https://documentation.opencollective.com/fiscal-hosts/fiscal-hosts>; platformun yeni yönetimi (OFiCo / OFiTech) / new stewardship — <https://documentation.opencollective.com/our-organization/about-open-collective>
- Open Collective Foundation'ın kapanışı / OCF dissolution — <https://blog.opencollective.com/open-collective-official-statement-ocf-dissolution/>
- Open Source Collective: %10 host ücreti / host fee — <https://docs.oscollective.org/welcome-and-introduction-to-osc/fees>; ödeme yöntemleri (yalnızca Wise ve sınırlı PayPal) / payout methods — <https://docs.oscollective.org/for-hosted-member-projects/spending-money-and-getting-paid/expense-policies-and-limitations>; proje kabul ölçütleri / project criteria — <https://oscollective.org/projects/>
- Open Collective Europe — <https://opencollective.com/europe>
- Liberapay: alıcı ülke listeleri (Türkiye yok) / recipient country tiers (Turkey absent) — <https://liberapay.com/about/global>; ödeme sağlayıcıları / payment processors — <https://en.liberapay.com/about/payment-processors>
- Patreon: ABD dışı yaratıcılar için ödeme kılavuzu (Türkiye, USD→TRY banka havalesi) / payouts guide for creators outside the US — <https://support.patreon.com/hc/en-us/articles/39694936541965-Payouts-guide-for-creators-outside-of-the-US>
- Polar: desteklenen ülkeler (Türkiye listede) / supported countries — <https://polar.sh/docs/merchant-of-record/supported-countries>
- Buy Me a Coffee: ödeme yapılan ülkeler (Türkiye yok) / supported payout countries — <https://help.buymeacoffee.com/en/articles/6258038-supported-countries-for-payouts-on-buy-me-a-coffee>
- Ko-fi: Stripe/PayPal'a devredilen ülke uygunluğu / country eligibility delegated to Stripe/PayPal — <https://help.ko-fi.com/hc/en-us/articles/360009265834-Can-I-use-Stripe-in-my-country>
- Software Freedom Conservancy: himaye başvurusu ve yüklenici usulü / project application and contractor process — <https://sfconservancy.org/projects/apply/>, <https://handbook.sfconservancy.org/contractors.html>

**İkincil fon kaynakları / secondary funders**

- OTF fonları / funds — <https://www.opentech.fund/funds/>; Internet Freedom Fund — <https://www.opentech.fund/funds/internet-freedom-fund/>; FOSS Sustainability Fund (kapalı / closed) — <https://www.opentech.fund/funds/free-and-open-source-software-sustainability-fund/>
- OTF başvuru kılavuzu (hibe değil sözleşme) / applicant guidebook (contracts, not grants) — <https://docs.opentech.fund/otf-application-guidebook/>
- OTF kongre görevi (22 U.S.C. §309A) ve fon kaynağı / congressional remit and funding source — <https://www.opentech.fund/about/congressional-remit/>, <https://www.opentech.fund/about/about-our-funding/>
- OTF'nin USAGM aleyhine davası (21.03.2025) / lawsuit — <https://www.opentech.fund/news/open-technology-fund-files-lawsuit-to-contest-grant-termination-and-preserve-critical-mission/>
- Prototype Fund: başvuru koşulları (Almanya ikameti) ve SSS (tutarlar) / application formalities (German residency) and FAQ (amounts) — <https://www.prototypefund.de/en/application>, <https://www.prototypefund.de/en/faq>
- FUTO hibeleri (mikro hibe 1.000–5.000 $) / grants — <https://futo.tech/grants/>; fonlanan projelerden beklenenler / pledges — <https://futo.tech/about>
- Mozilla MOSS (süresiz askıda / indefinite hiatus) — <https://www.mozilla.org/en-US/moss/>; Mozilla Foundation hibe sayfası / grantmaking — <https://www.mozillafoundation.org/en/what-we-do/grantmaking/>
- Internet Society Foundation hibe programları / grant programmes — <https://www.isocfoundation.org/grant-programmes/>
- Ford Foundation kritik dijital altyapı araştırması ("not soliciting") — <https://www.fordfoundation.org/campaigns/critical-digital-infrastructure-research/>
- Google Summer of Code mentor kuruluş şartları / mentoring organisation requirements — <https://summerofcode.withgoogle.com/>
- Outreachy topluluk katılım maliyeti (stajyer başına 8.000 $) / community sponsorship cost — <https://www.outreachy.org/>

**Emsaller ve dersler / precedents and lessons**

- postmarketOS 2025 mali raporu ve 2026 bütçesi / 2025 financial report and 2026 budget (11.03.2026) — <https://postmarketos.org/blog/2026/03/11/pmOS-budget-and-financial-update/>
- postmarketOS mali şeffaflık sayfası ve Open Collective / financials and Open Collective — <https://postmarketos.org/financials/>, <https://opencollective.com/postmarketos>
- postmarketOS katkıcı ödeme planı (pmCR 0004) / contributor compensation plan — <https://docs.postmarketos.org/pmcr/main/0004-payment-plan.html>
- Pardus resmî tarihçesi (2012 ULAKBİM'e devir, 2013 Debian tabanı kararı) / official history — <https://pardus.org.tr/en/pardus-history/>
- The Document Foundation'ın Oracle'ın Apache'ye bağışı hakkındaki açıklaması (01.06.2011) / statement on Oracle's donation — <https://blog.documentfoundation.org/blog/2011/06/01/statement-about-oracles-move-to-donate-openoffice-org-assets-to-the-apache-foundation/>
- Canonical'ın Unity Dash / Amazon açıklaması (12.10.2012) / Canonical's statement — <https://ubuntu.com/blog/searching-in-the-dash-in-ubuntu-12-10-an-update>

**Mevzuat ve tüzel kişilik / legislation and legal entities**

- Türk Medeni Kanunu m.56 — dernek için en az yedi kişi / at least seven persons for an association — <https://www.mevzuat.gov.tr/mevzuatmetin/1.5.4721.pdf>
- Türk Ticaret Kanunu (m.573 vd.; birincil metin bu belgenin yazımı sırasında alınamadı / primary text could not be retrieved) — <https://www.mevzuat.gov.tr/mevzuat?MevzuatNo=6102&MevzuatTur=1&MevzuatTertip=5>
- Vakıflar Genel Müdürlüğü — 2026 yılı asgari kuruluş mal varlığı 5.000.000 TL (Vakıflar Meclisi, 22.12.2025, 819/790) / minimum foundation asset for 2026 — <https://www.vgm.gov.tr/duyurular/2026-yili-icin-yeni-vakiflarin-kurulusunda-amaclarina>, <https://www.vgm.gov.tr/vakif-islemleri/vakif-nasil-kurulur-/asgari-kurulus-mal-varligi>
- KVKK — kişisel verilerin yurt dışına aktarılması (7499 sayılı Kanun değişikliği ve ikincil mevzuat) / transfer of personal data abroad — <https://www.kvkk.gov.tr/Icerik/2053/Yurtdisina-Aktarim>

**Upstream boşluklar / upstream gaps**

- `xdg-desktop-portal` yeni portal önerileri tartışma kategorisi (Contacts/Calendar portalı için mecra) / "New Portals" discussion category — <https://github.com/flatpak/xdg-desktop-portal/discussions/categories/new-portals>
- Ağ izni portalı tartışması / network permission portal discussion — <https://github.com/flatpak/xdg-desktop-portal/discussions/1166>
