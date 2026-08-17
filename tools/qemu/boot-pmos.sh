#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# postmarketOS generic-x86_64 (Phosh) imajını QEMU'da açar.
# Boots the postmarketOS generic-x86_64 (Phosh) image in QEMU.
#
# Doğrulanmış üç tuzak / Three verified pitfalls:
#  1. generic-x86_64 yalnızca UEFI ile açılır (systemd-boot); legacy BIOS yoktur.
#     It boots via UEFI only (systemd-boot); there is no legacy BIOS support.
#  2. QEMU yerel bir Windows programıdır ve MSYS/Git Bash'in POSIX yollarını
#     anlamaz; QEMU'ya giden her yol cygpath ile çevrilmelidir.
#     QEMU is a native Windows program and does not understand MSYS/Git Bash
#     POSIX paths; every path handed to QEMU must be converted with cygpath.
#  3. postmarketOS initramfs'i virtio_blk taşımaz. virtio diskle kök bölüm
#     bulunamaz ve sistem hata ayıklama kabuğuna düşer.
#     The postmarketOS initramfs does not carry virtio_blk. With a virtio disk
#     the root partition is not found and the system drops to the debug shell.
#
# Ayrıntılı gözlemler / Detailed observations: docs/qemu-denemeleri.md

set -uo pipefail

QEMU_DIR="${QEMU_DIR:-/c/Program Files/qemu}"
HERE="$(cd "$(dirname "$0")" && pwd)"

# MSYS/Cygwin dışında cygpath yoktur; orada yol dönüşümü gerekmez.
if command -v cygpath >/dev/null 2>&1; then
  w() { cygpath -w "$1"; }
else
  w() { printf '%s' "$1"; }
fi

IMG="${IMG:-$HERE/pmos-phosh.img}"
VARS="$HERE/uefi-vars.fd"
SERIAL="$HERE/serial.log"
CODE_FD="$QEMU_DIR/share/edk2-x86_64-code.fd"
VARS_TEMPLATE="$QEMU_DIR/share/edk2-i386-vars.fd"

ACCEL="${ACCEL:-whpx}"        # Windows: whpx, Linux: kvm, hızlandırma yoksa: tcg
MEM="${MEM:-4096}"
CPUS="${CPUS:-4}"
DISK_IF="${DISK_IF:-ide}"     # q35'te "ide" = ICH9 AHCI (yerleşik sürücü)
NIC_MODEL="${NIC_MODEL:-e1000e}"
# Phosh dikey ekran için tasarlandı; 720x1440 gerçekçi bir telefon oranıdır.
WIDTH="${WIDTH:-720}"
HEIGHT="${HEIGHT:-1440}"

if [ ! -f "$IMG" ]; then
  echo "HATA / ERROR: $IMG yok / not found." >&2
  echo "İmajı indirip açın / download and decompress the image:" >&2
  echo "  https://images.postmarketos.org/bpo/  (generic-x86_64 / phosh)" >&2
  echo "İndirdikten sonra SHA256'yı yayımlanan .sha256 dosyasıyla doğrulayın." >&2
  echo "After downloading, verify the SHA256 against the published .sha256 file." >&2
  exit 1
fi

# UEFI değişken deposu yazılabilir olmalı; yalnızca yoksa kopyalanır.
# Açılış girdisi bozulursa bu dosyayı silmek temiz bir başlangıç verir.
[ -f "$VARS" ] || cp "$VARS_TEMPLATE" "$VARS"

: > "$SERIAL"

echo "Hızlandırma / accel: $ACCEL | RAM: ${MEM}M | CPU: $CPUS | ${WIDTH}x${HEIGHT}"
echo "Disk: $DISK_IF | NIC: $NIC_MODEL"
echo "Seri konsol / serial log: $(w "$SERIAL")"
echo "SSH yönlendirmesi / forward: localhost:2222 -> 22 (sshd varsayılan kapalıdır)"
echo "QMP: 127.0.0.1:4444 (ekran görüntüsü / screendump)"

exec "$QEMU_DIR/qemu-system-x86_64.exe" \
  -machine q35 \
  -accel "$ACCEL" \
  -cpu max \
  -smp "$CPUS" \
  -m "$MEM" \
  -drive "if=pflash,format=raw,unit=0,readonly=on,file=$(w "$CODE_FD")" \
  -drive "if=pflash,format=raw,unit=1,file=$(w "$VARS")" \
  -drive "if=$DISK_IF,format=raw,file=$(w "$IMG")" \
  -device qemu-xhci -device usb-tablet -device usb-kbd \
  -nic "user,model=$NIC_MODEL,hostfwd=tcp::2222-:22" \
  -serial "file:$(w "$SERIAL")" \
  -qmp tcp:127.0.0.1:4444,server,nowait \
  "$@"
