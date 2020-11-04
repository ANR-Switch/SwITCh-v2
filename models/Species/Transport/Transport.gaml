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

	// True if is moving
	bool is_moving <- false;

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

	// Start to move
	action start (point start_location, point end_location, date start_time) {
		is_moving <- true;
		path the_path <- path_between(available_graph, start_location, end_location);
		if (the_path = nil) {
		// Something wrong
			write "The path is nil so there is (maybe) a problem with the graph";
			do end(start_time);
		} else {
			path_to_target <- list<Road>(the_path.edges);
			do updateOwnPosition();
			do updatePassengerPosition();
			do later the_action: changeRoad at: start_time;
		}

	}

	// Virtual end travel
	action end (date arrived_time) virtual: true;

	// Change road signal
	action changeRoad {
	// Leave the current road
		if is_moving and hasNextRoad() {
			ask getCurrentRoad() {
				do leave(myself, myself.event_date);
			}

			remove first(path_to_target) from: path_to_target;

			// Join the next road
			if hasNextRoad() {
				do updateOwnPosition();
				do updatePassengerPosition();
				ask getCurrentRoad() {
					do join(myself, myself.event_date);
				}

			} else {
				do end(event_date);
			}

		}

	}

	// Update transport position
	action updateOwnPosition {
		location <- getCurrentRoad().start_node.location;
	}

	// For each 'changeRoad' we must redefine the position of all passengers
	action updatePassengerPosition {
		loop passenger over: passengers {
			passenger.location <- location;
		}

		if passengers[0].name = "Individual98" {
			write "Individual98";
			write location;
			write passengers[0].location;
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
