enum ItemType
{
	STICK,
	MAX_ITEMS
}

class ItemData
{
	string name;
	string desc;
	int maxStack;
	Sprite @icon;
	
	ItemData(string name, string desc, int maxStack, Sprite @icon)
	{
		this.name = name;
		this.desc = desc;
		this.maxStack = maxStack;
		@this.icon = @icon;
	}
}

array<ItemData@> ITEMS = {
	@ItemData("Grass block", "A block of grass", 255, @Sprite(@TextureRegion(@Texture(":/sprites/tiles/grass_tile.png"), 1.0f/21.0f * 16, 0.0f, 1.0f/21.0f * (16+1), 1.0f))),
	@ItemData("Stick", "A stick", 5, @Sprite(@Texture(":/sprites/items/stick.png")))
};


void loadItems()
{
}