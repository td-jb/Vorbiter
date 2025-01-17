/// @description Insert description here
// You can write your code in this editor
if(global.component_saturation == 255){
	global.component_saturation = 128;	
	
}else if(global.component_saturation == 128){
	global.component_saturation = 0;	
	
}else{
	
	
	global.component_saturation = 255;	
}
reset_colors();