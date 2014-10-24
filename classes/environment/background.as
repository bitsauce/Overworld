array<uint> QUAD_INDICES = { 0,3,1, 1,3,2 };

// TODO: Add background colors again...
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

class Color
{
	Color(uint8 r, uint8 g, uint8 b, uint8 a = 255)
	{
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
	}
	
	uint8 r;
	uint8 g;
	uint8 b;
	uint8 a;
}

class BackgroundManager
{
	Color topColor(255, 255, 255, 255);
	Color bottomColor(90, 170, 255, 255);
	Sprite @sun = @Sprite(@Texture(":/sprites/sky/sun.png"));
	Sprite @moon = @Sprite(@Texture(":/sprites/sky/moon.png"));
	float wind = 0.04f;
	float cloudTime = 0.0f;
	Shader @simplexNoise = @Shader(":/shaders/simplex3d.vert", ":/shaders/simplex3d.frag");
	Texture @cloudGradient = @Texture(":/sprites/sky/cloud_gradient.png");
	Sprite @cloudSprite = @Sprite(TextureRegion(null, 0.0f, 0.0f, 7.0f, 10.0f));
	
	float exposure = 0.1f;
	float decay = 0.97f;
	float density = 0.98f;
	Shader @godRayShader = @Shader(":/shaders/godrays.vert", ":/shaders/godrays.frag");
	Batch @fbo = @Batch();
	Texture @fboTexture = @Texture(800, 600);
	
	BackgroundManager()
	{
		// Set god ray uniforms
		godRayShader.setUniform1f("exposure", exposure);
		godRayShader.setUniform1f("decay", decay);
		godRayShader.setUniform1f("density", density);
		
		simplexNoise.setSampler2D("u_gradient", @cloudGradient);
		//simplexNoise.setSampler2D("u_mask", @cloudMask);
		simplexNoise.setUniform1f("u_frequency", 0.1f);
		simplexNoise.setUniform1f("u_gain", 0.5f);
		simplexNoise.setUniform1f("u_lacunarity", 2.0f);
		simplexNoise.setUniform1i("u_octaves", 8);

		// Draw texture
		godRayShader.setSampler2D("texture", @fboTexture);
		
		sun.setOrigin(sun.getCenter());
		moon.setOrigin(moon.getCenter());
	}
	
	void update()
	{
		// Get hour and mintue
		int hour = TimeOfDay.getHour();
		int minute = TimeOfDay.getMinute();
		float time = TimeOfDay.getTime();
		
		// Change background depending on time
		if(TimeOfDay.isDay())
		{
			// Apply sunrise from 6:00 to 9:00
			if(hour >= 6 && hour < 9)
			{
				// Percentage of sunrise
				float minscale = 1.0f - (540-time)/180.0f; // Aka. (9*60-time)/(6*60-9*60)
				//topColor = blendRgb(Vector4(0.0f, 0.0f, 0.0f, 1.0f), rgbvec(255, 255, 255, 255*minscale));
				//bottomColor = blendRgb(rgbvec(10, 60, 110, 255), rgbvec(90, 170, 255, 255*minscale));
			}else
			{
				// Set day gradient
				//topColor = rgbvec(255, 255, 255);
				//bottomColor = rgbvec(90, 170, 255);
			}
			
			// Place sun
			float ang = (1140-time)/720.0f;
			Vector2 windowSize = Vector2(Window.getSize());
			Vector2 sunSize = sun.getSize();
			sun.setPosition(Vector2(windowSize.x/2.0f - sunSize.x/2.0f + Math.cos(Math.PI*ang) * (windowSize.x/2.0f + sunSize.x/4.0f),
									windowSize.y/2.0f - Math.sin(Math.PI*ang) * (windowSize.y/2.0f + 64)));
			sun.setRotation(180*(1.0f-ang));
		}else
		{
			// Apply sunset from 18:00 to 21:00
			if(hour >= 18 && hour < 21)
			{
				// Percentage of sunset
				float minscale = 1.0f - (1260-time)/180.0f; // Aka. (21*60-time)/(18*60-21*60)
				//topColor = blendRgb(rgbvec(255, 255, 255, 255), rgbvec(0, 0, 0, 255*minscale));
				//bottomColor = blendRgb(rgbvec(90, 170, 255, 255), rgbvec(10, 60, 110, 255*minscale));
			}else
			{
				// Set night gradient
				//topColor = rgbvec(0, 0, 0);
				//bottomColor = rgbvec(10, 60, 110);
			}
				
			// Place moon
			float ang = (1860 - (time >= 1140 ? time : time + 1440))/720.0f;
			Vector2 windowSize = Vector2(Window.getSize());
			Vector2 moonSize = moon.getSize();
			moon.setPosition(Vector2(windowSize.x/2.0f - moonSize.x/2.0f + Math.cos(Math.PI*ang) * (windowSize.x/2.0f + moonSize.x/2.0f),
									 windowSize.y/2.0f - Math.sin(Math.PI*ang) * windowSize.y/2.0f));
			moon.setRotation(180*(1.0f-ang));
		}
		
		// Apply wind
		cloudTime += wind * Graphics.dt;
	}
	
	void draw(Batch @background)
	{
		// Draw sky gradient
		array<Vertex> vertices(4);
		vertices[0].set4f(VERTEX_POSITION, 0.0f, 0.0f);
		vertices[0].set4ub(VERTEX_COLOR, topColor.r, topColor.g, topColor.b, topColor.a);
		vertices[1].set4f(VERTEX_POSITION, Window.getSize().x, 0.0f);
		vertices[1].set4ub(VERTEX_COLOR, topColor.r, topColor.g, topColor.b, topColor.a);
		vertices[2].set4f(VERTEX_POSITION, Window.getSize().x, Window.getSize().y);
		vertices[2].set4ub(VERTEX_COLOR, bottomColor.r, bottomColor.g, bottomColor.b, bottomColor.a);
		vertices[3].set4f(VERTEX_POSITION, 0, Window.getSize().y);
		vertices[3].set4ub(VERTEX_COLOR, bottomColor.r, bottomColor.g, bottomColor.b, bottomColor.a);
		
		//Batch @background = scene::game.getBatch(BACKGROUND);
		background.addVertices(vertices, QUAD_INDICES);
		
		if(!Input.getKeyState(KEY_G))
		{
			int hour = TimeOfDay.getHour();
			if(hour >= 6 && hour < 18)
			{
				sun.draw(@background);
			}else
			{
				moon.draw(@background);
			}
		}else
		{
			// Draw sun/moon
			Vector2 lightPos;
			int hour = TimeOfDay.getHour();
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
			background.setShader(@godRayShader);
			screen.draw(@background);
			background.setShader(null);
			
			// Set light pos
			lightPos.x /= 800;
			lightPos.y = 600 - lightPos.y;
			lightPos.y /= 600;
			godRayShader.setUniform2f("lightPos", lightPos.x, lightPos.y);
			
			// Clear fbo buffer
			fbo.clear();
		}
		
		// Draw clouds
		simplexNoise.setUniform1f("u_time", cloudTime);
		background.setShader(@simplexNoise);
		
		cloudSprite.setPosition(0.0f, 0.0f);
		cloudSprite.setSize(Window.getSize().x, Window.getSize().y);
		cloudSprite.draw(@background);
		
		background.setShader(null);
	}
}