enum ItemID
{
	GRASS_BLOCK,
	TREE_BLOCK,
	STONE_BLOCK,
	
	PICKAXE_IRON,
	
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

class ItemManager
{
	private array<ItemData@> data(MAX_ITEMS);
	
	ItemManager()
	{
		addItem(GRASS_BLOCK, "Grass block", "A block of grass", 255, @Sprite(@TextureRegion(@Texture(":/sprites/tiles/grass_tile.png"), 1.0f/21.0f * 16, 0.0f, 1.0f/21.0f * (16+1), 1.0f)));
		addItem(STICK, "Stick", "A stick", 5, @Sprite(@Texture(":/sprites/items/stick.png")));
		addItem(PICKAXE_IRON, "Iron Pickaxe", "A pickaxe", 1, @Sprite(@Texture(":/sprites/pickaxes/pickaxe_iron_icon.png")));
		@global::items = @this;
	}
	
	private void addItem(ItemID id, string name, string desc, int maxStack, Sprite @icon)
	{
		@data[id] = @ItemData(name, desc, maxStack, @icon);
	}
	
	ItemData @opIndex(int idx)
	{
		return @data[idx];
	}
	
	ItemData @getItem(ItemID id)
	{
		return @data[id];
	}
	
	ItemID find(ItemData @d)
	{
		return ItemID(data.findByRef(@d));
	}
}