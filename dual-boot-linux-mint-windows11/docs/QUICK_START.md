# Quick Start Guide
## Dual-Boot Setup in 30 Minutes

**For experienced users who want to get running fast**

---

## Prerequisites Check (2 minutes)

```powershell
# Windows - Run PowerShell as Admin
systeminfo | findstr /B /C:"Boot Mode" /C:"Secure Boot" /C:"TPM"
Get-TPM
msinfo32
```

✅ **Required:**
- UEFI boot mode
- TPM 2.0 enabled
- Two internal SSDs
- 8GB+ RAM
- Windows 11 already installed OR fresh system

---

## Step 1: Prepare Windows (5 minutes)

### If Windows Already Installed:

```powershell
# PowerShell as Administrator

# 1. Disable Fast Startup
powercfg /h off

# 2. Check BitLocker (must be OFF)
manage-bde -status C:
# If encrypted, run: manage-bde -off C:
# 3. Record product key
wmic path softwarelicensingservice get OA3xOriginalProductKey

# 4. Create restore point
Checkpoint-Computer -Description "Before Linux Dual Boot" -RestorePointType "MODIFY_SETTINGS"

# 5. Complete shutdown
shutdown /s /t 0
```

### If Fresh Install:
- Install Windows 11 on first SSD normally
- Complete all updates
- Run commands above

---

## Step 2: Install Linux Mint (15 minutes)

### ⚠️ CRITICAL: Physical Disconnection

**Power off completely, then:**

1. **Open computer case**
2. **Physically disconnect Windows SSD:**
   - SATA: Unplug both cables
   - M.2: Remove from slot
3. **Leave Linux SSD connected**

### Installation:

1. **Boot Linux Mint USB**
   - F11/F12 → Select USB
   - Choose "Start Linux Mint"