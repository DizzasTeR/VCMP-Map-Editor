function bindEvent(func, handler) {
    return SqCore.On()[func].Connect(handler);
}