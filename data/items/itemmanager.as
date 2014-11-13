class ItemManager
{
	private array<Item@> items(MAX_ITEMS);
	private bool initialized = false;
	
	void init()
	{
		// Make sure the manager is not initialized already
		if(initialized)
			return;
		
		// Add items
		add(GRASS_BLOCK, @BlockItem(GRASS_BLOCK));
		add(STONE_BLOCK, @BlockItem(STONE_BLOCK));
		add(WOOD_BLOCK, @BlockItem(WOOD_BLOCK));
		add(LEAF_BLOCK, @BlockItem(LEAF_BLOCK));
		add(AXE_IRON, @Axe(AXE_IRON));
		add(PICKAXE_IRON, @Pickaxe(PICKAXE_IRON));
		add(SHORTSWORD_WOODEN, @ArrowItem(SHORTSWORD_WOODEN));
		add(CRAFTING_BENCH, @PlaceableItem(CRAFTING_BENCH));
		
		add(WOODEN_BOW, @Bow(WOODEN_BOW));
		add(STICK, @ArrowItem(STICK));
		add(BERRIES, @HealingPotion(BERRIES));
		
		// Mark as initialized
		initialized = true;
	}
	
	void add(ItemID id, Item @item)
	{
		// Make sure the manager is not initialized
		if(initialized)
			return;
		
		// Set item
		@items[id] = @item;
	}
	
	Item @opIndex(int idx)
	{
		// Validate index and manager state
		if(!initialized || idx < 0 || idx >= MAX_ITEMS)
			return null;
		return @items[idx];
	}
}