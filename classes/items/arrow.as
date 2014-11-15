class ArrowItem : ItemData
{
	ArrowItem(ItemID id, const string &in name, const string &in desc, Sprite @icon, const int maxStack)
	{
		super(id, name, desc, @icon, maxStack, true);
	}
	
	void use(Player @player)
	{
		if(player.inventory.removeItem(@this))
		{
			Vector2 dt = Input.position + Camera.position - player.body.getPosition();
			
			Projectile p();
			p.body.setPosition(player.body.getPosition());
			p.body.applyImpulse(dt.normalized() * 5000, p.body.getPosition());
		}
	}
}