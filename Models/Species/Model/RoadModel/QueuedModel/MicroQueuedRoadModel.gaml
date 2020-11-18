/**
* Name: QueueRoadModel
* Implementation of queue road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../SimpleModel/MicroRoadModel.gaml"
import "../RoadModel.gaml"

/** 
 * Add to world the action to create a new road
 */
global {
	// Create a new road
	MicroQueueRoadModel create_micro_queue_road_model (Road queue_attached_road) {
		create MicroQueueRoadModel returns: values {
			color <- #cyan;
			attached_road <- queue_attached_road;
		}

		return values[0];
	}
}


/** 
 * Micro queue road species
 * 
 * Implement Road species
 */
species MicroQueueRoadModel parent: MicroRoadModel {
	// Just the current capacity
	bool has_capacity (Transport transport) {
		return attached_road.current_capacity >= transport.size;
	}
	
	// Implementation of leave
	action leave (Transport transport, date request_time) {
		do inner_leave(transport, request_time);
		do check_wainting_agents(request_time);
	}
}
