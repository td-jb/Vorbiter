/// @description Insert description here
// You can write your code in this editor
if(global.debugMode == DebugMode.PERFORMANCE){
	
	global.projectileTime = get_array_average(global.projectileTimeArray);
	global.gridUpdateTime = get_array_average(global.gridUpdateTimeArray)
	global.gridVertexTime = get_array_average(global.gridVertexTimeArray)
	global.trajectoryTime = get_array_average(global.trajectoryTimeArray)
	if(!global.Law.inBrowser){
		global.sumTimeArray = get_array_average(global.sumTimeArray)
	}
}