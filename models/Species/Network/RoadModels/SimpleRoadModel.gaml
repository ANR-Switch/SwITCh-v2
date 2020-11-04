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
	action join (Transport t, date request_time) {
		add item: t to: transports;
		float travelTime <- getFreeFlowTravelTime(t);
		ask t {
			myself.current_capacity <- myself.current_capacity - size;
		}

		// Ask the transport to change road when the travel time is reached	
		ask t {
			do later the_action: changeRoad at: request_time + travelTime;
		}

	}

	// Implementation of leave
	action leave (Transport t, date request_time) {
		remove item: t from: transports;
		ask t {
			myself.current_capacity <- myself.current_capacity + size;
		}
	}

}