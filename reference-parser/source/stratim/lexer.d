// SPDX-License-Identifier: GPL-3.0-or-later OR Stratim-Commercial-1.0
module stratim.lexer;

import std.string;
import std.array;
import std.regex;
import std.exception;
import std.conv;
import std.algorithm : canFind;

enum TokenType { META_CMD, BODY_CMD, DESCRIPTOR, CONTENT, EMPTY_LINE, LIST_PREFIX, END }

struct Token {
    TokenType type; string raw; size_t lineNum;
    string symbol, modifier, id, title;
    string[] array, attrs;
    string tag, langMod, content;
    int listDepth;
}

class StratimLexer {
private:
    string[] lines;
    size_t pos = 0, lineNum = 0;
    bool inMeta = true, inRawBlock = false;
    string rawAccumulator = "", rawModule = "";
    
    static immutable META_SYMBOLS = ["i","t","a","g","l","d","k","n","c","s","p","u","x","1","2","3","4","5","6","7","8","9"];
    static immutable BODY_SYMBOLS = ["*","#","=","|",">","_","-","/","f"];
    
public:
    this(string source) { lines = source.splitLines; }
    
    Token nextToken() {
        if (pos >= lines.length) return createToken(TokenType.END, "", lines.length);
        
        string line = lines[pos++];
        lineNum++;
        string trimmed = line.stripLeft;
        
        if (inRawBlock) {
            if (trimmed.startsWith(":::") && trimmed.endsWith(":::") && trimmed.length > 3) {
                inRawBlock = false;
                auto tok = createToken(TokenType.DESCRIPTOR, line, lineNum);
                tok.tag = "C"; tok.langMod = rawModule; tok.content = rawAccumulator;
                rawAccumulator = ""; rawModule = "";
                return tok;
            }
            rawAccumulator ~= (rawAccumulator.length ? "\n" : "") ~ line;
            return nextToken();
        }
        
        if (trimmed.length == 0) {
            if (inMeta) inMeta = false;
            return createToken(TokenType.EMPTY_LINE, line, lineNum);
        }
        
        if (inMeta && trimmed.startsWith("~ ")) {
            return parseCommand(trimmed[2..$].strip, lineNum, true);
        }
        
        if (trimmed.startsWith("~ ")) {
            return parseCommand(trimmed[2..$].strip, lineNum, false);
        }
        
        if (trimmed.startsWith("::: ")) {
            return parseDescriptor(trimmed, lineNum);
        }
        
        if (!inMeta) {
            auto listMatch = matchFirst(trimmed, regex(`^(\d+(\.\d+)*)\.\s`));
            if (!listMatch.empty) {
                string[] segs = listMatch[1].split(".");
                auto tok = createToken(TokenType.LIST_PREFIX, trimmed, lineNum);
                tok.listDepth = cast(int)segs.length - 1;
                return tok;
            }
            if (matchFirst(trimmed, regex(`^-\s`))) {
                auto tok = createToken(TokenType.LIST_PREFIX, trimmed, lineNum);
                tok.listDepth = 0;
                return tok;
            }
        }
        
        return createToken(TokenType.CONTENT, line, lineNum);
    }
    
private:
    Token createToken(TokenType t, string r, size_t ln) {
        Token tok; tok.type = t; tok.raw = r; tok.lineNum = ln; return tok;
    }
    
    Token parseCommand(string rest, size_t ln, bool isMeta) {
        Token tok = createToken(isMeta ? TokenType.META_CMD : TokenType.BODY_CMD, rest, ln);
        if (rest.length < 1) enforce(false, "Empty command at line " ~ to!string(ln));
        
        tok.symbol = rest[0..1];
        rest = rest[1..$].strip;
        
        if (!isMeta && rest.length > 0 && (rest[0] == '^' || rest[0] == 'v')) {
            tok.modifier = rest[0..1];
            rest = rest[1..$].strip;
        }
        
        auto idMatch = matchFirst(rest, regex(`^\(([a-zA-Z0-9_-]+)\)`));
        if (!idMatch.empty) { tok.id = idMatch[1]; rest = rest[idMatch[0].length..$].strip; }
        
        auto titMatch = matchFirst(rest, regex(`^\[([^\]]*)\]`));
        if (!titMatch.empty) { 
            tok.title = titMatch[1]; 
            rest = rest[titMatch[0].length..$].strip; 
        } else if (isMeta && rest.length > 0 && rest[0] != '@') {
            size_t sp = rest.indexOf(' ');
            size_t at = rest.indexOf('@');
            size_t end = size_t.max;
            if (sp != size_t.max) end = sp;
            if (at != size_t.max && (end == size_t.max || at < end)) end = at;
            
            if (end != size_t.max) {
                tok.title = rest[0..end].strip;
                rest = rest[end..$].strip;
            } else {
                tok.title = rest.strip;
                rest = "";
            }
        }
        
        auto arrMatch = matchFirst(rest, regex(`^@([a-zA-Z0-9_.,]+)`));
        if (!arrMatch.empty) { tok.array = arrMatch[1].split(","); rest = rest[arrMatch[0].length..$].strip; }
        
        while (true) {
            size_t eq = rest.indexOf('=');
            if (eq == size_t.max) break;
            if (rest.length < eq + 2 || rest[eq + 1] != '"') break;
            size_t endQ = rest.indexOf('"', eq + 2);
            if (endQ == size_t.max) break;
            tok.attrs ~= rest[0..endQ + 1];
            rest = rest[endQ + 1..$].strip;
        }
        
        enforce((isMeta ? META_SYMBOLS : BODY_SYMBOLS).canFind(tok.symbol),
                "Unknown symbol '" ~ tok.symbol ~ "' at line " ~ to!string(ln));
        return tok;
    }
    
    Token parseDescriptor(string trimmed, size_t ln) {
        string inner = trimmed[4..$];
        
        // Support inline descriptors: ::: E text ::: more text
        size_t endMarker = inner.indexOf(":::");
        if (endMarker == size_t.max) {
            enforce(false, "Unclosed ::: at line " ~ to!string(ln));
        }
        
        string descriptorPart = inner[0 .. endMarker].strip;
        string afterDescriptor = (endMarker + 3 < inner.length) ? inner[endMarker + 3 .. $].strip : "";
        
        Token tok = createToken(TokenType.DESCRIPTOR, trimmed, ln);
        
        size_t sp = descriptorPart.indexOf(' ');
        if (sp != size_t.max) {
            tok.tag = descriptorPart[0..sp];
            tok.content = descriptorPart[sp+1..$].strip;
        } else {
            tok.tag = descriptorPart;
            tok.content = "";
        }
        
        if (afterDescriptor.length > 0) {
            tok.content = (tok.content.length ? tok.content ~ " " : "") ~ afterDescriptor;
        }
        
        // Handle \lang mode
        if (tok.tag == "C" && tok.content.startsWith("\\lang ")) {
            string lp = tok.content[6..$];
            size_t bs = lp.indexOf("\\");
            enforce(bs != size_t.max, "Missing closing \\ in \\lang at line " ~ to!string(ln));
            tok.langMod = lp[0..bs].strip;
            tok.content = lp[bs+1..$].strip;
            if (!tok.content.endsWith(":::")) {
                inRawBlock = true; rawModule = tok.langMod; rawAccumulator = tok.content;
            }
        }
        return tok;
    }
} // <-- Закрытие класса StratimLexer