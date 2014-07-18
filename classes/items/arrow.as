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
			Vector2 dt = Input.position + global::camera.position - player.body.getPosition();
			
			Projectile p();
			p.body.setPosition(player.body.getPosition());
			p.body.applyImpulse(dt.normalized() * 5000, p.body.getPosition());
		}
	}
}