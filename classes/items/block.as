class BlockItem : Item
{
	TileID tile;
	
	BlockItem(ItemID id)
	{
		super(id, 255);
		tile = game::tiles.getByItem(id);
	}
	
	void use(Player @player)
	{
		Vector2 dt = Input.position + game::camera.position - player.body.getPosition();
		if(dt.length() <= ITEM_PICKUP_RADIUS)
		{
			TerrainLayer layer = game::terrain.getLayerByTile(tile);
			Vector2i pos = Vector2i((Input.position + game::camera.position)/TILE_SIZE);
			if(!game::terrain.isTileAt(pos.x, pos.y, layer) && player.inventory.removeItem(@this))
			{
				game::terrain.addTile(pos.x, pos.y, tile);
			}
		}
	}
}