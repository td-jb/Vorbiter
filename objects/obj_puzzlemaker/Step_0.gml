/// @description Insert description here
// You can write your code in this editor
if(cursor_collision_check(x,y,x+sprite_width, y+sprite_width)){
	window_set_cursor(cr_handpoint);
	if(mouse_check_button_released(mb_left)){
		url_open("https://store.steampowered.com/app/2464950/The_Puzzle_Maker_Cebbas_Odyssey/");
	}
	
}else{
	window_set_cursor(cr_default);
	
}	