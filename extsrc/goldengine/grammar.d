module goldengine.grammar;

import
    goldengine.dfastate,
    goldengine.lalrstate,
    goldengine.rule,
    goldengine.symbol;

version(Tango) {
    import
        tango.io.device.Conduit,
        tango.io.device.Array,
        tango.io.device.File;
} else {
    import std.stream;
}

private int readInt16(inout ubyte[] buffer, inout int bufPos) {
    int v = buffer[bufPos] + (buffer[bufPos+1] << 8);
    bufPos += 2;
    return v;
}

private ubyte readByte(inout ubyte[] buffer, inout int bufPos) {
    ubyte v = buffer[bufPos];
    bufPos++;
    return v;
}

private wchar[] readString(inout ubyte[] buffer, inout int bufPos) {
    wchar[] res;
    wchar c;
    while ((c = readInt16(buffer, bufPos)) != '\0') {
        res ~= c;
    }
    return res;
}


public class Grammar {
    private {
        ubyte[] mBuffer;
        int mBufferPos;
        int mStartSymbolIdx;

        const wchar[] cgtHeader = "GOLD Parser Tables/v1.0";
    }

    public {
        ///Grammar parameters
        wchar[] grmName;
        wchar[] grmVersion;
        wchar[] grmAuthor;
        wchar[] grmAbout;
        bool caseSensitive;

        ///Parse tables
        wchar[][] charsetTable;
        Symbol[] symbolTable;
        Rule[] ruleTable;
        DFAState[] dfaStateTable;
        LALRState[] lalrStateTable;

        ///Initial states
        int initialDFAState;
        int initialLALRState;

        ///Special symbols
        Symbol symbolStart;
        Symbol symbolEof;
        Symbol symbolError;
    }

    ///Declaration of CGT format constants and structures
    ///Those are only needed when reading a grammar file
    private {
        enum CGTEntryType : ubyte {
            contentEmpty   = 69,
            contentInteger = 73,
            contentString  = 83,
            contentBoolean = 66,
            contentByte    = 98,
        }

        enum CGTRecordType : ubyte {
            rtMultiple = 77,
        }

        enum CGTRecordId : ubyte {
            idParameters  = 80,   //P
            idTableCounts = 84,   //T
            idInitial     = 73,   //I
            idSymbols     = 83,   //S
            idCharSets    = 67,   //C
            idRules       = 82,   //R
            idDFAStates   = 68,   //D
            idLRTables    = 76,   //L
            idComment     = 33,   //!
        }

        struct CGTRecordEntry {
            CGTEntryType entryType;
            bool vBool;
            ubyte vByte;
            int vInteger;
            wchar[] vString;

            public static CGTRecordEntry read(inout ubyte[] buffer, inout int bufPos) {
                CGTRecordEntry res;
                res.entryType = cast(CGTEntryType)readByte(buffer, bufPos);
                switch (res.entryType) {
                    case CGTEntryType.contentEmpty:
                        break;
                    case CGTEntryType.contentBoolean:
                        res.vBool = readByte(buffer, bufPos) == 1;
                        break;
                    case CGTEntryType.contentByte:
                        res.vByte = readByte(buffer, bufPos);
                        break;
                    case CGTEntryType.contentInteger:
                        res.vInteger = readInt16(buffer, bufPos);
                        break;
                    case CGTEntryType.contentString:
                        res.vString = readString(buffer, bufPos);
                        break;
                    default:
                        throw new Exception("Invalid record entry type");
                }
                return res;
            }
        }

        struct CGTMRecord {
            int numEntries;
            CGTRecordId recId;
            CGTRecordEntry[] entries;

            public static CGTMRecord read(inout ubyte[] buffer, inout int bufPos) {
                CGTMRecord res;
                res.numEntries = readInt16(buffer, bufPos) - 1;
                CGTRecordEntry idRec = CGTRecordEntry.read(buffer, bufPos);
                if (idRec.entryType != CGTEntryType.contentByte)
                    throw new Exception("Invalid M record structure");

                res.recId = cast(CGTRecordId)idRec.vByte;
                res.entries.length = res.numEntries;
                foreach (inout e; res.entries) {
                    e = CGTRecordEntry.read(buffer, bufPos);
                }
                return res;
            }
        }
    }

version(Tango) {
    ///Load a grammar from a file
    this(char[] filename) {
        scope c = new File(filename);
        this(c);
    }

    ///Load a grammar from a stream
    this(Conduit c) {
        loadTables(c);
    }

    //actually loads the file
    private void loadTables(Conduit c) {
        auto mem = new Array(0, 4096);
        mem.copy(c);

        mBuffer = cast(ubyte[])mem.slice();
        mBufferPos = 0;

        processBuffer();
    }
} else {
    ///Load a grammar from a file
    this(char[] filename) {
        scope st = new File(filename, FileMode.In);
        this(st);
    }

    ///Load a grammar from a stream
    this(Stream st) {
        loadTables(st);
    }

    //actually loads the file
    private void loadTables(Stream st) {
        mBuffer.length = st.size;
        mBufferPos = 0;
        st.readBlock(mBuffer.ptr, st.size);

        processBuffer();
    }
}

    //process cached data
    private void processBuffer() {
        //check file header
        if (readString(mBuffer, mBufferPos) == cgtHeader) {
            while (mBufferPos < mBuffer.length) {
                CGTRecordType rt = cast(CGTRecordType)readByte(mBuffer, mBufferPos);
                switch (rt) {
                    //Multiple is the only current record type, but this
                    //code is ready for expansion
                    case CGTRecordType.rtMultiple:
                        CGTMRecord rec = CGTMRecord.read(mBuffer, mBufferPos);
                        int curEntry = 0;
                        switch (rec.recId) {
                            case CGTRecordId.idParameters:
                                grmName = rec.entries[0].vString;
                                grmVersion = rec.entries[1].vString;
                                grmAuthor = rec.entries[2].vString;
                                grmAbout = rec.entries[3].vString;
                                caseSensitive = rec.entries[4].vBool;
                                mStartSymbolIdx = rec.entries[5].vInteger;
                                break;
                            case CGTRecordId.idTableCounts:
                                symbolTable.length = rec.entries[0].vInteger;
                                charsetTable.length = rec.entries[1].vInteger;
                                ruleTable.length = rec.entries[2].vInteger;
                                dfaStateTable.length = rec.entries[3].vInteger;
                                lalrStateTable.length = rec.entries[4].vInteger;
                                break;
                            case CGTRecordId.idInitial:
                                initialDFAState = rec.entries[0].vInteger;
                                initialLALRState = rec.entries[1].vInteger;
                                break;
                            case CGTRecordId.idSymbols:
                                int symIdx = rec.entries[0].vInteger;
                                symbolTable[symIdx] = new Symbol(symIdx, rec.entries[1].vString,
                                    cast(SymbolKind)rec.entries[2].vInteger);
                                if (symIdx == mStartSymbolIdx) {
                                    //this is the start symbol, set reference
                                    symbolStart = symbolTable[symIdx];
                                }
                                if (symbolTable[symIdx].kind == SymbolKind.end) {
                                    //this is the "end of file" symbol
                                    symbolEof = symbolTable[symIdx];
                                }
                                if (symbolTable[symIdx].kind == SymbolKind.error) {
                                    //this is the "error" symbol
                                    symbolError = symbolTable[symIdx];
                                }
                                break;
                            case CGTRecordId.idCharSets:
                                charsetTable[rec.entries[0].vInteger] = rec.entries[1].vString;
                                break;
                            case CGTRecordId.idRules:
                                int ruleIdx = rec.entries[0].vInteger;
                                ruleTable[ruleIdx] = new Rule(ruleIdx, symbolTable[rec.entries[1].vInteger]);
                                for (int i = 3; i < rec.entries.length; i++) {
                                    ruleTable[ruleIdx].ruleSymbols ~= symbolTable[rec.entries[i].vInteger];
                                }
                                break;
                            case CGTRecordId.idDFAStates:
                                int stateIdx = rec.entries[0].vInteger;
                                bool acceptState = rec.entries[1].vBool;
                                Symbol accSym = null;
                                if (acceptState)
                                    accSym = symbolTable[rec.entries[2].vInteger];
                                dfaStateTable[stateIdx] = DFAState(stateIdx,
                                    acceptState, accSym);
                                for (int i = 4; i < rec.entries.length; i += 3) {
                                    dfaStateTable[stateIdx].edges ~= DFAEdge(
                                        rec.entries[i].vInteger,
                                        rec.entries[i+1].vInteger);
                                }
                                break;
                            case CGTRecordId.idLRTables:
                                int stateIdx = rec.entries[0].vInteger;
                                LALRState state = new LALRState(stateIdx);
                                for (int i = 2; i < rec.entries.length; i += 4) {
                                    state.actions ~= new LALRAction(
                                        symbolTable[rec.entries[i].vInteger],
                                        cast(ActionConstants)rec.entries[i+1].vInteger,
                                        rec.entries[i+2].vInteger);
                                }
                                lalrStateTable[stateIdx] = state;
                                break;
                            case CGTRecordId.idComment:
                                break;
                            default:
                                throw new Exception("Invalid record structure");
                        }
                        break;
                    default:
                        throw new Exception("Unknown record type");
                }
            }
        } else {
            throw new Exception("File format not recognized");
        }
        if (!symbolStart || !symbolEof || !symbolError || dfaStateTable.length < 1
            || lalrStateTable.length < 1)
            throw new Exception("Failed to load grammer: Missing some required values");
    }
}
