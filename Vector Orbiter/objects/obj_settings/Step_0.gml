/// @description Insert description here
// You can write your code in this editor
if(input_any_pressed()|| ( global.intro&& current_time- global.startTime > global.Law.introTimer)){
	global.intro = false;	
	
}
if(!window_has_focus()){
	audio_set_master_gain(0, 0);
}else
	if(window_has_focus() && audio_get_master_gain(0) != global.masterVolume){
		audio_set_master_gain(0, global.masterVolume);
	
}
if(input_source_using(INPUT_GAMEPAD)){
	global.Input.controllerMode = true;	
	
}else if(keyboard_check(vk_anykey) ||  abs(window_mouse_get_delta_x()) <0.1 && abs(window_mouse_get_delta_y()) <0.1) {
	
	global.Input.controllerMode = false;	
	
}