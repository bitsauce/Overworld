bool PickaxePlotTest(int x, int y)
{
	return Terrain.getTileAt(x, y, TERRAIN_SCENE) <= RESERVED_TILE &&
			Terrain.getTileAt(x, y, TERRAIN_BACKGROUND) <= RESERVED_TILE &&
			Terrain.getTileAt(x, y, TERRAIN_FOREGROUND) <= RESERVED_TILE;
}

class Pickaxe : Item
{
	private Vector2i prevPos;
	float time = 0.0f;
	int power = 0;
	RayCast ray;
	
	Pickaxe(ItemID id)
	{
		super(id, 1);
		
		@ray.plotTest = @PickaxePlotTest;
		ray.range = ITEM_PICKUP_RADIUS;
	}
	
	void use(Player @player)
	{
		Vector2 dt = Input.position + Camera.position - player.body.getPosition();
		Vector2i pos;
		if(ray.test(player.body.getPosition()/TILE_SIZE, (Input.position + Camera.position)/TILE_SIZE, pos))
		{
			TileID tile = Terrain.getTileAt(pos.x, pos.y);
			TerrainLayer layer = TERRAIN_SCENE;
			if(tile == EMPTY_TILE) { layer = TERRAIN_FOREGROUND; tile = Terrain.getTileAt(pos.x, pos.y, layer); }
			if(tile == EMPTY_TILE) { layer = TERRAIN_BACKGROUND; tile = Terrain.getTileAt(pos.x, pos.y, layer); }
			if(prevPos == pos && tile != EMPTY_TILE)
			{
				time += Graphics.dt;
				if(time >= power)
				{
					Terrain.removeTile(pos.x, pos.y, layer);
					Tiles[tile].createItemDrop(pos.x, pos.y);
				}
			}
			else
			{
				time = 0.0f;
			}
			prevPos = pos;	
		}
	}
}