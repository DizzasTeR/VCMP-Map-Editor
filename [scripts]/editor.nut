function bindEvent(func, handler) {
    return SqCore.On()[func].Connect(handler);
}

bindEvent("ScriptLoaded", function() {
    print("Loaded");
})