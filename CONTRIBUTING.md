# Contributing to Stratim

Thank you for your interest in the **Stratim** project!

We welcome contributions that help improve the parser, the standard specification, or the documentation. To keep the project deterministic and focused, please follow these guidelines.

## 📜 Before You Start

**Stratim is a specification-based format.** Any change to the parser or syntax must align with the official [Specification](docs/SPECIFICATION_EN.md).

### 1. Check for Existing Issues
Search the [Issues](https://github.com/nobrazov/stratim-standard/issues) and [Pull Requests](https://github.com/nobrazov/stratim-standard/pulls) to see if your topic has already been discussed.

### 2. Open an Issue First (Crucial!)
**Do not submit a Pull Request for a new feature without prior discussion.**
*   Open an [Issue](https://github.com/nobrazov/stratim-standard/issues/new) describing what you want to add or fix.
*   Explain **why** this fits the Stratim philosophy (readability, determinism, FB2 compatibility).
*   Wait for approval or feedback from the maintainers.

*Unsolicited Pull Requests that contradict the specification or project goals may be closed without review.*

## 🛠 Technical Requirements

### Parser Development (D Language)
*   **Language:** The reference parser is written in **D**.
*   **Build System:** We use **Dub**. Ensure your changes compile with `dub build`.
*   **Testing:** All Pull Requests **must pass** the CI checks (GitHub Actions).
    *   You can run tests locally: `cd test-suite && ./run_tests.sh` (or equivalent).
*   **Code Style:** Follow the existing coding style. Use `dformat` or similar tools if unsure, but consistency with the current codebase is priority.

### Specification / Docs
*   Documentation should be clear, concise, and available in both **English** and **Russian** (where applicable).
*   Examples must be valid `.stratim` files that parse successfully.

## 📝 Pull Request Process

1.  **Fork** the repository and create your branch from `main`.
2.  **Code** your changes.
3.  **Test** your changes locally.
4.  **Push** to your fork and submit a Pull Request.
5.  **Describe** your PR clearly:
    *   What problem does it solve?
    *   Link to the related Issue.
    *   Screenshots or examples of the new behavior.

## 🚫 What We Do Not Accept

*   **Breaking changes** without a major version bump proposal.
*   **Refactoring** just for the sake of refactoring (unless it fixes a bug or performance issue).
*   **Syntax changes** that make the format less readable or harder to parse deterministically.
*   **Spam or low-effort PRs.**

## 🤝 Code of Conduct

Be respectful. We are all here to build a better tool for authors. Harassment or toxic behavior will result in being blocked.

## 📄 License

By contributing, you agree that your contributions will be licensed under the project's **GPL v3 License**.

---

Thank you for helping make Stratim better!