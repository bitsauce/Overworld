class Bow : Item
{
	Bow(ItemID id)
	{
		super(id, 255);
		singleShot = true;
	}
	
	void use(Player @player)
	{
		Vector2 dt = Input.position + Camera.position - player.body.getPosition();
		
		Projectile p();
		p.body.setPosition(player.body.getPosition());
		p.body.applyImpulse(dt.normalized() * 7500, p.body.getCenter());
	}
}