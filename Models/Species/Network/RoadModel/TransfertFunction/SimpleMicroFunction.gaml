/**
* Name: SimpleMicroFonction
* Transfert function between simple and micro. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "TransfertFunction.gaml"


/** 
 * Add to world the action to create a new function
 */
global {
	// Create a new function
	SimpleMicroFunction create_simple_micro_function {
		create SimpleMicroFunction returns: functions {
		}

		return functions[0];
	}
}


/** 
 * Simple-Micro transfert fonction species
 */
species SimpleMicroFunction parent: TransfertFunction {
	
	// Create models
	action create_models(Road multi_road) {
		
	}
	
	// Model a to b transfert
	action switch_to_b {
		is_a_model <- false;
	}
	
	// Model b to a transfert
	action switch_to_a  {
		is_a_model <- true;
	}
}
