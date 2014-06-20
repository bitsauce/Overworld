class ItemData
{
	string desc = "[No description]";
	int maxStack = 255;
	Sprite @image;
	
	ItemData()
	{
	}
}

class Inventory : GameObject
{
	Sprite @itemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot.png"));
	Sprite @selectedItemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot_selected.png"));
	int selectedSlot = 0;
	
	void addItem(ItemData id)
	{
	}
	
	void update()
	{
		if(Input.getKeyState(KEY_1)) selectedSlot = 0;
		if(Input.getKeyState(KEY_2)) selectedSlot = 1;
		if(Input.getKeyState(KEY_3)) selectedSlot = 2;
		if(Input.getKeyState(KEY_4)) selectedSlot = 3;
		if(Input.getKeyState(KEY_5)) selectedSlot = 4;
		if(Input.getKeyState(KEY_6)) selectedSlot = 5;
		if(Input.getKeyState(KEY_7)) selectedSlot = 6;
		if(Input.getKeyState(KEY_8)) selectedSlot = 7;
		if(Input.getKeyState(KEY_9)) selectedSlot = 8;
	}
	
	void draw()
	{
		int hoveredItemSlot = -1;
		for(int i = 0; i < 9; i++)
		{
			Sprite @slotSprite;
			if(selectedSlot == i)
			{
				@slotSprite = @selectedItemSlot;
			}else{
				@slotSprite = @itemSlot;
			}
			slotSprite.setPosition(Vector2(5 + 34*i, 5));
			slotSprite.draw(global::batches[global::GUI]);
			if(Rect(slotSprite.getPosition(), slotSprite.getSize()).contains(Input.position))
				hoveredItemSlot = i;
		}
		
		if(hoveredItemSlot >= 0) {
			arial.draw(global::batches[global::GUI], Input.position + Vector2(16.0f, 0.0f), "Item");
		}
	}
}