/// @description Insert description here
// You can write your code in this editor
//var zeroCount = 0;
if(global.debugMode == DebugMode.PERFORMANCE){
	shift_array(global.projectileTimeArray);
	shift_array(global.gridUpdateTimeArray);
	shift_array(global.gridVertexTimeArray);
	shift_array(global.trajectoryTimeArray);
	shift_array(global.drawTimeArray);
	if(!global.inBrowser)
		shift_array(global.sumTimeArray);
}
if(room==game_room && !global.inBrowser)
	window_mouse_set(window_get_width()/2,window_get_height()/2);