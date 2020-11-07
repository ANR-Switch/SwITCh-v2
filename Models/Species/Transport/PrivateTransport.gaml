/**
* Name: PrivateTransport
* Based on the internal empty template. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../Individual/Individual.gaml"
import "Transport.gaml"

/** 
 * Private transport virtual species
 */
species PrivateTransport parent: Transport virtual: true {

	// Implementation of end
	action end (date arrived_time) {
		is_visible <- false;
		
		// For each passenger execute next trip
		loop passenger over: passengers {
			ask passenger {
				do execute_trip_chain(arrived_time);
			}

		}

		// "getOut" is not necessary because -> die
		do die;
	}

}
