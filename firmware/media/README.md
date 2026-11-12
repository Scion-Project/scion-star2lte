# The Exynos 9810 MFC (hardware video codec) firmware (prebuilt, Samsung's)

NOTICE. Samsung's MFC firmware image, `/vendor/firmware/mfc_fw.bin` of the phone's Android. It belongs to its owners and
is not licensed by this repository. Not kept in this repository: only this README and `SHA256SUMS` are tracked.

Source: FloydROM T Build 22 for the Exynos 9810 (`floyd/device/common/vendor/firmware/mfc_fw.bin`), the same file for
starlte, star2lte and crownlte. `userland/build.sh DEVICE=star2lte` puts it in `fw/`, where
`drivers/media/mfc/hakios.exynos_mfc.c` takes it before looking on the phone's VENDOR partition (a VENDOR of another ROM,
or a wiped one, has none). Get it with `tools/fetch-firmware.sh --from DIR` (your own unpacked vendor partition or ROM):
it is in no pinned public tree, so `--from` is the only way.

**Galaxy S9+ (star2lte).** The same files as the Galaxy S9's (devices/starlte/firmware/media): the S9+'s vendor tree (star2lte, `008b9fee9774`) carries the same bytes, or (mfc_fw.bin) the files were taken from the same firmware package for both phones.
