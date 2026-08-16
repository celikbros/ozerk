# OZERK

**Türkçe** | [English](#english)

> **Telefon senin. Veri senin. Karar senin.**

OZERK, Linux tabanlı, açık ve kullanıcı-egemen bir bağımsız mobil platform projesidir. Amacı, insanın günlük mobil ihtiyaçlarını zorunlu hesap, zorunlu mağaza, gizli telemetri ve kapalı platform bağımlılığı olmadan; açık standartlarla, özgür yazılımla ve web teknolojileriyle karşılayan bir mobil ekosistem kurmaktır. OZERK sıfırdan icat etmez: postmarketOS/Mobian, Phosh, Flatpak ve portallar, UnifiedPush, Waydroid gibi mevcut özgür yazılım yapıtaşlarına yaslanır ve eksik olan katmanları tanımlar.

Projenin kurucu metni manifestodur ve bu depodaki her kararın ölçüsüdür:

> 📖 **[OZERK Proje Manifestosu](docs/OZERK_Proje_Manifestosu.md)** — Türkçe (normatif metin)
> 📖 **[OZERK Project Manifesto](docs/OZERK_Project_Manifesto.en.md)** — English translation

## Mevcut durum

> **Aşama 0 — Kurucu standartlar.**
> Bu proje erken aşamadadır; **henüz kullanılabilir bir ürün veya platform kodu yoktur.**
> Şu anda kurucu belgeler ve standartlar (manifesto, yönetişim, RFC süreci, lisanslama) üzerinde çalışılmaktadır.
> İlk görünür hedef: `ozerk` geliştirici CLI iskeletinin erken bir demosu.

## Bileşenler

Manifesto §2'de tanımlanan, birbirini tamamlayan açık bileşenler:

| Bileşen | Kısa tanım |
|---|---|
| **OZERK OS** | Linux tabanlı mobil işletim sistemi |
| **OZERK Shell** | Telefon ve yakınsak masaüstü kullanıcı arayüzü |
| **OZERK Guard** | İzin, ağ, gizlilik ve uygulama denetim sistemi |
| **OZERK App** | Açık uygulama paketi ve yetki tanımlama standardı |
| **OZERK Store** | Uygulama keşif ve yükleme arayüzü |
| **OZERK Repo** | Federatif, kriptografik olarak doğrulanan yazılım depoları |
| **OZERK Push** | Sağlayıcıdan bağımsız bildirim altyapısı |
| **OZERK Bridge** | Gerektiğinde kullanılan izole Android uyumluluk ortamı |
| **OZERK SDK** | Native, web ve WebAssembly uygulamaları için geliştirici araçları |
| **OZERK Foundation** | Platform ilkelerini ve açık standartları koruyan bağımsız yapı |

Bu bileşenlerin hiçbiri henüz kodlanmamıştır; bu liste hedef mimariyi tanımlar.

## Depo haritası

```
docs/       Kurucu belgeler (manifesto, yol haritası, standartlar)
rfc/        Açık karar süreci: RFC taslakları ve kabul edilen RFC'ler
sdk/cli/    ozerk geliştirici CLI iskeleti (ilk demo hedefi)
LICENSES/   Kullanılan lisansların tam metinleri
```

Ayrıca:

- [docs/yol-haritasi.md](docs/yol-haritasi.md) — ilk 12 ayın somut planı ve demo kapıları
- [GOVERNANCE.md](GOVERNANCE.md) — kararların bugün nasıl alındığı ve nasıl devredileceği
- [rfc/0001-karar-kaydi.md](rfc/0001-karar-kaydi.md) — alınmış kararlar ve henüz kararlaştırılmamış açık konular

## Nasıl katılırım?

Geliştirme açık yürütülür. Başlamak için:

- [CONTRIBUTING.md](CONTRIBUTING.md) — katkı süreci ve kurallar
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — davranış kuralları
- [rfc/](rfc/) — önemli teknik kararların alındığı açık RFC süreci; yeni öneriler burada taslak olarak açılır

Aşama 0'da en değerli katkılar kod değil, kurucu belgelerin gözden geçirilmesi, RFC tartışmaları ve çevirilerdir.

## Lisanslama

Karma lisans modeli kullanılır; tam metinler [LICENSES/](LICENSES/) dizinindedir.

| Kapsam | Lisans |
|---|---|
| Sistem / OS bileşenleri | [GPL-3.0-or-later](LICENSES/GPL-3.0-or-later.txt) |
| SDK, CLI ve kütüphaneler (örn. `sdk/`) | [Apache-2.0](LICENSES/Apache-2.0.txt) |
| Belgeler (`docs/`, `rfc/` ve kök dizindeki belgeler) | [CC BY-SA 4.0](LICENSES/CC-BY-SA-4.0.txt) |

`CODE_OF_CONDUCT.md` istisnadır: Contributor Covenant v2.1 tabanlıdır ve kendi CC BY 4.0 atıf yükümlülüğünü taşır.

## Dil politikası

Kurucu belgeler iki dillidir: her belge hem Türkçe hem İngilizce içerir ve iki dil içerik olarak eşdeğerdir. İki metin arasında çelişki olursa **Türkçe metin bağlayıcıdır (normatiftir).**

---

## English

*The Turkish text is normative in case of discrepancy.*

> **Your phone. Your data. Your decision.**

OZERK is a Linux-based, open and user-sovereign independent mobile platform project. Its goal is to build a mobile ecosystem that meets everyday mobile needs without mandatory accounts, mandatory stores, hidden telemetry or closed-platform dependency — using open standards, free software and web technologies. OZERK does not reinvent from scratch: it builds on existing free software building blocks such as postmarketOS/Mobian, Phosh, Flatpak and portals, UnifiedPush and Waydroid, and defines the layers that are missing.

The founding document of the project is the manifesto, and it is the measure of every decision in this repository:

> 📖 **[OZERK Proje Manifestosu](docs/OZERK_Proje_Manifestosu.md)** — Turkish (normative text)
> 📖 **[OZERK Project Manifesto](docs/OZERK_Project_Manifesto.en.md)** — English translation

### Current status

> **Phase 0 — Founding standards.**
> This project is at an early stage; **there is no usable product or platform code yet.**
> Current work is on founding documents and standards (manifesto, governance, RFC process, licensing).
> First visible goal: an early demo of the `ozerk` developer CLI skeleton.

### Components

The complementary open components defined in §2 of the manifesto:

| Component | Short description |
|---|---|
| **OZERK OS** | Linux-based mobile operating system |
| **OZERK Shell** | Phone and convergent desktop user interface |
| **OZERK Guard** | Permission, network, privacy and application control system |
| **OZERK App** | Open application packaging and capability declaration standard |
| **OZERK Store** | Application discovery and installation interface |
| **OZERK Repo** | Federated, cryptographically verified software repositories |
| **OZERK Push** | Provider-independent notification infrastructure |
| **OZERK Bridge** | Isolated Android compatibility environment, used when needed |
| **OZERK SDK** | Developer tools for native, web and WebAssembly applications |
| **OZERK Foundation** | Independent body safeguarding platform principles and open standards |

None of these components have been implemented yet; this list defines the target architecture.

### Repository map

```
docs/       Founding documents (manifesto, roadmap, standards)
rfc/        Open decision process: RFC drafts and accepted RFCs
sdk/cli/    ozerk developer CLI skeleton (first demo goal)
LICENSES/   Full texts of the licenses in use
```

Also:

- [docs/yol-haritasi.md](docs/yol-haritasi.md) — the concrete plan and demo gates for the first 12 months
- [GOVERNANCE.md](GOVERNANCE.md) — how decisions are made today and how they will be handed over
- [rfc/0001-karar-kaydi.md](rfc/0001-karar-kaydi.md) — decisions taken and questions still open

### How do I contribute?

Development happens in the open. To get started:

- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution process and rules
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) — code of conduct
- [rfc/](rfc/) — the open RFC process where significant technical decisions are made; new proposals start as drafts here

In Phase 0 the most valuable contributions are not code, but reviews of the founding documents, RFC discussions and translations.

### Licensing

A mixed licensing model is used; full texts are in the [LICENSES/](LICENSES/) directory.

| Scope | License |
|---|---|
| System / OS components | [GPL-3.0-or-later](LICENSES/GPL-3.0-or-later.txt) |
| SDK, CLI and libraries (e.g. `sdk/`) | [Apache-2.0](LICENSES/Apache-2.0.txt) |
| Documents (`docs/`, `rfc/` and the documents in the repository root) | [CC BY-SA 4.0](LICENSES/CC-BY-SA-4.0.txt) |

`CODE_OF_CONDUCT.md` is an exception: it is based on Contributor Covenant v2.1 and carries its own CC BY 4.0 attribution obligation.

### Language policy

Founding documents are bilingual: each document contains both Turkish and English, and the two languages are equivalent in content. In case of discrepancy, **the Turkish text is binding (normative).**

---

**OZERK — Telefon senin. Veri senin. Karar senin.**
