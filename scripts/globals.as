array<Texture@> TILE_TEXTURES(MAX_TILES);
Font @arial = @Font("Arial Bold", 12);

namespace global {
	enum Layer {
		BACKGROUND,
		FOREGROUND,
		GUI,
		UITEXT,
		NUM_LAYERS
	}
	array<Batch@> batches(NUM_LAYERS);
	array<Player@> players;
	array<GameObject@> gameObjects;
	TimeOfDay @timeOfDay;
	
	Font @arial8 = @Font("Arial", 8);
}