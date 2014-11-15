class ItemManager
{
	private array<ItemData@> items(ITEM_COUNT);
	private bool initialized = false;
	
	void init()
	{
		// Make sure the manager is not initialized already
		if(initialized)
			return;
		
		// Add all item data
		for(int i = 0; i < ITEM_DATA.size; ++i)
		{
			ItemData @data = @ITEM_DATA[i];
			@items[data.getID()] = @data;
		}
		
		// Mark as initialized
		initialized = true;
	}
	
	ItemData @opIndex(int idx)
	{
		// Validate index and manager state
		if(!initialized || idx < 0 || idx >= ITEM_COUNT)
			return null;
		return @items[idx];
	}
}