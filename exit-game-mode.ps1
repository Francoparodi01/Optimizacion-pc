param(
    [switch] $NoInteraction
)

function Write-Log {
    param([string]$msg)
    Write-Output "`n$msg`n"
}

# — 0) Validar que sea Admin —
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Log "⚠️ Debes ejecutar este script como Administrador."
    if (-not $NoInteraction) { Read-Host "Presiona Enter para salir..." }
    exit 1
}

Write-Log "🛑 DESACTIVANDO MODO JUEGO (restaurando entorno)..."
Write-Output "---------------------------------------------------"

# — 1) Restaurar plan de energía original —
$originalPlanFile = "$env:TEMP\original_power_plan.txt"
if (Test-Path $originalPlanFile) {
    $guid = Get-Content $originalPlanFile
    try {
        powercfg -setactive $guid 2>$null
        Write-Log "🔋 Plan restaurado: $guid"
    } catch {
        Write-Log "⚠️ No se pudo restaurar el plan original. Aplicando 'Balanceado'."
        powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a 2>$null
    }
    Remove-Item $originalPlanFile -Force
} else {
    Write-Log "⚠️ No se encontró plan original. Aplicando 'Balanceado'."
    powercfg -setactive a1841308-3541-4fab-bc81-f71556f20b4a 2>$null
}

# Función de restore genérico de servicios
function Restore-Services {
    param(
        [string[]] $Names,
        [ValidateSet("Automatic","Manual","Disabled")] [string] $StartupType = "Manual"
    )
    foreach ($svc in $Names) {
        try {
            Set-Service -Name $svc -StartupType $StartupType -ErrorAction Stop
            Start-Service -Name $svc -ErrorAction Stop
            Write-Log "✅ Servicio restaurado: $svc"
        } catch {
            Write-Log "⚠️ No se pudo restaurar servicio: $svc"
        }
    }
}

# — 2) Servicios básicos —
Write-Log "🔁 Restaurando servicios básicos..."
$basic = @(
    "WSearch","SysMain","Fax","MapsBroker","DiagTrack"
    "UsoSvc","wuauserv","PrintSpooler",
    "Spooler","XblAuthManager"
)
Restore-Services -Names $basic -StartupType "Manual"

# — 3) Servicios extra de optimización profunda —
Write-Log "🔁 Restaurando servicios extra..."
$extra = @(
    "dmwappushservice","W32Time","WerSvc","WpnService","WwanSvc",
    "RemoteRegistry","ShellHWDetection","SensorService","SensorDataService",
    "StorSvc","TimeBrokerSvc","UserDataSvc","UserDataAccess","WpcMonSvc"
)
Restore-Services -Names $extra -StartupType "Manual"

# — 4) Restaurar efectos visuales por máscara y refrescar —
Write-Log "🎨 Restaurando efectos visuales..."
try {
    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True
    Write-Log "🌈 Entorno visual refrescado."
} catch {
    Write-Log "⚠️ No se pudo refrescar entorno visual."
}

# — 5) Restaurar Game Mode / Game DVR —
Write-Log "🎮 Restaurando Game Mode y Game DVR..."
try {
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" `
        -Name "GameDVR_Enabled" -Value 1 -ErrorAction Stop
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" `
        -Name "AutoGameModeEnabled" -Value 0 -ErrorAction Stop
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
        -Name "GameMode" -Value 0 -ErrorAction Stop
    Write-Log "✅ Game Mode y DVR restaurados."
} catch {
    Write-Log "⚠️ Falló restaurar Game Mode / DVR."
}

# — 6) Restaurar tareas de telemetría —
Write-Log "📅 Restaurando tareas de telemetría..."
$tasks = @(
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
)
foreach ($t in $tasks) {
    if (schtasks /Query /TN $t 2>$null) {
        schtasks /Change /TN $t /Enable | Out-Null
        Write-Log "✅ Tarea restaurada: $t"
    } else {
        Write-Log "ℹ️ Tarea no existe: $t"
    }
}

Write-Log "🎨 Restaurando efectos visuales a valor por defecto..."

try {
    # Volver a "automático" (dejar que Windows decida)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
        -Name "VisualFXSetting" -Value 0 -ErrorAction SilentlyContinue

    # Restaurar máscara animaciones estándar
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
        -Name "UserPreferencesMask" `
        -Value ([byte[]](0x9E,0x3E,0x07,0x80,0x10,0x00,0x00,0x00)) `
        -ErrorAction SilentlyContinue

    RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True

    Write-Log "✅ Efectos visuales restaurados (modo automático)."
} catch {
    Write-Log "⚠️ No se pudo restaurar la apariencia visual."
}


# — 7) Servicios de telemetría —
Write-Log "📡 Restaurando servicios de telemetría..."
$tele = @("DiagTrack","dmwappushservice","WMPNetworkSvc")
Restore-Services -Names $tele -StartupType "Manual"

Write-Log "✅ Entorno restaurado. Modo juego desactivado correctamente."

# No dejar Read-Host colgado cuando viene de la GUI
if (-not $NoInteraction) {
    Read-Host "Presiona Enter para finalizar..."
}
