/**
* Name: Road
* Road species. 
* Author: Jean-François Erdelyi
* Tags: 
*/

model SwITCh

import "../Road.gaml"

species Simple_Road_Model parent: Road{
	
	list<Transport> transports;
	
	action join(Transport t, date request_time){
		add item:t to:transports;
		date travelTime <- getFreeFlowTravelTime(t);
		// doLater ask transport to do changeroad at time travelTime
	}
	
	action leave(Transport t, date request_time){
		remove item:t from: transports;
	}
	
	aspect default {
		geometry geom_display <- (shape + lanes);	
		draw geom_display translated_by(trans*2) border: #gray color: rgb(255 * (max_capacity - current_capacity) / max_capacity, 0, 0);
	}
	
}