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

	// Still virtual end travel
	action end (date arrived_time) virtual: true;
}

