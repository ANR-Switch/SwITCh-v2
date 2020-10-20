/***
* Name: Individual
* Individuals species. 
* Author: Jean-François Erdelyi
* Tags:
*/

model SwITCh

import "Building.gaml"

species Individual {
	// **************** From database

	// The working place
	Building working_place <- nil;
	
	// The home place
	Building home_place <- nil;
	
	// ****************
	
	aspect default {
		draw circle(5) color: #green;
	}
		
}
