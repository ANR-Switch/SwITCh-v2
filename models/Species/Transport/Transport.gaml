/**
* Name: Transport
* Based on the internal empty template. 
* Author: Lo�c
* Tags: 
*/
model SWITCH

import "../../Utilities/Event_Manager.gaml"

import "../Network/Road.gaml"
import "../Individual/Individual.gaml"
species Transport virtual: true skills: [scheduling] {
	// The manager
	agent event_manager <- Event_Manager[0];
	
	//list of roads that lead to the target
	list<Road> path_to_target;

	// Travelers
	list<Individual> passengers <- [];

	//road graph available for the transport
	graph<Crossroad, Road> available_graph;

	// maximum speed for a transport (km/h)
	float max_speed;

	// transport length (meters)
	float size;

	//passenger capacity 
	int max_passenger;
	bool isMoving <- false;
	bool getIn (Individual i) {
		if (length(passengers) < max_passenger) {
			add item: i to: passengers;
			return true;
		}

		return false;
	}

	action getOut (Individual i) {
		remove item: i from: passengers;
	}

	action start (point start_location, point end_location, date start_time) {
		isMoving <- true;
		path the_path <- path_between(available_graph, start_location, end_location);
		if (the_path = nil) {
			write "PATH NIL //// TELEPORTATION ACTIVEEE !!!!!!";
			do end(start_time);
		} else {
			path_to_target <- list<Road>(the_path.edges);
			do changeRoad(start_time);
		}

	}

	action end (date arrived_time) virtual: true;

	action changeRoad (date signal_time) {
	// Leave the current road
		if isMoving and hasNextRoad() {
			ask getCurrentRoad() {
				do leave(myself, signal_time);
			}

		}

		isMoving <- true;
		remove first(path_to_target) from: path_to_target;

		// Join the next road
		if hasNextRoad() {
			do updatePassengerPosition();
			ask getCurrentRoad() {
				do join(myself, signal_time);
			}

		} else {
			do end(signal_time);
		}

	}

	action updatePassengerPosition {
		loop passenger over: passengers {
			passenger.location <- getCurrentRoad().start_node.location;
		}

	}

	bool hasNextRoad {
		return length(path_to_target) > 1;
	}

	Road getCurrentRoad {
		if length(path_to_target) > 0 {
			return path_to_target[0];
		} else {
			return nil;
		}

	}

	Road getCurrentRoad {
		if length(path_to_target) > 0 {
			return path_to_target[0];
		} else {
			return nil;
		}

	}

	Road getNextRoad {
		if (hasNextRoad()) {
			return path_to_target[1];
		} else {
			return nil;
		}

	}

}

