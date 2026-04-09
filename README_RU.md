# Stratim 0.1 — Deterministic Book Format

![Stratim Logo](docs/assets/logo.png)

**Стандарт описания структуры электронных книг на основе последовательных дескрипторов**

Stratim заменяет XML-многословие FictionBook 2 и устраняет неоднозначность Markdown, предоставляя:
- ✅ Детерминированный синтаксис без эвристик
- ✅ Нативные метаданные (без JSON/YAML)
- ✅ Явное управление вложенностью через стек
- ✅ Автоматическую сборку титульных блоков
- ✅ Универсальные ссылки и сноски
- ✅ Лицензии: GPL v3 / FDL 1.3 / Commercial (70/700 CNY)

## 📚 Документация

| Язык | Обзор | Спецификация |
|------|-------|--------------|
| 🇷 Русский | [Overview](docs/OVERVIEW_RU.md) | [Specification](docs/SPECIFICATION_RU.md) |
| 🌐 English | [Overview](docs/OVERVIEW_EN.md) | [Specification](docs/SPECIFICATION_EN.md) |

## 🚀 Быстрый старт

### 1. Установка парсера
```bash
git clone https://github.com/YOUR_USERNAME/stratim-standard.git
cd stratim-standard/reference-parser
dub build --build=release
```

### 2. Создание книги
Создайте файл `book.stratim`:

```stratim
~ t [Название книги]
~ a [Фамилия] first="Имя"
~ l ru
~ x (city) [Москва]

~ * (title) [Титул] @a,t,city type="fulllist"

~ # (ch1) [Глава 1]
Текст главы. См. #подробности[appendix].

1. Первый пункт
1.1. Вложенный пункт
2. Второй пункт

~ f (appendix) [Дополнительные материалы с ::: E курсивом :::]
```

### 3. Конвертация
```bash
./stratim ../book.stratim book.fb2
```

## ⚖️ Лицензирование

| Использование | Лицензия | Стоимость |
|---------------|----------|-----------|
| Открытое / Некоммерческое | GPL v3 (код) / FDL 1.3 (док-ция) | Бесплатно |
| Коммерческое / Проприетарное | [Commercial License](LICENSE-COMMERCIAL) | 70 CNY (физ.) / 700 CNY (юр.) |
| Все случаи | [AS IS](LICENSE-AS-IS) (отказ от гарантий) | Включено |

## 📦 Структура репозитория

```
stratim-standard/
├── docs/                    # Документация (RU/EN)
│   ├── assets/
│   │   └── logo.png        # Официальный логотип
│   ├── SPECIFICATION_RU.md
│   ├── SPECIFICATION_EN.md
│   ├── OVERVIEW_RU.md
│   └── OVERVIEW_EN.md
├── reference-parser/        # Официальный парсер (D)
│   ├── source/stratim/
│   │   ├── lexer.d
│   │   ├── parser.d
│   │   ├── validator.d
│   │   └── fb2gen.d
│   ├── dub.json
│   └── README.md
├── test-suite/              # Тестовые примеры
│   ├── t01_basic.stratim
│   ├── t02_assembly.stratim
│   └── t03_footnotes.stratim
├── examples/                # Примеры книг
├── LICENSE                  # GNU GPL v3
├── LICENSE-docs             # GNU FDL 1.3
├── LICENSE-COMMERCIAL       # Коммерческая лицензия
├── LICENSE-AS-IS            # Отказ от ответственности
├── README.md
└── .gitignore
```

## 🧪 Тестирование

```bash
cd test-suite
../reference-parser/stratim t01_basic.stratim out.fb2
# Сравните out.fb2 с ожидаемым результатом
```

## 🤝 Contributing

1. Fork репозиторий
2. Создайте ветку (`git checkout -b feature/amazing`)
3. Закоммитьте изменения (`git commit -m 'Add amazing'`)
4. Push (`git push origin feature/amazing`)
5. Откройте Pull Request

## 📜 Versioning

Semantic Versioning 2.0.0. `0.1` — начальный стабильный релиз. Обратная совместимость синтаксиса команд гарантируется в пределах мажорной версии.

---

**Stratim 0.1** — Детерминированная структура книг для цифровой эпохи.  
© 2026 Stratim Project. All rights reserved.