﻿# =======================
# Game Mode OFF - Restaurar Sistema
# =======================

Write-Host "`n==== DESACTIVANDO MODO JUEGO ====" -ForegroundColor Yellow

# =======================
# FUNCIONES
# =======================

function Enable-PreviouslyDisabledServices {
    Write-Host "♻️ Rehabilitando servicios detenidos..."

    $services = @(
        "Fax", "DiagTrack", "PrintSpooler", "WerSvc", "WSearch"
    )

    foreach ($svc in $services) {
        try {
            Set-Service -Name $svc -StartupType Manual -ErrorAction SilentlyContinue
            Start-Service -Name $svc -ErrorAction SilentlyContinue
            Write-Host "✅ Servicio $svc restaurado."
        } catch {
            Write-Host "⚠️ No se pudo restaurar el servicio $svc."
        }
    }
}

function Restore-DefaultVisualEffects {
    Write-Host "🎨 Restaurando efectos visuales predeterminados..."
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Value 1

    $RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $RegistryPath -Name ListviewAlphaSelect -Value 1
    Set-ItemProperty -Path $RegistryPath -Name TaskbarAnimations -Value 1
    Set-ItemProperty -Path $RegistryPath -Name ListviewShadow -Value 1
    Set-ItemProperty -Path $RegistryPath -Name IconsOnly -Value 1
}

function Restore-Wallpaper {
    Write-Host "🖼️ Restaurando fondo de pantalla (si se había guardado previamente)..."
    # Puedes guardar el fondo actual antes de borrarlo y restaurarlo aquí
    $WallpaperBackup = "$env:USERPROFILE\Documents\fondo_backup.jpg"
    if (Test-Path $WallpaperBackup) {
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name Wallpaper -Value $WallpaperBackup
        rundll32.exe user32.dll,UpdatePerUserSystemParameters
        Write-Host "✅ Fondo restaurado desde backup."
    } else {
        Write-Host "⚠️ No se encontró fondo de pantalla de respaldo."
    }
}

function Restore-DefaultPowerPlan {
    Write-Host "🔌 Restaurando plan de energía recomendado por Windows..."
    powercfg -setactive SCHEME_BALANCED
}

function Revert-BCDEditTweaks {
    Write-Host "🧾 Revirtiendo configuraciones bcdedit..."
    bcdedit /deletevalue useplatformtick
    bcdedit /deletevalue disabledynamictick
}

# =======================
# EJECUCIÓN
# =======================

Enable-PreviouslyDisabledServices
Restore-DefaultVisualEffects
Restore-Wallpaper
Restore-DefaultPowerPlan
Revert-BCDEditTweaks

Write-Host "`n✅ Sistema restaurado después del modo juego." -ForegroundColor Cyan
