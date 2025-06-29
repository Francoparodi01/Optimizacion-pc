# 🎮 ModoJuego - Optimizador de Windows para Gaming

**ModoJuego** es una herramienta para optimizar tu entorno Windows antes de jugar, desactivando procesos y servicios innecesarios, limpiando la RAM, activando el plan de energía adecuado y mejorando el rendimiento general. Incluye la opción de restaurar el entorno una vez finalizada la sesión de juego.

---

## 📥 Instalación

1. Descargar el archivo `.zip` del proyecto.
2. Descomprimir el contenido en cualquier carpeta.
3. Ejecutar el archivo `ModoJuego.exe` con doble clic (requiere permisos de administrador).

> 💡 *Se recomienda fijar la ubicación del `.exe` en una ruta que no se mueva, ya que se utiliza para restaurar configuraciones.*

---

## ▶️ Cómo utilizar ModoJuego

1. **Agregar la ruta del ejecutable de CS2** (por ejemplo: `C:\Archivos de programa (x86)\Steam\steam.exe`).
2. ✅ **(Solo la primera vez)**: Activar la opción `Validar archivos`.
3. 🧰 **(Opcional)**: Habilitar la opción `Optimización profunda de Windows` si se desea mejorar aún más el rendimiento.
4. 🔥 Presionar **"Activar Modo Juego"**.

Esto realizará acciones como:
- Detener servicios innecesarios.
- Cerrar procesos de fondo.
- Limpiar RAM standby.
- Configurar el plan de energía "Máximo rendimiento".
- Iniciar CS2 con prioridad alta y afinidad optimizada.

---

## ♻️ Restaurar entorno (al terminar de jugar)

Una vez que termines de jugar y quieras restaurar el sistema a su estado anterior:

1. Ejecutar el archivo `Exit-Game-Mode.exe` (o presionar el botón correspondiente si lo integraste en GUI).
2. Se recomienda correrlo **1 o 2 veces** para asegurar que todos los servicios y configuraciones se restablezcan correctamente.

---

## ⚠️ Requisitos

- Windows 10 / 11
- Ejecutar como administrador
- Steam instalado y configurado correctamente

---

## 📁 Archivos incluidos

- `ModoJuego.exe`: ejecutable principal.
- `EmptyStandbyList.exe`: utilidad para limpiar memoria standby.
- `Exit-Game-Mode.exe`: restaurador de entorno.
- `icono.ico`: ícono personalizado.

---

## 🙌 Agradecimientos

Desarrollado por **Franco Parodi** para mejorar el rendimiento de Windows en sesiones gaming competitivas.

