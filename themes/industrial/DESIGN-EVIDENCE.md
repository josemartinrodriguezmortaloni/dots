# DESIGN-EVIDENCE.md — Evidencia de medición

Respaldo de los valores de [`DESIGN.md`](DESIGN.md). Consultalo para verificar un valor, resolver una contradicción con una captura o extender el catálogo de componentes.

Regla de precedencia: un cuadro de los videos originales prevalece sobre este archivo, y este archivo prevalece sobre `DESIGN.md` en medidas y layout. El color, la familia tipográfica y el movimiento son decisiones de `DESIGN.md` §3 y no se verifican contra la película.

---

## 1. Fuentes

Carpeta local: `/home/m4s1t4/Videos/The Amateur/`. Origen: página del proyecto de Paul Roberts [F1].

| Archivo                               | Resolución | fps | Duración | md5 (prefijo) |
| ------------------------------------- | ---------- | --- | -------- | ------------- |
| `The_Amateur_CIA_2_1_Loop.mp4`        | 1920×1080  | 30  | 5,13 s   | `fa7885fd`    |
| `The_Amateur_CIA_CCTV_A_002.mp4`      | 1920×804   | 30  | 6,07 s   | `87cfa055`    |
| `The_Amateur_CIA_CCTV_B_002.mp4`      | 1920×804   | 24  | 2,92 s   | `2728ccf5`    |
| `The_Amateur_CIA_CCTV_D_001.mp4`      | 1920×820   | 30  | 3,37 s   | `042c5fc3`    |
| `The_Amateur_CIA_CCTV_E_001.mp4`      | 1920×820   | 30  | 4,60 s   | `f0038c1a`    |

- `The_Amateur_CIA_CCTV_D_001 (1).mp4`, `(2)` y `(3)` son copias idénticas de `D_001` (mismo md5).
- El loop es material de 24 fps entregado a 30 fps: 1 de cada 5 cuadros es un duplicado. Las mediciones de movimiento cuentan solo cuadros distintos.

---

## 2. Tomas

| Video  | Tiempo      | Contenido                                                                                     | Uso como evidencia            |
| ------ | ----------- | --------------------------------------------------------------------------------------------- | ----------------------------- |
| Loop   | 0,00–1,10 s | Pantalla `DECRYPTOR` completa, frontal y plana.                                               | Referencia principal: color, layout, tipografía, movimiento. |
| Loop   | 1,13 s      | Corte seco: el panel central queda vacío (solo cromo).                                        | Cambio de contenido.          |
| Loop   | 1,2–1,9 s   | Panel vacío; aparece la tarjeta `CD-ROM / ENCRYPTED` y el cursor.                             | Tarjeta flotante, cursor.     |
| Loop   | 2,0–2,9 s   | Toma en perspectiva con desenfoque del mismo panel.                                           | Solo cámara.                  |
| Loop   | 3,0–5,1 s   | Primer plano del dial radial y del gráfico de pistas, en perspectiva.                         | Dial, retícula, tag rojo.     |
| CCTV A | 0,0–2,7 s   | Muro CCTV frontal: 5×4 tiles, columna de datos a la derecha.                                  | Arquetipo B, tile CCTV, tablas. |
| CCTV A | 2,8–3,4 s   | Reconfiguración de tiles: un feed pasa a 2×2.                                                 | Marco sobre grilla.           |
| CCTV A | 3,5–6,0 s   | Feed ampliado con grade verde azulado; cabecera `CCTV ZOOM`.                                  | Cabecera sobre video.         |
| CCTV B | 0,0–0,9 s   | Muro de monitores en la sala, plano general.                                                  | Contexto.                     |
| CCTV B | 1,0–2,9 s   | Feed frontal de molinetes con recuadros faciales y fila de tarjetas `GATES`.                  | Detección facial, mosaico.    |
| CCTV D | 0,0–3,4 s   | Composición de 4 tomas de monitores: muro de 4×2 tiles y fila de tarjetas `VIEW`.             | Arquetipo B con tarjetas.     |
| CCTV E | 0,0–3,9 s   | Sala de control, muro de monitores, badge `IN PROGRESS`.                                      | Tarjetas de estado.           |
| CCTV E | 4,0–4,6 s   | Frontal: región de escaneo rayada y reconstrucción de mochila; tarjetas `STANDBY`.            | Arquetipo C.                  |

---

## 3. Color

Método: mediana y percentil 90 de los píxeles que cumplen un predicado dentro de una caja, sobre el cuadro indicado. Coordenadas en píxeles del video original.

| Elemento                         | Cuadro        | Caja (x0,y0,x1,y1)   | Mediana   | p90       |
| -------------------------------- | ------------- | -------------------- | --------- | --------- |
| Lienzo entre paneles             | Loop 0,00 s   | 314,300,318,600      | `#000004` | —         |
| Fondo de panel central           | Loop 0,00 s   | 700,500,800,510      | `#00080C` | —         |
| Fondo de terminal                | Loop 0,00 s   | 40,960,600,1000      | `#040810` | —         |
| Borde de panel                   | Loop 0,00 s   | 400,230,1200,236     | `#02143C` | `#0B1D45` |
| Grilla del gráfico de pistas     | Loop 0,00 s   | 700,300,1500,600     | `#16272F` | `#313539` |
| Badge `24`                       | Loop 0,00 s   | 16,52,42,78          | `#00447D` | —         |
| Barra de progreso inferior       | Loop 0,00 s   | 420,810,1060,822     | `#0065AB` | —         |
| Chip activo                      | Loop 0,00 s   | 360,98,640,108       | `#135992` | `#4C9DD8` |
| Tag rojo junto al título hero    | Loop 0,00 s   | 800,48,830,58        | `#830B15` | `#95101F` |
| Rojo más saturado del cuadro     | Loop 0,00 s   | cuadro completo      | `#A81018` | —         |
| Título `DECRYPTOR`               | Loop 0,00 s   | 380,48,570,72        | `#969598` | `#C5C6CB` |
| Sufijo `WP804100.WAV`            | Loop 0,00 s   | 600,48,800,72        | `#5F5E63` | `#6E6E6E` |
| Texto de menú                    | Loop 0,00 s   | 250,10,280,24        | `#41474D` | `#4A5056` |
| Texto de teclas F                | Loop 0,00 s   | 255,1055,300,1068    | `#4F5359` | `#5D5E65` |
| Ruta de archivo inactiva         | Loop 0,00 s   | 50,158,300,170       | `#1C2026` | `#20262C` |
| Horas `WORLD CLOCKS` (azul)      | CCTV A 0,2 s  | 1300,60,1600,190     | `#315979` | `#65AFE1` |
| Badge CCTV                       | CCTV A 0,2 s  | 20,10,60,40          | `#1D5788` | —         |
| Barra superior de recuadro facial| CCTV B 1,46 s | 1200,60,1480,110     | `#A56D4B` | `#B77D5A` |
| Badge `IN PROGRESS`              | CCTV E 0,46 s | 730,730,760,760      | `#965C46` | `#C28268` |

Cobertura de color en Loop 0,00 s (muestreo cada 2 px): casi negro 86,4 %, azul saturado 0,80 %, blanco 0,78 %, rojo 0,02 %.

Confianza:

- Alta: lienzo, panel, bordes, azules, grises. Hay muchos píxeles y aparecen en varias tomas.
- Media: rojo. Pocos píxeles; la compresión H.264 reduce la saturación de áreas chicas.
- Baja: ámbar. Aparece solo en tomas con grade verde azulado.
- Sin medir: el verde de la palabra `Successful` en la terminal 1. Se ve verdoso a simple vista, pero tiene menos de 50 píxeles.

---

## 4. Layout y tipografía

Medido sobre Loop 0,00 s (1920×1080).

| Medida                                 | Valor                                        |
| -------------------------------------- | -------------------------------------------- |
| Barra de menú                          | y 0–36; borde azul en y 35–37                |
| Contenido                              | y 40–845                                     |
| Fila de terminales                     | y 862–1040, 3 paneles iguales                |
| Barra de funciones                     | y 1045–1080                                  |
| Columna izquierda                      | x 5–313 (≈ 2 de 12 columnas)                 |
| Columna central                        | x 320–1600 (≈ 8 de 12)                       |
| Columna derecha                        | x 1606–1915 (≈ 2 de 12); 4 paneles iguales   |
| Panel hero / panel `FILES 87`          | x 320–1270 / x 1280–1595, y 40–230           |
| Separación entre paneles               | ≈ 6 px                                       |
| Badge                                  | ≈ 28×28 px                                   |
| Altura de mayúscula, título hero       | ≈ 20 px                                      |
| Altura de mayúscula, título de panel   | ≈ 13 px                                      |
| Altura de mayúscula, ruta de archivo   | ≈ 10 px                                      |
| Altura de mayúscula, menú y teclas F   | ≈ 7 px                                       |
| Altura de mayúscula, textura           | ≈ 5 px                                       |

Muro CCTV (CCTV A 0,2 s, 1920×804): tiles de ≈ 320 px de ancho en x 0–1600; columna de datos en x 1605–1915.

La identificación de la familia tipográfica es por rasgos, no por un archivo de fuente: contraformas cuadradas, `O` como rectángulo redondeado, `C` de lados rectos, números estrechos. La familia más cercana es Eurostile.

---

## 5. Movimiento

Método: diferencia absoluta en escala de grises entre cuadros consecutivos (umbral 25/255), por región, en Loop 0,00–1,47 s.

| Región                    | Caja                 | Cuadros distintos con cambio | Comportamiento                         |
| ------------------------- | -------------------- | ---------------------------- | -------------------------------------- |
| Barra de menú             | 0,0,1920,35          | 0 / 35                       | Estático.                              |
| Árbol de archivos         | 0,90,310,630         | 1 / 35                       | Estático.                              |
| Grilla `FILES 87`         | 1280,80,1590,220     | 0 / 35                       | Estático.                              |
| Terminales                | 0,880,1920,1040      | 0 / 35                       | Estático.                              |
| Barras `LEVEL`            | 330,110,1270,220     | todos                        | Crecen; los valores suben.             |
| Gráfico de pistas         | 600,230,1590,800     | todos                        | Ticks y bloques cambian.               |
| Dial radial               | 320,230,600,830      | todos                        | Segmentos cambian.                     |
| Progreso inferior         | 330,805,1590,825     | todos                        | Avanza.                                |
| Matrices `ACTIVITY`       | 1610,80,1920,830     | todos                        | Sustitución de caracteres.             |

- "Todos" significa todos los cuadros no duplicados: la actualización sigue la cadencia de 24 Hz de la fuente.
- En el cuadro 34 (≈ 1,13 s) el panel central pasa de lleno a vacío en un solo cuadro. Las matrices `ACTIVITY` siguen cambiando después del corte.

---

## 6. Correcciones respecto de la versión anterior de DESIGN.md

La versión anterior no estaba verificada contra los videos. Estas afirmaciones resultaron incorrectas:

| Afirmación anterior                                     | Evidencia                                                     |
| ------------------------------------------------------- | ------------------------------------------------------------- |
| Acento cian `#00A3A6` para el estado nominal            | No hay cian en la UI. El acento es azul `#0065AB`.            |
| Ámbar `#D97706` como advertencia general                | El ámbar aparece solo en detección facial y `IN PROGRESS`.    |
| Video en monocromo azulado con capa de color            | El video es a color natural. El tinte verde azulado es el grade de la película. |
| Prohibidos los anillos concéntricos y las retículas     | El panel principal tiene un dial de arcos concéntricos con retícula. |
| Borde del módulo cambia de color con el estado          | Los bordes son siempre azul marino. La alerta es un tag rojo. |
| Tipografía Inter + JetBrains Mono                       | Una sans cuadrada tipo Eurostile para todo; mono solo en código. |
| Actualización de números cada 50–200 ms                 | Los datos vivos cambian en cada cuadro fuente (≈ 42 ms).      |

---

## 7. Reproducir la medición

```sh
cd "/home/m4s1t4/Videos/The Amateur"
# Cuadro de referencia principal
ffmpeg -ss 0 -i The_Amateur_CIA_2_1_Loop.mp4 -frames:v 1 loop_t0.png
# Hoja de contactos a 6 fps
ffmpeg -i The_Amateur_CIA_2_1_Loop.mp4 -vf "fps=6,scale=480:-1,tile=6x6" -frames:v 1 loop_sheet.png
# Secuencia para medir movimiento
ffmpeg -t 1.5 -i The_Amateur_CIA_2_1_Loop.mp4 seq/f%03d.png
```

Para medir un color: recortá la caja de §3 con Pillow y calculá la mediana de los píxeles que cumplen el predicado del elemento (por ejemplo, azul `b > 100 && b − r > 50`).
