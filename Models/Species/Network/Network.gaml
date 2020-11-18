/**
* Name: Network
* Network associated to transport. 
* Author: Loïc
* Tags: 
*/
model SwITCh

import "Crossroad.gaml"
import "Road.gaml"

/** 
 * Add to world the action to create a new walk
 */
global {
	// Create a new network
	Network create_network(graph network_graph) {
		create Network returns: values {
			available_graph <- network_graph;
		}

		return values[0];
	}	
}

/**
 * Network species
 */
species Network {
	// Road graph available for the transport
	graph<Crossroad, Road> available_graph;
	
	// If true is already computed
	bool computed <- false;

	// If true path is nil
	bool path_nil <- false;
	
	// List of roads that lead to the target (must be computed)
	// First road is the current road
	list<Road> path_to_target;
	
	// Compute
	action compute (point from_location, point to_location) {
		path the_path <- path_between(available_graph, from_location, to_location);
		if (the_path = nil) {
			// Something wrong
			path_nil <- true;
		} else {
			path_to_target <- list<Road>(the_path.edges);
		}
		computed <- true;
	}

	// Pre compute path
	bool pre_compute (point start_location, point end_location) {
		do compute(start_location, end_location);
		if (computed and not path_nil) {
			return true;
		}

		return false;
	}
}
