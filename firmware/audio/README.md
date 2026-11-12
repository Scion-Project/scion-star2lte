# The Galaxy S9+'s audio firmware (prebuilt, Samsung's)

Samsung's own binaries, not kept in this repository (they were, until 7 Nov 2026; the earlier commits still hold them).

**Not in this repository.** Only this README and `SHA256SUMS` are tracked; the files themselves are fetched, and checked
against `SHA256SUMS`, by `tools/fetch-firmware.sh` (from your own copy with `--from DIR`, else from the pinned public
community vendor trees it names; `--check` only verifies). `userland/build.sh` with `DEVICE=star2lte` runs it for you when
a file is missing (kernel repository, `tools/` and `userland/build.sh`), and stops with what to do if a file cannot be had.
`userland/build.sh` with `DEVICE=star2lte` puts every file of `firmware/` (but the READMEs and `SHA256SUMS`) into `fw/` of the root image, where the kernel's
drivers find them (`hakios_image_file("fw", name)`).

The files are the ones of ExyHyperBrick's LineageOS vendor trees, branch `lineage-24.0`, `proprietary/vendor/firmware/`
(the phone's `/vendor/firmware`): [`proprietary_vendor_samsung_star2lte`](https://github.com/ExyHyperBrick/proprietary_vendor_samsung_star2lte) and, for `dsm.bin` and the codec's
`cs47l92-dsp1-trace.wmfw`, [`proprietary_vendor_samsung_exynos9810-common`](https://github.com/ExyHyperBrick/proprietary_vendor_samsung_exynos9810-common). A phone's own copies can be checked against
the sums below (`adb shell sha256sum /vendor/firmware/<name>`).

| file | what it is (the S9 kernel's names) | sha256 |
|---|---|---|
| `calliope_sram.bin` | ABOX's CPU, its SRAM image (32-bit ARM; abox.c, the "calliope" firmware) | `15e443768304746d65df5b337932e169ab6d72a83ac40e823dd29764f5381cf2` |
| `calliope_dram.bin` | ABOX's CPU, its DRAM image (at IOVA 0x80000000 through ABOX's SysMMU) | `6fb029b854badc9d661b0cb6c633fb4575f3bb307ca35a03488fd21fcad2e6dd` |
| `calliope_iva.bin` | ABOX's CPU, its IVA image | `2455175a0f90f19b507b16ee4865b878a47ca88adfef28540f28130a502f9b6f` |
| `dsm.bin` | Maxim's DSM, speaker protection for the MAX98512s, run on ABOX (device tree: ABOX ext firmware) | `b8f136e6503a2aa83537180945070368e8f8bc0a321868ded91eaaa1c461587c` |
| `dsm_tune.bin` | DSM's tuning for the S9+'s speakers (ext firmware) | `ede5f9db689eb881a00b7e145ef9fe0e2093030b4c62cf64595b9c5009fabd7b` |
| `AP_AUDIO_SLSI.bin` | ABOX ext firmware named in the S9's device tree (Samsung's audio solutions) | `496c0e987570bf63ef896da7b2d2ea47eaa374306e763d73cac84b533c129765` |
| `APBargeIn_AUDIO_SLSI.bin` | ABOX ext firmware named in the S9's device tree (Samsung's audio solutions) | `473497d57873e2565859e1c3052f5065be1f902e319a7e6454174d8a5deab93c` |
| `APDV_AUDIO_SLSI.bin` | ABOX ext firmware named in the S9's device tree (Samsung's audio solutions) | `d6ede70c633a88b40111d0e1c65a97c3a884d590239f085c997c6c8888d61771` |
| `APBiBF_AUDIO_SLSI.bin` | ABOX ext firmware named in the S9's device tree (Samsung's audio solutions) | `2754c5dd15d6fd238b62157a53723b7b7b27c507178de3ad53d4bed397135c73` |
| `SoundBoosterParam.bin` | ABOX ext firmware named in the S9's device tree (Samsung's audio solutions) | `cea8f88628189e09fdbfbfd8f1eea68e455bfc9790a31fe722081b6a33693e85` |
| `cs47l92-dsp1-trace.wmfw` | the CS47L93 codec's DSP1 (madera); not needed for playback | `a2a45b4c255e6f71d7187e001a6439797537377c6d75222ebb9040a2c651fad0` |

**The S9+'s own.** Five of these differ from the Galaxy S9's (devices/starlte): `dsm_tune.bin` (the speakers' protection and tuning), `SoundBoosterParam.bin`, `AP_AUDIO_SLSI.bin`, `APDV_AUDIO_SLSI.bin` and `APBiBF_AUDIO_SLSI.bin`; they are the star2lte vendor tree's, pinned at `008b9fee9774`. The other six are byte for byte the S9's. The kernel's ABOX driver does not load ABOX's CPU (calliope) or its ext firmware yet, so today none of these is read; they are here so that when DSM is brought up it is with the S9+'s speaker tuning.
