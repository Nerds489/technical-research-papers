# Dual-Boot Troubleshooting Reference
## Linux Mint + Windows 11 on Separate SSDs

**Quick problem diagnosis and resolution guide**

---

## Table of Contents

1. [Boot Problems](#boot-problems)
2. [GRUB Issues](#grub-issues)
3. [Windows Boot Issues](#windows-boot-issues)
4. [Drive Access Issues](#drive-access-issues)
5. [Performance Problems](#performance-problems)
6. [Update Issues](#update-issues)
7. [UEFI/BIOS Problems](#uefibios-problems)
8. [Recovery Procedures](#recovery-procedures)
9. [Diagnostic Commands](#diagnostic-commands)

---

## Boot Problems

### System Won't Boot - Black Screen

**Symptoms:** Power on, black screen, no GRUB, no OS

**Diagnosis:**
```bash
# Boot from Live USB

# Check if drives are detected
sudo fdisk -l
# Should show both SSDs

# Check EFI partitions
sudo blkid | grep vfat

# Check for UEFI boot entries
sudo efibootmgr -v
```

**Common Causes & Solutions:**

#### **Cause 1: Wrong Boot Order**
```
BIOS set to boot from wrong drive

Fix:
1. Enter BIOS (Del/F2/F10)
2. Boot section
3. Set Linux SSD as 1st boot device
4. Save and exit
```

#### **Cause 2: GRUB Corrupted**
```
Bootloader damaged or deleted

Fix:
# Boot from Linux Mint USB
sudo mount /dev/nvme0n1p2 /mnt  # Root partition
sudo mount /dev/nvme0n1p1 /mnt/boot/efi  # EFI
for i in /dev /dev/pts /proc /sys /run; do sudo mount --bind "$i" "/mnt$i"; done
sudo chroot /mnt
grub-install /dev/nvme0n1
update-grub
exit
sudo umount -R /mnt
reboot
```

#### **Cause 3: EFI Partition Damaged**
```
File system corruption on EFI partition

Fix:
# Boot from Live USB
sudo fsck.fat -a /dev/nvme0n1p1  # EFI partition
# If errors persist:
sudo mkfs.fat -F32 /dev/nvme0n1p1  # DESTRUCTIVE - reformats EFI
# Then reinstall GRUB (see Cause 2)
```

---

### GRUB Prompt Instead of Menu

**Symptoms:** `grub>` or `grub rescue>` prompt appears

**Diagnosis:**
```bash
# At grub rescue prompt
grub rescue> ls
# Shows: (hd0) (hd0,gpt1) (hd0,gpt2) (hd1) (hd1,gpt1)

grub rescue> ls (hd0,gpt1)/
# Repeat for each partition until you find one with /boot folder
```

**Solutions:**

#### **Method 1: Boot from GRUB Rescue**
```bash
# Find Linux partition (the one with /boot folder)
grub rescue> ls (hd0,gpt2)/boot
# Should show files

# Set root
grub rescue> set root=(hd0,gpt2)
grub rescue> set prefix=(hd0,gpt2)/boot/grub

# Load normal mode
grub rescue> insmod normal
grub rescue> normal

# After booting to Linux:
sudo grub-install /dev/nvme0n1
sudo update-grub
```

#### **Method 2: Reinstall GRUB**
```bash
# Boot from Live USB
# Follow "Cause 2: GRUB Corrupted" solution above
```

---

### System Boots Directly to Windows

**Symptoms:** GRUB never appears, always boots Windows

**Diagnosis:**
```powershell
# In Windows PowerShell
bcdedit /enum firmware
# Shows boot entries
```

**Solutions:**

#### **Solution 1: Fix Boot Order in BIOS**
```
1. Restart and enter BIOS (Del/F2/F10)
2. Navigate to Boot section
3. Move Linux SSD to 1st position
4. Move Windows SSD to 2nd position
5. Save and exit
```

#### **Solution 2: Fix EFI Boot Order**
```bash
# In Linux
sudo efibootmgr -v
# Note boot numbers

# Set Linux first (example numbers, adjust to yours)
sudo efibootmgr -o 0002,0001,0000

# Verify
sudo efibootmgr -v
# BootOrder should show Linux first
```

#### **Solution 3: Re-enable GRUB**
```bash
# Windows may have set itself as default
sudo grub-install /dev/nvme0n1
sudo update-grub
sudo reboot
```

---

### GRUB Menu Doesn't Appear

**Symptoms:** System boots directly to Linux without showing menu

**Diagnosis:**
```bash
# Check GRUB config
cat /etc/default/grub | grep TIMEOUT
cat /etc/default/grub | grep HIDDEN
```

**Solutions:**

#### **Solution 1: Increase Timeout**
```bash
sudo nano /etc/default/grub

# Find and change:
GRUB_TIMEOUT=0
# To:
GRUB_TIMEOUT=10

# Comment out or remove:
#GRUB_TIMEOUT_STYLE=hidden
#GRUB_HIDDEN_TIMEOUT=0

sudo update-grub
sudo reboot
```

#### **Solution 2: Hold Shift During Boot**
```
Press and hold Shift key immediately after BIOS/UEFI screen
GRUB menu will appear even if hidden
```

#### **Solution 3: Show Menu Always**
```bash
sudo nano /etc/default/grub

# Add/change:
GRUB_TIMEOUT=10
GRUB_TIMEOUT_STYLE=menu

# Remove:
# GRUB_HIDDEN_TIMEOUT=0

sudo update-grub
```

---

## GRUB Issues

### Windows Not in GRUB Menu

**Symptoms:** GRUB menu shows Linux options only, no Windows entry

**Diagnosis:**
```bash
# Check if os-prober is disabled
grep GRUB_DISABLE_OS_PROBER /etc/default/grub

# Manually check for Windows
sudo os-prober

# Check EFI entries
sudo efibootmgr -v | grep -i windows

# Check if Windows EFI exists
sudo ls /boot/efi/EFI/
# Should show "Microsoft" folder

# Check Windows drive is connected
sudo fdisk -l | grep -i microsoft
```

**Solutions:**

#### **Solution 1: Enable os-prober**
```bash
sudo nano /etc/default/grub

# Find line:
#GRUB_DISABLE_OS_PROBER=true

# Change to:
GRUB_DISABLE_OS_PROBER=false

# Save and exit (Ctrl+O, Enter, Ctrl+X)

# Update GRUB
sudo apt install os-prober  # If not installed
sudo update-grub

# Should see: "Found Windows Boot Manager on /dev/..."
```

#### **Solution 2: Mount Windows EFI Partition**
```bash
# If Windows EFI is not automatically mounted
sudo mkdir -p /mnt/winefi
sudo mount /dev/nvme1n1p1 /mnt/winefi  # Adjust device
sudo update-grub
sudo umount /mnt/winefi
```

#### **Solution 3: Manual GRUB Entry**
```bash
# Get Windows EFI UUID
sudo blkid | grep vfat
# Find Windows EFI partition UUID (usually 100-500MB)

# Edit custom GRUB entries
sudo nano /etc/grub.d/40_custom

# Add (replace UUID with yours):
menuentry 'Windows 11' --class windows --class os {
    insmod part_gpt
    insmod fat
    insmod chain
    search --no-floppy --fs-uuid --set=root 1CE5-7F28
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}

# Save and update
sudo chmod +x /etc/grub.d/40_custom
sudo update-grub
sudo reboot
```

#### **Solution 4: Using Device Path**
```bash
# If UUID method doesn't work
sudo nano /etc/grub.d/40_custom

# Add:
menuentry 'Windows 11' --class windows --class os {
    insmod part_gpt
    insmod fat
    insmod chain
    set root='(hd1,gpt1)'  # hd1 = second drive, gpt1 = first partition
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}

sudo update-grub
```

---

### GRUB Error: "error: file '/boot/grub/i386-pc/normal.mod' not found"

**Symptoms:** Error message at boot, drops to `grub rescue>` prompt

**Cause:** GRUB installed in Legacy mode but system using UEFI

**Diagnosis:**
```bash
# Boot from Live USB
sudo fdisk -l
# Look for partition types:
# "EFI System" = UEFI mode
# "Microsoft basic data" only = Legacy mode possible

# Check current boot mode
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "Legacy"
```

**Solution:**
```bash
# Boot from Live USB

# Reinstall GRUB in UEFI mode
sudo mount /dev/nvme0n1p2 /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot/efi
for i in /dev /dev/pts /proc /sys /run; do sudo mount --bind "$i" "/mnt$i"; done
sudo chroot /mnt

# Remove Legacy GRUB
apt remove grub-pc
apt autoremove

# Install UEFI GRUB
apt install grub-efi-amd64-signed shim-signed
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=LinuxMint
update-grub

exit
sudo umount -R /mnt
reboot
```

---

### GRUB Updates Break Boot Menu

**Symptoms:** After running `apt upgrade`, GRUB menu changed or broken

**Diagnosis:**
```bash
# Check GRUB package version
dpkg -l | grep grub

# Check for pending kernel updates
dpkg -l | grep linux-image
```

**Solutions:**

#### **Solution 1: Regenerate GRUB Config**
```bash
sudo update-grub
sudo reboot
```

#### **Solution 2: Reinstall GRUB Packages**
```bash
sudo apt install --reinstall grub-efi-amd64-signed shim-signed
sudo grub-install /dev/nvme0n1
sudo update-grub
sudo reboot
```

#### **Solution 3: Boot Previous Kernel**
```bash
# At GRUB menu
# Select: "Advanced options for Linux Mint"
# Choose previous kernel version
# Boot successfully

# Remove problematic kernel:
dpkg -l | grep linux-image  # Find problematic version
sudo apt remove linux-image-X.XX.X-XX-generic
sudo update-grub
```

---

## Windows Boot Issues

### Windows Won't Boot - Error Message

**Common Error Messages:**

#### **"Your PC ran into a problem and needs to restart"**

**Diagnosis:**
```cmd
# Boot from Windows Recovery USB
# Advanced options → Command Prompt

chkdsk C: /f /r
# Check for disk errors
```

**Solution:**
```cmd
# Repair boot files
bootrec /fixmbr
bootrec /fixboot
bootrec /scanos
bootrec /rebuildbcd

# If that fails, reinstall bootloader:
diskpart
list disk
select disk 1  # Your Windows SSD
list partition
select partition 1  # EFI partition
assign letter=S
exit

bcdboot C:\Windows /s S: /f UEFI
```

#### **"Missing operating system" or "No bootable device"**

**Cause:** BIOS not finding Windows bootloader

**Solution:**
```
1. Enter BIOS
2. Check both drives are detected
3. Set Windows SSD as boot device
4. Save and exit

If still fails:
# Boot Windows Recovery USB
# Rebuild bootloader (commands above)
```

#### **"INACCESSIBLE_BOOT_DEVICE"**

**Cause:** Driver or partition issue

**Solution:**
```cmd
# Boot Windows Recovery USB
# Advanced options → Command Prompt

# Check drives
diskpart
list disk
list volume
# Verify C: is accessible

# Repair Windows
dism /online /cleanup-image /restorehealth
sfc /scannow
```

---

### Blue Screen (BSOD) After Switching from Linux

**Symptoms:** Windows was working, booted Linux, then Windows blue screens

**Common Causes:**
1. Fast Startup not disabled
2. Windows partition mounted read-write in Linux
3. Time/date corruption
4. Hardware state change

**Solutions:**

#### **Solution 1: Safe Mode Boot**
```
1. Boot Windows Recovery USB
2. Troubleshoot → Advanced → Startup Settings
3. Restart
4. Press 4 for Safe Mode

In Safe Mode:
powercfg /h off  # Disable Fast Startup
sfc /scannow  # Check system files
chkdsk C: /f  # Check disk

Restart normally
```

#### **Solution 2: Fix Time Issues**
```powershell
# In Windows Safe Mode or normal boot
net stop w32time
w32tm /unregister
w32tm /register
net start w32time
w32tm /resync /force
```

#### **Solution 3: System Restore**
```
1. Boot Windows Recovery USB
2. Troubleshoot → Advanced → System Restore
3. Select restore point before Linux boot
4. Restore
```

---

### Windows Update Broke Dual-Boot

**Symptoms:** After Windows update, can't boot Linux

**Diagnosis:**
```bash
# Boot from Linux Mint USB

# Check GRUB still exists
sudo ls /boot/efi/EFI/LinuxMint
# OR
sudo ls /boot/efi/EFI/ubuntu

# Check EFI boot entries
sudo efibootmgr -v
```

**Solutions:**

#### **Solution 1: GRUB Still Exists, Boot Order Changed**
```bash
# Boot from Live USB (if needed)

# Fix boot order
sudo efibootmgr -v
# Find Linux entry (e.g., Boot0002)

# Set as first
sudo efibootmgr -o 0002,0001,0000  # Adjust numbers

# Reboot
```

#### **Solution 2: GRUB Deleted by Windows**
```bash
# Boot from Live USB

# Reinstall GRUB
sudo mount /dev/nvme0n1p2 /mnt
sudo mount /dev/nvme0n1p1 /mnt/boot/efi
for i in /dev /dev/pts /proc /sys /run; do sudo mount --bind "$i" "/mnt$i"; done
sudo chroot /mnt

grub-install /dev/nvme0n1
update-grub

exit
sudo umount -R /mnt
reboot
```

---

## Drive Access Issues

### Can't Mount Windows Drive from Linux

**Error:** "The disk contains an unclean file system" or "Could not mount"

**Diagnosis:**
```bash
# Check if Windows partition exists
sudo fdisk -l | grep NTFS

# Try mounting
sudo mount -t ntfs-3g /dev/nvme1n1p3 /mnt/windows
# Note the exact error message
```

**Common Causes & Solutions:**

#### **Cause 1: Fast Startup Enabled**
```
Windows didn't fully shut down

Fix in Windows:
powercfg /h off
shutdown /s /t 0

Then in Linux:
sudo mount -t ntfs-3g /dev/nvme1n1p3 /mnt/windows
```

#### **Cause 2: Hibernation File Present**
```bash
# Force mount read-only
sudo mount -t ntfs-3g -o ro /dev/nvme1n1p3 /mnt/windows

# If you need read-write:
# Boot into Windows
powercfg /h off  # Disable hibernation
shutdown /s /t 0  # Full shutdown

# Then in Linux:
sudo mount -t ntfs-3g -o rw /dev/nvme1n1p3 /mnt/windows
```

#### **Cause 3: Filesystem Corruption**
```bash
# Fix from Linux (use with caution!)
sudo ntfsfix /dev/nvme1n1p3

# If that doesn't work, fix from Windows:
# Boot Windows Recovery
chkdsk C: /f /r
```

#### **Cause 4: BitLocker Encryption**
```
Cannot mount encrypted partition from Linux

Fix:
# Boot Windows
# Disable BitLocker completely
Settings → Privacy & Security → Device Encryption → Off
# Wait for full decryption
# Shut down
# Then mount from Linux
```

---

### Permission Denied on Shared Partition

**Symptoms:** Can access shared drive but can't create/modify files

**Diagnosis:**
```bash
# Check current mount options
mount | grep shared

# Check ownership
ls -la /mnt/shared
```

**Solutions:**

#### **Solution 1: Remount with Correct Permissions**
```bash
# Unmount
sudo umount /mnt/shared

# Remount with proper options
sudo mount -t ntfs-3g -o uid=1000,gid=1000,dmask=022,fmask=133 /dev/nvme1n1p4 /mnt/shared

# Test
touch /mnt/shared/test.txt
```

#### **Solution 2: Fix fstab Entry**
```bash
# Edit fstab
sudo nano /etc/fstab

# Find shared partition line, should be:
UUID=YOUR-UUID /mnt/shared ntfs-3g defaults,uid=1000,gid=1000,dmask=022,fmask=133 0 0

# Save and remount
sudo mount -a
```

#### **Solution 3: Check User ID**
```bash
# Your UID might not be 1000
id
# Note your uid and gid

# Use those in mount options:
sudo mount -t ntfs-3g -o uid=YOUR-UID,gid=YOUR-GID /dev/nvme1n1p4 /mnt/shared
```

---

### Drive Shows as "Busy" or Won't Unmount

**Symptoms:** `umount: target is busy`

**Diagnosis:**
```bash
# Find what's using the drive
sudo lsof +D /mnt/shared
# OR
sudo fuser -m /mnt/shared
```

**Solutions:**

#### **Solution 1: Close Programs**
```bash
# Kill processes using the drive
sudo fuser -km /mnt/shared

# Then unmount
sudo umount /mnt/shared
```

#### **Solution 2: Lazy Unmount**
```bash
# Unmount when possible
sudo umount -l /mnt/shared
```

#### **Solution 3: Force Unmount**
```bash
# Last resort - may cause data loss
sudo umount -f /mnt/shared
```

---

## Performance Problems

### Slow Boot Time

**Diagnosis:**
```bash
# Check boot time
systemd-analyze

# Detailed breakdown
systemd-analyze blame

# Critical chain
systemd-analyze critical-chain
```

**Solutions:**

#### **Solution 1: Disable Slow Services**
```bash
# Common culprits:
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl disable plymouth-quit-wait.service
sudo systemctl disable snapd.service  # If not using Snap

# Mask to prevent restart
sudo systemctl mask plymouth-quit-wait.service
```

#### **Solution 2: Reduce GRUB Timeout**
```bash
sudo nano /etc/default/grub

# Change:
GRUB_TIMEOUT=10
# To:
GRUB_TIMEOUT=3

sudo update-grub
```

#### **Solution 3: Remove Old Kernels**
```bash
# List installed kernels
dpkg -l | grep linux-image

# Current kernel
uname -r

# Remove old kernels (keep current and one previous)
sudo apt remove linux-image-X.XX.X-XX-generic
sudo apt autoremove
sudo update-grub
```

---

### System Freezes or High Memory Usage

**Diagnosis:**
```bash
# Check memory usage
free -h

# Check swap usage
swapon --show

# Real-time monitoring
htop  # Press F6 to sort by MEM%

# Check OOM killer logs
dmesg | grep -i "killed process"
```

**Solutions:**

#### **Solution 1: Increase Swap**
```bash
# Check current swap
swapon --show

# Create larger swapfile
sudo swapoff -a
sudo dd if=/dev/zero of=/swapfile bs=1M count=8192  # 8GB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Verify
free -h
```

#### **Solution 2: Adjust Swappiness**
```bash
# Check current
cat /proc/sys/vm/swappiness

# For 8GB+ RAM, use lower value
sudo sysctl vm.swappiness=10

# Make permanent
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
```

#### **Solution 3: Install earlyoom**
```bash
# Prevents total system freeze
sudo apt install earlyoom
sudo systemctl enable --now earlyoom

# Configure
sudo nano /etc/default/earlyoom
# Set: EARLYOOM_ARGS="-m 5 -s 10"
# Means: kill processes when RAM <5% or swap <10%

sudo systemctl restart earlyoom
```

---

### SSD Performing Slowly

**Diagnosis:**
```bash
# Check TRIM is enabled
sudo fstrim -av

# Test speed (will take a few minutes)
sudo apt install fio
sudo fio --name=randwrite --ioengine=libaio --rw=randwrite --bs=4k --size=2G --numjobs=1 --runtime=60 --time_based

# Check drive health
sudo apt install smartmontools
sudo smartctl -a /dev/nvme0n1
```

**Expected Speeds:**
- NVMe Gen4: 7000+ MB/s sequential
- NVMe Gen3: 3500+ MB/s sequential
- SATA SSD: 500+ MB/s sequential

**Solutions:**

#### **Solution 1: Enable TRIM**
```bash
# Check if TRIM supported
sudo hdparm -I /dev/nvme0n1 | grep TRIM

# Enable TRIM timer
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# Manual TRIM
sudo fstrim -av
```

#### **Solution 2: Fix I/O Scheduler**
```bash
# For NVMe
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler

# Make permanent
sudo nano /etc/udev/rules.d/60-scheduler.rules
# Add:
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"

# Reload
sudo udevadm control --reload-rules
```

#### **Solution 3: Check for Over-provisioning**
```bash
# Some SSDs need free space
df -h
# Keep at least 10-20% free on system partition
```

---

## Update Issues

### Kernel Update Won't Install

**Error:** "The following packages have unmet dependencies"

**Diagnosis:**
```bash
# Check what's blocked
sudo apt install -f

# Check held packages
apt-mark showhold
```

**Solutions:**

#### **Solution 1: Fix Dependencies**
```bash
sudo apt update
sudo apt install -f
sudo apt --fix-broken install
sudo apt autoremove
sudo apt update && sudo apt full-upgrade
```

#### **Solution 2: Clear Package Cache**
```bash
sudo apt clean
sudo apt autoclean
sudo rm /var/lib/apt/lists/*
sudo apt update
sudo apt full-upgrade
```

#### **Solution 3: Manual Kernel Install**
```bash
# Download kernel manually
apt download linux-image-generic
sudo dpkg -i linux-image-*.deb
sudo apt install -f
```

---

### Windows Update Failed

**Error:** Update hangs or fails to install

**Solutions:**

#### **Solution 1: Windows Update Troubleshooter**
```
Settings → Update & Security → Troubleshoot
→ Additional troubleshooters → Windows Update
→ Run the troubleshooter
```

#### **Solution 2: Manual Update Reset**
```powershell
# Run PowerShell as Administrator

# Stop update services
net stop wuauserv
net stop cryptSvc
net stop bits
net stop msiserver

# Rename update folders
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old

# Restart services
net start wuauserv
net start cryptSvc
net start bits
net start msiserver

# Try update again
```

#### **Solution 3: Use Media Creation Tool**
```
If feature update fails:
1. Download Windows 11 Media Creation Tool
2. Choose "Upgrade this PC now"
3. Keep files and apps
4. Let it upgrade in place
```

---

## UEFI/BIOS Problems

### TPM Error on Boot

**Error:** "TPM device is not detected" or "TPM malfunction"

**Diagnosis:**
```powershell
# In Windows
tpm.msc
# Should show TPM status

# OR
Get-Tpm
```

**Solutions:**

#### **Solution 1: Enable TPM in BIOS**
```
1. Enter BIOS (Del/F2/F10)
2. Advanced → Security → TPM
3. Enable "TPM 2.0" or "fTPM" or "PTT"
4. Save and exit
```

#### **Solution 2: Reset TPM**
```
In BIOS:
Advanced → Security → TPM → Clear TPM
Save and exit
Boot Windows, TPM will reinitialize
```

---

### Secure Boot Violation

**Error:** "Secure Boot Violation" when booting Linux

**Solutions:**

#### **Solution 1: Disable Secure Boot**
```
1. Enter BIOS
2. Security → Secure Boot
3. Disable
4. Save and exit
```

#### **Solution 2: Enroll MOK Keys (Linux Mint 21.3+)**
```bash
# Linux Mint should auto-prompt on first boot
# Follow on-screen instructions to enroll keys

# Manual enrollment:
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
# Enter password when prompted

# Reboot
# MOK Manager appears
# Select "Enroll MOK"
# Enter password
# Reboot
```

---

### BIOS Not Saving Settings

**Symptoms:** Boot order or settings reset after power off

**Solutions:**

#### **Solution 1: Replace CMOS Battery**
```
Motherboard battery (CR2032) may be dead
Replace with new CR2032 battery
Reconfigure BIOS settings
```

#### **Solution 2: Update BIOS Firmware**
```
Check manufacturer website for BIOS updates
Download latest version
Follow manufacturer's update procedure
⚠️ NEVER interrupt BIOS update!
```

---

## Recovery Procedures

### Complete System Recovery from Backups

#### **Restore Linux from Timeshift**
```bash
# Boot from Live USB

# Install Timeshift if needed
sudo apt install timeshift

# Detect snapshots
sudo timeshift --list

# Restore
sudo timeshift --restore --snapshot 'YYYY-MM-DD_HH-MM-SS'

# Reinstall GRUB
sudo grub-install /dev/nvme0n1
sudo update-grub

reboot
```

#### **Restore Windows from System Image**
```
1. Boot from Windows Recovery USB
2. Troubleshoot → Advanced → System Image Recovery
3. Select most recent image
4. Follow wizard
5. Reboot
```

---

### Emergency Data Recovery

#### **Access Files When OS Won't Boot**
```bash
# Boot from Live USB

# Create mount point
sudo mkdir -p /mnt/recovery

# Mount Linux partition
sudo mount /dev/nvme0n1p2 /mnt/recovery
# Copy data to external drive
cp -r /mnt/recovery/home/$USER /media/external/backup

# Mount Windows partition
sudo mount -t ntfs-3g -o ro /dev/nvme1n1p3 /mnt/recovery
# Copy data
cp -r /mnt/recovery/Users/$USER /media/external/backup
```

#### **Fix Corrupted Filesystem**
```bash
# Boot from Live USB

# For ext4 (Linux)
sudo fsck.ext4 -f /dev/nvme0n1p2

# For NTFS (Windows)
sudo ntfsfix /dev/nvme1n1p3

# For FAT32 (EFI)
sudo fsck.fat -a /dev/nvme0n1p1
```

---

### Factory Reset Dual-Boot

#### **Keep Linux, Remove Windows**
```bash
# Boot into Linux

# Format Windows drive
sudo gparted
# Select Windows SSD
# Delete all partitions
# Create new ext4 partition

# Update GRUB
sudo update-grub

# Done - Windows removed
```

#### **Keep Windows, Remove Linux**
```
# Shut down system
# Physically disconnect Linux SSD
# Enter BIOS
# Set Windows SSD as boot device
# Boot into Windows normally

# Optional: Reconnect Linux SSD for data recovery
# Format it from Windows Disk Management when ready
```

---

## Diagnostic Commands

### System Information

```bash
# Boot mode (UEFI or Legacy)
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "Legacy BIOS"

# List all drives and partitions
sudo fdisk -l
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID

# Show mounted partitions
df -h

# Get partition UUIDs
sudo blkid

# System info
inxi -Fxz

# Hardware info
sudo lshw -short

# Kernel version
uname -a

# Distribution info
lsb_release -a
```

### Boot Information

```bash
# GRUB configuration
cat /etc/default/grub

# GRUB menu entries
grep menuentry /boot/grub/grub.cfg

# EFI boot entries
sudo efibootmgr -v

# Boot time analysis
systemd-analyze
systemd-analyze blame
systemd-analyze critical-chain

# Check GRUB installed
sudo grub-install --version
which grub-install

# Last boot log
journalctl -b
```

### Drive Health

```bash
# Install tools
sudo apt install smartmontools

# Check drive health
sudo smartctl -a /dev/nvme0n1
sudo smartctl -a /dev/nvme1n1

# Temperature
sudo smartctl -a /dev/nvme0n1 | grep Temperature

# TRIM status
sudo hdparm -I /dev/nvme0n1 | grep TRIM

# Drive errors
sudo smartctl -l error /dev/nvme0n1

# Drive test
sudo smartctl -t short /dev/nvme0n1
# Wait 2 minutes, then:
sudo smartctl -a /dev/nvme0n1
```

### Memory and Performance

```bash
# Memory usage
free -h

# Swap usage and priority
swapon --show

# CPU info
lscpu
cat /proc/cpuinfo

# Real-time system monitor
htop

# Process list by memory
ps aux --sort=-%mem | head -20

# Disk I/O
sudo iotop

# Network usage
sudo iftop

# Check swappiness
cat /proc/sys/vm/swappiness

# I/O scheduler
cat /sys/block/nvme0n1/queue/scheduler
```

### Network Diagnostics

```bash
# Network interfaces
ip a

# Connection status
nmcli connection show

# DNS resolution
resolvectl status

# Test internet
ping -c 4 8.8.8.8

# Firewall status
sudo ufw status verbose
```

### Package Information

```bash
# Installed kernels
dpkg -l | grep linux-image

# Current kernel
uname -r

# Update status
sudo apt update
apt list --upgradable

# Check for broken packages
sudo apt check
sudo dpkg --audit

# Package cache size
du -sh /var/cache/apt/archives
```

---

## Common Error Codes Reference

### Linux Error Codes

| Error | Meaning | Common Fix |
|-------|---------|------------|
| **errno 2** | No such file | Check path, file exists |
| **errno 5** | Input/output error | Disk problem, check with fsck |
| **errno 13** | Permission denied | Use sudo or fix permissions |
| **errno 16** | Device busy | Unmount or stop using process |
| **errno 28** | No space left | Free up disk space |
| **errno 30** | Read-only filesystem | Remount rw |

### GRUB Error Codes

| Error | Meaning | Solution |
|-------|---------|----------|
| **error: unknown filesystem** | GRUB can't read partition | Reinstall GRUB |
| **error: file not found** | Missing GRUB files | Reinstall GRUB |
| **error: invalid EFI file path** | Wrong bootloader path | Fix GRUB entry |
| **error: no such device** | Partition UUID changed | Update fstab and GRUB |

### Windows Error Codes

| Error | Meaning | Solution |
|-------|---------|----------|
| **0xc000000e** | Boot configuration corrupted | bootrec /rebuildbcd |
| **0xc0000225** | Boot file missing | bcdboot C:\Windows |
| **0x000000f** | Device disconnected | Check drive connections |
| **0xc0000034** | BCD corrupt | bcdedit /export, /import |

---

## Quick Checklist for Common Issues

### "Can't Boot Linux"
- [ ] Check BIOS boot order (Linux SSD first)
- [ ] Run `sudo update-grub` from Live USB
- [ ] Reinstall GRUB
- [ ] Check EFI boot entries (`efibootmgr -v`)

### "Can't Boot Windows"
- [ ] Fast Startup disabled
- [ ] Run bootrec /rebuildbcd
- [ ] Check BIOS boot order
- [ ] Verify Windows drive connected

### "Windows Not in GRUB"
- [ ] os-prober enabled (`GRUB_DISABLE_OS_PROBER=false`)
- [ ] Run `sudo update-grub`
- [ ] Create manual GRUB entry
- [ ] Check Windows EFI partition exists

### "Can't Mount Windows from Linux"
- [ ] Fast Startup disabled in Windows
- [ ] BitLocker disabled
- [ ] Run `sudo ntfsfix /dev/sdX`
- [ ] Mount read-only first

### "System Freezes"
- [ ] Check RAM usage (`free -h`)
- [ ] Increase swap
- [ ] Adjust swappiness
- [ ] Install earlyoom

---

**Last Updated:** November 1, 2025  
**Author:** OffTrackMedia & Network & Firewall Technicians  
**Repository:** https://github.com/Nerds489/

**END OF TROUBLESHOOTING REFERENCE**
