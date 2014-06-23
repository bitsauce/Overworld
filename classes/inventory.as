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
	Player @player;
	Sprite @itemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot.png"));
	Sprite @selectedItemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot_selected.png"));
	int selectedSlot = 0;
	grid<ItemSlot> slots(INV_WIDTH, INV_HEIGHT);
	bool showBag = false;
	
	Inventory(Player @player)
	{
		@this.player = @player;
	}
	
	ItemData @getSelectedItem()
	{
		return @slots[selectedSlot, 0].data;
	}
	
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
			if(amount == 0)
				break;
		}
		return amount; // Return remainding amount
	}
	
	bool removeItem(ItemData @data, int amount = 1, int slotX = -1, int slotY = -1)
	{
		ItemSlot @slot;
		if(slotX <= 0 || slotY <= 0) {
			@slot = @slots[selectedSlot, 0];
		}else{
			@slot = @slots[slotX, slotY];
		}
		
		if(!slot.isEmpty()) {
			slot.amount -= amount;
			if(slot.amount <= 0) {
				@slot.data = null;
				Console.log("outf");
			}
			return true;
		}
		return false;
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
		if(Input.getKeyState(KEY_TAB)) showBag = true;
		else showBag = false;
		if(Input.getKeyState(KEY_Q))
		{
			removeItem(@global::items[GRASS_BLOCK], 1, selectedSlot, 0);
			Item item();
			item.setPosition(player.getCenter());
			item.body.applyImpulse(Vector2(1.0f,-1.0f)*5000.0f, item.getCenter());
		}
	}
	
	void draw()
	{
		int hoveredItemSlot = -1;
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				// Draw item icon
				ItemSlot @slot = slots[x, y];
				if(slot.data != null)
				{
					Sprite @icon = slot.data.icon;
					icon.setPosition(Vector2(5 + 34*x, 5 + 34*y) + Vector2(8, 8));
					icon.draw(global::batches[global::GUI]);
					global::arial8.setColor(Vector4(1.0f));
					string str = formatInt(slot.amount, "");
					global::arial8.draw(global::batches[global::UITEXT], Vector2(5 + 34*x, 5 + 34*y) + Vector2(28 - global::arial8.getStringWidth(str), 20), str);
				}
				
				// Draw slot sprite
				Sprite @slotSprite;
				if(y == 0 && selectedSlot == x)
				{
					@slotSprite = @selectedItemSlot;
				}else{
					@slotSprite = @itemSlot;
				}
				slotSprite.setPosition(Vector2(5 + 34*x, 5 + 34*y));
				slotSprite.draw(global::batches[global::GUI]);
				if(Rect(slotSprite.getPosition(), slotSprite.getSize()).contains(Input.position)) {
					hoveredItemSlot = x;
				}
			}
			if(!showBag) break;
		}
		
		if(hoveredItemSlot >= 0 && @slots[hoveredItemSlot, 0].data != null) {
			arial.draw(global::batches[global::UITEXT], Input.position + Vector2(16.0f, 0.0f), slots[hoveredItemSlot, 0].data.desc);
		}
	}
}