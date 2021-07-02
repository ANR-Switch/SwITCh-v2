/**
* Name: GENGFTS
* Based on the internal empty template. 
* Author: benoitgaudou
* Tags: 
*/

// TODO:
// - un crop en Java du GTFS selon la zone d'étude
// - un file type GTFS pour  représenter le dossier GFTS. = a GTFS feed ?
//		- check presence  of all mandatory files (csv or txt)
// - skills for  each agent type
// - create a_speciess_with_a_GTFS_skill from: GTFSS_file;


model GENGFTS

global {

	shape_file boundary_shape_file <- shape_file("../Datasets/Castanet/Infrastructure/CASTANET-TOLOSAN/boundary.shp");
	shape_file buildings_shape_file <- shape_file("../Datasets/Castanet/Infrastructure/CASTANET-TOLOSAN/buildings.shp");
	
	geometry shape <- envelope(boundary_shape_file);
	
	csv_file stops_csv_file <- csv_file("../Datasets/Castanet/GFTS/stops.csv",",",string,true);
	csv_file shapes_csv_file <- csv_file("../Datasets/Castanet/GFTS/shapes.csv",",",string,true);
	csv_file trips_csv_file <- csv_file("../Datasets/Castanet/GFTS/trips.csv",",",string,true);

//	csv_file stop_times_csv_file <- csv_file("../Datasets/Castanet/GFTS/stop_times.csv",",",string,true);	
	csv_file stop_times_csv_file <- csv_file("../Datasets/Castanet/GFTS/GEN_stop_times.csv",",",string,true);
	
	date starting_date <- date ('1970-01-01 05:30:00');
	float step <- 20 #s;
	graph road_network;

	list<pair<trip,date>> bus_agenda;

	init {
		create boundary from: boundary_shape_file;
		create building from: buildings_shape_file;
		
		write "/==================================";
		write " CREATION OF STOPs                 ";
		write "/==================================";		
		
		create stop from: stops_csv_file with: [
			lat::float(get("stop_lat")), 
			lon::float(get("stop_lon")),
			stop_id::string(get("stop_id"))
		]  {
			location <- to_GAMA_CRS({lon,lat}, crs(boundary_shape_file)) as point;
			if(not (first(boundary) overlaps self)) {
				do die;
			}
		}
		write "Number of stops: " + length(stop);

		write "/==================================";
		write " CREATION OF ROADs                 ";
		write "/==================================";	
		
		create point_road from: shapes_csv_file with: [
			shape_id::string(get("shape_id")), 
			shape_pt_lat::float(get("shape_pt_lat")),
			shape_pt_lon::float(get("shape_pt_lon")),
			shape_pt_sequence::float(get("shape_pt_sequence"))			
		] {
			location <- to_GAMA_CRS({shape_pt_lon,shape_pt_lat}, crs(boundary_shape_file)) as point;		
			if(not (first(boundary) overlaps self)) {
				do die;
			}			
		}
		
		map<string,list<point_road>> roads <- point_road group_by(each.shape_id);

		loop r over: roads.pairs {
			list<point> pts <- (r.value sort_by(each.shape_pt_sequence)) collect (each.location);
			create road  with:[shape::line(pts), shape_id::r.key];
		}
		ask point_road {do die;}
		road_network <- as_edge_graph(road);
		
		write "Number of roads: " + length(road);


		write "/==================================";
		write " CREATION OF TRIPs                 ";
		write "/==================================";	
		
		create trip from: trips_csv_file with: [
			trip_id::string(get("trip_id")), 
			shape_id::string(get("shape_id"))
		] {
			if(road first_with(each.shape_id = self.shape_id) = nil){
				do die;
			}
		}
		write "Number of trips: " + length(trip);


		write "/==================================";
		write " CREATION OF THE bus_agenda        ";
		write "/==================================";	
			
 		loop stop_time_line over: rows_list(matrix(stop_times_csv_file)) {
			trip t <- trip first_with(each.trip_id = stop_time_line[0]);
			stop s <- stop first_with(each.stop_id = stop_time_line[1]);
			if(t != nil and s != nil){
				add map([
					"stop"::s,
					"stop_sequence"::stop_time_line[2],
					"arrival_time"::date(stop_time_line[3],"HH:mm:ss"),
					"departure_time"::date(stop_time_line[4],"HH:mm:ss")
					]) to: t.stop_times;
						
	//			save stop_time_line to: "../Datasets/Castanet/GFTS/GEN_stop_times.csv" type: csv header: false rewrite: false;		
			}
		}
		
		loop t over: trip {
			date date_departure <- t.stop_times min_of( each["departure_time"] as date );
//			write t.stop_times with_min_of(each["departure_time"] as date) as date;
			bus_agenda << t::date_departure;
		}
		bus_agenda <- bus_agenda sort_by(each.value);

	}
	
	reflex stop_simu when: empty(bus_agenda) {
		do pause;
	}
	
	reflex go when: first(bus_agenda).value = current_date {
		list<pair> pairs_to_remove;
		
		loop trip_date over: bus_agenda {
			if(trip_date.value != current_date) {
				break;
			}
			add trip_date to: pairs_to_remove;
			create bus {
				bus_trip <- trip_date.key;		
				location <- (first(bus_trip.stop_times)["stop"] as stop).location;
				remove first(bus_trip.stop_times) from: bus_trip.stop_times;
				target <- first(bus_trip.stop_times)["stop"];
			}
			write sample(length(bus)) + " - " + current_date;
		}
		remove all: pairs_to_remove from: bus_agenda;
	}
}

species trip {
	string trip_id;
	string shape_id;
	list<map> stop_times <- [];
}

species bus skills: [moving] {
	trip bus_trip;
	stop target;
	
	reflex death when: target = nil {
		do die;
	}
	
	reflex move {
		do goto target: target on: road_network;
		
		if(location = target.location) {
			remove first(bus_trip.stop_times) from: bus_trip.stop_times;
			
			if(empty(bus_trip.stop_times)) {
				write "TRIP " + bus_trip + " is over!";
				do die;
			}
			target <- first(bus_trip.stop_times)["stop"];
		}
	}
	
	aspect default {
		draw rectangle(20,10) color: #blue;
	}
}

species boundary {}
species building {}

species point_road{
	string shape_id;
	float shape_pt_lat;
	float shape_pt_lon;
	float shape_pt_sequence;	
	
	aspect default {
		draw shape + 10 color: #yellow;
	}	
}

species road {
	string shape_id;
	rgb color <- rnd_color(255);
	aspect default {
		draw shape  color: color;
	}	
}

species stop {
	string stop_id;
	float lat;
	float lon;
	
	aspect default {
		draw shape + 10 color: #red;
	}
}



experiment name type: gui {
	
	output {
		display "My display" { 
			species building;
			species stop;
			species road;
			species point_road;
			species bus;
		}
	}
}
