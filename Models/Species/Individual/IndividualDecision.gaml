/**
* Name: IndividualDecision
* Based on the internal empty template. 
* Author: alice
* Tags: 
*/
model IndividualDecision

import "Individual.gaml"
import "Context.gaml"


species IndividualDecision parent: Individual{
	string athletic among: ["no", "a bit", "yes", nil];
	map<string,int> grades;//how agent care for differents criteria	
	map<string, float> priority_modes;
	Context current_context;
	map<Context, string> habits_list;
	
	
	action change_context{
		ask current_context {
                do init(weather, Building closest_to myself.location, target);
               
     	}
	}
	
	action update_mode{
		do change_context();
		bool exist_already <- false;
		
		loop ctx over: habits_list.keys{
			ask current_context{
				if (self.is_the_same(ctx)){
					exist_already <- true;
				}
			}
		}
		
		if exist_already {
			chosen_mode <- habits_list[current_context];
		} else {
			do update_priority();
			chosen_mode<-get_max_priority_mode();
			
		}
			
	}
	
	
	string get_max_priority_mode{
		float p <- max(priority_modes);
		switch p{
			match priority_modes["car"]{
				return "car";
			}
			match priority_modes["bike"]{
				return "bike";
			}
			match priority_modes["walk"]{
				return "walk";
			}
			match priority_modes["bus"]{
				return "bus";
			}
		}
		
	}
	
	action change_context{
		ask current_context {
                do init(weather, Building closest_to location, target);
               
     	}
	}
	
	action add_habit(string pl) {
		do change_context();
		
		bool exist_already <- false;
		loop ctx over: habits_list.keys{
			ask current_context{
				
				if (self.is_the_same(ctx)){
					//write 'oui';
					exist_already <- true;
				}
			}
		}
		
		if (exist_already = true) {
			
		} else {
			add current_context::pl to: habits_list;
		}
		
		
		
	}
	
	
	//calcul pour chaque valeur
	float compute_value(string type, string criterion){ //compute contextual value according to mode and criteria
		
		float distance<- location distance_to target_point;
			
		float time_bike <- distance/bike_speed+0.1;
		float time_car <- distance/car_speed+0.1;
		float time_bus <- (distance/bus_speed+0.1)+bus_freq/2;
		float time_walk <- distance/walk_speed+0.1;
		
		float price_bus <- subscription_price/(21.8*2)+ 0.1; //21.8 est le nombre moyen de jour "de semaine" par mois
		float price_car <- (7.2*distance/100*gas_price) +0.1;
		float price_bike <- 0.0001;
		float price_walk <- 0.0001;
		
		float val;
		switch type {
			match "car" {
				switch criterion {
					match "comfort" {
						val <- 1.0;
					}
					match "price" {
						//on considère qu'une voiture dépense 7,2 litres pour 100 km(moyenne sur 2019)
						
						val <- 1.0 /(price_car/min([price_car,price_bus, price_walk, price_bike]));
						
					}
					match "time" {
						//on considère que la voiture à une allure moyenne de 25km/h
						//write max(time_car,time_bike, time_bus, time_walk);
						val<- 1.0/(time_car/min(time_car,time_bike, time_bus, time_walk));
						
					}
					match "ecology"{
						val <-0.0;
					}
					match "simplicity"{
						val <- 1.0;
					}
					match "safety"{
						
						val <- 1 - nb_car/100;
						
						//eventuellement prendre en compte la capacité de la route ? est-ce une info à la quelle on a accès ?
					}
				}	
			}//end match car
			match "bike" {
				switch criterion {
					match "comfort" {
						//enfants, motif du déplacement
						if(distance <5000){
							val <- 0.7;
						} else if (distance <9000){
							val <- 0.7- distance/5000;
							
						} else {
							val <- 0.0;
						}
//						
						
						if athletic = "no"{
							val <- val + 0.0;
						} else if (athletic = "a bit") {
							val <- val + 0.5;
						} else {
							val <- val + 1.0;
						}
						
						if weather = "sunny"{
								val <- (val +0.9)/3;
							} else if (weather = "rainy"){
								val <-(val + 0.2)/3;
							} else {
								val <- (val + 0.0)/3;
							}
					}
					match "price" {
						val <- 1/ (price_bike/min(price_car, price_bus, price_walk, price_bike));
					}
					match "time" {
						val<- 1 / (time_bike/min(time_car,time_bike, time_bus, time_walk));
					
					}
					match "ecology"{
						val <- 1.0;
					}
					match "simplicity"{
						// dans le trajet effectué, voir pourcentage route cyclables + distance au dessus de 20min pas cool (voir papiers socio)
						val <- 0.6;
					}
					match "safety"{
						//dans le trajet effectué pourcentage de route non partagée avec automobilistes
						val <-ratio_cycleway;
					}			
				}
			}//end match bike
			match "bus" {
				switch criterion {
					match "comfort" {
						//selon son heure de départ
						//nb de personnes qu'on peut transporter en 30min - nb actuel de passager
						float val1 <- ((30/bus_freq)* bus_capacity) - nb_bus/6;
						val <- val1/((30/bus_freq)* bus_capacity);
					}
					match "price" {
					 	val <- 1/ (price_bus/min(price_car,price_bus, price_walk, price_bike));
					 
					
					}
					match "time" {
						// On considère qu'un bus se déplace à 10km/h
						val<- 1 / (time_bus/min(time_car,time_bike, time_bus, time_walk));
						
					}
					match "ecology"{
						val <- 0.8;
					}
					match "simplicity"{
						//Dépend du nombre de ligne de bus différentes à prendre; à voir comment faire avec ces data
						val <-0.7;
					}
					match "safety"{
						if (sex = "f"){
							if(current_date.hour>21.0){
								val <- 0.5;
							} else {
								val <- 0.80;
							}
						} else {
							val <- 0.9;
						}
						
					}
				}
				
			}//end match bus
			match "walk"{
				switch criterion {
					match "comfort" { 
						if(distance <10){
							val <- 1.0;
						} else if (distance <25){
							val <- 1 - distance/1000;
							
						} else {
							val <- 0.0;
						}
//						
						if weather = "sunny"{
								val <- (val +1.0);
						} else if (weather = "rainy"){
							val <- (val + 0.0);
						} else {
							val <- (val + 0.0);
						}

						if athletic = "no"{
							val <- (val + 0.0)/3;
						} else if (athletic = "a bit") {
							val <- (val+0.5)/3;
						} else {
							val<- (val +1.0)/3;
						}
					}
					match "price" {
						val <- 1 / (price_walk/min(price_car, price_bus, price_walk, price_bike));
						
					}
					match "time" {
						val<- 1 / (time_walk/min(time_car,time_bike, time_bus, time_walk));
					
					}
					match "ecology"{
						val <- 1.0;
					}
					match "simplicity"{
						val <- 0.6;
						
					}
					match "safety"{
						if (sex = "f"){
							if(current_date.hour>21.0){
								val <- 0.2;
							} else {
								val <- 0.80;
							}
						} else {
							val <- 0.8;
						}
					}			
					
				}//end match criterion
			}//end match walk
		}//end switch
		
		return val;
	}

	//calcul pour un seul mode
	float compute_priority_mobility_mode(string type) {
		float val <- 0.0;
		float sum <- 0.0;
		float tot <- 0.0;
		loop i from: 0 to: length(criteria)-1{
			val <- grades[criteria[i]]*(compute_value(type,criteria[i]));
			sum <- sum+val;
			tot <- tot+ grades[criteria[i]];
		}
		
		return sum /tot;
	
		
		
	}
	
	//update les critères rationnels 
	action update_priority {
		
		loop i from: 0 to: length(type_mode)-1{
			
			priority_modes[type_mode[i]]<- compute_priority_mobility_mode(type_mode[i]);
			
		}
		
		float p <- max(priority_modes);
		switch p{
			match priority_modes["car"]{
				nb_car<-nb_car+1;
			}
			match priority_modes["bike"]{
				nb_bike<-nb_bike+1;
			}
			match priority_modes["walk"]{
				
				nb_walk<-nb_walk+1;
			}
			match priority_modes["bus"]{
				nb_bus<-nb_bus+1;
			}
		}
		
		
		
	}
	
}



/* Insert your model definition here */

