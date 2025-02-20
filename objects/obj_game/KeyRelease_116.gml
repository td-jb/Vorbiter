/// @description Insert description here
// You can write your code in this editor
global.Settings.fullGrid.value = !global.Settings.fullGrid.value;
if(!global.Settings.fullGrid.value){
	
	trigger_grid_update();
	
}else{
	fill_grid_buffer(true);
}