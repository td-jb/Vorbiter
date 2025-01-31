// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function update_trajectory_preview(){
	show_debug_message("Update trajectory preview drawn at frame: " + string(global.Game.roomFrame));
	simulate_trajectory(get_struct_x_position(obj_game.level.start), 
						get_struct_y_position(obj_game.level.start), 
						global.Input.launch_x, 
						global.Input.launch_y,
						obj_game.shot_preview_x,
						obj_game.shot_preview_y,
						obj_game.shot_preview_r,
						obj_game.shot_preview_mult);
}
function add_points(points){
	if(instance_exists(obj_main_menu))
		return;
	global.Game.levelScore += points;
	global.score += points;	
}

function trigger_reset(){
	global.Game.reset = true;
	global.Game.completeTime = global.Game.roomFrame;
	global.Game.overtime = 0;
	global.Game.pulseFactor = 1;
	global.liveProjectiles = 0;
	global.projectileCount = 0;
	with(obj_projectile){
		instance_destroy();	
		
	}
}
function restart_level(){
	if(global.highScore == global.score){
		global.highScore -= global.Game.levelScore;
	}
	
	global.score -= global.Game.levelScore;
	audio_play_sound(Endplosion, 0, false,0.8);
	global.Game.levelScore = 0;
	global.Game.simShotCount = 0;
	obj_game.level.endpoint.damage = 0;
	with(obj_projectile){
		instance_destroy();
	}
	level_init(obj_game.level);
	obj_game.spiral_grid_updates= array_create(0);
	obj_game.grid_updates= array_create(0);
	obj_game.last_shot_position = array_create(2, infinity);
	global.Input.shooting = false;
	global.Game.lastShot = 0;
	trigger_grid_update();
	global.projectileCount = 0;
	global.liveProjectiles = 0;
	
}
function level_end_check(){
	if(!global.editMode){
		if(!global.Game.levelComplete && (obj_game.level.endpoint.r - obj_game.level.endpoint.damage) <= obj_game.level.endpoint.tr){
			
			if(global.currentLevel + 1 < array_length(global.levels.array)){
				trigger_grid_update( global.levels.array[global.currentLevel + 1]);
			}
			global.Game.pulseRate = 1;
			global.Game.levelComplete = true;
			global.Game.completeTime = global.Game.roomFrame;
			global.Input.mouse_click_start_x = global.Input.mouse_click_start_y = -1;
			audio_play_sound(Victory,0,false, 0.8);
			audio_play_sound(Endplosion,0,false, 0.7);
			audio_sound_gain(shootingSound,0,1000);
			last_shot_position = array_create(2, infinity);
			global.Input.shooting= false;
			//total_multiplier =0;
			for(var i = 0; i < array_length(level.components); i++){
				
				reset_struct(level.components[i])
			}
	
			with(obj_projectile){
				color = c_lime;
				instance_destroy()
			}
			
		}
		if(global.Game.levelComplete || global.Game.reset){
			global.Game.overtime++;
			return true;
		}
	}else{
		return false;	
	}
	return false;
}
function level_end_update(){
	global.Game.cosPulse = cos(pi * global.Game.pulseFactor);
	if(global.Game.levelComplete || global.Game.reset){
		var otFactor = power((global.Game.overtime),2);
		global.Game.cosPulse += otFactor;
		audio_emitter_pitch(obj_game.endEmitter, global.Game.pulseRate);
		if(global.Game.cosPulse + level.endpoint.r > room_width*3)
		{
			global.Game.pulseRate = 1;
			if(!global.Game.reset){
				change_level();
				if(!instance_exists(obj_main_menu)){
					postGame = true;	
				}
			}else{
				global.Game.reset = false;	
				audio_emitter_pitch(obj_game.endEmitter, global.Game.pulseRate);
				restart_level();
			}
			return;
		}
	}
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
		add_high_score(array_length(global.levels.array) -1, global.Game.levelScore);
	}else{
		add_high_score(global.currentLevel -1, global.Game.levelScore);
	}
	save_player_data();
	global.Graphics.currX = 0;
	global.Graphics.currY = 0;
	global.Graphics.screenScale = 1;
	global.Game.levelScore = 0;
	postGame = false;
	global.Game.roomFrame = 0;
	global.Game.lastShot = 0;
	global.Game.overtime = 0;
	global.Game.completeTime = 0;
	global.projectileCount = 0;
	global.liveProjectiles = 0;
	
	return;	
}

function change_level(inc = 1){
	
	if(global.currentLevel + inc >= array_length(global.levels.array) || global.currentLevel + inc < 0){
		
		add_high_score(global.currentLevel +1, global.score);
		add_high_score(global.currentLevel, global.Game.levelScore);
		reset_struct(level.endpoint)
		global.currentLevel = 0;
		audio_stop_sound(endSound);
		audio_stop_sound(shootingSound);
			
		global.Game.simShotCount = 0;
	}else{
		global.Game.levelComplete = false; 
		reset_struct(level.endpoint)
		global.currentLevel += inc;
		level_init(global.levels.array[global.currentLevel]);
		obj_game.spiral_grid_updates= array_create(0);
		obj_game.grid_updates= array_create(0);
		trigger_grid_update(level)
		audio_emitter_pitch(obj_game.endEmitter, global.Game.pulseRate);
		global.Game.simShotCount = 0;
				
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
	global.Input.cursorX = camera_get_view_x(global.camera) +  camera_get_view_width(global.camera)/2
	global.Input.cursorY = camera_get_view_y(global.camera) +  camera_get_view_height(global.camera)/2
	obj_game.last_shot_position = array_create(2, infinity);
	
}
function increment_game_timers(){
	if(global.Graphics.stopTimer>0)
		global.Graphics.stopTimer--;
	global.Game.shotDelay = global.Law.baseShotDelay + (global.Law.baseShotDelay * (global.liveProjectiles + 1)/4);
	var dam_perc =(level.endpoint.damage )/(level.endpoint.r-level.endpoint.tr);
	global.Game.pulseRate = lerp(1,.5,dam_perc)	
	audio_sound_pitch(shootingSound,global.Game.pulseRate);
	if(obj_game.total_multiplier > 50){
		audio_sound_gain(multSound0, 0, 0 );
		audio_sound_gain(multSound, clamp(power(obj_game.total_multiplier,2)/200,0,.8),0)
	}else{
		audio_sound_gain(multSound0, clamp(power(obj_game.total_multiplier,2)/200,0,.8),0)
		audio_sound_gain(multSound, 0, 0 );
	
	}
	global.Game.pulseFactor = ((global.Game.roomFrame)%(global.Law.physRate/global.Game.pulseRate) * global.simRate)/(30);
	global.Graphics.minScale = lerp(global.Graphics.minScale, global.Graphics.targetMinScale, 4/fps);
	global.Game.roomFrame++;
}
function wipe_maximums(){
	global.maxTrajectoryTime = 0
	global.maxDrawTime = 0;
	global.maxGridUpdateTime = 0;
	global.maxProjectileTime =0
	global.maxSumTime = 0;
	global.maxVertexTime = 0;
	
}

function register_previous_grid_details(){
	
	global.Graphics.prev_grid_count_x = global.Graphics.gridCountX;
	global.Graphics.prev_grid_count_y = global.Graphics.gridCountY;
	global.Graphics.prev_grid_offset_x = global.Graphics.gridOffsetX;
	global.Graphics.prev_grid_offset_y = global.Graphics.gridOffsetY;
	global.Graphics.prev_grid_thickness = global.Settings.gridThickness.value;
	
}
function get_projectile_damage(projectile){
	return floor(projectile.r/10);	
}
function add_damage(obj_struct, _damage_increment){
	if(struct_exists(obj_struct, "damage") && obj_struct.name != "square"){
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
		update_struct(obj_struct);
		var sim_coords = world_coordinate_to_sim_grid_coordinate(obj_struct.v2x, obj_struct.v2y);
		trigger_grid_update(obj_game.level, sim_coords[0],sim_coords[1],obj_struct.mass-prevMass);
		//trigger_grid_update();
	}
}
function update_struct(obj_struct){
	
	var prevMass = obj_struct.mass;
	obj_struct.dr = get_actual_radius(obj_struct);
	obj_struct.mass = get_component_mass(obj_struct);	
	
}
function reset_struct(obj_struct){
	if(struct_exists(obj_struct, "damage") && obj_struct.damage != 0)
		set_damage(obj_struct, 0);
	struct_set(obj_struct, "d_x", 0)
	struct_set(obj_struct, "d_y", 0)
	struct_set(obj_struct, "x_vel", 0)
	struct_set(obj_struct, "y_vel", 0)
	if(obj_struct.name != "square"){
		struct_set(obj_struct,"dr",get_actual_radius(obj_struct));
		struct_set(obj_struct,"mass", get_component_mass(obj_struct));
	}
}
function get_struct_x_position(obj_struct){
	if(struct_exists(obj_struct, "v2x")){
		if(struct_exists(obj_struct, "d_x")){
			return obj_struct.v2x + obj_struct.d_x;	
		}
		return obj_struct.v2x;
	}else if(struct_exists(obj_struct,"cursorX")){
			
		return obj_struct.cursorX;
	}else
	return 0;
	
}
function get_struct_y_position(obj_struct){
	
	if(struct_exists(obj_struct, "v2y")){
		if(struct_exists(obj_struct, "d_y")){
			return obj_struct.v2y + obj_struct.d_y;	
		}
		return obj_struct.v2y;
	}else if(struct_exists(obj_struct,"cursorY")){
			
		return obj_struct.cursorY;
	}else
	return 0;
}
function create_projectile(_x, _y, _x_vel, _y_vel){
	var projectile = instance_create_layer(_x, _y,"Instances", obj_projectile);
	var start_x = _x ;
	var start_y = _y ;
	projectile.x = start_x;
	projectile.y = start_y;
	projectile.projectile = create_projectile_struct(start_x, start_y, _x_vel, _y_vel);
	show_debug_message("projectile launched: " + json_stringify(projectile.projectile, true));
	obj_game.last_shot_position[0] = _x+_x_vel;
	obj_game.last_shot_position[1] = _y+_y_vel;
	global.projectileCount++;
	global.liveProjectiles++;
	audio_sound_gain(shootingSound,0.5,30);
}
function create_projectile_struct(_x, _y, _x_vel, _y_vel){
	var newProjectile =  {
		name: "projectile",
		x_vel:_x_vel,
		y_vel:_y_vel,
		v2x: _x,
		v2y: _y,
		r: global.Law.pRadius,
		mult: 1,
		frameMult: 0,
		color: color_get_hue( global.projectileColor),
		_id: global.projectileCount
	}
	return newProjectile;
}

function create_sim_projectile(_x, _y, _x_vel, _y_vel, _r, _mult){
	
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
	global.Input.d_x = (window_mouse_get_x()- window_get_width()/2)* global.Graphics.screenScale;
	global.Input.d_y = (window_mouse_get_y() - window_get_height()/2)* global.Graphics.screenScale;
	if(room==game_room && os_browser == browser_not_a_browser){
		window_mouse_set(window_get_width()/2,window_get_height()/2);
	}else if(room==game_room){
		global.Input.d_x = window_mouse_get_delta_x() * global.Graphics.screenScale;
		global.Input.d_y = window_mouse_get_delta_y() * global.Graphics.screenScale;
	}
	
}
function set_cursor_position(){
	
	global.Input.cursorX = clamp(global.Input.cursorX, -global.Law.playRadius, global.Law.playRadius);
	global.Input.cursorY = clamp(global.Input.cursorY, -global.Law.playRadius, global.Law.playRadius);
}
function process_user_inputs(){
	if(keyboard_check_released(vk_tab)&& os_browser == browser_not_a_browser){
		global.editMode = !global.editMode;
	}
	if(mouse_wheel_down()){
		global.Graphics.targetMinScale = clamp(global.Graphics.targetMinScale + global.Settings.scrollRate.value* global.Graphics.screenScale, global.Graphics.screenScale, global.Graphics.maxScale);
		
	}else if(mouse_wheel_up()){
			
	global.Graphics.targetMinScale = clamp(global.Graphics.targetMinScale -  global.Settings.scrollRate.value* global.Graphics.screenScale, 0.5, global.Graphics.maxScale);
		
	}
	if(!global.editMode){
		if(keyboard_check(vk_control)){
			global.Input.d_x = global.Input.d_x/(4*global.Graphics.screenScale);
			global.Input.d_y = global.Input.d_y/(4*global.Graphics.screenScale);
		}
		if(keyboard_check(vk_space)){
			global.Input.boost = true;
		}else if(global.Input.boost)
		{
			global.Input.boost = false;	
		}
		if(keyboard_check(vk_lalt)){
			global.Input.brake = true;
		}else if(global.Input.brake)
		{
			global.Input.brake = false;	
		}
		if(global.Game.roomFrame > global.Game.lastShot+global.Game.shotDelay && keyboard_check(vk_lshift)&& last_shot_position[0] != infinity){
			global.Input.cursorX = last_shot_position[0];
			global.Input.cursorY = last_shot_position[1];
			global.Input.shooting= true;
			global.Input.mouse_click_start_x = get_struct_x_position(obj_game.level.start);
			global.Input.mouse_click_start_y = get_struct_y_position(obj_game.level.start);
			global.Input.launch_x = global.Input.cursorX-global.Input.mouse_click_start_x;
			global.Input.launch_y = global.Input.cursorY-global.Input.mouse_click_start_y;
			create_projectile(global.Input.mouse_click_start_x, global.Input.mouse_click_start_y, global.Input.launch_x, global.Input.launch_y);
			//audio_sound_gain(shootingSound,1/(global.liveProjectiles+1),30);
			global.Game.lastShot = global.Game.roomFrame;
		}
	}
	if(mouse_check_button_pressed(mb_left)){
		global.Input.shooting= true;
		if(!global.editMode){
			global.Input.mouse_click_start_x = get_struct_x_position(obj_game.level.start);
			global.Input.mouse_click_start_y = get_struct_y_position(obj_game.level.start);	
			//audio_sound_gain(shootingSound,1/(global.liveProjectiles+1),30);
		}
		else{
			if(power(get_struct_x_position(obj_game.level.start) - global.Input.cursorX, 2) + power(get_struct_y_position(obj_game.level.start) - global.Input.cursorY, 2) < power(level.start.r,2)){
				global.Game.editor_selected_object = level.start;
			
			}else if(power(level.endpoint.v2x - global.Input.cursorX, 2) + power(level.endpoint.v2y - global.Input.cursorY, 2) < power(level.endpoint.r,2)){
				global.Game.editor_selected_object = level.endpoint;
		
			}
			else{
				for(var i = 0; i < array_length(level.components); i++){
					if(	power(get_struct_x_position(level.components[i].v2x) - global.Input.cursorX, 2) + power(get_struct_y_position(level.components[i].v2y) - global.Input.cursorY, 2) < power(level.components[i].r,2)){
						global.Game.editor_selected_object = level.components[i]
					}
				}
				if(global.Game.editor_selected_object == noone && keyboard_check(vk_alt)){
					global.Game.editor_selected_object =  add_component_to_level(global.Input.cursorX, global.Input.cursorY, 10, "square");
				}
				if(global.Game.editor_selected_object == noone && keyboard_check(vk_shift)){
					global.Game.editor_selected_object = infinity;
				}
			}
			if(is_struct( global.Game.editor_selected_object)){
				global.Input.mouse_click_start_x = global.Game.editor_selected_object.v2x;
				global.Input.mouse_click_start_y = global.Game.editor_selected_object.v2y;
			}else{
					
				global.Input.mouse_click_start_x = global.Input.cursorX;
				global.Input.mouse_click_start_y = global.Input.cursorY;
			}
		}
		global.Input.launch_x = global.Input.cursorX - global.Input.mouse_click_start_x;
		global.Input.launch_y = global.Input.cursorY - global.Input.mouse_click_start_y;

	}
	if(mouse_check_button(mb_right) && global.Game.roomFrame - global.Game.lastShot > global.Law.baseShotDelay){
		with(obj_projectile){
			if(global.Graphics.minProjectile == noone || projectile._id < global.Graphics.minProjectile.projectile._id){
				global.Graphics.minProjectile = id;
			}
		}
		if(global.Graphics.minProjectile != noone){
			instance_destroy(global.Graphics.minProjectile);
			global.Graphics.minProjectile = noone;
			global.Game.lastShot = global.Game.roomFrame;
		}
		global.Graphics.stopTimer = fps/2;
	}
	if(mouse_check_button_pressed(mb_right)){
		if(global.Game.editor_selected_object != noone){
			global.Game.editor_selected_object = noone;
		}
	}
	if(global.editMode){
		if(keyboard_check_released(vk_delete)){
			if(global.Game.editor_selected_object != noone  && global.Game.editor_selected_object._id > 1){
				remove_component_from_level(global.Game.editor_selected_object);
				global.Game.editor_selected_object = noone;
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

	if(global.Input.shooting){
		if(abs(global.Input.d_x) + abs(global.Input.d_y) > 0){
			update_trajectory_preview();	
		}
		global.Input.launch_x += global.Input.d_x;
		global.Input.launch_y += global.Input.d_y;
		global.Input.cursorX = global.Input.mouse_click_start_x + global.Input.launch_x;
		global.Input.cursorY = global.Input.mouse_click_start_y + global.Input.launch_y;

		if(!global.editMode){
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
				if(global.Game.roomFrame > global.Game.lastShot+global.Game.shotDelay){
					global.Game.lastShot = global.Game.roomFrame;
					create_projectile(get_struct_x_position(obj_game.level.start), get_struct_y_position(obj_game.level.start),global.Input.launch_x, global.Input.launch_y);
					
					//show_debug_message("shot launched\nX: " + string(level.start.v2x) + "\nY: " + string(level.start.v2y) + "\nVelocity: " + string(global.Input.launch_x) +", " + string(global.Input.launch_y));
				}else if(global.Game.roomFrame == global.Game.lastShot +floor( global.Game.shotDelay/2)){
					audio_sound_gain(obj_game.shootingSound,.25,(global.Game.shotDelay/2) * 1000/fps)
				}
			}
			else{
				if(global.Game.editor_selected_object == infinity){
					shift_level_elements(global.Input.d_x, global.Input.d_y, true);
				}else if(is_struct(global.Game.editor_selected_object)){
					
					if(global.Game.editor_selected_object._id > 0 && keyboard_check(vk_control)){
						if(global.Game.editor_selected_object._id == 1 && keyboard_check(vk_shift)){
							global.Game.editor_selected_object.tr = sqrt((power(global.Input.launch_x,2) + power(global.Input.launch_y,2)));
						}else{
							global.Game.editor_selected_object.r =sqrt((power(global.Input.launch_x,2) + power(global.Input.launch_y,2)));
						}
					}else{
						global.Game.editor_selected_object.v2x = global.Input.cursorX;	
						global.Game.editor_selected_object.v2y = global.Input.cursorY;
					}
					
					update_struct(global.Game.editor_selected_object);
				}
			}
		}else{
			if(!keyboard_check(vk_shift)){
				audio_sound_gain(shootingSound,0,1000);
				global.Input.shooting= false;
			}
			if(global.editMode){
				global.Game.editor_selected_object = noone;	
				trigger_grid_update();
			}
		}
		if((!mouseInWindow && global.Law.inBrowser) ||(!keyboard_check(vk_shift) && !mouse_check_button(mb_left))){
			audio_sound_gain(shootingSound,0,1000);
			global.Input.shooting= false;
		}
	}else if(abs(global.Input.d_x) >0.1 || abs(global.Input.d_y) > 0.1){
		if(window_mouse_get_locked() 
		//&& (!os_type == os_android && os_type != os_ios)
		){
			global.Input.cursorX += global.Input.d_x;
			global.Input.cursorY += global.Input.d_y;
		}else{
			global.Input.cursorX = mouse_x;
			global.Input.cursorY = mouse_y;
		}
		global.Input.launch_x = global.Input.cursorX - get_struct_x_position(obj_game.level.start);
		global.Input.launch_y = global.Input.cursorY - get_struct_y_position(obj_game.level.start);

		if(!global.editMode){
			update_trajectory_preview();
		}
	}
}
function ai_player(){
	if(global.Game.roomFrame > global.Game.lastShot+global.Game.shotDelay){
		var baseXVector = -(level.endpoint.v2x-level.start.v2x)/2;
		var baseYVector = (level.endpoint.v2y-level.start.v2y)/2;
		for(var i = 0; i <array_length(level.components); i++){
			baseXVector -= 	(level.components[i].v2x-level.start.v2x)/array_length(level.components)* (level.components[i].r+level.components[i].damage)/100;	
			baseYVector += 	(level.components[i].v2y-level.start.v2y)/array_length(level.components) * (level.components[i].r+level.components[i].damage)/100;
		}
		global.Input.cursorX = level.start.v2x + global.Input.launch_x;
		global.Input.cursorY = level.start.v2y + global.Input.launch_y;
		if(global.Input.launch_x == 0)
			global.Input.launch_x =  /*random_range(.2, .4)*/-.75 *baseXVector
		if(global.Input.launch_y == 0)
			global.Input.launch_y = 0
			//baseYVector*.75
		
		update_trajectory_preview();			
		create_projectile(level.start.v2x, level.start.v2y, global.Input.launch_x, global.Input.launch_y);	
		global.Game.simShotCount++;
			if(global.Game.simShotCount>7){
				global.Game.simShotCount = 0;
				global.Input.launch_x =  random_range(.2, .4) *baseXVector
				global.Input.launch_y = random_range(.2, .4) *baseYVector
				global.Game.lastShot = global.Game.roomFrame+4*global.Law.physRate;
				audio_sound_gain(shootingSound,0.5,1000);
			}else{
				global.Game.lastShot = global.Game.roomFrame;
			}
		}	
}