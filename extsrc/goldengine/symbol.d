module goldengine.symbol;

version(Tango) {
    import
        tango.text.convert.Utf;

    alias toString toUTF8;
} else {
    import
        std.utf;
}

public enum SymbolKind {
    nonterminal = 0,     //Normal nonterminal
    terminal = 1,        //Normal terminal
    whitespace = 2,      //Type of terminal
    end = 3,             //End character (EOF)
    commentStart = 4,    //Comment start
    commentEnd = 5,      //Comment end
    commentLine = 6,     //Comment line
    error = 7,           //Error symbol
}

package int findw(wchar[] s, wchar c)
{
	foreach (int i, wchar c2; s)
	{
	    if (c == c2)
            return i;
	}
	return -1;
}

package wchar tolower(wchar c) {
    if (c>= 'A' && c <= 'Z')
        c = c + 32;
    return c;
}

package int ifindw(wchar[] s, wchar c)
{
	wchar c1 = tolower(c);

	foreach (int i, wchar c2; s)
	{
	    c2 = tolower(c2);
	    if (c1 == c2)
            return i;
	}
	return -1;
}

///Holds one symbol defined by the grammar file
///As each symbol will only exist in one instance, the class references
///can be compared directly
public class Symbol {
    ///Index into the symbol table, this corresponds to generated constants
    int index;
    ///plain symbol character or string
    wchar[] name;
    ///symbol type
    SymbolKind kind;

    package this(int index, wchar[] name, SymbolKind kind) {
        this.index = index;
        this.name = name;
        this.kind = kind;
    }

    public char[] toString() {
        return toUTF8(toStringw());
    }

    ///Return a text representation of the symbol
    public wchar[] toStringw() {
        switch (kind) {
            case SymbolKind.nonterminal:
                return "<" ~ name ~ ">";
                break;
            case SymbolKind.terminal:
                return patternFormat(name);
                break;
            default:
                return "(" ~ name ~ ")";
                break;
        }
    }

    ///Create a valid Regular Expression for a source string
    ///Put all special characters in single quotes
    private wchar[] patternFormat(wchar[] source) {
        const wchar[] quotedChars = "|-+*?()[]{}<>!";

        wchar[] ret;
        foreach (wchar ch; source) {
            if (ch == '\'')
                ret ~= "''";
            else if (findw(quotedChars, ch) >= 0) {
                ret ~= "'";
                ret ~= ch;
                ret ~= "'";
            } else
                ret ~= ch;
        }
        return ret;
    }
}
