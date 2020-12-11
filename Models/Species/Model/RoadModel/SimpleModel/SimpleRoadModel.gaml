/**
* Name: SimpleRoadModel
* Simple implementation of road. 
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
	SimpleRoadModel create_simple_road_model (Road simple_attached_road) { 
		create SimpleRoadModel returns: values {
			color <- #grey;
			attached_road <- simple_attached_road;
		}

		return values[0];
	}
}

/** 
 * Simple road species
 * Simple road are not realistic roads, there is no interactions, no priority and no capacity check
 * 
 * Implement Road species
 */
species SimpleRoadModel parent: RoadModel {

	// The list of transport in this road
	list<Transport> transports;

	// Implementation get transports
	list<Transport> get_transports  {
		return transports;
	}
	
	// Implementation get transports
	action set_transports (list<Transport> transport_list) {
		add item: transport_list to: transports all: true;
	}
	
	action add_transport(Transport transport) {
		// Add the wrapped transport
		add transport to: transports;
	}

	// Remove transport
	action remove_transport(Transport transport) {		
		// Remove
		remove transport from: transports;	
	}
	
	// Clear transports
	action clear_transports {
		 loop transport over: transports {
		 	// Remove event from the scheduler
		 	ask transport {
		 		do clear_events;
		 	}
		 }
		remove from: transports all: true;
	}
	
	// The simple road is just a road without interference
	bool has_capacity (Transport transport) {
		return true;
	}

	// Implementation of join
	action join (Transport transport, date request_time) {
		do add_transport(transport);		
		
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
		}

		// Ask the transport to change road when the travel time is reached
		float travel_time <- transport.compute_straight_forward_duration_through_road(attached_road, transport.get_current_target());
		ask transport {
			do update_positions(myself.attached_road.start_node.location);
		}
		do later the_action: end_road at: request_time + travel_time refer_to: transport;

	}
	
	// Implement end
	action end_road {
		ask refer_to as Transport {
			do update_positions(myself.attached_road.end_node.location);
			do change_road(myself.event_date);			
		}
	}
	
	// Implementation of leave
	action leave (Transport transport, date request_time) {		
		do remove_transport(transport); 
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