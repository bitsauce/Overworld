bool PickaxePlotTest(int x, int y)
{
	return scene::game.getTerrain().getTileAt(x, y, TERRAIN_SCENE) <= RESERVED_TILE &&
			scene::game.getTerrain().getTileAt(x, y, TERRAIN_BACKGROUND) <= RESERVED_TILE &&
			scene::game.getTerrain().getTileAt(x, y, TERRAIN_FOREGROUND) <= RESERVED_TILE;
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
		Vector2 dt = Input.position + game::camera.position - player.body.getPosition();
		Vector2i pos;
		if(ray.test(player.body.getPosition()/TILE_SIZE, (Input.position + game::camera.position)/TILE_SIZE, pos)) //if(dt.length() <= ITEM_PICKUP_RADIUS)
		{
			//Vector2i pos = Vector2i((Input.position + game::camera.position)/TILE_SIZE);
			TileID tile = game::terrain.getTileAt(pos.x, pos.y);
			TerrainLayer layer = TERRAIN_SCENE;
			if(tile == NULL_TILE) { layer = TERRAIN_FOREGROUND; tile = game::terrain.getTileAt(pos.x, pos.y, layer); }
			if(tile == NULL_TILE) { layer = TERRAIN_BACKGROUND; tile = game::terrain.getTileAt(pos.x, pos.y, layer); }
			if(prevPos == pos && tile != NULL_TILE)
			{
				time += Graphics.dt;
				if(time >= power)
				{
					game::terrain.removeTile(pos.x, pos.y, layer);
					game::tiles[tile].createItemDrop(pos.x, pos.y);
				}
			}else{
				time = 0.0f;
			}
			prevPos = pos;	
		}
	}
	
	void breakBackground()
	{
	}
	
}