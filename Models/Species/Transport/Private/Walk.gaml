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
	Walk create_walk {
		create Walk returns: walks {
			is_connexion <- false;
		}

		return walks[0];
	}

	// Create a new walk connexion
	Walk create_walk_connexion {
		create Walk returns: walks {
			is_connexion <- true;
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
	
	/**
	 * Entry point
	 */

	// Implementation of end the behavior depends of the kind of walk
	action end (date arrived_time) {
		// If is connexion walk then do connexion
		// Super end (PrivateNetwork) otherwise
		if is_connexion {
			do connexion(arrived_time);
		} else {
			return super.end(arrived_time);
		}	
	}
	
	/**
	 * Connexion behavior
	 */
	
	// Start connexion
	action connexion(date arrived_time) {
		// First and the only passenger in walk
		// Get location and target in order to compute the straight forward duration
		location <- passengers[0].location;
		point target <- passengers[0].get_target();
		date connexion_date <- arrived_time + compute_straight_forward_duration(target);
		
		// Do the normal behavior after straight forward duration
		do later the_action: connexion_network at: connexion_date;
	}
	
	// Super end (PrivateNetwork) wrapper
	action connexion_network {
		return super.end(event_date);
	}

	/**
	 * Aspects
	 */

	// Default aspect
	aspect default {
		if is_visible {
			draw square(8) color: #green border: #black;
		}

	}

}

