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
	SimpleMicroFunction create_simple_micro_function(RoadModel multi_model) {
		create SimpleMicroFunction returns: values {
			a <- world.create_simple_road_model(multi_model.attached_road);
			b <- world.create_micro_road_model(multi_model.attached_road);
		}

		return values[0];
	}
}


/** 
 * Simple-Micro transfert fonction species
 */
species SimpleMicroFunction parent: TransfertFunction {
	
	// Model b to a transfert
	action switch_to_a  {
		if not is_a_model {
			/*ask a {
				list<Transport> transports <- myself.b.get_transports();
				do set_transports(transports);
			}
			
			ask b {
				do clear_transports;	
			}*/
			
			is_a_model <- true;
		}
	}

	// Model a to b transfert
	action switch_to_b {
		if is_a_model {
			/*ask b {
				list<Transport> transports <- myself.a.get_transports();
				do set_transports(transports);
			}
			ask a {
				do clear_transports;	
			}*/
			
			is_a_model <- false;
		}
	}
}
