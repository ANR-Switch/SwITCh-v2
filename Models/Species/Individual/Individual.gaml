/**
* Name: Individual
* Individuals species. 
* Author: Jean-François Erdelyi
* Tags:
*/
model SwITCh

import "../Transport/Private/Walk.gaml"
import "../Transport/Private/Car.gaml"
import "../Transport/Private/Bike.gaml"
import "../Transport/Trip.gaml"
import "../Building.gaml"
import "Agenda.gaml"

/** 
 * Individuals species
 */
species Individual skills: [scheduling] {

	/**
	 * Personnal data
	 */

	// Age
	int age;

	// If true, can instantiate a car
	bool has_car <- false;

	// If true, can instantiate a bike
	bool has_bike <- false;

	// The agenda
	Agenda my_agenda <- world.create_agenda();

	// The working place
	Building working_place <- nil;

	// The home place
	Building home_place <- nil;
	
	/**
	 * Computation data
	 */

	// The event manager
	agent event_manager <- EventManager[0];

	// The chain of trips from start to end location
	queue<Trip> trip_chain;
	
	/**
	 * Activity data
	 */

	// Current activity
	Activity current_activity <- nil;

	// Current trip
	Trip current_trip <- nil;

	/**
	 * Trip queue wrapper actions
	 */

	// Add trip
	action push_trip (Trip first_trip) {
		push item: first_trip to: trip_chain;
	}

	// Get and remove next trip
	Trip pop_trip {
		return pop(trip_chain);
	}

	// Get and remove next trip
	Trip first_trip {
		return first(trip_chain);
	}

	// True if there is trips
	bool has_trip {
		return length(trip_chain) > 0;
	}

	/**
	 * Trip actions
	 */

	// Init trip chain
	action push_init_trip (Trip first_trip) {
		point pre_compute_target <- nil;
		
		// Pre compute and get entry location
		ask first_trip {
			pre_compute_target <- pre_compute(myself.location);
		}

		// If the trip entry point is nil it's not normal behavior.
		if pre_compute_target = nil {
			// Draw error and nothing more
			write "---------------------------------------------------";
			write "Impossible to enter into the graph, no entry point";
			write "Individual: " + self;
			write "Trip: " + first_trip;
			write "---------------------------------------------------";
		} else {
			// Entry network
			do push_trip(world.create_connexion_trip(self, pre_compute_target));
		}

	}
	
	// End trip chain
	action push_end_trip (point target) {
		do push_trip(world.create_connexion_trip(self, target));
	}

	// Clear trip
	action kill_trip {
		if current_trip != nil {
			ask current_trip {
				do die;
			}
		}
	}

	// Create transport trip 
	// TODO distance is arbitrary, we must define a better strategy -> a model of decision making
	action compute_trip_chain (Building target_building) {
		// #################################
		Transport transport <- nil;
		point target <- any_location_in(target_building.shape);
		
		/*
		float distance <- location distance_to target;
		if false {
			if not has_car and not has_bike {
				transport <- world.create_walk();
			} else if has_car and not has_bike {
				if distance > 5.0 #km {
					transport <- world.create_car();
				} else {
					transport <- world.create_walk();
				}
			} else if not has_car and has_bike {
				if distance > 5.0 #km {
					transport <- world.create_bike();
				} else {
					transport <- world.create_walk();
				}
			} else if has_car and has_bike {
				if distance > 5.0 #km {
					transport <- world.create_car();
				} else if distance > 0.5 #km {
					transport <- world.create_bike();
				} else {
					transport <- world.create_walk();
				}
			}
		}*/
		// #################################

		// Create and add first (and the only one) trip
		transport <- world.create_car();
		Trip first_trip <- world.create_trip(transport, self, target);
		do push_init_trip(first_trip);
		do push_trip(first_trip);
		do push_end_trip(target);
	}

	// Execute one trip of the chain
	action execute_trip_chain (date start_time) {

		// Check if there is another trip
		if has_trip() {
			// Clean previous trip
			do kill_trip;
			
			// Execute next trip
			current_trip <- pop_trip();
			
			// Start the current trip
			ask current_trip {
				do start(myself.location, start_time);
			}
		} else {
			// Set location and reset current target
			location <- current_trip.target;
	
			// Clean last trip
			do kill_trip;
		}
	}

	/**
	 * Activity actions
	 */

	// Add activity in agenda
	action add_activity (Activity activity) {
		ask my_agenda {
			do add_activity activity: activity individual: myself;
		}

	}

	// Compute activity
	action compute_activity (Activity activity, Building target, date start_time) {
		// Set current activity
		current_activity <- activity;

		// Compute and execute first trip
		do compute_trip_chain(target);
		do execute_trip_chain(start_time);
	}	

	/**
	 * Activity behaviors (scheduling)
	 */

	// Work action
	action work {
		// Check if the individual is not already in the building
		if working_place != nil and not (working_place.shape overlaps location) {
			do compute_activity(refer_to as Activity, working_place, event_date);
		}

	}

	// Familly action
	action familly {
		// Check if the individual is not already in the building
		if home_place != nil and not (home_place.shape overlaps location) {
			do compute_activity(refer_to as Activity, home_place, event_date);
		}

	}
	
	/**
	 * Unitilities
	 */
	 
	// Get current target
	point get_target {
		// Get target of the current trip
		if current_trip != nil {
			return current_trip.target;		
		}
		return nil;
	}

	/**
	 * Aspects
	 */

	// Default aspect
	aspect default {
		draw circle(3) color: #brown border: #black;
	} 
}
