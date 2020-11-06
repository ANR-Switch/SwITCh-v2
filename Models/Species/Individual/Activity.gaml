/**
* Name: Activity
* Activity that the individuals can do. Is a part of the Agenda. 
* Author: nvers
* Tags: 
*/
model SwITCh

import "Individual.gaml"

/** 
 * Add to world the list of activity and the action to create a new activity
 */
global {
	// List of activities that the individuals can do
	list<string> activity_types const: true <- ["shopping", "administration", "studying", "university", "familly", "healt", "leisure", "work", "other"];

	// Create a new activity with starting time, type and duration
	Activity create_activity (date act_starting_time, int act_type) {
		create Activity returns: activities {
			starting_time <- act_starting_time;
			activity_type <- act_type;
		}

		return activities[0];
	}

}

/** 
 * Activity species
 */
species Activity {
	// Starting date
	date starting_time;

	// Type
	int activity_type;

	// Get type (string)
	string get_activity_type_string {
		return activity_types[activity_type];
	}

	// Get type
	int get_activity_type {
		return activity_type;
	}

	// Schedule
	action schedule (Individual individual) {
		ask individual {
			switch myself.get_activity_type_string() {
				match "familly" {
					do later the_action: familly at: myself.starting_time refer_to: myself;
				}

				match "work" {
					do later the_action: work at: myself.starting_time refer_to: myself;
				}

			}

		}

	}

}