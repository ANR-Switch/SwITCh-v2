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
	TransportMovingGippsWrapper create_transport_moving_gipps_wrapper (Transport transport_to_wrap, TransportMovingGippsWrapper closest, RoadModel road_model) {
		create TransportMovingGippsWrapper returns: values {
			current_road <- road_model;
			wrapped <- transport_to_wrap;
			wrapped.transport_model <- self;
			location <- transport_to_wrap.location;
			desired_speed <- road_model.get_max_freeflow_speed(transport_to_wrap);
			speed <- desired_speed;
			target <- transport_to_wrap.current_trip.current_target;
			if closest != nil {
				closest_agent <- closest;			
			}

			float v_desired <- desired_speed;
			float v_safe <- #infinity;
			
			if (closest != nil and not dead(closest)) {
				float sqrt_value <- 0.0;
				
				// Get speed of the closest agent
				closest_agent <- closest;
				float closest_speed <- float(closest_agent get ("speed"));
				float closest_distance <- (topology(wrapped.network.available_graph) distance_between [wrapped, closest_agent]);
										
				sqrt_value <- ((most_sever_break ^ 2) * (reaction_time ^ 2)) + (closest_speed ^ 2) + ((2 * most_sever_break) * (closest_distance - spacing - (wrapped.size / 2.0)));
				if sqrt_value <= 0 {
					v_safe <- 0.0;	
				} else {
					v_safe <- (-most_sever_break * reaction_time) + sqrt(sqrt_value);
				}
			}
			
			// Set speed
			speed <- min(v_desired, v_safe);
			if speed < 0 {
				speed <- 0.0;
			}
		}

		return values[0];
	}
}

/** 
 * Transport moving species
 */
species TransportMovingGippsWrapper parent: TransportModel skills: [moving] {	
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
	
	// If true, transport is waiting
	bool waiting <- false;
		
	// Sensing zone
	geometry sensing_zone;

	// Reaction drive
	action compute_reaction_drive {
		//float v_temp <- speed + max_acc * reaction_time;
		float v_desired <- desired_speed;
		float v_safe <- #infinity;
		
		list<Transport> transports;
		add last(wrapped.current_trip.get_next_road_transports()) to: transports;
		add (wrapped.current_trip.get_current_road_transports() where (each.location overlaps sensing_zone and each != wrapped)) to: transports all: true;
		Transport closest <- last(transports);
		
		if (closest != nil and not dead(closest)) {
			float sqrt_value <- 0.0;
			
			// Get speed of the closest agent
			closest_agent <- closest;
			float closest_speed <- float(closest.transport_model get ("speed"));
			float closest_distance <- (topology(wrapped.network.available_graph) distance_between [wrapped, closest_agent]);
									
			sqrt_value <- ((most_sever_break ^ 2) * (reaction_time ^ 2)) + (closest_speed ^ 2) + ((2 * most_sever_break) * (closest_distance - spacing - (wrapped.size / 2.0)));
			if sqrt_value <= 0 {
				v_safe <- 0.0;	
			} else {
				v_safe <- (-most_sever_break * reaction_time) + sqrt(sqrt_value);
			}
		}
		
		// Set speed
		speed <- min(v_desired, v_safe);
		if speed < 0 {
			speed <- 0.0;
		}
	}

	// Inner move
	action inner_move {
		// Compute reaction
		do compute_reaction_drive;
		
		float distance_to_target <- (topology(wrapped.network.available_graph) distance_between [wrapped, target]);
		//float distance_to_target <- wrapped distance_to target;
		
		if speed > 0.0 {
			wrapped.remaining_duration <- step - (distance_to_target / speed);
		} else {
			wrapped.remaining_duration <- #infinity;
		}
		
		/*if speed > 0.0 {
			if (distance_to_target / speed) < step {
				write wrapped.name + " " + (distance_to_target / speed);
			}
		}*/
					
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
			//waiting <- true;
			//speed <- 0.0;
			ask current_road {
				do end_road(myself.wrapped, (starting_date + time));
			}
		}

	}

	// Moving force 
	action moving(date start_time) {
		do one_step_moving;
	}
	
	aspect {
		//draw sensing_zone empty: true border: #blue;
		draw line(wrapped.location, sensing_zone.location) empty: true border: #blue;
	}
	
}
