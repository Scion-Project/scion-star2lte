#!/bin/bash
# SPDX-License-Identifier: MIT-0
# A boot image for one run on the Galaxy S9+ (star2lte) or the Galaxy Note9 (crownlte): the same file in both device
# repositories, the phone it is for taken from the directory it is in (devices/<name>/mkimage.sh). It is the S9's
# (devices/starlte/mkimage.sh) with two differences:
#   - the loader is told which phone this is (loader_platform=<name>): the S9's UEFI reports the same framebuffer on all
#     three, so the loader could not tell them apart by it (xnuloader/loader.c, platform_sibling);
#   - there is no UEFI of this phone's own (README.md, "The UEFI"). The image borrows the S9's, devices/starlte/prebuilt
#     (tools/hakios-device.py sync starlte), and only when asked to with -U: that UEFI has never run on this phone, and
#     a phone it does not start needs Download mode (Vol Down + Bixby + USB) and the stock BOOT back.
#
#   devices/<name>/mkimage.sh -U [-o xnu-<name>.img] [-k kernel] [-r root.apfs] [-s SECS] [-q] [boot-args...]
#
# The kernel is this phone's configuration (make <name>_defconfig && make kernel: hakios-kernel); the boot-arguments
# default to that configuration's (tools/hakios-config.py args), with -v unless -q. The loader is xnuloader/loader.efi,
# built with the iPhone identity from your own IPSW (make loader): the image is yours, never to be published.
set -e
START=$PWD
NAME=$(basename "$(cd "$(dirname "$0")" && pwd)")
case "$NAME" in
star2lte|crownlte) ;;
*) echo "mkimage.sh: devices/$NAME: this script is the S9+'s and the Note9's (devices/star2lte, devices/crownlte)" >&2; exit 2 ;;
esac
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT"
OUT=$ROOT/xnu-$NAME.img K=$ROOT/hakios-kernel RD=$ROOT/userland/root.apfs SECS=120 VERBOSE=-v BORROW=
while getopts o:k:r:s:qU opt; do
	case $opt in
	o) OUT=$OPTARG ;; k) K=$OPTARG ;; r) RD=$OPTARG ;; s) SECS=$OPTARG ;; q) VERBOSE= ;; U) BORROW=1 ;;
	*) sed -n 2,16p "$0"; exit 2 ;;
	esac
done
shift $((OPTIND - 1))
if [ -z "$BORROW" ]; then
	echo "mkimage.sh: $NAME has no UEFI of its own. -U makes the image with the Galaxy S9's (devices/starlte/prebuilt)," >&2
	echo "mkimage.sh: which has never run on this phone: devices/$NAME/README.md, \"The UEFI\", says what that risks" >&2
	exit 2
fi
abs() { case "$1" in /*) echo "$1" ;; *) echo "$START/$1" ;; esac; }
OUT=$(abs "$OUT") K=$(abs "$K") RD=$(abs "$RD")
L=xnuloader/loader.efi
for f in "$L" "$K" "$RD" devices/starlte/prebuilt/SILICIUM_UEFI.fd devices/starlte/prebuilt/BootShim.bin; do
	[ -f "$f" ] || { echo "mkimage.sh: $f is missing (make loader, make kernel, userland/build.sh, tools/hakios-device.py sync starlte)" >&2; exit 1; }
done
ARGS="$*"
if [ -z "$ARGS" ]; then
	grep -q "^CONFIG_DEVICE=\"$NAME\"" .config 2>/dev/null || {
		echo "mkimage.sh: .config is not the $NAME's: make ${NAME}_defconfig first, or give the boot-arguments" >&2; exit 1; }
	ARGS=$(python3 tools/hakios-config.py args)
fi
case " $ARGS " in
*" loader_platform="*) echo "mkimage.sh: loader_platform= is this script's to set" >&2; exit 2 ;;
esac
ARGS="loader_platform=$NAME${VERBOSE:+ $VERBOSE} $ARGS"
P=$(mktemp "${TMPDIR:-/tmp}/$NAME-payload.XXXXXX")
trap 'rm -f "$P"' EXIT
python3 xnuloader/mkpayload.py -o "$P" loader.efi="$L" kernel="$K" ramdisk="$RD" \
	--cmdline "loader_return_after=$SECS epoch=$(date +%s) $ARGS" >/dev/null
# the S9's packing and the S9's UEFI (mkxnuimg.py takes devices/starlte/prebuilt when no Mu-Silicium/ is built here)
UEFI_TARGET=starlte python3 mkxnuimg.py -p "$P" -o "$OUT"
echo "mkimage.sh: $OUT ($NAME, with the Galaxy S9's UEFI: never run on this phone): in TWRP, Install Image to Boot; power on"
if [ "$SECS" = 0 ]; then LIMIT="no time limit"; else LIMIT="the run returns after $SECS s"; fi
echo "mkimage.sh: boot-args: $ARGS; $LIMIT"
