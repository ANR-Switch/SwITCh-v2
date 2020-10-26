/**
* Name: Road
* Road species. 
* Author: Jean-François Erdelyi
* Tags: 
*/

model SwITCh

species Road {

	// **************** From database

	// Type of road (the OpenStreetMap highway feature: https://wiki.openstreetmap.org/wiki/Map_Features)
	string type;

	// Is part of roundabout or not (OSM information)
	string junction;

	// Maximum legal speed on this road
	float max_speed;

	// Number of motorized vehicule lane in this road
	int nb_lanes <- 1;

	// Is the road is oneway or not
	string oneway;

	// If "foot = no" means pedestrians are not allowed
	string foot;

	// If "bicycle = no" means bikes are not allowed
	string bicycle;

	// If "access = no" means car are not allowed
	string access;

	// If "access = no" together with "bus = yes" means only buses are allowed 
	string bus;

	// Describe if there is parking lane
	string parking_lane;

	// Is used to give information about footways
	string sidewalk;

	// Can be used to describe any cycle lanes constructed within the carriageway or cycle tracks running parallel to the carriageway.
	string cycleway;
	
	// ****************

	aspect default {
		draw shape color: #darkgray;
	}
	
}
