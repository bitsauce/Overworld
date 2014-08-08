class BlockItem : Item
{
	private Tile tile;
	
	BlockItem(ItemID id, Tile tile)
	{
		super(id, 255);
		this.tile = tile;
	}
	
	void use(Player @player)
	{
		Vector2 dt = Input.position + game::camera.position - player.body.getPosition();
		if(dt.length() <= ITEM_PICKUP_RADIUS)
		{
			TerrainLayer layer = game::terrain.getLayerByTile(tile);
			Vector2i pos = Vector2i((Input.position + game::camera.position)/TILE_SIZE);
			if(!game::terrain.isTileAt(pos.x, pos.y, layer) &&
				player.inventory.removeItem(@this))
			{
				game::terrain.addTile(pos.x, pos.y, tile);
			}
		}
	}
}