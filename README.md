<!-- SPDX-License-Identifier: MIT-0 -->
# Samsung Galaxy S9+ (star2lte, SM-G965F, Exynos 9810)

**Nothing in this repository has run on an S9+.** Nobody working on HakiOS has one. Everything here is written from
Samsung's device trees and the Galaxy S9 port ([scion-starlte](https://github.com/Scion-Project/scion-starlte)), which
has run on an S9. Every area in `device.conf` is "missing" (its note says what is written for it), and every
driver is off until its boot-argument. If you have an S9+ and want to try, read "First runs" below first, and keep
your EFS backup off the phone.

**The repository.** This is the Galaxy S9+'s device repository, checked out at `devices/star2lte` of
[Scion-Project/scion-kernel](https://github.com/Scion-Project/scion-kernel) (`devices/manifest.conf`,
`tools/hakios-device.py sync star2lte`). It shares as much as the tools allow with the S9's:

- The Exynos 9810's layer is `socs/exynos9810` in the common repository, shared with the S9 and the other phones with this SoC.
- The drivers are the common repository's, the S9's: Samsung's device trees put the same chips at the same addresses and
  pins on all three phones (the table below), and the drivers check for the Exynos 9810's register base, not for the S9.
- The loader's platform is the S9's, under this phone's name (`xnuloader/loader.c`, `platform_star2lte`, a sibling of
  `platform_starlte`). The only driver that reads the name is the battery's (`drivers/power/hakios.max77705.c`: this
  phone's capacity and thermistor table).
- `mkimage.sh` is one file, the same in this repository and the other (scion-crownlte): it takes the phone from the
  directory it is in.
- There is no UEFI here (below).

## What differs from the S9, and where each fact comes from

Read from Samsung's own device trees of the three phones, in Scion-Project's fork of Samsung's kernel
([`android_kernel_samsung_exynos9810`](https://github.com/Scion-Project/android_kernel_samsung_exynos9810), `lineage-24.0`,
`e5906667068e`: `arch/arm64/boot/dts/exynos/exynos9810-{starlte,star2lte,crownlte}_eur_open_26.dts`, board revision 26),
LineageOS's device trees (`android_device_samsung_{starlte,star2lte,crownlte}` and `exynos9810-common`, `lineage-20`),
TeamWin's `android_device_samsung_crownlte` and Silicium's `Mu-Silicium` (`4bd8ae8`). GPL sources were read for these facts
only. "Same" means the node, its address and its pins are the same in the device trees; it does not mean seen working.

| | Galaxy S9 (starlte, SM-G960F) | Galaxy S9+ (star2lte, SM-G965F) | Galaxy Note9 (crownlte, SM-N960F) | Source |
|---|---|---|---|---|
| SoC, GIC, timer, PMU, watchdogs | Exynos 9810; GIC-400 at 0x10101000/0x10102000; 26 MHz | same | same | DT `interrupt-controller`, `timer`, `system-controller@14060000`, `watchdog_cl0/cl1` |
| Panel | S6E3HA8 `s6e3ha8_star`, 1440 x 2960, 64 x 132 mm | S6E3HA8 `s6e3ha8_star2`, 1440 x 2960, 69 x 142 mm | S6E3HA8 `s6e3ha8_crown`, 1440 x 2960, 70 x 145 mm | DT `panel_drv@001` `panel-lookup`, `s6e3ha8_*_ddi` |
| DSI / DSC | DSIM0 0x16080000, DECON-F 0x16030000; DSC on, 2 slices, 2 encoders | same | same | DT `dsim@`, `decon_f@`, `s6e3ha8_*_ddi` (`dsc_en`, `dsc_slice_num`, `dsc_cnt`) |
| Boot framebuffer | 0xCC000000, 1440 x 2960 x 4 | 0xCC000000 (seen by the WoA port for the S9+) | 0xCC000000 assumed: nobody has looked | Silicium `starltePkg` MemoryMapLib; ntdevlabs/exynos9810-woa `Exynos9810.h` |
| Touch | S6SY761 (`sec,sec_ts`, firmware `y761_star1`) at 0x48, HSI2C 0x104B0000, IRQ gpa1-0, LDO35/LDO43 | S6SY761 (`y761_star2`), same bus, address, IRQ, supplies | `sec,sec_ts`, firmware `y771_crown` (by that name an S6SY771; Samsung's one `sec_ts` driver serves both), same bus, address, IRQ, supplies; a force-sensor GPIO | DT `touchscreen@48` |
| Pen | none | none | Wacom W9018 (`wacom,w90xx`) at 0x56 on HSI2C 0x10910000, LDO `wacom_ldo_en`, 14563 x 7085, 4096 levels | DT `wacom@56` |
| Keys | power gpa2-4, volume up gpa0-3, down gpa0-4, Bixby gpa0-6 | same pins | same pins (one pinctrl group for both volume keys) | DT `gpio_keys`, `key-*` |
| PMIC / charger / gauge | S2MPS18 + S2MPB02; MAX77705 at 0x66 on HSI2C 0x14360000; gauge capacity 2967 (3000 mAh) | same chips; 3303 (3500 mAh) | same chips; 3753 (4000 mAh) | DT `max77705@66`, `max77705-fuelgauge`, `battery` |
| Battery thermistor | ADC channel 4, the S9's table | channel 4, its own table | channel 4, its own table (39 points) | DT `battery` `temp_table_adc/_data` |
| Haptics | MAX77705 haptic, PWM channel 1, 20.48 kHz, 70 % duty at most | same, 75 % | same, 83 % | DT `haptic` (`duty`, `period`, `normal_ratio`) |
| Audio | CS47L93 codec (SPI 0x10470000), MAX98512 amplifiers on HSI2C 0x108C0000, ABOX | same | same (the amplifier's `ppr_param_info` added) | DT `cs47l93@0`, `max98512@39`, `sound` |
| Cameras | rear S5K2L3 (0x20); front S5K3H1 (0x6A) | rear S5K2L3 + S5K3M3 tele (0x5A); front S5K3H1 | rear S5K2L3 + S5K3M3 tele; front S5K3H1 | DT `fimc-is_sensor_*` |
| Wi-Fi / BT | BCM4361 on PCIe channel 0; BT on UART_BT | same | same | DT `wlan`, `bluetooth`, `pcie0` |
| RAM | 4 GB: 0x80000000-0xFFFFFFFF, 0x880000000-0x8FFFFFFFF | 6 GB: high bank to 0x97FFFFFFF | 6 GB or 8 GB (512 GB model): high bank to 0x97FFFFFFF or 0x9FFFFFFFF | Silicium `SamsungPkg/Library/RamManagerLib` (size from NS_IRAM + 0x848, written by S-Boot; high bank from 0x880000000) |
| reserved-memory | `modem_if` 0xF0000000 + 0x9200000, `cp_ram_logging` 0xF9200000 + 32 MB, `abox_rmem` 0xFB200000 + 40 MB, `exynos_ss` 0xFDA00000 (`log_pstore` 0xFED10000), `secure_camera` 0xE1900000 + 30 MB, `rkp_region` 0xAF800000 + 32 MB | same, but the camera CMA pool 440 MB (S9: 228 MB) | same as the S9+, but `rkp_region` 0xAF600000 + 36 MB | DT `reserved-memory` |
| Partitions (names) | BOOT, RECOVERY, SYSTEM, VENDOR, ODM, CACHE, USERDATA, EFS, CPEFS, RADIO, MISC, HIDDEN, ... | same names | same names | TWRP `recovery.fstab`, LineageOS `fstab.samsungexynos9810` |
| Partition sizes | BOOT 57671680, RECOVERY 68149248, SYSTEM 4561305600 bytes; USERDATA the rest (about 52 GB on the 64 GB S9) | same BOOT, RECOVERY, SYSTEM; USERDATA by storage (64/128/256 GB) | same BOOT, RECOVERY, SYSTEM; USERDATA by storage (128/512 GB) | LineageOS `BoardConfigCommon.mk` (one value for all three); the installer measures USERDATA |
| DTB / DTBO | the boot loader's own, from the DTB partition (a dtbh image chosen by board revision); none in the boot image | same scheme | same scheme | LineageOS `BOARD_KERNEL_SEPARATED_DT`, `dtbhtoolExynos`; Silicium `starlte.toml` |
| Boot image | header v1, page 2048, base 0x10000000, kernel offset 0x8000 | same | same | LineageOS `BoardConfigCommon.mk`; TeamWin crownlte `BoardConfig.mk` |
| Boot loader id | `ro.boot.bootloader` G960F..., device `starlte` | G965F..., `star2lte` | N960F..., `crownlte` | LineageOS `lineage_*.mk` |

## The UEFI

**There is no UEFI built for this phone, and none is built here.** Project Silicium's
[Mu-Silicium](https://github.com/Project-Silicium/Mu-Silicium) has `starltePkg` (the S9) and no `star2ltePkg` or
`crownltePkg`; its `Resources/Configs/` has `starlte.toml` and no sibling (checked at `4bd8ae8`, 29 October 2026, and in
its whole tree on GitHub). The WoA port for the S9+ ([ntdevlabs/exynos9810-woa](https://github.com/ntdevlabs/exynos9810-woa),
BSD-2-Clause-Patent) has a UEFI of its own for the S9+ (`Star2LtePkg`), built for Windows (ACPI, its own memory manager), not
a Silicium platform: it is a source of facts here, not something to boot this port with.

`mkimage.sh -U` borrows the S9's UEFI (`devices/starlte/prebuilt/SILICIUM_UEFI.fd` and `BootShim.bin`, HakiOS's build of
Silicium's `starltePkg`). Without `-U` it refuses to make an image. Why the S9's might start this phone, from reading its source:

- its RAM is not fixed in the image: Silicium's `RamManagerLib` reads the size S-Boot leaves at NS_IRAM + 0x848 and builds
  the high bank from 0x880000000 to fit, taking out the secure holes it reads at run time;
- its memory map (`devices/starlte/uefi/files/.../MemoryMapLib.c`) names only what is the same on all three: the UEFI's
  own place at 0x8F000000, the panel's buffer at 0xCC000000 (1440 x 2960 x 4), `secure_camera`, the payload's landing
  place at 0xF0000000, the pstore, and the SoC's registers;
- its keys (`KeypadDeviceLib`) read gpa0-3, gpa0-4, gpa0-6 and gpa2-4, the same pins on all three;
- the UFS controller, the GIC and Carbon's PSCI are the SoC's.

Why it might not: it has never been run on an S9+. S-Boot might place or check the boot image differently; the Note9's
framebuffer address has not been seen by anyone; the DTB in Silicium's `starlte.toml` is the S9's (HakiOS's image carries
none, so S-Boot uses the phone's own, but that path is unproven here). If the screen stays black after the Samsung logo,
hold Vol Down + Power, then Vol Down + Bixby + Power with USB plugged into Download mode, and flash the stock BOOT back
(or restore TWRP's backup from recovery).

What a native UEFI needs (not done, for whoever has the phone): a `star2ltePkg` in Mu-Silicium made from `starltePkg`
(`star2lte.dsc`, `.fdf`, `.dec`, `Include/APRIORI.inc` and `DXE.inc`, `MemoryMapLib`, `KeypadDeviceLib`), with the panel's
buffer read from the phone (`adb shell su -c 'cat /proc/iomem'`, or `s3cfb.bootloaderfb` on the kernel's command line
in `/proc/cmdline`), `Resources/Configs/star2lte.toml` as `starlte.toml` (FD base 0x8F000000, size 2 MB, no compression,
header v1), HakiOS's changes (`uefi/apply.sh star2lte` in the kernel repository, once a `devices/star2lte/uefi/files` exists),
then a `prebuilt/` here with its own README, hashes and licences. Nothing should go in `prebuilt/` that has not started
the phone.

## Memory layout

As the S9's (devices/starlte/README.md, "Memory layout") below 4 GB: `reserved-memory` is the same in the three device trees
but for the camera's CMA pool (a size, not an address) and the Note9's `rkp_region` (0xAF600000 + 36 MB instead of
0xAF800000 + 32 MB; EL2's and the secure world's, below the UEFI's heap end and well below the payload). So the loader's
values are the S9's: the payload moved to 0xD0000000, the keep-outs 0xF0000000-0xFB1FFFFF (the CP) and 0xFB200000-0xFD9FFFFF
(ABOX), the RAM log in `log_pstore` (0xFED10000), the DPU's buffers from 0xD4000000. Above 4 GB the bank is bigger:
0x880000000 to 0x97FFFFFFF, 4 GB (6 GB in all). XNU's window is the largest free block UEFI reports, at most 6 GB (`MAX_MEM_SIZE` in the loader, the
kernel's bootstrap page tables cover 8 GB), so on a 6 GB phone it gets about 4 GB, on an 8 GB Note9 6 GB. Nothing of
this has been seen: the loader's `layout:` and `largest free block` lines of the first run say what it really is.

## Build

In the kernel repository, with this repository and the S9's synced (`tools/hakios-device.py sync star2lte starlte`):

```sh
make star2lte_defconfig && make kernel && make loader     # the loader with your own IPSW's iPhone identity
(source ./xnu-env.sh; cd userland && GL=1 NO_AIR=1 REST=1 ALONE=1 RC=rc.launchd bash build.sh)   # the small root
devices/star2lte/mkimage.sh -U -s 60                       # xnu-star2lte.img: the S9's UEFI, a 60 s run
```

The universal TWRP installer (Scion-Project/scion-installer, `universal/`) makes this phone's boot image the same way.

## First runs

One image a flash, the log read in TWRP after each (`/sys/fs/pstore/pmsg-ramoops-0`, and over USB with `usb_gadget=5`).
Back up BOOT, SYSTEM and EFS in TWRP first and copy them off the phone.

1. `mkimage.sh -U -s 60` with nothing else (`cpus=2 bootcpu=2`): does the S9's UEFI start, does the loader say
   `platform star2lte (loader_platform=)`, what do `largest free block` and `layout:` say, does the run come back to TWRP
   after 60 s with the log in pstore.
2. `usb_gadget=5 max77705_usbsw=1`: the log live over USB (the same PHY and MUIC as the S9's).
3. `ufs=2 system_apfs=ufs_SYSTEM` with the installer's system image: iOS from the flash.
4. Then one driver a run, as the S9's README orders them: `exynos_keys=1`, `s6sy761=1` (the S9+'s chip is the S9's, with its own firmware), `max77705=1` (this
   phone's battery: the log says `max77705: the star2lte's battery`), `max77705_haptic=1`, `mali=9`, `cpufreq_lit=1794000`,
   `tmu=3`.

## What is missing

- A UEFI of its own (above).
- The panel's brightness: this phone's S6E3HA8 is the `star2` variant, with gamma and AOR tables of its own. The S9's
  driver (`CONFIG_HAKIOS_S6E3HA8`) is left out of this configuration.
- The tele camera (S5K3M3): no driver on any phone yet.
- The cellular modem, as on the S9.
