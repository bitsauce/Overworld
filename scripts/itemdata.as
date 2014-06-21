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
	@ItemData("Stick", "A stick", 5, @Sprite(@Texture(":/sprites/items/stick.png")))
};


void loadItems()
{
}