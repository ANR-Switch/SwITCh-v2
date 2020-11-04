/**
* Name: Individual
* Individuals species. 
* Author: Jean-François Erdelyi
* Tags:
*/
model SwITCh

import "../Transport/Private/Walk.gaml"
import "../Transport/Trip.gaml"
import "../Building.gaml"
import "Agenda.gaml"

/** 
 * Individuals species
 */
species Individual skills: [scheduling] {

// The event manager
	agent event_manager <- EventManager[0];

	// The agenda
	Agenda my_agenda <- world.createAgenda();

	// The chain of trips from start to end location
	queue<Trip> trip_chain;

	// Current Transport
	Transport current_transport <- nil;

	// Current activity
	Activity current_activity <- nil;

	// Current trip
	Trip current_trip <- nil;

	// Current target
	point current_target <- nil;

	// If true, this individual is joining an activity (waiting a bus or in transport for example)
 	bool joining_activity <- false;

	// The working place
	Building working_place <- nil;

	// The home place
	Building home_place <- nil;

	// Age
	int age;

	// His/Her car
	Car car <- nil;

	// Add trip
	action pushTrip (Trip p) {
		push item: p to: trip_chain;
	}

	// Get and remove next trip
	Trip popTrip {
		return pop(trip_chain);
	}

	// Execute one trip of the chain
	action executeTripChain (date start_time) {
		// If this is not the first trip then kil it
		if current_trip != nil {
			ask current_trip {
				do die;
			}

		}

		// If there is another trip
 		if length(trip_chain) > 0 {
			current_trip <- popTrip();
			current_transport <- current_trip.transport;
			ask current_trip {
				do start(myself.location, start_time);
			}

		} else {
			current_transport <- nil;
			joining_activity <- false;
			location <- current_target;
		}

	}

	// Work action
 	action work (Activity activity) {
		if working_place != nil {
			do computeActivity(activity, working_place);
		}

	}

	// Familly action
 	action familly (Activity activity) {
		if home_place != nil {
			do computeActivity(activity, home_place);
		}

	}

	// Compute activity
 	action computeActivity (Activity activity, Building target) {
		if not joining_activity {
			joining_activity <- true;
			current_activity <- activity;
			do computeTransportTrip(target);
			do executeTripChain(event_date);
		}

	}

	// Return true if this individual has a car
	bool hasCar {
		return car != nil;
	}

	// Compute transport trip
 	action computeTransportTrip (Building building) {
		if hasCar() {
			//do pushTrip(world.createTrip(world.createWalk(), self, car.location));
 			//do pushTrip(world.createTrip(car, self, any_location_in(building.shape))); // TODO closest location on the graph
			//do pushTrip(world.createTrip(world.createWalk(), self, any_location_in(building.shape)));
		} else {
		}
		do pushTrip(world.createTrip(world.createWalk(), self, any_location_in(building.shape)));
	}

	// Add activity in agenda
 	action addActivity (Activity activity) {
		ask my_agenda {
			do addActivity activity: activity individual: myself;
		}

	}

	// Get current activity
	string getCurrentActivity {
		if joining_activity {
			return "I'm joining " + current_activity.getActivityTypeString();
		} else {
			return "I'm doing " + current_activity.getActivityTypeString();
		}

	}

	// Default aspect
	aspect default {
		draw circle(3) color: #brown border: #black;
	}

}
