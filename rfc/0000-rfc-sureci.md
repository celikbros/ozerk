# RFC 0000: RFC Süreci

**Türkçe** | [English](#english)

- **Durum:** Kabul
- **Tarih:** 17 Ağustos 2026
- **Yazar:** OZERK kurucusu

## Özet

Bu belge, OZERK projesinde önemli kararların kamuya açık biçimde alınmasını sağlayan hafif bir RFC (Request for Comments) sürecini tanımlar. Karar yetkisinin kimde olduğunu tanımlamaz; o [GOVERNANCE.md](../GOVERNANCE.md)'de tanımlıdır. Bu belge yalnızca kararın hangi yolla önerilip tartışılıp kayda geçirileceğini tanımlar.

## Neden bu süreç

Proje erken aşamadadır ve bugün tek kişi tarafından yürütülmektedir. Buna rağmen RFC süreci ilk günden uygulanır; çünkü amaç tören değil, karar izidir: bir karar neden alındı, hangi alternatifler değerlendirildi, neden reddedildi — bunların yazılı ve kalıcı olması, ileride katılacak katkıcılar için projenin hafızasıdır.

Süreç bilerek hafif tutulmuştur. Hedef bürokrasi değildir; kısa bir belge ve açık bir tartışma yeterlidir. Süreç, katkının önünde engel hâline gelirse düzeltilecek olan süreçtir.

## Ne zaman RFC gerekir

RFC şu konularda gerekir:

- **Mimari kararlar:** ör. uygulama sandbox modeli, repository güven modeli, güncelleme mimarisi.
- **Standartlar:** ör. uygulama manifest biçimi, web uygulama profili, bildirim protokolü.
- **İlke ve yönetişim değişiklikleri:** GOVERNANCE.md değişiklikleri, manifesto tadilleri, lisans politikası değişiklikleri.

RFC gerektirmeyenler: hata düzeltmeleri, küçük uygulama ayrıntıları, belge düzeltmeleri, günlük geliştirme kararları. Bunlar olağan issue ve PR akışıyla yürür. Şüphede kalınırsa önce bir issue açıp sormak yeterlidir.

## Dosya adlandırma

RFC dosyaları `rfc/` dizininde şu biçimde adlandırılır:

```
NNNN-kisa-baslik.md
```

- `NNNN`: dört basamaklı sıra numarası (0001, 0002, ...). PR açılırken bir sonraki boş numara alınır; çakışma olursa birleştirme sırasında güncellenir.
- Başlık: küçük harf, kelimeler tire ile ayrılmış, Türkçe karakter yerine ASCII karşılığı (ör. `0010-uygulama-manifesti.md`). RFC-0002 ile RFC-0009 arası numaralar [RFC-0001](0001-karar-kaydi.md)'deki açık kararlar için ayrılmıştır.

## Durumlar

Bir RFC şu durumlardan birindedir:

| Durum | Anlamı |
| --- | --- |
| Taslak | Yazım aşamasında; PR açılmış olabilir. |
| Tartışma | Kamuya açık tartışmada. |
| Kabul | Karar mekanizması tarafından kabul edildi; yürürlükte. |
| Ret | Reddedildi; gerekçesiyle birlikte depoda kalır. |
| Geri çekildi | Yazar tarafından geri çekildi; kayıt depoda kalır. |

Olağan akış: Taslak → Tartışma → Kabul / Ret / Geri çekildi.

## Süreç

1. Bu belgenin sonundaki şablon kopyalanır, `rfc/NNNN-kisa-baslik.md` dosyası oluşturulur ve bir PR açılır. Durum: Taslak.
2. PR'a bağlı bir issue açılır; tartışma orada yürür. RFC metni tartışmaya göre PR üzerinde güncellenir. Durum: Tartışma.
3. Tartışma süresi katı değildir; konunun ağırlığına göre belirlenir. Erken aşamada günler yeterli olabilir; yönetişim ve manifesto tadillerinde daha uzun süre tanınır.
4. Karar, [GOVERNANCE.md](../GOVERNANCE.md)'deki mekanizmayla verilir: bugün kurucu, ileride teknik komite, uzun vadede Foundation. Karar gerekçesiyle birlikte yazılır.
5. Kabul edilen RFC, durumu "Kabul" yapılarak birleştirilir. Reddedilen RFC de silinmez; durumu "Ret" ve ret gerekçesi eklenerek birleştirilir. Karar izi korunur.
6. Kabul edilmiş bir RFC daha sonra yeni bir RFC ile değiştirilebilir veya yürürlükten kaldırılabilir; eski RFC'ye hangi RFC'nin onu değiştirdiği not düşülür.

## Şablon

Yeni bir RFC başlatmak için aşağıdaki şablonu kopyalayın:

```markdown
# RFC NNNN: Başlık

- **Durum:** Taslak
- **Tarih:** YYYY-AA-GG
- **Yazar(lar):**

## Özet

Bir iki cümleyle: ne öneriliyor?

## Motivasyon

Bu karar neden gerekli? Hangi sorunu çözüyor? Şimdi alınmazsa ne olur?

## Tasarım

Önerinin kendisi. Kapsam, davranış, sınırlar. Gerekliyse örnekler.

## Alternatifler

Değerlendirilen diğer yollar ve neden tercih edilmedikleri.
"Hiçbir şey yapmamak" da bir alternatiftir.

## Açık Sorular

Henüz cevabı olmayan noktalar.
```

---

## English

# RFC 0000: The RFC Process

> The Turkish text is normative in case of discrepancy.

- **Status:** Accepted
- **Date:** 17 August 2026
- **Author:** OZERK founder

### Summary

This document defines a lightweight RFC (Request for Comments) process through which significant decisions in the OZERK project are made in public. It does not define who holds decision authority; that is defined in [GOVERNANCE.md](../GOVERNANCE.md). This document only defines how a decision is proposed, discussed and recorded.

### Why this process

The project is at an early stage and is currently run by a single person. The RFC process applies from day one nonetheless, because the goal is not ceremony but a decision trail: why a decision was made, which alternatives were considered, why they were rejected — having this written and permanent is the project's memory for contributors who join later.

The process is deliberately kept light. Bureaucracy is not the goal; a short document and an open discussion are enough. If the process ever becomes an obstacle to contribution, it is the process that will be fixed.

### When an RFC is required

An RFC is required for:

- **Architectural decisions:** e.g. the application sandbox model, the repository trust model, the update architecture.
- **Standards:** e.g. the application manifest format, the web application profile, the notification protocol.
- **Changes to principles and governance:** changes to GOVERNANCE.md, amendments to the manifesto, changes to licensing policy.

Not requiring an RFC: bug fixes, small implementation details, documentation fixes, day-to-day development decisions. These follow the ordinary issue and PR flow. When in doubt, opening an issue and asking first is enough.

### File naming

RFC files live in the `rfc/` directory and are named as follows:

```
NNNN-kisa-baslik.md
```

- `NNNN`: a four-digit sequence number (0001, 0002, ...). Take the next free number when opening the PR; if it collides, it is updated at merge time.
- Title: lowercase, words separated by hyphens, ASCII equivalents instead of Turkish characters (e.g. `0010-uygulama-manifesti.md`). Numbers RFC-0002 through RFC-0009 are reserved for the open decisions in [RFC-0001](0001-karar-kaydi.md).

### Statuses

An RFC is in one of the following states:

| Status | Meaning |
| --- | --- |
| Draft (Taslak) | Being written; a PR may be open. |
| Discussion (Tartışma) | Under public discussion. |
| Accepted (Kabul) | Accepted by the decision mechanism; in force. |
| Rejected (Ret) | Rejected; kept in the repository together with the rationale. |
| Withdrawn (Geri çekildi) | Withdrawn by the author; the record stays in the repository. |

The usual flow: Draft → Discussion → Accepted / Rejected / Withdrawn.

### Process

1. Copy the template at the end of this document, create `rfc/NNNN-kisa-baslik.md` and open a PR. Status: Draft.
2. Open an issue linked to the PR; discussion takes place there. The RFC text is updated on the PR as the discussion progresses. Status: Discussion.
3. The discussion period is not rigid; it is set according to the weight of the topic. At the early stage, days may be enough; governance changes and manifesto amendments get longer.
4. The decision is made by the mechanism in [GOVERNANCE.md](../GOVERNANCE.md): the founder today, a technical committee later, the Foundation in the long term. The decision is written down together with its rationale.
5. An accepted RFC is merged with its status set to "Accepted". A rejected RFC is not deleted either; it is merged with status "Rejected" and the rejection rationale added. The decision trail is preserved.
6. An accepted RFC may later be superseded or repealed by a new RFC; the old RFC is annotated with which RFC replaced it.

### Template

To start a new RFC, copy the template below:

```markdown
# RFC NNNN: Title

- **Status:** Draft
- **Date:** YYYY-MM-DD
- **Author(s):**

## Summary

In one or two sentences: what is being proposed?

## Motivation

Why is this decision needed? What problem does it solve? What happens if it is not made now?

## Design

The proposal itself. Scope, behavior, limits. Examples where useful.

## Alternatives

Other approaches considered and why they were not chosen.
"Doing nothing" is also an alternative.

## Open Questions

Points that do not have an answer yet.
```
