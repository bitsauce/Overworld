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
		Vector2 dt = Input.position + global::camera.position - player.getCenter();
		if(dt.length() <= ITEM_PICKUP_RADIUS)
		{
			TerrainLayer layer = global::terrain.getLayerByTile(tile);
			Vector2i pos = Vector2i((Input.position + global::camera.position)/TILE_SIZE);
			if(!global::terrain.isTileAt(pos.x, pos.y, layer) &&
				player.inventory.removeItem(@this))
			{
				global::terrain.addTile(pos.x, pos.y, tile);
			}
		}
	}
}