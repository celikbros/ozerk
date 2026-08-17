#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
# OZERK: taban dağıtımın Guard (RFC-0005) ve paketleme (RFC-0003) için
# gerekli yetenekleri sunup sunmadığını sınar. Salt okuma; sistemi değiştirmez.

say() { printf '\n=== %s ===\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1 && echo "VAR  $1 -> $(command -v "$1")" || echo "YOK  $1"; }

say "SISTEM"
. /etc/os-release && echo "os: $PRETTY_NAME"
echo "kernel: $(uname -r)"
echo "arch: $(uname -m)"
echo "libc: $( (ldd --version 2>&1 | head -1) || echo bilinmiyor)"
echo "init: $( [ -d /run/systemd/system ] && echo systemd || echo systemd-degil)"
systemctl --version 2>/dev/null | head -1

say "BELLEK"
grep -E '^(MemTotal|MemAvailable)' /proc/meminfo

say "CGROUP v2"
echo "fs turu: $(stat -fc %T /sys/fs/cgroup 2>/dev/null)"
echo "denetleyiciler: $(cat /sys/fs/cgroup/cgroup.controllers 2>/dev/null)"

say "AG NAMESPACE"
have unshare
have ip
unshare -n true 2>/dev/null && echo "unshare -n: CALISIYOR (root disi)" || echo "unshare -n: root disi calismadi"

say "NFTABLES"
have nft
nft --version 2>/dev/null
echo "-- socket cgroupv2 esleme destegi (kuru calisma) --"
nft --check --file - <<'NFT' 2>&1 | head -5 && echo "socket cgroupv2: KABUL EDILDI"
table inet ozerk_test {
  chain out {
    type filter hook output priority 0;
    socket cgroupv2 level 1 "user.slice" drop
  }
}
NFT

say "LANDLOCK"
if [ -r /proc/config.gz ]; then
  zcat /proc/config.gz 2>/dev/null | grep -E 'LANDLOCK' || echo "config'de LANDLOCK yok"
else
  echo "/proc/config.gz okunamiyor"
fi
ls -d /sys/kernel/security/landlock 2>/dev/null || echo "securityfs landlock dizini yok"
echo "lsm listesi: $(cat /sys/kernel/security/lsm 2>/dev/null)"

say "KULLANICI-MODU AG YIGINLARI"
have pasta
have passt
have slirp4netns

say "eBPF"
echo "bpf fs: $(stat -fc %T /sys/fs/bpf 2>/dev/null)"
have bpftool

say "PAKETLEME (RFC-0003)"
have flatpak
flatpak --version 2>/dev/null
echo "-- portal ikilileri --"
ls /usr/libexec/ 2>/dev/null | grep -i portal || echo "libexec'te portal yok"
ls /usr/lib/xdg-desktop-portal* 2>/dev/null | head -5
echo "-- portal paketleri --"
apk list -I 2>/dev/null | grep -iE 'xdg-desktop-portal|flatpak' | head -10 || echo "apk sorgusu basarisiz"

say "DNS / COZUMLEYICI"
have resolvectl
have unbound
have knot-resolver
have dnsmasq
echo "resolv.conf: $(head -3 /etc/resolv.conf 2>/dev/null | tr '\n' ' ')"

say "PAKET SAYISI"
apk list -I 2>/dev/null | wc -l

say "SON"
