class BlockItem : ItemData
{
	TileID tile;
	
	BlockItem(ItemID id, const string &in name, const string &in desc, Sprite @icon, const int maxStack)
	{
		super(id, name, desc, @icon, maxStack, false);
		tile = Tiles.getByItem(id);
	}
	
	void use(Player @player)
	{
		Console.log("t: "+tile);
		Vector2 dt = Input.position + Camera.position - player.body.getPosition();
		if(dt.length() <= ITEM_PICKUP_RADIUS)
		{
			TerrainLayer layer = getLayerByTile(tile);
			Vector2 pos = (Input.position + Camera.position)/TILE_PX;
			pos.x = Math.floor(pos.x); pos.y = Math.floor(pos.y);
			if(!Terrain.isTileAt(pos.x, pos.y, layer) && player.inventory.removeItem(@this))
			{
				Terrain.setTile(pos.x, pos.y, tile);
			}
		}
	}
}