namespace global
{
	array<Batch@> batches(LAYERS_MAX);
	
	array<Player@> players;
	array<GameObject@> gameObjects;
	TimeOfDay @timeOfDay;
	
	Font @arial12 = @Font("Arial Bold", 12);
	Font @arial8 = @Font("Arial", 8);
	
	Terrain @terrain;
	
	Camera camera;
	
	ItemManager items;
	
	DebugTextDrawer debug;
}