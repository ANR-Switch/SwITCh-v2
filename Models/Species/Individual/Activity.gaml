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
	Activity create_activity (date activity_start_date, int activity_type) {
		create Activity returns: activities {
			start_date <- activity_start_date;
			type <- activity_type;
		}

		return activities[0];
	}

}

/** 
 * Activity species
 */
species Activity {
	// Starting date
	date start_date;

	// Type
	int type;

	// Get type (string)
	string get_activity_type_string {
		return activity_types[type];
	}

	// Schedule
	action schedule (Individual individual) {
		ask individual {
			switch myself.get_activity_type_string() {
				match "familly" {
					do later the_action: familly at: myself.start_date refer_to: myself;
				}

				match "work" {
					//write (starting_date + time) milliseconds_between myself.start_date;
					do later the_action: work at: myself.start_date refer_to: myself;
				}

			}

		}

	}

}