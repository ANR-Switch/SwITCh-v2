/**
* Name: Event_Manager
* Event manager used by many species.
* Author: Jean-François Erdelyi 
* Tags: 
*/
model SwITCh

/** 
 * Event manager species
 */
species EventManager control: event_manager {
	// Get total size
	int get_size {
		return size;
	}
	
	// Get size sorted by species
	map get_size_by_species {
		return size_by_species;
	}
}