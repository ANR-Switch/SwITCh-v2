/**
* Name: Trip
* Based on the internal empty template. 
* Author: nvers
* Tags: 
*/


model Trip

import "Transport.gaml"

species Trip {
	
	Transport transport;
	
	point target_pos;
	
	action start{
		ask transport {
			do start(myself.target_pos); 
		}
	}
}

