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
		create SimpleMicroRoadModel returns: values {
			attached_road <- simple_micro_attached_road;
			transfert <- world.create_simple_micro_function(self);
		}

		return values[0];
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
	
	// Check micro param
	reflex check_param {
		do switch_model(micro_level);
	}

	// Switch model
	action switch_model (bool switch_micro) {
		if switch_micro {
			return transfert.switch_to_b();
		} else {
			return transfert.switch_to_a();
		}

	}
	
	// Implementation get passengers
	list<Transport> get_transports  {
		return get_road_model().get_transports();
	}
	
	// Implementation get transports
	action set_transports (list<Transport> transport_list) {
		return get_road_model().set_transports(transport_list);
	}
	
	// Clear transports
	action clear_transports {
		return get_road_model().clear_transports();
	}

	// Implementation of join
	action join (Transport transport, date request_time) {
		return get_road_model().join(transport, request_time);
	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {
		return get_road_model().leave(transport, request_time);
	}

	// Implement of getEntryPoint
	point get_entry_point {
		return get_road_model().get_entry_point();
	}

	// Implement of getExitPoint
	point get_exit_point {
		return get_road_model().get_exit_point();
	}

	// Accessor
	RoadModel get_road_model {
		return transfert.get_road_model();
	}

}
