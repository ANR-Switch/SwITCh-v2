/**
* Name: Road
* Virtual road species. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../IRoad.gaml"
import "../Model/RoadModel/RoadModel.gaml"
import "../Model/RoadModel/SimpleModel/SimpleRoadModel.gaml"
import "../Model/RoadModel/SimpleModel/MicroRoadModel.gaml"
import "../Model/RoadModel/QueuedModel/SimpleQueuedRoadModel.gaml"
import "../Model/RoadModel/QueuedModel/MicroQueuedRoadModel.gaml"
import "../Network/Road.gaml"
import "../Network/Crossroad.gaml"

/**
 * Get end point of the current segment (for the given agent)
 */
global {
 	// Get end point of the current segment (for the given agent)
	point get_end_point_road_segment(agent the_agent, Road the_road) {
		point segment_end_point <- nil;
		bool exec_loop <- true;
		int i <- 0;
		
		loop while: exec_loop {
			point p1 <- the_road.shape.points[i];
			segment_end_point <- the_road.shape.points[i + 1];
			
			if rectangle(p1, segment_end_point) overlaps the_agent.location {
				exec_loop <- false;
			}
			
			i <- i + 1;
			if i >= length(the_road.shape.points) - 1 {
				exec_loop <- false;
			}
		}

		return segment_end_point;
	}
}

/** 
 * Road virtual species
 */
species Road parent: IRoad {

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

	// Model type
	string model_type <- "simple" among: ["simple", "micro", "queued-simple", "queued-micro"];

	// Border color
	rgb border_color <- #grey;

	// The model
	RoadModel road_model;

	// Start crossroad node
	Crossroad start_node;

	// End crossroad node
	Crossroad end_node;

	// Maximum space capacity of the road (in meters)
	float max_capacity <- shape.perimeter * lanes min: 15.0;

	// Actual free space capacity of the road (in meters)
	float current_capacity <- max_capacity min: 0.0 max: max_capacity;

	// Init the road
	init {
		//location <- location with_precision 4;
		//shape.points[0] <- first(self.shape.points) with_precision 4;
		//shape.points[length(shape.points) - 1] <- last(self.shape.points) with_precision 4;

		// Set start and end crossroad
		start_node <- Crossroad closest_to first(self.shape.points);
		end_node <- Crossroad closest_to last(self.shape.points);
		
		// TODO *********** 
		/*switch model_type {
			match "simple" {
				road_model <- world.create_simple_road_model(self);
			}
			match "micro" {
				road_model <- world.create_micro_road_model(self);
			}
			match "queued-simple" {
				road_model <- world.create_simple_queue_road_model(self);
			}
			match "queued-micro" {
				road_model <- world.create_micro_queue_road_model(self);
			}
		}
		*/
		switch type {
			match "residential" {
				road_model <- world.create_micro_queue_road_model(self);
				//road_model <- world.create_micro_road_model(self);
				//road_model <- world.create_simple_road_model(self);
				//road_model <- world.create_simple_queue_road_model(self);				
			}

			default {
				road_model <- world.create_micro_queue_road_model(self);
				//road_model <- world.create_micro_road_model(self);
				//road_model <- world.create_simple_road_model(self);
				//road_model <- world.create_simple_queue_road_model(self);
			}

		}
		//road_model <- world.create_simple_road_model(self);
		// ***********

		// Set border color
		border_color <- road_model.color;

		// Get translations (in order to draw two roads if there is two directions)
		point A <- start_node.location;
		point B <- end_node.location;
		
	
		if (A = B) {
			trans <- {0, 0};
		} else {
			point u <- {-(B.y - A.y) / (B.x - A.x), 1};
			float angle <- angle_between(A, B, A + u);
			if (angle < 150) {
				trans <- u / norm(u);
			} else {
				trans <- -u / norm(u);
			}

		}

	}

	// Implement join the road
	action join (Transport transport, date request_time) {
		ask road_model {
			do join(transport, request_time);
		}

	}

	// Implement leave the road
	action leave (Transport transport, date request_time) {
		ask road_model {
			do leave(transport, request_time);
		}

	}

	// Implement true if this road has capacity
	bool has_capacity (Transport transport) {
		return road_model.has_capacity(transport);
	}
	
	// Implement true if this road has capacity
	bool check_if_exists (Transport transport) {
		return road_model.check_if_exists(transport);
	}

	// Implement get size
	float get_size {
		return shape.perimeter;
	}

	// Implement get max freeflow speed
	float get_max_freeflow_speed (Transport transport) {
		return min([transport.max_speed, max_speed]) #km / #h;
	}

	// Implement get free flow travel time in secondes (time to cross the road when the speed of the transport is equals to the maximum speed)
	float get_free_flow_travel_time (Transport transport) {
		return get_size() / get_max_freeflow_speed(transport);
	}

	// Default aspect
	aspect default {
		geometry geom_display <- (shape + lanes);
		draw geom_display translated_by (trans * 2) border: border_color color: rgb(255 * ((max_capacity - current_capacity) / max_capacity), 0, 0);
	}

}
