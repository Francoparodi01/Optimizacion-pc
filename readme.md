# 🎮 OptimizadorCS2 - Optimizador de Windows para Gaming

**Optimizador** es una herramienta para optimizar tu entorno Windows antes de jugar, desactivando procesos y servicios innecesarios, limpiando la RAM, activando el plan de energía adecuado y mejorando el rendimiento general. Incluye la opción de restaurar el entorno una vez finalizada la sesión de juego.

---

## 📥 Instalación

1. Descargar el archivo `.zip` del proyecto.
2. Descomprimir el contenido en cualquier carpeta.
3. Ejecutar el archivo `Optimizador.exe` con doble clic (requiere permisos de administrador).

> 💡 *Se recomienda fijar la ubicación del `.exe` en una ruta que no se mueva, ya que se utiliza para restaurar configuraciones.*

---

## ‼️ ALERTA IMPORTANTE

🔒 **Antes de aplicar cualquier optimización, se recomienda fuertemente crear un punto de restauración del sistema.**

Esto te permitirá volver al estado anterior de Windows en caso de que algo no funcione correctamente o quieras deshacer los cambios.

### ¿Cómo crear un punto de restauración?

1. Buscar en el menú Inicio: `Crear un punto de restauración`.
2. Seleccionar tu unidad principal (C:), y hacer clic en `Crear`.
3. Asignarle un nombre como "Antes de Optimizador" y confirmar.

☑️ Este paso es **opcional pero muy recomendable**, especialmente si vas a usar la opción de **"Optimización profunda de Windows"** que realiza cambios más extensos en el sistema.

---

## ▶️ Cómo utilizar Optimizador

1. **Agregar la ruta del ejecutable de CS2** (por ejemplo: `C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\bin\win64`).
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

- `Optimizador.exe`: ejecutable principal.
- `EmptyStandbyList.exe`: utilidad para limpiar memoria standby.
- `Exit-Game-Mode.exe`: restaurador de entorno.
- `icono.ico`: ícono personalizado.

---

## 🙌 Agradecimientos

Desarrollado por **Franco Parodi** para mejorar el rendimiento de Windows en sesiones gaming competitivas.
