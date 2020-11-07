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
	Trip create_trip (Transport trip_transport, Individual trip_individual, point trip_target) {
		create Trip returns: trips {
			transport <- trip_transport;
			individual <- trip_individual;
			target <- trip_target;
		}
		
		// Set the position of the transport at the same location of the individual
		ask trip_transport {
			location <- trip_individual.location;
		}

		return trips[0];
	}
	
	// Create a new trip
	Trip create_connexion_trip (Individual trip_individual, point trip_target) {
		return create_trip(world.create_walk_connexion(), trip_individual, trip_target);
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
		ask transport {
			// Ask the transport to add this individual;
			do get_in(myself.individual);
			// And start moving
			do start(position, myself.target, start_time);
		}
	}
	
	// Start the trip
	point pre_compute (point position) {
		ask transport {
			// PreCompute
			return pre_compute(position, myself.target);
		}
	}
	
	// Compute straight forward free flow travel time (in seconds) from location of transport to target
	float compute_straight_forward_duration {
		return transport.compute_straight_forward_duration(target); 
	}
	
	// Die transport and trip
	action clean_die {
		ask transport {
			do die;
		}
		do die;
	}
}
