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

		create simple_Individual from: agent_list;
	}
}

species simple_Individual{
	
	int age;
	string activity;
	string sex;
	
}

experiment "Visualise Synthethic population" type: gui {
	output {

		display "Age" type: opengl {
			chart "Age distribution" type: pie {
				data "0-16" value: simple_Individual count (each.age < 17);
				data "16-24" value: simple_Individual count (each.age > 16 and each.age < 25);
				data "25-34" value: simple_Individual count (each.age > 24 and each.age < 35);
				data "35-64" value: simple_Individual count (each.age > 34 and each.age < 65);
				data "64 +" value: simple_Individual count (each.age > 64);
			}

		}

		display "Activities" type: opengl {
			chart "Activities" type: pie {
				data "AGRICULTEUR" value: simple_Individual count (each.activity = "AGRICULTEUR");
				data "ARTISAN" value: simple_Individual count (each.activity = "ARTISAN");
				data "CADRE" value: simple_Individual count (each.activity = "CADRE");
				data "CHOMEUR" value: simple_Individual count (each.activity = "CHOMEUR");
				data "ECOLIER" value: simple_Individual count (each.activity = "ECOLIER");
				data "EMPLOYE" value: simple_Individual count (each.activity = "EMPLOYE");
				data "ETUDIANT" value: simple_Individual count (each.activity = "ETUDIANT");
				data "INACTIF" value: simple_Individual count (each.activity = "INACTIF");
				data "OUVRIER" value: simple_Individual count (each.activity = "OUVRIER");
				data "PROFINTERMEDIAIRE" value: simple_Individual count (each.activity = "PROFINTERMEDIAIRE");
				data "RETRAITE" value: simple_Individual count (each.activity = "RETRAITE");
			}

		}

		display "Sex" type: opengl {
			chart "Sex distribution" type: pie {
				data "H" value: simple_Individual count (each.sex = "HOMME");
				data "F" value: simple_Individual count (each.sex = "FEMME");
			}

		}

	}

}