/**
* Name: MicroRoadModel
* Implementation of micro road. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../RoadModel.gaml"
import "MicroRoad/TransportWrapper.gaml"

/** 
 * Add to world the action to create a new road
 */
global {
	// Create a new road
	MicroRoadModel create_micro_road_model (Road micro_attached_road) {
		create MicroRoadModel returns: micro_roads {
			attached_road <- micro_attached_road;
		}

		return micro_roads[0];
	}
}


/** 
 * Micro road species
 * 
 * Implement Road species
 */
species MicroRoadModel parent: RoadModel {
	// The list of transport in this road
	list<TransportWrapper> transports;
	
	// Map of transport <-> wrapper
	map<Transport, TransportWrapper> transports_map;

	// Implementation of join
	action join (Transport transport, date request_time) {
		// Create wrap
		TransportWrapper wrap <- world.create_wrapper(transport);
		
		// Change capacity
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity - size;
		}

		// Add all transport as guest
		ask wrap {
			do add_guests(myself.transports);
			location <- transport.location;
			desired_speed <- myself.attached_road.get_max_freeflow_speed(transport);
			speed <- desired_speed;
			target <- myself.get_exit_point();
			size <- wrapped.size;
		}
		
		// Add this new transport as guest for all other transports
		ask transports {
			do add_guest(wrap);
		}
		
		// Add the wrapped transport
		add item: wrap to: transport;
		add item: wrap at: transport to: transports_map;
	}

	// Implementation of leave
	action leave (Transport transport, date request_time) {
		// Get wrap
		TransportWrapper wrap <- transports_map[transport];
				
		// Remove transport
		ask transports {
			do remove_guest(wrap);
		}
		
		// Die wrapper
		if wrap != nil {
			ask wrap {
				do die;
			}
		}
		
		// Remove from the map
		remove transport from: transports_map;

		// Change capacity		
		ask transport {
			myself.attached_road.current_capacity <- myself.attached_road.current_capacity + size;
		}
	}
	
	// Implement of getEntryPoint
	point get_entry_point {
		return attached_road.start_node.location;
	}
	
	// Implement of getExitPoint
	point get_exit_point {
		return attached_road.end_node.location;
	}
}
