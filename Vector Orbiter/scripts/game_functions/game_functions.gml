// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function add_points(points){
	if(room != game_room)
		return;
	obj_game.levelScore += points;
	global.score += points;	
}

function trigger_reset(){
	obj_game.reset = true;
	obj_game.completeTime = current_time;
	obj_game.overtime = 0;
	obj_game.pulseFactor = 1;
	obj_game.liveProjectiles = 0;
	obj_game.projectileCount = 0;
	with(obj_projectile){
		instance_destroy();	
		
	}
}
function restart_level(){
	if(global.highScore == global.score){
		global.highScore -= obj_game.levelScore;
	}
	
	global.score -= obj_game.levelScore;
	audio_play_sound(Endplosion, 0, false,0.8);
	obj_game.levelScore = 0;
	obj_game.simShotCount = 0;
	obj_game.level.endpoint.damage = 0;
	with(obj_projectile){
		instance_destroy();
	}
	level_init(obj_game.level);
	
	obj_game.spiral_grid_updates= array_create(0);
	obj_game.grid_updates= array_create(0);
	trigger_grid_update();
	global.projectileCount = 0;
	global.liveProjectiles = 0;
	
}
function level_end_check(){
	if(!global.editMode){
		if(!levelComplete && (obj_game.level.endpoint.r - obj_game.level.endpoint.damage) <= obj_game.level.endpoint.tr){
			
			if(global.currentLevel + 1 < array_length(global.levels.array)){
				trigger_grid_update( global.levels.array[global.currentLevel + 1]);
			}
			pulseRate = 1;
			levelComplete = true;
			completeTime = current_time;
			mouse_click_start_x = mouse_click_start_y = -1;
			audio_play_sound(Victory,0,false, 0.8);
			audio_play_sound(Endplosion,0,false, 0.7);
			for(var i = 0; i < array_length(level.components); i++){
				
				reset_struct(level.components[i])
			}
	
			with(obj_projectile){
				color = c_lime;
				instance_destroy()
			}
			
		}
		if(levelComplete || reset){
			overtime = current_time - completeTime;
			return true;
		}
	}else{
		return false;	
	}
	return false;
}
function add_high_score(level_index, _score){
	
	if(_score > global.playerData.highscores[@level_index][9]){
		var scoreArray = global.playerData.highscores[@level_index];
		for(var i = array_length(scoreArray)-1; i>=0; i--){
			
			if(i == 0 && _score > scoreArray[@i]){
				if(level_index = array_length(global.levels.array))
					global.highScore = _score;
				array_insert(scoreArray,0,_score);
				array_delete(scoreArray, array_length(scoreArray)-1,1);
				return;
			}
			if(_score > scoreArray[@i])
				continue;
			array_insert(scoreArray, i + 1, _score);
			array_delete(scoreArray, array_length(scoreArray)-1,1);
			break;
		}
	}
	
}
function end_postgame(){
	if(global.currentLevel == 0){
	
		room_goto_previous();
		global.score = 0;
		global.projectileCount = 0;
		global.liveProjectiles = 0;	
		add_high_score(array_length(global.levels.array) -1, obj_game.levelScore);
	}else{
		add_high_score(global.currentLevel -1, obj_game.levelScore);
	}
	save_player_data();
	currX = 0;
	currY = 0;
	global.screenScale = 1;
	levelScore = 0;
	postGame = false;
	global.projectileCount = 0;
	global.liveProjectiles = 0;
	
	return;	
}
function level_end_update(){
	cosPulse = cos(pi * pulseFactor);
	if(levelComplete || reset){
		var otFactor = power((obj_game.overtime/15),2);
		cosPulse += otFactor;
	
		audio_sound_pitch(obj_game.endSound, obj_game.pulseRate);
		if(cosPulse + level.endpoint.r > room_width*3)
		{
			pulseRate = 1;
			if(!reset){
				change_level();
				if(room == game_room){
					postGame = true;	
				}
			}else{
				reset = false;	
				audio_sound_pitch(obj_game.endSound, obj_game.pulseRate);
				restart_level();
			}
			return;
		}
	}
}
function change_level(inc = 1){
	
	if(global.currentLevel + inc >= array_length(global.levels.array) || global.currentLevel + inc < 0){
		
		add_high_score(global.currentLevel +1, global.score);
		add_high_score(global.currentLevel, obj_game.levelScore);
		reset_struct(level.endpoint)
		global.currentLevel = 0;
		audio_stop_sound(endSound);
		audio_stop_sound(shootingSound);
			
		simShotCount = 0;
	}else{
		levelComplete = false; 
		reset_struct(level.endpoint)
		global.currentLevel += inc;
		level_init(global.levels.array[global.currentLevel]);
		obj_game.spiral_grid_updates= array_create(0);
		obj_game.grid_updates= array_create(0);
		trigger_grid_update(level)
		audio_sound_pitch(obj_game.endSound, obj_game.pulseRate);
		simShotCount = 0;
				
	}
}
function next_level(loop = true){
	if(loop && global.currentLevel + 1 >= array_length(global.levels.array)){
		global.currentLevel = 0;	
		change_level(0);
	}else{
		change_level(1);	
	}
	
	
}
function previous_level(loop = true){
	if(loop && global.currentLevel - 1 <0){
		global.currentLevel =  array_length(global.levels.array) - 1;	
		change_level(0);
	}else{
		change_level(-1);	
	}
}
function level_init(level_struct){
		
	struct_set(level_struct.start, "_id", 0);
	reset_struct(level_struct.start);
	struct_set(level_struct.endpoint, "_id", 1);
	reset_struct(level_struct.endpoint);
	for(var i = 0; i< array_length(level_struct.components); i++){
		struct_set(level_struct.components[@i],"_id",i+2);
		reset_struct(level_struct.components[@i]);
		
	}
	obj_game.level = level_struct;
	
}
function increment_game_timers(){
	if(stopTimer>0)
		stopTimer--;
	shotDelay = baseShotDelay + (baseShotDelay * (global.liveProjectiles + 1)/4);
	audio_sound_pitch(shootingSound,baseShotDelay/(shotDelay/2));
	pulseRate = ((level.endpoint.r)/(level.endpoint.r- level.endpoint.damage))
	pulseFactor = ((current_time-room_start)%(1000/(max(0.0001,pulseRate)) * global.simRate)/500);
	minScale = lerp(minScale, targetMinScale, 4/fps);
	room_frame++;
}
function set_cursor_type(){
	
//if(!window_has_focus()){
//	window_set_cursor(cr_default);
//}else if (room == game_room){
//	window_set_cursor(cr_none);	
//}
	
}
function set_cursor_delta(){
	
	if(!window_has_focus()){
		window_set_cursor(cr_default);
	}
	//else if (room == game_room){
	//	window_set_cursor(cr_none);	
	//}
	d_x = (window_mouse_get_x()- window_get_width()/2)* global.screenScale;
	d_y = (window_mouse_get_y() - window_get_height()/2)* global.screenScale;
	if(room==game_room && os_browser == browser_not_a_browser){
		window_mouse_set(window_get_width()/2,window_get_height()/2);
	}else if(room==game_room){
		d_x = window_mouse_get_delta_x() * global.screenScale;
		d_y = window_mouse_get_delta_y() * global.screenScale;
	}
	
}
function set_cursor_position(){
	
	cursor_x = clamp(cursor_x, -global.play_area_radius, global.play_area_radius);
	cursor_y = clamp(cursor_y, -global.play_area_radius, global.play_area_radius);
}
function register_previous_grid_details(){
	
	prev_grid_x_count = grid_x_count;
	prev_grid_y_count = grid_y_count;
	prev_grid_x_offset = grid_x_offset;
	prev_grid_y_offset = grid_y_offset;
	prev_grid_thickness = global.grid_thickness;
	
}
function get_projectile_damage(projectile){
	return floor(projectile.r/10);	
}
function add_damage(obj_struct, _damage_increment){
	if(struct_exists(obj_struct, "damage")){
		set_damage(obj_struct, obj_struct.damage + _damage_increment);
	}
	
}

function set_damage(obj_struct,_damage){
	if(struct_exists(obj_struct, "damage")){
		obj_struct.damage = _damage;
		//if(!struct_exists(obj_struct, "prevMass") || obj_struct.prevMass == 0){
		//	struct_set(obj_struct,"prevMass",obj.mass);	
		//}
		var prevMass = obj_struct.mass;
		obj_struct.dr = get_actual_radius(obj_struct);
		obj_struct.mass = get_component_mass(obj_struct);
		var sim_coords = world_coordinate_to_sim_grid_index(obj_struct.v2x, obj_struct.v2y);
		trigger_grid_update(obj_game.level, sim_coords[0],sim_coords[1],obj_struct.mass-prevMass);
		//trigger_grid_update();
	}
}
function reset_struct(obj_struct){
	if(struct_exists(obj_struct, "damage") && obj_struct.damage != 0)
		set_damage(obj_struct, 0);
	struct_set(obj_struct, "d_x", 0)
	struct_set(obj_struct, "d_y", 0)
	struct_set(obj_struct,"dr",get_actual_radius(obj_struct));
	struct_set(obj_struct,"mass", get_component_mass(obj_struct));
}
function get_struct_x_position(obj_struct){
	if(struct_exists(obj_struct, "d_x")){
		return obj_struct.v2x + obj_struct.d_x;	
	}
	return obj_struct.v2x;
}
function get_struct_y_position(obj_struct){
	
	if(struct_exists(obj_struct, "d_y")){
		return obj_struct.v2y + obj_struct.d_y;	
	}
	return obj_struct.v2y;
}
function create_projectile(_x, _y, _x_vel, _y_vel){
	var projectile = instance_create_layer(_x, _y,"Instances", obj_projectile);
	projectile.projectile = create_projectile_struct(_x, _y, _x_vel, _y_vel);
	global.projectileCount++;
	global.liveProjectiles++;
}
function create_projectile_struct(_x, _y, _x_vel, _y_vel){
	
	return {
		x_vel:_x_vel,
		y_vel:_y_vel,
		x_pos: _x,
		y_pos: _y,
		r: global.projectileRadius,
		mult: 1,
		frameMult: 0,
		color: color_get_hue( global.projectile_color),
		_id: global.projectileCount
	}
}
function process_user_inputs(){
	if(keyboard_check_released(vk_tab)&& os_browser == browser_not_a_browser){
		global.editMode = !global.editMode;
	}
	if(mouse_wheel_down()){
		targetMinScale = clamp(targetMinScale + scrollRate* global.screenScale, global.screenScale, maxScale);
		
	}else if(mouse_wheel_up()){
			
		targetMinScale = clamp(targetMinScale -  scrollRate* global.screenScale, 0.5, maxScale);
		
	}
	if(!global.editMode){
		if(keyboard_check(vk_control)){
			d_x = d_x/4;
			d_y = d_y/4;
			
		}
	}
	if(mouse_check_button_pressed(mb_left)){
		shooting = true;
		if(!global.editMode){
			mouse_click_start_x = get_struct_x_position(obj_game.level.start);
			mouse_click_start_y = get_struct_y_position(obj_game.level.start);	
			audio_sound_gain(shootingSound,.7,30);
		}
		else{
			if(power(get_struct_x_position(obj_game.level.start) - cursor_x, 2) + power(get_struct_y_position(obj_game.level.start) - cursor_y, 2) < power(level.start.r,2)){
				editor_selected_object = level.start;
			
			}else if(power(level.endpoint.v2x - cursor_x, 2) + power(level.endpoint.v2y - cursor_y, 2) < power(level.endpoint.r,2)){
				editor_selected_object = level.endpoint;
		
			}
			else{
				for(var i = 0; i < array_length(level.components); i++){
					if(	power(level.components[i].v2x - cursor_x, 2) + power(level.components[i].v2y - cursor_y, 2) < power(level.components[i].r,2)){
						editor_selected_object = level.components[i]
					}
				}
				if(editor_selected_object == noone && keyboard_check(vk_alt)){
					editor_selected_object =  add_component_to_level(cursor_x, cursor_y, 10);
				}
				if(editor_selected_object == noone && keyboard_check(vk_shift)){
					editor_selected_object = infinity;
				}
			}
			if(is_struct( editor_selected_object)){
				mouse_click_start_x = editor_selected_object.v2x;
				mouse_click_start_y = editor_selected_object.v2y;
			}else{
					
				mouse_click_start_x = cursor_x;
				mouse_click_start_y = cursor_y;
			}
		}
		launch_vector_x = cursor_x - mouse_click_start_x;
		launch_vector_y = cursor_y - mouse_click_start_y;
		last_mouse_x = window_mouse_get_x();
		last_mouse_y = window_mouse_get_y();
	}
	if(mouse_check_button(mb_right) && current_time - lastShot > baseShotDelay){
		with(obj_projectile){
			if(obj_game.min_projectile == noone || projectile._id < obj_game.min_projectile.projectile._id){
				obj_game.min_projectile = id;
			}
		}
		if(min_projectile != noone){
			instance_destroy(min_projectile);
			min_projectile = noone;
			lastShot = current_time;
		}
		stopTimer = fps/2;
	}
	if(mouse_check_button_pressed(mb_right)){
		if(editor_selected_object != noone){
			editor_selected_object = noone;
		}
	}
	if(global.editMode){
	if(keyboard_check_released(vk_delete)){
		if(editor_selected_object != noone  && editor_selected_object._id > 1){
			remove_component_from_level(editor_selected_object);
			editor_selected_object = noone;
		}
	}
		if(keyboard_check_released(vk_pageup)){
			next_level(true);
		}
		if(keyboard_check_released(vk_pagedown)){
			previous_level(true);	
		}
	}
	if(keyboard_check_released(vk_subtract)){
		global.simRate = -global.simRate;
		with(obj_projectile){
			//x_vel = - x_vel;
			//y_vel = - y_vel;
		
		}
	}
	var dispRatio = room_height/view_hport[0];

	if(shooting){
		launch_vector_x += d_x;
		launch_vector_y += d_y;
		cursor_x = mouse_click_start_x + launch_vector_x;
		cursor_y = mouse_click_start_y + launch_vector_y;
		last_mouse_x = window_mouse_get_x();
		last_mouse_y = window_mouse_get_y();
		if(!global.editMode){
			simulate_trajectory(get_struct_x_position(level.start), get_struct_y_position(level.start), launch_vector_x, launch_vector_y,shot_preview_x, shot_preview_y, shot_preview_r, shot_preview_mult);
			
			if window_mouse_get_x() < 2 || window_mouse_get_x() > window_get_width()-2 || window_mouse_get_y() < 2 || window_mouse_get_y() > window_get_height()-2 {
			    mouseInWindow = false;
				show_debug_message("dispRatio: " + string(dispRatio)+" mouse_x: " + string(mouse_x) +  " mouse_y: " + string(mouse_y) );
						window_mouse_set_locked(false);	
			} else {
			    mouseInWindow = true;
			}
		}
		if(mouse_check_button(mb_any)){
			if(!window_mouse_get_locked()){
				window_mouse_set_locked(true);	
				
				if(mouse_check_button(mb_left)){
					mouse_clear(mb_left);	
				}
				if(mouse_check_button(mb_right)){
					mouse_clear(mb_right);	
				}
				if(mouse_check_button(mb_right)){
					mouse_clear(mb_right);	
				}
			}
		
		}
		if(mouse_check_button(mb_left)){
			if(!global.editMode){
				if(current_time > lastShot+shotDelay){
					lastShot = current_time;
					create_projectile(get_struct_x_position(obj_game.level.start), get_struct_y_position(obj_game.level.start),launch_vector_x, launch_vector_y);
					
					//show_debug_message("shot launched\nX: " + string(level.start.v2x) + "\nY: " + string(level.start.v2y) + "\nVelocity: " + string(launch_vector_x) +", " + string(launch_vector_y));
				}
			}
			else{
				if(editor_selected_object == infinity){
					level.start.v2x += d_x;
					level.start.v2y += d_y;
					level.endpoint.v2x += d_x;
					level.endpoint.v2y += d_y;
					for(var i = 0; i <array_length(level.components); i++){
						level.components[i].v2x += d_x;
						level.components[i].v2y += d_y;
						
					}
				}else if(is_struct(editor_selected_object)){
					
					if(editor_selected_object._id > 0 && keyboard_check(vk_control)){
						if(editor_selected_object._id == 1 && keyboard_check(vk_shift)){
							editor_selected_object.tr = sqrt((power(launch_vector_x,2) + power(launch_vector_y,2)));;
						}else{
							editor_selected_object.r =sqrt((power(launch_vector_x,2) + power(launch_vector_y,2)));
						}
					}else{
						editor_selected_object.v2x = cursor_x;	
						editor_selected_object.v2y = cursor_y;
					}
				}
				//if(editor_selected_object >= 0){
					
				//	if(keyboard_check_pressed(vk_control)){
				//		level.start.r =sqrt((power(launch_vector_x,2) + power(launch_vector_y,2)));
				//	}else{
				//		level.start.v2x = cursor_x;	
				//		level.start.v2y = cursor_y;
				//	}
				//}else if (editor_selected_object ==1){
				//	if(keyboard_check_pressed(vk_control)){
				//		level.endpoint.r =sqrt((power(launch_vector_x,2) + power(launch_vector_y,2)));
				//	}else{
				//		level.endpoint.v2x = cursor_x;	
				//		level.endpoint.v2y = cursor_y;
				//	}
				//}else if(editor_selected_object >1){
				//	if(keyboard_check_pressed(vk_control)){
				//		level.components[editor_selected_object - 2].r = sqrt((power(launch_vector_x,2) + power(launch_vector_y,2)));
				//	}else{
				//		level.components[editor_selected_object - 2].v2x = cursor_x;
				//		level.components[editor_selected_object - 2].v2y = cursor_y;
				//	}
				//}
			}
		}else{
			shooting = false;
			if(global.editMode){
				editor_selected_object = noone;	
				trigger_grid_update();
			}
		}
		if((!mouseInWindow && global.inBrowser) || !mouse_check_button(mb_left)){
			audio_sound_gain(shootingSound,0,1000);
			shooting = false;
		}
	}else if(abs(d_x) >0.1 || abs(d_y) > 0.1){
		if(window_mouse_get_locked() 
		//&& (!os_type == os_android && os_type != os_ios)
		){
			cursor_x += d_x;
			cursor_y += d_y;
		}else{
			cursor_x = mouse_x;
			cursor_y = mouse_y;
		}
		launch_vector_x = cursor_x - get_struct_x_position(obj_game.level.start);
		launch_vector_y = cursor_y - get_struct_y_position(obj_game.level.start);
		last_mouse_x = window_mouse_get_x();
		last_mouse_y = window_mouse_get_y();
		if(!global.editMode){
			simulate_trajectory(get_struct_x_position(obj_game.level.start), get_struct_y_position(obj_game.level.start), launch_vector_x, launch_vector_y,shot_preview_x, shot_preview_y, shot_preview_r, shot_preview_mult);
		}
	}
}