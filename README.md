# SwITCh-v2
New version of SwITCh simulation.

# Files
 - Models folder contains all models
 - Parameters folder contains all inputs data (json files)
    - Config.json: dataset location
    - Agendas.json: fake agendas
    - OSM road types.json: data about networks 
    - Building type per activity type.json: biding OSM building tags to SwITCh tags

# Coding conventions
 - Action and parameter
 ```gaml 
 action my_action(int my_param)
 ```
 - Attribute
 ```gaml
 float my_attribute
 ```
 - Reflex
 ```gaml
 reflex my_reflex
 ```
 - Species
 ```gaml
 species MySpecies
 ```
 - Model
 ```gaml
 model MyModel
 ```
 - Experiment
 ```gaml
 experiment "My experiment"
 ```
 - Display
 ```gaml
 display my_display
 ```
 - GAML folder
 ```
 MyFolder
 ```
  - GAML file
 ```
 MyFile.gaml
 ```
