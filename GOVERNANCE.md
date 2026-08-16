# Yönetişim

**Türkçe** | [English](#english)

**Sürüm 0.1 — 17 Ağustos 2026**

Bu belge, OZERK projesinde kararların bugün nasıl alındığını ve bu yapının zamanla nasıl değişeceğini tanımlar. Kurucu metin [OZERK Proje Manifestosu](docs/OZERK_Proje_Manifestosu.md)'dur; bu belge manifestoyla çelişirse manifesto esas alınır.

## 1. Mevcut durum: kurucu liderliği

OZERK şu anda Aşama 0'dadır: kurucu standartlar yazılmaktadır ve henüz platform kodu yoktur.

Dürüst tespit şudur: proje bugün tek kişi tarafından yürütülmektedir ve bütün nihai kararları kurucu verir.

Bu durum bir ideal olarak değil, gerçeğin tanımı olarak yazılmıştır. Henüz düzenli bir katkıcı topluluğu yoktur; var olmayan bir topluluk adına seçilmiş kurullar ilan etmek gerçeği yansıtmazdı. Yönetişim yapısı, topluluğun gerçek büyüklüğüyle birlikte büyüyecektir.

Kurucu liderliği döneminde dahi geçerli olan sınırlar vardır:

- Önemli kararlar kapalı kapılar ardında değil, kamuya açık RFC süreciyle alınır (bkz. Bölüm 2).
- Manifestonun 23. bölümündeki kırmızı çizgiler kurucu dahil herkes için bağlayıcıdır (bkz. Bölüm 4).
- Kurucu liderliği geçicidir ve bu belge onun bitiş koşullarını taahhüt eder (bkz. Bölüm 3).

## 2. Kararlar nasıl alınır

Önemli kararlar — mimari kararlar, standartlar, ilke ve yönetişim değişiklikleri — kamuya açık RFC belgeleriyle alınır. Süreç [rfc/0000-rfc-sureci.md](rfc/0000-rfc-sureci.md) dosyasında tanımlıdır.

Kurucu, bu kapsama giren bir kararı RFC açmadan ve kamuya açık tartışma olmadan almamayı taahhüt eder. Karar hangi yönde verilirse verilsin gerekçesi yazılı ve kalıcı olur.

Günlük geliştirme kararları, hata düzeltmeleri ve küçük uygulama ayrıntıları RFC gerektirmez; olağan depo akışıyla (issue ve PR) yürür.

## 3. Gün batımı taahhüdü

Kurucu liderliği kalıcı olmak üzere tasarlanmamıştır. Hedeflenen sıra şudur:

1. **Bugün — kurucu liderliği.** Tek karar verici kurucudur; kararlar RFC süreciyle kamuya açık alınır.
2. **Teknik komite.** Kurucu dışında en az üç kişi, son altı ay boyunca projeye düzenli ve anlamlı katkı verdiğinde, karar yetkisi bir teknik komiteye devredilir. Kurucu bu komitenin eşit oy hakkına sahip bir üyesi olur; tek başına karar verme yetkisi sona erer. Komitenin kuruluşu, üyelik ve karar usulü bir RFC ile ilan edilir. Buradaki eşik göstergedir ve RFC ile netleştirilebilir; ancak geçişi süresiz ertelemenin gerekçesi yapılamaz.
3. **OZERK Foundation.** Uzun vadede, manifestonun 19. bölümünde tanımlanan modele geçilir: bağımsız, kâr amacı gütmeyen bir yapı RFC sürecini, açık standartları ve marka ilkelerinin korunmasını devralır. Hiçbir şirket — kurucunun şirketi dahil — platformun tek sahibi olamaz.

Bu taahhüdün kendisi bağlayıcıdır. Kurucunun bu bölümü tek taraflı olarak geri alması veya zayıflatması bu belgenin ihlalidir; bu bölümde yapılacak her değişiklik RFC gerektirir ve değişikliğin yönü ancak yetki devrini hızlandırmak olabilir.

## 4. Kırmızı çizgiler

Manifestonun 23. bölümündeki kırmızı çizgiler yalnızca ürün için değil, yönetişim için de bağlayıcıdır.

- Hiçbir RFC, yönetişim değişikliği veya manifesto tadili bu çizgileri ihlal edemez veya zayıflatamaz.
- Bu çizgileri aşan bir karar, hangi organ tarafından alınırsa alınsın — kurucu, teknik komite veya Foundation — OZERK adına geçersiz sayılır. Manifestonun ifadesiyle: bu çizgilerden biri ihlal edildiğinde ürün OZERK ruhundan uzaklaşmış kabul edilir.

## 5. Manifestonun tadili

Manifesto kurucu metindir; hafifçe değiştirilmez. Değişiklik gerektiğinde usul şudur:

1. Tadil önerisi bir RFC olarak açılır ve kamuya açık tartışılır.
2. Karar, o gün yürürlükte olan mekanizmayla verilir: bugün kurucu onayı; teknik komite kurulduktan sonra komite onayı; Foundation kurulduktan sonra Foundation'ın belirlediği usul.
3. Kabul edilen tadil, manifestoda yeni sürüm numarası ve tarihle işaretlenir; önceki sürümler depo geçmişinde korunur.
4. 23. bölümdeki kırmızı çizgileri zayıflatan tadiller, hangi onay mekanizmasından geçerse geçsin kabul edilemez (bkz. Bölüm 4).

## 6. Bu belgenin değiştirilmesi

Bu belgenin kendisi de aynı kurala tabidir: her değişiklik RFC süreciyle önerilir ve Bölüm 5'teki karar mekanizmasıyla sonuçlandırılır.

## 7. Lisans

Bu belge [CC BY-SA 4.0](LICENSES/CC-BY-SA-4.0.txt) ile lisanslanmıştır.

---

## English

# Governance

> The Turkish text is normative in case of discrepancy.

**Version 0.1 — 17 August 2026**

This document defines how decisions are made in the OZERK project today, and how that structure will change over time. The founding text is the [OZERK Project Manifesto](docs/OZERK_Proje_Manifestosu.md); if this document conflicts with the manifesto, the manifesto prevails.

### 1. Current state: founder leadership

OZERK is currently in Phase 0: the founding standards are being written and no platform code exists yet.

The honest statement is this: the project is currently run by a single person, and all final decisions are made by the founder.

This is written not as an ideal but as a description of reality. There is no regular contributor community yet; declaring elected bodies on behalf of a community that does not exist would misrepresent the facts. The governance structure will grow with the actual size of the community.

Even during the founder-leadership period, there are limits:

- Significant decisions are made through a public RFC process, not behind closed doors (see Section 2).
- The red lines in Section 23 of the manifesto are binding on everyone, including the founder (see Section 4).
- Founder leadership is temporary, and this document commits to the conditions of its end (see Section 3).

### 2. How decisions are made

Significant decisions — architectural decisions, standards, changes to principles and governance — are made through public RFC documents. The process is defined in [rfc/0000-rfc-sureci.md](rfc/0000-rfc-sureci.md).

The founder commits not to make any decision in this scope without an RFC and public discussion. Whichever way the decision goes, its rationale is written down and permanent.

Day-to-day development decisions, bug fixes and small implementation details do not require an RFC; they follow the ordinary repository flow (issues and PRs).

### 3. Sunset commitment

Founder leadership is not designed to be permanent. The intended sequence is:

1. **Today — founder leadership.** The founder is the single decision maker; decisions are made publicly through the RFC process.
2. **Technical committee.** When at least three people other than the founder have made regular, meaningful contributions to the project over the preceding six months, decision authority is transferred to a technical committee. The founder becomes a member of that committee with an equal vote; sole decision-making authority ends. The committee's formation, membership and decision procedure are announced in an RFC. The threshold here is indicative and may be clarified by RFC; it may not be used as a reason to postpone the transition indefinitely.
3. **OZERK Foundation.** In the long term, the model defined in Section 19 of the manifesto takes over: an independent, non-profit body assumes responsibility for the RFC process, the open standards, and the protection of the trademark principles. No company — including the founder's — may become the sole owner of the platform.

This commitment is itself binding. A unilateral withdrawal or weakening of this section by the founder is a violation of this document; any change to this section requires an RFC, and the only permissible direction of change is to accelerate the transfer of authority.

### 4. Red lines

The red lines in Section 23 of the manifesto are binding not only on the product but also on governance.

- No RFC, governance change or manifesto amendment may violate or weaken those lines.
- A decision crossing those lines is invalid under the OZERK name, regardless of which body made it — founder, technical committee or Foundation. In the manifesto's own words: when one of these lines is violated, the product is considered to have departed from the spirit of OZERK.

### 5. Amending the manifesto

The manifesto is the founding text; it is not changed lightly. When a change is needed, the procedure is:

1. The amendment proposal is opened as an RFC and discussed publicly.
2. The decision is made by the mechanism in force at that time: founder approval today; committee approval once the technical committee exists; the Foundation's own procedure once it exists.
3. An accepted amendment is marked in the manifesto with a new version number and date; previous versions are preserved in the repository history.
4. Amendments that weaken the red lines in Section 23 cannot be accepted, regardless of which approval mechanism they pass through (see Section 4).

### 6. Changing this document

This document itself is subject to the same rule: every change is proposed through the RFC process and decided by the mechanism in Section 5.

### 7. License

This document is licensed under [CC BY-SA 4.0](LICENSES/CC-BY-SA-4.0.txt).
