module goldengine.token;

import
    goldengine.lalrstate,
    goldengine.symbol;

public class Token {
    private {
        Symbol mParentSymbol;
        wchar[] mText;
        LALRState mLALRState;
        Object mData;
    }

    package this(Symbol parentSymbol, wchar[] text) {
        mParentSymbol = parentSymbol;
        mText = text;
    }

    ///Symbol that generated this token
    public Symbol parentSymbol() {
        return mParentSymbol;
    }
    package void parentSymbol(Symbol s) {
        mParentSymbol = s;
    }

    ///String from the source file that generated this token
    ///For a token created by a reduction, this is empty
    public wchar[] text() {
        return mText;
    }

    package LALRState lalrState() {
        return mLALRState;
    }
    package void lalrState(LALRState state) {
        mLALRState = state;
    }

    ///User-defined data that is stored with the token
    public Object data() {
        return mData;
    }
    package void data(Object d) {
        mData = d;
    }
}
