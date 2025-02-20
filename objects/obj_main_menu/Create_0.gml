/// @description Insert description here
// You can write your code in this editor
browser_input_capture(true);
buttons = ["Start"];
buttonscripts = [new_game];
scoreButtons = ["Previous Level", "Back", "Next Level"];
scoreButtonScripts = [previous_score, back_to_menu, next_score];
selectButtons = ["Previous Level", "Back", "Next Level"];
selectButtonScripts = [previous_score, back_to_menu, next_score];
if(global.score>0){
	array_push(buttons, "Continue");
	array_push(buttonscripts, continue_game);
	
}
if(global.playerData.highscores[0][0] != 0){
	array_push(buttons, "High Scores");
	array_push(buttonscripts, high_scores);
}
if(os_browser == browser_not_a_browser){
	room_width = window_get_width();
	room_height = window_get_height();
	
	array_push(buttons, "Quit");	
	array_push(buttonscripts, quit_game);
}else{

}

display_set_gui_size(view_wport[0], view_hport[0]);
button_width = 250;
button_height = 40;
button_margin = 5;
selected_button = -1;
up_down = 0;
base_delay = 10;
delay = 0;
global.Input.cursorX =0;
global.Input.cursorY = 0;
button_offset_x = view_wport[0]/2-button_width/2;
button_offset_y = view_hport[0]/2- (button_height * array_length(buttons))/2;

window_set_cursor(cr_default);
window_mouse_set_locked(false);
sub_page = array_length( global.playerData.highscores)-1;
menu_screen = MenuScreen.MAIN;

score_box_w = view_wport[0]/3;
score_box_x = view_wport[0]/3;
score_box_h = view_hport[0]/2;
score_box_y = view_hport[0]/4;