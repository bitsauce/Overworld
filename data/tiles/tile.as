class Tile
{
	private Texture @texture;
	ItemID item;
	//TileID id;
	
	Tile(Texture @texture, ItemID item = NULL_ITEM)
	{
		@this.texture = @texture;
		this.item = item;
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
	
	Texture @getTexture() const
	{
		return @texture;
	}
}