/// @description Insert description here
// You can write your code in this editor

if(global.inBrowser && window_mouse_get_locked()){
	
	window_mouse_set_locked(false);
	window_set_cursor(cr_default)
	return;
}
if((global.projectileCount>0 )&& !reset){

	trigger_reset();
}else{
	if(room == game_room){
		if(!reset){
			audio_stop_sound(endSound);
			room_goto_previous();
		}
	}
}