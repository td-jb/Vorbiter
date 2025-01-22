/// @description Insert description here
// You can write your code in this editor
if(mouse_check_button_released(mb_any)|| ( global.intro&& current_time- global.startTime > global.Law.introTimer)){
	global.intro = false;	
	
}
if(!window_has_focus()){
	audio_set_master_gain(0, 0);
}else
	if(window_has_focus() && audio_get_master_gain(0) != global.masterVolume){
		audio_set_master_gain(0, global.masterVolume);
	
}