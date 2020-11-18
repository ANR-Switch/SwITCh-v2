/**
* Name: Car
* The private transport Car. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../../../World.gaml"
import "../PrivateTransport.gaml"

/** 
 * Add to world the action to create a new car
 */
global {
	// Create a new car
	Car create_car {
		create Car returns: values {
		}

		return values[0];
	}
}

/** 
 * Car species
 * 
 * Implement PrivateTransport (and Transport) species
 */
species Car parent: PrivateTransport {
	geometry shape <- square(8);

	// Init speed, size and capacity
	init {
		max_speed <- 130.0;
		size <- 4.13; // Argus average size in meters
		max_passenger <- 5;
		network <- world.create_network(world.full_network);
	}

	// Default aspect
	aspect default {
		if is_visible {
			draw shape color: #brown border: #black;
		}

	}

}

