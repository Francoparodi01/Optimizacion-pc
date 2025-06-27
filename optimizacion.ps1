<#
.SYNOPSIS
  Toolkit de optimización de Windows para gaming (CS2):
  - Desactiva servicios innecesarios.
  - Configura políticas de actualización.
  - Forza esquema de energía en alto rendimiento.

.NOTES
  Requiere PowerShell 5.1+ y ejecución como administrador.
#>

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)  # Soluciona codificación "¿" -> "Â¿"

Ensure-Admin


function Write-Log {
  param($Message, $Level = 'Info')
  $time = (Get-Date).ToString('HH:mm:ss')
  switch ($Level) {
    'Info'  { Write-Host "[$time] $Message" -ForegroundColor Cyan }
    'Warn'  { Write-Host "[$time] $Message" -ForegroundColor Yellow }
    'Error' { Write-Host "[$time] $Message" -ForegroundColor Red }
    'OK'    { Write-Host "[$time] $Message" -ForegroundColor Green }
  }
}

function Ensure-Admin {
  if (-not ([Security.Principal.WindowsPrincipal] `
      [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Write-Log "Este script requiere privilegios de administrador." Error
    Exit 1
  }
}

function Disable-ServiceIfExists {
  param([string] $Name, [Switch] $Force = $true)
  try {
    $svc = Get-Service -Name $Name -ErrorAction Stop
    if ($svc.Status -ne 'Stopped') {
      Stop-Service -Name $Name -Force:$Force -ErrorAction Stop
    }
    Set-Service -Name $Name -StartupType Disabled -ErrorAction Stop
    Write-Log "Servicio '$Name' deshabilitado." OK
  } catch {
    Write-Log "No se pudo deshabilitar '$Name'." Warn
  }
}

function Set-RegistryValue {
  param([string] $Path, [string] $Name, [int] $Value)
  try {
    New-Item -Path $Path -Force | Out-Null
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
    Write-Log "Registro '$Path\\$Name' = $Value." OK
  } catch {
    Write-Log "Error en el registro '$Name'." Error
  }
}

function Disable-WindowsUpdate {
  Write-Log "Desactivando Windows Update..." Info
  Disable-ServiceIfExists 'wuauserv'
  $reg = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
  Set-RegistryValue -Path $reg -Name 'NoAutoUpdate' -Value 1
  Set-RegistryValue -Path $reg -Name 'AUOptions'    -Value 1

  $cfg = Get-ItemProperty -Path $reg -ErrorAction SilentlyContinue
  if ($cfg.NoAutoUpdate -eq 1 -and $cfg.AUOptions -eq 1) {
    Write-Log "Actualización automática deshabilitada." OK
  } else {
    Write-Log "No se aplicó configuración de Windows Update." Error
  }
}

function Prompt-DisableOptional {
  param([string] $SvcName, [string] $FriendlyName)
  $ans = Read-Host "¿Deshabilitar $FriendlyName? (s/n)"
  if ($ans -match '^[sS]$') {
    Disable-ServiceIfExists $SvcName
  } else {
    Write-Log "$FriendlyName preservado." Warn
  }
}

function Set-HighPerformancePowerPlan {
  Write-Log "Configurando esquema de energía a 'Alto rendimiento'..." Info
  $guid = (powercfg -L | Select-String -Pattern "Alto rendimiento").ToString().Split()[3]
  if ($guid) {
    powercfg -setactive $guid
    Write-Log "Plan de energía 'Alto rendimiento' activado." OK
  } else {
    Write-Log "No se encontró plan 'Alto rendimiento', se mantiene el actual." Warn
  }
}

function Show-ActivePowerScheme {
  Write-Log "Esquema de energía activo:" Info
  powercfg /getactivescheme
}

# ——— EJECUCIÓN ———

Disable-WindowsUpdate
Disable-ServiceIfExists 'DiagTrack'
Disable-ServiceIfExists 'dmwappushservice'
Disable-ServiceIfExists 'SysMain'
Disable-ServiceIfExists 'WerSvc'
Disable-ServiceIfExists 'RemoteRegistry'

Prompt-DisableOptional 'Cortana'     'Cortana'
Prompt-DisableOptional 'OneSyncSvc'  'OneDrive'
Prompt-DisableOptional 'bthserv'     'Bluetooth Support'
Prompt-DisableOptional 'WinDefend'   'Windows Defender'
Prompt-DisableOptional 'TermService' 'Remote Desktop Services'

Set-HighPerformancePowerPlan
Show-ActivePowerScheme

Write-Log "✅ Optimización finalizada. Disfrutá los FPS extra 💥" OK
