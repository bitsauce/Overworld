class WorldManager
{
	// WORLD PATH
	private string worldPath;
	private IniFile @worldFile;
	private bool loaded = false;
	string getWorldPath() const { return worldPath; }
	
	// GAME OBJECTS
	private array<GameObject@> objects;
	void addGameObject(GameObject @object) { objects.insertLast(@object); }
	void removeGameObject(GameObject @object) { int idx = objects.findByRef(@object); if(idx >= 0) { objects.removeAt(idx); } }
	
	// FURNITURE
	private array<Furniture@> furnitures;
	void addFurniture(Furniture @furniture) { furnitures.insertLast(@furniture); }
	void removeFurniture(Furniture @furniture) { int idx = furnitures.findByRef(@furniture); if(idx >= 0) { furnitures.removeAt(idx); } }
	Furniture @getHoveredFurniture() const { for(int i = 0; i < furnitures.size; ++i) { if(furnitures[i].isHovered()) return @furnitures[i]; } return null; }	
	
	// PLAYERS
	private array<Player@> players;
	void addPlayer(Player @player) { players.insertLast(@player); }
	void removePlayer(Player @player) { int idx = players.findByRef(@player); if(idx >= 0) { players.removeAt(idx); } }
	Player @getClosestPlayer(const Vector2 position, float &out distance = void) const { if(players.size == 0) return null; Player @player = null; float minDist = 0.0f; for(int i = 0; i < players.size; ++i) { float tmpDist = (players[i].body.getCenter() - position).length(); if(tmpDist < minDist || @player == null) { minDist = distance = tmpDist; @player = @players[i]; } } return player; }
	
	// GAME OBJECTS
	void update()
	{
		// Update game objects
		for(int i = 0; i < objects.size; ++i) {
			objects[i].update();
		}
	}
	
	void draw()
	{
		// Draw game objects
		for(int i = 0; i < objects.size; ++i) {
			objects[i].draw();
		}
	}
	
	void clear()
	{
		objects.clear();
		furnitures.clear();
		players.clear();
	}
	
	// WORLD FUNCTIONS
	void create(string worldPath)
	{
		// Set the world path
		this.worldPath = worldPath;
		@this.worldFile = @IniFile(worldPath + "/world.ini");
		
		// Create world file
		worldFile.setValue("world", "name", worldPath.split("/").last());
		worldFile.save();
		
		Console.log("Creating player...");
		
		// Create player
		Player player();
		player.body.setPosition(Vector2(0, Terrain.generator.getGroundHeight(0)*TILE_PX));
		
		// Give default loadout
		player.inventory.addItem(@Items[ITEM_PICKAXE_IRON]);
		player.inventory.addItem(@Items[ITEM_AXE_IRON]);
		
		// Show game
		Engine.pushScene(@scene::game);
	}
	
	bool load(string worldPath)
	{
		// Validate world
		if(!FileSystem.fileExists(worldPath + "/world.ini"))
		{
			Console.log("Loading failed (missing files)");
			return false;
		}
		
		Console.log("Loading world: " + worldPath + "...");
		
		// Set the world path
		this.worldPath = worldPath;
		@this.worldFile = @IniFile(worldPath + "/world.ini");
		
		// Load world file
		Terrain.generator.seed = parseInt(worldFile.getValue("world", "seed"));
		
		// Load time of day
		//TimeOfDay.setTime(parseInt(worldFile.getValue("world", "timeOfDay")));
		
		// Load all objects
		array<string> @objectFiles = @FileSystem.listFiles(worldPath + "/objects", "*.obj");
		for(int i = 0; i < objectFiles.size; ++i)
		{
			GameObject @object = cast<GameObject>(@Scripts.deserialize(objectFiles[i]));
			objects.insertLast(@object);
			
			Furniture @furniture = cast<Furniture>(object);
			if(@furniture != null) addFurniture(@furniture);
				
			Player @player = cast<Player>(object);
			if(@player != null) addPlayer(@player);
		}
		
		// World loaded
		this.loaded = true;
		worldFile.save();
		
		// Show game
		Engine.pushScene(@scene::game);
		
		return true;
	}
	
	void save()
	{
		if(!loaded) return;
		
		Console.log("Saving world...");
		
		// Save terrain
		worldFile.setValue("world", "seed", ""+Terrain.generator.seed);
		Terrain.saveChunks();
		
		// Save time of day
		//worldFile.setValue("world", "time", ""+TimeOfDay.getTime());
		
		// Save game objects
		FileSystem.remove(worldPath + "/objects");
		for(int i = 0; i < objects.size; ++i) {
			Scripts.serialize(cast<Serializable>(@objects[i]), worldPath + "/objects/" + i + ".obj");
		}
		
		// Save file
		worldFile.save();
	}
}