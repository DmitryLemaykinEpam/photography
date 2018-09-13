# Photography 

This is a test task application which manage locations presented a Map.

Assumptions about how users will interact with the app:

1) App supports iPhone/iPod UI, with Portrait and Landscape orientations
  a) The minimal iOS version is 11.4

2) App starts with Map screen and default location set
  a) Default locations go alon with the app as a resorce
  b) The Map display Default and User created loactions

3) User can mange locations from Map screen
  a) Long tap gesture on Map will create a Custom location
  b) User can select presented location and Edit or Remove it by tap on apropriate option on Pop up
  c) Also user can move Selected location over map and new position will be persisted
  
5) All locations persisted between app launches
  a) Changes of location coordinates saved immediately 
  b) Location Name and Notes changes will be saved only after User press Save button
 
5) Map screen can display User location, the will request User for that permission
  a) In case User does not provide the permission, app will continue work, but distance to loactions will be presented as 0
  
6) The amout of stored locations considered below 1000 items
