class Pickaxe : Item
{
	private Vector2i prevPos;
	float time = 0.0f;
	int power = 0;
	
	Pickaxe(ItemID id)
	{
		super(id, 1);
	}
	
	void use(Player @player)
	{
		Vector2 dt = Input.position+camera - player.getCenter();
		if(dt.length() <= ITEM_PICKUP_RADIUS)
		{
			Vector2i pos = Vector2i((Input.position+camera)/TILE_SIZE);
			Tile tile = global::terrain.getTileAt(pos.x, pos.y);
			TerrainLayer layer = TERRAIN_SCENE;
			if(tile == NULL_TILE) { layer = TERRAIN_FOREGROUND; tile = global::terrain.getTileAt(pos.x, pos.y, layer); }
			if(tile == NULL_TILE) { layer = TERRAIN_BACKGROUND; tile = global::terrain.getTileAt(pos.x, pos.y, layer); }
			if(prevPos == pos && tile != NULL_TILE)
			{
				time += Graphics.dt;
				if(time >= power) {
					global::terrain.removeTile(pos.x, pos.y, layer);
					switch(tile)
					{
					case GRASS_TILE:
					{
						ItemDrop item(@global::items[GRASS_BLOCK]);
						item.setPosition(Vector2(pos)*TILE_SIZE);
					}
					break;
					case TREE_TILE:
					{
						ItemDrop item1(@global::items[STICK]);
						item1.setPosition(Vector2(pos)*TILE_SIZE);
						ItemDrop item2(@global::items[WOOD_BLOCK]);
						item2.setPosition(Vector2(pos)*TILE_SIZE);
					}
					break;
					case LEAF_TILE:
					{
						ItemDrop item(@global::items[LEAF_BLOCK]);
						item.setPosition(Vector2(pos)*TILE_SIZE);
					}
					}
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