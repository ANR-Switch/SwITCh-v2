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
	int getSize {
		return size;
	}
	
	// Get size sorted by species
	map getSizeBySpecies {
		return size_by_species;
	}
}
