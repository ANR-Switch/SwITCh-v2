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
	
	Individual i;
	
	point target_pos;

	action start (point position, date start_time) {
		ask transport{
			do getIn(myself.i);
		}
		if (not transport.isMoving) {
			ask transport {
				do start(position, myself.target_pos, start_time);
			}

		}
	}
}

