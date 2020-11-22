class MapCodes
{
	static ALREADY_EXISTS		= "<%d> [%s] already exists!";
	static DOES_NOT_EXIST		= "Map does not exist!";
	
	static MAP_CREATED			= "<%d> [%s] created successfully!";
	static MAP_DESTROYED		= "<%d> [%s] destroyed successfully!";

	static RELOADING			= "<%d> [%s] is being reloaded...";
	static MAP_LOADED			= "<%d> [%s] loaded successfully!";
	static MAP_UNLOADED			= "<%d> [%s] unloaded successfully!";
	static NOT_LOADED			= "<%d> [%s] is not loaded";
	static MAP_SAVED			= "<%d> [%s] has been successfully saved!";

	static NO_OBJECTS			= "<%d> [%s] is an empty map";
	static NOT_MODIFIED			= "<%d> [%s] was not modified!";
}

class Map
{
	id      = null;
	name    = null;
	objects = null;

	exists  = false;
	loaded	= false;
	isModified = false;

	constructor(mapName)
	{
		this.name = mapName;
		this.objects = [];
		
		local query = g_MapsDatabase.connection.Query("SELECT * FROM [Maps] WHERE [name] = @mapName;");
		query.Param("@mapName").SetString(mapName);
		
		try {
			if(query.Step())
			{
				exists = true;

				local fields = query.GetTable();
				foreach(fieldName, fieldValue in fields)
				{
					this[fieldName] = fieldValue;
				}
			}

			if(this.exists)
				SqLog.Inf("Map::Map >> [%s]", this.name);
		}
		catch(e)
		{
			SqLog.Err("Map::Map >> '%s'", e);
		}
	}

	function Create(name = null, silent = false)
	{
		if(name == null)
			name = this.name;

		if(this.exists)
		{
			SqLog.Err("Map::Create >> %s", format(MapCodes.ALREADY_EXISTS, this.id, this.name));
			return false;
		}
		
		local query = g_MapsDatabase.connection.Query("INSERT INTO [Maps] (name) VALUES (@mapName);");
		query.Param("@mapName").SetString(name);
		query.Exec();
		
		this.exists = true;
		this.id = g_MapsDatabase.connection.LastInsertRowId.tointeger();
		this.name = name;

		SqLog.Inf("Map::Create >> Created map %s", format(MapCodes.MAP_CREATED, this.id, this.name));
		return true;
	}

	function Destroy()
	{
		if(!this.exists)
		{
			SqLog.Err("Map::Destroy >> %s", MapCodes.DOES_NOT_EXIST);
			return false;
		}

		Unload();

		local query = g_MapsDatabase.connection.Query("DELETE FROM [Maps] WHERE [id] = @mapID;");
		query.Param("@mapID").SetInteger(this.id);
		query.Exec();

		query = g_MapsDatabase.connection.Query("DELETE FROM [MapsData] WHERE [map_id] = @mapID;");
		query.Param("@mapID").SetInteger(this.id);
		query.Exec();

		local mapID = this.id, mapName = this.name;
		
		this.id = null;
		this.name = null;
		this.objects = null;

		this = null;

		SqLog.Inf("Map::Destroy >> %s", format(MapCodes.MAP_DESTROYED, mapID, mapName));
	}

	function Load()
	{
		if(!this.exists)
		{
			SqLog.Err("Map::Load >> %s", MapCodes.DOES_NOT_EXIST);
			return false;
		}

		if(this.loaded)
		{
			// This is a reload
			SqLog.Inf("Map::Load >> %s", format(MapCodes.RELOADING, this.id, this.name));
			
			Unload();
		}

		local query = g_MapsDatabase.connection.Query("SELECT * FROM [MapsData] WHERE [map_id] = %i;", this.id);
		if(query.Step())
		{
			do {
				local fields = query.GetTable();

				local object_model = fields.object_model;
				local object_position = fromJSON.decode(fields.object_position);
				local object_rotation = fromJSON.decode(fields.object_rotation);

				local object = SqObject.Create(object_model, 1, Vector3(object_position.x, object_position.y, object_position.z), 255); // Allow alpha support in future?
				object.RotateToEuler(object_rotation.x, object_rotation.y, object_rotation.z, 0);

				this.objects.push(object);
			}
			while(query.Step());	
		}
		this.loaded = true;

		if(this.objects.len() == 0)
			SqLog.Wrn("Map::Load >> %s", format(MapCodes.NO_OBJECTS, this.id, this.name));

		if(this.loaded)
			SqLog.Inf("Map::Load >> %s", format(MapCodes.MAP_LOADED, this.id, this.name));
		return true;
	}

	function Unload()
	{
		if(!this.exists)
		{
			SqLog.Err("Map::Unload >> %s", MapCodes.DOES_NOT_EXIST);
			return false;
		}

		if(!this.loaded)
		{
			SqLog.Err("Map::Unload >> %s", format(MapCodes.NOT_LOADED, this.id, this.name));
			return false;
		}

		SqForeach.Object.Active(getroottable(), function(object)
		{
			object.Destroy();
		});
		
		this.objects.clear();
		this.loaded = false;

		SqLog.Inf("Map::Unload >> %s", format(MapCodes.MAP_UNLOADED, this.id, this.name));
		return true;
	}

	function Save(force = false)
	{
		if(!this.exists)
		{
			SqLog.Err("Map::Save >> %s", MapCodes.DOES_NOT_EXIST);
			return false;
		}

		if(!this.loaded)
		{
			SqLog.Err("Map::Save >> %s", format(MapCodes.NOT_LOADED, this.id, this.name));
			return false;
		}

		if(!this.isModified && !force)
		{
			SqLog.Wrn("Map::Save >> %s", format(MapCodes.NOT_MODIFIED, this.id, this.name));
			return false;
		}

		this.isModified = false;

		local query = g_MapsDatabase.connection.Query("DELETE FROM [MapsData] WHERE [map_id] = @mapID");
		query.Param("@mapID").SetInteger(this.id);
		query.Exec();

		foreach(object in this.objects)
		{
			query = g_MapsDatabase.connection.Query(@"INSERT INTO [MapsData] (map_id, object_model, object_position, object_rotation)
										VALUES (@mapID, @objectModel, @objectPosition, @objectRotation);");
			query.Param("@mapID").SetInteger(this.id);
			query.Param("@objectModel").SetInteger(object.Model);
			query.Param("@objectPosition").SetString(toJSON.encode({x = object.Position.x, y = object.Position.y, z = object.Position.z}));
			query.Param("@objectRotation").SetString(toJSON.encode({x = object.EulerRotX, y = object.EulerRotY, z = object.EulerRotZ}));

			query.Exec();
		}

		SqLog.Inf("Map::Save >> %s", format(MapCodes.MAP_SAVED, this.id, this.name));
	}

	/***
	--- Objects
	***/

	function AddObject(model, position, rotation)
	{
		local object = SqObject.Create(model, 1, position, 255);
		object.RotateToEuler(rotation, 0);

		this.objects.push(object);
		this.isModified = true;
	}

	function DelObject(object)
	{
		foreach(index, _object in this.objects)
		{
			if(_object == object)
				this.objects.remove(index);
		}
		
		this.isModified = true;
	}
}