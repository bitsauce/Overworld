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
	Sprite @moon = @Sprite(@Texture(":/sprites/sky/moon.png"));
	
	float exposure = 0.1f;
	float decay = 0.97f;
	float density = 0.98f;
	Shader @godRayShader = @Shader(":/shaders/godrays.vert", ":/shaders/godrays.frag");
	Batch @fbo = @Batch();
	Texture @fboTexture = @Texture(800, 600);
	
	Background()
	{
		// Set god ray uniforms
		godRayShader.setUniform1f("exposure", exposure);
		godRayShader.setUniform1f("decay", decay);
		godRayShader.setUniform1f("density", density);

		// Draw texture
		godRayShader.setSampler2D("texture", @fboTexture);
		
		sun.setOrigin(sun.getCenter());
		moon.setOrigin(moon.getCenter());
	}
	
	void update()
	{
		// Get hour and mintue
		int hour = game::timeOfDay.getHour();
		int minute = game::timeOfDay.getMinute();
		float time = game::timeOfDay.getTime();
		
		// Change background depending on time
		if(game::timeOfDay.isDay())
		{
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
			float ang = (1140-time)/720.0f;
			Vector2 windowSize = Vector2(Window.getSize());
			Vector2 sunSize = sun.getSize();
			sun.setPosition(Vector2(windowSize.x/2.0f - sunSize.x/2.0f + Math.cos(Math.PI*ang) * (windowSize.x/2.0f + sunSize.x/4.0f),
									windowSize.y/2.0f - Math.sin(Math.PI*ang) * (windowSize.y/2.0f + 64)));
			sun.setRotation(180*(1.0f-ang));
		}else{
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
			float ang = (1860 - (time >= 1140 ? time : time + 1440))/720.0f;
			Vector2 windowSize = Vector2(Window.getSize());
			Vector2 moonSize = moon.getSize();
			moon.setPosition(Vector2(windowSize.x/2.0f - moonSize.x/2.0f + Math.cos(Math.PI*ang) * (windowSize.x/2.0f + moonSize.x/2.0f),
									 windowSize.y/2.0f - Math.sin(Math.PI*ang) * windowSize.y/2.0f));
			moon.setRotation(180*(1.0f-ang));
		}
	}
	
	void draw()
	{
		// Draw sky gradient
		array<Vertex> vertices(4);
		
		vertices[0].position.set(0.0f, 0.0f);
		vertices[0].color = topColor;
		
		vertices[1].position.set(Window.getSize().x, 0.0f);
		vertices[1].color = topColor;
		
		vertices[2].position.set(Window.getSize().x, Window.getSize().y);
		vertices[2].color = bottomColor;
		
		vertices[3].position.set(0, Window.getSize().y);
		vertices[3].color = bottomColor;
		
		game::batches[BACKGROUND].addVertices(vertices, QUAD_INDICES);
		
		if(!Input.getKeyState(KEY_G))
		{
			int hour = game::timeOfDay.getHour();
			if(hour >= 6 && hour < 18)
			{
				sun.draw(@game::batches[BACKGROUND]);
			}else{
				moon.draw(@game::batches[BACKGROUND]);
			}
		}else{
			// Draw sun/moon
			Vector2 lightPos;
			int hour = game::timeOfDay.getHour();
			if(hour >= 6 && hour < 18)
			{
				sun.draw(@fbo);
				lightPos = sun.getCenter();
			}else{
				moon.draw(@fbo);
				lightPos = moon.getCenter();
			}
			
			// Erase terrain
			//fbo.setBlendFunc(BLEND_ZERO, BLEND_ONE_MINUS_SRC_ALPHA);
			Shape @screen = @Shape(Rect(Vector2(0.0f), Vector2(Window.getSize())));
			//shape.setFillTexture(@terrainTexture);
			//shape.draw(@fbo);
			
			// Clear fbo and render celestial body to texture
			fboTexture.clear();
			fbo.renderToTexture(@fboTexture);
			
			// Draw fullscreen rect with godray shader
			game::batches[SCENE].setShader(@godRayShader);
			screen.draw(@game::batches[BACKGROUND]);
			game::batches[SCENE].setShader(null);
			
			// Set light pos
			lightPos.x /= 800;
			lightPos.y = 600 - lightPos.y;
			lightPos.y /= 600;
			godRayShader.setUniform2f("lightPos", lightPos.x, lightPos.y);
			
			// Clear fbo buffer
			fbo.clear();
		}
	}
}