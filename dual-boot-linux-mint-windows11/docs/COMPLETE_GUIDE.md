# Complete Installation Guide
## Dual-Boot Linux Mint & Windows 11 on Separate SSDs

**Document Version:** 2.0  
**Last Updated:** November 2025  
**Time Required:** 2-3 hours  
**Difficulty:** Beginner to Intermediate

---

## Table of Contents

1. [Pre-Installation Checklist](#pre-installation-checklist)
2. [BIOS/UEFI Configuration](#biosuefi-configuration)
3. [Windows 11 Installation](#windows-11-installation)
4. [Linux Mint Installation](#linux-mint-installation)
5. [GRUB Configuration](#grub-configuration)
6. [Post-Installation Setup](#post-installation-setup)
7. [Verification Steps](#verification-steps)
8. [Advanced Configuration](#advanced-configuration)

---

## Pre-Installation Checklist

### ✅ Hardware Requirements

**Essential:**
- [ ] Two internal SSDs (NVMe or SATA)
  - Drive 1: Windows 11 (minimum 120GB, recommended 256GB+)
  - Drive 2: Linux Mint (minimum 50GB, recommended 120GB+)
- [ ] 8GB+ RAM (16GB recommended)- [ ] UEFI firmware (not Legacy BIOS)
- [ ] 64-bit processor with TPM 2.0 support

**Verify in BIOS:**
```
During boot, press Del/F2/F10
Check System Information:
- UEFI Version: Should show version number
- TPM: Should show 2.0 or fTPM
- Secure Boot: Capable (can be disabled)
```

### ✅ Software Preparation

**Download Required:**
1. **Windows 11 ISO** (8GB+)
   - Official: https://www.microsoft.com/software-download/windows11
   - Create USB with Rufus or Media Creation Tool
   
2. **Linux Mint 22 Cinnamon** (3GB)
   - Official: https://linuxmint.com/download.php
   - Create USB with Rufus/Etcher/dd

3. **Recovery Tools** (Optional but recommended)
   - Boot-Repair-Disk ISO
   - SystemRescue ISO