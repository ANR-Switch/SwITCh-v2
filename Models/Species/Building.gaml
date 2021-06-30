/***
* Name: Building
* Author: ptaillandie
* Description: 
* Tags:
***/

model SwITCh

/** 
 * Add to world the map of colors for each activities
 */
global {
	//The list of activities
	string blg_type_home <- "staying_home";
	string blg_type_work <- "working";
	string blg_type_school <- "studying";
	string blg_type_shop <- "shopping";
	string blg_type_leisure <- "leisure";
	string blg_type_default <- "default";
	map<string, rgb> blg_colors <- [blg_type_home::#grey, blg_type_work::#red, blg_type_school::#cyan, blg_type_shop::#gold, blg_type_leisure::#magenta, blg_type_default::#white];
	rgb blg_color_default <- #white;
}

/** 
 * Building species
 */
species Building {
	// Building ID
	string id;

	// Type
	string type <- blg_type_default;
	
	// List of types (primary and others)
	list<string> types <- [];

	// Subarea (if the world is composed of several areas)
	string sub_area;
	
	// Number of households in the building
	int nb_households <- 1;
	
	// Size of the building
	float size <- shape.perimeter;
	
	// Default aspect
	aspect default {
		rgb current_color <- (type in blg_colors.keys) ? blg_colors[type] : blg_color_default ;
		draw shape color: current_color width: 1 border: #black;
		//draw shape border: current_color color: current_color width: 2;
	}

}
