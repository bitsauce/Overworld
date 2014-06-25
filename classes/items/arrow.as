class ArrowItem : Item
{
	ArrowItem(ItemID id)
	{
		super(id, 255);
		singleShot = true;
	}
	
	void use(Player @player)
	{
		if(player.inventory.removeItem(@this))
		{
			Vector2 dt = Input.position+camera - player.getCenter();
			
			Projectile p();
			p.setPosition(player.getCenter());
			p.body.applyImpulse(dt.normalized() * 5000, p.getPosition());
		}
	}
}