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
	// If true allow event in the past
	bool allow_past <- false;

	// Action to write the size of event queues
	action writeSize {
		write "[" + name + "]::[write_size] manager size = " + size + "; sorted by species = " + size_by_species + " at " + (starting_date + time);
	}

}
