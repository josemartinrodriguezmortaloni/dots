---
name: locality
description: Law of Locality and cyclomatic complexity below 4. Use when implementing code, refactoring code or a module, or designing a feature, idea, or refactor with the user.
---

# Locality

Software exists to solve human problems and must evolve while it does. It is an executable model of reality: its structure mirrors the structure of the problem, not of the technology. When the domain changes, the place to change is then known.

## The law

Every decision, datum, and behavior lives in exactly one place: the place where it makes conceptual sense. That place changes without shockwaves elsewhere. The failure mode is the Jenga tower: one moved block collapses unrelated behavior.

## Pillars

Every module and dependency passes all three.

- **I. Single localized responsibility.** A module exists only if its responsibility is clear and indivisible, that responsibility cannot live elsewhere without more coupling, and the system loses an essential capability without it.
- **II. Cohesion by reason for change.** Group by shared volatility, never by technical similarity. What changes together lives together; what changes for different reasons is split. Signup rules live with `Signup`, not in a shared `validators` module.
- **III. Intentional coupling.** Accidental coupling is the defect; coupling itself is a tool. Every dependency is explicit (visible in the contract), directional (clear, acyclic flow), justified (a real domain collaboration), and minimal (only the surface needed).

## Modularity

A modular system is a set of cohesive, loosely coupled modules. The pillars apply at four scales:

- Method: one clear objective.
- Class: strictly related aspects only.
- System: capabilities in autonomous modules.
- Module border: explicit, minimal dependencies.

## Cyclomatic complexity

V(G) = decision points + 1. Every function, method, and routine ends at V(G) < 4: at most two decisions. The decision count is the mechanical proxy for a method's single objective.

Enforce with a gate: a command in the project's lint or CI run that exits non-zero when any function has V(G) > 3. Tools flag V(G) above their max, so max is 3. Reduce by extracting a function that names one domain rule (Pillar II); a split that only spreads decisions across meaningless fragments moves the defect.

Gate violations outside the task's scope go to the user as a report; the user authorizes their refactor.

Read [CYCLOMATIC.md](CYCLOMATIC.md) before adding or running the gate and when a function reaches V(G) ≥ 4.

## Modes

Pick the mode by the request. Every step ends on its "Done when" criterion.

### Design with the user

Entry: the user explores a feature, idea, or refactor. No code yet.

1. State the human problem in the user's domain terms. Done when one sentence names who has what problem and the user confirms it.
2. List the reasons for change: what will likely change and its cause. Done when every item names its cause.
3. Give each decision, datum, and behavior one home (Pillars I, II). Done when no item has two homes or none, and the user confirms the assignment.
4. Draw the dependencies as contracts (signatures, no bodies). Done when every edge passes Pillar III and the graph has no cycle.
5. Pull test: for each change from step 2, list the places it touches. Done when each change touches one module; a change touching more returns to step 3.
6. Sketch the functions of each module. Done when every function's objective is stated without "and" and the user accepts the design.

After acceptance, run Implement.

### Implement

Entry: write code from scratch, or add behavior to existing code.

1. Find the home: the module that owns the behavior by reason for change. Create a module only if it passes Pillar I. Done when the target module is named and its reason for change covers the new behavior.
2. Write the code. Done when every dependency is visible in a signature or constructor and each function's objective is stated without "and".
3. Run the gate, adding it first when the project has none. Done when gate output shows no violation in any function written or edited; reduce and re-run for any above. A function edited while above the threshold gets the Refactor steps.
4. Pull test on the most likely next change. Done when it touches one place.

### Refactor

Entry: restructure a function, a module, or a whole area of code. Behavior stays.

1. Baseline: run the gate (adding it first when the project has none) and check every module in scope against the three pillars. Done when every gate violation and every pillar violation in scope is listed.
2. Pin the behavior with tests. Done when they pass on the untouched code and exercise every branch in scope (coverage output read).
3. Restructure one violation per move. Done when the tests pass after each move and every listed violation is closed.
4. Re-run the gate, then pull test on the most likely next change. Done when gate output shows no violation in scope and the change touches one place.
