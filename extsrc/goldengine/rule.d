module goldengine.rule;

import
    goldengine.symbol;

version(Tango) {
    import tango.text.convert.Utf;

    alias toString toUTF8;
} else {
    import std.utf;
}

public class Rule {
    ///Index into the rule table, this corresponds to the generated constants
    int index;
    ///Rule nonterminal
    Symbol ntSymbol;
    ///Rule handle
    Symbol[] ruleSymbols;

    package this(int index, Symbol ntSymbol) {
        this.index = index;
        this.ntSymbol = ntSymbol;
    }

    ///Does this rule consist of a single nonterminal?
    public bool oneNT() {
        return ruleSymbols.length == 1 && ruleSymbols[0].kind == SymbolKind.nonterminal;
    }

    public char[] toString() {
        return toUTF8(toStringw());
    }

    ///Get a string representation of this rule
    public wchar[] toStringw() {
        wchar[] handle;
        foreach (sym; ruleSymbols) {
            handle ~= sym.toStringw() ~ " ";
        }
        return ntSymbol.toStringw() ~ " ::= " ~ handle;
    }
}
