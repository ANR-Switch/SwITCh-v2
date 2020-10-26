/**
* Name: Agenda
* Based on the internal empty template. 
* Author: nvers
* Tags: 
*/


model SwITCh

import "Activity.gaml"

global{
	Agenda createAgenda{
		create Agenda returns: children{
			
		}
		return children[0];
	}
}

species Agenda {
	list<Activity> agenda <- [];
	
	action addActivity(Activity a){
		add a to: agenda;
	}
}

