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
	bool is_a_model <- false;
	
	// A representation
	Road a;
	
	// B representation
	Road b;
	
	// Create models
	action create_models(Road multi_road) virtual: true;
	
	// Model a to b transfert
	action switch_to_b virtual: true;
	
	// Model b to a transfert
	action switch_to_a virtual: true;
	
	// Get current road
	Road get_road {
		if is_a_model {
			return a;
		}
		return b;
	}
}
