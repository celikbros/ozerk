# QEMU Açılış Denemeleri

**Türkçe** | [English](#english)

- **Durum:** Canlı belge (deneme kaydı)
- **Tarih:** 2026-08-17
- **Lisans:** CC BY-SA 4.0
- **İlgili belgeler:** [docs/yol-haritasi.md](yol-haritasi.md) (Ay 0–2), [rfc/0002-taban-dagitim.md](../rfc/0002-taban-dagitim.md)

Bu belge, taban dağıtım adaylarının emülatörde çalıştırılmasından çıkan **gözlemleri** kaydeder. Ölçüm değil gözlemdir: burada yazılanlar tek bir makinede, tek bir yapıyla elde edilmiştir ve genellenemez. Doğrulanmamış hiçbir şey doğrulanmış gibi yazılmamıştır.

Açılış betiği: [tools/qemu/boot-pmos.sh](../tools/qemu/boot-pmos.sh)

---

## 1. postmarketOS v26.06 — Phosh — generic-x86_64

### 1.1. Denenen yapı

| Alan | Değer |
|---|---|
| İmaj | `20260814-0317-postmarketOS-v26.06-phosh-29.1-generic-x86_64-lts.img.xz` |
| Yayın tarihi | 14 Ağustos 2026 |
| Çekirdek | 6.18.44-0-lts |
| initramfs | 3.11.0-r1 |
| Phosh | 29.1 |
| Sıkıştırılmış / açılmış boyut | 1,72 GB / 4,07 GB |
| Ana makine | Windows 11, QEMU 11.1.0, WHPX hızlandırma |
| Deneme tarihi | 17 Ağustos 2026 |

İmajın SHA256 özeti, yayımlanan `.sha256` dosyasıyla **karşılaştırıldı ve tuttu**. İndirme bir kez ağ hatasıyla kesilip kaldığı yerden sürdürüldüğü için bu doğrulama gerekliydi. Yayımlanan dosyanın beyan edilenle aynı olduğunu geliştiricinin sözüne güvenmeden doğrulamak, manifesto Bölüm 6.4'ün küçük ölçekli bir uygulamasıdır.

### 1.2. Bölüm düzeni

Ana makineden GPT ayrıştırılarak okundu:

| # | Dosya sistemi | Etiket | Boyut | Tür |
|---|---|---|---|---|
| 1 | FAT32 | `pmOS_boot` | 487 MB | EFI Sistem Bölümü |
| 2 | ext4 | `pmOS_root` | 3678 MB | Linux root (x86-64) |

Kök bölümün tür GUID'i, keşfedilebilir bölümler belirtimindeki (Discoverable Partitions Specification) `x86-64 root` değeridir.

### 1.3. Karşılaşılan üç engel

Üçü de çözüldü ve betiğe yorum olarak işlendi.

**(a) Yalnızca UEFI.** `generic-x86_64` systemd-boot kullanır ve legacy BIOS ile açılmaz. QEMU'ya EDK2 donanım yazılımı `pflash` olarak verilmelidir. Değişken deposu (`vars`) yazılabilir bir kopya olmalıdır; açılış girdisi bozulursa bu dosyayı silmek temiz bir başlangıç verir.

**(b) Windows'ta yol dönüşümü.** QEMU yerel bir Windows programıdır; MSYS/Git Bash'in `/c/...` biçimindeki POSIX yollarını açamaz. Yol dönüşümü yapılmadığında QEMU sessizce değil, açık bir hata ile çıkar (`could not connect serial device to character backend`). Çözüm: QEMU'ya giden her yolu `cygpath -w` ile çevirmek.

**(c) virtio disk çalışmıyor — en önemli bulgu.** Disk `if=virtio` ile bağlandığında açılış şu hatayla durdu:

```
Waiting for root partition
root partition not found!
postmarketOS debug shell
```

Bölüm tablosu ve etiketler doğru olduğuna göre sorun kök bölümün *bulunamaması* değil, diskin hiç *görülememesiydi*: **postmarketOS initramfs'i virtio_blk sürücüsünü taşımıyor.** Aynı yönde ikinci bir kanıt, istenen ekran çözünürlüğünün (720x1440) uygulanmaması ve UEFI framebuffer'ının varsayılanına (1280x800) düşülmesiydi — virtio-gpu da devrede değildi.

Çözüm: diski AHCI'ye almak. q35 makinesinde `if=ide`, sürücüsü çekirdekte yerleşik olan ICH9 AHCI denetleyicisine karşılık gelir. Ağ kartı da aynı gerekçeyle `e1000e` seçildi. Bu değişiklikle sistem sorunsuz açıldı ve istenen çözünürlük uygulandı.

### 1.4. Açılış sonrası gözlemler

- Sistem **Phosh kilit ekranına** açılır. Ekranda yalnızca sayısal tuş takımı ve "Password:" alanı vardır.
- **Çevrim içi hesap istenmez.** Ne kurulum sihirbazı ne kilit ekranı bir e-posta, telefon numarası veya sağlayıcı hesabı sorar. Resmî imajın varsayılan yerel kullanıcısı `user`, varsayılan parolası `147147`'dir ve bu değer postmarketOS'un kurulum sayfasında belgelidir.
- Kilit açıldıktan sonra masaüstü kullanılabilir durumdadır; uygulamalar (ör. GNOME Haritalar) açılır.
- **sshd varsayılan olarak çalışmaz.** 2222 portundan bağlanıldığında SSH banner'ı gelmez. Dikkat: QEMU'nun kullanıcı modu ağı, misafir sistem ilgili portu dinlemese bile ana makinedeki TCP bağlantısını kabul eder; bu nedenle "port açık mı" testi yanıltıcıdır ve gerçek banner sınanmalıdır.

### 1.5. Manifesto açısından anlamı

**Hesapsız kullanım (Bölüm 6.2, kırmızı çizgi 23.1) için ilk somut kanıt olumludur.** Taban dağıtım, cihazı kullanmak için hiçbir çevrim içi hesap dayatmıyor. Ancak bunun OZERK için doğrudan devralınabilir bir sonuç olmadığı kaydedilmelidir:

- Gözlemlenen şey **bir emülatör imajının** davranışıdır; ticari bir cihazın kurulum akışı değildir.
- Varsayılan parolanın herkesçe bilinen sabit bir değer olması, bir demo imajı için makuldür; **OZERK'in kurulum akışı için kabul edilebilir değildir.** Manifesto Bölüm 6.2 kullanıcının kendi yerel parolasını, PIN'ini veya biyometrisini belirlemesini öngörür. Bu, ilk açılış deneyiminde çözülmesi gereken bir tasarım maddesidir.

**Guard (Bölüm 9, [RFC-0005](../rfc/0005-guard-ag-modeli.md)) için henüz veri toplanmadı.** Önerilen mimarinin dayandığı taban yetenekler — cgroup v2, nftables `socket cgroupv2` eşleşmesi, ağ namespace'leri, `pasta`/`passt` varlığı, Landlock ABI sürümü — bu denemede sınanmadı. Bunun için misafir sistemde kabuk erişimi gerekir; sshd kapalı olduğundan ilk adım SSH'ı etkinleştirmektir.

### 1.6. Yetenek sınaması — Guard ve paketleme

sshd etkinleştirildikten sonra misafir sistemde iki sınama betiği çalıştırıldı: [tools/qemu/probe.sh](../tools/qemu/probe.sh) ve [tools/qemu/probe2.sh](../tools/qemu/probe2.sh). Amaç, [RFC-0005](../rfc/0005-guard-ag-modeli.md)'in önerdiği mimarinin dayandığı yeteneklerin bu tabanda gerçekten bulunup bulunmadığını görmekti.

**Guard'ın dayandığı yetenekler ([RFC-0005](../rfc/0005-guard-ag-modeli.md)):**

| Yetenek | Durum | Kanıt |
|---|---|---|
| cgroup v2 (birleşik) | **Var** | `cgroup.controllers`: `cpuset cpu io memory hugetlb pids dmem` |
| nftables | **Var** — v1.1.6 | `nft --version` |
| nftables `socket cgroupv2` eşleşmesi | **Var** | Root ile `nft --check` kuralı **kabul etti** |
| Ayrıcalıksız kullanıcı namespace'i | **Var** | `user.max_user_namespaces` = 15323; `unshare -U -n` çalışıyor |
| Ağ namespace'i ile izolasyon | **Çalışıyor** | `bwrap --unshare-net` başarılı |
| Landlock | **Etkin** | Çekirdek günlüğü: `landlock: Up and running`; `lsm` listesi: `lockdown,capability,landlock,yama` |
| systemd `IPAddressAllow=` / `IPAddressDeny=` | **Tanınıyor** | systemd 261; `systemctl show -p IPAddressAllow` özelliği döndürüyor |
| `pasta` / `passt` | Kurulu **değil**, depoda **var** | `passt-2026.05.26-r0` |
| `slirp4netns` | Kurulu **değil**, depoda **var** | `slirp4netns-1.3.3-r0` |
| `unbound` (istemci başına görünüm) | Kurulu **değil**, depoda **var** | `unbound-1.25.2-r0` |
| Yerel çözümleyici (mevcut durum) | **dnsmasq** | `127.0.0.1:53` üzerinde dinliyor (NetworkManager tarafından yönetilen) |

**Paketleme katmanı ([RFC-0003](../rfc/0003-paket-formati.md)):**

| Bileşen | Sürüm |
|---|---|
| Flatpak | 1.16.6 |
| xdg-desktop-portal | 1.21.2 |
| xdg-desktop-portal-gtk | 1.15.3 |
| Portal arka uçları | `xdg-desktop-portal-phosh`, `-wlr`, `-gtk` |
| bubblewrap | 0.11.2 |

**Sistem:** postmarketOS v26.06, çekirdek 6.18.44-0-lts, **systemd 261**, **musl libc**, 1280 kurulu paket.

**Sonuç: RFC-0005'in önerdiği mimari bu taban üzerinde kurulabilir.** Zorlamanın dayandığı çekirdek yetenekleri (cgroup v2, nftables `socket cgroupv2`, ayrıcalıksız ağ namespace'i, Landlock) mevcut ve çalışıyor. Kullanıcı alanı bileşenleri (`pasta`, `unbound`) imajda kurulu değil ama Alpine deposunda paketli — yani sıfırdan yazılacak bir şey yok, paketlenip yapılandırılacak bileşenler var.

**Manifesto 9.2'nin 1. profili (ağ erişimi yok) bugün zorlanabilir durumda.** `bwrap --unshare-net` çalışıyor ve Flatpak'a `--share=network` verilmemesi yeterli. Bu, [RFC-0005](../rfc/0005-guard-ag-modeli.md)'in "sert sınır" dediği katmanın taban tarafından karşılandığını gösterir. Profil 2 ve 3 için gereken çözümleyici-çapalı mimari ise henüz kurulmamıştır; yalnızca kurulabilir olduğu doğrulanmıştır.

**Boştaki bellek:** 4 GB atanmış sistemde açılıştan hemen sonra `MemAvailable` 2,87 GB idi (yaklaşık 1 GB kullanımda). Bu tek bir gözlemdir, karşılaştırma için Mobian'da aynı koşulda tekrarlanmalıdır.

**Yöntem notu — kaydedilmesi gereken bir hata.** İlk denemede `apk search` tüm paketler için "bulunamadı" döndürdü ve `passt`, `unbound`, `slirp4netns`'in depoda olmadığı sonucu çıkarılacaktı. Bu **yanlış** olurdu: kurulu olduğu bilinen `bubblewrap` da "bulunamadı" çıkınca yöntemin kendisinin bozuk olduğu anlaşıldı — depo dizini güncel değildi. `apk update` sonrası 29.236 paketlik dizinle arama doğru sonucu verdi. Bilinen-doğru bir kontrol vakası olmasaydı bu belgeye yanlış bir bulgu girecekti.

### 1.7. Açık işler

1. Aynı deneme **Mobian** için yapılmalı; [RFC-0002](../rfc/0002-taban-dagitim.md)'nin karşılaştırması ancak iki taban da aynı koşullarda çalıştırıldıktan sonra veriye dayanır. Özellikle glibc/musl farkının Guard yeteneklerine etkisi ölçülmeli.
2. `pasta` + `unbound` kurulup [RFC-0005](../rfc/0005-guard-ag-modeli.md)'in E1/E2 deneyleri fiilen çalıştırılmalı: uygulama başına ağ namespace'i, çözümleyici-çapalı nftables kümesi ve bir alan adının canlı engellenmesi (yol haritasındaki **D2** kapısı).
3. Landlock ABI sürümü bir sistem çağrısı sondasıyla belirlenmeli; bu denemede yalnızca Landlock'un **etkin** olduğu doğrulandı, ABI seviyesi ölçülmedi.
4. Açılış süresi ölçülmeli. Bu denemede **ölçülmedi**; tahmin yazılmamıştır.
5. postmarketOS'un immutable varyantı **Duranium** ayrıca denenmeli ([RFC-0002](../rfc/0002-taban-dagitim.md) Bölüm 3); güncelleme mimarisi açısından asıl aday odur.
6. Kurulu imajda sshd varsayılan kapalıdır ve bu denemede elle açılmıştır. OZERK'in kendi imajında uzaktan erişimin varsayılan durumu ayrıca kararlaştırılmalıdır.

---

## English

*The Turkish text is normative in case of discrepancy.*

# QEMU Boot Trials

- **Status:** Living document (trial log)
- **Date:** 2026-08-17
- **License:** CC BY-SA 4.0
- **Related documents:** [docs/yol-haritasi.md](yol-haritasi.md) (Months 0–2), [rfc/0002-taban-dagitim.md](../rfc/0002-taban-dagitim.md)

This document records **observations** from running base-distribution candidates in an emulator. These are observations, not measurements: what is written here was obtained on a single machine with a single build and does not generalise. Nothing unverified is presented as verified.

Boot script: [tools/qemu/boot-pmos.sh](../tools/qemu/boot-pmos.sh)

## 1. postmarketOS v26.06 — Phosh — generic-x86_64

### 1.1. The build that was tried

| Field | Value |
|---|---|
| Image | `20260814-0317-postmarketOS-v26.06-phosh-29.1-generic-x86_64-lts.img.xz` |
| Build date | 14 August 2026 |
| Kernel | 6.18.44-0-lts |
| initramfs | 3.11.0-r1 |
| Phosh | 29.1 |
| Compressed / decompressed size | 1.72 GB / 4.07 GB |
| Host | Windows 11, QEMU 11.1.0, WHPX acceleration |
| Trial date | 17 August 2026 |

The image's SHA256 digest **was compared against the published `.sha256` file and matched**. This verification was necessary because the download was interrupted once by a network error and resumed. Verifying that a published file is what it claims to be, without relying on the developer's word, is a small-scale application of manifesto Chapter 6.4.

### 1.2. Partition layout

Read by parsing the GPT from the host:

| # | Filesystem | Label | Size | Type |
|---|---|---|---|---|
| 1 | FAT32 | `pmOS_boot` | 487 MB | EFI System Partition |
| 2 | ext4 | `pmOS_root` | 3678 MB | Linux root (x86-64) |

The root partition's type GUID is the `x86-64 root` value from the Discoverable Partitions Specification.

### 1.3. Three obstacles encountered

All three were resolved and recorded as comments in the script.

**(a) UEFI only.** `generic-x86_64` uses systemd-boot and does not boot under legacy BIOS. The EDK2 firmware must be given to QEMU as `pflash`. The variable store must be a writable copy; deleting that file gives a clean start if the boot entry becomes corrupted.

**(b) Path conversion on Windows.** QEMU is a native Windows program and cannot open MSYS/Git Bash POSIX paths of the form `/c/...`. Without conversion QEMU does not fail silently but exits with an explicit error (`could not connect serial device to character backend`). The fix is to convert every path handed to QEMU with `cygpath -w`.

**(c) The virtio disk does not work — the most important finding.** With the disk attached as `if=virtio`, boot halted with:

```
Waiting for root partition
root partition not found!
postmarketOS debug shell
```

Since the partition table and labels were correct, the problem was not that the root partition could not be *found* but that the disk could not be *seen* at all: **the postmarketOS initramfs does not carry the virtio_blk driver.** A second piece of evidence pointed the same way: the requested screen resolution (720x1440) was not applied and the system fell back to the UEFI framebuffer default (1280x800) — virtio-gpu was not active either.

The fix is to move the disk to AHCI. On the q35 machine, `if=ide` maps to the ICH9 AHCI controller, whose driver is built into the kernel. The NIC was set to `e1000e` for the same reason. With these changes the system booted without trouble and the requested resolution was applied.

### 1.4. Observations after boot

- The system boots to the **Phosh lock screen**. It shows only a numeric keypad and a "Password:" field.
- **No online account is requested.** Neither a setup wizard nor the lock screen asks for an email address, phone number or provider account. The official image's default local user is `user` and the default password is `147147`, a value documented on the postmarketOS installation page.
- Once unlocked the desktop is usable and applications (e.g. GNOME Maps) launch.
- **sshd does not run by default.** Connecting to port 2222 yields no SSH banner. Note: QEMU's user-mode networking accepts the host-side TCP connection even when the guest is not listening on the forwarded port, so a "is the port open" test is misleading and the real banner must be checked.

### 1.5. What this means for the manifesto

**The first concrete evidence for account-free use (Chapter 6.2, red line 23.1) is positive.** The base distribution imposes no online account in order to use the device. It must be recorded, however, that this is not a result OZERK can inherit directly:

- What was observed is the behaviour of **an emulator image**, not the setup flow of a commercial device.
- A fixed, publicly known default password is reasonable for a demo image but **is not acceptable for OZERK's setup flow.** Manifesto Chapter 6.2 requires the user to choose their own local password, PIN or biometric. This is a design item to be resolved in the first-boot experience.

**No data was gathered for Guard (Chapter 9, [RFC-0005](../rfc/0005-guard-ag-modeli.md)).** The base capabilities the proposed architecture rests on — cgroup v2, the nftables `socket cgroupv2` match, network namespaces, the presence of `pasta`/`passt`, the Landlock ABI level — were not tested in this trial. Doing so requires shell access in the guest, and since sshd is disabled the first step is to enable SSH.

### 1.6. Open work

1. Enable sshd in the guest and test Guard's base capabilities (cgroup v2, nftables, netns, Landlock ABI, `pasta`).
2. Record whether Flatpak and xdg-desktop-portal are present in the image, and at which versions (for [RFC-0003](../rfc/0003-paket-formati.md)).
3. Repeat the same trial for **Mobian**; the comparison in [RFC-0002](../rfc/0002-taban-dagitim.md) rests on data only once both bases have been run under the same conditions.
4. Measure boot time and idle memory use. These were **not measured** in this trial; no estimate has been written.
5. Separately try **Duranium**, the immutable postmarketOS variant ([RFC-0002](../rfc/0002-taban-dagitim.md) Chapter 3).
