// Item ids
enum ItemID
{
	NULL_ITEM,
	
	GRASS_BLOCK,
	STONE_BLOCK,
	WOOD_BLOCK,
	LEAF_BLOCK,
	
	PICKAXE_IRON,
	
	AXE_IRON,
	
	CRAFTING_BENCH,
	
	SHORTSWORD_WOODEN,
	
	WOODEN_BOW,
	
	STICK,
	BERRIES,
	
	MAX_ITEMS
}

/*array<TileData> =
{
	TileData(GRASS_BLOCK, "Grass block", "A block of grass")
}*/

// While i prefer this way of handling item data,
// it has the unfortunate downside of requiring 
// manual maintenance of the script writer each
// time an item is added to ItemID.
grid<string> ITEM_STRINGS = {
	{ "NULL", "" },
	
	{ "Grass block", "A block of grass" },
	{ "Stone block", "A block of stone" },
	{ "Wood block", "A block of wood" },
	{ "Leaf block", "A block of leaves" },
	
	{ "Iron Pickaxe", "A iron pickaxe" },
	
	{ "Iron Axe", "A iron axe for chopping wood" },
	
	{ "Crafting Bench", "A bench for crafting" },
	
	{ "Wooden Shortsword", "A crappy sword" },
	{ "Wooden Bow", "A wooden bow" },
	
	{ "Stick", "A stick" },
	{ "Berries", "Yummy!" }
};

array<Sprite@> ITEM_ICONS = {
	null,
	
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/grass_tile.png"), 0.25f, 0.25f, 0.75f, 0.75f * 2.0f/3.0f)),
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/stone_tile.png"), 0.25f, 0.25f, 0.75f, 0.75f * 2.0f/3.0f)),
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/wood_tile.png"), 0.25f, 0.25f, 0.75f, 0.75f * 2.0f/3.0f)),
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/leaf_tile.png"), 0.25f, 0.25f, 0.75f, 0.75f * 2.0f/3.0f)),
	
	@Sprite(@Texture(":/sprites/pickaxes/pickaxe_iron_icon.png")),
	
	@Sprite(@Texture(":/sprites/axes/iron_axe_item.png")),
	
	@Sprite(@Texture(":/sprites/plants/berry_bush.png")),
	
	@Sprite(@Texture(":/sprites/weapons/shortsword_wooden_item.png")),
	@Sprite(@Texture(":/sprites/weapons/wooden_bow_icon.png")),
	
	@Sprite(@Texture(":/sprites/items/stick.png")),
	@Sprite(@Texture(":/sprites/items/berries.png"))
};