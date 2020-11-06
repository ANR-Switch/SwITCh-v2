/**
* Name: Bike
* The private transport Bike. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../../../World.gaml"
import "../PrivateTransport.gaml"

/** 
 * Add to world the action to create a new bike
 */
global {
	// Create a new bike
	Bike create_bike {
		create Bike returns: bikes {
		}

		return bikes[0];
	}
}

/** 
 * Bike species
 * 
 * Implement PrivateTransport (and Transport) species
 */
species Bike parent: PrivateTransport {

	// Init speed, size and capacity
	init {
		max_speed <- 20.0;
		size <- 1.0;
		max_passenger <- 1;
		available_graph <- world.full_network;
	}

	// Default aspect
	aspect default {
		if is_visible {
			draw square(6) color: #blue border: #black;
		}

	}

}

