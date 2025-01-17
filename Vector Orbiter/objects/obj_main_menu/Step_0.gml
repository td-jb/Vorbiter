/// @description Insert description here
// You can write your code in this editor
if(!global.show_ui || global.intro){
	return;	
}
selected_button = -1;
curs_x = window_mouse_get_x() * view_wport[0]/window_get_width();
curs_y = window_mouse_get_y() * view_hport[0]/window_get_height();
switch(menu_screen){
	case MenuScreen.MAIN:
		for(var i = 0; i < array_length(buttons); i++){
			var x_pos = button_offset_x;
			var y_pos = button_offset_y + (button_height + button_margin) * i;
			if(curs_x >x_pos && curs_x < x_pos + button_width && curs_y > y_pos && curs_y < y_pos + button_height){
				selected_button = i;	
			}
	
		}
		break;
	case MenuScreen.SCORES:
		for(var i = 0; i < array_length(scoreButtons); i++){
			var x_pos = (view_wport[0]/2)- (3*button_width/2) + i * button_width;
			var y_pos = score_box_y + score_box_h + button_margin;
			if(curs_x >x_pos && curs_x < x_pos + button_width && curs_y > y_pos && curs_y < y_pos + button_height){
				selected_button = i;	
			}
	
		}
}
if(selected_button >=0){
	if(mouse_check_button_released(mb_left)){
	switch(menu_screen){
		case MenuScreen.MAIN:
			buttonscripts[selected_button]();		
			break;
		case MenuScreen.SCORES:
			scoreButtonScripts[selected_button]();		
			break;
	}
	}


}