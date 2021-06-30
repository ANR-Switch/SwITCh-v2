/**
* Name: World
* Entry point of SwITCh simulation.
* Author: Jean-François Erdelyi 
* Tags: 
*/
model SwITCh

import "Utilities/EventManager.gaml"
import "Species/Individual/Individual.gaml"
import "Species/Building.gaml"
import "Species/Network/Road.gaml"
import "Species/Network/Crossroad.gaml"
import "Species/Transport/Private/Car.gaml"

/** 
 * Setup the world
 */
global {

	// If true set all mixed road to micro
	bool micro_level <- false;
	
	// Do we compute all the shortest path?
	
	bool save_shortest_paths <- false;
	bool load_shortest_paths <- true;

	// Starting date of the simulation 

	date starting_date <- date([1970, 1, 1, 0, 0, 0]);
	float step <- 1#second;
	float seed <- 424242.0;

	// Get general configuration
	file config <- json_file("../Parameters/Config.json");
	map<string, unknown> config_data <- config.contents;

	// Get configs data
	string dataset <- string(config_data["datasets_root"]) + string(config_data["dataset"]);

	// Get shapes
	shape_file shape_buildings <- shape_file(dataset + "/Infrastructure/CASTANET-TOLOSAN/buildings.shp");
	shape_file shape_nodes <- shape_file(dataset + "/Infrastructure/CASTANET-TOLOSAN/nodes.shp");
	shape_file shape_roads <- shape_file(dataset + "/Infrastructure/CASTANET-TOLOSAN/roads.shp");
	shape_file shape_boundary <- shape_file(dataset + "/Infrastructure/CASTANET-TOLOSAN/boundary.shp");

	// CSV files from Mobisim
//	csv_file mobisim_individuals <- csv_file(dataset + "/Population/agents.csv",true);
	csv_file mobisim_individuals <- csv_file(dataset + "/Population/GEN_individuals.csv",",",string,true);	
	csv_file mobisim_households <- csv_file(dataset + "/Population/households.csv",true);
	csv_file mobisim_housings <- csv_file(dataset + "/Population/housings.csv",true);
	

	// Graph configuration
	string optimizer_type <- "NBAStar" among: ["NBAStar", "NBAStarApprox", "Dijkstra", "AStar", "BellmannFord", "FloydWarshall"];
	bool memorize_shortest_paths <- true; // True by default

	// Change the geometry of the world
	geometry shape <- envelope(shape_boundary);

	// Networks
	graph full_network;

	// Init the model
	init {
		// Only one event manager
		write "Utilities...";
		create EventManager number: 1;
		//create Logbook;
		write "-> " + (starting_date + (machine_time / 1000));

		// Create nodes (must be defined before roads in order to build the road with two crossroads) TODO OSM data ?
		write "Crossroad...";
		create Crossroad from: shape_nodes;
		write "-> " + (starting_date + (machine_time / 1000));

		// Create road
		write "Road...";
		create Road from: shape_roads with: [max_speed::float(read("maxspeed")), parking_lane::read("parking_la")];
		write "-> " + (starting_date + (machine_time / 1000));

		write "Graph...";
		
	 	// Do we compute all the shortest path?
	 	bool save_shortest_paths <- false;
	 	bool load_shortest_paths <- true;
	 	
		// Get networks		
		full_network <- as_driving_graph(Road, Crossroad);

		//allows to choose the type of algorithm to use compute the shortest paths
		full_network <- full_network with_optimizer_type optimizer_type;

		//allows to define if the shortest paths computed should be memorized (in a cache) or not
		full_network <- full_network use_cache memorize_shortest_paths;
	
		string shortest_paths_file <- "shortest_paths.csv";
		
		if save_shortest_paths {
			matrix ssp <- all_pairs_shortest_path(full_network);
			save ssp type:"text" to:shortest_paths_file;
			
		//loads the file of the shortest paths as a matrix and uses it to initialize all the shortest paths of the graph
		} else if load_shortest_paths {
			full_network <- full_network load_shortest_paths matrix(file(shortest_paths_file));
		}
		
		string shortest_paths_file <- "shortest_paths.csv";

 		if save_shortest_paths {
 			matrix ssp <- all_pairs_shortest_path(full_network);
 			save ssp type:"text" to:shortest_paths_file;

 		//loads the file of the shortest paths as a matrix and uses it to initialize all the shortest paths of the graph
 		} else if load_shortest_paths {
 			full_network <- full_network load_shortest_paths matrix(file(shortest_paths_file));
 		}
		
		// Setup the graphique representation
		ask Road {
			do setup();
		}
		
		write "-> " + (starting_date + (machine_time / 1000));

		// Create buildings from database (must be defined before individuals in order to build the individual with home place and working place)
		write "Building...";
		create Building from: shape_buildings with: [id::string(read("id")), type:: read("type")];
		write "-> " + (starting_date + (machine_time / 1000));

		// Create individuals 
		write "Individual...";
<<<<<<< HEAD
		//list<int> rds;
=======
>>>>>>> 1092fb77ece879e44a315e21364d16978f5f9f44
				
		create Individual from: mobisim_individuals with: [id_building :: string(get("id_building")),id::int(get("id")),age::int(get("age")), sex::string(get("sex")), role::string(get("role")),  profile::string(get("activity")),  education::string(get("education")),  income::int(get("income")),  id_household::int(get("id_household"))] {
			home_place <- Building first_with(each.id = id_building);
			if(home_place = nil) {
				do die;
			}  else {
				location <- any_location_in(home_place);
			}
		}	
		write sample(length(Individual));
		write "-> " + (starting_date + (machine_time / 1000));

//		// ############################ WIP IN PROGRESS TEST WARNING WARNING 
//		// Setup Individuals
//		write "Setup...";
//		if true {
//			file fake_agenda_json <- json_file("../Parameters/Agendas.json");
//			map<string, list<map<string, unknown>>> fake_agenda_data <- fake_agenda_json.contents;
//			
//			// Get building of each types (ONCE)
//			list<Building> study_building <- Building where (each.type = "studying");
//			list<Building> work_building <- Building where (each.type = "working");
//			list<Building> home_building <- Building where (each.type = "staying_home");
//			
//			//write study_building;
//			
//			loop activity over: list<map<string, unknown>>(fake_agenda_data["metro_boulot_dodo"]) {
//				int i <- 0;
//				date act_starting_time <- starting_date + int(activity["starting_date"]);
//				int act_type <- int(activity["activity_type"]);
//	
//				ask Individual {
//					// Add activity to all individuals
//					Activity a <- world.create_activity(act_starting_time + rds[i], act_type);
//					
//					//int random <- rnd(0, 100);
//					//if (random <= 85) {
//					//	has_car <- true;
//					//	has_bike <- true;	
//					//}
//	
//					/*if (random <= 24) {
//						a.start_date <- act_starting_time + (1800 * 0 + (1800 * rnd(0, 100) / 100));
//					} else if (random <= 50) {
//						a.start_date <- act_starting_time + (1800 * 1 + (1800 * rnd(0, 100) / 100));
//					} else if (random <= 76) {
//						a.start_date <- act_starting_time + (1800 * 2 + (1800 * rnd(0, 100) / 100));
//					} else if (random <= 94) {
//						a.start_date <- act_starting_time + (1800 * 3 + (1800 * rnd(0, 100) / 100));
//					} else if (random <= 100) {
//						a.start_date <- act_starting_time + (1800 * 4 + (1800 * rnd(0, 100) / 100));
//					}*/
//					
//					//a.start_date <- act_starting_time + (10 * (i / length(Individual)));
//					i <- i + 1;
//					
//					// If working ID exists
//					/*if working_place_id != nil and working_place_id >= 0 {
//						working_place <- Building first_with (each.id = working_place_id);
//					}
//					
//					// If home ID exists
//					if home_place_id != nil and home_place_id >= 0 {
//						home_place <- Building first_with (each.id = home_place_id);
//					}*/
//					
//					// If the working place is nil
//					//if working_place = nil {
//						if age < 18 {
//							working_place <- one_of(study_building);
//						} else if age >= 18 {
//							working_place <- one_of(work_building);
//						}
//			
//					//}
//					
//					// if the home place is nil
//					//if home_place = nil {
//						home_place <- one_of(home_building);
//					//}
//					
//					location <- any_location_in(home_place.shape);
//					
//					if a.get_activity_type_string() = "work" and working_place != nil {
//						do add_activity activity: a;						
//					} else if a.get_activity_type_string() = "studying" and working_place != nil {
//						do add_activity activity: a;						
//					} else if a.get_activity_type_string() = "familly" and home_place != nil {
//						do add_activity activity: a;						
//					} else {
//						do die();
//					}
//					
//					/*
//					if home_place = nil and age >= 18 {
//						home_place <- one_of(Building where (each.type = "staying_home"));
//					} else if home_place = nil and age < 18 {
//						Individual individual <- one_of(Individual where (each.age >= 18));
//						if (individual.home_place = nil) {
//							individual.home_place <- one_of(Building where (each.type = "staying_home"));
//						}
//	
//						home_place <- individual.home_place;
//					}
//	
//					if working_place = nil and age >= 18 {
//						working_place <- one_of(Building where (each.type = "working"));
//					} else if working_place = nil and age < 18 {
//						working_place <- one_of(Building where (each.type = "studying"));
//					}
//	
//					location <- any_location_in(home_place.shape);*/
//				}
//	
//			}
//		}
//		write "-> " + (starting_date + (machine_time / 1000));
		
		// ############################ WARNING WARNING WIP IN PROGRESS TEST 
		
		// TODO ???????? wtf because Agents are not scheduled
		
		/*create TransportMovingIdmWrapper {
			do die;
		}*/

		create Walk {
			do die;
		}

		create Car {
			do die;
		}

		create Bike {
			do die;
		}		
	}

}

// The main experiment
experiment "SwITCh" type: gui {
	// Speed of the "controled car"
	parameter "Micro level" var: micro_level category: "Models";
	output {
		display main_window type: opengl {
			species Road;
			species Crossroad;
			species Building;
			species Walk;
			species Car;
			species Bike;
			species Individual;
			
			//species TransportMovingIdmWrapper;
			//species MicroQueuedRoadIdmModel;
		}

	}

}
