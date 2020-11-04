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
	Agenda createAgenda {
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
	list<Activity> agenda <- [];
	
	// Add a new activity and schedule it
	action addActivity (Activity activity, Individual individual) {
		add activity to: agenda;
		ask activity {
			do schedule individual: individual;
		}

	}

}

