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
	
	// If true can use car
	bool has_car <- false;
	
	// If true can use bike
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

	// If true this individual activity is init (graph connexion)
	bool initialized_joining_activity <- false;

	/**
	 * Activity data
	 */
	 
	// Current activity
	Activity current_activity <- nil;
	
	// Current trip
	Trip current_trip <- nil;
	
	// Current transport
	Transport current_transport <- nil;
	
	// Current target (of the current trip)
	point current_target <- nil;

	/**
	 * Trip queue actions
	 */
	 
	// Add trip
	action push_trip (Trip trip) {
		push item: trip to: trip_chain;
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
	 
 	// Create transport trip TODO distance is arbitrary, we must define a better strategy
	action compute_trip_chain (Building target_building) {
		point target <- any_location_in(target_building.shape);
		float distance <- location distance_to target; // TODO must be distance in the graph 
		Transport transport <- nil;
				
		if not has_car and not has_bike {
			transport <- world.create_walk();
		} else if has_car and not has_bike {
			if distance > 0.5#km {
				transport <- world.create_car();
			} else {
				transport <- world.create_walk();
			}
			
		} else if not has_car and has_bike {
			if distance > 0.5#km {
				transport <- world.create_bike();
			} else {
				transport <- world.create_walk();
			}
		} else if has_car and  has_bike {
			if distance > 1.0#km {
				transport <- world.create_car();
			} else if distance > 0.5#km {
				transport <- world.create_bike();
			} else {
				transport <- world.create_walk();
			}
		}
		
		do push_trip(world.create_trip(transport, self, target));
	}
	
	// Execute one trip of the chain
	action execute_trip_chain (date start_time) {
		// If this is not the first trip then kill it
		if current_trip != nil {
			ask current_trip {
				do die;
			}

		}

		// Check if there is another trip 
		if has_trip() {
			// If initialized then normal behavior
			if initialized_joining_activity {
				do start_trip(start_time);
			} else {
				// Pre compute and get entry location
				ask first_trip() {
					myself.current_target <- pre_compute(myself.location);
				}

				// If the trip entry point is nil it's not normal behavior.
				if current_target = nil {
					// Something wrong: impossible to enter into the graph 
					// Execute the trip as usual
					do start_trip(start_time);
				} else {
					// Set init false;	
					initialized_joining_activity <- true;

					// Entry network					
					date entry_date <- compute_walk_straight_forward_access_time(start_time, current_target);
					do later the_action: entry_network at: entry_date;
				}

			}

		} else {
			// Exit network
			date exit_date <- compute_walk_straight_forward_access_time(start_time, current_target);
			do later the_action: exit_network at: exit_date;
		}

	}
	
	// Start trip
	action start_trip (date start_time) {
		current_trip <- pop_trip();
		current_transport <- current_trip.transport;
		ask current_trip {
			do start(myself.location, start_time);
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
 	action compute_activity (Activity activity, Building target, date start_date) {
		// Set current activity
		current_activity <- activity;

		// Reset joining and init to false
		initialized_joining_activity <- false;
	
		// Compute and execute trip chain
		do compute_trip_chain(target);
		do execute_trip_chain(start_date);
	}

	/**
	 * Entry and exit network actions (scheduling)
	 */
	 
	// Compute entry/exit time
	action compute_walk_straight_forward_access_time(date start_time, point target) {
		// Create walk transport
	 	current_transport <- world.create_walk();
	 	
	 	// Convert max speed in km/h to m/s
		float mPerS <- current_transport.max_speed / 3.6; // km/h to m/s
		
		// Set visible and location
		ask current_transport {
			is_visible <- true;
			location <- myself.location;
		}
		
		// Access time straight forward
		return start_time + ((location distance_to target) / mPerS); 
	}
	 
	// Entry network
	action entry_network {
		// End entry transport
		ask current_transport {
			do end(event_date);
		}
		
		// Set all trips data to nil
		current_trip <- nil;
		
		// Set location to last target location
		current_target <- nil;
				
		// Execute the trip chain
		do execute_trip_chain(event_date);
	}
	
	// Exit network
	action exit_network {
		// End exit transport
		ask current_transport {
			do end(event_date);
		}
			
		// Set all trips data to nil
		current_trip <- nil;
		
		// Reset joining and init to false
		initialized_joining_activity <- false;
		
		// Set location to last target location
		location <- current_target;
		current_target <- nil;
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
	 * Aspects
	 */
	 
	// Default aspect
	aspect default {
		draw circle(3) color: #brown border: #black;
	}

}
