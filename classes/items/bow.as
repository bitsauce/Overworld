class BowItem : ItemData
{
	BowItem(ItemID id, const string &in name, const string &in desc, Sprite @icon)
	{
		super(id, name, desc, @icon, 1, false);
	}
	
	void use(Player @player)
	{
		Vector2 dt = Input.position + Camera.position - player.body.getPosition();
		
		Projectile p();
		p.body.setPosition(player.body.getPosition());
		p.body.applyImpulse(dt.normalized() * 7500, p.body.getCenter());
	}
}