#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
#
# İkinci tur sınama: root yetkisi gerektiren ve depo dizinine bakan kontroller.
# Second-round probe: checks that need root and that query the package index.
#
# Kullanım / usage (misafir sistemde / in the guest):
#   sudo sh probe2.sh
#
# Sonuçlar: docs/qemu-denemeleri.md
# Salt okuma değildir: `apk update` depo dizinini tazeler. Paket kurmaz.
# Not read-only: `apk update` refreshes the package index. It installs nothing.

say() { printf '\n=== %s ===\n' "$1"; }

if [ "$(id -u)" -ne 0 ]; then
  echo "Bu betik root ile çalıştırılmalıdır / must be run as root: sudo sh $0" >&2
  exit 1
fi

say "NFTABLES"
nft --version
printf 'table inet ozerk_test {\n chain out {\n  type filter hook output priority 0;\n  socket cgroupv2 level 1 "user.slice" drop\n }\n}\n' > /tmp/ozerk_test.nft
if nft --check --file /tmp/ozerk_test.nft; then
  echo "socket cgroupv2 --check: GECTI / PASSED"
else
  echo "socket cgroupv2 --check: BASARISIZ / FAILED"
fi
rm -f /tmp/ozerk_test.nft

say "53 PORTUNU DINLEYEN / LISTENING ON PORT 53"
(ss -lnup 2>/dev/null || netstat -lnup 2>/dev/null) | grep ':53 ' || echo "(dinleyen yok / none)"

say "SYSTEMD IP FILTRELEME / IP FILTERING"
systemctl --version | head -1
# Özellik tanınıyorsa boş değerle döner; tanınmıyorsa hata verir.
systemctl show -p IPAddressAllow -p IPAddressDeny sshd.service 2>&1 | head -4

say "LANDLOCK"
dmesg 2>/dev/null | grep -i landlock | head -3 || echo "(dmesg satiri yok / no dmesg line)"
echo "lsm: $(cat /sys/kernel/security/lsm 2>/dev/null)"

say "DEPO DIZINI TAZELENIYOR / REFRESHING PACKAGE INDEX"
# ÖNEMLİ: dizin tazelenmeden yapılan `apk search` her paket için boş döner ve
# "depoda yok" gibi görünür. Aşağıdaki bubblewrap kontrolü bu tuzağa karşı
# bilinen-doğru vakadır: kurulu olduğu halde bulunamıyorsa yöntem bozuktur.
# IMPORTANT: without refreshing the index, `apk search` returns nothing for
# every package and looks like "not in the repository". The bubblewrap check
# below is the known-good control: if an installed package is not found, the
# method itself is broken, not the repository.
apk update 2>&1 | tail -3

say "YONTEM DOGRULAMASI / METHOD CONTROL"
apk info --who-owns /usr/bin/bwrap

say "DEPODA ARAMA / REPOSITORY SEARCH"
for p in passt slirp4netns unbound knot-resolver bubblewrap dnsmasq; do
  r=$(apk search -e "$p" | head -1)
  if [ -n "$r" ]; then echo "VAR  $p -> $r"; else echo "YOK  $p"; fi
done

say "SON / END"
