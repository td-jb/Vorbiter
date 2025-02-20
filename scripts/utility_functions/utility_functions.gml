// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

#region save/load functions
function load_levels(){
	var _buffer = buffer_load("levels.json");
	var _string = buffer_read(_buffer, buffer_string);
	buffer_delete(_buffer);
	global.universe = json_parse(_string);
	global.levels = global.universe.regions[0];
	for(var i = 0; i < array_length(global.levels.array); i++){
		reset_struct(global.levels.array[i].start);
		reset_struct(global.levels.array[i].endpoint);
		for(var k = 0; k < array_length(global.levels.array[i].components); k++){
			
			
			reset_struct(global.levels.array[i].components[k]);
		}
		
	}
}
function save_levels(){
	var save_string = json_stringify(global.levels,true);
	var _buffer = buffer_create(string_byte_length(save_string)+1,buffer_fixed,1);
	buffer_write(_buffer, buffer_string, save_string);
	var filename = "levels.json";
	buffer_save(_buffer,working_directory + filename);	
	buffer_delete(_buffer);// delete the buffer
}

function save_player_data(){
	if(!global.Law.inBrowser){
		var save_string = json_stringify(global.playerData,true);
		var _buffer = buffer_create(string_byte_length(save_string)+1,buffer_fixed,1);
		buffer_write(_buffer, buffer_string, save_string);
		var filename = "player.json";
		buffer_save(_buffer,working_directory + filename);	
		buffer_delete(_buffer);// delete the buffer
	}
	
}
function create_default_laws(){
	 return{
		baseDepth: depth,
		baseShotDelay: 6,
		circlePrecision: 2,
		playRadius: 1920 * 2.2,
		sqPlayRadius: power(1920 * 2.2,2),
		gravitation: 1,
		roundEdge: false,
		introTimer: 2000,
		pRadius: 10,
		pMassFactor: 150,
		inBrowser: os_browser != browser_not_a_browser,
		threeD: os_browser == browser_not_a_browser || webgl_enabled,
		gridMass: 10000,
		depthMod: 1,
		physRate: 60,
		gridVertexFormat: create_vertex_format(),
		boostMod: 0.01,
		brakeMod: 0.01,
		trajectorySampleRate: 4,
		trajectoryLength: 100,
		depthAlpha: 20000,
		multiplierRadiusMod: .45,
		multiplierRate: 1,
		hueMult: 2,
		edgeFalloff: 1000,
		momentum: true,
		stableBoundary: true,
		fieldCheck: false
	}				
}
function create_default_settings_struct(){
	
	return 	{
		masterVolume: {value: 1, type: SettingType.REAL, limits:[0,1], note: "The overall volume of all game sounds." },
		baseGridSize: {value: 48, type: SettingType.INT, limits:[16,512], name: "Grid Size", note: "The size of each grid cell in the game background. Smaller numbers may decrease performance significantly."},
		fullGrid: {value: !global.Law.inBrowser, type:SettingType.BOOL, name: "Draw Full Grid", note: "Sets whether the full grid is drawn each frame, or if instead the vertices are redrawn any time the visible portion of the screen changes. Setting this to false reduces GPU strain. Setting it to true reduces CPU strain"},
		gridScaleFactor: {value: 1, type: SettingType.REAL, limits:[0.5,5], name: "Grid Scaling Rate", note: "Changes the rate at which the grid resizes its cells", req:{struct:"fullGrid", value: false}},
		gridThickness: {value: 6, 
						type: SettingType.INT, 
						limits:[1,16], 
						name: "Grid Thickness", 
						note: "Changes the thickness with which the grid is drawn", 
						req:{struct:"fullGrid", value: false}},
		gridAlpha: {value: 0.1, type: SettingType.REAL, limits:[0,1], name: "Grid Transparency", note: "The transparency used when drawing the grid." },
		gridUpdateRate: {value: 400, type: SettingType.INT, limits:[1,36000], name: "Grid Update Rate", note: "How many grid nodes are updated per frame when recalculating gravity wells. Lower values will improve performance."},
		colorSaturation: {value: 255, type: SettingType.SATURATION, limits:[0,255], name: "Saturation", note: "The base Saturation level." },
		colorValue:  {value: 255, type: SettingType.VALUE, limits:[0,255], name: "Brightness", note: "The base Brightness." },
		backgroundHue: {value: 255, type: SettingType.HUE, limits:[0,255], name: "Background Hue", note: "The base hue used for background elements (the launcher ,the grid, exterior bounds)" },
		projectileHue:  {value: color_get_hue(c_aqua), type: SettingType.HUE, limits:[0,255], note: "The base hue used for projectiles and the level's target point" },
		badHue: {value:  color_get_hue(c_red), type: SettingType.HUE, limits:[0,255], name: "Bad Hue", note: "The base hue used to indicate bad events" },
		goodHue:  {value: color_get_hue(c_lime), type: SettingType.HUE, limits:[0,255], name: "Good Hue", note: "The base hue to indicate good events" },
		neutralHue: {value:  color_get_hue(c_yellow), type: SettingType.HUE, limits:[0,255], name: "Obstacle Hue", note: "The base hue used for drawing obstacles in space-time" },
		dangerHue: {value: 0.03, type: SettingType.HUE, limits:[0,255], name: "Danger Hue", note: "The hue used to indicate that something dangerous may occur"},
		trailLength: {value: 25, type: SettingType.INT, limits:[0, 200], name:"Trail Length" , note: "The length of the trail left by the projectiles."},
		trailDensity: {value: 4, type: SettingType.INT, limits:[1, 10], name:"Trail Density" , note: "The density of the points drawn in projectile trails."},
		scrollRate: {value: 0.1, type: SettingType.REAL, limits:[0.01,1], name: "Scroll Speed", note: "The speed with which the camera zoom follows the scroll wheel."},
		scaleRate: {value: 0.1, type: SettingType.REAL, limits:[0.01,1], name: "Camera Speed", note: "The speed with which the camera expands in order to follow projectiles."},
	}
}
function create_blank_game_state(){
	var new_state = {
		pulseRate: 1,
		levelComplete: false,
		reset: false,
		status: GameStatus.SIM,
		completeTime: 0,
		overtime: 0,
		roomFrame: 0,
		lastShot: 0,
		shotDelay: global.Law.baseShotDelay,
		roomStart: current_time,
		levelScore: 0,
		pulseFactor: 0,
		cosPulse: 0,
		editor_selected_object: -1,
		simShotCount: 0
	};	
	return new_state;
}
function create_blank_graphics_state(){
	var new_state = {
		gridCountX: view_wport[0]/global.Settings.baseGridSize.value,
		gridCountY: view_hport[0]/global.Settings.baseGridSize.value,
		prev_grid_count_y: 0,
		prev_grid_count_x: 0,
		prev_grid_thickness: global.Settings.gridThickness.value,
		grid_x_offset:0,
		grid_y_offset:0,
		prev_grid_offset_x:0,
		prev_grid_offset_y:0,
		baseWidth: window_get_width(),
		baseHeight: window_get_height(),
		currX: 0,
		currY: 0,
		targetX: 0,
		targetY: 0,
		minWidth: window_get_width(),
		minHeight: window_get_height(),
		gridHeight: 0,
		gridWidth: 0,
		gridStartX: 0,
		gridStartY: 0,
		gridSize: global.Settings.baseGridSize.value,
		minProjectileX: 0,
		maxProjectileX: 0,
		minProjectileY: 0,
		maxProjectileY: 0,
		prevMaxX: 0,
		prevMaxY: 0,
		prevMinX: 0,
		prevMinY: 0,
		currWidth: 0,
		currHeight: 0,
		minScale: 0.5,
		maxScale: global.Law.playRadius*2/window_get_height(),
		targetMinScale: 0.5,
		stopTimer: 0,
		screenScale: 1,
		vertBuffer: vertex_create_buffer(),
		updateBuffer: vertex_create_buffer(),
		minProjectile: noone,
		explosionCount: 0,
		shotPreviews: array_create(global.Law.trajectoryLength, -1)
	};	
	return new_state;
}
function create_blank_input_state(){
	var new_state = {
		mouse_click_start_x: -1,
		mouse_click_start_y: -1,
		d_x: 0,
		d_y: 0,
		launch_x: 0,
		launch_y: 0,
		shooting: false,
		cursorX: window_get_width()/2,
		cursorY: window_get_height()/2,
		controllerMode: false,
		boost: false,
		brake: false
	};	
	return new_state;
}
function load_player_data(){
	if(file_exists("player.json") && !global.Law.inBrowser){
		var _buffer = buffer_load("player.json");
		var _string = buffer_read(_buffer, buffer_string);
		buffer_delete(_buffer);
		global.playerData = json_parse(_string);
	}else{
		global.playerData = create_default_player_data();	
	}
	
}
function create_default_player_data(){
	var pd = {highscores: array_create(array_length(global.levels.array)+1)
		
	}
	for(var i = 0; i < array_length( pd.highscores); i++){
		pd.highscores[i] = array_create(10, 0);	
		
	}
	return pd;
	
}
#endregion
#region string manipulation functions
function forbidden_string_array(){
	return ["/","\\","?","*",":","\"","<",">","|"];
		
}

function remove_forbidden_characters(stringinput){
		var outputString = stringinput; 
		
		var forbidden_strings = forbidden_string_array();
		for(var i = 0; i < array_length(forbidden_strings); i++)
		{
			outputString = string_replace(outputString, forbidden_strings[i],"");		
		}
		return outputString;
		
	}
function check_banned_words(stringInput){
	var bannedWords = global.bannedWords;
	var stringMod = string_lower(stringInput);
	for(var i = 0; i <ds_list_size(global.bannedWords); i++){
		var swear =  ds_list_find_value(bannedWords, i);
		var count = string_count(swear,stringMod)
		if(count > 0)
		{
			show_debug_message("Banned word: " + swear);
			return true;
		}
	}
	stringMod = string_replace_all(stringInput, " ", "");
	stringMod = string_replace_all(stringMod, "-", "");
	stringMod = string_replace_all(stringMod, "_", "");
	stringMod = string_replace_all(stringMod, "/", "");
	stringMod = string_replace_all(stringMod, "\\", "");
	stringMod = string_replace_all(stringMod, "@", "a");
	stringMod = string_replace_all(stringMod, "3", "e");
	stringMod = string_replace_all(stringMod, "4", "a");
	stringMod = string_replace_all(stringMod, "0", "o");
	stringMod = string_replace_all(stringMod, "8", "b");
	stringMod = string_replace_all(stringMod, "5", "s");
	stringMod = string_replace_all(stringMod, "1", "l");
	for(var i = 0; i <ds_list_size(global.veryBannedwords); i++){
		var swear =  ds_list_find_value(global.veryBannedwords, i);
		swear = string_replace_all(swear, " ", "");
		var count = string_count(swear,stringMod)
		if(count > 0)
		{
			show_debug_message("Banned word: " + swear);
			return true;
		}
	}
	return false;
}
function load_banned_words(){
	var locationString = working_directory + "swear_words.csv";
	// load the dialog csv into a grid
	var fileGrid = load_csv(locationString);
	var rowIndex = 0; // the row currently being examined	
	var swearList = ds_list_create(); //initialize empty map for the dialog database
	while ( rowIndex < ds_grid_height(fileGrid) && (fileGrid[# 0, rowIndex] != "$") )  // \'$\' at the beginning of row marks end of file
	{
		var swear = fileGrid[# 0, rowIndex]; // add the key and the value to the map
		ds_list_add(swearList, swear);
		rowIndex++;
	}
	return swearList;
}

function load_extra_banned_words(){
	var locationString = working_directory + "mega_swears.csv";
	// load the dialog csv into a grid
	var fileGrid = load_csv(locationString);
	var rowIndex = 0; // the row currently being examined	
	var swearList = ds_list_create(); //initialize empty map for the dialog database
	while ( rowIndex < ds_grid_height(fileGrid) && (fileGrid[# 0, rowIndex] != "$") )  // \'$\' at the beginning of row marks end of file
	{
		var swear = fileGrid[# 0, rowIndex]; // add the key and the value to the map
		ds_list_add(swearList, swear);
		rowIndex++;
	}
	return swearList;
}
function num_separator(argument0, argument1, argument2 = 3){
/// num_separator(value, separator, digits)
// num_separator(12345678, "_", 3); // Result: 12_345_678

	var value = string(round(argument0));
	var sep = argument1;
	var digits = argument2 - 1;

	var res = "";

	var cnt = 0;
	var endPoint = 0;
	var neg = false;
	if(argument0<0){
		value = string_delete(value,1,1);
		neg = true;
		
	}
	if(abs(value) < 1000000){
		for (var i=string_length(value); i>endPoint; i--)
		{
	
		    res = string_char_at(value, i) + res;
		    if cnt++ == digits and i > 1
		    {
		        cnt = 0;
		        res = sep + res;
		    }
		}
	}else{
		if(abs(value) < 1000000000){
			
			if(abs(value) < 10000000){
				res = string_char_at(value, 1) + "." + string_char_at(value, 2)+ string_char_at(value, 3);
			}else if(abs(value) < 100000000){
				res = string_char_at(value, 1) + string_char_at(value, 2) + "."+ string_char_at(value, 3)+ string_char_at(value, 4);
			
			}else if(abs(value) < 1000000000){
				res = string_char_at(value, 1) + string_char_at(value, 2)+ string_char_at(value, 3) + "."+ string_char_at(value, 4)+ string_char_at(value, 5);
			
			}
		
			res  += " Million";
		}else if(abs(value) < 1_000_000_000_000){
				if(abs(value) < 1_000_000_000_0){
				res = string_char_at(value, 1) + "." + string_char_at(value, 2)+ string_char_at(value, 3);
			}else if(abs(value) < 1_000_000_000_00){
				res = string_char_at(value, 1) + string_char_at(value, 2) + "."+ string_char_at(value, 3)+ string_char_at(value, 4);
			
			}else if(abs(value) < 1_000_000_000_000){
				res = string_char_at(value, 1) + string_char_at(value, 2)+ string_char_at(value, 3) + "."+ string_char_at(value, 4)+ string_char_at(value, 5);
			
			}
			res  += " Billion";
		}else if(abs(value) < 1_000_000_000_000_000){
				if(abs(value) < 1_000_000_000_000_0){
				res = string_char_at(value, 1) + "." + string_char_at(value, 2)+ string_char_at(value, 3);
			}else if(abs(value) < 1_000_000_000_000_00){
				res = string_char_at(value, 1) + string_char_at(value, 2) + "."+ string_char_at(value, 3)+ string_char_at(value, 4);
			
			}else if(abs(value) < 1_000_000_000_000_000){
				res = string_char_at(value, 1) + string_char_at(value, 2)+ string_char_at(value, 3) + "."+ string_char_at(value, 4)+ string_char_at(value, 5);
			
			}
			res  += " Trillion";
		}
	}
	if(neg)
		res = string_insert("-",res, 0);
	return res;
}
#endregion

function spiral_algorithm(_array, _function, arg_1= 0, arg_2 = 0){
	//performs specified function on 2d array in spiral pattern
	if(!is_array(_array) || !is_array(_array[0])){
		// if this isn't a 2d array get out of here
		show_debug_message("Trying to spiralize un spiralizable object");
		return;	
	}
	var count = array_length(_array) * array_length(_array[0]);
	var index = 0;
	var n = 1;
	var modifier = 1;
	var x_index = floor(array_length(_array)/2);
	var y_index = floor(array_length(_array[0])/2);
	var start_n_index = 0;
	_array[@ x_index][@ y_index] = _function(arg_1,arg_2);
	while(index< count){
		for(var n_index = start_n_index; n_index < n*2; n++){
			if(n_index < n){
				y_index++;
			}else{
				x_index++;	
			}
			_array[@ x_index][@ y_index] = _function(arg_1,arg_2);
		}
		start_n_index = 0;
		n++;
		modifier *= -1;
	}
}
#region level editing functions
function add_default_level(){
	var level = {};
	var levelArray = global.levels.array;
	start = {name: "start",
		v2x: 100,
		v2y: 980,
		r: 25};
	//circle1 = {name: "circle",
	//	v2x: 400,
	//	v2y: 350,
	//	r: 25
	//	};
	endP = {name: "end",
		v2x: 960,
		v2y: 540,
		r: 125,
		tr: 100,
		damage: 0}
	
	struct_set(level,"name", string(array_length(levelArray)));
	struct_set(level,"start",start);
	struct_set(level,"endpoint",endP);
	var levelComponents = array_create(0);
	//array_push(levelComponents, circle1);
	struct_set(level,"components", levelComponents);
	array_push(levelArray, level);
	
}
function shift_level_elements(_d_x, _d_y, _permanent){
	var target_variable_x = "v2x";
	var target_variable_y = "v2y";
	if(!_permanent){
		target_variable_x = "d_x";
		target_variable_y = "d_y";
		global.Input.cursorX += _d_x;
		global.Input.cursorY += _d_y;
		//global.Input.launch_x += _d_x;
		//global.Input.launch_y += _d_y;
	}
	modify_struct_variable(obj_game.level.start, target_variable_x, _d_x);
	modify_struct_variable(obj_game.level.start, target_variable_y, _d_y);
	if(boundary_collision_check(obj_game.level.start))
		trigger_reset();
	modify_struct_variable(obj_game.level.endpoint, target_variable_x, _d_x);
	modify_struct_variable(obj_game.level.endpoint, target_variable_y, _d_y);
	if(boundary_collision_check(obj_game.level.endpoint))
		trigger_reset();
	for(var i = 0; i <array_length(obj_game.level.components); i++){
		modify_struct_variable(obj_game.level.components[i], target_variable_x, _d_x);
		modify_struct_variable(obj_game.level.components[i], target_variable_y, _d_y);
		if(boundary_collision_check(obj_game.level.components[i]))
			trigger_reset();
	}
	trigger_grid_update();
	update_trajectory_preview();
}

function modify_struct_variable(_struct, _var_name, _value){
	var new_value = _value;
	if(struct_exists(_struct, _var_name)){
		new_value += struct_get(_struct, _var_name);
	}
	struct_set(_struct, _var_name,  new_value);	
}
function add_component_to_level(_v2x, _v2y, _r, type = "circle"){
	var newComponent = noone;
	switch type{
		case "circle":
			newComponent = {name: type,
				v2x: _v2x,
				v2y: _v2y,
				r: _r,
				dr: _r,
				mass: power(_r,2),
				damage: 0,
				_id: array_length( obj_game.level.components)+2
				};
			break;
		case "square":{
				newComponent = {name: type,
				v2x: _v2x,
				v2y: _v2y,
				r: _r,
				mass: 0,
				damage: 0,
				_id: array_length( obj_game.level.components)+2
			};
		}
		break;
	}
	array_push( obj_game.level.components, newComponent);
	return newComponent;
}
function remove_component_from_level(obj_struct){
	var ind = array_get_index(obj_game.level.components,obj_struct);
	array_delete(obj_game.level.components, ind,1);
	for(var i = 0; i < array_length(obj_game.level.components);i++){
			obj_game.level.components[i]._id = i+ 2;
		
	}
	
}
#endregion
#region debug functions
function log_projectile_performance_time(frameTime){
	if(global.debugMode == DebugMode.PERFORMANCE){
		global.projectileTimeArray[global.averageFrameSamples-1] += frameTime;
		if(global.projectileTimeArray[global.averageFrameSamples-1] > global.maxProjectileTime){
			global.maxProjectileTime = global.projectileTimeArray[global.averageFrameSamples-1];
		}
	}
}

function log_trajectory_performance_time(frameTime){
	if(global.debugMode == DebugMode.PERFORMANCE){
		global.trajectoryTimeArray[global.averageFrameSamples-1] = frameTime;
		if(global.trajectoryTimeArray[global.averageFrameSamples-1] > global.maxTrajectoryTime){
			global.maxTrajectoryTime = global.trajectoryTimeArray[global.averageFrameSamples-1];
		}
	}
}
function log_grid_update_performance_time(frameTime){
	if(global.debugMode == DebugMode.PERFORMANCE){
		global.gridUpdateTimeArray[global.averageFrameSamples-1] += frameTime;
		if(global.gridUpdateTimeArray[global.averageFrameSamples-1] > global.maxGridUpdateTime){
			global.maxGridUpdateTime = global.gridUpdateTimeArray[global.averageFrameSamples-1];
		}
	}
}
function log_grid_vertex_performance_time(frameTime){
	if(global.debugMode == DebugMode.PERFORMANCE){
		global.gridVertexTimeArray[global.averageFrameSamples-1] += frameTime;
		if(global.gridVertexTimeArray[global.averageFrameSamples-1] > global.maxVertexTime){
			global.maxVertexTime = global.gridVertexTimeArray[global.averageFrameSamples-1];
		}
	}
}
function log_draw_performance_time(frameTime){
	if(global.debugMode == DebugMode.PERFORMANCE){
		global.drawTimeArray[global.averageFrameSamples-1] += frameTime;
		if(global.drawTimeArray[global.averageFrameSamples-1] > global.maxDrawTime){
			global.maxDrawTime = global.drawTimeArray[global.averageFrameSamples-1];
		}
	}
}
function log_sum_performance_time(){
	if(global.debugMode == DebugMode.PERFORMANCE){
		global.sumTime = global.trajectoryTime+global.projectileTime+global.gridUpdateTime+global.gridVertexTime+global.drawTime;
		if(global.sumTime > global.maxSumTime){
			global.maxSumTime = global.sumTime;
		}
	}
}
#endregion
#region array manipulation functions
function get_array_average(array){
	var sum_frametime = 0;

	for(var i = 0; i< array_length(array); i++){
		sum_frametime += array[i];
	
	}
	return sum_frametime/array_length(array)
	
}
function shift_array(array){
	if(array_length(array) == 0){
		return;	
	}
	if(global.Law.inBrowser){
		show_debug_message("shift_array line 533");	
	}
	for(var i = 0; i < array_length(array)-1;i++){
		array[@ i] = array[@ (i+1)];
	}
	if(global.Law.inBrowser){
		show_debug_message("shift_array line 539");	
	}
	array[@ (array_length(array)-1)] = 0;
}
#endregion


function generate_trig_tables(){
	//2*pi/4
	global.squares = array_create(global.Law.playRadius);
	for(var i=1; i <= global.Law.playRadius * 2; i++){
		global.squares[i-1] = power(i,2);
	}	
}

function cursor_collision_check(x_1, y_1, x_2, y_2){
	return (global.Input.cursorX > x_1 && global.Input.cursorX < x_2 && global.Input.cursorY > y_1 && global.Input.cursorY < y_2)
	
}
function fuzzy_sqrt(_real){
	
}