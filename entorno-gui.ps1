Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# ====== Formulario ======
$form = New-Object System.Windows.Forms.Form
$form.Text          = "Modo Juego - CS2"
$form.Size          = New-Object System.Drawing.Size(520, 600)
$form.StartPosition = "CenterScreen"
$form.Topmost       = $true

# Función para loguear en la consola
function Log {
    param ([string]$text)
    $form.Invoke([Action]{
        $output.AppendText("$text`r`n")
        $output.SelectionStart = $output.Text.Length
        $output.ScrollToCaret()
    })
}

# ====== Componentes ======

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

# Label + TextBox + Botón “Examinar”
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

# Botón: Activar Modo Juego
$btnOn = New-Object System.Windows.Forms.Button
$btnOn.Text     = "🎮 Activar Modo Juego"
$btnOn.Size     = New-Object System.Drawing.Size(200,40)
$btnOn.Location = New-Object System.Drawing.Point(30, 200)
$form.Controls.Add($btnOn)

# Botón: Restaurar Entorno
$btnOff = New-Object System.Windows.Forms.Button
$btnOff.Text     = "🔄 Restaurar Entorno"
$btnOff.Size     = New-Object System.Drawing.Size(200,40)
$btnOff.Location = New-Object System.Drawing.Point(250, 200)
$form.Controls.Add($btnOff)

# Botón: Reparar Sistema
$btnFix = New-Object System.Windows.Forms.Button
$btnFix.Text     = "🧯 Reparar Sistema"
$btnFix.Size     = New-Object System.Drawing.Size(420,35)
$btnFix.Location = New-Object System.Drawing.Point(30, 250)
$form.Controls.Add($btnFix)

# TextBox consola
$output = New-Object System.Windows.Forms.TextBox
$output.Multiline   = $true
$output.ScrollBars  = "Vertical"
$output.Size        = New-Object System.Drawing.Size(460,260)
$output.Location    = New-Object System.Drawing.Point(30, 300)
$output.ReadOnly    = $true
$output.BackColor   = "Black"
$output.ForeColor   = "Lime"
$form.Controls.Add($output)

# BasePath
$basePath = [AppDomain]::CurrentDomain.BaseDirectory

# ====== Eventos ======

# Activar Modo Juego
$btnOn.Add_Click({
    $csExe = $txtPath.Text.Trim()
    if (-not (Test-Path $csExe)) {
        [System.Windows.Forms.MessageBox]::Show("No se encontró:`n$csExe","Error","OK","Error")
        return
    }

    $flags = @()
    if ($chkValidate.Checked) { $flags += "-ValidateFiles" }
    if ($chkDeep.Checked)     { $flags += "-DeepOptimize" }

    $cmd = ".\game-mode.ps1 -CsExePath `"$csExe`" $($flags -join ' ')"
    Log "🟢 Ejecutando:`n$cmd"

    $fullArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$basePath\game-mode.ps1`" -CsExePath `"$csExe`" $($flags -join ' ')"
    Start-Process -FilePath powershell.exe -ArgumentList $fullArgs -NoNewWindow -Wait

    Log "✅ game-mode.ps1 finalizó."
})

# Restaurar Entorno
$btnOff.Add_Click({
    $script = Join-Path $basePath "exit-game-mode.ps1"
    if (-not (Test-Path $script)) {
        Log "❌ No se encontró: $script"
        return
    }

    $args = "-NoProfile -ExecutionPolicy Bypass -File `"$script`" -NoInteraction"
    Log "🟢 Ejecutando:`n$script -NoInteraction"
    Start-Process -FilePath powershell.exe -ArgumentList $args -NoNewWindow -Wait
    Log "✅ exit-game-mode.ps1 finalizó."
})

# Reparar Sistema
$btnFix.Add_Click({
    $script = Join-Path $basePath "reparar-windows.ps1"
    if (-not (Test-Path $script)) {
        Log "❌ No se encontró: $script"
        return
    }

    # Ejecutar PowerShell en ventana nueva visible
    Log "🛠 Ejecutando:`n$script (modo interactivo)"
    Start-Process -FilePath powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Wait
    Log "✅ reparar-windows.ps1 finalizó."
})

# Mostrar
[void]$form.ShowDialog()
