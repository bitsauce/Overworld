// ADDING ITEMS:
// 1) Create an ID for the item by adding it to the ItemID enum. (for example DRAGON_TOOTH_BLADE)
// 2) Modify ITEM_STRINGS so that the item name and description is in the correct spot
//    relative to it's ItemID. (for example { "Dragon Tooth Blade", "Taste my steel!" })
// 3) Create a new class that inherits the Item class, and implement its spesific behaviour
//    in the function(s) 'void use(Player @player)'.
// 4) Add the item to the ItemManager (see its constructor) using you're newly created item-class

class Item
{
	private ItemID id;
	string name;
	string desc;
	int maxStack;
	Sprite @icon;
	bool singleShot;
	
	Item(ItemID id, int maxStack)
	{
		this.id = id;
		this.name = ITEM_STRINGS[0, id];
		this.desc = ITEM_STRINGS[1, id];
		@this.icon = @ITEM_ICONS[id];
		this.icon.setSize(Vector2(16.0f));
		this.maxStack = maxStack;
		this.singleShot = false;
	}
	
	ItemID getID()
	{
		return id;
	}
	
	void use(Player @player) { /* Virtual function */ }
}