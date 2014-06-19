array<uint> QUAD_INDICES = { 0,3,1, 1,3,2 };

Vector4 rgbvec(uint8 r, uint8 g, uint8 b, uint8 a = 255)
{
	return Vector4(r/255.0f, g/255.0f, b/255.0f, a/255.0f);
}

Vector4 blendRgb(Vector4 dst, Vector4 src)
{
	// Alpha blending
	Vector4 ret(1.0f);
	ret.rgb = src.rgb*src.a + dst.rgb*(1.0f-src.a);
	return ret;
}

class Background : GameObject
{
	Vector4 topColor = Vector4(1.0f, 1.0f, 1.0f, 1.0f);
	Vector4 bottomColor = Vector4(0.35f, 0.67f, 1.0f, 1.0f);
	Sprite @sun = @Sprite(@Texture(":/sprites/sky/sun.png"));
	
	void update()
	{
		// Get hour and mintue
		int hour = global::timeOfDay.getHour();
		int minute = global::timeOfDay.getMinute();
		float time = global::timeOfDay.getTime();
		
		// Change background depending on time
		if((hour >= 0 && hour < 6) || (hour >= 18 && hour <= 24))
		{
			
			// Apply sunset from 18:00 to 21:00
			if(hour >= 18 && hour < 21)
			{
				// Percentage of sunset
				float minscale = 1.0f - (1260-time)/180.0f; // Aka. (21*60-time)/(18*60-21*60)
				topColor = blendRgb(rgbvec(255, 255, 255, 255), rgbvec(0, 0, 0, 255*minscale));
				bottomColor = blendRgb(rgbvec(90, 170, 255, 255), rgbvec(10, 60, 110, 255*minscale));
			}else{
				// Set night gradient
				topColor = rgbvec(0, 0, 0);
				bottomColor = rgbvec(10, 60, 110);
			}
			
			// Place moon
			float ang = (1620 - (time >= 1260.0f ? time : time + 1260.0f))/1260.0f;
			Vector2 windowSize = Vector2(Window.getSize());
			Vector2 sunSize = sun.getSize();
			sun.setPosition(Vector2(windowSize.x/2.0f - sunSize.x/2.0f + Math.cos(Math.PI*ang) * (windowSize.x/2.0f + sunSize.x/2.0f),
									windowSize.y - Math.sin(Math.PI*ang) * windowSize.y));
		}else{
			// Apply sunrise from 6:00 to 9:00
			if(hour >= 6 && hour < 9)
			{
				// Percentage of sunrise
				float minscale = 1.0f - (540-time)/180.0f; // Aka. (9*60-time)/(6*60-9*60)
				topColor = blendRgb(rgbvec(0, 0, 0, 255), rgbvec(255, 255, 255, 255*minscale));
				bottomColor = blendRgb(rgbvec(10, 60, 110, 255), rgbvec(90, 170, 255, 255*minscale));
			}else{
				// Set day gradient
				topColor = rgbvec(255, 255, 255);
				bottomColor = rgbvec(90, 170, 255);
			}
			
			// Place sun
			float ang = (1140-time)/780.0f;
			Vector2 windowSize = Vector2(Window.getSize());
			Vector2 sunSize = sun.getSize();
			sun.setPosition(Vector2(windowSize.x/2.0f - sunSize.x/2.0f + Math.cos(Math.PI*ang) * (windowSize.x/2.0f + sunSize.x/2.0f),
									windowSize.y - Math.sin(Math.PI*ang) * windowSize.y));
		}
	}
	
	void draw()
	{
		array<Vertex> vertices(4);
		
		vertices[0].position.set(0.0f, 0.0f);
		vertices[0].color = topColor;
		
		vertices[1].position.set(Window.getSize().x, 0.0f);
		vertices[1].color = topColor;
		
		vertices[2].position.set(Window.getSize().x, Window.getSize().y);
		vertices[2].color = bottomColor;
		
		vertices[3].position.set(0, Window.getSize().y);
		vertices[3].color = bottomColor;
		
		global::batches[global::BACKGROUND_LAYER].addVertices(vertices, QUAD_INDICES);
		
		sun.draw(@global::batches[global::BACKGROUND_LAYER]);
	}
}