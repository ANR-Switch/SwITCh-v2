/**
* Name: QueueRoadModel
* Implementation of queue road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../RoadModel.gaml"
import "MicroRoad/TransportWrapper.gaml"

/** 
 * Add to world the action to create a new road
 */
global {
	// Create a new road
	QueueRoadModel create_queue_road_model (Road queue_attached_road) {
		create QueueRoadModel returns: values {
			attached_road <- queue_attached_road;
		}

		return values[0];
	}
}


/** 
 * Queue road species
 * 
 * Implement Road species
 */
species QueueRoadModel parent: RoadModel {
	// The list of transport in this road
	list<Transport> transports;

	// Implementation get transports
	list<Transport> get_transports  {
		return list(transports);
	}
	
	// Implementation set transports
	action set_transports (list<Transport> transport_list) {
		loop transport over: transport_list {
			do add_transport(transport);
		}
	}
	
	// Clear transports
	action clear_transports {
		remove from: transports all: true;
	}
	
	// Add transport
	action add_transport(Transport transport) {
		// Add the wrapped transport
		add transport to: transports;
	}

	// Remove transport
	action remove_tansport(Transport transport) {		
		// Remove
		remove transport from: transports;	
	}

	// Implementation of join
	action join (Transport transport, date request_time) {
		do add_transport(transport);
		
		// Change capacity
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
		}
	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {
		do remove_tansport(transport);
		
		// Change capacity		
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


