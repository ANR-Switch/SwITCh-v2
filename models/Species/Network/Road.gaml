/**
* Name: Road
* Virtual road species. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "Crossroad.gaml"
import "../Transport/Transport.gaml"

/** 
 * Road virtual species
 */
species Road virtual: true {
	
	// Type of road (the OpenStreetMap highway feature: https://wiki.openstreetmap.org/wiki/Map_Features)
	string type;

	// Is part of roundabout or not (OSM information)
	string junction;

	// Maximum legal speed on this road
	float max_speed;
	
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
	
	// Number of motorized vehicule lane in this road
	int lanes;

	// Can be used to describe any cycle lanes constructed within the carriageway or cycle tracks running parallel to the carriageway.
	string cycleway;

	// Used to double the roads (to have two distinct roads if this is not a one-way road)
	point trans;

	// Start crossroad node
	Crossroad start_node;

	// End crossroad node
	Crossroad end_node;

	// Maximum space capacity of the road (in meters)
	float max_capacity <- shape.perimeter * lanes min: 15.0;

	// Actual free space capacity of the road (in meters)
	float current_capacity <- max_capacity min: 0.0 max: max_capacity;

	// Virtual join the road
	action join (Transport t, date request_time) virtual: true;

	// Virtual leave the road
	action leave (Transport t, date request_time) virtual: true;
	
	// Init the road
	action init(Crossroad start, Crossroad end) {
		// Set start and end crossroads
		start_node <- start;
		end_node <- end;
		
		// Don't know why some roads have a nil start...
		if (start_node = nil or end_node = nil) {
			//do die;
		}

		point A <- start_node.location;
		point B <- end_node.location;
		if (A = B) {
			trans <- {0, 0};
		} else {
			point u <- {-(B.y - A.y) / (B.x - A.x), 1};
			float angle <- angle_between(A, B, A + u);
			// write sample(int(angle));
			// write sample(norm(u));
			if (angle < 150) {
				trans <- u / norm(u);
			} else {
				trans <- -u / norm(u);
			}

		}
}

	// Get size
	float getSize {
		return shape.perimeter;
	}

	// Get free flow travel time (time to cross the road when the speed of the transport is equals to the maximum speed)
	date getFreeFlowTravelTime (Transport t) {
		float max_freeflow_speed <- min([t.max_speed, max_speed]) #km / #h;
		return date("now") + (getSize() / max_freeflow_speed);
	}

	// True if this road has capacity
	bool hasCapacity (float capacity) {
		return current_capacity > capacity;
	}

	// Default aspect
	aspect default {
		geometry geom_display <- (shape + lanes);
		draw geom_display translated_by (trans * 2) border: #gray color: rgb(255 * (max_capacity - current_capacity) / max_capacity, 0, 0);
	}

}
