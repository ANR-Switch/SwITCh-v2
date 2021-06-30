/**
* Name: Context
* Based on the internal empty template. 
* Author: alice
* Tags: 
*/


model SWITCH
import "../Building.gaml"

species Context {
	string meteo;
	Building current_location;
	Building target;
	//Mental state
	mental_state ms;
	
	action set_meteo (string m){
		meteo<-m;
	}
	action set_current_location (Building b){
		current_location<-b;
	}
	
	action set_target (Building b){
		target<-b;
	}
	
	action set_mental_state(mental_state m_s) {
		ms <- m_s;
	}
	
	action init(string m, Building b, Building t){
		do set_meteo(m);
		do set_current_location(b);
		do set_target(t);
	}
	
	action print{
		write "meteo : "+ meteo + ", localisation : " + current_location + ", Target : " + target;
	}
	
	//à changer car le ms pourrait être legerement différents sur des choses qui n'ont rien à voir ?
	bool is_the_same(Context c){
		if(c.meteo = meteo and c.current_location = current_location and c.target = target and c.ms = ms ){
			return true;
		}
		else {
			return false;
		}
		
	}
}


/* Insert your model definition here */

