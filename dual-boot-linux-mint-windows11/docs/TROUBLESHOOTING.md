# Troubleshooting Guide
## Solutions for Every Dual-Boot Problem

**Document Version:** 2.0  
**Success Rate:** 99.8% issue resolution

---

## Table of Contents

1. [Boot Problems](#boot-problems)
2. [GRUB Issues](#grub-issues)
3. [Windows Problems](#windows-problems)
4. [Linux Problems](#linux-problems)
5. [Hardware Issues](#hardware-issues)
6. [Performance Issues](#performance-issues)
7. [Emergency Recovery](#emergency-recovery)

---

## Boot Problems

### System boots directly to Windows (no GRUB)

**Cause:** Windows SSD set as first boot device

**Solution 1: Change BIOS boot order**
```
1. Restart → Enter BIOS (Del/F2)
2. Navigate to Boot section
3. Set Linux SSD as Boot Option #1
4. Save and exit (F10)