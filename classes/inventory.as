class ItemSlot
{
	Item @item;
	int amount;
		
	void set(Item @item, int amount)
	{
		@this.item = @item;
		this.amount = amount;
	}
	
	void clear()
	{
		@this.item = null;
		this.amount = 0;
	}
	
	int fill(int amount)
	{
		int dt = 0;
		this.amount += amount;
		if(this.amount > item.maxStack)
		{
			// Slot was overfilled, return delta
			dt = this.amount - item.maxStack;
			this.amount = item.maxStack;
		}
		return dt;
	}
	
	int remove(int amount)
	{
		int dt = amount;
		this.amount -= amount;
		if(this.amount <= 0)
		{
			dt = amount + this.amount;
			@this.item = null;
			this.amount = 0;
		}
		return dt;
	}
	
	bool isEmpty()
	{
		return @item == null;
	}
	
	bool contains(Item @item)
	{
		return @this.item == @item;
	}
}

const int INV_WIDTH = 9;
const int INV_HEIGHT = 3;

class Inventory
{
	// Owner
	Player @player;
	
	// Slot sprites
	Sprite @itemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot.png"));
	Sprite @selectedItemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot_selected.png"));
	
	// Selected hot-bar slot
	int selectedSlot = 0;
	
	// Inventory slots
	grid<ItemSlot> slots(INV_WIDTH, INV_HEIGHT);
	
	// Show bag flag
	bool showBag = false;
	
	// Held item slot
	ItemSlot heldSlot;
	
	// Crafting slots
	grid<ItemSlot> craftingSlots(3, 3);
	
	array<Recipie@> recipies;
	
	Inventory(Player @player)
	{
		@this.player = @player;
		
		recipies.insertLast(@Recipie(
				NULL_ITEM, WOOD_BLOCK, NULL_ITEM,
				NULL_ITEM, WOOD_BLOCK, NULL_ITEM,
				NULL_ITEM, STICK, NULL_ITEM,
				SHORTSWORD_WOODEN
			)
		);
	}
	
	Item @getSelectedItem()
	{
		return @slots[selectedSlot, 0].item;
	}
	
	int addItem(Item @data, int amount = 1)
	{
		// Search for slots containing the same type of item
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				ItemSlot @slot = @slots[x, y];
				if(slot.contains(@data))
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
		
		// Search for empty slots
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
				
				// No more left, break
				if(amount == 0)
					break;
			}
			if(amount == 0)
				break;
		}
		
		// Return remainding amount
		return amount; 
	}
	
	bool removeItem(Item @data, int amount = 1, int slotX = -1, int slotY = -1)
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
				@slot.item = null;
			}
			return true;
		}
		return false;
	}
	
	bool lmbPressed = false;
	bool rmbPressed = false;
	
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
			Item @item = @getSelectedItem();
			if(item != null) {
				removeItem(@item, 1, selectedSlot, 0);
				createItemDrop(@item, 1);
			}
		}
		
		if(Input.getKeyState(KEY_LMB))
		{
			if(!lmbPressed)
			{
				bool escape = false;
				for(int y = 0; y < INV_HEIGHT; y++)
				{
					for(int x = 0; x < INV_WIDTH; x++)
					{
						// Check if slot was clicked
						if(Rect(5 + 34*x, 5 + 34*y, 32, 32).contains(Input.position)) {
							leftClickSlot(@slots[x, y]);
							escape = true;
						}
						if(escape)
							break;
					}
					if(escape)
						break;
				}
				
				if(!escape){
					for(int y = 0; y < 3; y++)
					{
						for(int x = 0; x < 3; x++)
						{
							// Check if slot was clicked
							if(Rect(5 + 34*x, 256 + 34*y, 32, 32).contains(Input.position)) {
								leftClickSlot(@craftingSlots[x, y]);
								escape = true;
								updateCrafing();
							}
							if(escape)
								break;
						}
						if(escape)
							break;
					}
				}
				
				if(!heldSlot.isEmpty() && !escape)
				{
					createItemDrop(heldSlot.item, heldSlot.amount);
					heldSlot.clear();
				}
			}
			lmbPressed = true;
		}else
		{
			lmbPressed = false;
		}
		
		if(Input.getKeyState(KEY_RMB))
		{
			if(!rmbPressed)
			{
				bool escape = false;
				for(int y = 0; y < INV_HEIGHT; y++)
				{
					for(int x = 0; x < INV_WIDTH; x++)
					{
						// Draw slot sprite
						if(Rect(5 + 34*x, 5 + 34*y, 32, 32).contains(Input.position))
						{
							rightClickSlot(@slots[x, y]);
							escape = true;
						}
						if(escape)
							break;
					}
					if(escape)
						break;
				}
				
				if(!escape){
					for(int y = 0; y < 3; y++)
					{
						for(int x = 0; x < 3; x++)
						{
							// Check if slot was clicked
							if(Rect(5 + 34*x, 256 + 34*y, 32, 32).contains(Input.position)) {
								rightClickSlot(@craftingSlots[x, y]);
								escape = true;
								updateCrafing();
							}
							if(escape)
								break;
						}
						if(escape)
							break;
					}
				}
			}
			rmbPressed = true;
		}else{
			rmbPressed = false;
		}
	}
	
	void leftClickSlot(ItemSlot @slot)
	{			
		if(heldSlot.isEmpty()) {
			heldSlot = slot;
			slot.clear();
		}else{
			if(slot.isEmpty())
			{
				slot.set(heldSlot.item, heldSlot.amount);
				heldSlot.clear();
			}else if(@heldSlot.item == @slot.item){
				heldSlot.amount = slot.fill(heldSlot.amount);
				if(heldSlot.amount == 0)
					heldSlot.clear();
			}else{
				ItemSlot tmp = slot;
				slot = heldSlot;
				heldSlot = tmp;
			}
		}
	}
	
	void rightClickSlot(ItemSlot @slot)
	{
		if(heldSlot.isEmpty()) {
			heldSlot.set(slot.item, 1);
			slot.remove(1);
		}else if(@heldSlot.item == @slot.item){
			heldSlot.amount += 1;
			slot.remove(1);
		}else if(slot.isEmpty()) {
			slot.set(heldSlot.item, 1);
			heldSlot.remove(1);
		}
	}
	
	void updateCrafing()
	{
		for(int i = 0; i < recipies.size; i++)
		{
			bool match = true;
			for(int y = 0; y < 3; y++)
			{
				for(int x = 0; x < 3; x++)
				{
					ItemID id = craftingSlots[x, y].item.getID();
					if(id != recipies[i].recipie[x, y])
					{
						match = false;
						break;
					}
				}
				if(!match)
					break;
			}
			if(match)
			{
				addItem(@game::items[recipies[i].result]);
				
				
				for(int y = 0; y < 3; y++) {
					for(int x = 0; x < 3; x++) {
						craftingSlots[x, y].clear();
					}
				}
				
				break;
			}
		}
	}
	
	void createItemDrop(Item @item, int amount)
	{
		ItemDrop drop(@item, amount);
		drop.body.setPosition(player.body.getPosition());
		Vector2 dt = Input.position + game::camera.position - player.body.getPosition();
		if(dt.x >= 0.0f) {
			drop.body.applyImpulse(Vector2(1.0f, -1.0f)*5000.0f, drop.body.getCenter());
		}else{
			drop.body.applyImpulse(Vector2(-1.0f,-1.0f)*5000.0f, drop.body.getCenter());
		}
	}
	
	ItemSlot @hoveredItemSlot;
	void drawSlot(const Vector2 position, ItemSlot @slot)
	{	
		// Draw slot sprite
		Sprite @slotSprite;
		if(@slot == @slots[selectedSlot, 0])
		{
			@slotSprite = @selectedItemSlot;
		}else{
			@slotSprite = @itemSlot;
		}
		slotSprite.setPosition(position);
		slotSprite.draw(scene::game.getBatch(GUI));
		
		// Set as hovered if cursor is contained within the rectangle
		if(Rect(slotSprite.getPosition(), slotSprite.getSize()).contains(Input.position)) {
			@hoveredItemSlot = @slot;
		}
		
		// Draw slot content
		font::small.setColor(Vector4(1.0f)); // Set white font color
		if(slot.item != null)
		{
			// Draw item icon
			Sprite @icon = @slot.item.icon;
			icon.setPosition(position + Vector2(8, 8));
			icon.draw(scene::game.getBatch(GUI));
			
			// Draw quantity text
			if(slot.amount > 1) {
				string str = formatInt(slot.amount, "");
				font::small.draw(scene::game.getBatch(UITEXT), position + Vector2(28 - font::small.getStringWidth(str), 20), str);
			}
		}
	}
	
	void draw()
	{
		@hoveredItemSlot = null;
		for(int y = 0; y < INV_HEIGHT; y++) {
			for(int x = 0; x < INV_WIDTH; x++) {
				Vector2 position(5 + 34*x, 5 + 34*y);
				drawSlot(position, @slots[x, y]);
			}
			if(!showBag) break;
		}
		
		if(showBag) {
			for(int y = 0; y < 3; y++) {
				for(int x = 0; x < 3; x++) {
					Vector2 position(5 + 34*x, Window.getSize().y/2.0f + 34*y);
					drawSlot(position, craftingSlots[x, y]);
				}
			}
		}
		
		if(@hoveredItemSlot != null && @hoveredItemSlot.item != null) {
			font::large.draw(scene::game.getBatch(UITEXT), Input.position + Vector2(0.0f, 16.0f), hoveredItemSlot.item.desc);
		}
		
		if(!heldSlot.isEmpty())
		{
			Sprite @icon = @heldSlot.item.icon;
			icon.setPosition(Input.position + Vector2(-16, -16));
			icon.draw(@scene::game.getBatch(GUI));
			if(heldSlot.amount > 1) {
				string str = formatInt(heldSlot.amount, "");
				font::small.draw(scene::game.getBatch(UITEXT), Input.position + Vector2(4 - font::small.getStringWidth(str), -4), str);
			}
		}
	}
}