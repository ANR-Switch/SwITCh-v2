/**
* Name: Transport
* Commons behavior of public and private transport. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "../../Utilities/EventManager.gaml"
import "../Network/Road.gaml"
import "../Individual/Individual.gaml"

/** 
 * Transport virtual species
 * 
 * Can schedule actions (scheduling skill) using the action 'later'
 */
species Transport virtual: true skills: [scheduling] {

	// The event manager
	agent event_manager <- EventManager[0];

	// List of roads that lead to the target
	list<Road> path_to_target;

	// Travelers
	list<Individual> passengers <- [];

	// Road graph available for the transport
	graph<Crossroad, Road> available_graph;

	// Maximum speed for a transport (km/h)
	float max_speed;

	// Transport length (meters)
	float size;

	// Passenger capacity 
	int max_passenger;

	// If true is already computed
	bool computed <- false;
	
	// If true path is nil
	bool path_nil <- false;
	
	// If true the transport is visible
	bool is_visible <- false;

	// Passenger get in the transport
	bool getIn (Individual i) {
		// Can't be more than the max capacity
		if (length(passengers) < max_passenger) {
			add item: i to: passengers;
			return true;
		}

		return false;
	}

	// Passenger get out the transport
	action getOut (Individual i) {
		remove item: i from: passengers;
	}
	
	// Compute
	action compute(point start_location, point end_location) {
		path the_path <- path_between(available_graph, start_location, end_location);
		if (the_path = nil) {
			// Something wrong
			path_nil <- true;
		} else {
			path_to_target <- list<Road>(the_path.edges);
		}
		computed <- true;
	}
	
	// Pre compute path
	point preCompute(point start_location, point end_location) {
		do compute(start_location, end_location);
		if (computed and not path_nil) {
			return first(path_to_target).start_node.location;
		}
		return nil;
	}

	// Start to move
	action start (point start_location, point end_location, date start_time) {
		is_visible <- true;
		if not computed {
			do compute(start_location, end_location);
		} 

		if (computed and path_nil) {
			// Something wrong
			write "The path is nil so there is (maybe) a problem with the graph";
			do end(start_time);
		} else {
			do updateOwnPositionStart();
			do updatePassengerPosition();
			do later the_action: changeRoad at: start_time;
		}

	}

	// Virtual end travel
	action end (date arrived_time) virtual: true;

	// Change road signal
	action changeRoad {
		// Leave the current road
		Road r <- getCurrentRoad();
		if r != nil {
			ask getCurrentRoad() {
				do leave(myself, myself.event_date);
			}
		
		}

		remove first(path_to_target) from: path_to_target;

		// Join the next road
		if hasNextRoad() {
			do updateOwnPositionStart();
			do updatePassengerPosition();
			ask getCurrentRoad() {
				do join(myself, myself.event_date);
			}

		} else {
			do end(event_date);
		}

	}

	// Update transport position
	action updateOwnPositionStart {
		location <- getCurrentRoad().start_node.location;
	}
	
	// Update transport position
	action updateOwnPositionEnd {
		location <- getCurrentRoad().end_node.location;
	}

	// For each 'changeRoad' we must redefine the position of all passengers
	action updatePassengerPosition {
		loop passenger over: passengers {
			passenger.location <- location;
		}

	}

	// Check if there is a next road
	bool hasNextRoad {
		return length(path_to_target) > 1;
	}

	// Get current road of this transport
	Road getCurrentRoad {
		if length(path_to_target) > 0 {
			return path_to_target[0];
		} else {
			return nil;
		}

	}

	// Get next road
	Road getNextRoad {
		if (hasNextRoad()) {
			return path_to_target[1];
		} else {
			return nil;
		}

	}

}
