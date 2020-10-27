/***
* Name: Individual
* Author: admin_ptaillandie
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model SwITCh

global {
	//The list of activities
	string blg_type_home <- "home";	
	string blg_type_work <- "work";
	string blg_type_school <- "school";
	string blg_type_shop <- "shop";
	string blg_type_leisure <- "leisure";
	string blg_type_default <- "default";
	
	map<string,rgb> blg_colors <- [
		blg_type_home::#grey, blg_type_work::#red, blg_type_school::#cyan, 
		blg_type_shop::#gold, blg_type_leisure::#magenta, blg_type_default::#white
	];
	rgb blg_color_default <- #white;
}

species Building {
	int id;
	string type <- blg_type_default;
	string sub_area;
	list<string> types <- [];
	
	//Number of households in the building
	int nb_households <- 1;
	float size <- shape.perimeter;

	aspect default {
		draw shape color: (type in blg_colors.keys)?blg_colors[type]:blg_color_default border: #black;
	}
}

species Outside parent: Building;
