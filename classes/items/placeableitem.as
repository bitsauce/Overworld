class PlaceableItem : ItemData
{
	PlaceableItem(ItemID id, const string &in name, const string &in desc, Sprite @icon, const int maxStack)
	{
		super(id, name, desc, @icon, maxStack, true);
		singleShot = true;
	}
	
	void use(Player @player)
	{
		if(player.inventory.removeItem(@this))
		{
			Furniture furn(2, 1);
			@furn.sprite = @Sprite(TextureRegion(@Textures[BERRY_BUSH_TEXTURE]));
			furn.place(Input.position.x/TILE_PXF, Input.position.y/TILE_PXF);
		}
	}
}