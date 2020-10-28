/**
* Name: Road
* Road species. 
* Author: Jean-François Erdelyi
* Tags: 
*/

model SwITCh

import "Crossroad.gaml"

import "../Transport/Transport.gaml"


species Road virtual:true{
	
	//start crossroad node
	Crossroad start_node;

	//end crossroad node
	Crossroad end_node;

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
	
	//maximum space capacity of the road (in meters)
	float max_capacity <- shape.perimeter * nb_lanes min: 15.0;

	//actual free space capacity of the road (in meters)
	float current_capacity <- max_capacity min: 0.0 max: max_capacity;
	
	action join(Transport t, date request_time) virtual:true;
	
	action leave(Transport t, date request_time) virtual:true;
	
	float getSize{
		return shape.perimeter;
	}
	
	date getFreeFlowTravelTime(Transport t){
			float max_freeflow_speed <- min([t.max_speed, max_speed]) #km / #h;
			return date("now") + (getSize() / max_freeflow_speed);
	}
	
	bool hasCapacity (float capacity) {
		return current_capacity > capacity;
	}

	aspect default {
		geometry geom_display <- (shape + (2.0));	
	}
	
}
