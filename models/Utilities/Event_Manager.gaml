/**
* Name: Event_Manager
* Event manager used by many species.
* Author: Jean-François Erdelyi 
* Tags: 
*/
model SwITCh

species Event_Manager control: event_manager {
	bool allow_past <- false;

	action write_size {
		write "[" + name + "]::[write_size] manager size = " + size + "; sorted by species = " + size_by_species + " at " + (starting_date + time);
	}

}
