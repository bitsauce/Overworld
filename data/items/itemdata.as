// HOW TO ADD NEW ITEMS:
// 1) Add an id for the item in ItemID (naming: ITEM_ITEM_NAME_HERE)
// 2) Add an entry for the item in the ITEM_DATA array
//    This has the format:
//    ItemData(id, name, description, icon, maxStack, singleShot [default = false])
//    singleShot = only activate once per click
//
// HOW TO IMPLEMENT CUSTOM ITEM BEHAVIOUR:
// If you want to implement custom item behaviour, you'll need
// to create a new class which inherits ItemData.
// In this class you'll implement custom behaviour by
// overriding the function: 'void use(Player @player)',
// which will be called each time the player tries
// to activate the item.

// ITEM IDS
enum ItemID
{
	ITEM_NULL,
	
	ITEM_GRASS_BLOCK,
	ITEM_STONE_BLOCK,
	ITEM_WOOD_BLOCK,
	ITEM_LEAF_BLOCK,
	
	ITEM_PICKAXE_IRON,
	
	ITEM_AXE_IRON,
	
	ITEM_CRAFTING_BENCH,
	
	ITEM_SHORTSWORD_WOODEN,
	
	ITEM_WOODEN_BOW,
	
	ITEM_STICK,
	ITEM_BERRIES,
	
	ITEM_COUNT
}

// ITEM DATA
array<ItemData@> ITEM_DATA =
{
	// BLOCK ITEMS
	BlockItem(ITEM_GRASS_BLOCK, "Grass block", "A block of grass", @Sprite(TextureRegion(@Texture(":/sprites/tiles/grass_tile.png"), TILE_U1, TILE_V1, TILE_U3, TILE_V3)), 255),
	BlockItem(ITEM_STONE_BLOCK, "Stone block", "A block of stone", @Sprite(TextureRegion(@Texture(":/sprites/tiles/stone_tile.png"), TILE_U1, TILE_V1, TILE_U3, TILE_V3)), 255),
	BlockItem(ITEM_WOOD_BLOCK, "Wood block", "A block of wood", @Sprite(TextureRegion(@Texture(":/sprites/tiles/wood_tile.png"), TILE_U1, TILE_V1, TILE_U3, TILE_V3)), 255),
	BlockItem(ITEM_LEAF_BLOCK, "Leaf block", "A block of leaves", @Sprite(TextureRegion(@Texture(":/sprites/tiles/leaf_tile.png"), TILE_U1, TILE_V1, TILE_U3, TILE_V3)), 255),
	
	// PICKAXES
	PickaxeItem(ITEM_PICKAXE_IRON, "Iron pickaxe", "An iron pickaxe", @Sprite(@Texture(":/sprites/pickaxes/pickaxe_iron_icon.png"))),
	
	// AXES
	AxeItem(ITEM_AXE_IRON, "Iron axe", "An iron axe", @Sprite(@Texture(":/sprites/axes/iron_axe_item.png"))),
	
	// FURNITURE
	PlaceableItem(ITEM_CRAFTING_BENCH, "Crafting bench", "A bench for crafting things", @Sprite(TextureRegion(@Texture(":/sprites/tiles/grass_tile.png"), TILE_U1, TILE_V1, TILE_U3, TILE_V3)), 1),
	
	// SWORDS
	ArrowItem(ITEM_SHORTSWORD_WOODEN, "Wooden shortsword", "A wooden sword", @Sprite(@Texture(":/sprites/weapons/shortsword_wooden_item.png")), 1),
	
	// BOWS
	BowItem(ITEM_WOODEN_BOW, "Wooden bow", "A wooden bow for shooting things", @Sprite(@Texture(":/sprites/weapons/wooden_bow_icon.png"))),
	
	// ARROWS
	ArrowItem(ITEM_STICK, "Stick", "Catch!", @Sprite(@Texture(":/sprites/items/stick.png")), 1),
	
	// FOOD ITEMS
	HealingItem(ITEM_BERRIES, "Berries", "Yummy!", @Sprite(@Texture(":/sprites/items/berries.png")), 1)
};

// ITEM DATA CLASS
class ItemData
{
	private ItemID id;
	string name;
	string desc;
	int maxStack;
	Sprite @icon;
	bool singleShot;
	
	ItemData()
	{
		this.id = ITEM_NULL;
	}
	
	ItemData(ItemID id, const string &in name, const string &in desc, Sprite @icon, const int maxStack, const bool singleShot = false)
	{
		this.id = id;
		this.name = name;
		this.desc = desc;
		@this.icon = @icon;
		this.icon.setSize(Vector2(16));
		this.maxStack = maxStack;
		this.singleShot = singleShot;
	}
	
	ItemID getID() const
	{
		return id;
	}
	
	void use(Player @player) { /* Virtual function */ }
}