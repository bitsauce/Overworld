class HealingItem : ItemData
{
	HealingItem(ItemID id, const string &in name, const string &in desc, Sprite @icon, const int maxStack)
	{
		super(id, name, desc, @icon, maxStack, true);
	}
	
	void use(Player @player)
	{
		if(player.inventory.removeItem(@this)) {
			player.health += 2;
			if(player.health > player.maxHealth)
				player.health = player.maxHealth;
		}
	}
}