/**
* Name: QueueRoadModel
* Implementation of queue road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../RoadModel.gaml"

/** 
 * Add to world the action to create a new road
 */
global {
	// Create a new road
	SimpleQueueRoadModel create_simple_queue_road_model (Road queue_attached_road) {
		create SimpleQueueRoadModel returns: values {
			color <- #green;
			attached_road <- queue_attached_road;
		}

		return values[0];
	}
}

/** 
 * Simple queue road species
 * Queued road use queue to represent the transport inside the road in order to simulate priority and there is capacity check
 *  
 * Implement Road species
 */
species SimpleQueueRoadModel parent: RoadModel {
	// The list of transport in this road
	queue<Transport> transports;

	// Waiting queue
	queue<Transport> waiting_transports;
	
	// Request time of each transport
	map<Transport, date> request_times;
	
	// Outflow duration
	float outflow_duration <- 1 / (600 / 60) #s;
	
	// Last out date
	date last_out <- nil;
	
	/**
	 * Handlers collections
	 */
	
	// Add transport to waiting queue
	action push_in_waiting_queue (Transport transport) {
		push item: transport to: waiting_transports;
	}
	
	// Add new transport
	action add_transport (Transport transport) {
		push item: transport to: transports;
	}
	
	// Add request time transport
	action add_request_time_transport (Transport transport, date request_time) {
		do add_transport (transport);
		add request_time at: transport to: request_times;				
	}
	
	// Implementation get transports
	list<Transport> get_transports {
		return list(transports);
	}

	// Remove transport
	action remove_transport (Transport transport) {
		Transport first <- pop(transports);
		remove key: first from: request_times;
	}

	// Clear transports
	action clear_transports {
		loop transport over: transports {
			// Remove event from the event manager
			ask transport {
				do clear_events;
			}

		}
		remove key: transports from: request_times;
		remove from: transports all: true;
	}
	
	/**
	 * Join
	 */
	 
	// Implementation of join
	action join (Transport transport, date request_time, bool waiting) {
		if waiting {
			do push_in_waiting_queue(transport);
		} else {
			ask transport {
				myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
				do update_positions(first(myself.attached_road.start).location);
			}
			
			// Ask the transport to change road when the travel time is reached
			ask transport {
				do update_positions(myself.attached_road.location);
			}
			
			// Compute travel time
			float travel_time <- transport.compute_straight_forward_duration_through_road(attached_road, transport.get_current_target());		
			/*write "TIME -------------------";
			write request_time;
			write travel_time;
			write request_time + travel_time;
			write "END  -------------------";*/

			// Add data
			do add_request_time_transport(transport, (request_time + travel_time));
			
			// If this is the first transport
			if length(transports) = 1 {
				do check_first_agent(request_time);		
			}		
		}
	}
	 
	/**
	 * Leave
	 */
	
	// Implementation of leave
	action leave (Transport transport, date request_time) {		
		// Remove transport (pop first)
		do remove_transport(transport);
		
		// Update capacity
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity + size;
		}

		// Check and add transport
		do check_waiting(request_time);
	}
	
	// Exit signal
	action exit_signal {
		do exit(refer_to as Transport, event_date);
	}
	
	// Exit action
	action exit(Transport transport, date request_time) {
		last_out <- request_time;
		ask transport {
			do update_positions(myself.attached_road.end);
			do change_road(request_time);
		}
	}
	
	// Implement end
	action end_road(Transport transport, date request_time) {
		if last_out = nil {
			do exit(transport, request_time);
		} else {
			float delta <- (request_time - last_out);
			if delta >= outflow_duration {
				do exit(transport, request_time);
			} else {
				// If the transport has crossed the road
				date signal_date <- request_time + (outflow_duration - delta);
				
				// If the signal date is equals to the actual step date then execute it directly
				if signal_date = (starting_date + time) {
					do exit(transport, request_time + (outflow_duration - delta));
				} else {
					do later the_action: exit_signal at: request_time + (outflow_duration - delta) refer_to: transport;					
				}
			}
		}		
	}

	// Implement end
	action end_road_signal {
		do end_road(refer_to as Transport, event_date);
	}
	
	/**
	 * Waiting agents
	 */
	
	// Check waiting agents
	action check_waiting(date request_time) {
		do check_first_agent(request_time);
		if length(waiting_transports) > 0 {
			do add_waiting_agents(request_time);
		}
	}
	
	// Check first transport
	action check_first_agent (date request_time) {
		if not empty(transports) {
			Transport transport <- first(transports);
			date end_road_date; 
			if request_time > request_times[transport] {
				end_road_date <- request_time;
			} else {
				end_road_date <- request_times[transport];
			}
			
			if end_road_date = (starting_date + time) {
				do end_road(transport, end_road_date);
			} else {
				do later the_action: end_road_signal at: end_road_date refer_to: transport;			
			}
		}
	}

	// Check if there is waiting agents and add it if it's possible
	action add_waiting_agents (date request_time) {
		// Check if waiting tranport can be join the road
		loop while: not empty(waiting_transports) and has_capacity(first(waiting_transports)) {
			// Get first transport			
			ask pop(waiting_transports) {
				do inner_change_road(myself.attached_road, request_time);
			}
		}
	}
	
	
	/**
	 * Utilities
	 */	

	// Implement get max freeflow speed
	float get_max_freeflow_speed (Transport transport) {
		return min([transport.max_speed, attached_road.max_speed]) #km / #h;
	}
	
	// Compute the travel of incoming transports
	// The formula used is BPR equilibrium formula
	float get_road_travel_time (Transport transport, float distance_to_target) {
		float free_flow_travel_time <- get_free_flow_travel_time(transport, distance_to_target);
		float ratio <- ((attached_road.max_capacity - attached_road.current_capacity) / attached_road.max_capacity);
		float travel_time <- free_flow_travel_time * (1.0 + 0.15 * ratio ^ 4);
		return travel_time with_precision 3;
	}

	// Just the current capacity
	bool has_capacity (Transport transport) {
		return attached_road.current_capacity >= transport.size; 
	}
	
	// True if already in the road
	bool check_if_exists(Transport transport) {
		list<Transport> tmp <- (transports + waiting_transports) where(each = transport);	
		return length(tmp) > 0;
	}
}
