class PlaceableItem : Item
{
	PlaceableItem(ItemID id)
	{
		super(id, 255);
		singleShot = true;
	}
	
	void use(Player @player)
	{
		if(player.inventory.removeItem(@this))
		{
			Furniture furn(2, 1);
			@furn.sprite = @Sprite(TextureRegion(@Textures[BERRY_BUSH_TEXTURE]));
			furn.place(Input.position.x/TILE_SIZEF, Input.position.y/TILE_SIZEF);
		}
	}
}