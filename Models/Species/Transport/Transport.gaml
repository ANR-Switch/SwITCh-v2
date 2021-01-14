/**
* Name: Transport
* Commons behavior of public and private transport. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../../Utilities/EventManager.gaml"
import "../../Utilities/Logbook.gaml"
import "../Network/Network.gaml"
import "../Individual/Individual.gaml"

/** 
 * Transport virtual species
 * 
 * Can schedule actions (scheduling skill) using the action 'later'
 */
species Transport virtual: true skills: [scheduling, logging] {

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
	agent logbook <- Logbook[0];

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
		entry_time <- start_time;
		entry_exec_time <- (starting_date + (machine_time / 1000));
	 	//do later the_action: log_data at: start_time;
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
		do update_positions(last(get_current_road().shape.points));
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
			graph sub_graph <- as_edge_graph([current_trip.current_road], [first(current_trip.current_road.shape.points), last(current_trip.current_road.shape.points)]);
						
			//float road_dist <- current_trip.current_road.start_node distance_to current_trip.current_road.end_node;
			float road_dist <- topology(sub_graph) distance_between [first(current_trip.current_road.shape.points), last(current_trip.current_road.shape.points)];
			//float dist <- (location distance_to current_trip.current_road.end_node) / road_dist;
			float dist <- topology(sub_graph) distance_between [location, last(current_trip.current_road.shape.points)];
			
			//write road_dist;
			//write location;
			//write current_trip.current_road.end_node.location;
			//write topology(network.available_graph) distance_between [location, current_trip.current_road.end_node];
			//write "->" + dist;
			
			do log_plot_2d agent_name: name date: event_date data_name: "time-distance:" + current_trip.current_road.name x: string(abs(starting_date milliseconds_between event_date) / 1000) y: string(dist);			
		}
		//do later the_action: log_data at: event_date + 0.1;
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
				
				// Compute mean speed
				/*if current_trip.current_road != nil {
					//write "----------------";
					//write milliseconds_between(starting_date, entry_time) / 1000;
					//write milliseconds_between(starting_date, request_time) / 1000;
					//write milliseconds_between(entry_time, request_time) / 1000;
					
					date exit_exec_time <- (starting_date + (machine_time / 1000));
					float milli <- milliseconds_between(entry_time, request_time);
					float exec_time <- milliseconds_between(entry_exec_time, exit_exec_time) / 1000;
					if (milli) != 0 {
						mean_speed <- ((current_trip.current_road.start_node distance_to current_trip.current_target) / (milli / 1000)) * 3.6;
						do later the_action: log_data at: request_time;
						do log_plot_2d agent_name: name date: request_time data_name: "speed" x: road.name y: string(mean_speed);
						do log_plot_2d agent_name: name date: request_time data_name: "time" x: road.name y: string((milli / 1000));
						do log_plot_2d agent_name: name date: request_time data_name: "jam" x: road.name y: string(jam_duration);
						do log_plot_2d agent_name: name date: request_time data_name: "exec" x: road.name y: string(exec_time);
						
						entry_time <- nil;
						entry_exec_time <- nil;
						mean_speed <- nil;
						jam_duration <- nil;
						jam_start <- nil;
						
						/*if mean_speed > 50 {
							write "----------";
							write request_time;
							write entry_time;
							write (current_trip.current_road.start_node distance_to current_trip.current_target);
							write mili;
							write name;
							write current_trip.current_road;
							write "MEAN = " + mean_speed;	
						}
					} else {
						write "Something wrong, time is null";
					}
					entry_time <- request_time;
					entry_exec_time <- exit_exec_time;
				}*/
			}
		}
	}
	
	// Inner changer road
	action inner_change_road (Road road, date start_time) {
		//write 'Inner ' + ((starting_date milliseconds_between start_time) / 1000);
			
		// Joined varaiable used to leave road if true
		bool joinable <- false;
		bool exists <- false;
		
		ask road {
			joinable <- has_capacity(myself);
			exists <- check_if_exists(myself);
		}
		
		if exists {
			write "Something wrong, the car is already in the next road";
			return;
		}

		if joinable {
			current_trip.is_waiting <- false;

			// Set the current target depending if it's the last road or not
			do leave_current_road(start_time);
			if it_is_last_road_changing() {
				current_trip.current_target <- (road closest_points_with current_trip.end_location)[0];
			} else {	
				current_trip.current_target <- last(road.shape.points);
				//current_trip.current_target <- road.end_node.location;
			}

			ask road {
				do join(myself, start_time, !joinable);
			}
			
			current_trip.current_road <- road;
			current_trip.next_road <- get_next_road();
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
	
	// Get closest transport in the graph
	list<unknown> get_closest_transport(float distance_max) {
		if current_trip.current_road != nil {
			graph sub_graph <- nil;
			list<Transport> transports <- current_trip.current_road.road_model.get_transports() where (each != self); 
		
			//sub_graph <- network.available_graph;
			sub_graph <- as_edge_graph([current_trip.current_road], [first(current_trip.current_road.shape.points), last(current_trip.current_road.shape.points)]);
			float offset <- topology(sub_graph) distance_between [self, last(current_trip.current_road.shape.points)];		
	
			Transport closest <- nil;
			float closest_distance <- nil;
			list<unknown> res <- [nil, nil];
			
			if length(transports) > 0 {
				res <- inner_get_closest(sub_graph, transports, distance_max, self.location);
			}
			
			if res[0] = nil and offset < distance_max {
				if current_trip.next_road != nil {
					transports <- current_trip.next_road.road_model.get_transports() where (each != self);
					sub_graph <- as_edge_graph([current_trip.next_road], [first(current_trip.next_road.shape.points), last(current_trip.next_road.shape.points)]);
					return inner_get_closest(sub_graph, transports, distance_max, first(current_trip.next_road.shape.points), offset);	
				}
				return [nil, nil];
			}
			return res;
		}
		return [nil, nil];
	}
	
	// Inner get closest
	list<unknown> inner_get_closest(graph sub_graph, list<Transport> transports, float distance_max, point from, float offset <- 0) {
		Transport closest <- nil;
		float closest_distance <- distance_max;
		
		if sub_graph != nil and length(transports) > 0 {
			//loop i from: length(transports) - 1 to: 0  {
			float distance <- offset + (topology(sub_graph) distance_between [from, transports[0]]);				
			
			if distance > distance_max {
				return [closest, closest_distance];
			}
			
			/*if distance < closest_distance and distance > 0.01 {
				closest_distance <- distance;
				closest <- transports[i];
			}*/
			//}
		}
		
		return [nil, nil];
	}
	
	// Get all transport of current and the next road
	list<Transport> get_trip_transports {
		list<Transport> current_transports <- [];
		//list<Transport> next_transports <- [];
		
		if current_trip.current_road != nil {
			current_transports <- current_trip.current_road.road_model.get_transports();
		}
		/*if current_trip.next_road != nil {
			next_transports <- current_trip.next_road.road_model.get_transports();
		}*/
		
		return current_transports;// + next_transports;
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
		//float computed_duration <- (location distance_to target) / road.get_max_freeflow_speed(self);
		//return abs(computed_duration);
		return road.get_road_travel_time(self, (location distance_to target));	
	}

}
