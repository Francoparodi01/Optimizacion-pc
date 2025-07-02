Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# ====== Formulario ======
$form = New-Object System.Windows.Forms.Form
$form.Text          = "Modo Juego - CS2"
$form.Size          = New-Object System.Drawing.Size(520, 560)
$form.StartPosition = "CenterScreen"
$form.Topmost       = $true

# Checkbox: Validar archivos
$chkValidate = New-Object System.Windows.Forms.CheckBox
$chkValidate.Text     = "🔍 Validar archivos CS2"
$chkValidate.AutoSize = $true
$chkValidate.Location = New-Object System.Drawing.Point(30, 70)
$form.Controls.Add($chkValidate)

# Checkbox: Optimización profunda
$chkDeep = New-Object System.Windows.Forms.CheckBox
$chkDeep.Text     = "🧰 Optimización profunda de Windows"
$chkDeep.AutoSize = $true
$chkDeep.Location = New-Object System.Drawing.Point(30, 100)
$form.Controls.Add($chkDeep)

# Label + TextBox + Botón “Examinar” para ruta de CS2
$lblPath = New-Object System.Windows.Forms.Label
$lblPath.Text     = "Ruta a CS2 (.exe):"
$lblPath.AutoSize = $true
$lblPath.Location = New-Object System.Drawing.Point(30, 140)
$form.Controls.Add($lblPath)

$txtPath = New-Object System.Windows.Forms.TextBox
$txtPath.Size     = New-Object System.Drawing.Size(330, 22)
$txtPath.Location = New-Object System.Drawing.Point(30, 160)
$txtPath.Text     = "$env:ProgramFiles(x86)\Steam\Steam.exe"
$form.Controls.Add($txtPath)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text     = "Examinar…"
$btnBrowse.Size     = New-Object System.Drawing.Size(75, 22)
$btnBrowse.Location = New-Object System.Drawing.Point(370, 158)
$form.Controls.Add($btnBrowse)
$btnBrowse.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "EXE files (*.exe)|*.exe|All files (*.*)|*.*"
    if (Split-Path $txtPath.Text -ErrorAction SilentlyContinue) {
        $ofd.InitialDirectory = Split-Path $txtPath.Text
    }
    if ($ofd.ShowDialog() -eq 'OK') {
        $txtPath.Text = $ofd.FileName
    }
})

# Botones de acción
$btnOn = New-Object System.Windows.Forms.Button
$btnOn.Text     = "🎮 Activar Modo Juego"
$btnOn.Size     = New-Object System.Drawing.Size(200,40)
$btnOn.Location = New-Object System.Drawing.Point(30, 200)
$form.Controls.Add($btnOn)

$btnOff = New-Object System.Windows.Forms.Button
$btnOff.Text     = "🔄 Restaurar Entorno"
$btnOff.Size     = New-Object System.Drawing.Size(200,40)
$btnOff.Location = New-Object System.Drawing.Point(250, 200)
$form.Controls.Add($btnOff)

# TextBox para logs
$output = New-Object System.Windows.Forms.TextBox
$output.Multiline   = $true
$output.ScrollBars  = "Vertical"
$output.Size        = New-Object System.Drawing.Size(460,260)
$output.Location    = New-Object System.Drawing.Point(30, 260)
$output.ReadOnly    = $true
$output.BackColor   = "Black"
$output.ForeColor   = "Lime"
$form.Controls.Add($output)

# Función genérica para invocar scripts
function Invoke-ScriptAsync {
    param(
        [Parameter(Mandatory)] [string] $ScriptPath,
        [string[]]             $ArgumentList = @()
    )

    if (-not (Test-Path $ScriptPath)) {
        $output.AppendText("❌ No se encontró: $ScriptPath`r`n")
        return
    }

    # Muestro la invocación real tal como la va a ejecutar
    $cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" $($ArgumentList -join ' ')"
    $output.AppendText("🟢 Ejecutando:`n$cmd`r`n")

    # Arranco el Job apuntando directamente al ScriptFile (no al ScriptBlock)
    $job = Start-Job -FilePath $ScriptPath -ArgumentList $ArgumentList

    # Registro el evento para cuando termine
    Register-ObjectEvent -InputObject $job -EventName StateChanged -Action {
        if ($Event.SourceEventArgs.JobStateInfo.State -eq 'Completed') {
            $text = Receive-Job $Event.Sender -Keep
            $form.Invoke([Action]{
                $output.AppendText("$text`r`n✅ Script finalizado.`r`n")
            })
            Remove-Job $Event.Sender
        }
    }
}

# Base directory de los scripts
$basePath = [AppDomain]::CurrentDomain.BaseDirectory

# Evento: Activar Modo Juego
$btnOn.Add_Click({
    # 1) Ruta dinámica al EXE de CS desde el TextBox
    $csExe = $txtPath.Text.Trim()
    if (-not (Test-Path $csExe)) {
        [System.Windows.Forms.MessageBox]::Show(
            "No se encontró:`n$csExe","Error","OK","Error"
        )
        return
    }

    # 2) Armo los switches opcionales
    $flags = @()
    if ($chkValidate.Checked) { $flags += "-ValidateFiles" }
    if ($chkDeep.Checked)     { $flags += "-DeepOptimize" }

    # 3) La invocación EXACTA que quieres
    $cmd = ".\game-mode.ps1 -CsExePath `"$csExe`" $($flags -join ' ')"
    $output.AppendText("🟢 Ejecutando:`n$cmd`n")

    # 4) Llamo PowerShell.exe con -File
    $fullArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$basePath\game-mode.ps1`" -CsExePath `"$csExe`" $($flags -join ' ')"
    Start-Process -FilePath powershell.exe -ArgumentList $fullArgs -NoNewWindow -Wait

    $output.AppendText("✅ game-mode.ps1 finalizó.`n")
})


# Evento: Restaurar Entorno
$btnOff.Add_Click({
    $script = Join-Path $basePath "exit-game-mode.ps1"

    if (-not (Test-Path $script)) {
        $output.AppendText("❌ No se encontró: $script`r`n")
        return
    }

    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$script`" -NoInteraction"
    $output.AppendText("🟢 Ejecutando:`n$script -NoInteraction`n")

    # Ejecutar el script directamente (sin job)
    Start-Process -FilePath powershell.exe -ArgumentList $args -NoNewWindow -Wait

    $output.AppendText("✅ exit-game-mode.ps1 finalizó.`n")
})


[void]$form.ShowDialog()