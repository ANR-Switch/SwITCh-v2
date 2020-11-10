/**
* Name: TransportWrapper
* Transport wrapper for micro usage. 
* Author: Jean-François Erdelyi
* Tags: 
*/
model SwITCh

import "../../../../Transport/Transport.gaml"

/**
 * Add dot product speed to world
 */
global {
	
	// Create tranport wrapper
	TransportWrapper create_wrapper(Transport transport) {
		create TransportWrapper returns: transports {
			wrapped <- transport;
		}

		return transports[0];
	}
	
	// Get speed component from another (moving) agent
	float get_dot_product_speed(agent a, point direction) {
		
		// Get data
		point closest_target <- a get("destination");
		float closest_speed_norm <- float(a get("speed"));
		
		// Compute
		float res <- 0.0;
		if(closest_target != nil and closest_speed_norm != nil and a.location != closest_target) {
			float closest_distance <- a.location distance_to closest_target;
			point closest_direction <- {(closest_target.x - a.location.x) / closest_distance, (closest_target.y - a.location.y) / closest_distance};
			
			res <- (direction * closest_direction) * closest_speed_norm;
		}
		
		return res;
	}
	
	// Get angle
	float get_angle(point v1, point v2) {
		return atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
	}
}

/** 
 * Transport wrapper species
 */
species TransportWrapper skills: [moving] {

	// The wrapped transport
	Transport wrapped;
	
	// Guest agents
	list<agent> guest <- nil;
	
	// Reference of the followed car
	agent next_moving_agent <- nil;
	
	// Internal time step
	float time_step <- min(0.1, step);
	
	// Number of steps
	float step_count <- step / time_step;

	// Effect zone (following behavior)
	geometry sensing_zone;

	// Car target (is it depends of "right" variable)
	point target;
	
	// View 
	float view <- 10.0;

	// Size
	float size;

	// Distance to target
	float distance;
	
	// Direction of the target
	point direction;
	
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
	
	// Spacing between two transport
	float spacing <- 2 * size #m;

	// Add new guest
	action add_guest(TransportWrapper transport) {
		if(transport != nil and !dead(transport) and transport is_skill "moving") {
			add transport to: guest;
		}
	}
	
	// Add list of guests
	action add_guests(list<TransportWrapper> transports) {
		loop transport over: transports {
			do add_guest(transport);
		}
	}
	
	// Remove guest
	action remove_guest(TransportWrapper transport) {
		remove transport from: guest;
	}
	
	// Inner drive
	action inner_drive {
		direction <- {(target.x - location.x) / distance, (target.y - location.y) / distance};
		
		// Get all detected agents
		list<agent> all_agents <- (guest
			where (a: a != nil 						// Not nil
				and !dead(a) 						// Not dead
				and a != self						// Not itself
				and a.shape overlaps sensing_zone 	// Overlap the effect_zone
			)
		);
		
		// Get closest agent in all detected agents
		agent closest_agent <- nil;
		loop current_agent over: all_agents {
			if(closest_agent = nil or current_agent.location distance_to location < closest_agent.location distance_to location) {
				closest_agent <- current_agent;
			} 
		}		
		
		// If there is no closest agent then there is no agent to follow
		float next_moving_agent_speed;
		if(closest_agent != nil) {
			// Get speed of the closest agent
			float closest_speed <- world.get_dot_product_speed(closest_agent, direction);
			if(closest_speed > desired_speed) {
				next_moving_agent <- nil;
			} else {
				next_moving_agent <- closest_agent;
				next_moving_agent_speed <- closest_speed;
			}
		} else {
			next_moving_agent <- nil;
		}
	
		// If there is something to follow
		if (next_moving_agent != nil and not dead(next_moving_agent) ) {
			// Compute acceleration speed (Linear)
			acc <- (reactivity / reaction_time) * (next_moving_agent_speed - speed);
		} else {
			// Compute acceleration speed (Linear)
			acc <- (reactivity / reaction_time) * (desired_speed - speed);
		}
		
		// Limitation
		if(acc > max_acc) {
			acc <- max_acc;
		} else if(acc < -most_sever_break) {
			acc <- -most_sever_break;
		} 
		
		// Set speed
		speed <- speed + (acc * time_step);
		
		// Move skill
		do goto on: wrapped.available_graph target: target speed: speed;
				
		// Change "effect zone" with new location and speed
		float angle <- world.get_angle({1.0, 0.0}, direction);
		float radius <- (speed / desired_speed) * (view * 2.0) + spacing;
		point rect_pos <- location + (direction * ((radius / 2.0) + (size / 2.0)));
		sensing_zone <- rectangle(radius, radius / 2.0) at_location rect_pos rotated_by angle;
	}

	// Driver reflex
	reflex drive {
		bool exec_loop <- true;
		int nb_loop <- 0;
		
		loop while: exec_loop {
			// Get distance and direction
			distance <- location distance_to target;	
						
			if distance = 0 {
				exec_loop <- false;
			} else {
				do inner_drive();
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
			ask wrapped {
				do later the_action: change_road;
			}
		}
	}
	
	// Default
	aspect default {		
		// Draw the effect zone used in "following behavior"
		draw sensing_zone color: #darkcyan empty: true;
		// Draw speed
		draw line(location, location + (direction * speed)) color: #black;
	}
}
