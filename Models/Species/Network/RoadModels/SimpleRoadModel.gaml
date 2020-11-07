/**
* Name: SimpleRoadModel
* Simple implementation of road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../Road.gaml"
import "../../Transport/Transport.gaml"

/** 
 * Simple road species
 * 
 * Implement Road species
 */
species SimpleRoadModel parent: Road {

	// The list of transport in this road
	list<Transport> transports;

	// Implementation of join
	action join (Transport transport, date request_time) {
		add item: transport to: transports;
		float travelTime <- get_free_flow_travel_time(transport);
		ask transport {
			myself.current_capacity <- myself.current_capacity - size;
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
			myself.current_capacity <- myself.current_capacity + size;
		}
	}
	
	// Implement of getEntryPoint
	point get_entry_point {
		return start_node.location;
	}
	
	// Implement of getExitPoint
	point get_exit_point {
		return end_node.location;
	}
}