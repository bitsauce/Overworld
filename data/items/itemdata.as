// Item ids
enum ItemID
{
	NULL_ITEM,
	
	GRASS_BLOCK,
	STONE_BLOCK,
	WOOD_BLOCK,
	LEAF_BLOCK,
	
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
	{ "Stone block", "A block of stone" },
	{ "Wood block", "A block of wood" },
	{ "Leaf block", "A block of leaves" },
	{ "Iron Pickaxe", "A iron pickaxe" },
	{ "Wooden Shortsword", "A crappy sword" },
	{ "Stick", "A stick" },
	{ "Berries", "Yummy!" }
};

array<Sprite@> ITEM_ICONS = {
	null,
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/grass_tile.png"), 0.0f, 0.0f, 1.0f, 2.0f/3.0f)),
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/stone_tile.png"), 0.0f, 0.0f, 1.0f, 2.0f/3.0f)),
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/wood_tile.png"), 0.0f, 0.0f, 1.0f, 2.0f/3.0f)),
	@Sprite(TextureRegion(@Texture(":/sprites/tiles/leaf_tile.png"), 0.0f, 0.0f, 1.0f, 2.0f/3.0f)),
	@Sprite(@Texture(":/sprites/pickaxes/pickaxe_iron_icon.png")),
	@Sprite(@Texture(":/sprites/weapons/shortsword_wooden_item.png")),
	@Sprite(@Texture(":/sprites/items/stick.png")),
	@Sprite(@Texture(":/sprites/items/berries.png"))
};