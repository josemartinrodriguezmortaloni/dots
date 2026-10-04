// Nested tooltip runtime for visual-learning pages.
// Markup contract: SKILL.md "Markup contract". Behaviour spec: tooltip-ux.md.

const OPEN_MS = 300;
const LOCK_MS = 800;
const GRACE_MS = 250;
const MAX_LEVELS = 4;
const GAP = 8;
const LINK = "[data-c]:not(.c-cycle)";

// One level per open tooltip, root first: { id, link, tip, x, locked, exit, lockTimer }.
const chain = [];
const pointer = { x: 0, y: 0 };
const prune = { target: null, timer: 0 };
let openTimer = 0;

// Widgets

function mountWidget(el) {
  if (el.dataset.mounted) return;
  el.dataset.mounted = "1";
  try {
    window.W[el.dataset.widget](el);
  } catch (err) {
    el.textContent = `Widget error: ${err.message}`;
  }
}

const mountWidgets = (root) => root.querySelectorAll("[data-widget]").forEach(mountWidget);
const typeset = (el) => window.MathJax?.typesetPromise?.([el]) ?? Promise.resolve();

// Geometry (viewport coordinates)

const between = (v, lo, hi) => lo <= v && v <= hi;

function inRect(p, el) {
  const r = el.getBoundingClientRect();
  return between(p.x, r.left, r.right) && between(p.y, r.top, r.bottom);
}

const cross = (p, a, b) => (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y);

function inTriangle(p, a, b, c) {
  const signs = [cross(p, a, b), cross(p, b, c), cross(p, c, a)];
  return signs.every((d) => d >= 0) || signs.every((d) => d <= 0);
}

const corners = (r) => [
  { x: r.left, y: r.top },
  { x: r.right, y: r.top },
  { x: r.right, y: r.bottom },
  { x: r.left, y: r.bottom },
];

// Safe corridor: the convex hull of the exit point and the tooltip rectangle.
function inCorridor(level) {
  if (!level.exit) return false;
  const c = corners(level.tip.getBoundingClientRect());
  return c.some((corner, i) => inTriangle(pointer, level.exit, corner, c[(i + 1) % 4]));
}

const isAlive = (level) => inRect(pointer, level.tip) || inRect(pointer, level.link) || inCorridor(level);

const clamp = (v, lo, hi) => Math.max(lo, Math.min(v, hi));

// Below the link line when it fits, else above it: the link text stays visible.
function place(level) {
  const { tip, link, x } = level;
  const r = link.getBoundingClientRect();
  const below = r.bottom + GAP;
  const top = below + tip.offsetHeight < innerHeight ? below : Math.max(GAP, r.top - GAP - tip.offsetHeight);
  const left = clamp(x + 2 * GAP, GAP, innerWidth - tip.offsetWidth - GAP);
  tip.style.left = `${left + scrollX}px`;
  tip.style.top = `${top + scrollY}px`;
}

// Chain

const levelOf = (el) => chain.findIndex((level) => level.tip.contains(el));
const levelFor = (link) => chain.find((level) => level.link === link);
const findTemplate = (id) => document.querySelector(`template[data-concept="${CSS.escape(id)}"]`);

function markCycles(tip, pathIds) {
  tip.querySelectorAll("[data-c]").forEach((link) => {
    if (pathIds.includes(link.dataset.c)) link.classList.add("c-cycle");
  });
}

function buildTip(template, pathIds) {
  const tip = document.createElement("div");
  tip.className = "tip";
  tip.innerHTML = '<div class="tip-bar"><i></i></div><h3 class="tip-title"></h3>';
  tip.querySelector(".tip-title").textContent = template.dataset.title;
  tip.append(template.content.cloneNode(true));
  markCycles(tip, pathIds);
  return tip;
}

function removeLevel(level) {
  clearTimeout(level.lockTimer);
  level.tip.remove();
}

const closeFrom = (index) => chain.splice(index).forEach(removeLevel);

// Above the cap, drop the oldest level after the root.
function enforceDepth() {
  if (chain.length <= MAX_LEVELS) return;
  removeLevel(chain.splice(1, 1)[0]);
}

// Lock

function startLock(level) {
  level.exit = null;
  level.tip.classList.add("locking");
  level.lockTimer = setTimeout(() => lock(level), LOCK_MS);
}

function cancelLock(level) {
  clearTimeout(level.lockTimer);
  level.tip.classList.remove("locking");
}

function lock(level) {
  if (level.locked) return;
  cancelLock(level);
  level.locked = true;
  level.tip.classList.add("locked");
}

function relock(level) {
  if (!level.locked) startLock(level);
}

// Open

function openLevel(link) {
  const template = findTemplate(link.dataset.c);
  if (!template) return;
  closeFrom(levelOf(link) + 1);
  const pathIds = [...chain.map((level) => level.id), link.dataset.c];
  const level = { id: link.dataset.c, link, tip: buildTip(template, pathIds), x: pointer.x, locked: false, exit: null };
  document.body.append(level.tip);
  chain.push(level);
  enforceDepth();
  place(level);
  startLock(level);
  mountWidgets(level.tip);
  typeset(level.tip).then(() => place(level));
}

function openOrRelock(link) {
  const level = levelFor(link);
  if (level) return relock(level);
  openLevel(link);
}

// Close: prune to the deepest level that still holds the cursor, after a grace period.

function cancelPrune() {
  clearTimeout(prune.timer);
  prune.target = null;
}

function schedulePrune(target) {
  if (target === chain.length - 1) return cancelPrune();
  if (target === prune.target) return;
  cancelPrune();
  prune.target = target;
  prune.timer = setTimeout(() => {
    prune.target = null;
    closeFrom(target + 1);
  }, GRACE_MS);
}

// A tooltip that the cursor reaches during its lock transition locks at once.
function lockOnArrival() {
  const top = chain.at(-1);
  if (top && inRect(pointer, top.tip)) lock(top);
}

function leaveLink(link, point) {
  const level = levelFor(link);
  if (!level) return;
  level.exit = point;
  cancelLock(level);
}

// Events

// The link the pointer entered or left, or null when it moved inside one link.
function crossedLink(event) {
  const link = event.target.closest?.(LINK);
  if (!link || link.contains(event.relatedTarget)) return null;
  return link;
}

function trackPointer(event) {
  pointer.x = event.clientX;
  pointer.y = event.clientY;
  lockOnArrival();
  schedulePrune(chain.findLastIndex(isAlive));
}

document.addEventListener("pointermove", trackPointer);
document.addEventListener("pointerdown", trackPointer);

document.addEventListener("pointerover", (event) => {
  const link = crossedLink(event);
  if (!link) return;
  clearTimeout(openTimer);
  openTimer = setTimeout(() => openOrRelock(link), OPEN_MS);
});

document.addEventListener("pointerout", (event) => {
  const link = crossedLink(event);
  if (!link) return;
  clearTimeout(openTimer);
  leaveLink(link, { x: event.clientX, y: event.clientY });
});

// Click and tap open and lock at once.
document.addEventListener("click", (event) => {
  const link = event.target.closest?.(LINK);
  if (!link) return;
  clearTimeout(openTimer);
  openOrRelock(link);
  const level = levelFor(link);
  if (level) lock(level);
});

// Esc closes the chain and only the chain.
document.addEventListener(
  "keydown",
  (event) => {
    if (event.key !== "Escape" || !chain.length) return;
    event.preventDefault();
    event.stopImmediatePropagation();
    closeFrom(0);
  },
  true,
);

document.documentElement.style.setProperty("--lock-ms", `${LOCK_MS}ms`);
mountWidgets(document.querySelector("main"));
