// SPDX-License-Identifier: GPL-3.0-or-later OR Stratim-Commercial-1.0
module main;

import std.stdio;
import std.file;
import stratim.lexer;
import stratim.parser;
import stratim.fb2gen;

void main(string[] args) {
    if (args.length != 3) {
        stderr.writeln("Usage: stratim <input.stratim> <output.fb2>");
        return;
    }
    
    string inFile = args[1];
    string outFile = args[2];
    
    try {
        if (!std.file.exists(inFile)) {
            stderr.writeln("Error: File not found: ", inFile);
            return;
        }
        string source = cast(string)std.file.read(inFile);
        
        auto lexer = new StratimLexer(source);
        auto parser = new StratimParser(lexer);
        auto ast = parser.parse();
        
        auto generator = new FB2Generator(ast, parser.metaDict); // Исправлено: передан metaDict
        string fb2 = generator.generate();
        
        std.file.write(outFile, fb2);
        writeln("✓ Converted: ", inFile, " → ", outFile);
        
    } catch (Exception e) {
        stderr.writeln("✗ Error: ", e.msg);
    }
    writeln("Stratim Parser v0.1-alpha");
    writeln("Usage: stratim <input.stratim> <output.fb2>");
}