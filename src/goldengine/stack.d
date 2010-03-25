module goldengine.stack;

///Simple stack class using a dynamic array
public class Stack(T) {
    private T[] mItems;

    T pop() {
        T ret = null;
        if (mItems.length > 0) {
            ret = top();
            mItems.length = mItems.length -1;
        }
        return ret;
    }

    T top() {
        if (mItems.length > 0) {
            return mItems[$-1];
        } else {
            return null;
        }
    }

    void push(T item) {
        mItems ~= item;
    }

    size_t count() {
        return mItems.length;
    }

    void clear() {
        mItems = null;
    }

    T opIndex(size_t idx) {
        return mItems[idx];
    }
}
