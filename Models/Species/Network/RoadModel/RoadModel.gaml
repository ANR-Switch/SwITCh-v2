/**
* Name: RoadModel
* Virtual road model species. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../Crossroad.gaml"
import "../../Transport/Transport.gaml"

/** 
 * Road model virtual species
 */
species RoadModel virtual: true parent: RoadModelInterface {
	// Attached road in the network
	Road attached_road <- nil;

	// Virtual join the road
	action join (Transport transport, date request_time) virtual: true;

	// Virtual leave the road
	action leave (Transport transport, date request_time) virtual: true;
	
	// Virtual get entry point in the road
	point get_entry_point virtual: true;
	
	// Virtual get exit point in the road
	point get_exit_point virtual: true;
	
	// Virtual get transports
	list<Transport> get_transports virtual: true;

	// Virtual set transports
	action set_transports (list<Transport> transport_list) virtual: true;
	
	// Virtual clear transports
	action clear_transports virtual: true;

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

	// True if this road has capacity
	bool has_capacity (float capacity) {
		return attached_road.has_capacity(capacity);
	}

}
