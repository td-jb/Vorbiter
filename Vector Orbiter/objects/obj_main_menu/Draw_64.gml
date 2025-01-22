/// @description Insert description here
// You can write your code in this editor

if(global.intro){
	var introPerc = (current_time- global.startTime)/global.Law.introTimer;
	var alpha = 1;
	if(introPerc<0.25){
		alpha = introPerc*4;
	}
	if(introPerc > 0.9){
		
		alpha = 1-((introPerc-0.9) * 20)	
	}	
	var spr_width = sprite_get_width(logo_sketch);
	var spr_height = sprite_get_height(logo_sketch);
	var spr_scale = 0.6* (display_get_gui_height()/spr_height);
	var true_width = spr_scale * spr_width;
	draw_sprite_ext(logo_sketch,0,view_wport[0]/2 - true_width/2, view_hport[0]/2 - (spr_height * spr_scale)/2,spr_scale,spr_scale,0,c_white,alpha);
	return;	
}
if(global.debugMode< DebugMode.NONE)
draw_text(cursor_x, cursor_y, "x: " + string(cursor_x) + "\ny: " + string(cursor_y));


if(!global.show_ui)
	return;
switch(menu_screen){
	case MenuScreen.MAIN:
		for(var i = 0; i < array_length(buttons); i++){
			var x_pos = button_offset_x;
			var y_pos = button_offset_y + (button_height + button_margin) * i;
	
				draw_set_color(c_gray)
			if(selected_button == i){
				draw_set_alpha(0.4)
			}else{
				draw_set_alpha(0.2)
			}
			draw_roundrect(x_pos, y_pos, x_pos + button_width, y_pos + button_height, false);
			draw_set_color(c_lime);
			var text = buttons[i];
			var text_width = string_width(buttons[i]);
			var text_height = string_height(buttons[i]);
				draw_set_alpha(1)
			draw_text(x_pos +  button_width/2 - text_width/2, y_pos + button_height/2 - text_height/2, buttons[i]);
	
	
		}
		draw_set_color(c_white);
		if(global.highScore > 0 ){
			var hsString = "High Score: " + num_separator(global.highScore,",");
			var swidth = string_width(hsString);
			draw_text(view_wport[0] - button_margin - swidth,button_margin,hsString);	
	
		}
		break;
	case MenuScreen.SCORES:

		var scoreText  = "";
		if(sub_page == array_length(global.levels.array)){
			scoreText = "Game High Scores";
				
		}else{
			scoreText = "Level " + string(sub_page + 1) + " High Scores";
			
		}
		for(var i = 0; i < array_length(global.playerData.highscores[sub_page]); i++){
		
				scoreText += "\n";
			scoreText += string(i+1) +") " + string( num_separator(global.playerData.highscores[sub_page][i],","));
		
		}
		draw_set_color(c_black);
		draw_set_alpha(0.4);
		draw_rectangle(score_box_x, score_box_y,score_box_x+score_box_w, score_box_y + score_box_h, false);
		
		draw_set_color(c_white);
		draw_set_alpha(1);
		draw_text(score_box_x + button_margin,score_box_y + button_margin, scoreText);
		for(var i = 0; i < array_length(scoreButtons); i++){
			var x_pos = (view_wport[0]/2)- (3*button_width/2) + i * button_width;
			var y_pos = score_box_y + score_box_h + button_margin;
	
			draw_set_color(c_gray)
			if(selected_button == i){
				draw_set_alpha(0.4)
			}else{
				draw_set_alpha(0.2)
			}
			draw_roundrect(x_pos, y_pos, x_pos + button_width, y_pos + button_height, false);
			draw_set_color(c_lime);
			var text = scoreButtons[i];
			var text_width = string_width(scoreButtons[i]);
			var text_height = string_height(scoreButtons[i]);
				draw_set_alpha(1)
			draw_text(x_pos +  button_width/2 - text_width/2, y_pos + button_height/2 - text_height/2, scoreButtons[i]);
	
	
		}
}