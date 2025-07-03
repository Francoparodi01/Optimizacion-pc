# =======================
# Game Mode Optimizer
# =======================
# Este script aplica múltiples optimizaciones en Windows para mejorar el rendimiento en juegos.
# Incluye: ajustes visuales, servicios, energía, bcdedit tweaks, eliminación de bloatware y más.

# =======================
# FUNCIONES AUXILIARES
# =======================

function Confirm-And-RemoveApp($AppName, $PackageName) {
    $response = Read-Host "¿Deseas eliminar $AppName? (s/n)"
    if ($response -eq "s") {
        Get-AppxPackage -AllUsers $PackageName | Remove-AppxPackage
    }
}

# Telemetría: configurar en modo seguridad mínima
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name AllowTelemetry -Value 0 -Type DWord -Force


$telemetryServices = @(
    "DiagTrack",          # Servicio de seguimiento
    "dmwappushservice",   # Servicio de telemetría adicional
    "WMPNetworkSvc",      # Compartición de Windows Media
    "RemoteRegistry",     # Registro remoto
    "RetailDemo"          # Demo de tiendas
)

foreach ($svc in $telemetryServices) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Feedback\Siuf\DmClient",
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
)

foreach ($task in $tasksToDisable) {
    schtasks /Change /TN $task /Disable | Out-Null
}


# Cortana y Búsqueda Web
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Force


function Disable-StartupApps {
    Write-Host "`nBuscando programas en el inicio..."
    $startupItems = Get-CimInstance -ClassName Win32_StartupCommand

    foreach ($item in $startupItems) {
        Write-Host "`nNombre: $($item.Name)"
        Write-Host "Comando: $($item.Command)"
        $response = Read-Host "¿Deseas deshabilitar este programa del arranque? (s/n)"
        if ($response -eq "s") {
            $registryPath = $item.Location
            try {
                Remove-ItemProperty -Path $registryPath -Name $item.Name -ErrorAction SilentlyContinue
                Write-Host "✅ Deshabilitado con éxito."
            } catch {
                Write-Host "⚠️ No se pudo deshabilitar: $($_.Exception.Message)"
            }
        }
    }
}

function Set-VisualEffectsPerformance {
    Write-Host "🔧 Configurando efectos visuales para mejor rendimiento..."
    $PerformanceKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    Set-ItemProperty -Path $PerformanceKey -Name VisualFXSetting -Value 2

    $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $RegistryPath -Name ListviewAlphaSelect -Value 0
    Set-ItemProperty -Path $RegistryPath -Name TaskbarAnimations -Value 0
    Set-ItemProperty -Path $RegistryPath -Name ListviewShadow -Value 0
    Set-ItemProperty -Path $RegistryPath -Name IconsOnly -Value 0
}

function Set-MaximumPerformancePlan {
    Write-Host "⚡ Activando plan de energía: Máximo Rendimiento..."
    powercfg /setactive 0478d363-7eb3-4e33-ab97-9e3ac79c4059
}

function Apply-BCDEditTweaks {
    Write-Host "🛠️ Aplicando mejoras de latencia con bcdedit..."
    bcdedit /set useplatformtick yes
    bcdedit /set disabledynamictick yes
}

function Disable-UnneededServices {
    Write-Host "🧯 Deshabilitando servicios innecesarios..."
    $services = @(
        "Fax", "DiagTrack", "PrintSpooler", "WerSvc", "WSearch"
    )
    foreach ($svc in $services) {
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

function Remove-Bloatware {
    Write-Host "🧹 Eliminando bloatware innecesario automáticamente..."

    $packagesToRemove = @(
        "MicrosoftCorporationII.QuickAssist",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.Copilot",
        "Microsoft.BingWeather",
        "MicrosoftCorporationII.MicrosoftFamily",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.BingSearch",
        "Clipchamp.Clipchamp",
        "MSTeams",
        "Microsoft.Todos",
        "Microsoft.MicrosoftStickyNotes",
        "Microsoft.BingNews",
        "Microsoft.OutlookForWindows",
        "Microsoft.WindowsAlarms",
        "Microsoft.MicrosoftSolitaireCollection"
    )

    foreach ($pkg in $packagesToRemove) {
        Get-AppxPackage -AllUsers $pkg | Remove-AppxPackage
    }
}

function Ask-ToRemoveOptionalApps {
    Write-Host "`n📦 Preguntando por apps opcionales..."

    Confirm-And-RemoveApp "Cámara" "Microsoft.WindowsCamera"
    Confirm-And-RemoveApp "Grabadora de Sonidos" "Microsoft.WindowsSoundRecorder"
    Confirm-And-RemoveApp "Recorte y anotación" "Microsoft.ScreenSketch"
    Confirm-And-RemoveApp "OneDrive" "Microsoft.OneDriveSync"

    $response = Read-Host "¿Deseas desinstalar completamente OneDrive? (s/n)"
    if ($response -eq "s") {
        Start-Process -FilePath "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -NoNewWindow -Wait
    }
}

function Confirm-And-RemoveApp($AppName, $PackageName) {
    $response = Read-Host "¿Deseas eliminar $AppName (s/n)"
    if ($response -eq "s") {
        Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq $PackageName } | Remove-AppxPackage
    }
}

function Disable-StartupApps {
    Write-Host "`n🔍 Buscando programas en el inicio..."
    $startupItems = Get-CimInstance -ClassName Win32_StartupCommand

    foreach ($item in $startupItems) {
        Write-Host "`nNombre: $($item.Name)"
        Write-Host "Comando: $($item.Command)"
        $response = Read-Host "¿Deseas deshabilitar este programa del arranque? (s/n)"
        if ($response -eq "s") {
            $registryPath = $item.Location
            try {
                Remove-ItemProperty -Path $registryPath -Name $item.Name -ErrorAction SilentlyContinue
                Write-Host "✅ Deshabilitado con éxito."
            } catch {
                Write-Host "⚠️ No se pudo deshabilitar: $($_.Exception.Message)"
            }
        }
    }
}



function Ask-WindowsUpdate {
    $response = Read-Host "¿Deseas buscar actualizaciones de Windows antes de optimizar? (s/n)"
    if ($response -eq "s") {
        Write-Host "🔄 Buscando actualizaciones..."
        UsoClient StartScan
    }
}

$currentWallpaper = (Get-ItemProperty "HKCU:\Control Panel\Desktop").Wallpaper
Copy-Item $currentWallpaper "$env:USERPROFILE\Documents\fondo_backup.jpg" -ErrorAction SilentlyContinue


function Disable-Wallpaper {
    Write-Host "🖼️ Desactivando fondo de pantalla..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value ""
    rundll32.exe user32.dll,UpdatePerUserSystemParameters
}

# =======================
# EJECUCIÓN PRINCIPAL
# =======================

Write-Host "`n==== MODO JUEGO ACTIVADO ====" -ForegroundColor Green

Ask-WindowsUpdate
Set-VisualEffectsPerformance
Set-MaximumPerformancePlan
Apply-BCDEditTweaks
Disable-Wallpaper
Disable-UnneededServices
Remove-Bloatware
Ask-ToRemoveOptionalApps
Disable-StartupApps



Write-Host "`n✅ Optimización de Modo Juego completada." -ForegroundColor Cyan
