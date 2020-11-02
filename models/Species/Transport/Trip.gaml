/**
* Name: Trip
* The trip is a part of the path from the origin to destination, it's composed by one individual, one transport and one destination.
* Author: nvers
* Tags: 
*/
model SwITCh

import "Transport.gaml"

/** 
 * Trip species
 */
species Trip {
	// The transport
	Transport transport;
	
	// The individual
	Individual individual;
	
	// Destination
	point target_pos;

	// Start the trip
	action start (point position, date start_time) {
		// Ask the transport to add this individual
		ask transport {
			do getIn(myself.individual);
		}

		// And start moving
		if (not transport.is_moving) {
			ask transport {
				do start(position, myself.target_pos, start_time);
			}

		}

	}

}

