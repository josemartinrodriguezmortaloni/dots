# DESIGN-CATALOG.md — Catálogo de la película

Capa 3 del sistema de [`DESIGN.md`](DESIGN.md). Contiene las composiciones y los componentes que aparecen en las pantallas de la CIA de _The Amateur_ (2025). Todo lo que está acá es **observado** en los videos.

Usá este catálogo en dos casos:

- La pantalla tiene densidad **operativa** (DESIGN.md §4.1). Las composiciones de §1 y el shell de §2 son su punto de partida.
- La pantalla necesita un componente de la película, en cualquier densidad: un dial, un gráfico de pistas, una terminal, un tile de video, un recuadro de detección.

Los componentes usan los tokens, la tipografía y los estados de DESIGN.md. Las medidas de este archivo son para densidad operativa a 1920×1080. En otra densidad, tomá los tamaños de texto y de control de los tokens de esa densidad y conservá la estructura del componente.

---

## 1. Composiciones de pantalla operativa

Grilla de 12 columnas. Cada composición reproduce una pantalla de la película.

### 1.1 Consola de análisis (pantalla `DECRYPTOR`)

Columnas 2 / 8 / 2.

```css
.shell-console {
  display: grid;
  grid-template-columns: repeat(12, minmax(0, 1fr));
  grid-template-rows: 36px minmax(0, 1fr) minmax(0, 3fr) 190px 36px;
  grid-template-areas:
    "menu menu menu menu menu menu menu menu menu menu menu menu"
    "tree tree hero hero hero hero hero hero ids  ids  act  act"
    "tree tree main main main main main main main main act  act"
    "trm1 trm1 trm1 trm1 trm2 trm2 trm2 trm2 trm3 trm3 trm3 trm3"
    "fkey fkey fkey fkey fkey fkey fkey fkey fkey fkey fkey fkey";
  gap: var(--gap);
  padding: 0 5px;
  height: 100vh;
  background: var(--void);
}
```

- `tree`: árbol de archivos (§3.2) en ≈ 75 % del alto y un panel de miniaturas debajo.
- `hero`: panel principal con título hero y filas `LEVEL` (§3.1).
- `ids`: grilla de códigos (§3.3).
- `main`: dial radial (§3.7) recortado a la izquierda y gráfico de pistas (§3.8) a la derecha.
- `act`: cuatro matrices de datos (§3.4) apiladas, de igual alto.
- `trm1–3`: tres terminales (§3.9) de igual ancho.

### 1.2 Muro CCTV

Video en 10 columnas, datos en 2.

```css
.shell-cctv {
  grid-template-rows: 36px minmax(0, 1fr) 96px 36px;
  grid-template-areas:
    "menu menu menu menu menu menu menu menu menu menu menu menu"
    "wall wall wall wall wall wall wall wall wall wall data data"
    "card card card card card card card card card card data data"
    "fkey fkey fkey fkey fkey fkey fkey fkey fkey fkey fkey fkey";
}
```

- `wall`: grilla interna de 5 × 4 tiles de video (§3.10), sin separación. Un feed puede ocupar 2 × 2 tiles.
- `data`: paneles apilados: tabla clave-valor (§3.5), tabla de estructura (§3.6), grilla de códigos (§3.3), matrices (§3.4).
- `card`: 5–6 tarjetas de igual ancho: tarjetas de identidad (§3.14) y tarjetas de estado (`VIEW-F5.55`, `STANDBY`, `IN PROGRESS`).

### 1.3 Monitor de detalle

- Un feed ampliado ocupa 6 columnas, con una región de escaneo (§3.12) o recuadros de detección (§3.11).
- A la derecha, 4 columnas muestran una vista derivada: reconstrucción de objeto (§3.13), rostro o mapa.
- En las 2 columnas finales van matrices de datos.
- Debajo va la fila de tarjetas.

### 1.4 Paso de fila medido

| Elemento                              | Paso de fila |
| ------------------------------------- | ------------ |
| Árbol de archivos                     | 25 px        |
| Tabla clave-valor                     | 20 px        |
| Filas `LEVEL`                         | 17 px        |
| Filas del gráfico de pistas           | 30 px        |
| Grilla de códigos                     | 11 px        |
| Matriz de datos                       | 12 px        |
| Código de terminal                    | 12 px        |

---

## 2. Shell operativo

### 2.1 Barra de menú

- Alto 36 px, fondo `--panel`, borde inferior de 1 px en `--line`.
- Izquierda: emblema de 16 px + `Systems` en `--t-label` `--ink-300` + versión `v24.004.b` en `--ink-500`.
- Ítems `FILE EDIT VIEW WINDOW COMMS NETWORK`, en `--t-label` `--ink-700`, en celdas de igual ancho (≈ 140 px) separadas por líneas verticales de 1 px `--line`.
- Derecha: bandeja de iconos de 14 px (`+`, monitores, engranaje, `ENG`, niveles, candado), cada uno con una tecla F en superíndice de 6 px.

### 2.2 Barra de funciones

- Alto 36 px. Comandos `HELP F1`, `ADV HELP F2`, `PROMPT F3`, `REFRESH F4`, `ADD/CREATE F5`, `EXIT F6` y `▶`, en `--t-label` `--ink-500`, en celdas iguales con divisores de 1 px.
- Derecha: cinco iconos de layout (grilla, tabla, mosaico, reloj, engranaje), un campo de búsqueda `Filter ADV +` de ≈ 250 px sobre `--panel-2`, y un menú `⋮`.
- Cada comando es un atajo de teclado real: `F1` abre la ayuda.

---

## 3. Componentes de la película

### 3.1 Fila `LEVEL`

Variante de la barra rayada (DESIGN.md §5.12) con rótulo y valor.

- Fila de 17 px: rótulo `LEVEL 1` (`--t-body`, peso 500, `--ink-100`) + barra + valor.
- Barra de 6 px de alto. Segmento opcional en `--accent` sólido al final del relleno, para marcar el tramo actual.
- Valor a la derecha: `05.33` en `--t-body` `tabular-nums` `--ink-100`, seguido de un glifo `▲` de 6 px.
- Encima de las filas va un bloque de chips (`FLR`, `SCN`, `EXT`, `OVR`), agrupados de a 3–6, con uno o dos activos.

### 3.2 Árbol de archivos

- Filas de 25 px. Grupo: caret `▼` en `--ink-300` + nombre `.SSY/051_23B` en `--ink-100`.
- Ítem: sangría de 16 px, icono de 12 px (documento en `--ink-300`, o documento relleno `--accent` para el ítem seleccionado) + ruta en minúsculas `files/fgrkshn/dfgr999/23/…` en `--t-body`.
- Ítem activo en `--ink-100`. Ítem inactivo en `--ink-900` (texto fantasma).

### 3.3 Grilla de códigos (`FILES 49/19/68`, `FILE SYSTEM - LIVE`)

- 4–5 columnas iguales, filas de 11 px.
- Fila: índice en un cuadrado de 7 px `--ink-700` con numeral de 6 px + marcador opcional `▶` + código `0000121` en `--t-code` `--ink-300`.
- Códigos enmascarados `XXX-XX2` mezclados con los numéricos.
- 20–30 % de las filas en `--ink-900`.

### 3.4 Matriz de datos (`DATA`, `ACTIVITY`)

- 4 columnas × 2 bloques.
- Encabezado de columna en textura: `ZNE-A` + sufijo de 5 px.
- Celda: 4 líneas de 6 caracteres alfanuméricos (`A02561`, `9105 1`) en `--t-body` `--ink-300`. Algunos caracteres faltan y dejan huecos.
- Datos vivos: cada actualización reemplaza el 10–20 % de los caracteres, elegidos al azar.

### 3.5 Tabla clave-valor (`WORLD CLOCKS`)

- Dos pares por fila, filas de 20 px.
- Clave en mayúsculas con dos puntos (`CHICAGO:`) en `--t-body` `--ink-300`.
- Valor `14:23:45` en `--accent` `tabular-nums`.

### 3.6 Tabla de estructura (`STRUCTURE`)

- Encabezados de columna en textura `--ink-500` (`INPT`, `OTPT`, `RSLTS`, `RTE`).
- Valores en pares (`20-00 38 40`). La fila actual en `--accent`, el resto en `--ink-300`.
- Última columna: grilla de celdas de 12 px con números. Celda seleccionada con relleno `--accent`. Celda enfocada con contorno de 1 px `--ink-300`.

### 3.7 Dial radial

Instrumento circular recortado por el borde del panel: se ve media circunferencia o menos.

- 4–6 arcos concéntricos de 1 px `--ink-300`, cada uno de 60–200°. Un arco principal de 2 px `--ink-100`.
- 1–2 anillos de segmentos: guiones radiales de 3×8 px con separación irregular.
- Escala de rangos (`91-100` … `01-10`) en `--t-body` `--ink-100`, sobre el arco. La escala continúa como rótulo de fila del gráfico de pistas.
- Centro: cruz `+` de 20 px en `--ink-100`.
- Retícula de foco: rectángulo con esquinas en L que contiene una mini lectura (tag rojo, `LEVEL 1`, 4 pares clave-valor en textura).
- Tarjeta de medio (`MEDIA/CD-4.09`): badge chico + título + 4 líneas de textura, con esquinas en L.
- Cada arco y cada anillo representa una escala o un valor. Un dial sin dato no existe en la película.

### 3.8 Gráfico de pistas

Gráfico de eventos en filas horizontales.

- Filas de 30 px separadas por líneas `--grid`. Grilla vertical `--grid` cada 50 px.
- Rótulo de rango de cada fila a la izquierda.
- Eventos:
  - Ticks verticales de 2×8 px en `--ink-100`, en grupos tipo código de barras.
  - Cuadrados de 6 px en `--accent`.
  - Tramos: línea de 1 px con topes en los extremos y un micro rótulo centrado.
  - Cápsulas: rectángulo de doble línea de 3 px de alto, en `--ink-300`.
  - Marcadores `▽` y `△` de 6 px, y cruces `+` de 14 px.
  - Un tag `--red-600` marca el evento seleccionado.
- Barra inferior: progreso sólido de 8 px en `--accent`, con rótulo de rango (`01-10`) y una franja de ticks.
- Micro rótulos `ACTIVE` y pares de valores (`37.95 / 38.23`) en los márgenes.

### 3.9 Terminal

- Cabecera: badge emblema + `TERMINAL 1 / SCANNING` (sufijo en `--accent`) + textura `DECRYPTION`.
- Franja de subtítulo: barra de 16 px sobre `--panel-2` con la ruta `SCAN/REMOVABLE_MEDIA_DECRYPTION` en textura. Chevrons `▷` en el margen izquierdo.
- Área de código sobre `--panel-2`. Números de línea en `--ink-500`. Código en `--t-code` `--ink-300`.
- Sintaxis: palabras clave, rutas y resultados exitosos en `--ink-100`. `Error`, strings y literales en `--red-600`.
- Una terminal ancha divide el código en dos columnas.
- Ítem marcado: una pill `--red-600` de 60×6 px en la línea del ítem, después de su tamaño (`14426 bytes`).
- El código de la terminal es estático. No se desplaza solo.

### 3.10 Tile CCTV

- Video a color natural. Tiles contiguos, sin separación.
- Separación entre tiles: línea de 1 px en `--line`. Cruz `+` de 9 px en `--ink-100` en cada intersección.
- Cabecera superpuesta al video, sin caja de fondo: badge + `CCTV ZOOM -21.27.3V0` + textura `SELECT`.
- Arriba a la derecha: chips de textura `SNAPSHOT`, `VIEW`, `ACTIVE`, y los controles de ventana.
- Lateral derecho interno: columna de pares de valores (`28.27 / 34.98`) en textura `--ink-100`.
- Chips `SCANNING` de 20×6 px, con relleno `--accent` o contorno `--ink-300`.
- Controles de reproducción: 4 círculos de 14 px con contorno de 1 px (`◀`, `▶`, `●`, `▢`). El activo va relleno en `--accent`.
- Leyenda sobre el video: `REF 1320/78 TRANSMISSION` en 14 px con tracking de 0,1 em. `REF 1320/78` en `--accent`, `TRANSMISSION` en `--ink-100`.
- Tile offline: `▷ STATUS` y `OFFLINE` centrados en `--t-label` `--ink-500`, con `ACTIVE IP 541.112.255.01` en textura.

### 3.11 Recuadro de detección facial

- Rectángulo de 1 px `--ink-100` alrededor del rostro.
- Barra de 4 px en `--amber-500` sobre todo el borde superior.
- Icono de captura de 12 px (cuadrado `--accent` con una diagonal) en la esquina superior izquierda, dentro del recuadro.
- ID del sujeto (`208`) en 16 px `--ink-100`, fuera del recuadro, a la izquierda.
- Coordenadas `X: 45 / Y:` en textura, fuera del recuadro, arriba a la derecha.
- Etiqueta `▣ EID > 133` en textura, debajo del recuadro.
- Cruz `+` de 20 px en el centro del sujeto que se sigue.

### 3.12 Región de escaneo

- Rectángulo de 1 px `--ink-300` sobre el video.
- Relleno rayado a 45°: líneas de 1 px `--ink-100` al 30 %, cada 6 px.
- Flecha `▷` de 8 px en la esquina superior derecha.
- Pares de chips `SCANNING` con valores de textura dentro de la región.

```css
.scan-region {
  border: 1px solid var(--ink-300);
  background: repeating-linear-gradient(135deg, color-mix(in srgb, var(--ink-100) 30%, transparent) 0 1px, transparent 1px 6px);
}
```

### 3.13 Reconstrucción de objeto

- Render de nube de puntos y líneas, blanco sobre `--panel`, estilo radiografía.
- Partes identificadas con micro cajas: icono de 10 px + `OBJ >` en textura, unidas a la parte por una línea de 1 px.

### 3.14 Tarjeta de identidad (`GATES-F11`)

- Tarjeta de la fila inferior: badge + título + textura + 2–3 filas de controles (`CAM 3`, `GATE 9`).
- A la derecha, dos miniaturas de rostro de 64×72 px.
- Variante mosaico: el rostro se arma con parches rectangulares desplazados unos píxeles entre sí. Comunica una identidad reconstruida desde varias fuentes.

### 3.15 Control de cámaras

- Filas `CAM 1 ON/OFF`. La opción activa en `--ink-100`, la inactiva en `--ink-700`.
- A la izquierda de cada fila, un par de chips de 16×8 px.

### 3.16 Tarjeta de objeto flotante (`CD-ROM / ENCRYPTED`)

- Icono de disco de 90 px: círculos concéntricos en `--ink-300` con un rótulo de textura. Debajo, una IP en textura.
- Tarjeta de ≈ 380×260 px sobre `--panel`, con esquinas en L.
- Izquierda: cuadro de vista previa vacío con esquinas en L.
- Derecha: título `CD-ROM / ENCRYPTED` (`ENCRYPTED` en `--red-600`) y 4 líneas clave-valor en textura.

---

## 4. Movimiento medido

Medido cuadro a cuadro en el loop principal (fuente a 24 fps). Detalle en [`DESIGN-EVIDENCE.md`](DESIGN-EVIDENCE.md) §5.

| Región                                            | Comportamiento                                            |
| ------------------------------------------------- | --------------------------------------------------------- |
| Barra de menú, barra de funciones, cromo          | Estático.                                                 |
| Árbol de archivos, grilla de códigos, terminales  | Estático.                                                 |
| Filas `LEVEL`, gráfico de pistas, dial, progreso  | Cambia en cada cuadro fuente (24 Hz).                     |
| Matrices de datos                                 | Cambia en cada cuadro fuente: sustitución de caracteres.  |

El cambio de contenido de un panel es un corte de un cuadro: el panel queda vacío (solo cromo y parte primaria del título) y el contenido nuevo entra también por corte.
