/**
* Name: RoadModel
* Virtual road model species. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../../Network/Crossroad.gaml"
import "../../Transport/Transport.gaml"

/** 
 * Road model virtual species
 */
species RoadModel virtual: true parent: IRoad skills: [scheduling] {
	// The event manager
	agent event_manager <- EventManager[0];
	
	// Road color
	rgb color;
	
	// Waiting queue
	queue<Transport> waiting;
	
	// Attached road in the network
	Road attached_road <- nil;

	// Virtual join the road
	action join (Transport transport, date request_time) virtual: true;
	
	// Virtual end 
	action end_road virtual: true;

	// Virtual leave the road
	action leave (Transport transport, date request_time) virtual: true;
	
	// Virtual get transports
	list<Transport> get_transports virtual: true;

	// Virtual set transports
	action set_transports (list<Transport> transport_list) virtual: true;
	
	// Virtual clear transports
	action clear_transports virtual: true;
	
	// True if this road has capacity
	bool has_capacity (Transport transport) virtual: true;
	
	// Add transport to waiting queue
	action push_in_waiting_queue(Transport transport) {
		push item: transport to: waiting;
	}
		
	// Check if there is waiting agents and add it if it's true
	action check_wainting_agents(date request_time) {
		// Check if waiting tranport can be join the road
		loop while: not empty(waiting) and has_capacity(first(waiting)) {
			// Get first transport
			Transport first <- pop(waiting);
			
			// Join new road
			do join(first, request_time);
			
			// Leave previous road
			ask first {
				do leave_current_road(request_time);
			}
		}
	}
	
	// Get size
	float get_size {
		return attached_road.get_size();
	}
	
	// Get max freeflow speed
	float get_max_freeflow_speed (Transport transport) {
		return attached_road.get_max_freeflow_speed(transport);
	}
	
	// Get free flow travel time in secondes (time to cross the road when the speed of the transport is equals to the maximum speed)
	float get_free_flow_travel_time (Transport transport) {
		return attached_road.get_free_flow_travel_time(transport);
	}

}
