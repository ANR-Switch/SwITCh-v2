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
	
	// Get all transport of current road
	list<Transport> get_current_road_transports {	
		if current_road != nil {
			return current_road.get_transports();	
		} else {
			return [];
		}
	}
	
	// Get all transport of the next road
	list<Transport> get_next_road_transports {	
		if next_road != nil {
			return next_road.get_transports();	
		} else {
			return [];
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
		start_location <- ((Road closest_to origin).shape closest_points_with origin)[0];
		end_location <- ((Road closest_to target).shape closest_points_with target)[0];
		current_target <- first(transport.network.path_to_target).end;
		transport.location <- start_location;
	}

}
