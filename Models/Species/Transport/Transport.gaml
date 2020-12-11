/**
* Name: Transport
* Commons behavior of public and private transport. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../../Utilities/EventManager.gaml"
import "../Network/Network.gaml"
import "../Individual/Individual.gaml"

/** 
 * Transport virtual species
 * 
 * Can schedule actions (scheduling skill) using the action 'later'
 */
species Transport virtual: true skills: [scheduling] {

	/**
	 * Transport data
	 */

	// Travelers
	list<Individual> passengers <- [];

	// Maximum speed for a transport (km/h)
	float max_speed;

	// Transport length (meters)
	float size;

	// Passenger capacity 
	int max_passenger;

	/**
	 * Computation data
	 */

	// The event manager
	agent event_manager <- EventManager[0];

	// Current trip
	Trip current_trip <- nil;

	// Associated network
	Network network <- nil;

	// If true the transport is visible
	bool is_visible <- false;

	/**
	 * Compute path actions
	 */

	// Compute
	action compute (point from_location, point to_location) {
		ask network {
			do compute(from_location, to_location);
		}

		ask current_trip {
			do setup();
		}

	}

	// Pre compute path
	bool pre_compute (point from_location, point to_location) {
		bool ret;
		ask network {
			ret <- pre_compute(from_location, to_location);
		}

		if ret {
			ask current_trip {
				do setup();
			}

		} else {
			// TODO it's not a good solution.
			// The graph is not perfect and sometime,
			// some buildings are not reachable
			ask current_trip.individual {
				do die();
			}

		}

		return ret;
	}

	/**
	 * Add and remove passengers
	 */

	// Passenger get in the transport
	bool get_in (Individual i) {
	// Can't be more than the max capacity
		if (length(passengers) < max_passenger) {
			add item: i to: passengers;
			return true;
		}

		return false;
	}

	// Passenger get out the transport
	action get_out (Individual i) {
		remove item: i from: passengers;
	}

	/**
	 * Start end stop  
	 */

	// Start to move
	action start (point start_location, point end_location, date start_time, Trip trip) {
		// Start standard
		current_trip <- trip;
		is_visible <- true;
		do start_standard(start_location, end_location, start_time);
	}

	// Start to move
	action start_standard (point start_location, point end_location, date start_time) {
		if not network.computed {
			do compute(start_location, end_location);
		}

		if (network.computed and network.path_nil) {
		// Something wrong
			write "---------------------------------------------------";
			write "The path is nil";
			write "Transport: " + self;
			write "---------------------------------------------------";
			do end(start_time);
		} else {
			do inner_change_road(get_current_road(), start_time);
		}

	}

	// Virtual end travel
	action end (date arrived_time) virtual: true;

	/**
	 * Update position actions
	 */

	// Redefine the position of all passengers and the transport itself
	action update_positions (point new_location) {
		location <- new_location;
		loop passenger over: passengers {
			passenger.location <- new_location;
		}

	}

	// Set position to the end of the current road
	action update_end_positions {
		do update_positions(get_current_road().end_node.location);
	}

	/**
	 * Road actions
	 */

	// Check if there is a next road
	bool has_next_road {
		return length(network.path_to_target) > 1;
	}

	// Check if is the last road changing
	bool it_is_last_road_changing {
		return length(network.path_to_target) <= 2;
	}

	// Get current road of this transport
	Road get_current_road {
		if length(network.path_to_target) > 0 {
			return first(network.path_to_target);
		} else {
			return nil;
		}

	}

	// Get next road of this transport
	Road get_next_road {
		if length(network.path_to_target) > 1 {
			return network.path_to_target[1];
		} else {
			return nil;
		}

	}

	// Leave current road	
	action leave_current_road (date request_time) {
		if current_trip.current_road != nil {
			Road road <- get_current_road();
			if road != nil {
				ask road {
					do leave(myself, request_time);
				}

				remove first(network.path_to_target) from: network.path_to_target;
				current_trip.is_waiting <- false;
			}

		}

	}
	
	// Inner changer road
	action inner_change_road (Road road, date start_time) {
		// Joined varaiable used to leave road if true
		bool joinable <- false;
		
		ask road {
			joinable <- has_capacity(myself) and not check_if_exists(myself);
		}

		if joinable {
			current_trip.is_waiting <- false;

			// Set the current target depending if it's the last road or not
			if it_is_last_road_changing() {
				current_trip.current_target <- current_trip.end_location;
			} else {
				current_trip.current_target <- road.end_node.location;
			}

			ask road {
				do join(myself, start_time);
			}

			do leave_current_road(start_time);
			current_trip.current_road <- road;
			current_trip.next_road <- get_next_road();
		} else {
			current_trip.is_waiting <- true;
			
			ask road {
				do join(myself, start_time);
			}

			current_trip.next_road <- road;
		}

	}

	// Change road signal
	action change_road (date request_date) {
		if has_next_road() {
			do inner_change_road(get_next_road(), request_date);
		} else {
			do leave_current_road(request_date);
			do end(request_date);
		}

	}
	
	// Get all transport of current and the next road
	list<Transport> get_trip_transports {
		list<Transport> current_transports <- [];
		list<Transport> next_transports <- [];
		
		if current_trip.current_road != nil {
			current_transports <- current_trip.current_road.road_model.get_transports();
		}
		if current_trip.next_road != nil {
			//next_transports <- current_trip.next_road.road_model.get_transports();
		}
		
		return current_transports + next_transports;
	}

	/**
	 * Utilities
	 */

	// Get current target (if the transport execute a trip)
	point get_current_target {
		if current_trip != nil and not dead(current_trip) {
			return current_trip.current_target;
		}

		return nil;
	}

	// Convert km/h to m/s
	float get_speed_meter_per_second {
		return max_speed / 3.6;
	}

	// Compute straight forward free flow travel time (in seconds) from location of transport to target
	float compute_straight_forward_duration (point target) {
		return (location distance_to target) / get_speed_meter_per_second();
	}

	// Compute straight forward duration: transport target in the given road
	float compute_straight_forward_duration_through_road (Road road, point target) {
		return (location distance_to target) / road.get_max_freeflow_speed(self);
	}

}
