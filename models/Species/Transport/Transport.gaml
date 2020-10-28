/**
* Name: Transport
* Based on the internal empty template. 
* Author: Lo�c
* Tags: 
*/
model SWITCH

import "../Network/Road.gaml"
species Transport virtual: true {

	//list of roads that lead to the target
	list<Road> path_to_target;

	// maximum speed for a transport (km/h)
	float max_speed;

	// transport length (meters)
	float size;

	//passenger capacity 
	int max_passenger;

	action start (point target_pos) virtual: true;

	action end (date arrived_time) virtual: true;

	action changeRoad (date signal_time) {
		// Leave the current road
		if hasNextRoad() {
			ask getCurrentRoad() {
				do leave(myself, signal_time);
			}

		}

		remove first(path_to_target) from: path_to_target;

		// Join the next road
		if hasNextRoad() {
			ask getCurrentRoad() {
				do join(myself, signal_time);
			}

		} else {
			do end(signal_time);
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

}

