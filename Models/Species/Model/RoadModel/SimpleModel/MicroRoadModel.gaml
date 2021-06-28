/**
* Name: MicroRoadModel
* Implementation of micro road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../RoadModel.gaml"
import "../../Transport/TransportMovingGippsWrapper.gaml"

/** 
 * Add to world the action to create a new road
 */
global {
// Create a new road
	MicroRoadModel create_micro_road_model (Road micro_attached_road) {
		create MicroRoadModel returns: values {
			color <- #blue;
			attached_road <- micro_attached_road;
		}

		return values[0];
	}

}

/** 
 * Micro road species
 * Simple road are not realistic roads, there is no interactions, no priority and no capacity check
 * 
 * Implement Road species
 */
species MicroRoadModel parent: RoadModel {
	// The list of transport in this road
	map<Transport, TransportMovingGippsWrapper> transports_wraps;
	list<Transport> transports;

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
		TransportMovingGippsWrapper wrap <- world.create_transport_moving_gipps_wrapper(transport, transports_wraps closest_to transport, self);

		// Add the wrapped transport
		add transport to: transports;
		add wrap at: transport to: transports_wraps;
	}

	// Add transport
	action add_transport_with_delta_cycle (Transport transport, float delta_cycle, date request_date) {
		do add_transport(transport);
		ask transports_wraps[transport] {
			do moving(request_date);
		}
	}

	// Remove transport
	action remove_transport (Transport transport) {
		// Get wrap
		TransportMovingGippsWrapper wrap <- transports_wraps[transport];
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

	// Implementation of join
	action join (Transport transport, date request_time, bool waiting) {
		float entry_time <- 0.0;
		if transport.current_trip.current_road != nil {
			entry_time <- attached_road.start_node.waiting_time;
		}

		do later the_action: entry at: request_time + entry_time refer_to: transport;

		// Change capacity
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
		}

	}
	
	// Entry action
	action entry {
		float simulation_cycle <- ((starting_date + time) - starting_date) / step;
		float event_cycle <- (event_date - starting_date) / step;
		Transport transport <- refer_to as Transport;
		do add_transport_with_delta_cycle(transport, simulation_cycle - event_cycle, event_date);
	}

	// Implement end
	action end_road(Transport transport, date request_time) {
		ask transport {
			do change_road(myself.event_date);
		}
	}

	// Capacity
	bool has_capacity (Transport transport) {
		return true;
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
		list<Transport> tmp <- (transports) where(each = transport);	
		return length(tmp) > 0;
	}

}
