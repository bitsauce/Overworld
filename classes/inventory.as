class Inventory : MouseListener
{
	// OWNER
	Player @player;
	
	// SLOT SPRITES
	Sprite @itemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot.png"));
	Sprite @selectedItemSlot = @Sprite(@Texture(":/sprites/inventory/item_slot_selected.png"));
	
	// SHOW BAG
	bool showBag = false;
	
	// INVENTORY MANAGEMENT
	ItemSlot heldSlot;
	
	// HOT BAR
	int selectedSlot = 0;
	
	// INVENTORY SLOTS
	grid<ItemSlot> slots(INV_WIDTH, INV_HEIGHT);
	
	// CRAFTING
	grid<ItemSlot> craftingSlots(3, 3);
	ItemSlot resultSlot;
	
	Inventory(Player @player)
	{
		Input.addMouseListener(@this);
		
		@this.player = @player;
	}
	
	void mouseClick(MouseButton){}
	
	void mouseScroll(int dt)
	{
		selectedSlot -= dt;
		if(selectedSlot < 0)
		{
			selectedSlot = INV_WIDTH-1;
		}
		else if(selectedSlot >= INV_WIDTH)
		{
			selectedSlot = 0;
		}
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
		showBag = Input.getKeyState(KEY_TAB);
			
		// Throw items
		if(Input.getKeyState(KEY_Q))
		{
			Item @item = @getSelectedItem();
			if(item != null)
			{
				int amt = slots[selectedSlot, 0].amount;
				removeItem(@item, amt, selectedSlot, 0);
				createItemDrop(@item, amt, true);
			}
		}
		
		if(Input.getKeyState(KEY_LMB))
		{
			if(!lmbPressed)
			{
				bool escape = false;
				for(int y = 0; y < INV_HEIGHT && !escape; y++)
				{
					for(int x = 0; x < INV_WIDTH && !escape; x++)
					{
						// Check if slot was clicked
						if(Rect(5 + 34*x, 5 + 34*y, 32, 32).contains(Input.position))
						{
							if(y == 0 && !showBag)
							{
								selectedSlot = x;
							}
							else
							{
								leftClickSlot(@slots[x, y]);
							}
							escape = true;
						}
					}
				}
				
				for(int y = 0; y < 3 && !escape; y++)
				{
					for(int x = 0; x < 3 && !escape; x++)
					{
						// Check if slot was clicked
						if(Rect(5 + 34*x, Window.getSize().y/2.0f + 34*y, 32, 32).contains(Input.position))
						{
							leftClickSlot(@craftingSlots[x, y]);
							updateCrafing();
							escape = true;
						}
					}
				}
				
				if(Rect(5 + 34*4, Window.getSize().y/2.0f + 34, 32, 32).contains(Input.position))
				{
					for(uint y = 0; y < 3; ++y)
					{
						for(uint x = 0; x < 3; ++x)
						{
							craftingSlots[x, y].remove(resultSlot.amount);
						}
					}
					leftClickSlot(@resultSlot);
					escape = true;
				}
				
				if(!heldSlot.isEmpty() && !escape)
				{
					createItemDrop(heldSlot.item, heldSlot.amount);
					heldSlot.clear();
				}
			}
			lmbPressed = true;
		}
		else
		{
			lmbPressed = false;
		}
		
		if(Input.getKeyState(KEY_RMB))
		{
			if(!rmbPressed)
			{
				bool escape = false;
				for(int y = 0; y < INV_HEIGHT && !escape; ++y)
				{
					for(int x = 0; x < INV_WIDTH && !escape; ++x)
					{
						// Draw slot sprite
						if(Rect(5 + 34*x, 5 + 34*y, 32, 32).contains(Input.position))
						{
							rightClickSlot(@slots[x, y]);
							escape = true;
						}
					}
				}
				
				for(int y = 0; y < 3 && !escape; y++)
				{
					for(int x = 0; x < 3 && !escape; x++)
					{
						// Check if slot was clicked
						if(Rect(5 + 34*x, Window.getSize().y/2.0f + 34*y, 32, 32).contains(Input.position))
						{
							rightClickSlot(@craftingSlots[x, y]);
							updateCrafing();
							escape = true;
						}
					}
				}
			}
			rmbPressed = true;
		}
		else
		{
			rmbPressed = false;
		}
		
		Debug.setVariable("Hovered", isHovered() ? "true" : "false");
	}
	
	bool isHovered() const
	{
		return !showBag ? Rect(5, 5, 34*(INV_WIDTH-1) + 32, 32).contains(Input.position) :
						(Rect(5, 5, 34*(INV_WIDTH-1) + 32, 34*(INV_HEIGHT-1) + 32).contains(Input.position) ||
						Rect(5, Window.getSize().y/2.0f, 34*3, 34*3).contains(Input.position) ||
						Rect(5 + 34*4, Window.getSize().y/2.0f + 34, 32, 32).contains(Input.position));
	}
	
	void leftClickSlot(ItemSlot @slot)
	{			
		if(heldSlot.isEmpty())
		{
			heldSlot = slot;
			slot.clear();
		}
		else
		{
			if(slot.isEmpty())
			{
				slot.set(heldSlot.item, heldSlot.amount);
				heldSlot.clear();
			}
			else if(@heldSlot.item == @slot.item)
			{
				heldSlot.amount = slot.fill(heldSlot.amount);
				if(heldSlot.amount == 0)
					heldSlot.clear();
			}
			else
			{
				ItemSlot tmp = slot;
				slot = heldSlot;
				heldSlot = tmp;
			}
		}
	}
	
	void rightClickSlot(ItemSlot @slot)
	{
		if(heldSlot.isEmpty())
		{
			int amt = Math.ceil(slot.amount/2.f);
			heldSlot.set(slot.item, amt);
			slot.remove(amt);
		}
		else if(@heldSlot.item == @slot.item)
		{
			heldSlot.amount -= 1;
			slot.fill(1);
		}
		else if(slot.isEmpty())
		{
			slot.set(heldSlot.item, 1);
			heldSlot.remove(1);
		}
	}
	
	void updateCrafing()
	{
		resultSlot.clear();
		uint craftWidth = 0;
		uint craftHeight = 0;
		//uint craftX = 0;
		//uint craftY = 0;
		for(int y = 0; y < 3; ++y)
		{
			for(int x = 0; x < 3; ++x)
			{
				if(!craftingSlots[x, y].isEmpty()) craftWidth = Math.max(craftWidth, x+1);
				if(!craftingSlots[x, y].isEmpty()) craftHeight = Math.max(craftHeight, y+1);
			}
		}
		
		for(int i = 0; i < Recipes.size; ++i)
		{
			Recipe @recipe = Recipes[i];
			uint recipeWidth = recipe.pattern.width();
			uint recipeHeight = recipe.pattern.height();
			if(recipeWidth == craftWidth && recipeHeight == craftHeight)
			{
				uint amount;
				bool match = false;
				for(int y = 0; y < 3 && y + recipeHeight - 1 < 3 && !match; ++y)
				{
					for(int x = 0; x < 3 && x + recipeWidth - 1 < 3 && !match; ++x)
					{
						match = true; // Assume there is a match and prove otherwise
						amount =  0xFFFFFFFF;
						for(int j = 0; j < recipeHeight && match; ++j)
						{
							for(int i = 0; i < recipeWidth && match; ++i)
							{
								ItemID id = craftingSlots[x+i, y+j].isEmpty() ? NULL_ITEM : craftingSlots[x+i, y+j].item.getID();
								amount = Math.min(craftingSlots[x+i, y+j].amount, amount);
								if(id != recipe.pattern[i, j])
								{
									match = false;
								}
							}
						}
					}
				}				
				if(match)
				{
					resultSlot.set(@Items[recipe.result], recipe.amount * amount);
					break;
				}
			}
		}
	}
	
	void createItemDrop(Item @item, int amount, bool usePlayerDir = false)
	{
		ItemDrop drop(@item, amount);
		drop.body.setPosition(player.body.getPosition());
		
		bool tossRight = (Input.position + Camera.position - player.body.getPosition()).x >= 0.0f;
		if(usePlayerDir) 
			tossRight = !player.skeleton.flipX;
			
		if(tossRight)
		{
			drop.body.applyImpulse(Vector2(1.0f, -1.0f)*5000.0f, drop.body.getCenter());
		}
		else
		{
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
		}
		else
		{
			@slotSprite = @itemSlot;
		}
		slotSprite.setPosition(position);
		slotSprite.draw(scene::game.getBatch(GUI));
		
		// Set as hovered if cursor is contained within the rectangle
		if(Rect(slotSprite.getPosition(), slotSprite.getSize()).contains(Input.position))
		{
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
			if(slot.amount > 1)
			{
				string str = formatInt(slot.amount, "");
				font::small.draw(scene::game.getBatch(UITEXT), position + Vector2(28 - font::small.getStringWidth(str), 20), str);
			}
		}
	}
	
	void draw()
	{
		@hoveredItemSlot = null;
		for(int y = 0; y < INV_HEIGHT; y++)
		{
			for(int x = 0; x < INV_WIDTH; x++)
			{
				Vector2 position(5 + 34*x, 5 + 34*y);
				drawSlot(position, @slots[x, y]);
			}
			if(!showBag) break;
		}
		
		if(showBag)
		{
			for(int y = 0; y < 3; y++)
			{
				for(int x = 0; x < 3; x++)
				{
					Vector2 position(5 + 34*x, Window.getSize().y/2.0f + 34*y);
					drawSlot(position, craftingSlots[x, y]);
				}
			}
			
			drawSlot(Vector2(5 + 34*4, Window.getSize().y/2.0f + 34), resultSlot);
		}
		
		if(@hoveredItemSlot != null && @hoveredItemSlot.item != null)
		{
			font::large.draw(scene::game.getBatch(UITEXT), Input.position + Vector2(0.0f, 16.0f), hoveredItemSlot.item.desc);
		}
		
		if(!heldSlot.isEmpty())
		{
			Sprite @icon = @heldSlot.item.icon;
			icon.setPosition(Input.position + Vector2(-16, -16));
			icon.draw(@scene::game.getBatch(GUI));
			if(heldSlot.amount > 1)
			{
				string str = formatInt(heldSlot.amount, "");
				font::small.draw(scene::game.getBatch(UITEXT), Input.position + Vector2(4 - font::small.getStringWidth(str), -4), str);
			}
		}
	}
}

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