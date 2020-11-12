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
import "Species/Network/RoadModel/Model/MicroRoad/TransportWrapper.gaml"

/** 
 * Setup the world
 */
global {
	
	// If true set all mixed road to micro
	bool micro_level <- false;

	// Starting date of the simulation 
	date starting_date <- date([1970, 1, 1, 0, 0, 0]);
	float step <- 0.1;

	// Get general configuration
	file config <- json_file("../Parameters/Config.json");
	map<string, unknown> config_data <- config.contents;

	// Get configs data
	string dataset <- string(config_data["datasets_root"]) + string(config_data["dataset"]);

	// Get shapes
	shape_file shape_buildings <- shape_file(dataset + "/buildings.shp");
	shape_file shape_individuals <- shape_file(dataset + "/individuals.shp");
	shape_file shape_nodes <- shape_file(dataset + "/nodes.shp");
	shape_file shape_roads <- shape_file(dataset + "/roads.shp");
	shape_file shape_boundary <- shape_file(dataset + "/boundary.shp");
	
	// Graph configuration
	string optimizer_type <- "NBAStar" among: ["NBAStar", "NBAStarApprox", "Dijkstra", "AStar", "BellmannFord", "FloydWarshall"];
	bool memorize_shortest_paths <- true; //true by default

	// Change the geometry of the world
	geometry shape <- envelope(shape_boundary);

	// Networks
	graph full_network;

	// Init the model
	init {
		// Only one event manager
		create EventManager;

		// Create nodes (must be defined before roads in order to build the road with two crossroads) TODO OSM data ?
		create Crossroad from: shape_nodes;
		
		// Create roads
		create Road from: shape_roads as list with:
		[model_type:: read("model_type"), type:: read("type"), junction::read("junction"), max_speed::float(read("maxspeed")), lanes::int(read("lanes")), oneway::read("oneway"), foot::read("foot"), bicycle::read("bicycle"), access::read("access"), bus::read("bus"), parking_lane::read("parking_la"), sidewalk::read("sidewalk"), cycleway::read("cycleway")];
			
		// Create buildings from database (must be defined before individuals in order to build the individual with home place and working place)
		create Building from: shape_buildings with: [id::int(read("id")), type::read("type")];

		// Create individuals from database 
		create Individual from: shape_individuals with: [working_place::one_of(Building where (each.id = read("work_pl"))), home_place::one_of(Building where
		(each.id = read("home_pl"))), age::int(read("age"))];
		
		// ############################ WIP IN PROGRESS TEST WARNING WARNING 
		// Setup Individuals
		file fake_agenda_json <- json_file("../Parameters/Agendas.json");
		map<string, list<map<string, unknown>>> fake_agenda_data <- fake_agenda_json.contents;
		loop activity over: list<map<string, unknown>>(fake_agenda_data["metro_boulot_dodo"]) {
			date act_starting_time <- starting_date + int(activity["starting_date"]);
			int act_type <- int(activity["activity_type"]);

			// Add activity to all individuals
			Activity a <- create_activity(act_starting_time, act_type);
			ask Individual {
				int random <- rnd(0, 100);
				if (random <= 85) {
					has_car <- true;
					has_bike <- true;
				}

				do add_activity activity: a;
				if home_place = nil and age >= 18 {
					home_place <- one_of(Building where (each.type = "staying_home"));
				} else if home_place = nil and age < 18 {
					Individual individual <- one_of(Individual where (each.age >= 18));
					if (individual.home_place = nil) {
						individual.home_place <- one_of(Building where (each.type = "staying_home"));
					}

					home_place <- individual.home_place;
				}

				location <- any_location_in(home_place.shape);
				if working_place = nil and age >= 18 {
					working_place <- one_of(Building where (each.type = "working"));
				} else if working_place = nil and age < 18 {
					working_place <- one_of(Building where (each.type = "studying"));
				}

			}

		}
		// ############################ WARNING WARNING WIP IN PROGRESS TEST 
		
		// Get networks		
		full_network <- directed(as_edge_graph(Road, Crossroad));
		
		//allows to choose the type of algorithm to use compute the shortest paths
		full_network <- full_network with_optimizer_type optimizer_type;

		//allows to define if the shortest paths computed should be memorized (in a cache) or not
		full_network <- full_network use_cache memorize_shortest_paths;
		
		// TODO ???????? wtf because Agents are not actived
		create TransportWrapper {
			do die;
		}
		
		// TODO ???????? wtf because Agents are not actived
		create Walk {
			do die;
		}
		
		// TODO ???????? wtf because Agents are not actived
		create Car {
			do die;
		}
		
		// TODO ???????? wtf because Agents are not actived
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
			species TransportWrapper;

		}

	}

}
