class Recipe
{
	grid<ItemID> @recipe;
	ItemID result;
	
	Recipe(ItemID x0y0, ItemID x1y0, ItemID x2y0,
			ItemID x0y1, ItemID x1y1, ItemID x2y1,
			ItemID x0y2, ItemID x1y2, ItemID x2y2,
			ItemID result)
	{
		grid<ItemID> arr = {
			{ x0y0, x1y0, x2y0 },
			{ x0y1, x1y1, x2y1 },
			{ x0y2, x1y2, x2y2 }
		};
		@this.recipe = @arr;
		this.result = result;
	}
}
