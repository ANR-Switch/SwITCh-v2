/**
* Name: Activity
* Based on the internal empty template. 
* Author: nvers
* Tags: 
*/


model Activity

global{
	list<string> activity_types <- ["shopping","administration","studying","university","familly","healt","leisure","work","other"];
	
	Activity createActivity(date starting_time, int activity_type, point end_location){
		create Activity returns: children{
			self.starting_time <- starting_time;
			self.end_location <- end_location;
			self.activity_type <- activity_type;
		}
		return children[0];
	}
}

species Activity {
	
	date starting_time; 
	
	int activity_type;
	
	point end_location;
	
	string getActivityTypeString{
		return activity_types[activity_type];
	}
	
	int getActivityType{
		return activity_type;
	}
		
}