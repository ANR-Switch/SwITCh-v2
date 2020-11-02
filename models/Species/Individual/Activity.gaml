/**
* Name: Activity
* Activity that the individuals can do. Is a part of the Agenda. 
* Author: nvers
* Tags: 
*/
model SwITCh

/** 
 * Add to world the list of activity and the action to create a new activity
 */
global {
	// List of activities that the individuals can do
	list<string> activity_types const: true <- ["shopping", "administration", "studying", "university", "familly", "healt", "leisure", "work", "other"];

	// Create a new activity with starting time, type and duration
 	Activity createActivity (date starting_time, int activity_type, float activity_duration) {
		create Activity returns: children {
			self.starting_time <- starting_time;
			self.activity_type <- activity_type;
			self.activity_duration <- activity_duration;
		}

		return children[0];
	}

}

/** 
 * Activity species
 */
species Activity {
	// Starting date
	date starting_time;
	
	// Duration
	float activity_duration;
	
	// Type
	int activity_type;
	
	// Get type (string)
	string getActivityTypeString {
		return activity_types[activity_type];
	}

	// Get type
	int getActivityType {
		return activity_type;
	}

}