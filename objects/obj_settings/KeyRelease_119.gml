/// @description Insert description here
// You can write your code in this editor
if(global.Settings.colorSaturation.value == 255){
	global.Settings.colorSaturation.value = 128;	
	
}else if(global.Settings.colorSaturation.value == 128){
	global.Settings.colorSaturation.value = 0;	
	
}else{
	
	
	global.Settings.colorSaturation.value = 255;	
}
reset_colors();