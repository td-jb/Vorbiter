/// @description Insert description here
// You can write your code in this editor

//grid_update_start_x = -1;
//grid_update_start_y = -1;
//grid_update_curr_x = grid_update_start_x;
//grid_update_curr_y = grid_update_start_y;
//grid_update_pending = false;
#region grid update arrays
grid_updates = array_create(0);
finished_grid_updates = array_create(0);
spiral_grid_updates = array_create(0);
finished_spiral_grid_updates = array_create(0);
updated_grid_points = array_create(0);
#endregion

global.currentLevel = clamp(global.currentLevel,0,array_length(global.levels.array));
level_init(global.levels.array[global.currentLevel]);


endEmitter = audio_emitter_create();
endSound = audio_play_sound_on(endEmitter,EndDrum,true,0, .7);
multSound = audio_play_sound_on(endEmitter, mult_1,true,0,0);
multSound0 = audio_play_sound_on(endEmitter, mult_0,true,0,0);
shootingSound = audio_play_sound(_108hzbinaural,0,true, 0, 0.5);
		audio_emitter_pitch(obj_game.endEmitter, 1);

global.projectileCount = 0;
global.liveProjectiles = 0;

if(!instance_exists(obj_main_menu)){
	window_mouse_set_locked(true);
}
set_camera_view();
if(!global.Law.inBrowser){
	global.Input.cursorX = global.Graphics.currX + global.Graphics.currWidth/2;
	global.Input.cursorY = window_get_height()/2;
}else{
	global.Input.cursorX = mouse_x;
	global.Input.cursorY = mouse_y;
}

shake_layer =  layer_get_fx("shake");
shake_fx_params = fx_get_parameters(shake_layer);
left_click_sprite = spr_lmb;
right_click_sprite = spr_rmb;
escape_sprite = spr_esc;
scroll_sprite = spr_mouse_wheel;
textMargin = 5;
sprite_scale = 0.33;
row_height = max(sprite_get_height(left_click_sprite),sprite_get_height(right_click_sprite),sprite_get_height(escape_sprite))*sprite_scale + textMargin
row_width = row_height * 3;
mouseInWindow = true;
debug_x = 0;
debug_y = 0;
total_multiplier = 0;
last_shot_position = array_create(2, infinity);
shot_preview_x = array_create(global.Law.trajectoryLength);
shot_preview_y = array_create(global.Law.trajectoryLength);
shot_preview_r = array_create(global.Law.trajectoryLength);
shot_preview_mult = array_create(global.Law.trajectoryLength, 1);
if(global.Law.threeD){
	global.camera = view_camera[0];	
	camera_set_proj_mat(global.camera,global.projection_matrix);
	camera_set_view_mat(global.camera, global.view_matrix)
	camera_apply(global.camera);
}
trigger_grid_update();
browser_input_capture(true);
hit_list = array_create(0);
postGame = false;