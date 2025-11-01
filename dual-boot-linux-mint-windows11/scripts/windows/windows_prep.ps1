#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Windows 11 Dual-Boot Preparation Script v2.0
    
.DESCRIPTION
    Prepares Windows 11 for dual-boot with Linux Mint
    - Validates prerequisites
    - Disables Fast Startup
    - Checks BitLocker status
    - Creates system restore point
    - Backs up critical data
    - Records system information
    
.NOTES
    Author: OffTrackMedia & Network & Firewall Technicians
    Version: 2.0
    Requires: Windows 11, PowerShell 5.1+, Administrator privileges
    
.EXAMPLE
    .\windows_prep.ps1
#>

# ============================================================
# INITIALIZATION
# ============================================================

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"

# Script version
$ScriptVersion = "2.0"
$ScriptDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
# Log file setup
$LogPath = "$env:USERPROFILE\Desktop\DualBoot-Prep-$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$ReportPath = "$env:USERPROFILE\Desktop\DualBoot-SystemInfo-$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Color functions for output
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [ValidateSet('Info','Success','Warning','Error','Header')]
        [string]$Type = 'Info'
    )
    
    $Timestamp = Get-Date -Format "HH:mm:ss"
    
    switch ($Type) {
        'Info'    { 
            Write-Host "[$Timestamp] [INFO] $Message" -ForegroundColor Cyan
            Add-Content -Path $LogPath -Value "[$Timestamp] [INFO] $Message"
        }
        'Success' { 
            Write-Host "[$Timestamp] [SUCCESS] $Message" -ForegroundColor Green
            Add-Content -Path $LogPath -Value "[$Timestamp] [SUCCESS] $Message"
        }
        'Warning' { 
            Write-Host "[$Timestamp] [WARNING] $Message" -ForegroundColor Yellow
            Add-Content -Path $LogPath -Value "[$Timestamp] [WARNING] $Message"
        }
        'Error'   { 
            Write-Host "[$Timestamp] [ERROR] $Message" -ForegroundColor Red
            Add-Content -Path $LogPath -Value "[$Timestamp] [ERROR] $Message"
        }        'Header'  { 
            Write-Host "`n╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
            Write-Host "║  $Message" -ForegroundColor Cyan
            Write-Host "╚══════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
            Add-Content -Path $LogPath -Value "`n=== $Message ==="
        }
    }
}

# ============================================================
# PREREQUISITE CHECKS
# ============================================================

function Test-Prerequisites {
    Write-ColorOutput -Message "PREREQUISITE VALIDATION" -Type Header
    
    $Prerequisites = @{
        'Windows11' = $false
        'UEFI' = $false
        'TPM' = $false
        'SecureBoot' = $false
        'AdminRights' = $false
        'DiskSpace' = $false
        'RAM' = $false
    }
    
    # Check Windows version
    try {
        $OS = Get-CimInstance -ClassName Win32_OperatingSystem
        if ($OS.BuildNumber -ge 22000) {
            $Prerequisites['Windows11'] = $true
            Write-ColorOutput -Message "Windows 11 detected (Build $($OS.BuildNumber))" -Type Success
        } else {
            Write-ColorOutput -Message "Windows 11 not detected (Build $($OS.BuildNumber))" -Type Error
        }