# Stratim — Text Format for E-Books

**A clean text format for structured e-books. Simpler than XML, more powerful than Markdown.**

---

## 🌐 Language / Язык

- 🇬 [English Documentation](OVERVIEW_EN.md)
- 🇷🇺 [Русская документация](OVERVIEW_RU.md)

---

## ✨ Why Stratim?

| Problem | Stratim Solution |
|---------|------------------|
| XML verbosity (FB2) | Clean text syntax with `~` commands |
| Markdown ambiguity | Deterministic parsing, no heuristics |
| Complex nesting | Explicit stack with `^`/`v` modifiers |
| No native metadata | Built-in `~ t`, `~ a`, `~ l` commands |

---

## 🚀 Quick Start

### 1. Install Parser
```bash
git clone https://github.com/nobrazov/stratim-standard.git
cd stratim-standard/reference-parser
dub build --build=release
```

### 2. Create Your First Book
Create `book.stratim`:
```stratim
~ t [My Book Title]
~ a [Author Name] first="First"
~ l en

~ * (title) [Title Page] @a,t type="fulllist"

~ # (ch1) [Chapter 1]
Welcome to ::: E Stratim ::: — the future of book formatting.

1. First point
2. Second point
2.1. Nested detail

See #Appendix[appendix] for more.

~ f (appendix) [Additional materials with ::: S bold ::: text.]
```

### 3. Convert to FB2
```bash
./stratim book.stratim book.fb2
```

Open `book.fb2` in Calibre, FBReader, or Okular.

---

## 📚 Documentation

| Resource | Description |
|----------|-------------|
| [Overview (EN)](OVERVIEW_EN.md) | Quick introduction to Stratim |
| [Overview (RU)](OVERVIEW_RU.md) | Быстрое введение в Stratim |
| [Specification (EN)](SPECIFICATION_EN.md) | Complete technical reference |
| [Specification (RU)](SPECIFICATION_RU.md) | Полное техническое описание |
| [GitHub Repository](https://github.com/nobrazov/stratim-standard) | Source code and examples |

---

## 🔑 Key Features

### ✅ Metadata & Assembly
Native metadata without JSON/YAML:
```stratim
~ t [Book Title]
~ a [Last Name] first="First"
~ l ru
~ x (city) [Moscow]

~ * (title) [Title] @a,t,city type="fulllist"
```

### ✅ Inline Formatting
```stratim
Text with ::: E italic :::, ::: S bold :::, 
and ::: Q "quotes" ::: formatting.
```

### ✅ Links & Footnotes
```stratim
See #this section[ch1] and #footnote[fn1^].

~ f (fn1) [Footnote content here.]
```

### ✅ Native Lists
```stratim
1. Level 0 item
1.1. Nested item
2. Another level 0
- Bullet point
```

---

## 📦 Project Status

**Version:** `0.1-alpha` (2026-04-10)

| Feature | Status |
|---------|--------|
| Core syntax (`~` commands) | ✅ Stable |
| Metadata & assembly | ✅ Stable |
| Inline links & footnotes | ✅ Stable |
| Formatting descriptors | ✅ Stable |
| Lists | 🟡 Alpha (text only) |
| Nesting `^`/`v` | 🟡 Alpha (basic) |
| Images | 🔜 Planned (v0.1-beta) |
| RefList/Notelist | 🔜 Planned (v0.1-beta) |

---

## 📄 License

- **Parser Code:** [GPL v3](https://github.com/nobrazov/stratim-standard/blob/main/LICENSE)
- **Documentation:** [GNU FDL 1.3](https://github.com/nobrazov/stratim-standard/blob/main/LICENSE-docs)
- **Commercial Use:** [Commercial License](https://github.com/nobrazov/stratim-standard/blob/main/LICENSE-COMMERCIAL)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

---

**Stratim Project** — Deterministic book structure for the digital age.  
© 2026 Stratim Project. All rights reserved.