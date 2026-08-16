# Katkı Rehberi

**Türkçe** | [English](#english)

> Çelişki hâlinde Türkçe metin bağlayıcıdır (normatiftir).

OZERK şu anda **Aşama 0**'dadır: kurucu standartlar yazılıyor, henüz platform kodu yok. Bu nedenle bu aşamada katkı, büyük kod parçaları göndermek değil; projenin temelini birlikte doğru kurmaktır.

## 1. Şu anda katkı ne demektir?

Aşama 0'da öncelikli katkı alanları:

- **RFC tartışmaları:** Kurucu standartlar RFC belgeleriyle şekillenir. Bir RFC'yi okumak, itiraz etmek, alternatif önermek veya yeni bir RFC taslağı açmak en değerli katkıdır. Süreç için bkz. [rfc/0000-rfc-sureci.md](rfc/0000-rfc-sureci.md).
- **Doküman iyileştirme:** Manifesto dışındaki belgelerde eksik, belirsiz veya çelişkili noktaları düzeltmek. (Manifesto kurucu metindir; değişiklik önerileri ancak RFC süreciyle tartışılır.)
- **Çeviri:** Belgelerin Türkçe ve İngilizce bölümlerini eşdeğer tutmak, terminolojiyi tutarlı hâle getirmek.
- **CLI iskeleti:** `ozerk` geliştirici CLI'ının erken iskeleti üzerinde çalışmak.

Küçük katkılar (yazım düzeltmesi, kırık bağlantı, terminoloji tutarlılığı) da memnuniyetle kabul edilir.

## 2. GitHub akışı

Geliştirme GitHub'da, açık biçimde yürür:

1. **Issue aç:** Önerini veya sorunu kısaca tanımla. Büyük değişikliklerde önce issue açmak, emeğin boşa gitmesini önler.
2. **Tartış:** Kapsam ve yaklaşım issue üzerinde (gerekirse RFC olarak) netleşir.
3. **PR gönder:** Küçük, odaklı PR'lar tercih edilir. PR açıklamasında hangi issue'ya karşılık geldiğini belirt.

## 3. DCO (Developer Certificate of Origin)

Her commit, [Developer Certificate of Origin 1.1](https://developercertificate.org/) beyanıyla imzalanmalıdır (sign-off). Bu, katkıyı gönderme hakkına sahip olduğunu beyan ettiğin anlamına gelir; ayrı bir sözleşme (CLA) yoktur.

Sign-off için commit atarken `-s` bayrağını kullan:

```bash
git commit -s -m "docs: repository standardı taslağına güven zinciri bölümü eklendi"
```

Bu, commit mesajının sonuna şu satırı ekler:

```
Signed-off-by: Ad Soyad <eposta@ornek.com>
```

Sign-off içermeyen commit'ler birleştirilmez.

## 4. Commit mesajı üslubu

- Kısa ve açıklayıcı yaz: ilk satır değişikliği özetlesin.
- Türkçe veya İngilizce serbesttir.
- Gerekirse gövdede "neden" sorusunu yanıtla; "ne" zaten diff'te görünür.

## 5. Dil politikası

- Kurucu belgeler iki dillidir: tek dosyada önce Türkçe, sonra İngilizce bölüm yer alır.
- İki bölüm içerik olarak eşdeğer tutulur. Bir bölümü değiştiren PR, diğer bölümü de güncellemelidir; çeviriye gücün yetmiyorsa PR'da açıkça belirt, çeviri katkısı ayrıca değerlidir.
- Çelişki hâlinde Türkçe metin bağlayıcıdır.

## 6. Lisanslama beyanı

Depo karma lisans modeli kullanır; tam metinler [LICENSES/](LICENSES/) dizinindedir. Bir katkı gönderdiğinde, katkının ilgili dizinin lisansı altında yayımlanmasını kabul etmiş olursun:

| Alan | Lisans |
| --- | --- |
| Belgeler (`docs/`, `rfc/` ve kök dizindeki belgeler) | CC BY-SA 4.0 |
| SDK, CLI ve kütüphaneler | Apache-2.0 |
| Sistem / OS bileşenleri | GPL-3.0-or-later |

## 7. Kod stili

Şimdilik kısa bir kural yeterlidir: Rust kodu `rustfmt` ile biçimlendirilmiş ve `clippy` uyarılarından temiz olmalıdır. Platform kodu büyüdükçe bu bölüm genişletilecektir.

## 8. Davranış kuralları

Tüm katkı alanlarında [davranış kuralları](CODE_OF_CONDUCT.md) geçerlidir.

---

## English

**[Türkçe](#katkı-rehberi)** | English

> The Turkish text is normative in case of discrepancy.

OZERK is currently in **Phase 0**: the founding standards are being written and there is no platform code yet. At this stage, contributing does not mean submitting large pieces of code; it means helping build the project's foundation correctly, together.

## 1. What does contributing mean right now?

Priority areas in Phase 0:

- **RFC discussions:** The founding standards take shape through RFC documents. Reading an RFC, objecting to it, proposing an alternative, or opening a new RFC draft is the most valuable contribution. See [rfc/0000-rfc-sureci.md](rfc/0000-rfc-sureci.md) for the process.
- **Document improvement:** Fixing gaps, ambiguities, or contradictions in documents other than the manifesto. (The manifesto is the founding text; proposed changes are discussed only through the RFC process.)
- **Translation:** Keeping the Turkish and English sections of documents equivalent and the terminology consistent.
- **CLI skeleton:** Working on the early skeleton of the `ozerk` developer CLI.

Small contributions (typo fixes, broken links, terminology consistency) are welcome too.

## 2. GitHub workflow

Development happens in the open, on GitHub:

1. **Open an issue:** Briefly describe your proposal or the problem. For larger changes, opening an issue first prevents wasted effort.
2. **Discuss:** Scope and approach are settled on the issue (as an RFC where needed).
3. **Submit a PR:** Small, focused PRs are preferred. State in the PR description which issue it addresses.

## 3. DCO (Developer Certificate of Origin)

Every commit must be signed off under the [Developer Certificate of Origin 1.1](https://developercertificate.org/). This means you certify that you have the right to submit the contribution; there is no separate agreement (CLA).

Use the `-s` flag when committing:

```bash
git commit -s -m "docs: add trust chain section to repository standard draft"
```

This appends the following line to the commit message:

```
Signed-off-by: Your Name <email@example.com>
```

Commits without a sign-off will not be merged.

## 4. Commit message style

- Keep it short and descriptive: the first line should summarize the change.
- Turkish or English — both are fine.
- If needed, answer "why" in the body; "what" is already visible in the diff.

## 5. Language policy

- Founding documents are bilingual: a single file contains the Turkish section first, then the English section.
- The two sections are kept equivalent in content. A PR that changes one section must also update the other; if you cannot provide the translation, say so clearly in the PR — translation contributions are valued in their own right.
- In case of discrepancy, the Turkish text is normative.

## 6. Licensing statement

The repository uses a mixed licensing model; the full texts are in the [LICENSES/](LICENSES/) directory. By submitting a contribution, you agree that it is published under the license of the relevant directory:

| Area | License |
| --- | --- |
| Documents (`docs/`, `rfc/` and the documents in the repository root) | CC BY-SA 4.0 |
| SDK, CLI, and libraries | Apache-2.0 |
| System / OS components | GPL-3.0-or-later |

## 7. Code style

For now, one short rule is enough: Rust code must be formatted with `rustfmt` and clean of `clippy` warnings. This section will grow as the platform code grows.

## 8. Code of conduct

The [code of conduct](CODE_OF_CONDUCT.md) applies in all contribution spaces.
