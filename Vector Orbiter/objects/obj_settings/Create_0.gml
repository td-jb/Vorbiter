/// @description Insert description here
// You can write your code in this editor

#region enums
enum DebugMode {
	SCREEN,
	PERFORMANCE,
	INPUT,
	NONE
}
enum MenuScreen{
	MAIN,
	SCORES,
	SELECT,
	SETTINGS
	
}
#endregion
#region Laws of nature
global.circle_precision_factor = 2;
global.play_area_radius = 1920 * 2.2;
global.gravitation = 1;
global.highScore = 0;
global.introTimer = 2000;
global.projectileRadius = 10;
global.projectileMassFactor = 150;
global.play_area_radius_sq = power(global.play_area_radius,2);
global.inBrowser = os_browser != browser_not_a_browser;
global.threeD = !global.inBrowser || webgl_enabled;
global.levels = {};
global.playerData = {};
global.grid_mass = global.projectileRadius* 1000;
global.depthMod = 1;
global.minFrameRate = 60;
global.grid_vertex_format = create_vertex_format();
global.boostMod = 0.01;
global.brakeMod = 0.01;
global.trajectorySampleRate = 4;
global.z_alpha =20000;
global.multiplierRadiusMod = .45;
global.multiplierRate = 1;
global.hueMult = 2;
global.v_buff = vertex_create_buffer();
global.u_buff = vertex_create_buffer();
load_levels();
load_player_data();
if(global.threeD){
	global.camera = view_camera[0];	
	global.projection_matrix = matrix_build_projection_perspective(view_wport[0], view_hport[0], 0,300);
}else{
	global.camera = view_camera[0];	
}
#endregion;
#region User settings
global.base_grid_size = 48;
global.grid_solid = false;
global.gridScaleFactor = 1;
global.component_saturation = 255;
global.component_value = 255;
global.bg_color = make_color_hsv(255,global.component_saturation,global.component_value);
global.good_color = make_color_hsv(color_get_hue(c_lime), global.component_saturation, global.component_value);
global.projectile_color = make_color_hsv(color_get_hue(c_aqua), global.component_saturation, global.component_value);
global.bad_color = make_color_hsv(color_get_hue(c_red), global.component_saturation, global.component_value);
global.neutral_hue = (60/360 * 256);
global.danger_hue =0.03;
global.grid_alpha = 0.1;
global.roundEdge = false;
global.edgeFalloff = 1000;
global.fullGrid = !global.inBrowser;
global.grid_thickness = 6;
if(!global.fullGrid){
	global.grid_thickness = 3;
}
if(global.inBrowser){
	global.grid_alpha = 0.9;	
}
global.trail_sample_rate = 4;
global.trail_length = 75;
global.grid_update_chunk = 500;
#endregion
#region Dynamic Variables
global.intro = true;
global.score = 0;
global.startTime = current_time;
global.simRate = 1
global.playerProfile = "Turd Jabroni";
global.debugMode = DebugMode.NONE;
global.editMode = false;
global.objectDepth = false;
global.spiralUpdate = false;
global.currentLevel = 0;
global.show_ui = true;
global.boost = false;
global.brake = false;
global.grid_size = global.base_grid_size;
global.sim_grid_size = global.base_grid_size;
global.sim_grid_count = (global.play_area_radius * 2)/global.sim_grid_size;
global.screenScale = 1;
#endregion
#region Debug variables
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
global.gridDebugMessages = false;
global.normalizeFlybyBoost = false;
global.vertCopyRate = false;
global.frame_vert_count = 0;
#endregion
#region Input overlay variables
left_click_sprite = spr_lmb;
right_click_sprite = spr_rmb;
escape_sprite = spr_esc;
textMargin = 5;
sprite_scale = 0.33;
row_height = max(sprite_get_height(left_click_sprite),sprite_get_height(right_click_sprite),sprite_get_height(escape_sprite))*sprite_scale + textMargin
row_width = row_height * 3;
#endregion
#region initialization
init_sim_grid();
fill_grid_buffer(true);
audio_play_sound(opening_sound,0,false,0.8);
#endregion