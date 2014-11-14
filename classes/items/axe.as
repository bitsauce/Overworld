class Axe : Item
{
	private Vector2i prevPos;
	RayCast ray;
	float time = 0.0f;
	int power = 0;
	
	Axe(ItemID id)
	{
		super(id, 1);
		
		@ray.plotTest = @PickaxePlotTest;
		ray.range = ITEM_PICKUP_RADIUS;
	}
	
	void use(Player @player)
	{
		Vector2 dt = Input.position + Camera.position - player.body.getPosition();
		Vector2i pos;
		if(ray.test(player.body.getPosition()/TILE_PX, (Input.position + Camera.position)/TILE_PX, pos))
		{
			TileID tile = Terrain.getTileAt(pos.x, pos.y, TERRAIN_BACKGROUND);
			if(prevPos == pos && tile == WOOD_TILE)
			{
				time += Graphics.dt;
				if(time >= power)
				{
					Terrain.removeTile(pos.x, pos.y, TERRAIN_BACKGROUND);
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