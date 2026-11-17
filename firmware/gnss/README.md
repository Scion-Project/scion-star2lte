# The S9+'s GNSS receiver: its ESW (prebuilt, Broadcom's)

NOTICE. The code of the BCM4775 B0's GNSS baseband ("ESW", `esw3_dev:4775_B0`), which the host writes into the
baseband's RAM through its boot ROM before the measurement engine can run. It belongs to Broadcom and is not licensed
by this repository (LICENSE, item 5).

**Not in this repository.** Only this README and `SHA256SUMS` are tracked. `tools/fetch-firmware.sh` cuts the three
pieces out of Broadcom's `gpsd` (Samsung's Android vendor partition, `vendor/bin/hw/gpsd`, "LHD2 ver. 108.20.545200"):
from your own copy with `--from DIR`, else from the pinned public vendor tree (exynos9810-common). Each piece is checked
against `SHA256SUMS`.

| File | Baseband address | Size | In gpsd |
|---|---|---|---|
| `gnss-esw-0-5fdf0.bin` | 0x5fdf0 | 528 | `a4775_B0_ImageSegments[0]`, file offset 0x1abff0 |
| `gnss-esw-1-78000.bin` | 0x78000 | 25844 | `a4775_B0_ImageSegments[1]`, file offset 0x1ac200 |
| `gnss-esw-2-5fff0.bin` | 0x5fff0 | 12 | the word gpsd writes last (the retain/jump variant), file offset 0x1abfe4 |

The names say the load order and the address: `gnss-esw-<N>-<ADDR>.bin`. `userland/build.sh` (DEVICE=star2lte) puts them in
the image's `/redwood/fw`, where gnssd (`userland/src/gnssd.m`) finds them by that pattern and loads them in that order
(the kernel repository's docs/gnss.md and docs/gnssd.md).
