/// @description Insert description here
// You can write your code in this editor
global.fullGrid = !global.fullGrid;
if(!global.fullGrid){
	
	trigger_grid_update();
	
}else{
	fill_grid_buffer(true);
}