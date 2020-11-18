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
 * 
 * Implement Road species
 */
species SimpleQueueRoadModel parent: SimpleRoadModel {
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
