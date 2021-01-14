/**
* Name: RoadModelInterface
* Virtual road interface model species. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "Network/Crossroad.gaml"
import "Transport/Transport.gaml"

/** 
 * Road interface model virtual species
 */
species IRoad virtual: true {
	// Virtual join the road
	action join (Transport transport, date request_time, bool waiting) virtual: true;

	// Virtual leave the road
	action leave (Transport transport, date request_time) virtual: true;
	
	// Virtual get size
	float get_size virtual: true;
	
	// Virtual get max freeflow speed
	float get_max_freeflow_speed (Transport transport) virtual: true;
	
	// Virtual get road travel time
	float get_road_travel_time (Transport transport, float distance_to_target) virtual: true;
	
	// Virtual get free flow travel time in secondes (time to cross the road when the speed of the transport is equals to the maximum speed)
	float get_free_flow_travel_time (Transport transport, float distance_to_target) virtual: true;
	
	// Virtual get true if this road has capacity
	bool has_capacity (Transport transport) virtual: true;

	// Check if exists
	bool check_if_exists (Transport transport) virtual: true;
	
}
