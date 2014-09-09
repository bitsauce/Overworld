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
			TerrainLayer layer = getLayerByTile(tile);
			Vector2 pos = (Input.position + game::camera.position)/TILE_SIZE;
			pos.x = Math.floor(pos.x); pos.y = Math.floor(pos.y);
			if(!game::terrain.isTileAt(pos.x, pos.y, layer) && player.inventory.removeItem(@this))
			{
				game::terrain.addTile(pos.x, pos.y, tile);
			}
		}
	}
}