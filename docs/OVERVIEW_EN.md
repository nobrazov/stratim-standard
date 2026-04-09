# Stratim — Standard Overview

## What is Stratim?

Stratim is a modern text format for authoring and structuring e-books. It was created as a direct alternative to FictionBook 2 (FB2) and Markdown, addressing their fundamental limitations:

### Problems Stratim Solves

| Format | Problem | Stratim Solution |
|--------|---------|------------------|
| **FictionBook 2** | XML verbosity, hard to edit manually | Text syntax with `~` commands |
| **Markdown** | Ambiguity, parsing heuristics | Deterministic sequential descriptors |
| **Both** | Complex nesting, implicit rules | Explicit stack with `^`/`v` modifiers |

## Philosophy

### 1. Sequential over Nested
The document is read linearly. Each new `~` command implicitly closes the previous context.

```stratim
~ # (ch1) [Chapter 1]
Chapter text
~ # (ch2) [Chapter 2]  ← ch1 auto-closed
```

### 2. Native Metadata
No JSON or YAML. All fields use `~` commands.

```stratim
~ t [Book Title]
~ a [Last] first="First"
~ l en
```

### 3. Block Separator
**Exactly one empty line** separates metadata from body.

```stratim
~ t [Book]
~ l en

~ # (ch1) [Chapter]  ← empty line required
```

### 4. Formatting as Anomaly
`:::` markup allowed only in content, max 3 nesting levels.

```stratim
::: E italic ::: and ::: S bold :::
```

### 5. Natural Text Flow
- `\n` → new paragraph `<p>`
- Empty line → `<empty-line/>`
- Whitespace normalized (multiple → single)

## Key Features

### 📋 Metadata & Block Assembly

```stratim
~ t [Stratim Mechanics]
~ a [Petrov] first="Alexey"
~ x (city) [Moscow]
~ x (year) [2026]

~ * (title) [Title Page] @a,t,city,year type="fulllist"
```

**Result:** Auto-assembled centered title block with page break.

### 🔗 Universal Links

```stratim
See #Chapter One[ch1] and #Appendix[appendix].
```

### 📝 Footnotes

```stratim
Quantum entanglement described in #1935[fn_epr].

~ f (fn_epr) [EPR paradox, 1935.]
```

**Automation:**
- Sequential numbering `[1]`, `[2]`...
- Assembly in `<body name="notes">`
- Backlinks

### 📊 Native Lists

```stratim
1. Level 0 item
1.1. Nested item
1.2. Another nested
2. Next level 0 item
```

**Determinism:** Depth = segments count - 1. Indentation ignored.

### 🎨 Formatting

| Tag | Purpose | Example |
|-----|---------|---------|
| `D` | Drop cap | `::: D F irst :::` |
| `E` | Italic | `::: E important :::` |
| `S` | Bold | `::: S key :::` |
| `C` | Code | `::: C \lang d\ code :::` |
| `R` | Raw text | `::: R preserve spaces :::` |

### 🔀 Nesting Control

```stratim
~ # (ch1) [Chapter 1]
~ # ^ (sec1) [Section 1.1]  ← deepen
~ # ^ (sec1_1) [Subsection] ← deeper
~ # v                        ← rise up
~ # (sec2) [Section 1.2]    ← same level
```

## Licensing

### Open Use
- **Parser code:** GNU GPL v3
- **Documentation:** GNU FDL 1.3
- **Cost:** Free

### Commercial Use
For proprietary software integration:
- **Individuals:** 70 CNY
- **Organizations:** 700 CNY
- **License:** [LICENSE-COMMERCIAL](../LICENSE-COMMERCIAL)

### Disclaimer
**AS IS** clause always applies — software provided "as is", without warranties.

## Quick Start

### 1. Installation
```bash
git clone https://github.com/YOUR_USERNAME/stratim-standard.git
cd stratim-standard/reference-parser
dub build --build=release
```

### 2. Create a Book
Create `book.stratim`:
```stratim
~ t [My Book]
~ a [Author] first="Name"
~ l en

~ * (title) [Title] @a,t type="fulllist"

~ # (ch1) [Chapter 1]
Text with ::: E emphasis ::: and #link[fn1].

~ f (fn1) [Note.]
```

### 3. Convert
```bash
./stratim book.stratim book.fb2
```

## Resources

- 🌐 [Full Specification (EN)](SPECIFICATION_EN.md)
- 🇷 [Полная спецификация (RU)](SPECIFICATION_RU.md)
- 💻 [Parser Source](../reference-parser/)
- 🧪 [Test Suite](../test-suite/)
- 📝 [Book Examples](../examples/)

---

**Stratim 0.1** — Deterministic structure for digital books.  
© 2026 Stratim Project.