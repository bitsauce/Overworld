class RecipeManager
{
	bool initialized = false;
	array<Recipe> recipes;
	
	void init()
	{
		initialized = true;
		
		add(grid<ItemID> = { 
				{ ITEM_WOOD_BLOCK },
				{ ITEM_WOOD_BLOCK }
			}, ITEM_STICK, 8);
			
		add(grid<ItemID> = { 
				{ ITEM_WOOD_BLOCK, ITEM_WOOD_BLOCK, ITEM_WOOD_BLOCK },
				{ ITEM_WOOD_BLOCK, ITEM_WOOD_BLOCK, ITEM_WOOD_BLOCK },
				{ ITEM_WOOD_BLOCK, ITEM_WOOD_BLOCK, ITEM_WOOD_BLOCK }
			}, ITEM_CRAFTING_BENCH, 1);
	}
	
	private void add(grid<ItemID> @pattern, ItemID result, uint amount)
	{
		Recipe r;
		@r.pattern = @pattern;
		r.result = result;
		r.amount = amount;
		recipes.insertLast(r);
	}
	
	uint get_size() const
	{
		return recipes.size;
	}
	
	Recipe @opIndex(uint idx)
	{
		// Validate index and manager state
		if(!initialized || idx < 0 || idx >= recipes.size)
			return null;
		return @recipes[idx];
	}
}

class Recipe
{
	grid<ItemID> @pattern;	// The recipe item pattern
	ItemID result;			// The result of the recipe
	uint amount;			// The amount of result items the recipe gives
}