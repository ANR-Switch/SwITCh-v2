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
		create Walk returns: values {
			is_connexion <- false;
		}

		return values[0];
	}

	// Create a new walk connexion
	Walk create_walk_connexion {
		create Walk returns: values {
			is_connexion <- true;
		}

		return values[0];
	}

}

/** 
 * Walk species
 * 
 * Implement PrivateTransport (and Transport) species
 */
species Walk parent: PrivateTransport {

	// If true is connexion trip
	bool is_connexion <- false;

	// Init speed, size and capacity
	init {
		max_speed <- 6.0;
		size <- 1.0;
		max_passenger <- 1;
		network <- world.create_network(world.full_network);
	}

	// Start to move
	action start (point start_location, point end_location, date start_time, Trip trip) {
		current_trip <- trip;
		is_visible <- true;
		if is_connexion {
			// Start connexion
			do connexion(start_time);
		} else {
			// Start standard
			do start_standard(start_location, end_location, start_time);
		}

	}

	// Start connexion
	action connexion (date start_time) {
		// First and the only passenger in walk
		// Get location and target in order to compute the straight forward duration
		location <- passengers[0].location;
		current_trip.current_target <- passengers[0].get_target();
		date connexion_date <- start_time + compute_straight_forward_duration(current_trip.current_target);

		// Do the normal behavior after straight forward duration
		do later the_action: connexion_network at: connexion_date;
	}

	// Super end (PrivateNetwork) wrapper
	action connexion_network {
		do update_positions(current_trip.current_target);
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

