#include "classes/terrain.as"
#include "classes/background.as"

array<Texture@> TILE_TEXTURES(MAX_TILES);
Terrain t(50, 50);
Background b;
Batch @backgroundBatch = Batch();
Batch @foregroundBatch = Batch();

void main()
{
}

void draw()
{
	t.draw();
}

void update()
{
	if(Input.getKeyState(KEY_LMB))
		t.removeTile(Input.position.x/TILE_SIZE, Input.position.y/TILE_SIZE);
	else if(Input.getKeyState(KEY_RMB))
		t.addTile(Input.position.x/TILE_SIZE, Input.position.y/TILE_SIZE, GRASS_TILE);
}