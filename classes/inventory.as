class ItemData
{
	string desc = "[No description]";
	int maxStack = 255;
	int stack = 0;
	Sprite @icon = null;
	
	ItemData()
	{
	}
}

class ItemSlot
{
	ItemData @data;
	int amount;
		
	void set(ItemData @data, int amount)
	{
		@this.data = @data;
		this.amount = amount;
	}
	
	int fill(int amount)
	{
		int dt = 0;
		this.amount += amount;
		if(this.amount > data.maxStack)
		{
			// Slot was overfilled, return delta
			dt = this.amount - data.maxStack;
			this.amount = data.maxStack;
		}
		return dt;
	}
	
	bool isEmpty()
	{
		return @data == null;
	}
	
	bool contains(ItemData @data)
	{
		return @data == @data;
	}
}

const int INV_WIDTH = 9;
const int INV_HEIGHT = 3;

class Inventory : GameObject
{
	Sprite @itemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot.png"));
	Sprite @selectedItemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot_selected.png"));
	int selectedSlot = 0;
	grid<ItemSlot> slots(INV_WIDTH, INV_HEIGHT);
	
	int addItem(ItemData @data, int amount = 1)
	{
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				ItemSlot @slot = @slots[x, y];
				if(slot.isEmpty())
				{
					// This slot is empty.
					// Fill it with item data.
					slot.set(@data, amount);
					amount = 0;
				}
				else if(slot.contains(@data))
				{
					// This slot contains the same item.
					// Fill this slot with 'amount'.
					amount = slot.fill(amount);
				}
				
				// No more left, break
				if(amount == 0)
					break;
			}
		}
		return amount; // Return remainding amount
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
		for(int i = 0; i < INV_WIDTH; i++)
		{
			// Draw item icon
			ItemSlot @slot = slots[i, 0];
			if(slot.data != null)
			{
				Sprite @icon = slot.data.icon;
				icon.setPosition(Vector2(5 + 34*i, 5) + Vector2(8, 8));
				icon.draw(global::batches[global::GUI]);
				global::arial8.setColor(Vector4(1.0f));
				string str = formatInt(slot.amount, "");
				global::arial8.draw(global::batches[global::UITEXT], Vector2(5 + 34*i, 5) + Vector2(28 - global::arial8.getStringWidth(str), 20), str);
			}
			
			// Draw slot sprite
			Sprite @slotSprite;
			if(selectedSlot == i)
			{
				@slotSprite = @selectedItemSlot;
			}else{
				@slotSprite = @itemSlot;
			}
			slotSprite.setPosition(Vector2(5 + 34*i, 5));
			slotSprite.draw(global::batches[global::GUI]);
			if(Rect(slotSprite.getPosition(), slotSprite.getSize()).contains(Input.position)) {
				hoveredItemSlot = i;
			}
		}
		
		if(hoveredItemSlot >= 0 && @slots[hoveredItemSlot, 0].data != null) {
			arial.draw(global::batches[global::UITEXT], Input.position + Vector2(16.0f, 0.0f), slots[hoveredItemSlot, 0].data.desc);
		}
	}
}