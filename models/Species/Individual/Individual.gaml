/***
* Name: Individual
* Individuals species. 
* Author: Jean-François Erdelyi
* Tags:
*/

model SwITCh

import "../Network/Building.gaml"
import "Agenda.gaml"

species Individual {
	// The agenda
	Agenda my_agenda <- world.createAgenda();	
	
	// The working place
	Building working_place <- nil;
	
	// The home place
	Building home_place <- nil;
	
	// ****************
	
	aspect default {
		draw circle(5) color: #green;
	}
		
}
