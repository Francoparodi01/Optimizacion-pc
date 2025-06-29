param(
    [string]$CsExePath,
    [switch]$ValidateFiles,
    [switch]$DeepOptimize
)

# -- Función de optimización profunda --
function Optimize-WindowsForGaming {
    Write-Output "`n🧰 Iniciando optimización profunda de Windows...`n"

    # Plan energía (suprimir warning)
    Write-Output "`n⚡ Aplicando plan 'Máximo rendimiento'...`n"
    & powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    Write-Output "`n✅ Plan aplicado.`n"

    # Servicios extra
    $svcs = @(
        "Spooler","dmwappushservice","W32Time","WerSvc","WpnService","WwanSvc",
        "RemoteRegistry","ShellHWDetection","SensorService","SensorDataService",
        "StorSvc","TimeBrokerSvc","UserDataSvc","UserDataAccess","WpcMonSvc"
    )
    foreach ($s in $svcs) {
        Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Output "`n⛔ Servicio detenido: $s`n"
    }

    # Telemetría (tareas y servicios)
    $tasks = @(
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
        "\Microsoft\Windows\Customer Experience Improvement Program\Uploader"
    )
    foreach ($t in $tasks) {
        schtasks /Change /TN $t /Disable | Out-Null
        Write-Output "`n🚫 Tarea deshabilitada: $t`n"
    }
    foreach ($svc in @("DiagTrack","dmwappushservice","WMPNetworkSvc")) {
        Stop-Service $svc -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Output "`n🚫 Servicio telemetría: $svc`n"
    }

    # Notificaciones & Action Center
    Write-Output "`n🔕 Desactivando notificaciones y Action Center...`n"
    Try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications" `
            -Name "ToastEnabled" -Value 0 -ErrorAction Stop
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
            -Force | Out-Null
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
            -Name "DisableNotificationCenter" -Type DWord -Value 1 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
            -Name "SubscribedContent-338388Enabled" -Value 0 -ErrorAction Stop
        Write-Output "`n✅ Notificaciones desactivadas.`n"
    } Catch {
        Write-Output "`n⚠️ No se pudieron desactivar notificaciones.`n"
    }

    # Efectos Visuales = Mejor rendimiento
    Write-Output "`n✨ Ajustando Efectos Visuales a máximo rendimiento...`n"
    Try {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
            -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
            -Name "VisualFXSetting" -Value 2 -ErrorAction Stop
        RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True
        Write-Output "`n✅ Efectos Visuales ajustados.`n"
    } Catch {
        Write-Output "`n⚠️ No se pudo ajustar Efectos Visuales.`n"
    }
}

# -- Función Modo Juego --
function Enter-GameMode {
    Write-Output "`n🎮 ACTIVANDO MODO JUEGO...`n"

    # Guardar plan original
    Try {
        (powercfg /getactivescheme) -match ":\s(.+)\s\(" | Out-Null
        $Matches[1] | Set-Content "$env:TEMP\original_power_plan.txt"
        Write-Output "`n💾 Plan original guardado.`n"
    } Catch {
        Write-Output "`n⚠️ No se pudo guardar plan original.`n"
    }

    # Aplicar plan rendimiento
    Write-Output "`n⚡ Aplicando plan Máximo rendimiento...`n"
    & powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    Write-Output "`n✅ Plan aplicado.`n"

    # Servicios básicos
    $svcs2 = @("WSearch","SysMain","Fax","MapsBroker","DiagTrack",
               "XblAuthManager","XblGameSave","XboxGipSvc",
               "BITS","UsoSvc","wuauserv","PrintSpooler")
    foreach ($s in $svcs2) {
        Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
        Set-Service  -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Output "`n⛔ Servicio detenido: $s`n"
    }

    # Cerrar apps de fondo
    $apps = @("OneDrive","FACEIT","EADesktop","RiotClientServices","Docker Desktop","LGHUB")
    foreach ($a in $apps) {
        Get-Process -Name $a -ErrorAction SilentlyContinue |
            Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Output "`n🛑 Proceso cerrado: $a`n"
    }

    # Efectos de escritorio
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" `
        -Value ([byte[]](0x90,0x12,0x03,0x80,0x12,0x00,0x00,0x00)) `
        -ErrorAction SilentlyContinue
    Write-Output "`n🎨 Efectos de escritorio desactivados.`n"

    # Game Mode / DVR
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar"    -Name "AutoGameModeEnabled" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
        -Name "GameMode" -Value 1 -ErrorAction SilentlyContinue
    Write-Output "`n✅ Game Mode activado.`n"

    # Limpieza de RAM standby
    $ramCleaner = "C:\GamingTools\EmptyStandbyList.exe"
    if (Test-Path $ramCleaner) {
        Start-Process $ramCleaner -ArgumentList workingsets -Wait
        Write-Output "`n🧼 RAM standby limpiada.`n"
    } else {
        Write-Output "`n❌ EmptyStandbyList.exe no encontrado.`n"
    }

    # Optimización profunda
    if ($DeepOptimize) { Optimize-WindowsForGaming }

    # Validar archivos
    if ($ValidateFiles) {
        Write-Output "`n🔍 Validando CS2 en Steam...`n"
        Start-Process "steam://validate/730"
    }

    # Lanzar CS2 usando la ruta del usuario
    Write-Output "`n🚀 Lanzando CS2 desde: $CsExePath`n"
    Start-Process -FilePath $CsExePath -ArgumentList "-applaunch 730"
    do { Start-Sleep 1 } until (Get-Process -Name cs2 -ErrorAction SilentlyContinue)
    $p = Get-Process -Name cs2
    $p.PriorityClass     = 'High'
    $p.ProcessorAffinity = 85
    Write-Output "`n⚙ Prioridad=High, Afinidad=0,2,4,6.`n"
}

# — EJECUCIÓN —
Enter-GameMode
