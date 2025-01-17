// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

#region save/load functions
function load_levels(){
	var _buffer = buffer_load("levels.json");
	var _string = buffer_read(_buffer, buffer_string);
	buffer_delete(_buffer);
	global.levels = json_parse(_string);
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
	if(!global.inBrowser){
		var save_string = json_stringify(global.playerData,true);
		var _buffer = buffer_create(string_byte_length(save_string)+1,buffer_fixed,1);
		buffer_write(_buffer, buffer_string, save_string);
		var filename = "player.json";
		buffer_save(_buffer,working_directory + filename);	
		buffer_delete(_buffer);// delete the buffer
	}
	
}
function load_player_data(){
	if(file_exists("player.json") && !global.inBrowser){
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
function forbidden_string_array(){
	return ["/","\\","?","*",":","\"","<",">","|"];
		
}
function wipe_maximums(){
	global.maxTrajectoryTime = 0
	global.maxDrawTime = 0;
	global.maxGridUpdateTime = 0;
	global.maxProjectileTime =0
	global.maxSumTime = 0;
	global.maxVertexTime = 0;
	
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
function add_component_to_level(_v2x, _v2y, _r, type = "circle"){
	var newComponent = {name: type,
		v2x: _v2x,
		v2y: _v2y,
		r: _r,
		dr: _r,
		mass: power(_r,2),
		damage: 0,
		_id: array_length( obj_game.level.components)+2
		};
	
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
	if(global.inBrowser){
		show_debug_message("shift_array line 533");	
	}
	for(var i = 0; i < array_length(array)-1;i++){
		array[@ i] = array[@ (i+1)];
	}
	if(global.inBrowser){
		show_debug_message("shift_array line 539");	
	}
	array[@ (array_length(array)-1)] = 0;
}
function reset_colors(){
	
	
	global.bg_color = make_color_hsv(255,global.component_saturation,global.component_value);
	global.good_color = make_color_hsv(color_get_hue(c_lime), global.component_saturation, global.component_value);
	global.projectile_color = make_color_hsv(color_get_hue(c_aqua), global.component_saturation, global.component_value);
	global.bad_color = make_color_hsv(color_get_hue(c_red), global.component_saturation, global.component_value);
	trigger_grid_update();
}
function generate_trig_tables(){
	//2*pi/4

	
}