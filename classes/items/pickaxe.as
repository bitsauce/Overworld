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
		Vector2 dt = Input.position + global::camera.position - player.body.getPosition();
		if(dt.length() <= ITEM_PICKUP_RADIUS)
		{
			Vector2i pos = Vector2i((Input.position + global::camera.position)/TILE_SIZE);
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
						item.body.setPosition(Vector2(pos)*TILE_SIZE + item.size/2.0f);
					}
					break;
					case TREE_TILE:
					{
						ItemDrop item1(@global::items[STICK]);
						item1.body.setPosition(Vector2(pos)*TILE_SIZE + item1.size/2.0f);
						ItemDrop item2(@global::items[WOOD_BLOCK]);
						item2.body.setPosition(Vector2(pos)*TILE_SIZE + item2.size/2.0f);
					}
					break;
					case LEAF_TILE:
					{
						ItemDrop item(@global::items[LEAF_BLOCK]);
						item.body.setPosition(Vector2(pos)*TILE_SIZE + item.size/2.0f);
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