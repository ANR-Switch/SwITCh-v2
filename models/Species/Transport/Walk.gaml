/**
* Name: Walk
* Based on the internal empty template. 
* Author: Lo�c
* Tags: 
*/


model SwITCH

import "PrivateTransport.gaml"

species Walk parent: PrivateTransport {
	
	string transport_mode <- "walk";
	
	init{
		max_speed <- 6.0;
		size <- 1.0;
		max_passenger <- 1;
	}
	
	action end(date arrived_time){
		do updatePassengerPosition();
		loop passenger over:passengers{
			ask passenger{ 
				do executeTripChain(arrived_time);
			}
		}
		do die;
	}
	
	aspect default {
		draw square(2) color: #green border: #black;
	}
	
}

