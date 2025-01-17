/// @description Insert description here
// You can write your code in this editor
enum DebugMode {
	SCREEN,
	PERFORMANCE,
	INPUT,
	NONE
}
enum MenuScreen{
	MAIN,
	SCORES
	
}
global.inBrowser =os_browser != browser_not_a_browser;
global.playerProfile = "Turd Jabroni";
global.levels = {};
global.playerData = {};
global.currentLevel = 0;
global.gravitation = 1;
global.score = 0;
global.highScore = 0;
load_levels();
load_player_data();
global.intro = true;
global.introTimer = 2000;
global.startTime = current_time;
global.debugMode = DebugMode.NONE;
global.simRate = 1
global.projectileRadius = 10;
global.projectileMassFactor = 150;
global.editMode = false;
global.threeD = !global.inBrowser || webgl_enabled;
show_debug_message("3D = " + string(global.threeD))
global.objectDepth = false;
global.grid_mass = global.projectileRadius* 1000;
//if(global.inBrowser)
//	global.grid_mass *= 10;
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_colour();
vertex_format_add_texcoord();
global.grid_vertex_format = vertex_format_end();
global.depthMod = 1;
global.limitGraphCalculation = false;
global.graphNeighborLimit = 4;
global.spiralUpdate = false;
if(global.threeD){
	
	//if(!global.inBrowser){
	//global.camera = camera_create();
	//camera_destroy(view_camera[0]);
	//view_set_camera(0, global.camera);
	//}else{
		global.camera = view_camera[0];	
	//}
	global.projection_matrix = matrix_build_projection_perspective(view_wport[0], view_hport[0], 0,300);
	//var translation_matrix = matrix_build(0,0,0,90,0,0,-1,-1,0);
}else{
	global.camera = view_camera[0];	
}
audio_play_sound(Endplosion,0,false,0.8);

//global.view_matrix = matrix_multiply(global.view_matrix, translation_matrix);
//global.view_matrix[5] *= -1;
//matrix_set(matrix_projection, global.projection_matrix);
//camera_apply(view_camera[0]);
left_click_sprite = spr_lmb;
right_click_sprite = spr_rmb;
escape_sprite = spr_esc;
textMargin = 5;
sprite_scale = 0.33;
row_height = max(sprite_get_height(left_click_sprite),sprite_get_height(right_click_sprite),sprite_get_height(escape_sprite))*sprite_scale + textMargin
row_width = row_height * 3;

global.averageFrameSamples = 30;
global.projectileTimeArray = array_create(global.averageFrameSamples, 0);
global.trajectoryTimeArray = array_create(global.averageFrameSamples, 0);
global.gridVertexTimeArray = array_create(global.averageFrameSamples, 0);
global.gridUpdateTimeArray = array_create(global.averageFrameSamples, 0);
global.drawTimeArray = array_create(global.averageFrameSamples, 0);
global.sumTimeArray = array_create(global.averageFrameSamples, 0);
global.projectileTime = 0;
global.maxProjectileTime = 0;
global.trajectoryTime = 0;
global.maxTrajectoryTime = 0;
global.gridVertexTime = 0;
global.maxVertexTime = 0;
global.gridUpdateTime = 0;
global.maxGridUpdateTime = 0;
global.drawTime = 0;
global.maxDrawTime = 0;
global.sumTime = 0;
global.maxSumTime = 0;
global.masterVolume =1;
global.ratio = "Width";
global.show_ui = true;

global.roundEdge = false;
global.edgeFalloff = 1000;
global.gridScaleFactor = 1;
global.base_grid_size = 48;
//global.base_grid_size = 256;
global.minFrameRate = 60;
global.fullGrid = !global.inBrowser;
global.grid_thickness = 6;
//global.grid_thickness = 16;
if(!global.fullGrid){
	global.grid_thickness = 3;
}
global.grid_solid = false;
global.v_buff = vertex_create_buffer();
global.u_buff = vertex_create_buffer();
global.frame_vert_count = 0;
global.play_area_radius = 1920 * 2.2;
global.play_area_radius_sq = power(global.play_area_radius,2);
global.grid_size = global.base_grid_size;
global.sim_grid_size = global.base_grid_size;
global.sim_grid_count = (global.play_area_radius * 2)/global.sim_grid_size;
global.screenScale = 1;

global.gridDebugMessages = false;
global.component_saturation = 255;
global.component_value = 255;
global.bg_color = make_color_hsv(255,global.component_saturation,global.component_value);
global.good_color = make_color_hsv(color_get_hue(c_lime), global.component_saturation, global.component_value);
global.projectile_color = make_color_hsv(color_get_hue(c_aqua), global.component_saturation, global.component_value);
global.bad_color = make_color_hsv(color_get_hue(c_red), global.component_saturation, global.component_value);
global.neutral_hue = (60/360 * 256);
global.danger_hue =0.03;
global.grid_alpha = 0.1;
if(global.inBrowser){

	global.grid_alpha = 0.9;	
}
global.trail_sample_rate = 4;
global.trail_length = 75;
global.trajectorySampleRate = 4;
global.z_alpha =20000;
global.multiplierRadiusMod = .45;
global.multiplierRate = 1;
global.hueMult = 2;
global.normalizeFlybyBoost = false;
global.vertCopyRate = false;
global.grid_update_chunk = 500;
init_sim_grid();
if(global.inBrowser)
	show_debug_message("Sim grid initialized");
fill_grid_buffer(true);
if(global.inBrowser)
	show_debug_message("Sim grid filled");