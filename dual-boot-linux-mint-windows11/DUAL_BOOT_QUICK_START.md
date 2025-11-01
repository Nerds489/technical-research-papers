# Dual-Boot Quick Start Guide
## Linux Mint Cinnamon + Windows 11 on Separate SSDs

**For experienced users who want fast deployment**

---

## TL;DR

1. **Physical disconnection** during install is **MANDATORY**
2. Install Windows first, Linux second
3. Disconnect inactive drive during each OS installation
4. GRUB on Linux SSD manages boot menu
5. Time: 2-3 hours total

---

## Prerequisites Checklist

- [ ] Two internal SSDs (NVMe or SATA)
- [ ] UEFI firmware (NOT Legacy BIOS)
- [ ] TPM 2.0 enabled
- [ ] Secure Boot capable (can disable temporarily)
- [ ] Windows 11 USB (8GB+)
- [ ] Linux Mint 22.x USB (8GB+)
- [ ] Backups of all important data

---

## Phase 1: Install Windows 11

**Time: 30-45 minutes + updates**

```powershell
# Pre-flight BIOS
✓ UEFI mode (not Legacy)
✓ TPM 2.0 enabled
✓ Note which drive is which

# Install Windows normally
1. Boot Windows USB
2. Custom install
3. Select Windows SSD (verify by size!)
4. Let Windows auto-partition
5. Complete OOBE

# Post-install (CRITICAL)
powercfg /h off  # Disable Fast Startup
shutdown /s /t 0  # Complete shutdown
```

---

## Phase 2: Install Linux Mint

**Time: 20-30 minutes**

```bash
# CRITICAL: Physically disconnect Windows SSD
# - SATA: Unplug data + power cables
# - M.2: Remove drive from slot

# Boot Linux Mint USB
1. Start Linux Mint (live session)
2. Test hardware (WiFi, display, etc.)
3. Double-click "Install Linux Mint"

# Installation selections
✓ Language & keyboard
✓ Install multimedia codecs
✓ "Erase disk and install" (SAFE - Windows disconnected!)
✓ Timezone
✓ User account

# Wait for installation (10-20 min)
# Restart when prompted
# Remove USB

# First boot commands
sudo apt update && sudo apt upgrade -y
sudo ufw enable
sudo reboot
sudo shutdown -h now
```

---

## Phase 3: Configure Dual-Boot

**Time: 10 minutes**

```bash
# Reconnect Windows SSD (power off first!)

# Enter BIOS
1. Set Linux SSD as 1st boot device
2. Set Windows SSD as 2nd boot device
3. Save and exit

# Boot into Linux

# Enable os-prober
sudo nano /etc/default/grub
# Change: #GRUB_DISABLE_OS_PROBER=true
# To: GRUB_DISABLE_OS_PROBER=false
# Save: Ctrl+O, Enter, Ctrl+X

# Update GRUB
sudo update-grub
# Should see: "Found Windows Boot Manager"

# Test
sudo reboot
# GRUB menu should show both Linux and Windows
```

---

## Quick Configuration

### Disable Fast Startup (Windows)
```powershell
powercfg /h off
```

### Fix Time Sync
```powershell
# Windows - Make it use UTC
reg add "HKLM\System\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /d 1 /t REG_DWORD /f
```

### Shared NTFS Partition (Optional)
```bash
# Create mount point
sudo mkdir -p /mnt/shared

# Get partition UUID
sudo blkid | grep ntfs

# Add to /etc/fstab
UUID=YOUR-UUID /mnt/shared ntfs-3g defaults,uid=1000,gid=1000,dmask=022,fmask=133 0 0

# Mount
sudo mount -a
```

### Enable TRIM (Both OSes)
```bash
# Linux
sudo systemctl enable fstrim.timer

# Windows (PowerShell)
fsutil behavior set DisableDeleteNotify 0
```

---

## GRUB Customization

```bash
# Edit /etc/default/grub

# Change timeout
GRUB_TIMEOUT=5

# Set default OS
GRUB_DEFAULT=0  # Linux first entry
GRUB_DEFAULT="Windows Boot Manager"  # Windows

# Hide menu
GRUB_TIMEOUT=0
GRUB_TIMEOUT_STYLE=hidden

# Apply changes
sudo update-grub
```

---

## Troubleshooting

### Windows Not in GRUB Menu
```bash
sudo nano /etc/default/grub
# Ensure: GRUB_DISABLE_OS_PROBER=false
sudo apt install os-prober
sudo update-grub
```

### Manual GRUB Entry (If os-prober Fails)
```bash
# Get Windows EFI UUID
sudo blkid | grep vfat

# Edit custom entries
sudo nano /etc/grub.d/40_custom

# Add:
menuentry 'Windows 11' --class windows --class os {
    insmod part_gpt
    insmod fat
    insmod chain
    search --no-floppy --fs-uuid --set=root YOUR-UUID-HERE
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}

sudo update-grub
```

### GRUB Rescue Mode
```bash
# Boot Linux Mint USB

# Mount partitions
sudo mount /dev/nvme0n1p2 /mnt  # Root
sudo mount /dev/nvme0n1p1 /mnt/boot/efi  # EFI
for i in /dev /dev/pts /proc /sys /run; do sudo mount --bind "$i" "/mnt$i"; done

# Chroot and reinstall
sudo chroot /mnt
grub-install /dev/nvme0n1  # Your Linux SSD
update-grub
exit

# Cleanup and reboot
sudo umount -R /mnt
reboot
```

### Can't Mount Windows Partition
```bash
# Fast Startup not disabled
# Boot Windows and run:
powercfg /h off

# Force mount read-only in Linux
sudo mount -t ntfs-3g -o ro /dev/nvme1n1p3 /mnt/windows
```

---

## Backup Commands

### Linux - Timeshift
```bash
# Setup
sudo timeshift --create --comments "Initial snapshot"

# Automated snapshots
sudo timeshift-gtk  # Configure GUI schedule
```

### Windows - System Image
```powershell
# Via Control Panel
Control Panel → Backup and Restore (Windows 7) → Create system image
```

### Quick Backup Script
```bash
# Linux home directory
sudo rsync -aAXv --delete /home/$USER/ /media/backup/home-backup/

# Windows from Linux (if mounted)
sudo rsync -av /mnt/windows/Users/$USER/ /media/backup/windows-user-backup/
```

---

## Maintenance Schedule

```bash
# Weekly
sudo apt update && sudo apt upgrade -y
# Windows Update

# Monthly
sudo apt full-upgrade -y
sudo smartctl -a /dev/nvme0n1  # Check SSD health
sudo timeshift --create

# Quarterly
# Test backup restoration
# Verify TRIM working
```

---

## Essential Commands

### System Info
```bash
# Drive layout
sudo fdisk -l
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE

# Boot mode
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "Legacy"

# GRUB entries
grep menuentry /boot/grub/grub.cfg

# EFI boot entries
sudo efibootmgr -v
```

### Performance
```bash
# Check swappiness
cat /proc/sys/vm/swappiness

# Reduce for 8GB+ RAM
sudo sysctl vm.swappiness=10

# I/O scheduler
cat /sys/block/nvme0n1/queue/scheduler
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler
```

### Monitoring
```bash
# RAM usage
free -h

# Disk usage
df -h

# SSD health
sudo smartctl -a /dev/nvme0n1

# Temperature
sensors  # Install: sudo apt install lm-sensors
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Update GRUB | `sudo update-grub` |
| Reinstall GRUB | `sudo grub-install /dev/nvme0n1` |
| List kernels | `dpkg --list \| grep linux-image` |
| Boot to Windows | `sudo grub-reboot "Windows Boot Manager" && sudo reboot` |
| Check boot order | `sudo efibootmgr -v` |
| Mount Windows | `sudo mount -t ntfs-3g /dev/nvme1n1p3 /mnt/windows` |
| TRIM all drives | `sudo fstrim -av` |
| Create snapshot | `sudo timeshift --create` |
| Check services | `systemctl list-unit-files --state=enabled` |
| Kernel version | `uname -r` |

---

## Common Mistakes to Avoid

❌ **NOT physically disconnecting drives** during installation
- Causes: GRUB on wrong drive, boot dependency

❌ **Forgetting to disable Fast Startup** in Windows
- Causes: Filesystem locks, can't mount from Linux

❌ **Using Legacy BIOS** mode instead of UEFI
- Causes: Windows 11 won't install, TPM issues

❌ **Not updating GRUB** after reconnecting Windows drive
- Causes: Windows missing from boot menu

❌ **Installing on same drive** thinking it's easier
- Causes: 99% of dual-boot problems

❌ **Skipping backups** before installation
- Causes: Data loss if something goes wrong

---

## Emergency Recovery Kit

**Keep these ready:**

1. ✅ Linux Mint Live USB
2. ✅ Windows 11 Installation USB
3. ✅ Boot-Repair-Disk USB
4. ✅ External drive with backups
5. ✅ This guide (printed or on phone)

**Bookmark:**
- https://forums.linuxmint.com/
- https://wiki.archlinux.org/title/GRUB
- https://wiki.archlinux.org/title/Dual_boot_with_Windows

---

## Success Checklist

After completion, verify:

- [ ] Both OSes boot successfully
- [ ] GRUB shows both Linux and Windows
- [ ] Can switch between OSes reliably
- [ ] Time stays correct when switching
- [ ] Can access shared partition from both
- [ ] Fast Startup disabled in Windows
- [ ] TRIM enabled on both SSDs
- [ ] Initial backups created
- [ ] EFI boot entries correct (`efibootmgr -v`)
- [ ] Both drives show healthy (`smartctl`)

---

## Next Steps

1. **Install applications** in both OSes
2. **Setup Timeshift** for Linux system snapshots
3. **Create Windows System Image** backup
4. **Configure shared partition** for common files
5. **Join communities** for help and tips
6. **Customize GRUB** appearance if desired
7. **Document your setup** for future reference

---

## Support

**Issues?** Check the comprehensive guide: `DUAL_BOOT_LINUX_MINT_WINDOWS11_GUIDE.md`

**Still stuck?**
- Linux Mint Forums: https://forums.linuxmint.com/
- Reddit: r/linuxmint, r/linuxquestions
- Discord: Linux Mint Community Server

---

**Last Updated:** November 1, 2025  
**Author:** OffTrackMedia & Network & Firewall Technicians  
**Repository:** https://github.com/Nerds489/

**END OF QUICK START GUIDE**
