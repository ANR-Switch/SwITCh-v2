/**
* Name: Synthethicpopulationexplorer
* Based on the internal empty template. 
* Author: nverstae
* Tags: 
*/
model Synthethicpopulationexplorer

global {
	init {
		csv_file agent_list <- csv_file("../Datasets/Castanet/Population/agents.csv",true);

		create Individual from: agent_list;
	}
}

species Individual{
	
	int age;
	string activity;
	string sex;
	
}

experiment "Visualise Synthethic population" type: gui {
	output {

		display "Age" type: opengl {
			chart "Age distribution" type: pie {
				data "0-16" value: Individual count (each.age < 17);
				data "16-24" value: Individual count (each.age > 16 and each.age < 25);
				data "25-34" value: Individual count (each.age > 24 and each.age < 35);
				data "35-64" value: Individual count (each.age > 34 and each.age < 65);
				data "64 +" value: Individual count (each.age > 64);
			}

		}

		display "Activities" type: opengl {
			chart "Activities" type: pie {
				data "AGRICULTEUR" value: Individual count (each.activity = "AGRICULTEUR");
				data "ARTISAN" value: Individual count (each.activity = "ARTISAN");
				data "CADRE" value: Individual count (each.activity = "CADRE");
				data "CHOMEUR" value: Individual count (each.activity = "CHOMEUR");
				data "ECOLIER" value: Individual count (each.activity = "ECOLIER");
				data "EMPLOYE" value: Individual count (each.activity = "EMPLOYE");
				data "ETUDIANT" value: Individual count (each.activity = "ETUDIANT");
				data "INACTIF" value: Individual count (each.activity = "INACTIF");
				data "OUVRIER" value: Individual count (each.activity = "OUVRIER");
				data "PROFINTERMEDIAIRE" value: Individual count (each.activity = "PROFINTERMEDIAIRE");
				data "RETRAITE" value: Individual count (each.activity = "RETRAITE");
			}

		}

		display "Sex" type: opengl {
			chart "Sex distribution" type: pie {
				data "H" value: Individual count (each.sex = "HOMME");
				data "F" value: Individual count (each.sex = "FEMME");
			}

		}

	}

}