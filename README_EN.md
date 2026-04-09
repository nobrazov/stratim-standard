# Stratim 0.1 — Deterministic Book Format

![Stratim Logo](docs/assets/logo.png)

**A standard for describing e-book structures using sequential descriptors.**

Stratim replaces the verbosity of FictionBook 2 and eliminates Markdown ambiguity by providing:
- ✅ Deterministic syntax without heuristics
- ✅ Native metadata (no JSON/YAML)
- ✅ Explicit hierarchy control via stack
- ✅ Automatic title block assembly
- ✅ Universal links & footnotes
- ✅ Licenses: GPL v3 / FDL 1.3 / Commercial (70/700 CNY)

## 📚 Documentation

| Language | Overview | Specification |
|----------|----------|---------------|
| 🇷🇺 Russian | [Overview](docs/OVERVIEW_RU.md) | [Specification](docs/SPECIFICATION_RU.md) |
| 🌐 English | [Overview](docs/OVERVIEW_EN.md) | [Specification](docs/SPECIFICATION_EN.md) |

## 🚀 Quick Start

### 1. Install Parser
```bash
git clone https://github.com/YOUR_USERNAME/stratim-standard.git
cd stratim-standard/reference-parser
dub build --build=release
```

### 2. Create a Book
Create a `book.stratim` file:

```stratim
~ t [Book Title]
~ a [Last] first="First"
~ l en
~ x (city) [London]

~ * (title) [Title Page] @a,t,city type="fulllist"

~ # (ch1) [Chapter 1]
Chapter text. See #details[appendix].

1. First item
1.1. Nested item
2. Second item

~ f (appendix) [Additional materials with ::: E italics :::]
```

### 3. Convert
```bash
./stratim ../book.stratim book.fb2
```

## ⚖️ Licensing

| Usage | License | Cost |
|-------|---------|------|
| Open Source / Non-Commercial | GPL v3 (Code) / FDL 1.3 (Docs) | Free |
| Commercial / Proprietary | [Commercial License](LICENSE-COMMERCIAL) | 70 CNY (Ind.) / 700 CNY (Corp.) |
| All Cases | [AS IS](LICENSE-AS-IS) (No Warranty) | Included |

## 📦 Repository Structure

```
stratim-standard/
├── docs/                    # Documentation (RU/EN)
│   ├── assets/
│   │   └── logo.png        # Official logo
│   ├── SPECIFICATION_RU.md
│   ├── SPECIFICATION_EN.md
│   ├── OVERVIEW_RU.md
│   └── OVERVIEW_EN.md
├── reference-parser/        # Official parser (D)
│   ├── source/stratim/
│   │   ├── lexer.d
│   │   ├── parser.d
│   │   ├── validator.d
│   │   └── fb2gen.d
│   ├── dub.json
│   └── README.md
├── test-suite/              # Test examples
├── examples/                # Book examples
├── LICENSE                  # GNU GPL v3
├── LICENSE-docs             # GNU FDL 1.3
├── LICENSE-COMMERCIAL       # Commercial license
├── LICENSE-AS-IS            # Disclaimer
├── README_RU.md             # Russian README
├── README_EN.md             # English README
└── .gitignore
```

## 🧪 Testing

```bash
cd test-suite
../reference-parser/stratim t01_basic.stratim out.fb2
# Compare out.fb2 with expected output
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing'`)
4. Push (`git push origin feature/amazing`)
5. Open a Pull Request

## 📜 Versioning

Semantic Versioning 2.0.0. `0.1` is the initial stable release. Backward compatibility of command syntax is guaranteed within a major version.

---

**Stratim 0.1** — Deterministic book structure for the digital age.  
© 2026 Stratim Project. All rights reserved.