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
	Car createCar {
		create Car returns: cars {
		}

		return cars[0];
	}
}

/** 
 * Car species
 * 
 * Implement PrivateTransport (and Transport) species
 */
species Car parent: PrivateTransport {

	// Init speed, size and capacity
	init {
		max_speed <- 130.0;
		size <- 4.13; // Argus average size in meters
		max_passenger <- 5;
		available_graph <- world.full_network;
	}

	// Default aspect
	aspect default {
		if is_visible {
			draw square(6) color: #brown border: #black;
		}

	}

}

