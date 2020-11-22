CMD.Register("exec", "g", ["code"], 1, 1, CMD_PERMISSIONS.EVERYONE /* Change to ADMIN later */).BindExec(this, function(player, params) {
    try {
        compilestring(params.code)();
        player.Message("[#ffffff]Executed");
    } catch(error) {
        player.Message("[#ffffff]Error: %s", error);
    }
    return true;
});