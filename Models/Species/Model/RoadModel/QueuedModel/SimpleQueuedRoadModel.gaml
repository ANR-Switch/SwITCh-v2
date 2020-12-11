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
species SimpleQueueRoadModel parent: RoadModel {
	// The list of transport in this road
	queue<Transport> transports;

	// Waiting queue
	queue<Transport> waiting;
	
	// Request time of each transport
	map<Transport, date> request_times;

	// Check first transport
	action check_first_agent (date request_time) {
		if not empty(transports) {
			Transport first <- first(transports);
			if request_time >= request_times[first] {
				ask first {
					do update_positions(myself.attached_road.end_node.location);
					do change_road(request_time);
				}
			} else {
				do later the_action: end_road at: request_times[first];
			}
		}
	}

	// Check if there is waiting agents and add it if it's possible
	action add_wainting_agents (date request_time) {
		// Check if waiting tranport can be join the road
		loop while: not empty(waiting) and has_capacity(first(waiting)) {
			// Get first transport
			Transport first <- pop(waiting);
			
			ask first {
				//do update_positions(myself.attached_road.end_node.location);
				do inner_change_road(myself.attached_road, request_time);
			}
		}

	}

	// Add transport to waiting queue
	action push_in_waiting_queue (Transport transport) {
		push item: transport to: waiting;
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
	reflex check_waiting when: length(waiting) > 0 {
		do add_wainting_agents((starting_date + time));
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
	action join (Transport transport, date request_time) {
		if not has_capacity(transport) {
			do push_in_waiting_queue(transport);
		} else {
			ask transport {
				myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
			}
			
			// If there is no road before the entry_time is 0;
			float entry_time <- 0.0;
			if transport.current_trip.current_road != nil {
				entry_time <- attached_road.start_node.waiting_time;				
			}
			
			do later the_action: entry at: request_time + entry_time refer_to: transport;			
		}	
	}
	
	// Entry action
	action entry {
		Transport transport <- refer_to as Transport;
		
		// Ask the transport to change road when the travel time is reached
		ask transport {
			do update_positions(myself.attached_road.start_node.location);
		}
		
		// Compute travel time
		float travel_time <- transport.compute_straight_forward_duration_through_road(attached_road, transport.get_current_target());
		
		// Add data
		do add_transport(transport);	
		do add_request_time_transport(transport, (event_date + travel_time));
		
		// If this is the first transport
		if transport = first(transports) {
			do check_first_agent(event_date);		
		}
	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {	
		// Remove transport (pop first)
		do remove_transport(transport);
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity + size;
		}

		// Check and add transport
		do check_first_agent(request_time);
	}

	// Implement end
	action end_road {		
		// If the transport have crossed the road
		ask first(transports) {
			// Udpdate position
			do update_positions(myself.attached_road.end_node.location);
			do change_road(myself.event_date);
		}
	}

	// Just the current capacity
	bool has_capacity (Transport transport) {
		return true; 
	}
	
	// True if already in the road
	bool check_if_exists(Transport transport) {
		list<Transport> tmp <- (transports + waiting) where(each = transport);	
		return length(tmp) > 0;
	}
}
