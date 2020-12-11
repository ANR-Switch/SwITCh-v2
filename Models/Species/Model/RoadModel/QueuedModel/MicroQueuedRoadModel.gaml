/**
* Name: MicroRoadModel
* Implementation of micro road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../RoadModel.gaml"
import "../../Transport/TransportMovingWrapper.gaml"
import "../../Transport/TransportMovingLinearGippsWrapper.gaml"

/** 
 * Add to world the action to create a new road
 */
global {
	// Create a new road
	MicroQueuedRoadModel create_micro_queue_road_model (Road micro_attached_road) {
		create MicroQueuedRoadModel returns: values {
			color <- #blue;
			attached_road <- micro_attached_road;
		}

		return values[0];
	}

}

/** 
 * Micro road species
 * Queued road use queue to represent the transport inside the road in order to simulate priority and there is capacity check 
 * 
 * Implement Road species
 */
species MicroQueuedRoadModel parent: RoadModel {
	// The list of transport in this road
	map<Transport, TransportMovingLinearGippsWrapper> transports_wraps;
	list<Transport> transports;
	
	// Waiting queue
	queue<Transport> waiting;

	// Implementation get transports
	list<Transport> get_transports {
		return transports;
	}

	// Implementation set transports
	action set_transports (list<Transport> transport_list) {
		loop transport over: transport_list {
			do add_transport(transport);
		}

	}

	// Clear transports
	action clear_transports {
		ask transports_wraps {
			do die;
		}

		remove key: transports from: transports_wraps;
		remove from: transports all: true;
	}

	// Add transport
	action add_transport (Transport transport) {		
		// Create wrap
		TransportMovingLinearGippsWrapper wrap <- world.create_transport_moving_linear_gipps_wrapper(transport, transports closest_to transport, self);

		// Add the wrapped transport
		add transport to: transports;
		add wrap at: transport to: transports_wraps;
	}

	// Add transport
	action add_transport_with_delta_cycle (Transport transport, float delta_cycle, date request_date) {
		do add_transport(transport);
		ask transports_wraps[transport] {
			do moving(delta_cycle, request_date);
		}
	}
	
	// Switch from temporarty to transports
	action switch_from_temporary_with_delta_cycle(Transport transport, float delta_cycle, date request_date) {
		do add_transport_with_delta_cycle(transport, delta_cycle, request_date);
	}
	
	// Add transport to waiting queue
	action push_in_waiting_queue (Transport transport) {
		push item: transport to: waiting;
	}

	// Remove transport
	action remove_transport (Transport transport) {		
		// Get wrap
		TransportMovingLinearGippsWrapper wrap <- transports_wraps[transport];
		if not dead(wrap) {
			// Die wrapper	
			ask wrap {
				do die;
			}

		}

		// Remove
		remove transport from: transports;
		remove key: transport from: transports_wraps;
	}
	
	// Check if there is waiting agents and add it if it's possible
	action add_waiting_agents (date request_time) {
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

	// Implementation of join
	action join (Transport transport, date request_time) {
		if not has_capacity(transport) {
			do push_in_waiting_queue(transport);
		} else {
			// Ask the transport to change road when the travel time is reached
			ask transport {
				myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
				//do update_positions(myself.attached_road.start_node.location);
			}
			float simulation_cycle <- ((starting_date + time) - starting_date) / step;
			float event_cycle <- (request_time - starting_date) / step;
			do add_transport_with_delta_cycle(transport, simulation_cycle - event_cycle, request_time);
		}
	}
	
	// Entry action
	action exit {
		ask refer_to as Transport {
			do change_road(myself.event_date);
		}
	}

	// Implement end
	action end_road {	
		Transport transport <- refer_to as Transport;
		
		float entry_time <- 0.0;
		if transport.current_trip.current_road != nil {
			entry_time <- attached_road.start_node.waiting_time;
		}
	
		do later the_action: exit at: event_date + entry_time refer_to: transport;
	}

	// Capacity
	bool has_capacity (Transport transport) {
		return true; 
			// attached_road.current_capacity >= transport.size;
			//and 
			//not (circle(transport.size / 2, transport.location) overlaps (transports closest_to transport));
	}
	
	// Check waiting agents
	reflex check_waiting when: length(waiting) > 0 {
		do add_waiting_agents((starting_date + time));
	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {
		do remove_transport(transport);
		// Change capacity		
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity + size;
		}
	}
	
	// True if already in the road
	bool check_if_exists(Transport transport) {
		list<Transport> tmp <- (transports + waiting) where(each = transport);	
		return length(tmp) > 0;
	}

}
