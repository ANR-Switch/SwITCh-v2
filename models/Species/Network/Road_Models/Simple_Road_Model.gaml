/**
* Name: Road
* Road species. 
* Author: Jean-François Erdelyi
* Tags: 
*/

model SwITCh

import "../Road.gaml"
import "../../Transport/Transport.gaml"

species Simple_Road_Model parent: Road {
	
	list<Transport> transports;
	
	action join(Transport t, date request_time){
		add item:t to:transports;
		date travelTime <- getFreeFlowTravelTime(t);
		
		// doLater ask transport to do changeroad at time travelTime
		
		ask t {
			do later the_action: changeRoad with_arguments: map("signal_time"::travelTime) at: travelTime;
		}
	}
	
	action leave(Transport t, date request_time){
		remove item:t from: transports;
	}
}