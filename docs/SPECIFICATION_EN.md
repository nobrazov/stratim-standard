# Stratim 0.1 — Technical Specification

**Status:** Stable Release 0.1  
**Publication Date:** 2026-04-10  
**Licensing:**  
- Parser Code: GNU GPL v3  
- Documentation: GNU FDL 1.3  
- Commercial/Proprietary Use: Commercial License (70 CNY Ind. / 700 CNY Corp.)  
- Warranties: AS IS (Disclaimer always applies)

---

## 1. Introduction

Stratim is a text-based book structure format built on the principle of **sequential descriptors**. It replaces the verbosity of FictionBook 2 (XML) and eliminates Markdown ambiguity by providing a deterministic parsing model, explicit stack-based nesting, and strict separation between structure and content.

### Philosophy
1. **Determinism:** One command → one predictable result. No parser guessing.
2. **Explicit Structure:** Hierarchy managed via stack and `^`/`v` modifiers.
3. **Separation of Concerns:** Structure is defined by `~` commands; formatting is isolated in `:::` descriptors.
4. **Natural Flow:** `\n` separates paragraphs, whitespace is normalized, indentation does not affect logic.

---

## 2. Metadata

Metadata is defined exclusively via `~` commands at the beginning of the file. No JSON/YAML frontmatter. The metadata block and the document body are separated by **exactly one empty line** (`\n\n`).

### 2.1 Metadata Command Syntax
```text
~ <symbol> (internal_id) [display_title] @array attributes
```

| Symbol | Purpose | FB2 Equivalent | Attributes / Notes |
|--------|---------|----------------|--------------------|
| `~ i` | Document ID | `<document-info><id>` | `type="isbn\|uuid\|custom"` |
| `~ t` | Book Title | `<title-info><book-title>` | `lang="en"` (opt.) |
| `~ a` | Author / Contributor | `<title-info><author>` | `first`, `mid`, `last`, `role` |
| `~ g` | Genre | `<title-info><genre>` | FB2 2.1 registry value |
| `~ l` | Language | `<title-info><lang>` | BCP 47 / ISO 639-1 |
| `~ d` | Date | `<title-info><date>` | `type="publish\|creation"`, `YYYY-MM-DD` |
| `~ k` | Keywords | `<title-info><keywords>` | Separator `;` or repeated commands |
| `~ n` | Annotation | `<title-info><annotation>` | Allows `:::` descriptors |
| `~ c` | Cover | `<title-info><coverpage>` | `src="path.jpg"`, `alt="..."` |
| `~ s` | Series | `<title-info><sequence>` | `name="..."`, `num="..."` |
| `~ p` | Publisher Info | `<publish-info>` | `name`, `city`, `year`, `isbn` |
| `~ u` | Source | `<document-info><src-url>` | `url`, `owner` |
| `~ x` | Custom Field | `<custom-info>` | Requires `(key)` in `^[a-zA-Z0-9_-]+$` |
| `~ 1`..`~ 9` | Quick Slots | `<custom-info type="N">` | For templates/catalogs |

### 2.2 Rules
- Empty lines inside the metadata block are **forbidden**.
- The first encountered empty line is interpreted **solely** as the separator.
- Required fields: `~ t` and `~ l`. Missing separator → `MISSING_META_SEPARATOR`.
- Repeated commands create arrays in FB2. Duplicate keys in `~ x` → `DUPLICATE_CUSTOM_KEY`.

### 2.3 Example
```text
~ t [Stratim Mechanics]
~ a [Petrov] first="Alexey" mid="Ivanovich" role="author"
~ l en
~ d [2026-04-10] type="publish"
~ x (city) [Moscow]
~ x (version) [0.1]

```
*(Note the empty line after metadata)*

---

## 3. Body Structure

The body starts immediately after the separator. The book title is defined in metadata (`~ t`). Hierarchy is managed via an **explicit node stack**. A new command implicitly closes the previous context.

### 3.1 Body Command Syntax
```text
~ <symbol> [modifier] (internal_id) [display_title] @array attributes
```

| Symbol | Purpose | FB2 Equivalent | Note |
|--------|---------|----------------|------|
| `*` | Title / Root Section | `<section>` | Visual wrapper for title page |
| `#` | Section / Chapter | `<section>` | Main structural block |
| `=` | Poem | `<poem>` | Leaf node, `^` forbidden |
| `|` | Epigraph | `<epigraph>` | Can appear before first chapter |
| `>` | Image / Media | `<image>` | Requires `src="..."` |
| `_` | Section Annotation | `<annotation>` | Leaf node |
| `-` | Visual Separator | `<empty-line/>` | No content |
| `/` | Page Break | `<style>page-break...</style>` | Rendering instruction |
| `f` | Footnote Definition | `<body name="notes">` | Structural node of type `FOOTNOTE` |

**Stack Modifiers:**
- `^` — deepen (child node)
- `v` — rise to parent level
- *empty* — same level (sibling)

**Array Operator `@`:**
- `@key1,key2` — list of metadata keys or anchors.
- Context determined by `type` attribute:
  - `type="fulllist"` → assemble title block from metadata (auto page break).
  - `type="reflist"` → bibliography from anchors (GOST numbering).
  - `type="notelist"` → notes from anchors (assembly in `<body name="notes">`).

### 3.2 Stack Logic
- `~ # ^` → nested section (depth +1)
- `~ #` → section at same level
- `~ # v` → return to parent level (depth -1)
- Maximum stack depth: `15` levels.

### 3.3 Structure Example
```text
~ * (title_page) [Title Page] @a,t,city type="fulllist"

~ # (ch1) [Chapter 1. Principles]
Chapter text.
~ # ^ (sec1) [Section 1.1]
Nested text.
~ # v
~ # (sec2) [Section 1.2]
Sibling section.
```

---

## 4. Text Processing

### 4.1 Normalization & Paragraphs
- **Whitespace:** All sequences of spaces/tabs are reduced to a single space `0x20`. Leading indentation is ignored.
- **Newline `\n`:** Separates paragraphs → `<p>...</p><p>...</p>`.
- **Empty line in body:** → `<empty-line/>`.
- **Text outside commands:** Before metadata or after separator without command → `ORPHAN_TEXT` error.

### 4.2 Native Lists
Lists are determined by **lexical prefix**. Indentation does not affect structure.

**Numbered:**
```text
1. Level 0 Item
1.1. Level 1 Item
1.2. Level 1 Item
2. Level 0 Item (sibling to "1.")
2.1.5. Deep Level 2 Item
```
**Depth Algorithm:** `Depth = (segments in number) - 1`.
- `1.` → 1 segment → Depth 0
- `1.1.` → 2 segments → Depth 1
- Parser automatically closes open levels when depth decreases.

**Unnumbered:**
```text
- Marker A (always Depth 0 in v0.1)
- Marker B
```

**Termination:** Empty line, `~` command, or text without prefix.

---

## 5. Formatting Descriptors (`:::`)

Formatting is considered an **anomaly** and allowed only inside text content.
```text
::: TAG content :::
```

| Tag | Purpose | FB2 Mapping |
|-----|---------|-------------|
| `D` | Drop Cap | `<span class="drop-cap">` |
| `E` | Italic | `<emphasis>` |
| `S` | Bold | `<strong>` |
| `U` | Underline | `<underline>` |
| `K` | Strikethrough | `<strikethrough>` |
| `C` | Code | `<code>` |
| `Q` | Inline Quote | `<emphasis type="cite">` |
| `F` | Footnote Link | `<a epub:type="noteref">` |
| `N` | Sidebar Note | `<annotation>` |
| `W` | Non-breaking Hyphen | `&#8209;` |
| `R` | Raw Text | `<p xml:space="preserve">` |

**Rules:**
- **Nesting Limit:** Strictly ≤3 levels. Exceeding → `NESTING_OVERFLOW`.
- Markdown parsing is disabled inside `:::`. Empty lines preserve as `<empty-line/>`.
- **Anomalous Code:** `::: C \lang <module>\ ... :::` switches lexer to `RAW_CODE` mode (normalization off, spaces and `\n` preserved literally). `<module>` validated against `^[a-zA-Z0-9_]+$`.

---

## 6. Variables & Substitution

The `(* key)` operator resolves in body text flow.
```text
Book «(* t)». Author: (* a). Status: (* 1).
```

**Resolution Rules:**
1. **Key:** Standard symbol (`t`, `l`, `a`, `g`, `d`), digit `1`..`9`, or key from `~ x`.
2. **Auto-format:** `(* a)` automatically formats as `Last F.M.` (joining all authors with `, `).
3. **Order:** Resolution occurs **after** AST build, **before** XML escaping.
4. **Recursion:** Forbidden. `(* (* t) )` → `RECURSIVE_VAR`.
5. **Fallback:** Key not found → `WARNING: UNRESOLVED_KEY`, literal `(* key)` output.
6. **Scope:** Usage outside text flow (in `~` commands or `:::`) → `VAR_IN_STRUCTURE`.

---

## 7. Links & Footnotes

### 7.1 Universal Link Syntax
```text
#text[id]
```
| Element | Description |
|---------|-------------|
| `#` | Inline link marker (text flow only) |
| `text` | Display text. Any UTF-8 until `[`. |
| `[id]` | Target anchor. Must exist as `(internal_id)` in tree. |

**Example:** `See #Chapter One[ch1] and #source[bib01].`

### 7.2 Footnote Mechanism
A footnote is a specialized link type determined by the structural command that creates the anchor.

1. **Link in text:** `#text[id]` or `#[1][fn1]`
2. **Definition:** `~ f (id) [footnote content with ::: formatting :::]`
3. **Parser Handling:**
   - All `~ f` nodes flagged as `TYPE_FOOTNOTE`.
   - Links to these nodes wrapped in `<sup>` during serialization.
   - All definitions automatically collected into `<body name="notes">`.
   - Backlinks `l:href="#src_id"` generated.
   - Sequential numbering `[1]`, `[2]`... formed by order of appearance.

**Example:**
```text
Quantum entanglement described in #1935[fn_epr].

~ f (fn_epr) [EPR paradox first described in Einstein, Podolsky, Rosen paper (1935).]
```

---

## 8. Validation & Conformance

Document is valid if:
1. ✅ Empty line separator exists after metadata.
2. ✅ All `(internal_id)` are unique within file.
3. ✅ `:::` nesting depth does not exceed 3.
4. ✅ Only reserved command symbols are used.
5. ✅ Stack nesting complies with `^`/`v` rules (max 15).
6. ✅ Required metadata `~ t` and `~ l` are present.
7. ✅ No recursion in `(* key)` operators.
8. ✅ All anchors in `@` for `reflist`/`notelist` and `#text[id]` exist in AST.

**Error Codes:** `MISSING_META_SEPARATOR`, `DUPLICATE_ID`, `NESTING_OVERFLOW`, `UNKNOWN_COMMAND`, `DEPTH_OVERFLOW`, `MISSING_REQUIRED_META`, `RECURSIVE_VAR`, `BROKEN_REFERENCE`, `TYPE_MISMATCH_LINK`.

---

## 9. FictionBook 2.1 Mapping

| Stratim Construction | FB2 2.1 Equivalent |
|----------------------|--------------------|
| `~ t [Title]` | `<title-info><book-title>Title</book-title>` |
| `~ a [Last] first="F"` | `<title-info><author><first-name>F</first-name><last-name>Last</last-name></author>` |
| `~ x (key) [val]` | `<custom-info type="x" info-type="key" info="val"/>` |
| `~ # (id) [T] @a,t type="fulllist"` | `<section id="id"><title><p>T</p></title><p align="center">Author</p><empty-line/><p align="center">Title</p></section>` + `<style>page-break-before: always</style>` |
| `~ # ^` | Nested `<section>` |
| `~ = (id)` | `<poem><title><p>id</p></title><stanza>...</stanza></poem>` |
| `~ | (id)` | `<epigraph><p>...</p></epigraph>` |
| `~ > src="..." alt="..."` | `<image l:href="..." description="..."/>` |
| `~ -` | `<empty-line/>` |
| `~ /` | `<style>page-break-before: always</style>` |
| `#text[fn_id]` (where `fn_id` defined via `~ f`) | `<sup><a l:href="#fn_id" type="note">text</a></sup>` |
| `~ f (fn_id) [Content]` | `<body name="notes"><section><p><a name="fn_id"/><a l:href="#src_fn_id">[N]</a> Content</p></section></body>` |
| `::: E text :::` | `<emphasis>text</emphasis>` |
| `::: S text :::` | `<strong>text</strong>` |
| `::: C \lang d\ code` | `<code class="stratim-lang-d" xml:space="preserve">code</code>` |
| `::: R text` | `<p xml:space="preserve">text</p>` |
| `(* a)` | Auto-joined authors `Last F.M.` |

---

## 10. Versioning

Format follows **Semantic Versioning (SemVer 2.0.0)**.
- `0.1` denotes initial stable specification.
- Backward compatibility of command syntax guaranteed within major version (`1.x.x`).
- Changes breaking parsing logic or AST structure released as major versions (`2.0.0`).
- Patch versions (`0.1.1`) used for validation fixes, mapping clarifications, and parser optimizations without syntax changes.

---

© 2026 Stratim Project. All rights reserved.  
Documentation distributed under GNU FDL 1.3. Parser source code under GNU GPL v3.