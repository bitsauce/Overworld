class Projectile : GameObject
{
	Vector2 size = Vector2(20, 6);
	Sprite @sprite = @Sprite(@Texture(":/sprites/items/stick2.png"));
	b2Body @body;
	
	Projectile()
	{	
		b2BodyDef def;
		def.type = b2_dynamicBody;
		def.fixedRotation = false;
		@body = @b2Body(def);
		body.setObject(@this);
		body.createFixture(Rect(0, 0, size.x, size.y), 32.0f);
	}
	
	void draw()
	{
		sprite.setRotation(body.getAngle()*(180/Math.PI));
		sprite.setPosition(body.getPosition());
		sprite.draw(global::batches[SCENE]);
	}
}