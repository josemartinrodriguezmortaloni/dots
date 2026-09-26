# DESIGN.md — Brutalismo instrumental de SimPlant

Sistema de estilo para cualquier pantalla de SimPlant: un tablero de monitoreo, una app de gestión, un formulario, un login, una pantalla de celular.

La interfaz es un **instrumento**: lienzo gris carbón, dibujo de línea, estructura expuesta y un solo acento blanco. Es brutalista porque muestra su grilla, sus bordes y sus códigos. Tiene gusto porque cada elemento visible cumple una función y nada se agrega por decoración.

Origen de cada decisión:

- **Geometría y componentes:** medidos cuadro a cuadro en las pantallas de la CIA de _The Amateur_ (2025).
- **Paleta, tipografía, movimiento y rechazos:** decisiones propias, con criterios de las skills `impeccable` y `design-taste-frontend`.

El sistema tiene tres capas:

1. **Invariantes** (§3): color, tipografía, línea, esquinas, movimiento y rechazos. Valen en toda pantalla.
2. **Densidad** (§4): cuánto cromo, cuánta textura y qué tamaños lleva la pantalla. Se elige una densidad por pantalla.
3. **Catálogo de la película**: composiciones y componentes observados en los videos. Está en [`DESIGN-CATALOG.md`](DESIGN-CATALOG.md). Leelo cuando la pantalla tenga densidad operativa, o cuando necesites un componente de la película: dial, gráfico de pistas, terminal, tile de video, detección facial, región de escaneo.

Leé [`DESIGN-EVIDENCE.md`](DESIGN-EVIDENCE.md) cuando necesites verificar una medida o un layout contra el cuadro original. Sus colores son los de la película y no aplican a este sistema.

## Vocabulario

Estas palabras tienen un significado fijo en los tres archivos:

- **Lienzo**: el fondo gris carbón de la pantalla.
- **Panel**: un rectángulo con cromo que agrupa un solo tema de datos o de acciones.
- **Cromo**: todo lo que rodea al contenido de un panel: borde, esquinas en L, badge, título, controles de ventana.
- **Acento**: el blanco puro, `--accent`. Marca selección, acción primaria, avance y foco.
- **Inversión**: un bloque relleno de `--accent` con texto `--on-accent`. Es la forma principal del acento.
- **Lectura**: un valor que el usuario lee para decidir o actuar: un dato, una etiqueta de campo, un mensaje.
- **Textura**: microtexto que da densidad y no se lee (IPs, `SELECT`, `04.02`). Solo existe en densidad operativa.
- **Vivo**: un dato que cambia en el tiempo mientras está visible.
- **Densidad**: el nivel de §4 que fija el cromo y los tamaños de una pantalla: `operativa`, `estandar` o `compacta`.
- **Observado**: una medida o un componente medido en los videos.
- **Derivado**: un valor o componente que la película no muestra, construido con los invariantes. Los componentes derivados siguen las mismas reglas que los observados.

---

## 1. Procedimiento

Seguí los pasos en orden para cada pantalla. Cada paso termina en su criterio de completitud.

1. **Nombrá la tarea y el contenido.** Escribí en una oración qué hace el usuario en esta pantalla. Listá cada bloque de contenido con su tipo: formulario, acción, texto, navegación, lista, tabla, serie temporal, log, estado, imagen o video, objeto único. Listo cuando cada bloque tiene un tipo.
2. **Elegí la densidad** con la regla de §4.1. Listo cuando la pantalla tiene una densidad y la regla la justifica.
3. **Componé la grilla** (§4.3). En densidad operativa, partí de una composición del catálogo o armá una libre. En las otras, armá una composición libre. Listo cuando cada bloque del paso 1 tiene una región y un ancho en columnas para cada breakpoint, y el bloque principal tiene el ancho mayor.
4. **Armá el shell** de la densidad elegida (§4.4). Listo cuando el shell cumple la regla de scroll de su densidad.
5. **Convertí cada bloque en paneles y componentes.** Usá la tabla de §7 para encontrar el componente de cada elemento. Listo cuando cada elemento tiene un componente de §5 o del catálogo, y cada panel tiene el cromo que exige su densidad (§4.2).
6. **Asigná color por rol** (§3.2). Listo cuando cada uso de blanco de acento, rojo o ámbar corresponde a una fila de la tabla de roles.
7. **Definí los estados** de cada elemento interactivo (§6) y de cada bloque de datos (§5.20). Listo cuando cada elemento interactivo tiene reposo, hover, foco, presionado y deshabilitado, y cada bloque de datos tiene vacío, carga y error.
8. **Verificá con §8.** Listo cuando pasan todos los puntos universales, los puntos de la densidad elegida y ningún patrón de §3.7 aparece en la pantalla.

---

## 2. ADN del estilo

Una pantalla que cumple estas seis propiedades se reconoce como parte de la familia, en cualquier densidad.

1. **Lienzo carbón, dibujo de línea.** El fondo es gris carbón neutro, nunca negro. El contenido se dibuja con líneas de 1 px, texto chico y rellenos pequeños. La pantalla se lee como un instrumento.
2. **Grises neutros y un solo acento blanco.** El texto va en grises sin tinte. El blanco marca selección, acción primaria y avance, casi siempre por inversión. El rojo y el ámbar son señales puntuales.
3. **Esquinas rectas con escuadras en L.** Todo es rectangular. Las escuadras en L de las esquinas son la firma visual del panel.
4. **Una grotesca neutra, Geist, en tres pesos.** Rótulos, botones y títulos en mayúsculas. La jerarquía sale del tamaño, el peso y la inversión.
5. **Software plausible de hoy.** La interfaz se comporta como un sistema real: menús, ventanas, atajos de teclado, rutas, códigos.
6. **Cambios secos con tacto.** Color y posición responden en 120 ms con salida exponencial. El contenido cambia por corte. Solo los datos vivos se mueven solos.

Contexto de diseño de la geometría, sin métricas:

- [F1] Paul Roberts, "The Amateur (2025)", cliente VineFX — <https://paulroberts.tv/projects/the-amateur-2025>. Pantallas actuales, de alta tecnología y modulares, sobre una grilla que se subdivide o enmarca elementos grandes.
- [F2] British Cinematographer, "Vine FX exhibits original screen graphics for The Amateur" (20/06/2025) — <https://britishcinematographer.co.uk/vine-fx-exhibits-original-screen-graphics-for-the-amateur/>. Avanzado pero creíble. La IA muestra resultados, no procesos.

---

## 3. Capa 1 — Invariantes

### 3.1 Tokens

Copiá este bloque como archivo de tokens. Ningún componente declara un color, tamaño o duración literal fuera de él. Poné `data-density` en el elemento raíz de cada pantalla.

```css
:root {
  /* Color — grises neutros (croma 0) y un acento blanco. */
  --void: #1F1F1F;        /* lienzo, gris carbón */
  --panel: #262626;       /* fondo de panel */
  --panel-2: #303030;     /* cajas internas, campos, filas en hover */
  --line: #4A4A4A;        /* borde de panel */
  --grid: #333333;        /* grilla de gráficos, separador de filas */
  --ink-100: #D4D4D4;     /* lecturas, títulos */
  --ink-300: #B0B0B0;     /* datos, etiquetas, escuadras en L */
  --ink-500: #9A9A9A;     /* sufijos, textura, placeholder */
  --ink-700: #707070;     /* contornos de control, controles de ventana, texto deshabilitado */
  --ink-900: #3A3A3A;     /* texto fantasma, pista de barras, borde deshabilitado */
  --accent: #FFFFFF;      /* selección, acción primaria, avance, foco */
  --accent-press: #C8C8C8;/* relleno de acento presionado */
  --on-accent: #1F1F1F;   /* texto sobre --accent, --amber-500 y --red-600 */
  --red-600: #E96D66;     /* error, acción destructiva */
  --amber-500: #D9974A;   /* tarea en progreso, detección */
  --scrim: color-mix(in srgb, var(--void) 80%, transparent); /* fondo detrás de un diálogo */

  /* Tipografía */
  --font-ui: "Geist", system-ui, sans-serif;
  --font-code: "Geist Mono", ui-monospace, monospace;
  --track-hero: -0.02em;
  --track-title: 0.02em;
  --track-label: 0.06em;
  --track-micro: 0.1em;

  /* Línea y forma */
  --stroke: 1px;
  --stroke-strong: 2px;
  --corner-arm: 10px;

  /* Movimiento */
  --dur-state: 120ms;
  --ease-state: cubic-bezier(0.25, 1, 0.5, 1); /* ease-out-quart */
  --press-shift: 1px;

  /* Capas */
  --z-dropdown: 10;
  --z-sticky: 20;
  --z-scrim: 30;
  --z-dialog: 40;
  --z-toast: 50;
  --z-tooltip: 60;

  --scale: 1;
}

@media (min-width: 2560px) {
  :root { --scale: 1.25; }
}

@media (prefers-reduced-motion: reduce) {
  :root { --dur-state: 0ms; --press-shift: 0px; }
}

[data-density="operativa"] {
  --t-hero: calc(28px * var(--scale));
  --t-title: calc(18px * var(--scale));
  --t-body: calc(13px * var(--scale));
  --t-label: calc(10px * var(--scale));
  --t-code: calc(9px * var(--scale));
  --t-micro: calc(7px * var(--scale));
  --t-badge: calc(20px * var(--scale));
  --badge: calc(28px * var(--scale));
  --control-h: calc(20px * var(--scale));
  --row: calc(20px * var(--scale));
  --gap: 6px;
  --pad-x: 12px;
  --pad-y: 8px;
}

[data-density="estandar"] {
  --t-hero: 28px;
  --t-title: 18px;
  --t-body: 14px;
  --t-label: 11px;
  --t-code: 12px;
  --t-micro: 10px;
  --t-badge: 16px;
  --badge: 24px;
  --control-h: 28px;
  --row: 32px;
  --gap: 8px;
  --pad-x: 16px;
  --pad-y: 12px;
}

[data-density="compacta"] {
  --t-hero: 24px;
  --t-title: 18px;
  --t-body: 15px;
  --t-label: 12px;
  --t-code: 13px;
  --t-micro: 11px;
  --t-badge: 16px;
  --badge: 24px;
  --control-h: 44px;
  --row: 44px;
  --gap: 8px;
  --pad-x: 16px;
  --pad-y: 12px;
}
```

- Las únicas variaciones de color permitidas son opacidades de estos tokens, con `color-mix()`.
- Todos los grises tienen croma 0. Un gris con tinte cálido o frío rompe la escala.
- El estilo es solo oscuro. No tiene tema claro.

### 3.2 Roles de color

Cada uso de un color que no sea gris corresponde a una fila de esta tabla.

| Color                     | Significado                                 | Ejemplos                                                                  |
| ------------------------- | ------------------------------------------- | ------------------------------------------------------------------------- |
| `--accent` como relleno   | Seleccionado, acción primaria, avance       | Botón primario, chip activo, casilla marcada, barra de progreso, ítem actual de la navegación lateral. |
| `--accent` como texto     | Proceso en curso, lectura destacada         | Sufijo `SCANNING`, hora de un reloj, ítem actual de la barra superior. Siempre en peso 500. |
| `--accent` como contorno  | Foco de teclado, fila seleccionada          | Contorno de foco, contorno interior de la fila seleccionada.              |
| `--red-600`               | Error, acción destructiva                   | Tag `ERROR`, botón `DELETE`, borde de campo inválido.                     |
| `--amber-500`             | Tarea en progreso, detección                | Badge `IN PROGRESS`, barra de recuadro facial, tarea en cola.             |
| Grises `ink`              | Todo lo demás                               | Texto, trazos, rayados, iconos, contornos, escuadras.                     |

- Cada panel tiene como máximo una acción primaria.
- El acento ocupa ≤ 10 % de los píxeles de la pantalla (≤ 5 % en operativa). Si pasa, el blanco deja de señalar.
- `--ink-100` y `--accent` difieren poco en luminancia (1,3:1). Por eso el acento como texto va siempre en peso 500, y la selección se marca con relleno o contorno, nunca solo con color de texto.
- El rojo ocupa un tag, una palabra, un borde o un botón destructivo. Nunca un área grande.

### 3.3 Contraste

Relaciones WCAG 2.x sobre `--panel` y sobre `--panel-2`:

| Token         | `--panel` | `--panel-2` | Uso                                                            |
| ------------- | --------- | ----------- | -------------------------------------------------------------- |
| `--accent`    | 15,1:1    | 13,2:1      | Todo texto. Texto `--on-accent` encima: 16,5:1.                 |
| `--ink-100`   | 10,2:1    | 8,9:1       | Todo texto.                                                    |
| `--ink-300`   | 7,0:1     | 6,1:1       | Todo texto.                                                    |
| `--amber-500` | 6,1:1     | 5,3:1       | Todo texto. Texto `--on-accent` encima: 6,7:1.                  |
| `--ink-500`   | 5,4:1     | 4,7:1       | Todo texto, incluido placeholder.                              |
| `--red-600`   | 4,9:1     | 4,3:1       | Rellenos, tags, bordes, iconos de error. Texto `--on-accent` encima: 5,4:1. |
| `--ink-700`   | 3,1:1     | 2,7:1       | Contornos de control, controles de ventana, texto deshabilitado. |
| `--line`      | 1,7:1     | 1,5:1       | Bordes de panel. Nunca el único límite de un control.          |

- Toda lectura usa un token con contraste ≥ 4,5:1 sobre su fondo. El placeholder también.
- El límite de todo control (campo, botón secundario, checkbox, chip) tiene ≥ 3:1 sobre su fondo: usá `--ink-700` o más claro.
- Un mensaje de error es texto `--ink-100` precedido de un tag `--red-600`. El texto del mensaje nunca va en rojo.

### 3.4 Tipografía

- **Familia UI:** Geist, una grotesca neutra. Una sola familia lleva títulos, rótulos, botones, datos y texto corrido.
- **Familia de código:** Geist Mono. Solo para código, logs y valores que se alinean por carácter.
- **Carga:** cargá Geist 400, 500 y 600 y Geist Mono 400 desde `assets/fonts/`. En web, usá `font-display: block`, para que el texto no cambie de métrica después de la carga.
- **Pesos:** 400 para datos, texto corrido y numerales. 500 para rótulos, botones, títulos de panel y acento como texto. 600 solo para el título hero, uno por pantalla.
- **Caja:** títulos, rótulos, botones, chips, pestañas, tags y textura en mayúsculas. Texto corrido, rutas, código y datos ingresados por el usuario en su caja original.
- **Cifras:** `font-variant-numeric: tabular-nums` en todo número vivo o alineado en columna.
- **Línea de texto corrido:** 65–72 caracteres como máximo. Tablas y logs pueden ser más anchos.
- **Corte de línea:** `text-wrap: balance` en títulos, `text-wrap: pretty` en texto corrido.
- **Itálica:** la familia se usa siempre recta.

| Nivel         | Token       | Tracking          | Peso | Color                   | Uso                                                |
| ------------- | ----------- | ----------------- | ---- | ----------------------- | -------------------------------------------------- |
| Hero          | `--t-hero`  | `--track-hero`    | 600  | `ink-100` + `ink-500`   | Título principal de la pantalla. Uno por pantalla. |
| Título        | `--t-title` | `--track-title`   | 500  | `ink-100` + `ink-500`   | Título de panel o de diálogo.                      |
| Lectura       | `--t-body`  | 0                 | 400  | `ink-100` / `ink-300`   | Datos, texto corrido, valores de campo.            |
| Rótulo        | `--t-label` | `--track-label`   | 500  | `ink-300`               | Etiquetas, botones, pestañas, encabezados de tabla.|
| Código        | `--t-code`  | 0                 | 400  | `ink-300`               | Código y logs.                                     |
| Textura       | `--t-micro` | `--track-micro`   | 400  | `ink-500`               | `SELECT`, IPs, marcas. Nunca una lectura.          |

**Composición del título.** `[badge] PRIMARIO / SUFIJO` en una línea:

- La parte primaria nombra el contenido. Va en `--ink-100`.
- El separador es ` / ` o `-`.
- El sufijo es opcional. Va en `--ink-500` si es un código o un calificador (`VIEW-F11.31`, `SETTINGS / ACCOUNT`), y en `--accent` peso 500 si es un estado de proceso (`TERMINAL 1 / SCANNING`).
- La categoría del panel va en el sufijo, en la misma línea. Sobre el título no va ningún rótulo.
- En densidad operativa, debajo del título puede ir una línea de textura.

### 3.5 Línea, forma e iconos

- Todo trazo mide `--stroke` (1 px). Las barras de progreso, las marcas de selección y los arcos principales miden `--stroke-strong` (2 px).
- `border-radius: 0` en todo elemento. Los círculos se usan solo en radios, iconos de disco, botones de reproducción, diales y marcadores de posición en gráficos.
- **Escuadra en L:** dos segmentos de `--corner-arm` × 1 px en `--ink-300`, en las cuatro esquinas de cada panel y de cada diálogo.
- **Cruz `+`:** 1 px en `--ink-100`, brazos de 4–10 px. Marca intersecciones de grilla y puntos de interés.
- **Rayado:** líneas a 45°, para barras de progreso, pistas, regiones seleccionadas y esqueletos de carga.
- **Iconos:** 12×12 px en operativa y estándar, 16×16 px en compacta. Trazo de 1 px en `--ink-300` o `--ink-700`. El icono de un estado activo va en `--accent`.
- La profundidad se marca solo con `--panel-2` y con bordes: sin sombras, glow, gradientes decorativos ni `backdrop-filter`.

### 3.6 Movimiento

- **Estado:** hover, foco, presionado y selección cambian `color`, `background-color`, `border-color`, `opacity` y `transform` en `--dur-state` con `--ease-state`.
- **Tacto:** un control presionado baja `--press-shift` en Y (`translateY(1px)`).
- **Contenido y layout:** apertura y cierre, cambio de pestaña, cambio de contenido y cambio de layout son cortes de 0 ms. El panel queda con su cromo y el contenido nuevo aparece entero.
- **Datos vivos:** solo se animan cuando el dato es realmente vivo. La animación es lineal o por pasos (`steps()`).
- **Carga:** una barra rayada que avanza, o un rayado que se desplaza por pasos.
- **`prefers-reduced-motion: reduce`:** los tokens de §3.1 llevan el estado a 0 ms y el tacto a 0 px. Los datos vivos se actualizan a 1 Hz y los rayados de carga quedan fijos.
- Máximo 3 destellos por segundo en toda la pantalla (WCAG 2.3.1).

### 3.7 Rechazos

Cada fila es un patrón que delata una interfaz genérica, y la forma que lo reemplaza. Si estás por escribir la columna izquierda, escribí la derecha.

| Patrón genérico                                                     | Forma del sistema                                                                 |
| ------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| Borde lateral de color de más de 1 px en fila, alerta o tarjeta     | Contorno completo de 1 px, fondo `--panel-2`, o un tag o marcador delante del texto. |
| Negro puro `#000`                                                   | `--void`.                                                                         |
| Sombra, glow, blur, vidrio, texto con gradiente                     | Color sólido. Jerarquía por tamaño, peso o inversión.                             |
| Sombra dura desplazada ("neo-brutalismo")                           | Borde de 1 px. El brutalismo está en la estructura expuesta, no en la sombra.     |
| Rótulo chico en mayúsculas sobre cada sección                       | La categoría va en el sufijo del título (§3.4).                                   |
| Numeración `01 / 02 / 03` como decoración                           | El badge numera solo cuando el número es el atajo del panel (§5.2).               |
| Fila de paneles iguales con icono, título y texto                   | Anchos según prioridad: el bloque principal ocupa más columnas (§4.3).            |
| Métrica héroe aislada: número grande, rótulo y estadísticas         | El KPI va junto a la serie que lo explica (§5.16).                                |
| Diálogo como primera opción                                         | Edición en línea o en un panel. Diálogo solo para confirmar algo destructivo (§5.13). |
| Spinner circular en medio del contenido                             | Esqueleto rayado con la forma del contenido (§5.20).                              |
| Emojis                                                              | Iconos de trazo de 1 px (§3.5).                                                   |
| Datos redondos o genéricos (`99,99 %`, `John Doe`, `Acme`)          | Datos con forma real e irregular (`47,2 %`, `00:14:37`, `run-0412`).              |
| Segunda familia display                                             | Geist en tres pesos (§3.4).                                                       |

---

## 4. Capa 2 — Densidad

### 4.1 Elegir la densidad

Elegí una densidad por pantalla. Una misma app puede mezclarlas: un login compacto y un tablero operativo.

| Densidad    | Condición                                                                                    | Ejemplos                                         |
| ----------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `operativa` | Viewport ≥ 1366 px **y** ≥ 4 bloques de datos visibles a la vez **y** el usuario monitorea más de lo que edita. | Tablero de monitoreo, sala de control, muro de video. |
| `compacta`  | Viewport < 768 px, **o** una sola tarea con ≤ 2 bloques de contenido.                        | Login, confirmación, formulario corto, pantalla de celular. |
| `estandar`  | Todo lo demás.                                                                               | Configuración, gestión de registros, vista de detalle, formulario largo, documento. |

### 4.2 Qué cambia con la densidad

| Elemento                     | `operativa`                    | `estandar`                         | `compacta`                    |
| ---------------------------- | ------------------------------ | ---------------------------------- | ----------------------------- |
| Borde + escuadras en L       | Todo panel                     | Todo panel                         | Todo panel                    |
| Título                       | Todo panel                     | Todo panel                         | Todo panel                    |
| Badge numerado               | Todo panel                     | Paneles principales                | Sin badge                     |
| Línea de textura bajo título | Todo panel                     | Sin textura                        | Sin textura                   |
| Controles de ventana         | Todo panel                     | Solo si el panel se expande o cierra | Sin controles               |
| Textura en el contenido      | Sí                             | Sin textura                        | Sin textura                   |
| Datos vivos                  | Al menos un panel              | Solo datos realmente vivos         | Solo datos realmente vivos    |
| Scroll de página             | Ninguno                        | Vertical, con barra superior fija  | Vertical                      |
| Títulos con código           | Primario o sufijo con código   | Sufijo opcional                    | Sin código                    |
| Catálogo de la película      | Punto de partida               | Componentes sueltos                | Componentes sueltos           |

Los tamaños de texto, control, fila y separación de cada densidad están en los tokens de §3.1.

### 4.3 Grilla y breakpoints

| Viewport       | Columnas | Separación | Margen |
| -------------- | -------- | ---------- | ------ |
| ≥ 1366 px      | 12       | `--gap`    | 5 px (operativa), 24 px (estándar) |
| 768–1365 px    | 8        | `--gap`    | 16 px  |
| < 768 px       | 4        | `--gap`    | 16 px  |

- **Composición libre:** asigná a cada bloque una región rectangular de columnas completas. El ancho sigue la prioridad del bloque: el principal ocupa más columnas que sus vecinos (por ejemplo 7 + 5, u 8 + 4). Un panel que pide más columnas que las disponibles ocupa todas.
- **Subdivisión:** un panel divide su cuerpo en celdas iguales para lecturas chicas.
- **Marco:** un elemento grande (video, gráfico, dial, formulario principal) ocupa varias celdas, y las celdas vecinas lo rodean con lecturas que lo describen.
- Los bordes de todos los paneles se alinean a las líneas de la grilla. La pantalla lee como una sola grilla.
- En densidad compacta, los paneles se apilan en una columna a ancho completo.

### 4.4 Shell por densidad

**Operativa.** Barra de menú de 36 px, contenido, fila inferior de terminales o tarjetas y barra de funciones de 36 px. Ocupa exactamente el viewport. Detalle en DESIGN-CATALOG.md §2.

**Estándar.** Barra superior fija de 40 px (§5.17). Navegación lateral opcional de 2 columnas (§5.17). El contenido va sobre la grilla y hace scroll vertical.

**Compacta.** Barra superior de 48 px (§5.17). Contenido en una columna, con scroll vertical. Barra de acción inferior opcional de 64 px con la acción primaria a ancho completo.

---

## 5. Componentes universales

Cada componente indica si es **observado** (medido en los videos) o **derivado** (construido con los invariantes). Los tamaños usan los tokens de la densidad activa. Los colores salen siempre de §3.2.

### 5.1 Panel — observado

- Fondo `--panel`, borde de 1 px `--line`, escuadras en L en las cuatro esquinas.
- Cabecera: badge (si la densidad lo pide) + título + línea de textura (si la densidad lo pide). Controles de ventana a la derecha: lista `≡`, expandir `⤢`, cerrar y refrescar `↻`, en `--ink-700`. El control activo va en `--accent`.
- Cuerpo con padding `--pad-y` `--pad-x`.
- Un panel grande lleva además un tick `├` de 8 px en el punto medio de sus bordes largos.

### 5.2 Badge — observado

- Cuadrado de `--badge`, contorno de 1 px `--ink-500`, numeral de dos dígitos en `--t-badge` `--ink-100` `tabular-nums`.
- El numeral es el atajo de teclado que enfoca el panel (`Alt+1`…`Alt+9`). Si el panel no tiene atajo, no lleva badge.
- Variante emblema: el mismo cuadrado con el emblema de la app. Se usa en el panel principal y en logs.
- Variante progreso: relleno `--amber-500`, numeral `--on-accent`, junto al rótulo `IN PROGRESS`.
- Variante contador: un badge de `--t-label` de alto que muestra una cantidad junto a un ítem de navegación.

### 5.3 Botón — derivado del chip observado

- Alto `--control-h`, padding horizontal `--pad-x`, texto en `--t-label` mayúsculas, peso 500.
- **Primario:** inversión: relleno `--accent`, texto `--on-accent`.
- **Secundario:** contorno de 1 px `--ink-700`, texto `--ink-300`.
- **Destructivo:** relleno `--red-600`, texto `--on-accent`.
- **De icono:** icono solo, en un área de `--control-h` × `--control-h`.
- El texto del botón es un verbo en mayúsculas: `SAVE`, `SIGN IN`, `EXPORT`.
- Estados en §6.

### 5.4 Chip y tag — observado

- Chip: alto 11 px en operativa y `--control-h` en las otras densidades, contorno de 1 px `--ink-700`, texto en `--t-micro` (operativa) o `--t-label` `--ink-300`.
- Chip activo: relleno `--accent`, texto `--on-accent`.
- Tag de estado: rectángulo sin interacción, texto en mayúsculas: `ERROR` en relleno `--red-600` y texto `--on-accent`; `IN PROGRESS` en relleno `--amber-500` y texto `--on-accent`; `ACTIVE` en relleno `--accent` y texto `--on-accent`; `DONE` e `IDLE` en contorno `--ink-700` y texto `--ink-300`.
- Los chips van en filas con separación de 4 px.

### 5.5 Campo de texto — derivado

- Etiqueta arriba, en `--t-label` mayúsculas `--ink-300`, separada 4 px de la caja.
- Caja de alto `--control-h`, fondo `--panel-2`, borde de 1 px `--ink-700`.
- Valor en `--t-body` `--ink-100`. Placeholder en `--t-label` mayúsculas `--ink-500`: es una pista, y la etiqueta de arriba lleva la lectura.
- Texto de ayuda debajo en `--t-label` `--ink-300`.
- Inválido: borde `--red-600` y, debajo, tag `ERROR` + mensaje en `--ink-100`.
- Área de texto: mismo estilo, alto en múltiplos de `--row`.
- Campo de búsqueda: mismo estilo, con un `+` o un icono de lupa a la derecha. Observado como `Filter ADV +`.

### 5.6 Checkbox y radio — derivado

- **Checkbox:** cuadrado de 12 px (16 px en compacta), contorno de 1 px `--ink-300`. Marcado: relleno `--accent` con un tilde de 1,5 px en `--on-accent`. Indeterminado: relleno `--accent` con una barra horizontal de 6×2 px en `--on-accent`.
- **Radio:** círculo de 12 px (16 px en compacta), contorno de 1 px `--ink-300`. Marcado: un punto interno de 6 px (8 px en compacta) en `--accent`.
- Etiqueta a la derecha en `--t-body` `--ink-300`, separada 8 px. El área clickeable incluye la etiqueta y mide al menos `--control-h` de alto.

### 5.7 Selector segmentado y toggle — observado (`CAM 1 ON/OFF`)

- **Selector segmentado:** una fila de celdas contiguas de alto `--control-h`, cada una con contorno de 1 px `--ink-700`. La celda elegida es una inversión: relleno `--accent`, texto `--on-accent`.
- **Toggle:** un selector segmentado de dos celdas `ON` / `OFF`.
- **Toggle en línea** (operativa): el texto `ON/OFF`, con la opción activa en `--accent` peso 500 y la inactiva en `--ink-700`.

### 5.8 Select y menú desplegable — derivado

- Disparador: igual que el campo de texto, con un caret `▼` de 8 px en `--ink-300` a la derecha.
- Menú: panel flotante sin badge, fondo `--panel`, borde de 1 px `--line`, escuadras en L, en la capa `--z-dropdown`.
- Ítem: alto `--row`, texto en `--t-body` `--ink-300`. Hover: fondo `--panel-2` y texto `--ink-100`. Seleccionado: cuadrado de 4 px `--accent` delante del texto y texto `--accent` peso 500.
- Separador entre grupos: línea de 1 px `--grid`. Rótulo de grupo en `--t-label` `--ink-300`.
- El menú aparece y desaparece por corte, pegado al disparador.

### 5.9 Slider — derivado

- Pista de 1 px `--ink-700` con ticks de 4 px cada 10 %.
- Tramo recorrido: 2 px en `--accent`.
- Control: rectángulo de 8×14 px (12×24 px en compacta) en `--accent`.
- Valor a la derecha en `--t-body` `tabular-nums` `--ink-100`.

### 5.10 Pestañas — observado (fila de chips)

- Una fila de chips de alto `--control-h`, texto en `--t-label` mayúsculas.
- La pestaña actual es el chip activo: relleno `--accent`, texto `--on-accent`.
- En navegación de secciones grandes (estándar), la pestaña actual puede usar una barra inferior de 2 px `--accent` con texto `--accent` peso 500, y las demás texto `--ink-300`.

### 5.11 Tabla y lista — observado (tablas y árbol de la película)

- Encabezado: `--t-label` mayúsculas `--ink-300`, sobre una franja `--panel-2`.
- Fila: alto `--row`, separador de 1 px `--grid`. Texto en `--t-body` `--ink-300`; la columna principal en `--ink-100`.
- Números alineados a la derecha, con `tabular-nums`.
- Hover: fondo `--panel-2`. Seleccionada: fondo `--panel-2` y contorno interior de 1 px `--accent` en los cuatro lados.
- Fila inactiva o archivada: texto `--ink-700`.
- Lista: la misma fila sin columnas, con un icono de 12 px a la izquierda.
- Árbol: caret `▼` / `▶` en `--ink-300` y sangría de 16 px por nivel.
- Paginación: chips numerados `01 02 03`, con la página actual como chip activo, más glifos `◀` `▶`.

### 5.12 Barra rayada — observado

Barra de progreso y barra de valor.

- Pista: rayado a 45° en `--ink-900`, alto 6 px (8 px en compacta).
- Relleno: rayado a 45° en `--ink-300`, franjas de 2 px cada 4 px, que crece de izquierda a derecha.
- Tramo actual opcional: segmento sólido `--accent` al final del relleno.
- Valor a la derecha en `--t-body` `tabular-nums`.
- Progreso indeterminado: el rayado se desplaza 4 px por paso, con `steps()`.

```css
.hatch-fill {
  background: repeating-linear-gradient(135deg, var(--ink-300) 0 2px, transparent 2px 4px);
}
.hatch-track {
  background: repeating-linear-gradient(135deg, var(--ink-900) 0 2px, transparent 2px 4px);
}
```

### 5.13 Diálogo — derivado de la tarjeta flotante observada

- Usalo solo para confirmar una acción destructiva o irreversible. Toda otra edición va en línea o en un panel.
- Panel flotante centrado, con escuadras en L, en la capa `--z-dialog`, sobre un fondo `--scrim` en `--z-scrim`.
- Título en `--t-title`. Badge solo en densidad operativa.
- Cuerpo en `--t-body` `--ink-300`, con la consecuencia de la acción en una oración.
- Acciones abajo a la derecha: secundaria y después destructiva. En compacta, apiladas a ancho completo con la destructiva arriba.

### 5.14 Notificación — derivada de la línea de log observada

- Franja `--panel-2` con borde de 1 px `--line`.
- Contenido en una línea: tag del rol (§5.4) + hora `HH:MM:SS` en `--t-code` `tabular-nums` `--ink-300` + origen `[MÓDULO]` en `--ink-300` + mensaje en `--t-body` `--ink-100`.
- Las notificaciones se apilan abajo a la derecha (arriba en compacta), en la capa `--z-toast`. Entran y salen por corte.

### 5.15 Tooltip — derivado

- Caja `--panel-2` con borde de 1 px `--line`, sin flecha, en la capa `--z-tooltip`.
- Texto en `--t-label` `--ink-100`, en una o dos líneas.
- Aparece a los 400 ms de hover o de foco, por corte, y desaparece al salir.

### 5.16 Gráficos y KPI — observado (gráfico de pistas, barras) y derivado (líneas)

- Grilla del gráfico en `--grid`. Ejes y marcas en `--t-label` `--ink-300`.
- **Serie temporal:** línea de 1 px. Serie principal en `--accent`, segunda en `--ink-300`, tercera en `--ink-500` punteada. Sin relleno bajo la línea.
- **Barras:** barras rayadas (§5.12). La barra destacada lleva un segmento `--accent`.
- **Eventos en el tiempo:** gráfico de pistas (DESIGN-CATALOG.md §3.8).
- **Proporción:** barra apilada rayada. Para un solo valor circular, un dial (DESIGN-CATALOG.md §3.7).
- **KPI:** valor en `--t-hero` peso 400 `tabular-nums` `--ink-100` + rótulo en `--t-label` `--ink-300` + variación en un tag. El KPI va en la cabecera o al costado de la serie que lo explica, dentro del mismo panel.
- Un punto de interés se marca con una cruz `+` o un cuadrado de 6 px `--accent`.

### 5.17 Navegación — derivada de la barra de menú observada

- **Barra superior:** alto 36 px (operativa), 40 px (estándar) o 48 px (compacta), en la capa `--z-sticky`. Fondo `--panel`, borde inferior de 1 px `--line`. Izquierda: emblema + nombre del producto en `--t-label` `--ink-300` + versión en `--ink-500`. Centro o izquierda: ítems de navegación en `--t-label` mayúsculas `--ink-300`, separados por líneas verticales de 1 px `--line`; el ítem actual en `--accent` peso 500 con una barra inferior de 2 px `--accent`. Derecha: iconos de 12–16 px.
- **Navegación lateral:** columna `--panel` de 2 columnas de grilla. Ítems de alto `--row` con icono + texto en `--t-label` mayúsculas `--ink-300`. El ítem actual es una inversión a lo ancho de la columna: relleno `--accent`, texto e icono `--on-accent`.
- **Compacta:** la navegación principal pasa a un menú desplegable abierto desde un icono `≡` de la barra superior.

### 5.18 Imagen y video — observado

- Imagen y video a color natural, sin tinte ni filtro.
- El cromo se dibuja encima, sin caja de fondo: título en `--ink-100`, lecturas en `--t-micro` o `--t-label`.
- Avatar: cuadrado de 32 px (40 px en compacta), borde de 1 px `--ink-700`.
- Selección sobre una imagen: recuadro de 1 px `--ink-100` con barra superior `--amber-500` mientras se procesa (DESIGN-CATALOG.md §3.11), o región rayada (DESIGN-CATALOG.md §3.12).

### 5.19 Barra de scroll — derivada

- La barra de scroll es la nativa del sistema, con colores del sistema de tokens.
- Ancho fino, barra en `--ink-700`, pista transparente.
- En paneles con texto: `scrollbar-gutter: stable`.

```css
* { scrollbar-width: thin; scrollbar-color: var(--ink-700) transparent; }
```

### 5.20 Estados de contenido — observado y derivado

| Estado  | Forma                                                                                             |
| ------- | ------------------------------------------------------------------------------------------------- |
| Vacío   | Panel con su cromo. Cuerpo con un rótulo (`NO RUNS`, `OFFLINE`) en `--t-label` `--ink-300`, una oración en `--ink-300` que dice qué llena el panel, y la acción secundaria que lo llena. Una celda vacía de una grilla lleva un `+` centrado. |
| Carga   | Esqueleto: bloques rayados `--ink-900` con la forma y el tamaño del contenido final, o barra rayada indeterminada. |
| Espera  | Título `STANDBY` en `--ink-300`.                                                                  |
| Proceso | Badge ámbar y título `IN PROGRESS`.                                                               |
| Error   | Tag `ERROR` + mensaje en `--ink-100` que dice qué falló y qué hacer, y una acción secundaria para reintentar. |

---

## 6. Estados de interacción — derivados

La película no muestra interacción, salvo chips activos, celdas seleccionadas y el cursor. Estos estados se construyen con los invariantes y cambian con el movimiento de estado de §3.6.

| Estado        | Botón primario                  | Botón secundario, chip, campo            | Fila, ítem de menú                     |
| ------------- | ------------------------------- | ---------------------------------------- | -------------------------------------- |
| Reposo        | Relleno `--accent`, texto `--on-accent` | Contorno `--ink-700`, texto `--ink-300` | Texto `--ink-300`                |
| Hover         | Relleno `--ink-100`             | Contorno `--ink-300`, texto `--ink-100`  | Fondo `--panel-2`, texto `--ink-100`   |
| Foco (teclado)| Contorno de 1 px `--accent` a 2 px de distancia (`outline-offset: 2px`) | Igual                 | Contorno interior de 1 px `--accent`   |
| Presionado    | Relleno `--accent-press` + `translateY(var(--press-shift))` | Relleno `--panel-2` + `translateY(var(--press-shift))` | Fondo `--panel-2` |
| Seleccionado  | —                               | Relleno `--accent`, texto `--on-accent`  | Fondo `--panel-2` + contorno interior de 1 px `--accent` |
| Deshabilitado | Relleno `--ink-900`, texto `--ink-700` | Contorno `--ink-900`, texto `--ink-700` | Texto `--ink-700`                  |
| Inválido      | —                               | Contorno `--red-600` + tag `ERROR`       | —                                      |

- El foco de teclado usa `:focus-visible`, para que no aparezca con el mouse.
- El cursor es el puntero estándar del sistema. Los elementos deshabilitados usan `cursor: not-allowed`.
- Todo elemento interactivo se opera con teclado: `Tab` para moverse, `Enter` o `Space` para activar, `Esc` para cerrar.

---

## 7. Mapeo y microcopy

### 7.1 Elemento genérico → componente

| Elemento genérico            | Componente                                                   |
| ---------------------------- | ------------------------------------------------------------ |
| Navegación principal         | Barra superior o navegación lateral (§5.17)                  |
| Acciones globales (operativa)| Barra de funciones con teclas F (catálogo §2.2)              |
| Tarjeta, widget, sección     | Panel (§5.1)                                                 |
| Botón                        | Botón (§5.3)                                                 |
| Filtro, etiqueta             | Chip (§5.4)                                                  |
| Estado de un ítem            | Tag (§5.4)                                                   |
| Campo, búsqueda, área de texto | Campo de texto (§5.5)                                      |
| Checkbox, radio              | §5.6                                                         |
| Switch, opción binaria       | Toggle (§5.7)                                                |
| Opciones excluyentes visibles| Selector segmentado (§5.7)                                   |
| Dropdown, menú contextual    | Select y menú (§5.8)                                         |
| Rango numérico               | Slider (§5.9)                                                |
| Pestañas                     | §5.10                                                        |
| Tabla, lista, árbol, paginación | §5.11                                                     |
| Progreso, cuota, nivel       | Barra rayada (§5.12)                                         |
| Confirmación destructiva     | Diálogo (§5.13)                                              |
| Toast, alerta, log           | Notificación (§5.14); log largo: terminal (catálogo §3.9)    |
| Ayuda contextual             | Tooltip (§5.15)                                              |
| Gráfico, KPI                 | §5.16                                                        |
| Imagen, video, avatar        | §5.18                                                        |
| Vacío, carga, error          | §5.20                                                        |
| Vigilancia, rastreo, análisis de medios | Catálogo §3.7–§3.16                               |

### 7.2 Microcopy

- **Títulos:** la parte primaria dice qué es el contenido (`ACCOUNT`, `RUNS`, `NETWORK`). El sufijo agrega un código, un calificador o un estado (`RUNS / 2026-Q3`, `NETWORK-F12`, `SYNC / RUNNING`).
- **Densidad operativa:** los títulos llevan código, como en la película: `SUSTANTIVO-F<nn>.<nn>` (`VIEW-F11.31`), `SUSTANTIVO - MM/DD-DD/MM` (`ACTIVITY - 12/24-31/12`), `SUSTANTIVO <n>/<n>/<n>` (`FILES 49/19/68`).
- **Rótulos de estado:** una o dos palabras en mayúsculas: `ACTIVE`, `SCANNING`, `LIVE`, `STANDBY`, `IN PROGRESS`, `DONE`, `OFFLINE`, `ERROR`.
- **Botones:** un verbo concreto en mayúsculas, opcionalmente con objeto: `SAVE`, `EXPORT LOG`, `START RUN`.
- **Idioma:** en un producto en otro idioma, usá ese idioma con el mismo tono: términos técnicos cortos, verbos concretos, sin adjetivos.
- **Datos de ejemplo:** valores con forma real e irregular: `47,2 %`, `00:14:37`, `run-0412`, rutas y códigos plausibles. IPs de los rangos de documentación RFC 5737.
- **Tono:** vocabulario de sistemas. La interfaz habla como software de hoy, no como ciencia ficción ni como marketing.

---

## 8. Verificación

### 8.1 Universal — toda pantalla

1. **Tokens:** una búsqueda de `#[0-9a-fA-F]{3,8}` y `rgb(` fuera del archivo de tokens da 0 resultados.
2. **Forma:** todo `border-radius` es 0, salvo los círculos permitidos en §3.5.
3. **Tipografía:** Geist y Geist Mono, sin otra familia; el peso 600 aparece como máximo una vez; los números vivos o en columna usan `tabular-nums`.
4. **Contraste:** toda lectura, incluido el placeholder, cumple ≥ 4,5:1 sobre su fondo; todo límite de control cumple ≥ 3:1 (§3.3).
5. **Color:** cada uso de acento, rojo o ámbar corresponde a una fila de §3.2; cada panel tiene como máximo una acción primaria; en una captura, el acento ocupa ≤ 10 % de los píxeles.
6. **Cromo mínimo:** cada panel tiene borde, escuadras en L y título.
7. **Movimiento:** toda `transition` de estado usa `--dur-state` y `--ease-state` sobre `color`, `background-color`, `border-color`, `opacity` o `transform`; los cambios de contenido y de layout duran 0 ms; las animaciones de datos usan `linear` o `steps()`.
8. **Estados:** cada elemento interactivo tiene reposo, hover, foco visible, presionado y deshabilitado (§6); cada bloque de datos tiene vacío, carga y error (§5.20).
9. **Teclado:** todo elemento interactivo se alcanza con `Tab` y muestra el foco.
10. **Sin desplazamiento:** una actualización de datos no mueve el layout.
11. **Rechazos:** ningún patrón de la columna izquierda de §3.7 aparece en la pantalla.

### 8.2 Por densidad

**Operativa:**

1. Sin scroll de página a 1366×768 ni a 1920×1080.
2. Cada panel tiene badge, línea de textura y controles de ventana.
3. Al menos un panel muestra datos vivos a 12–24 Hz (1 Hz con `prefers-reduced-motion`).
4. En una captura a 1920×1080, el acento ocupa ≤ 5 % de los píxeles y el rojo < 0,5 %.

**Estándar:**

1. Sin scroll horizontal entre 768 y 1920 px de ancho; la barra superior queda fija durante el scroll vertical.
2. Ningún texto mide menos de 10 px.
3. Los paneles con atajo de teclado tienen badge.

**Compacta:**

1. Sin scroll horizontal a 360 px de ancho.
2. Todo elemento interactivo mide al menos 44 × 44 px.
3. Ningún texto mide menos de 11 px.
4. La pantalla tiene una sola acción primaria.
