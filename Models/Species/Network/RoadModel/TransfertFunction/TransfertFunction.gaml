/**
* Name: TransfertFonction
* Transfert function. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../../Road.gaml"

/** 
 * Transfert fonction species
 */
species TransfertFunction virtual: true {
	// If true is 'a' model
	bool is_a_model <- true;
	
	// A representation
	RoadModel a;
	
	// B representation
	RoadModel b;
	
	// Model a to b transfert
	action switch_to_b virtual: true;
	
	// Model b to a transfert
	action switch_to_a virtual: true;
	
	// Get current road
	RoadModel get_road_model {
		if is_a_model {
			return a;
		}
		return b;
	}
}
