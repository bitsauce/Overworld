// TOGGLES
void ToggleFullscreen()
{
	if(!Window.isFullscreen())
	{
		// Set fullscreen
		array<Vector2i> @resolutions = Window.getResolutionList();
		if(resolutions.size != 0)
		{
			Window.setSize(resolutions[resolutions.size-1]);
			Window.enableFullscreen();
		}
	}else{
		Window.disableFullscreen();
		Window.setSize(Vector2i(800, 600));
	}
}

void ZoomIn()
{
	Camera.zoom += 0.1f;
}

void ZoomOut()
{
	Camera.zoom -= 0.1f;
}

void Exit()
{
	Engine.exit();
}

void Back()
{
	Engine.popScene();
}

Texture @renderTextToTexture(Font @font, string text, int padding = 2.0f)
{
	Texture @texture = @Texture(font.getStringWidth(text) + padding, font.getStringHeight(text) + padding);
	texture.setFiltering(LINEAR);
	
	Batch @batch = @Batch();
	font.setColor(Vector4(1.0f));
	font.draw(@batch, Vector2(padding/2.0f, padding/2.0f), text);
	batch.renderToTexture(@texture);
	
	return @texture;
}

bool TerrainPlotTest(int x, int y)
{
	return Terrain.getTileAt(x, y) <= RESERVED_TILE;
}

void DebugCreate()
{
}