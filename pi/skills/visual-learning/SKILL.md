---
name: visual-learning
description: Build an interactive textbook as a single HTML page (nested tooltips, expandable readings, interactive widgets) from a source document, written in ASD-STE100 in the user's language (default Spanish). Use when the user asks to turn a text, paper, or chapter into an interactive textbook.
---

# Visual learning

The product is one self-contained HTML page that teaches one source document. It has no project, no package manager, and no build step. Speed comes from four rules:

- **Ready runtime.** The tooltip runtime, the CSS, and the assembler already exist in `assets/` in this skill's directory. Agents write only content.
- **Fixed contract.** The markup contract below never changes, so all writers start at the same time.
- **Content is data.** Tooltips are `<template>` records, not code.
- **Bounded loop.** The concept loop runs exactly two rounds. It never iterates "until no unknown concepts remain".

## Inputs

- **Source document**: text, figures, footnotes, references.
- **Output language**: the language the user names. Default: Spanish. File names, concept ids, and widget names stay in English.
- **Audience**: a curious first-year university student of the subject, with only high-school background in it. If the user gives a knowledge level or an exclusion list (concepts the student already knows), use it. Drop exclusion entries unrelated to the subject before you pass the list to subagents.

## Writing standard: ASD-STE100

Every visible string follows ASD-STE100: main body, tooltips, expanded readings, captions, widget labels. The STE dictionary is English-only. In Spanish, apply the same rules, and use the most common literal word for each meaning.

- One word has one meaning, and one meaning has one word. Keep the same term for a concept everywhere.
- Technical names (the subject's terms of art) are allowed. Give each one a tooltip at its first use in a section.
- Sentences: descriptive, max 25 words; procedural, max 20 words. One topic per sentence.
- Paragraphs: one topic, max 6 sentences. Key information first.
- Active voice. Simple tenses: present, past, future. In Spanish, use the indicative mood, and prefer active voice to passive "se" constructions.
- In English, no "-ing" forms, except in technical names. In Spanish, no gerunds, except in technical names.
- Noun clusters: max 3 words. Keep articles and connecting words.
- Use vertical lists for sequences, conditions, and parallel items.

**Faithfulness.** The main body rewrites the source prose in STE. It keeps every fact, claim, number, equation, footnote, reference, figure, and the section order. It adds and drops no claims. New explanations go only into tooltips and expanded readings.

## Markup contract

Paths are relative to the output directory `<slug>/`. Each worker writes only its own files in `parts/`, so all workers run in parallel without conflicts.

| Element | Contract |
| --- | --- |
| Section | `parts/sections/NN-slug.html`: one `<section id="NN-slug">` with an `<h2>`. |
| Concept link | `<span data-c="kebab-id">term</span>`: opens a nested tooltip. |
| Expanded reading | `<details class="expand"><summary>Title</summary>…</details>`. |
| Figure | `<figure><img src="figures/x.png" alt="..."><figcaption>…</figcaption></figure>`. Copy the original file to `figures/`. The build embeds it in the page. |
| Math | `\( … \)` inline, `\[ … \]` display (MathJax). Write `<`, `>`, `&` inside TeX as `&lt;`, `&gt;`, `&amp;`. |
| Concept record | `parts/concepts/<batch>.html`: one `<template data-concept="kebab-id" data-title="Title">body</template>` per concept. |
| Widget slot | `<div data-widget="name"></div>`, in a section, an expanded reading, or a concept record. |
| Widget code | `parts/widgets/<file>.js`: `W["name"] = (root) => { … }`. The function builds DOM or SVG inside `root`, with plain JavaScript and inline styles. No imports, max 120 lines. Prefix each name with the file stem, so names stay unique. |

## Workflow

1. **Plan (inline).** Read the source. Split it by top-level heading. Choose the slug, the page title, the output language, and the exclusion list. Create `<slug>/parts/{sections,concepts,widgets}` and `<slug>/figures/`, and copy the original figures. Complete when each heading has a target section file.
2. **Write sections (parallel, one message).** Launch one section writer per top-level heading. Paste in "Writing standard", "Markup contract", "Widgets", and the section's source text. The writer links a concept with `data-c` at its first use in the section, if the concept is not in the exclusion list. Complete when the section file exists and the writer returns its concept list: `{ id, term, gloss }`, with a one-line gloss.
3. **Concepts round 1 (parallel).** Merge the concept lists, deduplicate by id, and map synonyms to one id. Split the ids into batches of max 8 concepts. Launch one worker per batch, all in the same message. In the same message, launch one reviewer per section (see "Review"). A concept worker writes one `parts/concepts/<batch>.html`. Each tooltip body has max 120 words, in STE. It can link other concepts with `data-c`. Complete when the worker returns the new ids it linked that are not yet in the registry.
4. **Concepts round 2 (parallel, last round).** Batch the new ids from round 1 the same way. These tooltips are terminal: they link only ids that already exist, and add no new ids. If a term has no record, write it as plain text.
5. **Build and gate.** Run:

   ```sh
   node <skill-dir>/assets/build.mjs <slug> --lang es --title "Page title"
   ```

   The script checks every concept link, widget slot, figure, and widget syntax, then writes `<slug>/index.html`. When it exits 1, fix each listed failure in `parts/` and run it again. Complete when it prints `OK`. Report the path to `index.html`.

Pass the "Writing standard" section and the exclusion list to every content worker and reviewer.

## Review

One reviewer per section runs during round 1, in parallel with the concept workers. The reviewer compares the section file to its source text. Every fact, number, equation, footnote, reference, and figure must be present, and every sentence must follow STE. The reviewer fixes the section file in place. It edits no other file. Complete when the section passes both checks.

## Widgets

A widget shows a gears-level model: a mechanism with a variable that the student changes to see the effect. See also: <https://www.lesswrong.com/posts/B7P97C27rvHPz3s9B/gears-in-understanding>

- After each original figure, add an expanded reading with a widget that extends the figure.
- After a paragraph that introduces a gears-level model, add an expanded reading with a widget for that model.
- In a tooltip, add a widget only if the concept is a gears-level model. Max one widget per tooltip.

## Runtime

`assets/runtime.js`, `assets/page.css`, and `assets/build.mjs` are fixed. Content workers never edit them. To change the tooltip behaviour, read `assets/tooltip-ux.md` first.

Future: analytics, quizzes
