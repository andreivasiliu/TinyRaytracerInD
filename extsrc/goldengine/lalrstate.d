module goldengine.lalrstate;

import
    goldengine.symbol;

package enum ActionConstants {
    acShift = 1,
    acReduce = 2,
    acGoto = 3,
    acAccept = 4,
}

package class LALRAction {
    Symbol entry;
    ActionConstants action;
    int target;

    this(Symbol entry, ActionConstants action, int target) {
        this.entry = entry;
        this.action = action;
        this.target = target;
    }
}

package class LALRState {
    int index;
    LALRAction[] actions;

    this(int index) {
        this.index = index;
    }

    public LALRAction findAction(Symbol s) {
        foreach (LALRAction a; actions) {
            if (a.entry == s) {
                return a;
            }
        }
        return null;
    }
}
