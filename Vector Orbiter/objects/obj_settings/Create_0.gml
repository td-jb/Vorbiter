/// @description Insert description here
// You can write your code in this editor
//game_set_speed( 244, gamespeed_fps);
#region enums
enum DebugMode {
	SCREEN,
	PERFORMANCE,
	INPUT,
	GAME,
	NONE
}
enum MenuScreen{
	MAIN,
	SCORES,
	SELECT,
	SETTINGS
	
}
enum GameStatus{
	PLAY,
	EDIT,
	END,
	RESET,
	POST,
	SIM,
	PAUSE
}
enum SettingType{
	REAL,
	INT,
	BOOL,
	HUE,
	SATURATION,
	VALUE
}
#endregion
#region Laws of nature
global.Law = create_default_laws();			
#endregion;
#region User settings
global.Settings = create_default_settings_struct();
#endregion
#region Dynamic Variables
global.levels = {};
global.playerData = {};
load_levels();
load_player_data();
global.intro = true;
global.score = 0;
global.highScore = 0;
global.startTime = current_time;
global.simRate = 1
global.playerProfile = "Turd Jabroni";
global.debugMode = DebugMode.NONE;
global.editMode = false;
global.objectDepth = false;
global.spiralUpdate = false;
global.currentLevel = 0;
global.show_ui = true;
global.sim_grid_size = global.Settings.baseGridSize.value;
global.sim_grid_count = (global.Law.playRadius * 2)/global.sim_grid_size;
global.backgroundColor = make_color_hsv(255,global.Settings.colorSaturation.value,global.Settings.colorValue.value);
global.goodColor = make_color_hsv(global.Settings.goodHue.value, global.Settings.colorSaturation.value, global.Settings.colorValue.value);
global.projectileColor = make_color_hsv(global.Settings.projectileHue.value, global.Settings.colorSaturation.value, global.Settings.colorValue.value);
global.badColor = make_color_hsv(global.Settings.badHue.value, global.Settings.colorSaturation.value, global.Settings.colorValue.value);
global.Graphics = create_blank_graphics_state();
global.Game = create_blank_game_state();
global.Input = create_blank_input_state();
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
#region global.Input overlay variables
textMargin = 5;
#endregion
#region initialization
						
if(global.Law.threeD){
	global.camera = view_camera[0];	
	global.projection_matrix = matrix_build_projection_perspective(view_wport[0], view_hport[0], 0,300);
}else{
	global.camera = view_camera[0];	
}
if(global.Law.inBrowser){
	global.Settings.gridAlpha.value = 0.9;	
}
if(!global.Settings.fullGrid.value){
	global.Settings.gridThickness.value = 3;
}
init_sim_grid();
fill_grid_buffer(true);
audio_play_sound(opening_sound,0,false,0.8);
#endregion