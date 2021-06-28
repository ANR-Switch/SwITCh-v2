/**
* Name: TransportWrapper
* Transport wrapper for micro usage. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "TransportModel.gaml"
import "../../Transport/Transport.gaml"

/**
 * Factory
 */
global {

	// Create transport wrapper
	TransportMovingIdmWrapper create_transport_moving_idm_wrapper (Transport transport_to_wrap, RoadModel road_model) {
		create TransportMovingIdmWrapper returns: values {
			current_road <- road_model;
			wrapped <- transport_to_wrap;
			wrapped.transport_model <- self;
			location <- transport_to_wrap.location;
			desired_speed <- road_model.get_max_freeflow_speed(transport_to_wrap);
			speed <- desired_speed;
			target <- transport_to_wrap.current_trip.current_target;
			do compute_drive();
		}

		return values[0];
	}
}

/** 
 * Transport moving species
 */
species TransportMovingIdmWrapper parent: TransportModel skills: [moving] {	
	// The road
	RoadModel current_road;

	// The wrapped transport
	Transport wrapped;
	
	// Car target
	point target;

	// Distance to target
	float distance;

	// Desired speed
	float desired_speed;

	// Acceleration	
	float acc;

	// Max acceleration
	float max_acc <- (4.0 #m / (#s ^ 2));

	// Most sever break
	float most_sever_break <- (3.0 #m / (#s ^ 2));

	// Reaction time
	float reaction_time <- 1.1#s;

	// Spacing between two cars
	float spacing <- 2.0#m;
	
	// Delta param
	float delta <- 4.0;

	// Next car
	agent closest_agent <- nil;
	
	// If true, transport is waiting
	bool waiting <- false;
		
	// Sensing zone
	geometry sensing_zone;

	// Reaction drive
	action compute_drive {
		// Add transports
		list<Transport> transports;
		add (wrapped.current_trip.get_next_road_transports() where (each.location overlaps sensing_zone and each != wrapped)) to: transports all: true;
		add (wrapped.current_trip.get_current_road_transports() where (each.location overlaps sensing_zone and each != wrapped)) to: transports all: true;
		float delta_speed <- 0.0;
		float actual_gap <- 0.0;
		
		// Get closest
		closest_agent <- last(transports);
		bool is_leader <- closest_agent = nil or dead(closest_agent);
		if (not is_leader) {
			delta_speed <- float(closest_agent get ("speed")) - speed;
			actual_gap <- (topology(wrapped.network.available_graph) distance_between [wrapped, closest_agent]) + (wrapped.size * 2);
		} else {
			/*float distance_to_crossroad <- (topology(wrapped.network.available_graph) distance_between [wrapped, wrapped.current_trip.current_road.start_node]);
			if distance_to_crossroad > 40.0 and not wrapped.current_trip.current_road.end_node.is_available() {
				delta_speed <- -speed;
				actual_gap <- distance_to_crossroad + (wrapped.size * 2);
			}*/
		}
		float desired_minimum_gap <- spacing + reaction_time * speed - ((speed * delta_speed) / (2 * sqrt(max_acc * most_sever_break)));
		
		if (is_leader) {	
			acc <- max_acc * (1 - ((speed / desired_speed) ^ delta));
		} else {
			acc <- max_acc * (1 - ((speed / desired_speed) ^ delta) - (desired_minimum_gap / actual_gap));
		}
		speed <- speed + acc * reaction_time;
	}

	// Inner move
	action inner_move {
		// Compute drive
		do compute_drive;
		
		float distance_to_target <- (topology(wrapped.network.available_graph) distance_between [wrapped, target]);
		
		if speed > 0.0 {
			wrapped.remaining_duration <- step - (distance_to_target / speed);
		} else {
			wrapped.remaining_duration <- #infinity;
		}
	
		do goto on: current_road.attached_road target: target speed: speed;
		wrapped.shape <- wrapped.default_shape rotated_by heading;	
		
		float cos_a <- cos(heading);
		float sin_a <- sin(heading);
		point rect_pos <- location + (point(cos_a, sin_a) * 20.01);
		sensing_zone <- rectangle(40, 40) at_location rect_pos rotated_by heading;
	}
	
	// Reflex
	reflex one_step when: not waiting {
		do one_step_moving;
	}

	// One step
	action one_step_moving  {
		do inner_move();
		distance <- abs(location distance_to target);
		
	 	if distance < 0.0 {
			location <- target;
		}

		// Set position
		ask wrapped {
			do update_positions(myself.location);
		}

		// Change road
		if distance <= 0.0 {
			ask current_road {
				do end_road(myself.wrapped, (starting_date + time));
			}
			waiting <- true;
			speed <- 0.0;
		}

	}

	// Moving force 
	action moving(date start_time) {
		do one_step_moving;
	}
	
	aspect {
		//draw sensing_zone empty: true border: #blue;
		//draw line(wrapped.location, sensing_zone.location) empty: true border: #blue;
	}
	
}
