/***
* Name: Individual
* Individuals species. 
* Author: Jean-François Erdelyi
* Tags:
*/
model SwITCh

import "../Transport/Trip.gaml"
import "../Network/Building.gaml"
import "Agenda.gaml"
species Individual {
	
	// The agenda
	Agenda my_agenda <- world.createAgenda();
	queue trip_chain;

	// Current Transport
	Transport current_transport;

	// The working place
	Building working_place <- nil;

	// The home place
	Building home_place <- nil;

	// ****************
	action pushTrip (Trip p) {
		push item: p to: trip_chain;
	}

	Trip popTrip {
		return pop(trip_chain);
	}

	action executeTripChain {
		if length(trip_chain) > 0 {
			Trip currentTrip <- popTrip(); 
			current_transport <- currentTrip.transport;
			ask currentTrip {
				do start();
			}
		}
	}

}
