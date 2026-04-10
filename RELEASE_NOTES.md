# Stratim v0.1-alpha (2026-04-10)

Initial public release of the Stratim standard and reference parser.

## ✨ Features

### Core Parser & Generator
- ✅ Reference parser written in D (GDC/LDC2 compatible)
- ✅ FB2 2.1 XML export generator
- ✅ Native metadata commands: `~ t` (title), `~ a` (author), `~ l` (language), `~ d` (date), `~ g` (genre), `~ k` (keywords)
- ✅ Title page assembly: `~ *`
- ✅ Hierarchical sections: `~ #`
- ✅ Footnotes system: `~ f`
- ✅ Inline formatting descriptors: `::: E :::` (emphasis), `::: S :::` (strong), `::: Q :::` (quote), etc.
- ✅ Cross-references & links: `#text[id]`, `#text[id^]`
- ✅ Native list support: numbered (`1.`, `2.1.`) and bulleted (`-`)

### Documentation & Resources
- ✅ Full technical specification (EN/RU)
- ✅ README files (EN/RU)
- ✅ Test suite with example `.stratim` files
- ✅ GitHub Pages documentation site
- ✅ Project presentation article

### Developer Experience
- ✅ GitHub Actions CI/CD pipeline (auto-build & test)
- ✅ GitHub repository syntax highlighting (`.gitattributes`)
- ✅ Sublime Text syntax definition
- ✅ Open licensing: GPL-3.0 (code), GNU FDL 1.3 (docs), Commercial license available

## 🔜 Roadmap (v0.1-beta)
- ⏳ Image support (`~ >`)
- ⏳ RefList & Notelist auto-generation
- ⏳ Advanced nesting modifiers (`^`/`v`)
- ⏳ CSS-based list indentation & styling

## 📦 Installation & Quick Start

```bash
git clone https://github.com/nobrazov/stratim-standard.git
cd stratim-standard/reference-parser
dub build --build=release
./stratim ../test-suite/t01_basic.stratim output.fb2 
