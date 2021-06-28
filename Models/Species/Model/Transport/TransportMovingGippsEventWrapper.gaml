/**
* Name: TransportWrapper
* Transport wrapper for micro usage. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../../Transport/Transport.gaml"

/**
 * Factory
 */
global {

	// Create transport wrapper
	TransportMovingGippsEventWrapper create_transport_moving_gipps_event_wrapper (Transport transport_to_wrap, TransportMovingGippsEventWrapper closest, RoadModel road_model) {
		create TransportMovingGippsEventWrapper returns: values {
			current_road <- road_model;
			wrapped <- transport_to_wrap;
			location <- transport_to_wrap.location;
			desired_speed <- road_model.get_max_freeflow_speed(transport_to_wrap);
			speed <- desired_speed;
			target <- transport_to_wrap.current_trip.current_target;

			float v_temp <- speed + max_acc * reaction_time;
			//float v_temp <- speed + max_acc * time_step;
			float v_safe <- #infinity;
			if closest != nil {
				float sqrt_value <- 0.0;
				// Get speed of the closest agent
				float closest_speed <- closest.speed;
				float closest_distance <- location distance_to closest;
				sqrt_value <- most_sever_break ^ 2 * reaction_time ^ 2 + closest_speed ^ 2 + 2 * most_sever_break * (closest_distance - spacing - (wrapped.size / 2));
				if sqrt_value <= 0 {
					v_safe <- 0.0;
				} else {
					v_safe <- (-most_sever_break * reaction_time) + sqrt(sqrt_value);
				}
			}
			speed <- min(v_temp, desired_speed, v_safe);
		}

		return values[0];
	}
}

/** 
 * Transport moving species
 */
species TransportMovingGippsEventWrapper skills: [moving, scheduling] {
	// The event manager
	agent event_manager <- EventManager[0];
	
	// The road
	RoadModel current_road;

	// The wrapped transport
	Transport wrapped;

	// Internal time step
	float time_step <- step;
	
	// Inner cycle
	int inner_cycle <- 0;
	
	// Car target
	point target;

	// Distance to target
	float distance;

	// Desired speed
	float desired_speed;

	// Max acceleration
	float max_acc <- (1.5 #m / (#s ^ 2));

	// Most sever break
	float most_sever_break <- (1.0 #m / (#s ^ 2));

	// Reaction time
	float reaction_time <- step;

	// Spacing between two cars
	float spacing <- 2.0#m;
	
	// Next car
	agent closest_agent <- nil;
	
	// Sensing zone
	geometry sensing_zone;

	// Reaction drive
	action compute_reaction_drive {
		float v_temp <- speed + max_acc * reaction_time;
		float v_desired <- desired_speed;
		float v_safe <- #infinity;
	
		list<Transport> transports <- wrapped.current_trip.get_current_road_transports() where (each.location overlaps sensing_zone and each != wrapped);
		//list<unknown> res <- wrapped.get_closest_transport(40.0);
	
		// If there is agent 
		float closest_speed <- 0.0;
		float closest_distance <- location distance_to target;
		closest_agent <- transports closest_to location;
		//closest_agent <- res[0];
		if closest_agent = wrapped {
			write "Something wrong, the closest car is itself";
			closest_agent <- nil;
		}
		
		if (closest_agent != nil and not dead(closest_agent)) {
			float sqrt_value <- 0.0;
			// Get speed of the closest agent
			closest_speed <- float(closest_agent get ("speed"));
			closest_distance <- location distance_to closest_agent;

			sqrt_value <- most_sever_break ^ 2 * reaction_time ^ 2 + closest_speed ^ 2 + 2 * most_sever_break * (closest_distance - spacing - (wrapped.size / 2));
			if sqrt_value <= 0 {
				v_safe <- 0.0;	
			} else {
				v_safe <- (-most_sever_break * reaction_time) + sqrt(sqrt_value);
			}	
		}
		
		// Set speed
		speed <- min(v_temp, v_desired, v_safe);
	}

	// Inner move
	action inner_move {
		// Compute reaction
		if inner_cycle mod (reaction_time / time_step) = 0 {
			do compute_reaction_drive;
		}
		
		do goto on: current_road.attached_road target: target speed: speed / (step / time_step);
		wrapped.shape <- wrapped.default_shape rotated_by heading;
		
		/*float cos_a <- cos(heading);
		float sin_a <- sin(heading);
		point rect_pos <- location + (point(cos_a, sin_a) * 20.01);
		sensing_zone <- rectangle(40, 40) at_location rect_pos rotated_by heading;
		inner_cycle <- inner_cycle + 1;*/
	}

	// One step
	action one_step_moving  {
		do inner_move();
		distance <- abs(location distance_to target);
		
	 	if distance < 0.0 {
			location <- target;	
		} else if (distance > 0.0) {
			do later the_action: one_step_moving at: event_date + time_step;									
		}

		// Set position
		ask wrapped {
			do update_positions(myself.location);
		}

		// Change road
		if distance <= 0.0 {
			ask current_road {
				do end_road(myself.wrapped, myself.event_date + myself.time_step);									
			}
			do die;
		}

	}

	// Moving force 
	action moving(date start_time) {
		do later the_action: one_step_moving at: start_time;
	}
	
	aspect {
		//draw sensing_zone empty: true border: #blue;
		//draw line(wrapped.location, sensing_zone.location) empty: true border: #blue;
	}

}