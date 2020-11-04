/**
* Name: Trip
* The trip is a part of the path from the origin to destination, it's composed by one individual, one transport and one destination.
* Author: nvers
* Tags: 
*/
model SwITCh

import "Transport.gaml"

/** 
 * Add to world the action to create a new trip
 */
global {
// Create a new trip
	Trip createTrip (Transport tripTransport, Individual tripIndividual, point tripTarget) {
		create Trip returns: trips {
			transport <- tripTransport;
			individual <- tripIndividual;
			target <- tripTarget;
		}

		return trips[0];
	}

}

/** 
 * Trip species
 */
species Trip {
// The transport
	Transport transport;

	// The individual
	Individual individual;

	// Destination
	point target;

	// Start the trip
	action start (point position, date start_time) {
		// Set the current target of the individual
		ask individual {
			current_target <- myself.target;
		}
		
		// Ask the transport to add this individual;
		ask transport {
			do getIn(myself.individual);
		}

		// And start moving
		if (not transport.is_moving) {
			ask transport {
				do start(position, myself.target, start_time);
			}

		}

	}

}

