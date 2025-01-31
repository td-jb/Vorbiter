/// @description Insert description here
// You can write your code in this editor
if(global.intro || !global.show_ui)
	return;
var screenMidX = display_get_gui_width()/2;
var screenMidY= display_get_gui_height()/2;

var levelName =  "Sector " +string( global.currentLevel+ 1);
var stringWidth = string_width(levelName);
var stringHeight = string_height(levelName);
if(!window_has_focus()){
	audio_set_master_gain(0, 0);

	draw_text(screenMidX - stringWidth/2, screenMidY-stringHeight/2, "PAUSED");
}
draw_set_color(c_white);

if(postGame){
	if(global.currentLevel >0)
		levelName = string(global.currentLevel) + " - " +global.levels.array[global.currentLevel-1].name;
	else
		levelName = string(array_length(global.levels.array)) + " - " +global.levels.array[array_length(global.levels.array)-1].name;
	var scoreText = levelName +"\nProjectiles Fired: " + string(global.projectileCount)+ "\nLevel Score: " + string(num_separator(global.Game.levelScore,",")) +"\nTotal Score: " + string(num_separator(global.score, ",")) + "\nClick to continue";
	 stringWidth = string_width(scoreText);
	 stringHeight = string_height(scoreText);
	draw_text(screenMidX - stringWidth/2, screenMidY- stringHeight/2, scoreText);
	
}else{
	draw_text(screenMidX - stringWidth/2, stringHeight/2, levelName);
}
if(instance_exists(obj_main_menu))
	return;

var bottom_right_x = display_get_gui_width() -textMargin;
var bottom_right_y = display_get_gui_height()-textMargin;

var timePercentage = (current_time%2000)/2000
timePercentage = clamp(timePercentage, 0, 1);
var prompt_width = sprite_get_width(spr_back) * sprite_scale;

if(!global.editMode){
	#region esc prompt
		draw_sprite_ext(escape_sprite,0, bottom_right_x - row_width,bottom_right_y - row_height,sprite_scale,sprite_scale, 0,c_white, 1);
			if(!instance_exists(obj_game) || (global.liveProjectiles ==0 && global.Game.levelScore == 0)){
			draw_sprite_ext(spr_back, 0 ,bottom_right_x - row_width * 0.5, bottom_right_y - row_height, sprite_scale, sprite_scale, 0, c_white, 1);
		}else{
		
			draw_sprite_ext(spr_refresh, 0 ,bottom_right_x - row_width * 0.5, bottom_right_y - row_height, sprite_scale, sprite_scale, 0, c_white, 1);
	
		}

	#endregion

	#region rmb prompt
		var alpha = 1/timePercentage;
		draw_sprite_ext(right_click_sprite,0, bottom_right_x - row_width,bottom_right_y - row_height * 2,sprite_scale,sprite_scale, 0,c_white, 1);
		for(var i = 0; i < 5; i++){
			var x_vector = sin( random_range(0,2*pi))*row_height/2;
			var y_vector = cos(random_range(0,2*pi))* row_height/2;
			draw_set_color(global.projectileColor);
			draw_set_alpha(alpha);
			var _x = bottom_right_x - row_width * 0.33;
			var _y = bottom_right_y - row_height * 2 + row_height/2;
			draw_line_width(_x +(x_vector*timePercentage *0.9), _y +(y_vector *timePercentage *0.9), _x+ (x_vector * timePercentage), _y + (y_vector* timePercentage), 2);
		}
	#endregion

	#region lmb prompt

		draw_sprite_ext(left_click_sprite,0, bottom_right_x - row_width,bottom_right_y - row_height * 3,sprite_scale,sprite_scale, 0,c_white, 1);
		var _x = bottom_right_x - row_width * 0.25;
		var _y = bottom_right_y - row_height * 3 + row_height/2;
		draw_set_color(global.projectileColor);
		draw_circle(_x,_y,row_height/4,false);
		var _x2 = bottom_right_x - row_width * 0.5;
		var iteration_count = 100;
		for(var i = 0; i<iteration_count; i++){
			var perc1 = (1/iteration_count)*i;
			var perc2 = (1/iteration_count)*(i+1);
			draw_set_alpha(1-perc1);
			draw_line_width(lerp(_x,_x2, perc1), _y, lerp(_x,_x2, perc2),_y,row_height/2 * (1-perc1));	
		
		}
		draw_set_alpha(1);
	#endregion


	#region esc prompt

		draw_sprite_ext(scroll_sprite,0, bottom_right_x - row_width,bottom_right_y - row_height * 4,sprite_scale,sprite_scale, 0,c_white, 1);
		draw_sprite_ext(spr_zoom, 0 ,bottom_right_x - row_width * 0.5, bottom_right_y - row_height * 4, sprite_scale, sprite_scale, 0, c_white, 1);
	
	#endregion
	var completionPercentage = (obj_game.level.endpoint.r-obj_game.level.endpoint.tr);
	var compBoxWidth = display_get_gui_width()/4;
	var compBoxHeight = row_height/2;
	draw_set_alpha(0.3);
	draw_set_color(c_black);
	draw_rectangle(bottom_right_x - compBoxWidth - textMargin, textMargin, bottom_right_x - textMargin, textMargin + compBoxHeight, false);
	draw_set_color(global.goodColor);
	draw_rectangle(bottom_right_x - compBoxWidth - textMargin, textMargin, bottom_right_x - textMargin, textMargin + compBoxHeight, true);

	if(obj_game.level.endpoint.damage >0){
		completionPercentage = obj_game.level.endpoint.damage/completionPercentage;
		draw_rectangle(bottom_right_x - compBoxWidth - textMargin, textMargin, bottom_right_x - textMargin - (compBoxWidth * (1-completionPercentage)), textMargin + compBoxHeight, false);
	
	}
	draw_set_alpha(1);
}