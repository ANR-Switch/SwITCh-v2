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
	TransportMovingWrapper create_transport_moving_wrapper (Transport transport_to_wrap, RoadModel road_model) {
		create TransportMovingWrapper returns: values {
			current_road <- road_model;
			wrapped <- transport_to_wrap;
			location <- transport_to_wrap.location;
			desired_speed <- road_model.attached_road.get_max_freeflow_speed(transport_to_wrap);
			speed <- desired_speed / 2.0;
			target <- transport_to_wrap.current_trip.current_target;
		}

		return values[0];
	}

}

/** 
 * Transport moving species
 */
species TransportMovingWrapper skills: [moving] {
	// The road
	RoadModel current_road;

	// The wrapped transport
	Transport wrapped;

	// Internal time step
	float time_step <- min(0.1, step);

	// Number of steps
	float step_count <- step / time_step;

	// Car target (is it depends of "right" variable)
	point target;

	// Distance to target
	float distance;

	// Desired speed
	float desired_speed <- 20.0;

	// Current acceleration
	float acc <- 0.0 #m / (#s ^ 2);

	// Max acceleration
	float max_acc <- (3.0 #m / (#s ^ 2));

	// Most sever break
	float most_sever_break <- (11.0 #m / (#s ^ 2));

	// Reaction time
	float reaction_time <- 1.0;

	// Reactivity
	float reactivity <- 3.0;
	
	// Inner move
	action inner_move {

		// Compute acceleration speed (Linear)
		acc <- (reactivity / reaction_time) * (desired_speed - speed);

		// Limitation
		if (acc > max_acc) {
			acc <- max_acc;
		} else if (acc < -most_sever_break) {
			acc <- -most_sever_break;
		}

		// Set speed
		speed <- speed + (acc * time_step);

		// Move skill
		do goto on: wrapped.network.available_graph target: target speed: speed;
	}

	// Moving
	reflex moving {
		bool exec_loop <- true;
		int nb_loop <- 0;
		loop while: exec_loop {
			// Get distance and direction
			distance <- location distance_to target;
			if distance = 0 {
				exec_loop <- false;
			} else {
				do inner_move();
				nb_loop <- nb_loop + 1;
				exec_loop <- (nb_loop < step_count);
			}

		}
			
		// Set position
		ask wrapped {
			do update_positions(myself.location);
		}

		// Change road
		if distance = 0 {
			ask current_road {
				do later the_action: end_road refer_to: myself.wrapped;
			}
			do die;
		}

	}
}
