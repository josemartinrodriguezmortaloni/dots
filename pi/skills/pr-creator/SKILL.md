---
name: pr-creator
description: Use when writing or editing a pull request title or body.
---

Don't write essays, don't include that you ran tests. Rather, write a concise body. Focus on mermaid codeblock diagrams, code samples/snippets (this can be internals, or even sample usage). Use bullet points for the text you do write. 'validation/i ran tests' is not needed

- For visual changes (either directly or indirectly) show a table of before and after with uploaded images/videos.
- For benchmarks, always show tables of before/after (baseline from target branch, candidate from the PR)
- Don't at intermidate PR details - e.g. if we reduced PR size from +6k lines to +1k lines, dont even mention it lol. if we refactored from one commit to another it doesnt matter. only the final aggregate squash merge commit is what matters for commentary
- For truely impressive, difficult, or high risk/wide scoped changes you might write the body like a technical blog (again with context, storytelling, code samples/before/after etc diagrams, images whatever.
- Feel free to use code refs
- Never put yourself as co-author
