/**
* Name: Event_Manager
* Event manager used by many species.
* Author: Jean-François Erdelyi 
* Tags: 
*/
model SwITCh

/** 
 * Event manager species
 */
species EventManager control: event_manager {
	// "Past" must be allowed in order to remove some issues about time traveling. 
	// In fact, if the action is scheduled in the past, the action is directly executed.
	// 
	// So if the timestep is 10min for example, but the travel time is 1min
	// The effective date is 10min + 1min and it's not correct
	// We must execute everything inside these 10 minutes.
	// Travel time	 	       1m       2m      1m               5m
	// 					Start|-----|----------|-----|--------------------/-------|End
	// Step                                 10m					(Event scheduled)
	// 					     |-------------------------------------------|---------------->
	bool allow_past <- true;
	
	// Use the smart method
	bool naive <- false;
}
