# ============================
# Interfaz Gráfica: Optimizador de Juegos
# ============================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Crear formulario
$form = New-Object System.Windows.Forms.Form
$form.Text = "Optimizador de Juegos - Modo Game"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

# Crear botón: Activar Modo Juego
$btnActivar = New-Object System.Windows.Forms.Button
$btnActivar.Text = "Activar Modo Juego"
$btnActivar.Location = New-Object System.Drawing.Point(30, 20)
$btnActivar.Size = New-Object System.Drawing.Size(150, 40)
$form.Controls.Add($btnActivar)

# Crear botón: Salir del Modo Juego
$btnSalir = New-Object System.Windows.Forms.Button
$btnSalir.Text = "Salir del Modo Juego"
$btnSalir.Location = New-Object System.Drawing.Point(200, 20)
$btnSalir.Size = New-Object System.Drawing.Size(150, 40)
$form.Controls.Add($btnSalir)

# Crear área de texto para consola
$txtConsola = New-Object System.Windows.Forms.TextBox
$txtConsola.Multiline = $true
$txtConsola.ScrollBars = "Vertical"
$txtConsola.ReadOnly = $true
$txtConsola.BackColor = "Black"
$txtConsola.ForeColor = "Lime"
$txtConsola.Font = "Consolas, 10pt"
$txtConsola.Location = New-Object System.Drawing.Point(30, 80)
$txtConsola.Size = New-Object System.Drawing.Size(520, 350)
$form.Controls.Add($txtConsola)

# Función para ejecutar scripts y mostrar salida en consola
function Ejecutar-Script {
    param($rutaScript)

    $output = powershell -ExecutionPolicy Bypass -File $rutaScript 2>&1

    $popup = New-Object System.Windows.Forms.Form
    $popup.Text = "Salida del Script"
    $popup.Size = New-Object System.Drawing.Size(600, 400)
    $popup.StartPosition = "CenterScreen"

    $txtPopup = New-Object System.Windows.Forms.TextBox
    $txtPopup.Multiline = $true
    $txtPopup.ScrollBars = "Vertical"
    $txtPopup.ReadOnly = $true
    $txtPopup.BackColor = "Black"
    $txtPopup.ForeColor = "Lime"
    $txtPopup.Font = "Consolas, 10pt"
    $txtPopup.Dock = "Fill"

    $txtPopup.AppendText(">>> Ejecutando $rutaScript`r`n")
    $txtPopup.AppendText($output -join "`r`n")
    $txtPopup.AppendText("`r`n--- FIN DEL SCRIPT ---`r`n`r`n")

    $popup.Controls.Add($txtPopup)
    [void]$popup.ShowDialog()
}


# Eventos para los botones
$btnActivar.Add_Click({
    Ejecutar-Script -rutaScript ".\game-mode.ps1"
})

$btnSalir.Add_Click({
    Ejecutar-Script -rutaScript ".\exit-game-mode.ps1"
})

# Mostrar el formulario
[void]$form.ShowDialog()
