# DESIGN.md — Lenguaje visual de la CIA · The Amateur (2025)

Sistema de estilo para generar cualquier interfaz con el aspecto de las pantallas de la CIA de _The Amateur_ (2025): un tablero de monitoreo, una app de gestión, un formulario, un login, una pantalla de celular.

El sistema tiene tres capas:

1. **Invariantes** (§3): color, tipografía, línea, esquinas y movimiento. Valen en toda pantalla.
2. **Densidad** (§4): cuánto cromo, cuánta textura y qué tamaños lleva la pantalla. Se elige una densidad por pantalla.
3. **Catálogo de la película**: composiciones y componentes observados en los videos. Está en [`DESIGN-CATALOG.md`](DESIGN-CATALOG.md). Leelo cuando la pantalla tenga densidad operativa, o cuando necesites un componente de la película: dial, gráfico de pistas, terminal, tile de video, detección facial, región de escaneo.

Los valores salen de la medición cuadro a cuadro de los videos originales. Leé [`DESIGN-EVIDENCE.md`](DESIGN-EVIDENCE.md) cuando necesites verificar un valor contra el cuadro original, o cuando un valor contradiga una captura.

## Vocabulario

Estas palabras tienen un significado fijo en los tres archivos:

- **Lienzo**: el fondo casi negro de la pantalla.
- **Panel**: un rectángulo con cromo que agrupa un solo tema de datos o de acciones.
- **Cromo**: todo lo que rodea al contenido de un panel: borde, esquinas en L, badge, título, controles de ventana.
- **Lectura**: un valor que el usuario lee para decidir o actuar: un dato, una etiqueta de campo, un mensaje.
- **Textura**: microtexto que da densidad y no se lee (IPs, `SELECT`, `04.02`). Solo existe en densidad operativa y estándar.
- **Vivo**: un dato que cambia en el tiempo mientras está visible.
- **Densidad**: el nivel de §4 que fija el cromo y los tamaños de una pantalla: `operativa`, `estandar` o `compacta`.
- **Observado**: un valor o componente medido en los videos.
- **Derivado**: un valor o componente que la película no muestra, construido con los invariantes. Los componentes derivados siguen las mismas reglas que los observados.

---

## 1. Procedimiento

Seguí los pasos en orden para cada pantalla. Cada paso termina en su criterio de completitud.

1. **Nombrá la tarea y el contenido.** Escribí en una oración qué hace el usuario en esta pantalla. Listá cada bloque de contenido con su tipo: formulario, acción, texto, navegación, lista, tabla, serie temporal, log, estado, imagen o video, objeto único. Listo cuando cada bloque tiene un tipo.
2. **Elegí la densidad** con la regla de §4.1. Listo cuando la pantalla tiene una densidad y la regla la justifica.
3. **Componé la grilla** (§4.3). En densidad operativa, partí de una composición del catálogo o armá una libre. En las otras, armá una composición libre. Listo cuando cada bloque del paso 1 tiene una región y un ancho en columnas para cada breakpoint.
4. **Armá el shell** de la densidad elegida (§4.4). Listo cuando el shell cumple la regla de scroll de su densidad.
5. **Convertí cada bloque en paneles y componentes.** Usá la tabla de §7 para encontrar el componente de cada elemento. Listo cuando cada elemento tiene un componente de §5 o del catálogo, y cada panel tiene el cromo que exige su densidad (§4.2).
6. **Asigná color por rol** (§3.2). Listo cuando cada uso de lima, rojo, ámbar, naranja o teal corresponde a una fila de la tabla de roles.
7. **Definí los estados** de cada elemento interactivo (§6). Listo cuando cada elemento interactivo tiene reposo, hover, foco, presionado y deshabilitado.
8. **Verificá con §8.** Listo cuando pasan todos los puntos universales y los puntos de la densidad elegida.

---

## 2. ADN del estilo

Una pantalla que cumple estas seis propiedades se reconoce como parte de la familia, en cualquier densidad.

1. **Lienzo negro, dibujo de línea.** El fondo es casi negro neutro, con un leve tinte verde. El contenido se dibuja con líneas de 1 px, texto chico y rellenos pequeños. La pantalla se lee como un instrumento.
2. **Grises neutros y un solo acento lima.** El texto va en blanco y grises. El lima marca identidad, selección y avance; sus rellenos llevan texto oscuro. El rojo, el ámbar, el naranja y el teal son señales puntuales.
3. **Esquinas rectas con escuadras en L.** Todo es rectangular. Las escuadras en L de las esquinas son la firma visual del panel.
4. **Una sola familia sans cuadrada, liviana, en mayúsculas.** Títulos, rótulos y botones en mayúsculas, con peso 400–500.
5. **Software plausible de hoy.** La interfaz se comporta como un sistema real: menús, ventanas, atajos de teclado, rutas, códigos.
6. **Cambios secos.** La interfaz cambia de estado sin transición. Solo los datos vivos se mueven.

Contexto de diseño, sin métricas:

- [F1] Paul Roberts, "The Amateur (2025)", cliente VineFX — <https://paulroberts.tv/projects/the-amateur-2025>. Pantallas actuales, de alta tecnología y modulares, sobre una grilla que se subdivide o enmarca elementos grandes.
- [F2] British Cinematographer, "Vine FX exhibits original screen graphics for The Amateur" (20/06/2025) — <https://britishcinematographer.co.uk/vine-fx-exhibits-original-screen-graphics-for-the-amateur/>. Avanzado pero creíble. La IA muestra resultados, no procesos. Interfaz viva que guía con movimiento, color y ritmo.

---

## 3. Capa 1 — Invariantes

### 3.1 Tokens

Copiá este bloque como archivo de tokens. Ningún componente declara un color, tamaño o duración literal fuera de él. Poné `data-density` en el elemento raíz de cada pantalla.

```css
:root {
  /* Color — observado en las imágenes de referencia 6–9. Los tokens --blue-* contienen el acento lima. */
  --void: #080C0D;        /* lienzo; texto sobre rellenos de acento */
  --panel: #0D1112;       /* fondo de panel */
  --panel-2: #161F1E;     /* cajas internas, campos, filas en hover */
  --line: #676B6C;        /* borde de panel y de campo, gris neutro */
  --grid: #383E3E;        /* grilla de gráficos, separador de filas */
  --ink-100: #F4F8F8;     /* lecturas, títulos, esquinas en L */
  --ink-300: #D9DDDD;     /* datos, etiquetas, contornos en hover */
  --ink-500: #7B8784;     /* sufijos, textura, placeholder */
  --ink-700: #626D69;     /* contornos, controles de ventana, texto deshabilitado */
  --ink-900: #25292A;     /* texto fantasma, pista de barras, borde deshabilitado */
  --blue-700: #90AF3C;    /* lima oscuro: badge, presionado */
  --blue-500: #DEF85D;    /* lima: seleccionado, acción primaria, avance */
  --blue-300: #C9F057;    /* lima claro: proceso en curso, foco, lectura destacada */
  --red-600: #EF4C42;     /* error, cifrado, alerta */
  --amber-500: #E7B954;   /* detección o tarea en progreso */
  --orange-500: #EF7B2F;  /* umbral superado, degradación */
  --teal-300: #4FDABE;    /* diagnóstico, información, segunda serie */
  --scrim: color-mix(in srgb, var(--void) 80%, transparent); /* fondo detrás de un diálogo */

  /* Tipografía */
  --font-ui: "Saira", "Eurostile", "Microgramma", sans-serif;
  --font-code: "JetBrains Mono", "IBM Plex Mono", monospace;
  --track-title: 0.04em;
  --track-label: 0.08em;
  --track-micro: 0.1em;

  /* Línea y forma */
  --stroke: 1px;
  --stroke-strong: 2px;
  --corner-arm: 10px;

  /* Movimiento */
  --dur-ui: 0ms;

  --scale: 1;
}

@media (min-width: 2560px) {
  :root { --scale: 1.25; }
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
- Todo texto o icono sobre un relleno de acento (`--blue-*`, `--red-600`, `--amber-500`, `--orange-500`, `--teal-300`) va en `--void`.
- Los fondos teñidos (bloque de log con error, fila elegida, área bajo una serie) son `color-mix()` del acento sobre `--panel`, entre 10 % y 25 %.
- El estilo es solo oscuro. No tiene tema claro.

### 3.2 Roles de color

Cada uso de un color saturado corresponde a una fila de esta tabla.

| Color         | Significado                            | Ejemplos                                                                  |
| ------------- | -------------------------------------- | ------------------------------------------------------------------------- |
| `--blue-700`  | Identidad; estado presionado           | Badge `24`, índice de fila, botón mientras se presiona.                   |
| `--blue-500`  | Seleccionado, acción primaria, avance  | Chip activo, botón primario, tag `LIVE`, casilla marcada, barra de progreso. |
| `--blue-300`  | Proceso en curso, foco, lectura destacada | `TERMINAL 1 / SCANNING`, contorno de foco, toggle `[ ON ]`, hora de un reloj. |
| `--red-600`   | Error, cifrado, acción destructiva     | Tag `ERROR`, `ENCRYPTED`, botón `DELETE`, borde de campo inválido.        |
| `--amber-500` | Detección o tarea en progreso          | Barra de recuadro facial, badge `IN PROGRESS`, `3 UNSAVED`, tarea en cola. |
| `--orange-500`| Umbral superado, degradación           | Pico sobre el límite, latencia `1.9 s` sobre p95, tasa de `5xx`.          |
| `--teal-300`  | Diagnóstico, información, referencia   | Bloque `DIAGNOSIS`, segunda serie de un gráfico, referencia a otra variable. |
| Grises `ink`  | Todo lo demás                          | Texto, trazos, rayados, iconos, contornos.                                |

- Cada panel tiene como máximo una acción primaria en `--blue-500`.
- El rojo ocupa un tag, una palabra, un borde o un botón destructivo. Nunca un área grande.
- En las imágenes de referencia, el lima ocupa 1,0–1,9 % de los píxeles y el rojo ≤ 0,41 %.

### 3.3 Contraste

Relaciones WCAG 2.x sobre `--panel` / `--panel-2`:

| Token          | Contraste     | Uso                                                          |
| -------------- | ------------- | ------------------------------------------------------------ |
| `--ink-100`    | 17,7 / 15,7:1 | Todo texto.                                                  |
| `--ink-300`    | 13,9 / 12,3:1 | Todo texto.                                                  |
| `--blue-300`   | 14,5 / 12,9:1 | Todo texto, contorno de foco.                                |
| `--teal-300`   | 10,9 / 9,7:1  | Todo texto.                                                  |
| `--amber-500`  | 10,4 / 9,2:1  | Todo texto.                                                  |
| `--orange-500` | 6,8 / 6,0:1   | Todo texto.                                                  |
| `--ink-500`    | 5,1 / 4,5:1   | Textura, sufijos de título, placeholder.                     |
| `--red-600`    | 5,2 / 4,6:1   | Rellenos, tags, bordes, palabra de estado. Texto `--void` encima: 5,4:1. |
| `--blue-500`   | 16,0 / 14,2:1 | Rellenos, barras, bordes. Texto `--void` encima: 16,6:1.     |
| `--blue-700`   | 7,6 / 6,7:1   | Rellenos. Texto `--void` encima: 7,8:1.                      |
| `--ink-700`    | 3,5 / 3,1:1   | Contornos, controles de ventana, texto deshabilitado.        |
| `--line`       | 3,5 / 3,1:1   | Borde de panel y de campo.                                   |

- Texto `--void` sobre `--amber-500`: 10,7:1; sobre `--orange-500`: 7,1:1; sobre `--teal-300`: 11,3:1.

- Toda lectura usa un token con contraste ≥ 4,5:1 sobre su fondo.
- Un mensaje de error es texto `--ink-100` precedido de un tag `--red-600`. El texto del mensaje nunca va en rojo.

### 3.4 Tipografía

- **Familia UI:** sans geométrica de contraformas cuadradas, familia Eurostile/Microgramma en ancho normal. `--font-ui` usa Saira (Google Fonts) como implementación web.
- **Carga:** cargá Saira 400 y 500 con `display=block`, para que el texto no cambie de métrica después de la carga. Sin esta línea, el navegador usa la sans del sistema y el estilo se pierde.

  ```html
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Saira:wght@400;500&family=JetBrains+Mono:wght@400&display=block">
  ```
- **Familia de código:** monoespaciada estrecha, `--font-code`. Solo para código, logs y valores que se alinean por carácter.
- **Pesos:** 400 para títulos, datos y numerales. 500 para rótulos de fila, botones y encabezados de terminal. El peso máximo es 500.
- **Caja:** títulos, rótulos, botones, chips, pestañas y textura en mayúsculas. Texto corrido, rutas, código y datos ingresados por el usuario en su caja original.
- **Cifras:** `font-variant-numeric: tabular-nums` en todo número vivo o alineado en columna.
- **Itálica:** la familia se usa siempre recta.

| Nivel         | Token       | Tracking          | Color                   | Uso                                                |
| ------------- | ----------- | ----------------- | ----------------------- | -------------------------------------------------- |
| Hero          | `--t-hero`  | `--track-title`   | `ink-100` + `ink-500`   | Título principal de la pantalla.                   |
| Título        | `--t-title` | `--track-title`   | `ink-100` + `ink-500`   | Título de panel o de diálogo.                      |
| Lectura       | `--t-body`  | 0,02 em           | `ink-100` / `ink-300`   | Datos, texto corrido, valores de campo.            |
| Rótulo        | `--t-label` | `--track-label`   | `ink-300`               | Etiquetas, botones, pestañas, encabezados de tabla.|
| Código        | `--t-code`  | 0                 | `ink-300`               | Código y logs.                                     |
| Textura       | `--t-micro` | `--track-micro`   | `ink-500`               | `SELECT`, IPs, marcas. Nunca una lectura.          |

**Composición del título.** `[badge] PRIMARIO / SUFIJO` en una línea:

- La parte primaria nombra el contenido. Va en `--ink-100`.
- El separador es ` / ` o `-`.
- El sufijo es opcional. Va en `--ink-500` si es un código o un calificador (`VIEW-F11.31`, `SETTINGS / ACCOUNT`), y en `--blue-300` si es un estado de proceso (`TERMINAL 1 / SCANNING`).
- En densidad operativa y estándar, debajo del título puede ir una línea de textura.

### 3.5 Línea, forma e iconos

- Todo trazo mide `--stroke` (1 px). Las barras de progreso, las marcas de selección y los arcos principales miden `--stroke-strong` (2 px).
- `border-radius: 0` en todo elemento. Los círculos se usan solo en iconos de disco, botones de reproducción, diales y marcadores de posición en gráficos.
- **Escuadra en L:** dos segmentos de `--corner-arm` × 1 px en `--ink-300`, en las cuatro esquinas de cada panel y de cada diálogo.
- **Cruz `+`:** 1 px en `--ink-100`, brazos de 4–10 px. Marca intersecciones de grilla y puntos de interés.
- **Rayado:** líneas a 45°, para barras de progreso, pistas y regiones seleccionadas.
- **Iconos:** 12×12 px en operativa y estándar, 16×16 px en compacta. Trazo de 1 px en `--ink-300` o `--ink-700`. El icono de un estado activo puede ir relleno en `--blue-500`.
- Sin sombras, glow, gradientes decorativos ni `backdrop-filter`. La profundidad se marca con `--panel-2` y con bordes.

### 3.6 Movimiento

- Todo cambio de interfaz dura `--dur-ui` (0 ms): hover, foco, selección, apertura y cierre, cambio de pestaña, cambio de layout.
- Un cambio de contenido es un corte: el panel queda con su cromo y el contenido nuevo aparece entero.
- Solo se animan los datos vivos, y solo cuando el dato es realmente vivo. La animación es lineal o por pasos (`steps()`).
- Indicadores de carga: una barra rayada que avanza, o un rayado que se desplaza por pasos.
- Con `prefers-reduced-motion: reduce`, los datos vivos se actualizan a 1 Hz y los rayados de carga quedan fijos.
- Máximo 3 destellos por segundo en toda la pantalla (WCAG 2.3.1).

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
| Línea de textura bajo título | Todo panel                     | Opcional                           | Sin textura                   |
| Controles de ventana         | Todo panel                     | Solo si el panel se expande o cierra | Sin controles               |
| Textura en el contenido      | Sí                             | Opcional, ≥ 10 px                  | Sin textura                   |
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

- **Composición libre:** asigná a cada bloque una región rectangular de columnas completas. Un panel que pide más columnas que las disponibles ocupa todas.
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

Cada componente indica si es **observado** (medido en los videos) o **derivado** (construido con los invariantes). Los tamaños usan los tokens de la densidad activa.

### 5.1 Panel — observado

- Fondo `--panel`, borde de 1 px `--line`, escuadras en L en las cuatro esquinas.
- Cabecera: badge (si la densidad lo pide) + título + línea de textura (si la densidad lo pide). Controles de ventana a la derecha: lista `≡`, expandir `⤢`, cerrar y refrescar `↻`, en `--ink-700`. El control activo va en `--blue-500`.
- Cuerpo con padding `--pad-y` `--pad-x`.
- Un panel grande lleva además un tick `├` de 8 px en el punto medio de sus bordes largos.

### 5.2 Badge — observado

- Cuadrado de `--badge`, relleno `--blue-700`, numeral de dos dígitos en `--t-badge` `--void`.
- Variante emblema: el mismo cuadrado con el emblema de la app. Se usa en el panel principal y en logs.
- Variante progreso: relleno `--amber-500`, junto al rótulo `IN PROGRESS`.
- Variante contador: un badge de `--t-label` de alto que muestra una cantidad junto a un ítem de navegación.

### 5.3 Botón — derivado del chip observado

- Alto `--control-h`, padding horizontal `--pad-x`, texto en `--t-label` mayúsculas, peso 500.
- **Primario:** relleno `--blue-500`, texto `--void`.
- **Secundario:** contorno de 1 px `--ink-700`, texto `--ink-300`.
- **Destructivo:** relleno `--red-600`, texto `--void`.
- **De icono:** icono solo, en un área de `--control-h` × `--control-h`.
- El texto del botón es un verbo en mayúsculas: `SAVE`, `SIGN IN`, `EXPORT`.
- Estados en §6.

### 5.4 Chip y tag — observado

- Chip: alto 11 px en operativa y `--control-h` en las otras densidades, contorno de 1 px `--ink-700`, texto en `--t-micro` (operativa) o `--t-label` `--ink-300`.
- Chip activo: relleno `--blue-500`, texto `--void`.
- Tag de estado: rectángulo sin interacción, relleno del color de su rol, texto `--void`: `ERROR` en `--red-600`, `IN PROGRESS` en `--amber-500`, `ACTIVE` en `--blue-500`.
- Los chips van en filas con separación de 4 px.

### 5.5 Campo de texto — derivado

- Etiqueta arriba, en `--t-label` mayúsculas `--ink-300`.
- Caja de alto `--control-h`, fondo `--panel-2`, borde de 1 px `--line`.
- Valor en `--t-body` `--ink-100`. Placeholder en `--t-label` mayúsculas `--ink-500`: es una pista, y la etiqueta de arriba lleva la lectura.
- Texto de ayuda debajo en `--t-label` `--ink-300`.
- Inválido: borde `--red-600` y, debajo, tag `ERROR` + mensaje en `--ink-100`.
- Área de texto: mismo estilo, alto en múltiplos de `--row`.
- Campo de búsqueda: mismo estilo, con un `+` o un icono de lupa a la derecha. Observado como `Filter ADV +`.

### 5.6 Checkbox y radio — derivado

- **Checkbox:** cuadrado de 12 px (16 px en compacta), contorno de 1 px `--ink-300`. Marcado: relleno `--blue-500` con un tilde de 1,5 px en `--void`. Indeterminado: relleno `--blue-500` con una barra horizontal de 6×2 px.
- **Radio:** el mismo cuadrado. Marcado: un cuadrado interno de 6 px (8 px en compacta) en `--blue-500`, sin relleno exterior. El tilde distingue el checkbox; el cuadrado interno distingue el radio.
- Etiqueta a la derecha en `--t-body` `--ink-300`, separada 8 px. El área clickeable incluye la etiqueta y mide al menos `--control-h` de alto.

### 5.7 Selector segmentado y toggle — observado (`CAM 1 ON/OFF`)

- **Selector segmentado:** una fila de celdas contiguas de alto `--control-h`, cada una con contorno de 1 px `--ink-700`. La celda elegida tiene relleno `--blue-500` y texto `--void`.
- **Toggle:** un selector segmentado de dos celdas `ON` / `OFF`.
- **Toggle en línea** (operativa): el texto `ON/OFF`, con la opción activa en `--ink-100` y la inactiva en `--ink-700`.

### 5.8 Select y menú desplegable — derivado

- Disparador: igual que el campo de texto, con un caret `▼` de 8 px en `--ink-300` a la derecha.
- Menú: panel flotante sin badge, fondo `--panel`, borde de 1 px `--line`, escuadras en L.
- Ítem: alto `--row`, texto en `--t-body` `--ink-300`. Hover: fondo `--panel-2` y texto `--ink-100`. Seleccionado: barra de 2 px `--blue-500` a la izquierda y texto `--ink-100`.
- Separador entre grupos: línea de 1 px `--grid`. Rótulo de grupo en `--t-label` `--ink-300`.
- El menú aparece y desaparece en 0 ms, pegado al disparador.

### 5.9 Slider — derivado

- Pista de 1 px `--ink-700` con ticks de 4 px cada 10 %.
- Tramo recorrido: 2 px en `--blue-500`.
- Control: rectángulo de 8×14 px (12×24 px en compacta) en `--ink-100`.
- Valor a la derecha en `--t-body` `tabular-nums` `--ink-100`.

### 5.10 Pestañas — observado (fila de chips)

- Una fila de chips de alto `--control-h`, texto en `--t-label` mayúsculas.
- La pestaña actual es el chip activo: relleno `--blue-500`, texto `--void`.
- En navegación de secciones grandes (estándar), la pestaña actual puede usar una barra inferior de 2 px `--blue-500` con texto `--ink-100`, y las demás texto `--ink-300`.

### 5.11 Tabla y lista — observado (tablas y árbol de la película)

- Encabezado: `--t-label` mayúsculas `--ink-300`, sobre una franja `--panel-2`.
- Fila: alto `--row`, separador de 1 px `--grid`. Texto en `--t-body` `--ink-300`; la columna principal en `--ink-100`.
- Números alineados a la derecha, con `tabular-nums`.
- Hover: fondo `--panel-2`. Seleccionada: barra de 2 px `--blue-500` a la izquierda y fondo `--panel-2`.
- Fila inactiva o archivada: texto `--ink-700`.
- Lista: la misma fila sin columnas, con un icono de 12 px a la izquierda.
- Árbol: caret `▼` / `▶` en `--ink-300` y sangría de 16 px por nivel.
- Paginación: chips numerados `01 02 03`, con la página actual como chip activo, más glifos `◀` `▶`.

### 5.12 Barra rayada — observado

Barra de progreso y barra de valor.

- Pista: rayado a 45° en `--ink-900`, alto 6 px (8 px en compacta).
- Relleno: rayado a 45° en `--ink-300`, franjas de 2 px cada 4 px, que crece de izquierda a derecha.
- Tramo actual opcional: segmento sólido `--blue-500` al final del relleno.
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

- Panel flotante centrado, con escuadras en L, sobre un fondo `--scrim`.
- Título en `--t-title`. Badge solo en densidad operativa.
- Cuerpo en `--t-body` `--ink-300`.
- Acciones abajo a la derecha: secundaria y después primaria. En compacta, apiladas a ancho completo con la primaria arriba.
- Un diálogo destructivo usa el botón destructivo como acción primaria.

### 5.14 Notificación — derivada de la línea de log observada

- Franja `--panel-2` con una barra de 2 px a la izquierda, en el color del rol (`--blue-500`, `--amber-500` o `--red-600`).
- Contenido en una línea: hora `HH:MM:SS` en `--t-code` `tabular-nums` `--ink-300` + origen `[MÓDULO]` en `--ink-300` + mensaje en `--t-body` `--ink-100`.
- Las notificaciones se apilan abajo a la derecha (arriba en compacta). Entran y salen por corte.

### 5.15 Tooltip — derivado

- Caja `--panel-2` con borde de 1 px `--line`, sin flecha.
- Texto en `--t-label` `--ink-100`, en una o dos líneas.
- Aparece a los 400 ms de hover o de foco, en 0 ms, y desaparece al salir.

### 5.16 Gráficos y KPI — observado (gráfico de pistas, barras) y derivado (líneas)

- Grilla del gráfico en `--grid`. Ejes y marcas en `--t-label` `--ink-300`.
- **Serie temporal:** línea de 1 px. Primera serie en `--ink-100`, segunda en `--teal-300`, tercera en `--ink-500` punteada. Sin relleno bajo la línea.
- **Barras:** barras rayadas (§5.12). La barra destacada lleva un segmento `--blue-500`.
- **Eventos en el tiempo:** gráfico de pistas (DESIGN-CATALOG.md §3.8).
- **Proporción:** barra apilada rayada. Para un solo valor circular, un dial (DESIGN-CATALOG.md §3.7).
- **KPI:** valor en `--t-hero` `tabular-nums` `--ink-100` + rótulo en `--t-label` `--ink-300` + variación en un tag.
- Un punto de interés se marca con una cruz `+` o un cuadrado de 6 px `--blue-500`.

### 5.17 Navegación — derivada de la barra de menú observada

- **Barra superior:** alto 36 px (operativa), 40 px (estándar) o 48 px (compacta). Fondo `--panel`, borde inferior de 1 px `--blue-500`. Izquierda: emblema + nombre del producto en `--t-label` `--ink-300` + versión en `--ink-500`. Centro o izquierda: ítems de navegación en `--t-label` mayúsculas `--ink-300`, separados por líneas verticales de 1 px `--line`; el ítem actual en `--ink-100` con una barra inferior de 2 px `--blue-500`. Derecha: iconos de 12–16 px.
- **Navegación lateral:** columna `--panel` de 2 columnas de grilla. Ítems de alto `--row` con icono + texto en `--t-label` mayúsculas. El ítem actual lleva una barra de 2 px `--blue-500` a la izquierda y texto `--ink-100`.
- **Compacta:** la navegación principal pasa a un menú desplegable abierto desde un icono `≡` de la barra superior.

### 5.18 Imagen y video — observado

- Imagen y video a color natural, sin tinte ni filtro.
- El cromo se dibuja encima, sin caja de fondo: título en `--ink-100`, lecturas en `--t-micro` o `--t-label`.
- Avatar: cuadrado de 32 px (40 px en compacta), borde de 1 px `--ink-700`.
- Selección sobre una imagen: recuadro de 1 px `--ink-100` con barra superior `--amber-500` mientras se procesa (DESIGN-CATALOG.md §3.11), o región rayada (DESIGN-CATALOG.md §3.12).

### 5.19 Barra de scroll — derivada

- Ancho 4 px (6 px en compacta), barra en `--ink-700`, pista transparente. En hover, la barra pasa a `--ink-300`.
- En paneles con texto: `scrollbar-gutter: stable`.

```css
* { scrollbar-width: thin; scrollbar-color: var(--ink-700) transparent; }
```

### 5.20 Estados de contenido — observado

| Estado  | Forma                                                                                             |
| ------- | ------------------------------------------------------------------------------------------------- |
| Vacío   | Panel con su cromo y un cuerpo con `▷ STATUS` y un rótulo (`NO DATA`, `OFFLINE`) centrados en `--t-label` `--ink-300`. Una celda vacía de una grilla lleva un `+` centrado. |
| Carga   | Barra rayada indeterminada, o bloques rayados `--ink-900` en el lugar de cada línea de texto.     |
| Espera  | Título `STANDBY` en `--ink-300`.                                                                  |
| Proceso | Badge ámbar y título `IN PROGRESS`.                                                               |
| Error   | Tag `ERROR` + mensaje en `--ink-100`, y una acción secundaria para reintentar.                    |

---

## 6. Estados de interacción — derivados

La película no muestra interacción, salvo chips activos, celdas seleccionadas y el cursor. Estos estados se construyen con los invariantes. Todos cambian en 0 ms.

| Estado        | Botón primario                  | Botón secundario, chip, campo            | Fila, ítem de menú                     |
| ------------- | ------------------------------- | ---------------------------------------- | -------------------------------------- |
| Reposo        | Relleno `--blue-500`            | Contorno `--ink-700`, texto `--ink-300`  | Texto `--ink-300`                      |
| Hover         | Contorno interno de 1 px `--void` | Contorno `--ink-300`, texto `--ink-100` | Fondo `--panel-2`, texto `--ink-100` |
| Foco (teclado)| Contorno de 1 px `--blue-300` a 2 px de distancia (`outline-offset: 2px`) | Igual                 | Igual, dentro de la fila               |
| Presionado    | Relleno `--blue-700`            | Relleno `--panel-2`                      | Fondo `--panel-2`                      |
| Seleccionado  | —                               | Relleno `--blue-500`, texto `--void`     | Barra de 2 px `--blue-500` a la izquierda |
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
| Modal, confirmación          | Diálogo (§5.13)                                              |
| Toast, alerta, log           | Notificación (§5.14); log largo: terminal (catálogo §3.9)    |
| Ayuda contextual             | Tooltip (§5.15)                                              |
| Gráfico, KPI                 | §5.16                                                        |
| Imagen, video, avatar        | §5.18                                                        |
| Vacío, carga, error          | §5.20                                                        |
| Vigilancia, rastreo, análisis de medios | Catálogo §3.7–§3.16                               |

### 7.2 Microcopy

- **Títulos:** la parte primaria dice qué es el contenido (`ACCOUNT`, `ORDERS`, `NETWORK`). El sufijo agrega un código, un calificador o un estado (`ORDERS / 2026-Q3`, `NETWORK-F12`, `SYNC / RUNNING`).
- **Densidad operativa:** los títulos llevan código, como en la película: `SUSTANTIVO-F<nn>.<nn>` (`VIEW-F11.31`), `SUSTANTIVO - MM/DD-DD/MM` (`ACTIVITY - 12/24-31/12`), `SUSTANTIVO <n>/<n>/<n>` (`FILES 49/19/68`).
- **Rótulos de estado:** una o dos palabras en mayúsculas: `ACTIVE`, `SCANNING`, `LIVE`, `STANDBY`, `IN PROGRESS`, `OFFLINE`, `ERROR`, `ENCRYPTED`.
- **Botones:** un verbo en mayúsculas, opcionalmente con objeto: `SAVE`, `EXPORT LOG`, `SIGN IN`.
- **Idioma:** la película usa inglés técnico. En un producto en otro idioma, usá ese idioma con el mismo tono: términos técnicos cortos, sin adjetivos.
- **Datos de ejemplo:** IPs ficticias con un octeto inválido (`541.112.255.01`, como en la película) o de los rangos de documentación RFC 5737. Rutas y códigos con forma real.
- **Tono:** vocabulario de sistemas y seguridad informática. La interfaz habla como software de hoy, no como ciencia ficción.

---

## 8. Verificación

### 8.1 Universal — toda pantalla

1. **Tokens:** una búsqueda de `#[0-9a-fA-F]{3,8}` y `rgb(` fuera del archivo de tokens da 0 resultados.
2. **Forma:** todo `border-radius` es 0, salvo los círculos permitidos en §3.5.
3. **Tipografía:** una familia sans y una monoespaciada; ningún peso supera 500; los números vivos o en columna usan `tabular-nums`.
4. **Contraste:** toda lectura cumple ≥ 4,5:1 sobre su fondo (§3.3).
5. **Color:** cada uso de lima, rojo, ámbar, naranja o teal corresponde a una fila de §3.2; cada panel tiene como máximo una acción primaria.
6. **Cromo mínimo:** cada panel tiene borde, escuadras en L y título.
7. **Movimiento:** toda `transition` y toda `animation` de interfaz dura 0 ms; las animaciones de datos usan `linear` o `steps()`.
8. **Estados:** cada elemento interactivo tiene reposo, hover, foco visible, presionado y deshabilitado (§6).
9. **Teclado:** todo elemento interactivo se alcanza con `Tab` y muestra el foco.
10. **Sin desplazamiento:** una actualización de datos no mueve el layout.

### 8.2 Por densidad

**Operativa:**

1. Sin scroll de página a 1366×768 ni a 1920×1080.
2. Cada panel tiene badge, línea de textura y controles de ventana.
3. Al menos un panel muestra datos vivos a 12–24 Hz (1 Hz con `prefers-reduced-motion`).
4. En una captura a 1920×1080, el lima ocupa < 3 % de los píxeles y el rojo < 0,5 %.

**Estándar:**

1. Sin scroll horizontal entre 768 y 1920 px de ancho; la barra superior queda fija durante el scroll vertical.
2. Ningún texto mide menos de 10 px.
3. Los paneles principales tienen badge.

**Compacta:**

1. Sin scroll horizontal a 360 px de ancho.
2. Todo elemento interactivo mide al menos 44 × 44 px.
3. Ningún texto mide menos de 11 px.
4. La pantalla tiene una sola acción primaria.
