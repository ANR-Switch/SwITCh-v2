/**
* Name: MOBISIMJointagentshousseholdshousings
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/


model MOBISIMJointagentshousseholdshousings

global {
	csv_file agents_csv_file <- csv_file("../Datasets/Castanet/Population/agents.csv",",",string,true);
	csv_file households_csv_file <- csv_file("../Datasets/Castanet/Population/households.csv",",",string,true);
	csv_file housings_csv_file <- csv_file("../Datasets/Castanet/Population/housings.csv",",",string,true);

	init {
		matrix<string> mat_households <- households_csv_file.contents;
		matrix<string> mat_housings <- housings_csv_file.contents;
		
		map<string,string> map_households_housings <- map([]);
		map<string,string> map_housings_buildings <- map([]);
		
		loop row over: rows_list(mat_households) {
			add  row[4] replace("\"","") at: row[0] replace("\"","")  to: map_households_housings;
		}

		loop row over: rows_list(mat_housings) {
			add  row[6] replace("\"","") at: row[0] replace("\"","")  to: map_housings_buildings;
		}
		
		create Individual from: agents_csv_file with: [
			id::string(get("Id")),
			age::int(get("age")), 
			sex::string(get("sex")), 
			role::string(get("role")),  
			activity::string(get("activity")),
			education::string(get("education")),
			income::int(get("income")),
			id_household::string(get("id_household"))
		] {
			id_building <- map_housings_buildings[map_households_housings[string(id_household)]];
		}
		
//		save ["id","age","sex", "role", "activity", "education", "income", "id_household", "id_building"] type: csv to:"../Datasets/Castanet/Population/GEN_individuals.csv" rewrite: true;
		ask Individual {
			save [id,age,sex, role, activity, education, income, id_household, id_building] type: csv to:"../Datasets/Castanet/Population/GEN_individuals.csv" rewrite: false;			
		}
	}
}

species Individual {

	string id;
	int age;
	string sex; 	
	string role;
	string activity;
	string education;
	int income;
	string id_household;
	string id_building;
}



experiment name type: gui {
	output {}
}