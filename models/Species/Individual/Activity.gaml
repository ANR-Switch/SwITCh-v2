/**
* Name: Activity
* Based on the internal empty template. 
* Author: nvers
* Tags: 
*/


model SwITCh

global{
	list<string> activity_types <- ["shopping","administration","studying","university","familly","healt","leisure","work","other"];
	
	Activity createActivity(date starting_time, int activity_type){
		create Activity returns: children{
			self.starting_time <- starting_time;
			self.activity_type <- activity_type;
		}
		return children[0];
	}
}

species Activity {
	
	date starting_time; 
	
	int activity_type;
	
	string getActivityTypeString{
		return activity_types[activity_type];
	}
	
	int getActivityType{
		return activity_type;
	}
		
}