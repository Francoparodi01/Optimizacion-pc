Write-Output "`n👀 Esperando a que se abra CS2 manualmente..."
$cs2Detected = $false

while (-not $cs2Detected) {
    $proc = Get-Process -Name "cs2" -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Output "`n✅ CS2 detectado. Aplicando optimización del proceso..."
        $cs2Detected = $true

        try {
            # Afinidad completa
            $logicalCores = [Environment]::ProcessorCount
            $affinityMask = [Math]::Pow(2, $logicalCores) - 1
            $proc.ProcessorAffinity = [int]$affinityMask

            # Prioridad alta
            $proc.PriorityClass = 'High'

            # GPU Scheduling
            New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" `
                -Name "HwSchMode" -PropertyType DWord -Value 2 -Force | Out-Null

            # GPU Preferida para CS2
            $csPath = $proc.Path
            if ($csPath) {
                New-ItemProperty -Path "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences" `
                    -Name "$csPath" -PropertyType String -Value "GpuPreference=2;" -Force | Out-Null
            }

            Write-Output "`n⚙️ Afinidad y prioridad aplicadas a CS2 correctamente."
        }
        catch {
            Write-Output "`n⚠️ Error aplicando configuración al proceso CS2: $_"
        }
        break
    }

    Start-Sleep -Seconds 1
}

Write-Output "`n🎮 Watcher terminado. ¡Buena partida!"
