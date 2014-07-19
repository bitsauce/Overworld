// ADDING ITEMS:
// 1) Create an ID for the item by adding it to the ItemID enum. (for example DRAGON_TOOTH_BLADE)
// 2) Modify ITEM_STRINGS so that the item name and description is in the correct spot
//    relative to it's ItemID. (for example { "Dragon Tooth Blade", "Taste my steel!" })
// 3) Create a new class that inherits the Item class, and implement its spesific behaviour
//    in the function(s) 'void use(Player @player)'.
// 4) Add the item to the ItemManager (see its constructor) using you're newly created item-class

enum ItemID
{
	NULL_ITEM,
	
	GRASS_BLOCK,
	WOOD_BLOCK,
	LEAF_BLOCK,
	STONE_BLOCK,
	
	PICKAXE_IRON,
	
	SHORTSWORD_WOODEN,
	
	STICK,
	BERRIES,
	
	MAX_ITEMS
}

// While i prefer this way of handling item data,
// it has the unfortunate downside of requiring 
// manual maintinance of the script writer each
// time a item is added to ItemID.
grid<string> ITEM_STRINGS = {
	{ "NULL", "" },
	{ "Grass block", "A block of grass" },
	{ "Wooden block", "A block of wood" },
	{ "Leaf block", "A block of leaves" },
	{ "Stone block", "A block of stone" },
	{ "Iron Pickaxe", "A iron pickaxe" },
	{ "Wooden Shortsword", "A crappy sword" },
	{ "Stick", "A stick" },
	{ "Berries", "Yummy!" }
};

array<Sprite@> ITEM_ICONS = {
	null,
	@Sprite(@TextureRegion(@Texture(":/sprites/tiles/grass_tile.png"), 1.0f/21.0f * 16, 0.0f, 1.0f/21.0f * (16+1), 1.0f)),
	@Sprite(@TextureRegion(@Texture(":/sprites/tiles/tree_tile.png"), 1.0f/21.0f * 16, 0.0f, 1.0f/21.0f * (16+1), 1.0f)),
	@Sprite(@TextureRegion(@Texture(":/sprites/tiles/leaf_tile.png"), 1.0f/21.0f * 16, 0.0f, 1.0f/21.0f * (16+1), 1.0f)),
	@Sprite(@TextureRegion(@Texture(":/sprites/tiles/stone_tile.png"), 1.0f/21.0f * 16, 0.0f, 1.0f/21.0f * (16+1), 1.0f)),
	@Sprite(@Texture(":/sprites/pickaxes/pickaxe_iron_icon.png")),
	@Sprite(@Texture(":/sprites/weapons/shortsword_wooden_item.png")),
	@Sprite(@Texture(":/sprites/items/stick.png")),
	@Sprite(@Texture(":/sprites/items/berries.png"))
};

class Item
{
	string name;
	string desc;
	int maxStack;
	Sprite @icon;
	bool singleShot;
	
	Item(ItemID id, int maxStack)
	{
		this.name = ITEM_STRINGS[0, id];
		this.desc = ITEM_STRINGS[1, id];
		@this.icon = @ITEM_ICONS[id];
		this.maxStack = maxStack;
		this.singleShot = false;
	}
	
	void use(Player @player) {}
}

class ItemManager
{
	private array<Item@> data(MAX_ITEMS);
	
	ItemManager()
	{
		addItem(GRASS_BLOCK, @BlockItem(GRASS_BLOCK, GRASS_TILE));
		addItem(WOOD_BLOCK, @BlockItem(WOOD_BLOCK, GRASS_TILE/*TREE_TILE*/));
		addItem(LEAF_BLOCK, @BlockItem(LEAF_BLOCK, GRASS_TILE/*LEAF_TILE*/));
		addItem(STONE_BLOCK, @BlockItem(STONE_BLOCK, GRASS_TILE/*STONE_TILE*/));
		addItem(PICKAXE_IRON, @Pickaxe(PICKAXE_IRON));
		addItem(SHORTSWORD_WOODEN, @ArrowItem(SHORTSWORD_WOODEN));
		addItem(STICK, @ArrowItem(STICK));
		addItem(BERRIES, @HealingPotion(BERRIES));
		//@global::items = @this;
	}
	
	private void addItem(ItemID id, Item @item)
	{
		@data[id] = @item;
	}
	
	Item @opIndex(int idx)
	{
		if(idx < 0 || idx >= data.size)
			return null;
		return @data[idx];
	}
	
	Item @getItem(ItemID id)
	{
		return @data[id];
	}
	
	ItemID find(Item @d)
	{
		return @d != null ? ItemID(data.findByRef(@d)) : NULL_ITEM;
	}
}