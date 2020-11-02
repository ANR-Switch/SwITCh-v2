/**
* Name: Individual
* Individuals species. 
* Author: Jean-François Erdelyi
* Tags:
*/
model SwITCh

import "../Transport/Trip.gaml"
import "../Building.gaml"
import "Agenda.gaml"

/** 
 * Individuals species
 */
species Individual {

	// The agenda
	Agenda my_agenda <- world.createAgenda();

	// The chain of trips from start to end location
	queue<Trip> trip_chain;

	// Current Transport
	Transport current_transport;

	// The working place
	Building working_place <- nil;

	// The home place
	Building home_place <- nil;

	// Add trip
	action pushTrip (Trip p) {
		push item: p to: trip_chain;
	}

	// Get and remove next trip
	Trip popTrip {
		return pop(trip_chain);
	}

	// Execute one trip of the chain
	action executeTripChain (date start_time) {
		if length(trip_chain) > 0 {
			Trip currentTrip <- popTrip();
			current_transport <- currentTrip.transport;
			ask currentTrip {
				do start(myself.location, start_time);
			}

		} else {
		// Je suis arrivé!
		// TODO OK 
		}

	}
	
	// Default aspect
	aspect default {
		draw circle(3) color: #brown border: #black;
	}

}
