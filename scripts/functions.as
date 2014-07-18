// TOGGLES
void toggleFullscreen()
{
	if(!Window.isFullscreen())
	{
		// Set fullscreen
		array<Vector2i> @resolutions = Window.getResolutionList();
		if(resolutions.size != 0) {
			Window.setSize(resolutions[resolutions.size-1]);
			Window.enableFullscreen();
		}
	}else{
		Window.disableFullscreen();
		Window.setSize(Vector2i(800, 600));
	}
}

void toggleProfiler()
{
	Engine.toggleProfiler();
}