# PowerShell Script: TURBO-GAMER-PRO
# Requiere ejecución como administrador

#   Write-Log "Windows Update desactivado." OK

# }
# =================== 🛠️ TURBO GAMER PRO OPTIMIZATIONS ==================

# Asegurarse de que se ejecuta como administrador
function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        Write-Log "Este script requiere privilegios de administrador." ERROR
        Exit 1
    }
}

Ensure-Admin
# =================== 📝 LOGGING FUNCTION ==================
    
<#
.SYNOPSIS
    Función para registrar mensajes con diferentes niveles de severidad.
.DESCRIPTION
    Esta función permite registrar mensajes en la consola con diferentes colores según el nivel de severidad.
.PARAMETER Message
    El mensaje a registrar.
.PARAMETER Level
    El nivel de severidad del mensaje. Puede ser 'INFO', 'WARN', 'ERROR' o 'OK'. Por defecto es 'INFO'.
.EXAMPLE
    Write-Log "Este es un mensaje informativo."
    Write-Log "Este es un mensaje de advertencia." WARN
    Write-Log "Este es un mensaje de error." ERROR
    Write-Log "Operación completada con éxito." OK
.NOTES
    Requiere PowerShell 5.1+ y ejecución como administrador.
#>


function Write-Log {
    param($Message, $Level = 'INFO')
    $ts = (Get-Date).ToString("HH:mm:ss")
    switch ($Level.ToUpper()) {
        'OK'    { Write-Host "[$ts] $Message" -ForegroundColor Green }
        'WARN'  { Write-Host "[$ts] $Message" -ForegroundColor Yellow }
        'ERROR' { Write-Host "[$ts] $Message" -ForegroundColor Red }
        default { Write-Host "[$ts] $Message" -ForegroundColor Cyan }
    }
}

function Disable-ServiceSafe {
    param([string]$Name)
    try {
        $svc = Get-Service -Name $Name -ErrorAction Stop
        if ($svc.Status -ne 'Stopped') {
            Stop-Service $Name -Force -ErrorAction Stop
        }
        Set-Service $Name -StartupType Disabled
        Write-Log "Servicio '$Name' deshabilitado." OK
    } catch {
        Write-Log "No se pudo deshabilitar '$Name'." WARN
    }
}

# =================== 🔧 DISABLE GAME STUFF ===================
function Disable-GameDVR {
    Write-Log "Desactivando GameDVR y GameBar..." INFO
    $paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR",
        "HKCU:\System\GameConfigStore"
    )
    foreach ($path in $paths) {
        New-Item -Path $path -Force | Out-Null
    }
    Set-ItemProperty -Path $paths[0] -Name "AppCaptureEnabled" -Value 0
    Set-ItemProperty -Path $paths[1] -Name "GameDVR_Enabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "ShowStartupPanel" -Value 0 -ErrorAction SilentlyContinue
    Write-Log "GameDVR/GameBar desactivados." OK
}

# =================== 🔧 NETWORK OPTIM ===================
function Optimize-Network {
    Write-Log "Aplicando tweaks de red para gaming..." INFO
    $reg = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces'
    $adapters = Get-ChildItem $reg
    foreach ($adapter in $adapters) {
        New-ItemProperty -Path $adapter.PSPath -Name "TcpAckFrequency" -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue
        New-ItemProperty -Path $adapter.PSPath -Name "TCPNoDelay"      -Value 1 -PropertyType DWord -Force -ErrorAction SilentlyContinue
        New-ItemProperty -Path $adapter.PSPath -Name "TcpDelAckTicks"  -Value 0 -PropertyType DWord -Force -ErrorAction SilentlyContinue
    }
    Write-Log "Tweaks de red aplicados." OK
}

# =================== ⚙️ POWER PLAN ===================
function Enable-UltimatePerformance {
    Write-Log "Activando plan de energía 'Ultimate Performance'..." INFO
    $exists = powercfg -L | Select-String -Pattern "Ultimate Performance"
    if (-not $exists) {
        powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    }
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    Write-Log "'Ultimate Performance' activado." OK
}

# =================== 🧠 DISABLE TELEMETRY ===================
function Disable-Telemetry {
    Write-Log "Eliminando telemetría y tareas programadas de tracking..." INFO
    $tasks = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Autochk\Proxy",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    )
    foreach ($task in $tasks) {
        schtasks /Change /TN $task /Disable | Out-Null
    }

    $telemetryKeys = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    )
    foreach ($key in $telemetryKeys) {
        New-Item -Path $key -Force | Out-Null
        Set-ItemProperty -Path $key -Name "AllowTelemetry" -Value 0 -Type DWord
    }
    Write-Log "Telemetría neutralizada." OK
}

# =================== 🔇 SILENCE NOTIFICATIONS ===================
function Disable-FeedbackNotifications {
    Write-Log "Desactivando Feedback & Notificaciones..." INFO
    $path = "HKCU:\Software\Microsoft\Siuf\Rules"
    New-Item -Path $path -Force | Out-Null
    Set-ItemProperty -Path $path -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToastFeedback" `
                     -Name "Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue

    Write-Log "Feedback silenciado." OK
}

# =================== 🚫 STOP BLOAT SERVICES ===================
function Disable-UnnecessaryServices {
    $services = @(
        "DiagTrack", "dmwappushservice", "SysMain", "WerSvc", "RemoteRegistry", "wuauserv", "OneSyncSvc", "RetailDemo"
    )
    foreach ($svc in $services) {
        Disable-ServiceSafe $svc
    }
}

# =================== 🧠 MAIN EXEC ===================

Disable-GameDVR
Optimize-Network
Enable-UltimatePerformance
Disable-Telemetry
Disable-FeedbackNotifications
Disable-UnnecessaryServices
Set-HighPerformancePowerPlan
Show-ActivePowerScheme

# =================== 📝 REGISTRY UTILITY FUNCTION ==================

function Set-RegistryValue {
    param(
        [string] $Path,
        [string] $Name,
        [int] $Value
    )
    try {
        New-Item -Path $Path -Force | Out-Null
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
        Write-Log "Registro '$Path\$Name' = $Value." OK
    } catch {
        Write-Log "Error al establecer el registro '$Name'." ERROR
    }
}
function Set-HighPerformancePowerPlan {
    Write-Log "Configurando esquema de energía a 'Alto rendimiento'..." INFO
    $guid = (powercfg -L | Select-String -Pattern "Alto rendimiento").ToString().Split()[3]
    if ($guid) {
        powercfg -setactive $guid
        Write-Log "Plan de energía 'Alto rendimiento' activado." OK
    } else {
        Write-Log "No se encontró plan 'Alto rendimiento', se mantiene el actual." WARN
    }
}
function Show-ActivePowerScheme {
    Write-Log "Esquema de energía activo:" INFO
    powercfg /getactivescheme
}


