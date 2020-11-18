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
	
	// If true the transport is waiting
	bool is_waiting;

	/**
	 * Road 
	 */

	// Current road (used for debug)
	Road current_road;

	// Next road (used for debug)
	Road next_road;

	// Origin point
	point origin;
	
	// Destination point
	point target;

	/**
	 * Transport computation data
	 */

	// Current target point (intermediate target)
	point current_target;

	// Start point in the graph (closest point in the graph)
	point start_location <- nil;

	// End point in the graph (closest point in the graph)
	point end_location <- nil;

	// Start the trip
	action start (point position, date start_time) {
		// If this is not precomputed trip
		if origin = nil {
			origin <- position;
		}

		ask transport {
		// Ask the transport to add this individual;
			do get_in(myself.individual);
			// And start moving
			do start(myself.origin, myself.target, start_time, myself);
		}

	}

	// Start the trip
	point pre_compute (point position) {
		origin <- position;
		ask transport {
			// Pre compute
			current_trip <- myself;
			if pre_compute(myself.origin, myself.target) {
				return myself.start_location;
			}

		}

	}

	// Setup trip
	action setup {
		// Set start and end point in the graph. Set the first intermediate target
		start_location <- any_location_in(Road closest_to origin);
		end_location <- any_location_in(Road closest_to target);
		current_target <- first(transport.network.path_to_target).end_node.location;
		transport.location <- start_location;
	}

}
