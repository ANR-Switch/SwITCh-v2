/**
* Name: Agenda
* The list of activity for individuals. 
* Author: nvers
* Tags: 
*/
model SwITCh

import "Individual.gaml"
import "Activity.gaml"

/** 
 * Add to world the action to create a new agenda
 */
global {
	// Create a new agenda
	Agenda create_agenda {
		create Agenda returns: agendas {
		}

		return agendas[0];
	}

}

/** 
 * Agenda species
 */
species Agenda {
	// The list of activities
	queue<Activity> agenda <- [];
	
	// Add a new activity and schedule it
	action add_activity (Activity activity) {
		push item: activity to: agenda;
	}
	
	// Pop and schedule activity
	action pop_activity(Individual individual) {
		if length(agenda) != 0 {	
			Activity a <- pop(agenda);
			ask a {
				do schedule individual: individual;
			}
			
		}
		
	}

}

