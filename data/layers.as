class LayerManager
{
	private array<Batch@> batches(LAYER_COUNT);
	private bool initialized = false;
		
	void init()
	{
		if(initialized) return;
		
		// Create layer batches
		for(int i = 0; i < batches.size; ++i) {
			@batches[i] = @Batch();
		}
		
		initialized = true;
	}
	
	Batch @opIndex(uint idx)
	{
		// Validate index and manager state
		if(!initialized || idx >= LAYER_COUNT)
			return null;
		return batches[idx];
	}
}