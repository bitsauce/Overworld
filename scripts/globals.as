namespace global
{
	enum Layer
	{
		BACKGROUND,
		SCENE,
		FOREGROUND,
		GUI,
		UITEXT,
		NUM_LAYERS
	}
	
	array<Batch@> batches(NUM_LAYERS);
	
	array<Player@> players;
	array<GameObject@> gameObjects;
	TimeOfDay @timeOfDay;
	
	Font @arial12 = @Font("Arial Bold", 12);
	Font @arial8 = @Font("Arial", 8);
	
	ItemManager @items = @ItemManager();
	
	Terrain @terrain;
}