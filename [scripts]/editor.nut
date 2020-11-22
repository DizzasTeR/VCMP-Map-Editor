/***
- GLOBALS
***/
bindEvent("ScriptLoaded", function() { // To avoid script load order
    getroottable().setdelegate({
		function _get(index) {
			return null;
		}
				
		function _set(index, value) {
			rawset(index, value);
		}
	});

    g_MapsDatabase = MapDatabase(/* "Maps.db" */);
});

bindEvent("ScriptLoaded", function() {
    SqLog.Inf("VCMP Map Editor");
    
    // TESTING
    local map = Map("mymap");
    map.Create(); // Creates if it doesn't exist
    //map.Destroy(); // map is now completely invalidated.
    
    //map = Map("mymap");
    //map.Create();
    
    map.Load();

    map.AddObject(500, Vector3(0, 0, 20), Vector3(0, 0, 0));
    map.Save();
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