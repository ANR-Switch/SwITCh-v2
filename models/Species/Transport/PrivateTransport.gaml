/**
* Name: PrivateTransport
* Based on the internal empty template. 
* Author: Lo�c
* Tags: 
*/
model SwITCh

import "../Individual/Individual.gaml"

import "Transport.gaml"
species PrivateTransport parent: Transport virtual:true{
	
	action end (date arrived_time) virtual: true;
	
	aspect default {
		draw square(1 #px) color: #green border: #black;
	}

}

