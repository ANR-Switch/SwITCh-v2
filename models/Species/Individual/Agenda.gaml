/**
* Name: Agenda
* The list of activity for individuals. 
* Author: nvers
* Tags: 
*/
model SwITCh

import "Activity.gaml"

/** 
 * Add to world the action to create a new agenda
 */
global {
	// Create a new agenda
	Agenda createAgenda {
		create Agenda returns: children {
		}

		return children[0];
	}

}

/** 
 * Agenda species
 */
species Agenda {
	// The list of activities
	list<Activity> agenda <- [];

	// Add a new activity
	action addActivity (Activity a) {
		add a to: agenda;
	}

}

