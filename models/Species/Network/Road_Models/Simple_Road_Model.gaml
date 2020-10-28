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
		geometry geom_display <- (shape + (2.0));	
		draw geom_display;
	}
	
}