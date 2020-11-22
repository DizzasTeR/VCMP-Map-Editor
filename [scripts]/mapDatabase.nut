class MapDatabase
{
    static DEFAULT_DB = "Maps.db";

    connection  = null;

    constructor(dbName = null)
    {
        if(dbName == null)
            dbName = MapDatabase.DEFAULT_DB;

        this.connection = SQLite.Connection(dbName);
        if(this.connection)
        {
            SqLog.Inf("[MODULE] MapDatabase instance successful!");
            SqLog.Inf("[MODULE] Creating database structure if not present...");
            this.connection.Exec(@"CREATE TABLE IF NOT EXISTS [Maps] (
                [id]            INTEGER
                                    PRIMARY KEY AUTOINCREMENT
                                    UNIQUE
                                    NOT NULL,
                [name]          VARCHAR (64)
                                    UNIQUE
                                    NOT NULL
            );");

            this.connection.Exec(@"CREATE TABLE IF NOT EXISTS [MapsData] (
                [map_id]            INTEGER
                                    NOT NULL,
                [object_model]      INTEGER
                                    NOT NULL,
                [object_position]   TEXT
                                    NOT NULL,
                [object_rotation]   TEXT
                                    NOT NULL
                
            );");
        }
    }
}