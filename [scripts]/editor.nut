/***
- GLOBALS
***/
g_LuaDelegate <- {
	function _get(index) {
		return null;
	}
			
	function _set(index, value) {
		rawset(index, value);
	}
};

bindEvent("ScriptLoaded", function() { // To avoid script load order
    getroottable().setdelegate(g_LuaDelegate);
    g_MapsDatabase = MapDatabase(/* "Maps.db" */);
});

bindEvent("ScriptLoaded", function() {
    SqLog.Inf("VCMP Map Editor");
    
    // TESTING
    map = Map("mymap");
    map.Create(); // Creates if it doesn't exist
    //map.Destroy(); // map is now completely invalidated.
    
    //map = Map("mymap");
    //map.Create();
    
    map.Load();

    //map.AddObject(500, Vector3(0, 0, 20), Vector3(0, 0, 0));
    //map.Save();
});

bindEvent("PlayerCreated", function(player, ...)
{
    player.Data = {}.setdelegate(g_LuaDelegate);
    player.Data.permission_level = CMD_PERMISSIONS.ADMIN;
});

bindEvent("PlayerSpawn", function(player)
{
    print(SqCount.Object.Active());
    // player.MakeTask(function() {
    //     map.AddObject(500, this.Inst.Position, Vector3(0, 0, 0));
    //     map.Save();
    // }, 3000, 1);
});

/***

TO DO:
- Command Manager
- UI
- Controls

Current Progress:
- Classes structure done
- Map database connectivity && map data parsing

***/