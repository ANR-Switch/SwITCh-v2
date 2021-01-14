/**
* Name: QueueRoadModel
* Implementation of queue road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../SimpleModel/SimpleRoadModel.gaml"
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
species SimpleQueueRoadModel parent: RoadModel skills: [scheduling] {
	// The list of transport in this road
	queue<Transport> transports;

	// Waiting queue
	queue<Transport> waiting_transports;
	
	// Request time of each transport
	map<Transport, date> request_times;
	
	// Outflow duration
	float outflow_duration <- 1 / (600 / 60) #s;
	
	// Check first transport
	action check_first_agent (date request_time) {
		if not empty(transports) {
			Transport first <- first(transports);
			if request_time >= request_times[first] {
				do later the_action: exit at: request_time + outflow_duration refer_to: first;
			} else {
				do later the_action: end_road at: request_times[first];
			}
		}
	}

	// Check if there is waiting agents and add it if it's possible
	action add_waiting_agents (date request_time) {
		// Check if waiting tranport can be join the road
		loop while: not empty(waiting_transports) and has_capacity(first(waiting_transports)) {
			// Get first transport
			Transport first <- pop(waiting_transports);
			
			ask first {
				//do update_positions(myself.attached_road.end_node.location);
				do inner_change_road(myself.attached_road, request_time);
			}
		}
	}

	// Add transport to waiting queue
	action push_in_waiting_queue (Transport transport) {
		push item: transport to: waiting_transports;
	}

	// Implementation get transports
	list<Transport> get_transports {
		return list(transports);
	}

	// Implementation get transports
	action set_transports (list<Transport> transport_list) {
		loop transport over: transport_list {
			do add_transport(transport);
		}
	}
		
	// Check waiting agents
	action check_waiting(date request_date) {
		if length(waiting_transports) > 0 {
			do add_waiting_agents(request_date);
		}
	}

	// Add new transport
	action add_transport (Transport transport) {
		// Add transport
		push item: transport to: transports;
	}
	
	// Add request time transport
	action add_request_time_transport (Transport transport, date request_time) {
		// Add request time
		add request_time at: transport to: request_times;				
	}

	// Remove transport
	action remove_transport (Transport transport) {
		// Remove
		Transport first <- pop(transports);
		remove key: first from: request_times;
	}

	// Clear transports
	action clear_transports {
		loop transport over: transports {
			// Remove event from the scheduler
			ask transport {
				do clear_events;
			}

		}

		remove key: transports from: request_times;
		remove from: transports all: true;
	}

	// Implementation of join
	action join (Transport transport, date request_time, bool waiting) {
		if waiting {
			do push_in_waiting_queue(transport);
		} else {
			ask transport {
				myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
				do update_positions(first(myself.attached_road.shape.points).location);
			}
			
			// If there is no road before the entry_time is 0;
			float entry_time <- 0.0;
			if transport.current_trip.current_road != nil {
				entry_time <- attached_road.start_node.waiting_time;				
			}
			
			// Something wrong with float precision sometimes...
			if entry_time = 0 and request_time = (starting_date + time) {
				do later the_action: entry refer_to: transport;							
			} else {
				do later the_action: entry at: request_time + entry_time refer_to: transport;			
			}
		}
	}
	
	// Entry action
	action entry {
		Transport transport <- refer_to as Transport;
		
		// Ask the transport to change road when the travel time is reached
		ask transport {
			do update_positions(myself.attached_road.location);
		}
		
		// Compute travel time
		float travel_time <- transport.compute_straight_forward_duration_through_road(attached_road, transport.get_current_target());		
		
		// Add data
		do add_transport(transport);
		do add_request_time_transport(transport, (event_date + travel_time));
		//do check_waiting(event_date);
		
		// If this is the first transport
		if transport = first(transports) {
			do check_first_agent(event_date);		
		}
	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {
		// Remove transport (pop first)
		do remove_transport(transport);
		//do check_waiting(request_time);
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity + size;
		}

		// Check and add transport
		do check_first_agent(request_time);
		do check_waiting(request_time);
	}
	
	// Exit action
	action exit {
		ask refer_to as Transport {
			do update_positions(last(myself.attached_road.shape.points));
			do change_road(myself.event_date);
		}
	}
	
	// Implement get max freeflow speed
	float get_max_freeflow_speed (Transport transport) {
		return min([transport.max_speed, attached_road.max_speed * 0.6]) #km / #h;
	}
	
	// Compute the travel of incoming transports
	// The formula used is BPR equilibrium formula
	float get_road_travel_time (Transport transport, float distance_to_target) {
		float free_flow_travel_time <- get_free_flow_travel_time(transport, distance_to_target);
		float ratio <- ((attached_road.max_capacity - attached_road.current_capacity) / attached_road.max_capacity);
		float travel_time <- free_flow_travel_time * (1.0 + 0.15 * ratio ^ 4);
		return travel_time with_precision 3;
	}

	// Implement end
	action end_road {		
		// If the transport have crossed the road
		do later the_action: exit at: event_date + outflow_duration refer_to: first(transports);
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
