/**
* Name: GenerateagendasfromMobiliscopedata
* Based on the internal empty template. 
* Author: bdoussin
* Tags: 
*/

model SimpleSwitchAgenda

import "Individual.gaml"
import "Activity.gaml"

global {
	
	string district_number <- "\"047\"";
	csv_file csv_activities <- csv_file("Mobiliscope_Data/act_nb.csv");
	list activities <- rows_list(csv_activities.contents) where (string(each[0]) = district_number);
	list<list<int>> hourly_activities <- [];
	int max_dans_la_zone;
	list<string> actionP <- ["familly", "work", "studying", "shopping", "leisure"];

}
