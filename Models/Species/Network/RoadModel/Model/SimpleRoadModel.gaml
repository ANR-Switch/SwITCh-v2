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
			attached_road <- simple_attached_road;
		}

		return values[0];
	}
}

/** 
 * Simple road species
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

	// Implementation of join
	action join (Transport transport, date request_time) {
		add item: transport to: transports;
		float travelTime <- attached_road.get_free_flow_travel_time(transport);
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
		}

		// Ask the transport to change road when the travel time is reached
		ask transport {
			do later the_action: change_road at: request_time + travelTime;
		}

	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {		
		remove item: transport from: transports;
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity + size;
		}
	}
	
	// Implement of getEntryPoint
	point get_entry_point {
		return attached_road.start_node.location;
	}
	
	// Implement of getExitPoint
	point get_exit_point {
		return attached_road.end_node.location;
	}
}