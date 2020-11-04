/**
* Name: Walk
* The private transport Walk. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../../../World.gaml"
import "../PrivateTransport.gaml"

/** 
 * Add to world the action to create a new walk
 */
global {
	// Create a new walk
	Walk createWalk {
		create Walk returns: walks {
		}

		return walks[0];
	}

}
	
/** 
 * Walk species
 * 
 * Implement PrivateTransport (and Transport) species
 */
species Walk parent: PrivateTransport {
	
	// Init speed, size and capacity
	init {
		max_speed <- 6.0;
		size <- 1.0;
		max_passenger <- 1;
		available_graph <- world.full_network;
	}

	action end (date arrived_time) {
		location <- getCurrentRoad().end_node.location;
		do updatePassengerPosition();
		loop passenger over: passengers {
			ask passenger {
				do executeTripChain(arrived_time);
			}

		}

		do die;
	}

	aspect default {
		draw square(6) color: #green border: #black;
	}

}

