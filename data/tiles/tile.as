class Tile
{
	private TileID id;
	private Texture @texture;
	private ItemID item;
	private float opacity;
	
	Tile(TileID id)
	{
		this.id = id;
		@this.texture = @TILE_TEXTURES[id];
		this.item = TILE_ITEMS[id];
		this.opacity = TILE_OPACITIES[id];
	}
	
	void createItemDrop(int x, int y)
	{
		ItemDrop itemDrop(@game::items[item]);
		itemDrop.body.setPosition(Vector2(x, y) * TILE_SIZE + itemDrop.size/2.0f);
	}
	
	void setupFixture(b2Fixture @fixture)
	{
		fixture.setFriction(0.5f);
	}
	
	TileID getID() const
	{
		return id;
	}
	
	Texture @getTexture() const
	{
		return @texture;
	}
	
	ItemID getItemID() const
	{
		return item;
	}
	
	float getOpacity() const
	{
		return opacity;
	}
}