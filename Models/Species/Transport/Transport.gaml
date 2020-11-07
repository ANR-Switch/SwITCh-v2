/**
* Name: Transport
* Commons behavior of public and private transport. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../../Utilities/Scheduler.gaml"
import "../Network/Road.gaml"
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

	// Road graph available for the transport
	graph<Crossroad, Road> available_graph;

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

	// If true is already computed
	bool computed <- false;
	
	// If true path is nil
	bool path_nil <- false;
	
	// If true the transport is visible
	bool is_visible <- false;
	
	// If true is connexion trip
	bool is_connexion <- false;

	// List of roads that lead to the target (must be computed)
	list<Road> path_to_target;
	
	/**
	 * Compute path actions
	 */
	
	// Compute
	action compute(point start_location, point end_location) {
		path the_path <- path_between(available_graph, start_location, end_location);
		if (the_path = nil) {
			// Something wrong
			path_nil <- true;
		} else {
			path_to_target <- list<Road>(the_path.edges);
		}
		computed <- true;
	}

	// Pre compute path and return entry point
	point pre_compute(point start_location, point end_location) {
		do compute(start_location, end_location);
		if (computed and not path_nil) {
			ask get_current_road() {
				return get_entry_point();
			}
		}
		return nil;
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
	action start (point start_location, point end_location, date start_time) {
		is_visible <- true;
		
		if is_connexion {
			// Start connexion
			do start_connexion(end_location, start_time);	
		} else {
			// Start standard
			do start_standard(start_location, end_location, start_time);			
		}
		
	}
	
	// Start to move
	action start_connexion (point end_location, date start_time) {
		do end(start_time);
	}
	
	// Start to move
	action start_standard (point start_location, point end_location, date start_time) {
		if not computed {
			do compute(start_location, end_location);
		} 

		if (computed and path_nil) {
			// Something wrong
			write "---------------------------------------------------";
			write "The path is nil";
			write "Transport: " + self;
			write "---------------------------------------------------";
			do end(start_time);
		} else {
			do update_positions(get_current_road().get_entry_point());
			do later the_action: change_road at: start_time;
		}
	}

	// Virtual end travel
	action end (date arrived_time) virtual: true;

	
	/**
	 * Update position actions
	 */

	// Redefine the position of all passengers and the transport itself
	action update_positions(point new_location) {
		location <- new_location;
		loop passenger over: passengers {
			passenger.location <- new_location;
		}

	}
	
	/**
	 * Road actions
	 */

	// Check if there is a next road
	bool has_next_road {
		return length(path_to_target) > 1;
	}

	// Get current road of this transport
	Road get_current_road {
		if length(path_to_target) > 0 {
			return first(path_to_target);
		} else {
			return nil;
		}

	}
	
	// Change road signal
	action change_road {
		// Leave the current road
		Road r <- get_current_road();
		if r != nil {
			ask r {
				do leave(myself, myself.event_date);
			}
		
		}

		remove first(path_to_target) from: path_to_target;

		// Join the next road
		if has_next_road() {
			do update_positions(get_current_road().get_entry_point());
			ask get_current_road() {
				do join(myself, myself.event_date);
			}

		} else {
			do update_positions(r.get_exit_point());
			do end(event_date);
		}

	}
	
	/**
	 * Utilities
	 */

	// Convert km/h to m/s
	float get_speed_meter_per_second {
		return max_speed / 3.6;
	}

	// Compute straight forward free flow travel time (in seconds) from location of transport to target
	float compute_straight_forward_duration(point target) {
		return (location distance_to target) / get_speed_meter_per_second(); 
	}
}
