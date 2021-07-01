/**
* Name: GenerateagendasfromMobiliscopedata
* Based on the internal empty template. 
* Author: nverstae
* Tags: 
*/
model GenerateagendasfromMobiliscopedata

/* Insert your model definition here */
global {

	init {
	// Get general configuration
		file config <- json_file("../Parameters/Config.json");
		map<string, unknown> config_data <- config.contents;
		string district_number <- "\"047\"";

		// Get configs data
		string dataset <- string(config_data["datasets_root"]) + string(config_data["dataset"]);

		// Get synthethic population
		csv_file mobisim_individuals <- csv_file(dataset + "/Population/GEN_individuals.csv",true);

		// Get number of activities per hours ['Loisir', 'Achat', 'Etudes', 'Travail', 'A la maison']
		csv_file csv_activities <- csv_file("../Datasets/Castanet/Statistics/Mobiliscope/act_nb.csv"); //.contents where ((each column_at (0)) = district_number);
		list activities <- rows_list(csv_activities.contents) where (string(each[0]) = district_number);
		list hourly_activities <- [];
		loop line over: activities {
			add [line[2], line[3], line[4], line[5], line[6]] to: hourly_activities;
		}

		// Get resident mix per hour ['Residents', 'Non-résidents']
		csv_file csv_residents <- csv_file("../Datasets/Castanet/Statistics/Mobiliscope/res_nb.csv");
		list residents <- rows_list(csv_residents.contents) where (string(each[0]) = district_number);
		list hourly_residents <- [];
		loop line over: residents {
			add [line[2], line[3]] to: hourly_residents;
		}

		// Get last mode mix per hour ['Mobilité douce', 'Vehicule motorisé privé', 'Transports public']
		csv_file csv_mode <- csv_file("../Datasets/Castanet/Statistics/Mobiliscope/mode_nb.csv");
		list mode <- rows_list(csv_mode.contents) where (each[0] = district_number);
		list hourly_mode <- [];
		loop line over: mode {
			add [line[2], line[3], line[4]] to: hourly_mode;
		}

		// Get list of citizen ids
		list<string> id <- matrix<string>(mobisim_individuals) column_at (0);
		list population <- rows_list(mobisim_individuals.contents);

		// Map containing for each citizen its associated agenda
		map<string, list> agendas <- map([]);

		// For each citizen, initialise his/her agenda
		loop citoyen over: id {
			list<int> agenda <- 24 list_with 0;
			add agenda at: citoyen to: agendas;
		}
		
		bool bfirst <- true;
		// First, we'll loop over the agendas to determine for each hour if the citizen is in the city (1) or not (0)
		loop citizen over: agendas.pairs {
			int hour <- 0;
			int nbResident <- 0;
			int nbNonResident <- 0;
			int total;
			loop hour from: 0 to: 23 {
				nbResident <- (list(hourly_residents[hour])[1]);
				nbNonResident <- (list(hourly_residents[hour])[0]);
				list h_act <- hourly_activities[hour];
						bool resident <- rnd_choice([true::nbResident,false::nbNonResident]);
						if(resident){
							citizen.value[hour] <- rnd_choice([1::int(h_act[0]),2::int(h_act[1]),3::int(h_act[2]),4::int(h_act[3]),5::int(h_act[4])]);
						}else{
							citizen.value[hour] <-  0;
						}
			}
			save [citizen.key]+citizen.value to: "../Datasets/Castanet/Population/agenda.csv" header:false type:"csv" rewrite: bfirst ;
			bfirst <- false;
			//write [citizen.key,citizen.value];
			
		}
		
//		save agendas to: "../Datasets/Castanet/Population/agenda.csv" type:"csv" rewrite: true;

		// Now that we have the proper distribution in column, we need to check and repair row constraints.
		loop citizen over: agendas.pairs {
			
		}
	}
	
	action switchActivities(string id1, string id2, int act1, int act2,map<string,list> agendas,int hour){
		list<int> agenda1 <- agendas[id1];
		list<int> agenda2 <- agendas[id2];
		int tmp <- agendas[id1][hour];
		agendas[id1][hour] <- agendas[id2][hour];
		agendas[id2][hour] <- tmp;
	}
	
	string getOneOfIdFromCSP(string CSP,list<list> population){
		return one_of(population where (each[4] = CSP))[0];
	}
	
	string getCSPfromID(string id,list<list> population){
		return ( population first_with (each[0] = id))[4]; 
	}

}

experiment name type: gui {

// Define parameters here if necessary
// parameter "My parameter" category: "My parameters" var: one_global_attribute;

// Define attributes, actions, a init section and behaviors if necessary
// init { }
	output {
	// Define inspectors, browsers and displays here

	// inspect one_or_several_agents;
	//
	// display "My display" { 
	//		species one_species;
	//		species another_species;
	// 		grid a_grid;
	// 		...
	// }

	}

}