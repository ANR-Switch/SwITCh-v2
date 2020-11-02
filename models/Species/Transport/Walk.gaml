/**
* Name: Walk
* Based on the internal empty template. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "PrivateTransport.gaml"

/** 
 * Walk species
 * 
 * Implement PrivateTransport (and Transport) species
 */
species Walk parent: PrivateTransport {
	// Set the transport name
	string transport_mode <- "walk";

	// Init speed, size and capacity
	init {
		max_speed <- 6.0;
		size <- 1.0;
		max_passenger <- 1;
	}

	// Implementation of end
	action end (date arrived_time) {
		do updatePassengerPosition();
		loop passenger over: passengers {
			ask passenger {
				do executeTripChain(arrived_time);
			}

		}

		do die;
	}

	// Default aspect
	aspect default {
		draw square(2) color: #green border: #black;
	}

}

