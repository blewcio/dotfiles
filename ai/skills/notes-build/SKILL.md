---
name: notes-build
description: Turn raw lecture material (AI-generated video/course summaries you paste in, slide decks, textbook excerpts) into structured, example-rich study notes — Key Concepts, Examples, Notes, and Key Learnings per section, plus a Table of Contents and a course Glossary. Use when building a course/lecture notes document from source material, extending one with more lectures, supplementing it from slide decks, or reviewing it for consistency and completeness.
compatibility: opencode
---

# Learning Notes — build and maintain course study notes

Workflow for turning raw, messy lecture material into a study-ready notes
document: one video/lecture per section, each with a consistent
Key Concepts → Examples → Notes → Key Learnings structure, cross-referenced
where concepts recur, and topped off with a Table of Contents and a Glossary.

**Two phases, used at different times:**
- **Building** (Steps 0–5): run once per lecture, as its raw source material
  becomes available. You'll invoke this many times over a session or across
  many sessions as the user works through a course.
- **Finishing** (Steps 6–11): run once most/all sections exist, or any time
  the user asks for a review — consistency, completeness, Key Learnings,
  Table of Contents, Glossary, verification.

Don't assume both phases happen in one sitting. If the user just pastes one
lecture's raw content, do Steps 0–5 for that section and stop — don't
unilaterally run the Finishing steps until asked or until it's clearly the
last section going in.

## Non-goals

Don't fabricate exam content and present it as if it came from the course.
Don't assume you have direct access to Coursera, a video platform, or any
paywalled course content — you don't; the user must paste AI-summary output
or point you at local files (slide decks, transcripts). Don't restructure a
section that's already in good Key Concepts/Examples/Notes shape just to
impose stylistic uniformity. Don't invent numbers, quotes, or named
examples — if source material doesn't give a concrete example for a concept,
either leave it flagged or add a clearly marked illustrative one (Step 7),
never an unmarked one.

## Step 0 — Scope

Confirm the target note file (existing or new) and which lecture(s)/section(s)
are in scope for this invocation. If there's an existing outline (module
headings with empty placeholder sections), work within it rather than
inventing a new structure — ask if the outline looks incomplete or unclear.

Confirm what source material is available for this pass:
- **Type A — pasted AI-summary text** (from Coursera's own AI, ChatGPT, etc.,
  run by the user against the actual video): drives Steps 3–4.
- **Type B — local files** (slide deck PDFs, transcripts, readings): drives
  Step 5.

A lecture can have both; process Type A first (it's usually the backbone),
then layer Type B on top as supplementary Notes content.

## Step 1 — Backup before any edit

Before editing an existing notes file for the first time in a session, copy
the untouched original to a sibling backup:

```
<Note Name>.backup-<YYYY-MM-DD>.md
```

Skip if a backup with today's date already exists — don't overwrite it with
a partially-edited version. This is additive and reversible, so do it
without asking.

## Step 2 — Establish the per-section format

Every lecture section should end up as:

```markdown
## <Lecture Title>

<One-sentence intro: what this lecture covers and why it matters in the arc of the course.>

### Key Concepts

- **<Concept Name>**: <1–3 sentence definition, self-contained enough to understand without the example below.>

### Examples

- **<Example Name>**: <the concrete situation> — illustrates <which concept and how>.

### Notes

<Supplementary material from Step 5: frameworks, exact figures, quotes, diagrams — content that's essential but doesn't fit the Key Concepts/Examples shape.>

### Key Learnings

- <2 bullets, the single most exam-relevant takeaway(s), distilled only from this section's own content.>
```

If the existing document already uses a different but internally consistent
format, match that instead of forcing this one — consistency across the
whole document matters more than matching this template exactly.

## Step 3 — The two standardized source prompts

If the user hasn't already run something against the video, hand them these
two prompts to run wherever they have actual video/transcript access (a tool
you don't have):

> **Prompt 1 — Key Concepts:** "Give me a list and explanation of the main
> concepts from this video. For each concept, provide a bolded name followed
> by a 1-2 sentence explanation."

> **Prompt 2 — Examples:** "Summarize all examples from this video. For each
> example, describe the specific situation/case and what it illustrates or
> the lesson it demonstrates."

These two, run separately, consistently outperform a single blended
"concepts + examples" prompt — the blended version tends to produce prose
that's harder to scan and drops concepts that don't have a paired example.
Don't reinvent this template per lecture; reuse it so raw output arrives in
a consistent, easy-to-merge shape.

## Step 4 — Merge raw prompt output into a section

Given one or more raw prompt outputs for a lecture (possibly several runs —
users sometimes try 3–5 prompt variants before landing on these two):

- Read all the raw output for this lecture before writing anything.
- Pick the most concept-isolating phrasing for Key Concepts (a clean bulleted
  list beats prose that blends concepts together).
- Pick the most concrete phrasing for Examples — a bullet naming a specific
  situation (a company, an experiment, a named case) beats one that just
  restates the paired concept in different words. Dedupe near-identical
  examples across multiple raw outputs; when two versions of the same
  example differ, keep the one with more specific detail, not the first one.
- Write one intro sentence per section, placing it in the arc of the course
  (references earlier/later sections where there's a real throughline —
  don't force false connections).
- Never add content that isn't traceable to the raw output at this step —
  that's what Step 5 and Step 7 are for, and they mark their additions.

## Step 5 — Supplement from slide decks and other local files

For each PDF or other file offered as source material:

- Check page count first; most PDF-reading tools cap out around 20 pages per
  call — read in batches (`pages: "1-20"`, `"21-40"`, ...) rather than
  assuming one call covers the whole deck.
- Extract content that's **essential and missing** from what Step 4 already
  produced — exact figures, direct quotes, named frameworks/models, legal or
  historical anchors, acronym expansions. Don't re-transcribe the whole deck;
  the raw AI summary already covered the narrative.
- **Deciding how to represent a diagram:**
  - A conceptual framework (a flowchart, an org chart, a process model) →
    recreate as a Mermaid diagram (`flowchart TD`, etc.) — cleaner and more
    legible than a cropped screenshot, and it themes correctly.
  - A real photo, an annotated historical image, or an actual data
    curve/graph → extract as an image rather than recreating it, since the
    specific visual *is* the content:
    ```bash
    # Check page count and whether the diagram is an embedded raster image:
    pdfinfo "<deck.pdf>" | grep -i pages
    pdfimages -list -f <page> -l <page> "<deck.pdf>"
    ```
    If `pdfimages -list` shows an embedded image on that page, extract it
    directly:
    ```bash
    pdfimages -j -f <page> -l <page> "<deck.pdf>" /tmp/extract
    ```
    If it shows no embedded image (the diagram is vector-drawn — shapes,
    curves, text boxes), render the whole page instead and crop to the
    diagram:
    ```bash
    pdftoppm -png -r 200 -f <page> -l <page> "<deck.pdf>" /tmp/page
    magick /tmp/page-<page>.png -crop <W>x<H>+<X>+<Y> +repage <output.png>
    ```
    Read the cropped result back before embedding it, to confirm the crop
    box actually captured the diagram cleanly.
  - Save extracted/cropped images into a sibling `attachments/` folder next
    to the notes file, and embed with standard Markdown image syntax:
    `![<alt text>](attachments/<file>)`.
- Append everything from this step to that section's `### Notes`, not into
  Key Concepts/Examples — keep the Step 4 content and the slide-derived
  content visually distinct so it's clear what came from where.
- It's fine for a section's Notes to end up empty if the slides genuinely
  added nothing beyond what Step 4 already captured — don't pad it.
- **Link each source file to the section(s) it feeds.** Right after that
  section's intro sentence (before `### Key Concepts`), add a `**Materials:**`
  line linking every local file used for that section — a module/lecture
  slide deck, a companion worksheet, an assessment template — using an
  Obsidian wikilink with a display alias: `[[<exact filename incl.
  extension>|<short label>]]`. Verify the filename resolves (matches a real
  file in the vault) before writing the link — don't guess at spelling. If a
  source file feeds multiple sections (e.g. a course-wide summary, a shared
  assessment template), link it from each section it actually supports rather
  than picking just one.

## Step 6 — Consistency & completeness pass

Run this across the whole document (or the whole module, if scoped), not
just the section just edited:

- **Every Key Concept needs a concrete Example.** Scan each section: does
  every Key Concept bullet have at least one Example bullet that actually
  illustrates it with a specific situation, not just a reworded restatement
  of the concept sentence? Flag (or fix, per Step 7) any that don't.
- **No contradictions.** The same number, date, or claim shouldn't appear
  two different ways in two places (e.g., an approximate figure in one
  section and a precise one from a slide in another) — reconcile toward the
  more precise/sourced version.
- **No un-cross-referenced duplication.** When the same theory or framework
  gets taught in two different lectures (common when a course revisits a
  concept at increasing depth, or when a case study spans multiple
  lectures), add a one-line pointer between them (`see [[#Other Section]]`)
  rather than leaving them as two disconnected islands a reader might not
  realize are the same idea.
- **Naming consistency — verify against source, don't just pick one.** If a
  name/spelling is inconsistent across sections (a company, a person), check
  the actual source material (slides, not just prior raw AI summaries, which
  can themselves mis-transcribe a spoken name) before standardizing — the
  more authoritative source wins, not the more frequent one.
- **Wikilinks point to headings, not phantom notes.** If this is a
  single-file document using `[[...]]` links for internal navigation, they
  must be `[[#Heading Text]]` (a same-document heading link), not
  `[[Heading Text]]` (which most tools, including Obsidian, resolve as a
  link to a *separate* note of that name — a broken link here). Verify:
  ```bash
  grep -noE '\[\[[^#][^]]*\]\]' "<file>"   # should be empty
  ```
- **Coherence and readability.** Once the mechanical checks above pass, also
  apply the notes-cleanup skill's "Coherence and readability review" (same
  three questions: reads well, logical, consistent) to the whole document —
  it catches the same idea explained several times in different words across
  non-adjacent sections, which the checks above won't.

## Step 7 — Fill genuine example gaps

For any Key Concept still missing a concrete example after Step 6:

- First check whether the source material (raw AI output or slides) actually
  had one that got lost in merging — recover it if so.
- If the source genuinely never provided one, add an illustrative example
  and mark it unmistakably as not from the course:
  ```markdown
  - *Illustrative example (mine, not from the course) — <Concept Name>*: <a plausible, concrete, specific scenario>.
  ```
- Keep it short and concrete (a specific-feeling scenario beats a generic
  one) but don't overstate it as real — no invented company names presented
  as if they were named in the course, no fabricated statistics presented as
  research findings.
- If you're not confident you can write a good illustrative example without
  it reading as a real course example, leave the gap flagged instead of
  forcing one.

## Step 8 — Add Key Learnings

For each section, end with a `### Key Learnings` heading and 2 bullets:

- Distill only from that section's own Key Concepts/Examples/Notes — this
  is a compression pass, not a place to introduce new facts, sources, or
  claims the section didn't already support.
- Phrase each as a standalone, memorable takeaway — the kind of line that
  would actually help on an exam, not a restatement of the section's title.
- Keep the format consistent across every section (same heading, always 2
  bullets, no sub-bullets) so the document reads as one system.

## Step 9 — Document-level pass: Table of Contents, materials summary, and Glossary

**Course materials summary** — place directly under the document's opening
sentence (above the Table of Contents), a single `**Course materials:**` line
linking course-wide files that aren't scoped to one section — an overall
course summary, a works-cited/references file, a personal workbook of
exercise responses, a certificate. Same wikilink-with-alias format as the
per-section links from Step 5. This is the document-level counterpart to the
per-section `**Materials:**` lines — course-wide files go here, section-scoped
files stay on their section.

**Table of Contents** — place near the top, grouped by module/unit, one
linked entry per lecture section:

```markdown
## Table of Contents

**Module 1 — <Module Title>**
- [[#Lecture Title]]
- ...

**Reference**
- [[#Course Glossary — Quick Reference]]
```

**Glossary** — place at the very end, one alphabetized entry per named
theory/model/framework used anywhere in the document, one-line definition,
link back to its home section:

```markdown
# Course Glossary — Quick Reference

- **<Theory Name>**: <one-line definition>. → [[#<Home Section>]]
```

If a concept is taught briefly in one section and in full depth in another
(see Step 6), link the glossary entry to the deep-dive section, and note
the brief mention exists too.

## Step 10 — Verify

- Confirm every `[[#...]]` link target exactly matches a real heading in the
  document. `grep -P` (Perl regex) isn't available on macOS's built-in BSD
  grep — use `-E` instead, which works everywhere:
  ```bash
  grep -oE '\[\[#[^]|]+' "<file>" | sed 's/\[\[#//' | sort -u > /tmp/link_targets.txt
  grep '^## ' "<file>" | sed 's/^## //' | sort -u > /tmp/actual_headings.txt
  comm -23 /tmp/link_targets.txt /tmp/actual_headings.txt   # should be empty
  ```
- Confirm every `**Materials:**` link (Steps 5 and 9) resolves to a real
  file — find each linked filename in the vault and flag any that don't
  match, rather than trusting the spelling used when the link was written.
- Confirm every embedded image path actually exists in the attachments
  folder, and every ```` ```mermaid ```` block has balanced brackets/quotes.
- Confirm every section has exactly one `### Key Concepts`, `### Examples`,
  `### Notes`, and `### Key Learnings` (or the document's equivalent
  headings) in that order, with a blank line before each `##`/`###`.
- Render-test for broken Markdown using the notes-cleanup skill's bundled
  `scripts/verify_markdown.py` (catches unescaped tags, stray non-breaking
  spaces, accidental code blocks) — it lives alongside that skill's own
  SKILL.md, a sibling of this skill's own directory (e.g.
  `~/.claude/skills/notes-cleanup/scripts/verify_markdown.py`; locate the
  exact path via the notes-cleanup skill directory rather than assuming a
  fixed relative path):
  ```bash
  python3 -m venv /tmp/mdtest && /tmp/mdtest/bin/pip install --quiet markdown-it-py
  /tmp/mdtest/bin/python3 <path-to-notes-cleanup-skill>/scripts/verify_markdown.py <file> [<file> ...]
  ```

## Step 11 — Report

Summarize: which section(s) were built or updated this pass, the backup
path, how many Key Learnings were added, how many concept-gaps got a marked
illustrative example (list them — the user may want to swap these for real
examples later after rewatching), and anything left flagged (contradictions
found but not resolved, naming uncertain even after checking source,
sections still missing an example).
