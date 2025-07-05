# Reparar-Windows-Interactivo.ps1
# Script interactivo para reparar Windows paso a paso

function Preguntar {
    param([string]$mensaje)
    do {
        $respuesta = Read-Host "$mensaje (S/N)"
    } while ($respuesta -notmatch '^[sSnN]$')
    return $respuesta -match '^[sS]$'
}

$logPath = "$env:USERPROFILE\Desktop\reparacion_windows_log.txt"
Start-Transcript -Path $logPath -Append
Write-Host "`n===== REPARACIÓN DE WINDOWS - INICIO =====`n" -ForegroundColor Cyan

# Paso 1: DISM
if (Preguntar "¿Querés ejecutar DISM para reparar la imagen del sistema?") {
    Write-Host "`nEjecutando DISM..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
} else {
    Write-Host "Saltando DISM..." -ForegroundColor Gray
}

# Paso 2: SFC
if (Preguntar "¿Querés ejecutar SFC para verificar y reparar archivos del sistema?") {
    Write-Host "`nEjecutando SFC..." -ForegroundColor Yellow
    sfc /scannow
} else {
    Write-Host "Saltando SFC..." -ForegroundColor Gray
}

# Paso 3: Reiniciar servicios
if (Preguntar "¿Querés reiniciar servicios como Windows Update y BITS?") {
    $servicios = @("wuauserv", "bits")
    foreach ($svc in $servicios) {
        Write-Host "`nReiniciando servicio: $svc" -ForegroundColor Yellow
        Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        Start-Service -Name $svc
        sc config $svc start= auto | Out-Null
    }
} else {
    Write-Host "Saltando reinicio de servicios..." -ForegroundColor Gray
}

# Paso 4: Registrar DLLs
if (Preguntar "¿Querés registrar DLLs comunes como jscript.dll y vbscript.dll?") {
    $dlls = @("jscript.dll", "vbscript.dll", "mshtml.dll")
    foreach ($dll in $dlls) {
        Write-Host "Registrando $dll..." -ForegroundColor Yellow
        try {
            regsvr32 /s $dll
        } catch {
            Write-Host "Error al registrar $dll" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Saltando registro de DLLs..." -ForegroundColor Gray
}

# Paso 5: Reinstalar apps del sistema
if (Preguntar "¿Querés reinstalar las apps del sistema (solo Windows 10/11)?") {
    Write-Host "`nReinstalando apps del sistema..." -ForegroundColor Yellow
    Get-AppxPackage -AllUsers | Foreach {
        try {
            Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"
        } catch {
            Write-Host "Error con el paquete $($_.Name)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Saltando reinstalación de apps..." -ForegroundColor Gray
}

Write-Host "`n===== REPARACIÓN FINALIZADA =====" -ForegroundColor Green
Write-Host "Log guardado en: $logPath" -ForegroundColor Cyan
Stop-Transcript


# Fin del script