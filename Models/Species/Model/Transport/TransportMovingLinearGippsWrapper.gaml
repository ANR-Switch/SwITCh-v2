/**
* Name: TransportWrapper
* Transport wrapper for micro usage. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../../Transport/Transport.gaml"

/**
 * Add dot product speed to world
 */
global {

	// Create transport wrapper
	TransportMovingLinearGippsWrapper create_transport_moving_linear_gipps_wrapper (Transport transport_to_wrap, agent next, RoadModel road_model) {
		create TransportMovingLinearGippsWrapper returns: values {
			current_road <- road_model;
			wrapped <- transport_to_wrap;
			location <- transport_to_wrap.location;
			desired_speed <- road_model.attached_road.get_max_freeflow_speed(transport_to_wrap);
			target <- transport_to_wrap.current_trip.current_target;
			closest_agent <- next;
			speed <- 0.0;
		}

		return values[0];
	}
}

/** 
 * Transport moving species
 */
species TransportMovingLinearGippsWrapper skills: [moving] {
	// The road
	RoadModel current_road;

	// The wrapped transport
	Transport wrapped;

	// Internal time step
	float time_step <- min(0.1, step) #second;

	// Number of steps
	float step_count_max <- step / time_step;

	// Car target
	point target;

	// Distance to target
	float distance;

	// Desired speed
	float desired_speed;

	// Current acceleration
	float acc <- 0.0 #m / (#s ^ 2);

	// Max acceleration
	float max_acc <- (1.5 #m / (#s ^ 2));

	// Most sever break
	float most_sever_break <- (1.0 #m / (#s ^ 2));

	// Reaction time
	float reaction_time <- 1.1;

	// Spacing between two cars
	float spacing <- 2.0#m;
	
	// Next car
	agent closest_agent <- nil;
	
	// Sensing zone
	geometry sensing_zone;

	// Reaction drive
	action compute_reaction_drive {		
		float v_temp <- speed + max_acc * time_step;
		float v_desired <- desired_speed;
		float v_safe <- #infinity;	
	
		list<Transport> transports <- wrapped.get_trip_transports() where (each.location overlaps sensing_zone);
	
		// If there is agent 
		float closest_speed <- 0.0;
		float closest_distance <- location distance_to target;
		closest_agent <- transports closest_to wrapped;
		if (closest_agent != nil) {
			// Get speed of the closest agent
			closest_speed <- float(closest_agent get ("speed"));
			closest_distance <- location distance_to closest_agent;
		}
		float sqrt_value <- most_sever_break ^ 2 * reaction_time ^ 2 + closest_speed ^ 2 + 2 * most_sever_break * (closest_distance - spacing);

		if sqrt_value < 0 {
			v_safe <- 0.0;	
		} else {
			v_safe <- (-most_sever_break * reaction_time) + sqrt(sqrt_value);
		}
		acc <- (min(v_temp, v_desired, v_safe) - speed);

		// Limitation
		if (acc > max_acc) {
			acc <- max_acc;
		} else if (acc < -most_sever_break) {
			acc <- -most_sever_break;
		}

		// Set speed
		speed <- speed + acc;
	}

	// Inner move
	action inner_move {
		float cos_a <- cos(heading);
		float sin_a <- sin(heading);
		point rect_pos <- wrapped.location + (point(cos_a, sin_a) * 20.5);
		sensing_zone <- rectangle(40, 20) at_location rect_pos rotated_by heading;
		
		// Compute reaction
		if cycle mod (reaction_time / step) = 0 {
			do compute_reaction_drive;
		}
		do goto on: current_road.attached_road target: target speed: speed;
	}

	// One step
	action one_step_moving (float nb_step, date request_date) {
		bool exec_loop <- true;
		int nb_loop <- 0;
		loop while: exec_loop {
			// Get distance and direction
			distance <- location distance_to target;
			if distance <= 0 {
				exec_loop <- false;
			} else {
				do inner_move();
				nb_loop <- nb_loop + 1;
				exec_loop <- (nb_loop < nb_step);
			}

		}

		// Set position
		ask wrapped {
			do update_positions(myself.location);
		}

		// Change road
		if (distance with_precision 2) <= (spacing) {
			ask current_road {
				do later the_action: end_road at: request_date + (myself.time_step * nb_loop) refer_to: myself.wrapped;
			}

			do die;
		}

	}

	// Moving force 
	action moving (float delta_cycle, date request_date) {
		do one_step_moving(step_count_max * delta_cycle, request_date);
	}

	// Moving relfex
	reflex moving_cyclic {
		do one_step_moving(step_count_max, (starting_date + time));
	}
	
	aspect {
		draw sensing_zone empty: true border: #blue;
	}

}
