# Cyclomatic complexity

McCabe introduced it in 1976. V(G) counts the linearly independent paths through a function. It equals the number of tests for basis-path coverage and is the upper bound of the tests that branch coverage needs.

## Count

V(G) = D + 1, where D is the number of decision points:

- `if`, `else if`, ternary `? :`
- `for`, `while`, `do-while`
- each `case` of a `switch` (`default` excluded)
- short-circuit `&&` and `||`
- each `catch`

Equivalent graph form: V(G) = E − N + 2P (edges, nodes, connected components; P = 1 for one function).

V(G) < 4 means D ≤ 2. A `switch` with three cases is already V(G) = 4.

## Enforce

The gate is a command that exits non-zero when any function has V(G) > 3. It runs where the project's other checks run: the lint script, pre-commit, or CI. The tool count wins over the hand count, because tools also count language-specific constructs. Every tool flags V(G) above its max, so max is 3.

- ESLint: `"complexity": ["error", 3]` in the config; the lint script is the gate.
- Ruff: `select = ["C901"]` with `[lint.mccabe] max-complexity = 3`; `ruff check` is the gate.
- Other languages: add `lizard -C 3 <src>` (run with `uvx lizard`) to the project's check script. It exits 1 when any function has CCN > 3.

A gate is done when a probe function with V(G) = 4 makes it exit non-zero. Add the probe, run the gate, read the exit code, delete the probe.

## Reduce

- **Guard clause**: return early on edge cases and validations to flatten nested `if`/`else`.
- **Extraction**: move conditional logic or a loop body to a function that names one domain rule.
- **Pure function**: make the extracted function depend on its inputs only, so each of its paths needs no setup to test.
- **Lookup table or polymorphism**: replace a `switch` or a long `if`/`else` chain with a map from key to value or function, or with one class per case.
- **Declarative pipeline**: replace a loop that branches with `map`, `filter`, `reduce` when it reads clearer at equal performance.

## Worked example

Before: D = 4, V(G) = 5.

```javascript
function applyDiscount(amount, customer, isFrequent) {
    if (amount <= 0) {                        // +1
        return 0;
    }
    let rate = 0;
    if (isFrequent && amount > 100) {         // +1 if, +1 &&
        rate = 0.15;
    } else if (customer.hasCoupon) {          // +1
        rate = 0.05;
    }
    return amount * (1 - rate);
}
```

After: each function names one domain rule. V(G) = 2, 3, 2.

```javascript
const FREQUENT_RATE = 0.15;
const COUPON_RATE = 0.05;

const qualifiesAsFrequent = (amount, isFrequent) => isFrequent && amount > 100;    // V = 2

function discountRate(amount, customer, isFrequent) {
    if (qualifiesAsFrequent(amount, isFrequent)) return FREQUENT_RATE;             // +1
    if (customer.hasCoupon) return COUPON_RATE;                                    // +1
    return 0;
}                                                                                  // V = 3

function applyDiscount(amount, customer, isFrequent) {
    if (amount <= 0) return 0;                                                     // +1
    return amount * (1 - discountRate(amount, customer, isFrequent));
}                                                                                  // V = 2
```
