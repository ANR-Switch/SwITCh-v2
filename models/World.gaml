/**
* Name: World
* Entry point of SwITCh simulation.
* Author: Jean-François Erdelyi 
* Tags: 
*/

model SwITCh

import "Utilities/Event_Manager.gaml"

import "Species/Network/Road_Models/Simple_Road_Model.gaml"

import "Species/Individual/Individual.gaml"
import "Species/Building.gaml"
import "Species/Network/Road.gaml"
import "Species/Network/Crossroad.gaml"

global {
	
	// Starting date of the simulation 
	date starting_date <- date([1970,1,1,0,0,0]);
		
	// Get general configuration
	file config <- json_file("../utilities/Config.json");
	map<string, unknown> config_data <- config.contents;
	
	file osm_road_type_json <- json_file("../Parameters/OSM road types.json");
	map<string, unknown> osm_road_type_data <- osm_road_type_json.contents;
	
	// Get configs data
	string dataset <- string(config_data["datasets_root"]) + string(config_data["dataset"]);
	map<string, list> car_definition <- osm_road_type_data["car_definition"];
	map<string, list> bicycle_definition <- osm_road_type_data["bicycle_definition"];
	
	// Get shapes
	shape_file shape_buildings <- shape_file(dataset + "/buildings.shp");
//	shape_file shape_individuals <- shape_file(dataset + "/individuals.shp");
	shape_file shape_nodes <- shape_file(dataset + "/nodes.shp");
	shape_file shape_roads <- shape_file(dataset + "/roads.shp");
	
	// TODO : to review : init value when all agents created or a  function ?  s
	list<Road> roads -> {agents of_generic_species Road};
	
	// Change the geometry of the world
	geometry shape <- envelope(shape_roads);
	
	// Networks
	graph road_network;
	graph bicycle_network;
		
	init {
		create Event_Manager;
		
		// Create roads from database
		create Simple_Road_Model from: shape_roads with: [
			type::read("type"),
			junction::read("junction"),
			max_speed::float(read("maxspeed")),
			nb_lanes::int(read("lanes")),
			oneway::read("oneway"),
			foot::read("foot"),
			bicycle::read("bicycle"),
			access::read("access"),
			bus::read("bus"),
			parking_lane::read("parking_la"),
			sidewalk::read("sidewalk"),
			cycleway::read("cycleway")
		];
		
		
		// Create nodes
		create Crossroad from: shape_nodes;

		// Create buildings from database
		create Building from: shape_buildings with: [
			id::int(read("id")), 
			type::read("type")
		];
		
		// Create individuals from database
//		create Individual from: shape_individuals with: [
//			working_place::one_of(Building where (each.id = read("work_pl"))), 
//			home_place::one_of(Building where (each.id = read("home_pl")))
//		];
		
		// Get networks from roads definitions		
		road_network <- directed(as_edge_graph(roads 
			where ((car_definition["type"] contains each.type) 
				or (car_definition["access"] contains each.access)), 
		Crossroad));	
		
		bicycle_network <- directed(as_edge_graph(roads 
			where ((bicycle_definition["type"] contains each.type) 
				and (bicycle_definition["access"] contains each.type)
					or (bicycle_definition["bicycle"] contains each.bicycle)
					or (bicycle_definition["cycleway"] contains each.cycleway)
			),
	 	Crossroad));
	 	
	 	ask roads {
			start_node <- Crossroad(first(self.shape.points));
			end_node <- Crossroad(last(self.shape.points));
			
			//don't know why some roads have a nil start...
			if (start_node = nil or end_node = nil) {
	//			do die;
			}

			point A <- start_node.location;
			point B <- end_node.location;
			if (A = B) {
				trans <- {0, 0};
			} else {
				point u <- {-(B.y - A.y) / (B.x - A.x), 1};
				float angle <- angle_between(A, B, A + u);
				// write sample(int(angle));
				// write sample(norm(u));
				if (angle < 150) {
					trans <- u / norm(u);
				} else {
					trans <- -u / norm(u);
				}

			}

		}
	}
}

experiment SwITCh type: gui {	
	output {
		display main_window type: opengl {	
			species Road;
			species Simple_Road_Model;
			species Crossroad;
			species Building;
			species Individual;
		}
	}
}
