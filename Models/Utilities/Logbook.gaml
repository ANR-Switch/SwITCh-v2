/**
* Name: Logbook
* Log data.
* Author: Jean-François Erdelyi 
* Tags: 
*/
model SwITCh

/** 
 * Logbook species
 */
species Logbook skills: [logging_book] {
	string file_path <- "/Users/jferdelyi/Downloads/";

	reflex write_data when: cycle = 5000 {
		do write file_name: (file_path + name + "_" + (starting_date + (machine_time / 1000)) + ".json") flush: true;
	}

}
