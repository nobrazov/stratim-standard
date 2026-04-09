// SPDX-License-Identifier: GPL-3.0-or-later OR Stratim-Commercial-1.0
module stratim.fb2gen;

import stratim.parser;
import std.string;
import std.array;
import std.conv;

class FB2Generator {
    ASTNode root;
    string[string] meta;
    string[] footnotes;
    int fnCounter = 0;

    this(ASTNode r, string[string] m) { root = r; meta = m; }

    string generate() {
        string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
        xml ~= "<FictionBook xmlns=\"http://www.gribuser.ru/xml/fictionbook/2.1\" xmlns:l=\"http://www.w3.org/1999/xlink\">\n";
        xml ~= "<description>" ~ genTitleInfo() ~ "</description>\n";
        xml ~= "<body>\n";
        
        foreach (node; root.children) {
            if (node.isFootnote) {
                collectFootnote(node);
            } else {
                xml ~= buildSection(node, 0);
            }
        }
        
        xml ~= "</body>\n";
        
        if (footnotes.length > 0) {
            xml ~= "<body name=\"notes\">\n";
            foreach (fn; footnotes) xml ~= fn;
            xml ~= "</body>\n";
        }
        
        xml ~= "</FictionBook>";
        return xml;
    }

    string genTitleInfo() {
        string res = "<title-info>\n";
        if ("t" in meta) res ~= "<book-title>" ~ escapeXml(meta["t"]) ~ "</book-title>\n";
        if ("a" in meta) {
            string[] parts = meta["a"].split(" ");
            res ~= "<author>\n";
            if (parts.length >= 2) res ~= "<first-name>" ~ escapeXml(parts[1]) ~ "</first-name>\n";
            res ~= "<last-name>" ~ escapeXml(parts[0]) ~ "</last-name>\n</author>\n";
        }
        if ("l" in meta) res ~= "<lang>" ~ meta["l"] ~ "</lang>\n";
        res ~= "</title-info>\n";
        return res;
    }

    string buildSection(ASTNode n, int depth) {
        string res = "";
        string tag = mapSymbol(n.symbol);
        string idAttr = n.id.length ? " id=\"" ~ escapeXml(n.id) ~ "\"" : "";
        
        // Обработка fulllist (титульная страница)
        bool isFullList = false;
        foreach (attr; n.attrs) { 
            if (attr.indexOf("type=\"fulllist\"") != -1) { 
                isFullList = true; 
                break; 
            } 
        }

        if (isFullList && n.array.length > 0) {
            res ~= "<" ~ tag ~ idAttr ~ ">\n";
            if (n.title.length) res ~= "<title><p>" ~ escapeXml(n.title) ~ "</p></title>\n";
            foreach (key; n.array) {
                if (key in meta) {
                    res ~= "<p align=\"center\">" ~ escapeXml(meta[key]) ~ "</p><empty-line/>\n";
                }
            }
            res ~= "</" ~ tag ~ ">\n";
            return res;
        }

        // Обычный раздел
        res ~= "<" ~ tag ~ idAttr ~ ">\n";
        if (n.title.length) {
            res ~= "<title><p>" ~ escapeXml(n.title) ~ "</p></title>\n";
        }
        res ~= processContent(n.content);
        
        // Рекурсивная обработка детей (для вложенности ^)
        foreach (child; n.children) {
            if (!child.isFootnote) {
                res ~= buildSection(child, depth + 1);
            } else {
                collectFootnote(child);
            }
        }
        
        res ~= "</" ~ tag ~ ">\n";
        return res;
    }

    string processContent(string[] lines) {
        string res = "";
        string currentP = "";
        
        foreach (line; lines) {
            string trimmed = line.strip;
            
            if (trimmed.length == 0) {
                if (currentP.length) { 
                    string resolved = resolvePlaceholders(currentP);
                    res ~= "<p>" ~ resolved ~ "</p>\n"; 
                    currentP = ""; 
                }
                res ~= "<empty-line/>\n";
            } 
            else if (trimmed.length >= 6 && trimmed[0] == '#' && trimmed[1..6] == "LIST:") {
                if (currentP.length) { 
                    string resolved = resolvePlaceholders(currentP);
                    res ~= "<p>" ~ resolved ~ "</p>\n"; 
                    currentP = ""; 
                }
                // Парсим "#LIST:depth:full text here"
                string rest = trimmed[6..$]; // убираем "#LIST:"
                size_t firstColon = rest.indexOf(':');
                if (firstColon != size_t.max && firstColon + 1 < rest.length) {
                    // Пропускаем depth и берём текст после второй :
                    string text = rest[firstColon + 1 .. $].strip;
                    res ~= "<p>" ~ text ~ "</p>\n";  // Просто выводим текст как параграф
                    // В будущем можно добавить CSS класс для отступа
                }
            } 
            else {
                currentP ~= (currentP.length ? " " : "") ~ trimmed;
            }
        }
        
        if (currentP.length) {
            string resolved = resolvePlaceholders(currentP);
            res ~= "<p>" ~ resolved ~ "</p>\n";
        }
        return res;
    }

        string resolvePlaceholders(string text) {
        string result = "";
        size_t i = 0;
        
        while (i < text.length) {
            // Обработка #DESC:TAG:content#
            if (i + 6 < text.length && text[i..i+6] == "#DESC:") {
                size_t endTag = text.indexOf(':', i + 6);
                size_t endHash = text.indexOf('#', endTag + 1);
                if (endTag != size_t.max && endHash != size_t.max) {
                    string tag = text[i+6 .. endTag];
                    string content = text[endTag+1 .. endHash];
                    // formatDesc уже делает escapeXml внутри, не экранируем повторно
                    result ~= formatDesc(tag, content);
                    i = endHash + 1;
                    continue;
                }
            }
            
            // Обработка ссылок #текст[id] или #текст[id^]
            if (text[i] == '#') {
                size_t bracket = text.indexOf('[', i + 1);
                if (bracket != size_t.max) {
                    string linkText = text[i+1 .. bracket].strip;
                    size_t endB = text.indexOf(']', bracket + 1);
                    if (endB != size_t.max) {
                        string idPart = text[bracket+1 .. endB];
                        bool isFn = (idPart.length > 0 && idPart[$-1] == '^');
                        string target = isFn ? idPart[0..$-1] : idPart;
                        
                        // Экранируем только текст ссылки, не теги <a>
                        string escapedText = escapeXml(linkText);
                        if (isFn) {
                            fnCounter++;
                            result ~= "<sup><a l:href=\"#" ~ target ~ "\" type=\"note\">" ~ escapedText ~ "</a></sup>";
                        } else {
                            result ~= "<a l:href=\"#" ~ target ~ "\">" ~ escapedText ~ "</a>";
                        }
                        i = endB + 1;
                        continue;
                    }
                }
            }
            
            // Обычный текст: экранируем
            result ~= escapeXml(text[i..i+1]);
            i++;
        }
        return result; // НЕ вызываем escapeXml здесь — он уже применён к тексту
    }

    string formatDesc(string tag, string content) {
        content = escapeXml(content);
        switch (tag) {
            case "E": return "<emphasis>" ~ content ~ "</emphasis>";
            case "S": return "<strong>" ~ content ~ "</strong>";
            case "U": return "<underline>" ~ content ~ "</underline>";
            case "K": return "<strikethrough>" ~ content ~ "</strikethrough>";
            case "C": return "<code class=\"stratim-lang-" ~ tag ~ "\">" ~ content ~ "</code>";
            case "Q": return "<emphasis type=\"cite\">" ~ content ~ "</emphasis>";
            case "W": return content.replace("-", "&#8209;");
            case "R": return "<p xml:space=\"preserve\">" ~ content ~ "</p>";
            default: return content;
        }
    }

    void collectFootnote(ASTNode n) {
        fnCounter++;
        string id = n.id.length ? n.id : "fn" ~ to!string(fnCounter);
        string backlink = "<a name=\"" ~ id ~ "\"/><a l:href=\"#src_" ~ id ~ "\">[" ~ to!string(fnCounter) ~ "]</a> ";
        
        // processContent уже возвращает <p>...</p>, не оборачиваем ещё раз
        string contentXml = processContent(n.content);
        footnotes ~= "<section><p>" ~ backlink ~ "</p>" ~ contentXml ~ "</section>\n";
    }

    string mapSymbol(string sym) {
        switch (sym) {
            case "*": return "section";
            case "#": return "section";
            case "=": return "poem";
            case "|": return "epigraph";
            case ">": return "image";
            case "_": return "annotation";
            case "-": return "empty-line";
            case "f": return "section";
            case "root": return "root";
            default: return "section";
        }
    }

    string escapeXml(string s) {
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;");
    }
}