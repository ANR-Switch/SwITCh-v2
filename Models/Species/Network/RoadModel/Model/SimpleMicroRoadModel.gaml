/**
* Name: SimpleMicroRoadModel
* Implementation of multi road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../TransfertFunction/SimpleMicroFunction.gaml"

/** 
 * Add to world the action to create a new road
 */
global {
	// Create a new road
	SimpleMicroRoadModel create_simple_micro_road_model (Road simple_micro_attached_road) { 
		create SimpleMicroRoadModel returns: simple_micro_roads {
			attached_road <- simple_micro_attached_road;
		}

		return simple_micro_roads[0];
	}
}


/** 
 * Simple micro road species
 * 
 * Implement Road species
 */
species SimpleMicroRoadModel parent: RoadModel {

	// Transfert function Simple-Micro
	TransfertFunction transfert;
	
	// Init multi road model
	init {
		transfert <- world.create_simple_micro_function();
	}

	// Switch model
	action switch_model (bool switch_micro) {
		if switch_micro {
			return transfert.switch_to_b();
		} else {
			return transfert.switch_to_a();
		}

	}

	// Implementation of join
	action join (Transport transport, date request_time) {
		return get_road().join(transport, request_time);
	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {
		return get_road().leave(transport, request_time);
	}

	// Implement of getEntryPoint
	point get_entry_point {
		return get_road().get_entry_point();
	}

	// Implement of getExitPoint
	point get_exit_point {
		return get_road().get_exit_point();
	}

	// Accessor
	Road get_road {
		return transfert.get_road();
	}

}
