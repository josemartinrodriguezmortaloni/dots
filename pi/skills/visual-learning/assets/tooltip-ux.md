# Nested tooltip UX

Behaviour spec for `runtime.js`. Read it before you change the runtime. The UX follows the tooltips of Paradox Interactive grand strategy games.

1. **Open.** Hover a concept link for 300 ms to open its tooltip. Place the tooltip offset from the cursor, away from the link, so it never covers the link.
2. **Lock.** A new tooltip lets the pointer pass through it (`pointer-events: none`). If the cursor stays on the link, the tooltip locks after 800 ms. A fill bar on the tooltip edge shows the lock progress. A locked tooltip shows a pin icon and receives clicks. A click or tap on a link opens and locks at once.
3. **Safe corridor.** After the cursor leaves the link, the convex hull of the exit point and the tooltip keeps the tooltip open. This lets the cursor travel diagonally from the link to the tooltip. If the cursor reaches the tooltip during the lock transition, the tooltip locks at once.
4. **Nest.** In a locked tooltip, concept links open child tooltips with the same timer and lock rules. Each child opens below or above its link line, so the parent's link text stays visible.
5. **Depth.** Max 4 levels show at the same time. A new child above that cap closes the oldest level after the root.
6. **Cycles.** A link to a concept already open in the chain renders as a muted, struck-through, non-interactive term.
7. **Close.** When the cursor leaves all tooltips, links, and corridors, the whole chain closes after a 250 ms grace period. When the cursor returns to an ancestor, only that ancestor's descendants close after the grace period. Esc closes the whole chain and nothing else.

## Test

`runtime.js` has no unit tests. After a change, build a fixture with `build.mjs` and drive it in headless Chromium with `playwright-core`. Check each numbered rule above: timings, lock, nesting, depth cap, cycle marking, prune, Esc, and corridor arrival.
