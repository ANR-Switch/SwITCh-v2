/**
* Name: Building
* Building species. 
* Author: Jean-François Erdelyi
* Tags: 
*/

model SwITCh

species Building {
	
	// **************** From database
	
	// ID of the building
	int id;
	
	// The building main type. This attribute can be used to give a type to a building, so it can be related to a certain type of activity. [from OSM data]
	string type <- "default";
	
	// ****************

	aspect default {
		draw shape color: #gray;
	}

}
