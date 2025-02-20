// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function new_game(){
	restart_level();
	room_goto(game_room);
	global.currentLevel = 0;
	if(global.currentLevel == 0)
		global.score = 0;
}
function continue_game(){
	restart_level();
	room_goto(game_room);
}
function high_scores(){
	obj_main_menu.menu_screen = MenuScreen.SCORES;
	
}
function back_to_menu(){
	obj_main_menu.menu_screen = MenuScreen.MAIN;
	
}
function previous_score(){
	if(obj_main_menu.sub_page >0)
		obj_main_menu.sub_page--;
	else
		obj_main_menu.sub_page = array_length(global.playerData.highscores)-1;
}
function next_score(){
	
	obj_main_menu.sub_page++;
	obj_main_menu.sub_page = obj_main_menu.sub_page%array_length(global.playerData.highscores)
	
}
function quit_game(){
		
	game_end();
}