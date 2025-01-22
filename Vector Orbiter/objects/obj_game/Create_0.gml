/// @description Insert description here
// You can write your code in this editor

//grid_update_start_x = -1;
//grid_update_start_y = -1;
//grid_update_curr_x = grid_update_start_x;
//grid_update_curr_y = grid_update_start_y;
//grid_update_pending = false;
g_state = create_blank_game_state();
i_state = create_blank_input_state();
c_state = create_blank_camera_state();
#region grid update arrays
grid_updates = array_create(0);
finished_grid_updates = array_create(0);
spiral_grid_updates = array_create(0);
finished_spiral_grid_updates = array_create(0);
updated_grid_points = array_create(0);
#endregion

global.currentLevel = clamp(global.currentLevel,0,array_length(global.levels.array));
level_init(global.levels.array[global.currentLevel]);

grid_x_count = view_wport[0]/global.grid_size;
grid_y_count = view_hport[0]/global.grid_size;
grid_trigger = false;
prev_grid_x_count = grid_x_count;
prev_grid_y_count = grid_y_count;
prev_grid_thickness = global.grid_thickness;
grid_x_offset = 0;
grid_y_offset = 0;
prev_grid_x_offset = grid_x_offset;
prev_grid_y_offset = grid_y_offset;
pulseRate = 1;
levelComplete = false;
reset = false;
completeTime = 0;
overtime = 0;

room_frame = 0;
lastShot = 0;
room_start = current_time;
baseShotDelay = 6;
shotDelay = 6;
//global.syncGroup = audio_create_sync_group(true)

endEmitter = audio_emitter_create();
endSound = audio_play_sound_on(endEmitter,EndDrum,true,0, 0.25);
shootingSound = audio_play_sound(_108hzbinaural,0,true, 0);

global.projectileCount = 0;
global.liveProjectiles = 0;
simShotCount = 0;

baseWidth = window_get_width();
baseHeight = window_get_height();
minWidth = baseWidth;
minHeight = baseHeight;
grid_height = minHeight;
grid_width = minWidth;
grid_start_x = 0;
grid_start_y = 0;

maxProjectileX = 0;
minProjectileX = 0;
maxProjectileY = 0;
minProjectileY = 0;
prevMaxX = 0;
prevMaxY = 0;
prevMinX = 0;
prevMinY = 0;

room_frame = 0;
currWidth = minWidth;
currHeight = minHeight;
targetWidth = currWidth;
targetHeight = currHeight;
minScale = 0.5;
targetMinScale = minScale;
maxScale = global.play_area_radius*2/window_get_height();
scrollRate = 0.1;
currX = 0;
currY = 0;
targetX = 0;
targetY = 0;
levelScore = 0;
scaleRate = 0.1;
scaleAmount = 0;
stopTimer = 0;
expandDistFactor = 1.2;
pulseFactor = 0;
cosPulse = 0;
baseDepth = depth;
last_mouse_x = window_mouse_get_x();
last_mouse_y = window_mouse_get_y();

if(room == game_room){
	//window_set_cursor(cr_none);
	window_mouse_set_locked(true);
}
if(!global.inBrowser){
	window_mouse_set(window_get_width()/2,window_get_height()/2);
	curs_x = window_mouse_get_x() * view_wport[0]/window_get_width();
	curs_y = window_mouse_get_y() * view_hport[0]/window_get_height();
}
cursor_x = window_get_width()/2;
cursor_y = window_get_height()/2;
set_camera_view();

if(!global.inBrowser){
	cursor_x = currX + currWidth/2;
	cursor_y = window_get_height()/2;
}else{
	cursor_x = mouse_x;
	cursor_y = mouse_y;
}
cursor_x_offset = 0;
cursor_y_offset = 0;
preview_length = 100;
shot_preview_x = array_create(preview_length);
shot_preview_y = array_create(preview_length);
shot_preview_r = array_create(preview_length);
shot_preview_mult = array_create(preview_length, 1);
editor_selected_object = -1;
shooting = false;
maxGravDepth = 0;
proj_near = -10000
proj_far = 1000;
grav_depth_factor = 100;
proj_wid = currWidth;
proj_hei = currHeight;
min_projectile = noone;
shake_layer =  layer_get_fx("shake");
shake_fx_params = fx_get_parameters(shake_layer);
explosion_count = 0;
left_click_sprite = spr_lmb;
right_click_sprite = spr_rmb;
escape_sprite = spr_esc;
scroll_sprite = spr_mouse_wheel;
textMargin = 5;
sprite_scale = 0.33;
row_height = max(sprite_get_height(left_click_sprite),sprite_get_height(right_click_sprite),sprite_get_height(escape_sprite))*sprite_scale + textMargin
row_width = row_height * 3;
depthMod = 1;
proj_index = 0;
mouseInWindow = true;
debug_x = 0;
debug_y = 0;
total_multiplier = 0;
last_shot_position = array_create(2, infinity);
if(global.threeD){
	global.camera = view_camera[0];	
	camera_set_proj_mat(global.camera,global.projection_matrix);
	camera_set_view_mat(global.camera, global.view_matrix)
	camera_apply(global.camera);
}

trigger_grid_update();
browser_input_capture(true);
hit_list = array_create(0);
postGame = false;