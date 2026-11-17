# The Galaxy S9's Wi-Fi firmware (prebuilt, Broadcom's)

NOTICE. Broadcom's firmware, NVRAM and regulatory data for the BCM4361 radio module of the Galaxy S9 (made by Murata or
by Samsung Electro-Mechanics, SEMCO), as Samsung ships them. They belong to their owners and are not licensed by this
repository (LICENSE, item 5); their terms are still to verify. Not kept in this repository (they were, from 2 Nov to
7 Nov 2026; the earlier commits still hold them): the files are fetched unchanged.

**Not in this repository.** Only this README and `SHA256SUMS` are tracked; the files themselves are fetched, and checked
against `SHA256SUMS`, by `tools/fetch-firmware.sh` (from your own copy with `--from DIR`, else from the pinned public
community vendor trees it names; `--check` only verifies). `userland/build.sh` with `DEVICE=star2lte` runs it for you when
a file is missing (kernel repository, `tools/` and `userland/build.sh`), and stops with what to do if a file cannot be had.

Source: the LineageOS 24 vendor image for starlte, `/vendor/firmware/` (the same files, by SHA-1, as
`proprietary-files.txt` of LineageOS's `device_samsung_exynos9810-common` lists, and as the user's own phone's VENDOR
partition has). Left out: the factory-test (`bcmdhd_mfg.bin_*`) and monitor-mode (`bcmdhd_mon.bin_*`) builds.

`userland/build.sh` with `DEVICE=star2lte` puts them into `fw/` of the root image under these names, where the kernel's
`drivers/wifi/hakios.brcmfmac.c` finds them for brcmfmac (which asks for `brcmfmac4361b2-pcie.bin`, `.txt` and
`.clm_blob`). Without them in the image the kernel reads the same files from the phone's own VENDOR partition at run time
(`ufs=2`; `drivers/storage/hakios.ext4.c`). Which NVRAM is the phone's the kernel reads from the module's ID in the
chip's OTP, as bcmdhd does (WIFI.md).

| file | what it is | sha256 |
|---|---|---|
| `bcmdhd_sta.bin_b2` | the station firmware for the chip's revision B2 (13.50.37, "4361b2-roml/config_pcie_release_ipa") | `e3c66440a4a6c3d30918f922c20ccd0fbecaa1aaa0460b4458b48e202473f452` |
| `bcmdhd_sta.bin_b0` | the same for B0 and B1 | `171e66d61ac3e838fdb3fa62fd5dd6c8e590db192247dac1a8c60a364e30ac69` |
| `bcmdhd_clm.blob` | the regulatory data (CLM), downloaded after the firmware | `1c1477864b0858bd0ad8700a766318c2f7220e4766dba0e8ee15d8bf13435356` |
| `nvram.txt_r02a_b2` | the board's NVRAM: SEMCO E32A R02 (module ID 91 33) | `5bb574b0f3debe080855f00cde0381416aeca7fafc4a3f4a488bbe2e6b5d8be9` |
| `nvram.txt_r02b_b2` | the board's NVRAM: SEMCO E32A R02, Skyworks (module ID a1 33) | `68cb903937a5c2af055bee36141047df9cf5e7d79a23a24a0677e2faf85ccba2` |
| `nvram.txt_murata_r041_b2` | the board's NVRAM: Murata 1QW ES4.1 | `6bf82955037750e1cd9534d524a62ea072b07058c5a5797030030ddde59c0173` |

**Galaxy S9+ (star2lte).** The same files as the Galaxy S9's (devices/starlte/firmware/wifi): the S9+'s vendor tree (star2lte, `008b9fee9774`) carries the same bytes, or (mfc_fw.bin) the files were taken from the same firmware package for both phones.
