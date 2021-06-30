/**
* Name: Crossroad
* Is the node of road graph.  
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../Transport/Transport.gaml"

/** 
 * Crossroad species
 */
species Crossroad {
	
	// OSM type (highway feature for node: https://wiki.openstreetmap.org/wiki/Key:highway) 
	string type;
	
	// OSM information on crossroad (see https://wiki.openstreetmap.org/wiki/Tag:highway%3Dcrossing)
	string crossing;
	
	// Subarea (if the world is composed of several areas)
	list<string> sub_areas;
	
	// Waiting time
	float waiting_time <- 0.0;
		
	// For now just the presence or not of transports
	bool is_available {
		return length(Transport where (circle(3) overlaps each)) <= 0;
	}
	
	// Default aspect
	aspect default {
		draw circle(3) color: #grey border: #black;
	}
}
