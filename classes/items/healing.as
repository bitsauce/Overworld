class HealingPotion : Item
{
	HealingPotion(ItemID id)
	{
		super(id, 255);
		singleShot = true;
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