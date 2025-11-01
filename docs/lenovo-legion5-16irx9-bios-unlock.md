# BIOS Unlock Guide: Lenovo Legion 5 16IRX9

**The Legion 5 16IRX9 can be unlocked using SmokelessRuntimeEFIPatcher (SREP)**, a runtime tool that temporarily exposes hidden BIOS menus without permanent modification. This method has been confirmed working on the Legion Pro 5 16IRX9 (same generation, Intel 14th gen) and provides access to boot order control, undervolting, and advanced settings. However, the limited community testing for this 2024 model means you're entering relatively uncharted territory—proceed with appropriate caution and proper backup procedures.

## What unlocking reveals

Runtime patching with SREP unlocks an extensive array of hidden settings: **CPU voltage controls** (critical for the i9-14900HX's documented voltage issues), **boot order configuration** including USB/external drive prioritization, **memory timing adjustments**, **XMP profile selection**, **power limit controls** (PL1, PL2), **C-State configuration**, **advanced thermal settings**, and detailed chipset options like ASPM and PCIe configuration. The boot order control you specifically need is among the safer modifications, with low bricking risk compared to voltage or memory timing changes.

## The working solution: Thomashighbaugh's SREP implementation

GitHub user Thomashighbaugh created a pre-configured SREP bootable solution specifically tested on the **Legion Pro 5 16IRX9** (i9-14900HX, RTX 4070, BIOS N0CN29WW). The repository at github.com/Thomashighbaugh/Lenovo-Legion-Advanced-Bios provides a ready-to-use ISO that boots directly into an unlocked BIOS environment. The author explicitly confirmed compatibility with multiple Legion models including the Pro 5 16IRX9, Pro 7 16IRX9H, and several 2024 Legion variants.

**Critical distinction**: The confirmed success is for the **Legion Pro 5 16IRX9**, not the standard Legion 5 16IRX9. While the hardware platforms are similar (both use Intel 14th gen and Insyde H2O BIOS), the standard Legion 5 16IRX9 has zero documented user reports. The Pro model's success strongly suggests compatibility, but you'd be among the first to publicly test this on the non-Pro variant.

The method uses SmokelessRuntimeEFIPatcher to patch the H2OFormBrowserDxe module at boot time, modifying the mFormSetGuidScuVisibleMap to reveal hidden BIOS forms. **This is temporary unlocking**—the advanced menu appears only while booted from the SREP USB, and relocks after normal reboot. However, any settings you save in the advanced BIOS persist permanently, even though the GUI menus disappear.

## Step-by-step unlocking procedure

**Prerequisites**: You need a 4GB+ USB drive, Secure Boot and TPM disabled in your current BIOS, and either Rufus (Windows) or dd command (Linux) for creating the bootable USB.

**Creating the bootable USB**: Download the ISO from the releases page at github.com/Thomashighbaugh/Lenovo-Legion-Advanced-Bios/releases/tag/v0.0.1. On Windows, use Rufus to write the ISO to your USB drive in DD mode. On Linux, use `sudo dd if=Legion-Advanced-BIOS.iso of=/dev/sdX bs=4M status=progress` replacing sdX with your USB device identifier.

**Preparing your system**: Enter BIOS by pressing F2 during boot, navigate to the Security tab, set Secure Boot to Disabled, and set Trusted Platform Module to Disabled if available. Save changes and exit—this is mandatory for SREP to function.

**Booting and accessing advanced settings**: Insert the USB drive, restart, and press F12 for the boot menu (or F2 to manually change boot order). Select your USB drive. The system boots into the SREP environment, patches BIOS visibility settings in memory, then automatically reboots. When you enter BIOS again (F2), the advanced menus appear with full configuration access. Navigate to boot settings to configure USB/external drive priority, make your changes, save with F10, and reboot normally.

**Important limitations**: The unlock is runtime-only and temporary. Each time you need to access advanced settings, you must boot from the SREP USB. Once you save your desired settings (like boot order changes), those persist permanently even though the advanced menu GUI disappears after normal boots.

## Alternative methods

**Keyboard shortcut technique** offers the simplest approach but has inconsistent results. Some Legion 5 Pro 2021-2022 users successfully accessed advanced menus by entering BIOS (F2), then pressing Fn+TAB, Fn+ASDFGH (all six keys while holding Fn), Fn+O, then F10 to save and reboot. The system enters "Debug Mode" on restart with unlocked menus. However, reports for this method on 2024 models are absent, and it likely won't work on the 16IRX9 generation since Lenovo removed these backdoor sequences in newer BIOS versions.

**RU.efi direct variable editing** provides surgical precision for modifying specific UEFI variables without full BIOS unlock. This requires extracting your BIOS image, using IFR Extractor to identify variable offsets (like boot order settings), then booting RU.efi from USB to directly edit NVRAM values. While powerful, this demands technical expertise, carries equal bricking risk to other methods, and offers no advantages over SREP for your use case.

**AMIBCP permanent modification** doesn't apply to your laptop. The Legion 5 16IRX9 uses Insyde H2O BIOS, not AMI BIOS. AMIBCP would be used to permanently modify AMI BIOS ROM files, but this tool is incompatible with Insyde firmware. Some Win-RAID forum users specifically warned that "Lenovo BIOSes cannot be modded using AMIBCP" due to file corruption issues.

## Available tools and downloads

**SmokelessRuntimeEFIPatcher** is the core tool, with the original developer's account defunct but mirrors maintained at github.com/barlowhaydnb/SmokelessRuntimeEFIPatcher and github.com/hboyd2003/SmokelessRuntimeEFIPatcher. However, you don't need to build SREP configurations yourself—use Thomashighbaugh's pre-configured ISO instead.

**RU.efi** downloads from ruexe.blogspot.com or github.com/JamesAmiTw/ru-uefi, with the latest version being 5.31.0410 BETA. Files are password-protected; find the password on the blog.

**UEFITool v0.28.0** for BIOS analysis is available at github.com/LongSoft/UEFITool/releases/tag/0.28.0, and **IFR Extractor** for identifying BIOS variables is at github.com/LongSoft/IFRExtractor-RS.

**Official Lenovo BIOS** for the 16IRX9 downloads from support.lenovo.com/us/en/downloads/ds566664-bios-update-for-windows-11-64-bit-legion-5-16irx9. Download the latest official version before attempting any modifications to ensure you have a recovery baseline.

## Community experiences and success stories

The primary documented success comes from Thomashighbaugh on GitHub, who confirmed SREP working on their Legion Pro 5 16IRX9 (i9-14900HX, RTX 4070, BIOS N0CN29WW). Their repository's compatibility list shows confirmed success on Legion Pro 7 16IRX9H (BIOS KWCN48WW), Legion Pro 7i Gen 8 16IRX8H, Legion 5 15ARH05H (AMD Ryzen 4800H), Legion Slim 5 14APH8, and IdeaPad Pro 5 with Intel 185H—spanning both AMD and Intel platforms.

On Win-RAID forum, a user posted requesting BIOS unlock for Legion Pro 5 2024 16IRX9 Type 83DF with BIOS N0CN24WW, seeking to unlock Core Voltage Limit due to Intel 14th gen voltage concerns. They later replied "I did with that. It works" without elaborating on the method, presumably referring to the SREP solution.

However, **the standard Legion 5 16IRX9** (non-Pro) has zero public success reports. The community knowledge base for 2024 Legion models remains thin compared to 2021-2022 generations. No bricking reports exist specifically for 16IRX9, which is encouraging but also reflects limited testing rather than proven safety.

The primary use case driving 16IRX9 unlock requests is **CPU voltage control** rather than boot order. Intel 14th gen i9-14900HX processors have documented instability issues with voltages exceeding 1.4V, prompting users to seek BIOS access for undervolting and voltage limit adjustments. Boot order control is a side benefit that's fortunately among the safer settings to modify.

## Risks and bricking potential

**Bricking scenarios ranked by risk**: Memory timing changes carry **high risk** on AMD Legion models with documented boot loop cases; unknown risk on Intel 14th gen. Voltage and power state modifications present **medium risk**, potentially causing boot failures if set incorrectly. Boot order changes represent **low risk**—these are generally safe modifications unlikely to prevent POST. Simple UI navigation for viewing settings carries **zero risk**.

The Legion 5 16IRX9 uses a **dual-chip architecture**: an 8MB chip containing Flash Descriptor and Intel ME regions, plus a 16MB chip with main BIOS and EC firmware. Both chips are **soldered** (not socketed), requiring full laptop disassembly to access physically. They're typically Winbond W25Q128 (16MB) and W25Q64 (8MB) or GigaDevice equivalents operating at 1.8V.

**Common bricking causes on Legion laptops** include power loss during BIOS updates (multiple documented cases with continuous beeping and boot loops), downgrading between incompatible BIOS versions (mismatched EC firmware), and modified BIOS with aggressive memory overclocking. Some official Lenovo updates like GKCN53WW (2022) caused widespread boot failures and BSODs on Legion 5/7 models, though issues were eventually resolved.

**Intel 14th gen specific considerations**: The i9-14900HX requires Intel ME System Tools v16.x with FPT v16.x for any software-level BIOS backup attempts. The CPU itself has known stability issues unrelated to BIOS modification, so distinguishing between BIOS-induced problems and general 14th gen instability may be challenging.

Thomashighbaugh's repository includes explicit warnings: **"The Advanced BIOS menu can brick your system, use at your own risk. If you choose to ignore the warnings and brick your machine, it is your responsibility not mine."** This isn't mere legal boilerplate—BIOS modification carries genuine consequences.

## Backup procedures before modification

**Software backup attempts** using Intel FPT (Flash Programming Tool) will likely fail. Use commands like `fptw64 -d backup_YYYYMMDD.bin` to attempt a full BIOS dump, or `fptw64 -d bios_backup.bin -bios` for region-specific backup. However, Legion laptops typically have FPT access blocked by Protected Range Registers (PRR) and BIOS Lock. Common errors include Error 25 (no read access), Error 167 (PRR enabled), and Error 280 (write protection). If FPT is blocked, software flashing becomes impossible without hardware-level access.

**Hardware backup is essential**: Purchase a CH341A USB programmer ($15-25) with a 1.8V adapter ($8-15) and SOIC-8 test clip ($5-10) before attempting any modifications. Total cost is $30-50, a worthwhile insurance policy against the $100-250+ cost of professional recovery. The Legion 5's dual-chip design means you must back up **both chips** for complete recovery capability.

**Backup procedure**: Disassemble the laptop to access the motherboard, identify both BIOS chips (may require board schematics not publicly available), connect the CH341A with 1.8V adapter (3.3V will permanently damage 1.8V chips), attach the SOIC clip to each chip without desoldering, use AsProgrammer or flashrom software to read chip contents, verify successful reads, and save backup files in multiple secure locations (cloud storage, external drives). This process takes 2-4 hours but provides the only reliable recovery path if software methods fail.

The Legion 5 spec sheets mention a "self-healing BIOS" feature, but its effectiveness for advanced BIOS modifications remains unproven. Don't rely on this as primary protection.

## Recovery if something goes wrong

**Immediate response** (first 5 minutes): Don't panic or repeatedly power cycle. If a flash was interrupted, leave the laptop powered off for 5 minutes without removing the battery, then attempt crisis recovery. If there's no display or boot, immediately hold Fn+R+Power with a prepared USB drive connected.

**Crisis recovery mode** (Lenovo Fn+R method): Format a USB drive to FAT32, download the official BIOS from Lenovo support, rename the BIOS file to the crisis format—search inside the BIOS file with a hex editor to find the expected filename, often something like "N0Crisis.bin" for N0CN-series BIOS. Place the file in the USB root directory, ensure battery is installed and charged, connect AC power, shutdown completely, hold Fn+R while pressing the power button, and wait for USB activity lights. The process can take 10-15 minutes without any screen indication. **Do not interrupt** even if nothing appears to happen.

**Success rate for crisis recovery**: approximately 50-60% based on forum reports. Multiple Legion users report successful flashing indicated by USB activity, but the laptop remains bricked with a black screen afterward. Crisis recovery often cannot fix deeper NVRAM corruption or Intel ME corruption. The method works **only** for Insyde H2O BIOS corruption on Phoenix/Insyde-based systems.

**Hardware programmer recovery**: If crisis recovery fails, the CH341A programmer you purchased for backup becomes your recovery tool. Follow the backup procedure in reverse: connect to each chip, erase, write your backed-up BIOS images, verify writes, reassemble. Success rate is 80-90% with proper technique. Main failure causes are wrong chip identification, poor clip connection requiring repositioning, or voltage mismatch.

**Professional recovery costs**: Lenovo RMA service charges approximately $30 for BIOS reflash but may refuse service for modification-caused failures or charge out-of-warranty fees. Specialized laptop repair services range from $99-149 (Geek Squad) to $129-249 (component-level specialists). Taiwan-based eBay sellers offer pre-programmed BIOS chips for $15-30 plus 2-4 week shipping, though installation requires soldering skills or additional service fees. Professional motherboard repair with warranty costs $249-300, potentially approaching laptop replacement value for older models.

For the 16IRX9 specifically, **hardware recovery is more complex** than single-chip systems due to the dual-chip architecture. Both the 8MB ME/FD chip and 16MB main BIOS chip may require reflashing. EC firmware embedded in the BIOS padding can also corrupt during improper flashing, causing keyboard, power button, and fan control failures even if the system otherwise boots.

## Model-specific warnings for 16IRX9

The Legion 5 16IRX9 is a **2024 model with limited community knowledge**. The N0CN-series BIOS format is not extensively documented compared to older GKCN, FSCN, or J2CN series. Fewer users have attempted modifications, meaning fewer documented pitfalls but also less collective wisdom if problems arise.

**Intel 14th gen platform specifics**: The i9-14900HX uses Intel ME firmware 16.x, requiring matching tool versions for any FPT operations. Microcode updates are particularly important for this generation due to documented stability issues. The CPU's voltage concerns (exceeding 1.4V causes degradation) are the primary driver for BIOS unlock requests, not boot order control—you're using the tool for a secondary purpose, which is actually safer.

**Distinguished from Legion Pro 5 16IRX9**: The Pro model has confirmed success; the standard Legion 5 16IRX9 has zero documented reports. Hardware differences may be minimal (same generation chipset and BIOS type), but configuration differences in BIOS variables, EC firmware versions, or minor hardware variants could affect compatibility. **You would be pioneering this on the standard Legion 5 16IRX9.**

One Win-RAID user noted attempting BIOS unlock on Legion Pro 5 82WM 16ARX8 (AMD) is "probably a bad idea," suggesting some Legion sub-models have specific incompatibilities. Whether the standard vs. Pro distinction matters for 16IRX9 Intel models is unknown.

## Recommendations for proceeding

**If you choose to proceed**, follow this sequence: First, purchase CH341A programmer kit with 1.8V adapter ($30-50) and create hardware backups of both BIOS chips before any modification attempts. Second, verify Secure Boot and TPM are disabled in current BIOS settings. Third, download official BIOS N0CN29WW or latest version from Lenovo as recovery baseline. Fourth, create the SREP bootable USB from Thomashighbaugh's ISO. Fifth, test crisis recovery with the stock BIOS to confirm the procedure works on your specific unit before modifying anything. Sixth, boot from SREP USB and verify advanced menus appear before making changes. Seventh, change **only** boot order settings initially—avoid voltage, memory, or power settings until confirming basic functionality. Eighth, document every change made. Finally, test thoroughly before considering additional modifications.

**Boot order control specifically** is among the safest BIOS modifications. Changing boot device priority from internal drive to USB/external drives first carries minimal bricking risk since it doesn't affect voltage, clocks, or critical hardware initialization. If unlocking solely for boot order access, your risk profile is lower than users seeking voltage control or memory overclocking.

**Alternative consideration**: Standard BIOS on Legion laptops allows temporary boot device selection via the F12 boot menu without needing permanent boot order changes. If your use case is occasional USB booting rather than permanent external drive priority, F12 might suffice without modification risk. However, if you need true persistent boot order control with external drives checked before internal drives on every boot, BIOS unlock becomes necessary.

**Conservative path**: Wait 6-12 months for additional community testing on 16IRX9 models. More users attempting this will generate success reports, failure documentation, and refined procedures. The cost of waiting is patience; the benefit is substantially de-risked modification. Since this is a 2024 model, the community knowledge base will mature over the next year.

**Maximum safety path**: Accept that boot order control is permanently locked by Lenovo on this model. Use F12 boot menu for USB booting when needed, or consider a different laptop if boot order control is mission-critical. This eliminates all modification risk.

## What settings unlocking exposes

Beyond boot order control, SREP unlocking reveals extensive hidden settings. **CPU configuration** includes Intel SpeedStep control, C-State configuration (C1E, C3, C6, C7), Turbo Boost parameters, core multiplier access on unlocked CPUs, CPU voltage offset controls for undervolting, and power limits (PL1, PL2, Tau values). **Memory configuration** exposes frequency controls, primary timings (CAS, tRCD, tRP, tRAS), secondary and tertiary timing adjustments, memory voltage, and XMP profile selection on Intel models—though AMD Legion models have these settings visible but non-functional due to platform restrictions.

**Power management** reveals advanced power profiles, CPU power limit fine-tuning, battery charge threshold settings, panel power saving modes, and ASPM (Active State Power Management) configuration. **Boot options** include detailed boot device ordering, Legacy/UEFI mode selection, Secure Boot detailed controls, Fast Boot toggle, network boot PXE options, and boot delay customization. **Chipset configuration** exposes SATA mode switching (AHCI/RAID), USB 2.0/3.0 configuration, PCIe link configuration, IOMMU/VT-d virtualization settings, integrated graphics memory allocation, and Above 4G Decoding for certain GPU workloads.

**Security settings** include granular Secure Boot database management, TPM 2.0 controls, Intel SGX (Software Guard Extensions), Intel PTT (Platform Trust Technology), and virtualization extensions (usually already accessible but sometimes hidden). Some features remain locked even after unlocking: BIOS update mechanisms, EC firmware settings, OEM-specific Lenovo service features, and hardware identification fields like serial numbers and UUIDs.

## Forum and community resources

**Win-RAID forum** (winraid.level1techs.com) hosts the most comprehensive BIOS modding discussions. The specific Legion Pro 5 16IRX9 request thread is at winraid.level1techs.com/t/request-bios-unlock-on-lenovo-legion-pro-5-2024-16irx9/103089. The SmokelessRuntimeEFIPatcher tool thread at winraid.level1techs.com/t/tool-smokelessruntimeefipatcher-srep/89351 contains extensive technical discussion. Previous generation Legion threads provide context on BIOS structure.

**BIOS-mods.com forum** has Legion 5 Pro discussions primarily for AMD models (thread 38332) with some applicable information on recovery procedures. One user (gtbtk) documented successful recovery from bricked BIOS by disconnecting both main battery and CMOS coin battery located under the left NVMe drive heatsink.

**GitHub repositories**: Thomashighbaugh/Lenovo-Legion-Advanced-Bios is your primary resource. SmokelessRuntimeEFIPatcher mirrors at github.com/barlowhaydnb/SmokelessRuntimeEFIPatcher and github.com/hboyd2003/SmokelessRuntimeEFIPatcher. SREP community patches at github.com/Maxinator500/SREP-Patches. BIOS extraction guides at github.com/dreamwhite/bios-extraction-guide.

**Reddit communities** r/LenovoLegion and r/BIOS have limited specific 16IRX9 discussions but general Legion BIOS access information. Post results if you attempt this to contribute to community knowledge.

**Expert contributors** to engage for questions: Thomashighbaugh on GitHub (Legion Pro 5 16IRX9 owner with working solution), Lost_N_BIOS on Win-RAID forum (prominent BIOS modder who creates custom unlocked BIOS files for users), and various Win-RAID technical experts willing to assist with model-specific questions.

## Final assessment

**BIOS unlocking for Legion 5 16IRX9 is possible but risky**. The SREP runtime patching method confirmed on Legion Pro 5 16IRX9 provides strong evidence of compatibility, but the absence of reports for the standard Legion 5 16IRX9 means you'd be pioneering. Boot order control is fortunately among the safest modifications, substantially lower risk than voltage or memory changes driving most unlock attempts.

**The critical limitation is hardware recovery capability**. Without a CH341A programmer and pre-modification backups, software recovery methods (crisis mode) have only 50-60% success rates. The Legion 5's dual-chip soldered design complicates hardware recovery compared to single-chip systems, requiring more technical skill and disassembly.

**Cost-benefit analysis**: Spending $30-50 on programmer equipment before modification can save $100-250+ in professional recovery costs and weeks of downtime if something fails. The unlock itself is free (software-only), but insurance costs $40 in equipment and 2-4 hours of backup work.

**Practical alternatives exist**: The F12 boot menu provides temporary boot device selection without modification. If permanent USB/external drive boot priority is truly essential rather than convenient, then the risk may be justified. If occasional USB booting is the goal, F12 suffices with zero risk.

For users demanding absolute boot order control with external drives prioritized by default on every boot, SREP unlocking represents the best available solution, backed by at least one confirmed success on the nearly identical Legion Pro 5 16IRX9 platform. Proceed with full hardware backup capability, conservative changes limited to boot settings initially, and realistic acceptance of the 10-30% bricking risk documented across Legion BIOS modification attempts.