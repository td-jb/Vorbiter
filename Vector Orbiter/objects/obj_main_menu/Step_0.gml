/// @description Insert description here
// You can write your code in this editor
if(!global.show_ui || global.intro){
	return;	
}
if(!global.Input.controllerMode){
	selected_button = -1;
	if(window_get_cursor() == cr_none)
		window_set_cursor(cr_default);
	global.Input.cursorX = window_mouse_get_x() * view_wport[0]/window_get_width();
	global.Input.cursorY = window_mouse_get_y() * view_hport[0]/window_get_height();
}else{
	window_set_cursor(cr_none);
	up_down = 0;
}
	if(delay >0)
		delay--;
switch(menu_screen){
	case MenuScreen.MAIN:
		if(!global.Input.controllerMode){
			for(var i = 0; i < array_length(buttons); i++){
				var x_pos = button_offset_x;
				var y_pos = button_offset_y + (button_height + button_margin) * i;
		
					if(global.Input.cursorX >x_pos && global.Input.cursorX < x_pos + button_width && global.Input.cursorY > y_pos && global.Input.cursorY < y_pos + button_height){
						selected_button = i;	
					}
			
	
			}
		}else if(delay <= 0){
			up_down = (input_check("down") - input_check("up"));
			selected_button = (selected_button + up_down )% array_length(buttons);
			delay = base_delay;
			
		}
		break;
	case MenuScreen.SCORES:
		for(var i = 0; i < array_length(scoreButtons); i++){
			var x_pos = (view_wport[0]/2)- (3*button_width/2) + i * button_width;
			var y_pos = score_box_y + score_box_h + button_margin;
			if(global.Input.cursorX >x_pos && global.Input.cursorX < x_pos + button_width && global.Input.cursorY > y_pos && global.Input.cursorY < y_pos + button_height){
				selected_button = i;	
			}
	
		}
		break;
	case MenuScreen.SELECT:
		for(var i = 0; i < array_length(scoreButtons); i++){
			var x_pos = (view_wport[0]/2)- (3*button_width/2) + i * button_width;
			var y_pos = score_box_y + score_box_h + button_margin;
			if(global.Input.cursorX >x_pos && global.Input.cursorX < x_pos + button_width && global.Input.cursorY > y_pos && global.Input.cursorY < y_pos + button_height){
				selected_button = i;	
			}
	
		}
		break;	
	case MenuScreen.SETTINGS:
		for(var i = 0; i < array_length(scoreButtons); i++){
			var x_pos = (view_wport[0]/2)- (3*button_width/2) + i * button_width;
			var y_pos = score_box_y + score_box_h + button_margin;
			if(global.Input.cursorX >x_pos && global.Input.cursorX < x_pos + button_width && global.Input.cursorY > y_pos && global.Input.cursorY < y_pos + button_height){
				selected_button = i;	
			}
	
		}
		break;
}
if(selected_button >=0){
	if(input_check("shoot") || input_check("action") || input_check("accept")){
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