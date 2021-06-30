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
	
	// Default representation
	geometry default_shape;

	/**
	 * Computation data
	 */

	// The event manager
	agent event_manager <- EventManager[0];
	
	// Logbook
	//agent logbook <- Logbook[0];

	// Current trip
	Trip current_trip <- nil;

	// Associated network
	Network network <- nil;

	// If true the transport is visible
	bool is_visible <- false;

	// Mean speed
	float mean_speed <- 0.0;
	
	// Jam start date
	date jam_start;
	
	// Jam duration
	float jam_duration <- 0.0;
	
	// Entry time
	date entry_time;
	
	// Entry timestamp
	date entry_exec_time;
	
	// Last remaining duration 
	float remaining_duration <- 0.0;

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
			/*ask path_to_target {
				write name + " : " + get_size();
			}*/
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
		entry_time <- start_time;
		entry_exec_time <- (starting_date + (machine_time / 1000));
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
		loop passenger over: passengers {
			passenger.location <- new_location;
		}
		location <- new_location;

	}

	// Set position to the end of the current road
	action update_end_positions {
		do update_positions(get_current_road().end);
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
		return length(network.path_to_target) <= 1;
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
	
	action log_data {
		if current_trip!= nil and current_trip.current_road != nil {
			graph sub_graph <- as_edge_graph([current_trip.current_road], [current_trip.current_road.start, current_trip.current_road.end]);
						
			//float road_dist <- current_trip.current_road.start_node distance_to current_trip.current_road.end_node;
			float road_dist <- topology(sub_graph) distance_between [current_trip.current_road.start, current_trip.current_road.end];
			//float dist <- (location distance_to current_trip.current_road.end_node) / road_dist;
			float dist <- topology(sub_graph) distance_between [location, current_trip.current_road.end];
		}
	}

	// Leave current road	
	action leave_current_road (date request_time) {
		if current_trip.current_road != nil {
			Road road <- get_current_road();
			//write "LEAVE -> " +  road.get_size() + " : " + milliseconds_between(starting_date, request_time);
			if road != nil {
				ask road {
					do leave(myself, request_time);
				} 

				remove first(network.path_to_target) from: network.path_to_target;
				current_trip.is_waiting <- false;
				
				// Compute mean speed
				if current_trip.current_road != nil {					
					date exit_exec_time <- (starting_date + (machine_time / 1000));
					float milli <- milliseconds_between(entry_time, request_time);
					float exec_time <- milliseconds_between(entry_exec_time, exit_exec_time) / 1000;
					if (milli) != 0 {
						float dist <- topology(network.available_graph) distance_between [current_trip.current_road.start, current_trip.current_target];
						mean_speed <- (dist / (milli / 1000)) * 3.6;						
						entry_time <- nil;
						entry_exec_time <- nil;
						mean_speed <- nil;
						jam_duration <- nil;
						jam_start <- nil;
					} else {
						//write name;
						write "Something wrong, time is null";
					}
					entry_time <- request_time;
					entry_exec_time <- exit_exec_time;
				}
			}
		}
	}
	
	// Inner changer road
	action inner_change_road (Road road, date start_time) {		
		// Joined varaiable used to leave road if true
		bool joinable <- false;
		bool exists <- false;
		
		ask road {
			joinable <- has_capacity(myself);
			exists <- check_if_exists(myself);
		}
		
		if exists {
			write "Something wrong, the transport is already in the next road: " + name;
			return;
		}

		if joinable {
			current_trip.is_waiting <- false;

			// Set the current target depending if it's the last road or not		
			do leave_current_road(start_time);
			current_trip.current_road <- road;
			current_trip.next_road <- get_next_road();
			
			if it_is_last_road_changing() {
				current_trip.current_target <- (road closest_points_with current_trip.end_location)[0];
			} else {
				current_trip.current_target <- road.end;
			}

			ask road {
				//write "JOIN -> " +  road.get_size() + " : " + milliseconds_between(starting_date, start_time);
				do join(myself, start_time, !joinable);
			}
			
		} else {
			current_trip.is_waiting <- true;
			
			ask road {
				do join(myself, start_time, !joinable);
			}

			current_trip.next_road <- road;
		}

	}

	// Change road
	action change_road (date request_date) {
		if has_next_road() {
			do inner_change_road(get_next_road(), request_date);
		} else {
			do leave_current_road(request_date);
			do end(request_date);
		}

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
		float computed_duration <- (location distance_to target) / get_speed_meter_per_second();
		return abs(computed_duration);	
	}

	// Compute straight forward duration: transport target in the given road
	float compute_straight_forward_duration_through_road (Road road, point target) {
		float dist <- topology(network.available_graph) distance_between [road.start, target];
		return road.get_road_travel_time(self, dist);	
	}

}
