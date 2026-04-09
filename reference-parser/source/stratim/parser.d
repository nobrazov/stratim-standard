// SPDX-License-Identifier: GPL-3.0-or-later OR Stratim-Commercial-1.0
module stratim.parser;

import stratim.lexer;
import std.array;
import std.string;
import std.conv;
import std.exception;

struct ASTNode {
    string symbol, id, title, modifier;
    string[] content;
    string[] attrs, array;
    bool isFootnote;
    ASTNode[] children;

    this(string sym, string ident, string tit, string mod) {
        symbol = sym; id = ident; title = tit; modifier = mod;
        isFootnote = (sym == "f");
    }
}

class StratimParser {
    StratimLexer lexer;
    ASTNode root;
    string[string] metaDict;
    string[] errors;
    bool bodyStarted = false;
    
    // Индекс текущего узла в root.children для добавления контента
    // -1 = нет активного узла (мета-режим или до первой команды)
    int currentIdx = -1;

    this(StratimLexer lex) {
        lexer = lex;
        root = ASTNode("root", "", "", "");
    }

    ASTNode parse() {
        Token tok;
        while ((tok = lexer.nextToken()).type != TokenType.END) {
            try { handleToken(tok); }
            catch (Exception e) { errors ~= "Line " ~ to!string(tok.lineNum) ~ ": " ~ e.msg; }
        }
        validate();
        return root;
    }

    // Вспомогательная: получить ссылку на текущий активный узел
    ref ASTNode getCurrentNode() {
        if (currentIdx >= 0 && currentIdx < root.children.length) {
            return root.children[currentIdx];
        }
        // Если нет активного узла, возвращаем фиктивный (контент в него не попадёт)
        static ASTNode dummy;
        return dummy;
    }

    void handleToken(Token tok) {
        switch (tok.type) {
            case TokenType.META_CMD:
                metaDict[tok.symbol] = tok.title;
                if (tok.array.length) metaDict[tok.symbol] = tok.array.join(",");
                break;
                
            case TokenType.EMPTY_LINE:
                if (!bodyStarted) { 
                    bodyStarted = true; 
                    currentIdx = -1; 
                }
                // Добавляем маркер пустой строки в текущий раздел
                if (bodyStarted && currentIdx >= 0) {
                    getCurrentNode().content ~= "";
                }
                break;
                
            case TokenType.BODY_CMD:
                attachNode(tok);
                break;
                
            case TokenType.CONTENT:
                if (bodyStarted && currentIdx >= 0) {
                    getCurrentNode().content ~= tok.raw;
                }
                break;
                
            case TokenType.LIST_PREFIX:
                if (bodyStarted && currentIdx >= 0) {
                    // Сохраняем ВЕСЬ текст строки, а не только маркер
                    string fullLine = tok.raw.strip;
                    getCurrentNode().content ~= "#LIST:" ~ to!string(tok.listDepth) ~ ":" ~ fullLine;
                }
                break;
                
            case TokenType.DESCRIPTOR:
                if (bodyStarted && currentIdx >= 0) {
                    string tag = tok.tag == "C" ? "C:" ~ tok.langMod : tok.tag;
                    // Добавляем # в конце, чтобы resolvePlaceholders мог найти конец
                    getCurrentNode().content ~= "#DESC:" ~ tag ~ ":" ~ tok.content ~ "#";
                }
                break;
                
            default: break;
        }
    }

        void attachNode(Token tok) {
        ASTNode node = ASTNode(tok.symbol, tok.id, tok.title, tok.modifier);
        node.attrs = tok.attrs;
        node.array = tok.array;
        
        // Спец-обработка для сносок: контент был в tok.title, переносим в content
        if (tok.symbol == "f" && tok.title.length > 0 && tok.array.length == 0) {
            node.content ~= tok.title;
            node.title = ""; // Очищаем, чтобы не дублировать
        }
        
        // ... остальная логика стека ...
        
        root.children ~= node;
        currentIdx = cast(int)(root.children.length - 1);
    }

    void validate() {
        if (errors.length > 0) throw new Exception(errors.join("\n"));
        if (!("t" in metaDict)) throw new Exception("MISSING_REQUIRED_META: ~ t (title)");
        if (!("l" in metaDict)) throw new Exception("MISSING_REQUIRED_META: ~ l (language)");
        if (!bodyStarted) throw new Exception("MISSING_META_SEPARATOR");
    }
}