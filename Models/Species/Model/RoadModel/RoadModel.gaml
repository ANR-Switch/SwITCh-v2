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

	// Attached road in the network
	Road attached_road <- nil;

	// Virtual join the road
	action join (Transport transport, date request_time, bool waiting) virtual: true;

	// Virtual end 
	action end_road (Transport transport, date request_time) virtual: true;

	// Virtual leave the road
	action leave (Transport transport, date request_time) virtual: true;

	// Virtual get transports
	list<Transport> get_transports virtual: true;

	// Virtual add transport
	action add_transport (Transport transport) virtual: true;

	// Virtual remove transport
	action remove_transport (Transport transport) virtual: true;

	// Virtual clear transports
	action clear_transports virtual: true;

	// True if this road has capacity
	bool has_capacity (Transport transport) virtual: true;
	
	// True if already in the road
	bool check_if_exists(Transport transport) virtual: true;

	// Get size
	float get_size {
		return attached_road.get_size();
	}
	
	// Implement get max freeflow speed
	float get_max_freeflow_speed (Transport transport) {
		return min([transport.max_speed, attached_road.max_speed]) #km / #h;
	}
	
	// Compute the travel of incoming transports
	float get_road_travel_time (Transport transport, float distance_to_target) {
		return get_free_flow_travel_time(transport, distance_to_target) with_precision 3;
	}

	// Get free flow travel time in secondes (time to cross the road when the speed of the transport is equals to the maximum speed)
	float get_free_flow_travel_time (Transport transport, float distance_to_target) {
		return attached_road.get_free_flow_travel_time(transport, distance_to_target);
	}

}
