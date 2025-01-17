// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function simulate_trajectory(start_x, start_y, launch_vector_x, launch_vector_y, x_array, y_array, r_array, m_array){
	var starttime = current_time;
	//show_debug_message("Trajectory Preview\nX: " + string(start_x) + "\nY: " + string(start_y) + "\nprojectile: " + string(launch_vector_x) +", " + string(launch_vector_y));

	var projectile = {x_vel: launch_vector_x,
		y_vel: launch_vector_y,
		x_pos: start_x,
		y_pos: start_y,
		mult: 1,
		frameMult: 0,
		r: global.projectileRadius}
	
	hit_list = [];
	for(var k = 0; k <array_length(x_array)*global.trajectorySampleRate; k +=1){
		projectile.frameMult = 0;
		increase_projectile_radius(projectile);
		var dist = apply_gravitational_acceleration(obj_game.level.endpoint,projectile.x_pos,projectile.y_pos,get_projectile_mass(projectile.r),projectile);
		apply_flyby_mod(obj_game.level.endpoint, dist,projectile.r, projectile,true);
		if( collision_check(obj_game.level.endpoint,dist,projectile.r)){
			
			projectile.x_pos += (projectile.x_vel/60);
			projectile.y_pos += (projectile.y_vel /60);
			while(k < array_length(x_array)*global.trajectorySampleRate){
				x_array[floor(k)/global.trajectorySampleRate] = projectile.x_pos;
				y_array[floor(k)/global.trajectorySampleRate] = projectile.y_pos;
				r_array[floor(k)/global.trajectorySampleRate] =projectile.r;
				m_array[floor(k)/global.trajectorySampleRate] = projectile.mult;
				k++;
			}
			return;
		
		}
		for(var i= 0; i < array_length(obj_game.level.components); i++){
			
			dist = apply_gravitational_acceleration(obj_game.level.components[i], projectile.x_pos,projectile.y_pos,get_projectile_mass(projectile.r),projectile) ;
			apply_flyby_mod(obj_game.level.components[i], dist,projectile.r, projectile,true);
			if( collision_check(obj_game.level.components[i],dist,projectile.r)){
			
				projectile.x_pos += (projectile.x_vel/60);
				projectile.y_pos += (projectile.y_vel /60);
				while(k < array_length(x_array)*global.trajectorySampleRate){
					
				
					x_array[floor(k)/global.trajectorySampleRate] = projectile.x_pos;
					y_array[floor(k)/global.trajectorySampleRate] = projectile.y_pos;
					r_array[floor(k)/global.trajectorySampleRate] =projectile.r;
					m_array[floor(k)/global.trajectorySampleRate] = projectile.mult;
					k++;
				}
				return;
		
			}
		}
		projectile.x_pos += (projectile.x_vel/60);
		projectile.y_pos += (projectile.y_vel/60);
		x_array[floor(k)/global.trajectorySampleRate] = projectile.x_pos;
		y_array[floor(k)/global.trajectorySampleRate] = projectile.y_pos;
		r_array[floor(k)/global.trajectorySampleRate] =projectile.r;
		m_array[floor(k)/global.trajectorySampleRate] = projectile.mult;
	}
	log_trajectory_performance_time( current_time - starttime);
}
function apply_gravitational_acceleration(obj_struct, subj_x, subj_y, subj_mass, subj_projectile){
	var end_dist_x = ( obj_struct.v2x - subj_x);
	var end_dist_y = (obj_struct.v2y - subj_y);
	var dist =get_square_distance(obj_struct, subj_x, subj_y);
	var ratio = get_gravitational_force(obj_struct, dist, subj_mass);
	var truedist = sqrt(dist);
	var x_ratio = end_dist_x/truedist;
	var y_ratio =end_dist_y/truedist;
	subj_projectile.x_vel += (x_ratio * ratio);
	subj_projectile.y_vel += (y_ratio * ratio);
	return dist;
	
}
function increase_projectile_radius(_projectile){
	
	_projectile.r += ((2/(60) * (0.1*_projectile.r))* global.simRate);
	
}
function apply_flyby_mod(obj_struct, dist, projectile_radius, vel, preview = false){
	
	var obj_rad = (obj_struct.dr);
	var mult_halo = obj_rad * global.multiplierRadiusMod;
	var max_rad = obj_rad + mult_halo + projectile_radius;
	var combradsq = power(max_rad,2)
	var truedist = (dist - combradsq);
	var projSquare = power(projectile_radius,2);
	//if(!preview)
	//	show_debug_message("Flyby calculated at dist2: " + string(truedist) + " and radius2: " + string(projSquare) );
		
	if(truedist< 0){
		var sqrt_dist = sqrt(dist);
		var overlap = (max_rad)-sqrt_dist;
		var ratio = overlap/mult_halo;
		if(!preview){
			show_debug_message("Multiplier applied at overlap ratio: " + string(ratio));
		}
		if(!array_contains(hit_list,obj_struct._id )){
			array_push(hit_list,obj_struct._id);
		}
		
			vel.frameMult ++;	
			vel.mult += global.multiplierRate*vel.frameMult*array_length(hit_list) * ratio;
			var boostlimiter =500;
			var x_vel_mod = vel.x_vel*ratio/boostlimiter;
			var y_vel_mod = vel.y_vel*ratio/boostlimiter;
			if(global.normalizeFlybyBoost && ratio > 0.8){
				var v_mag = sqrt(power(vel.x_vel,2) + power(vel.y_vel,2));
				var delta_x = (obj_struct.v2x - vel.x_pos);
				var delta_y = obj_struct.v2y - vel.y_pos;
				var sin_theta = delta_x/sqrt_dist;
				var cos_theta = delta_y/sqrt_dist;
				x_vel_mod = (sin_theta*v_mag)*(vel.mult/boostlimiter);
				y_vel_mod = (cos_theta*v_mag)*(vel.mult/boostlimiter);
			}
			vel.x_vel	+=  x_vel_mod
			vel.y_vel	+= y_vel_mod
		if(!preview){
			
			
			multiTimer = multiLifespan;
			multi_x = x;
			multi_y = y;
			
		}else{
		}
		
	}
}

function get_projectile_mass(radius){
	return(radius) + global.projectileMassFactor;
}
function get_square_distance(obj_struct, subj_x, subj_y){
	
	var end_dist_x = (obj_struct.v2x - subj_x);
	var end_dist_y = (obj_struct.v2y - subj_y);
	return (power(end_dist_x,2) + power(end_dist_y,2));
}
function get_actual_radius(obj_struct){
	if(struct_exists(obj_struct,"damage")){
		var true_r = obj_struct.r + obj_struct.damage;
		if(obj_struct.name == "end"){
			true_r = obj_struct.r - obj_struct.damage;
		}
		return true_r;
	}else{
		return obj_struct.r;	
	}
	
}
function collision_check(obj_struct, dist, subj_r){
	
	var true_r =  (obj_struct.dr);
	return (dist < power( true_r + subj_r,2));
}
function get_component_mass(obj_struct){
	return power( (obj_struct.dr),2);
	
}
function get_gravitational_force(obj_struct, subj_dist, subj_mass){
	if(struct_exists(obj_struct,"v2x") &&struct_exists(obj_struct,"v2y")&&struct_exists(obj_struct,"r")&&struct_exists(obj_struct,"damage")){
		var grav = global.simRate * gravity_function(subj_mass,(obj_struct.mass), subj_dist);
		return grav;
	}
	return 0;
}

function gravity_function(m_1, m_2, d_squared){
	return 	(m_1* m_2 *global.gravitation)/d_squared;
}
function modify_struct_gravitational_field(delta_mass, d_squared){
	var delta_force = gravity_function(delta_mass, global.grid_mass, d_squared);
	return delta_force;
}
function get_gravitational_force_at_point(subj_x, subj_y, subj_mass = 1, _level = noone){
	if(_level == noone)
		_level = obj_game.level;
	var starttime = current_time;
	var ratio = 0;
	var end_dist_x = (level.endpoint.v2x - subj_x);
	var end_dist_y = (level.endpoint.v2y - subj_y);
	var dist =(power(end_dist_x,2) + power(end_dist_y,2)); 
	
	ratio = get_gravitational_force(_level.endpoint,dist,subj_mass);	
	
	for(var i = 0; i < array_length(_level.components); i++){
		end_dist_x = (_level.components[i].v2x - subj_x);
		end_dist_y = (_level.components[i].v2y - subj_y);
		dist = power(end_dist_x,2) + power(end_dist_y,2); 
		ratio += get_gravitational_force(_level.components[i], dist, subj_mass);
	}
	return ratio;
}


function get_total_gravitational_acceleration(subj_x, subj_y, subj_mass = 1){
	var starttime = current_time;
	var ratio = 0;
	var end_dist_x = (obj_game.level.endpoint.v2x - subj_x);
	var end_dist_y = (obj_game.level.endpoint.v2y - subj_y);
	var dist =(power(end_dist_x,2) + power(end_dist_y,2)); 
	var x_vel = 0;
	var y_vel = 0;
	var x_ratio = power(end_dist_x,2) /dist;
	var y_ratio = power(end_dist_y,2)/dist;
	
	ratio = get_gravitational_force(obj_game.level.endpoint,dist,subj_mass);	
	if(end_dist_x <0)
		x_ratio *= -1;
	if(end_dist_y < 0)
		y_ratio *= -1;
	var velModX =x_ratio*ratio
	var velModY = y_ratio*ratio
	velModX =  clamp(velModX, -abs(end_dist_x),abs(end_dist_x));
	velModY = clamp(velModY, -abs(end_dist_y),abs(end_dist_y));
	x_vel += velModX
	y_vel += velModY;
	var neighbors = array_create(2);
	for(var i = 0; i < array_length(obj_game.level.components); i++){
		for(var k = 0; k < array_length(neighbors); k++){
			if(neighbors[k] == 0){
				neighbors[k] = obj_game.level.components[i];
				break;
			}
			if(get_square_distance(obj_game.level.components[i], subj_x, subj_y) < get_square_distance(neighbors[k],subj_x, subj_y)){
				if(k < array_length(neighbors)-1){
					neighbors[k+1] = neighbors[k];	
					
				}
				neighbors[k] = obj_game.level.components[i];
				break;
				
			}
			
			
		}
		
	}
	
	for(var i = 0; i < array_length(neighbors); i++){
		if(neighbors[i] == 0)
			break;
			
		 end_dist_x = (neighbors[i].v2x - subj_x);
		 end_dist_y = (neighbors[i].v2y - subj_y);
			dist = power(end_dist_x,2) + power(end_dist_y,2); 
		
			ratio = get_gravitational_force(neighbors[i], dist, subj_mass);
			
			 x_ratio = power(end_dist_x,2) /dist;
			 y_ratio = power(end_dist_y,2)/dist;
			if(end_dist_x <0)
				x_ratio *= -1;
			if(end_dist_y < 0)
				y_ratio *= -1;
			velModX =x_ratio*ratio
			velModY = y_ratio*ratio
			velModX =  clamp(velModX, -abs(end_dist_x),abs(end_dist_x));
			velModY = clamp(velModY, -abs(end_dist_y),abs(end_dist_y));
			x_vel += velModX
			y_vel += velModY;
	}
	var return_array = array_create(2);
	return_array[0] = x_vel;
	return_array[1] = y_vel;
	return return_array;
}
function world_coordinate_to_sim_grid_index(x_pos, y_pos){
	var index_x = 	(x_pos + global.play_area_radius)/global.sim_grid_size;
	var index_y = 	(y_pos + global.play_area_radius)/global.sim_grid_size;
	return [index_x, index_y];
}
function sim_grid_index_to_world_coordinate(index_x, index_y){
	var x_pos = (index_x * global.sim_grid_size)-global.play_area_radius;
	var y_pos = (index_y * global.sim_grid_size)-global.play_area_radius;
	return [x_pos, y_pos];
}
function get_gravity_depth_at_coordinate(x_pos, y_pos, radius = 0){
	if(!global.objectDepth)
		return depth;
	var indices = world_coordinate_to_sim_grid_index(x_pos, y_pos);
	var index_x = 	indices[0];
	var index_y = 	indices[1];
	radius = radius/global.sim_grid_size;
	var min_x = floor(index_x-radius);
	var min_y = floor(index_y-radius);
	var max_x = ceil(index_x+radius);
	var max_y = ceil(index_y+radius);
	var x_lerp = index_x%1;
	var y_lerp = index_y % 1;
	if(index_x > global.sim_grid_count-2||index_y > global.sim_grid_count-2 ||
	index_x < 1 || index_y <1){
		return 0;
	}
					
	if(radius > 0){
		x_lerp = 0.5;
		y_lerp = 0.5;
	}
	var grav_1 = global.depth_array[min_x][min_y][2]
	var grav_2 = global.depth_array[min_x][max_y][2]
	var grav_3 = global.depth_array[max_x][min_y][2]
	var grav_4 = global.depth_array[max_x][max_y][2]
	var y_grav_1 = lerp(grav_1, grav_2, y_lerp); 
	var y_grav_2 = lerp(grav_3, grav_4, y_lerp);
	var y_grav = lerp(y_grav_1,y_grav_2,x_lerp);
	var x_grav_1 = lerp(grav_1, grav_3, x_lerp); 
	var x_grav_2 = lerp(grav_2, grav_4, x_lerp);
	
	var x_grav = lerp(x_grav_1,x_grav_2,y_lerp);
	return (	y_grav + x_grav)/2;
}

function init_sim_grid(){
	
	var starttime = current_time;
	global.depth_array = array_create(global.sim_grid_count);	
	for(var i = global.sim_grid_count-1; i >= 0; i--)
	{
		global.depth_array[i] = array_create(global.sim_grid_count);
		for(var k = global.sim_grid_count-1; k >=0; k--){
			global.depth_array[i][k] = array_create(4, -1);
			var x_coord = i*global.sim_grid_size-(global.play_area_radius);
			var y_coord = k*global.sim_grid_size -(global.play_area_radius);
			global.depth_array[i][k][0] = x_coord;
			global.depth_array[i][k][1] = y_coord;
			global.depth_array[i][k][2] = get_edge_falloff(x_coord, y_coord);
			//global.depth_array[i][k][3] = get_vert_alpha(x_coord, y_coord);
		}
	}
	log_grid_update_performance_time(current_time - starttime);
	show_debug_message("Full grid calculated in " + string(current_time - starttime) + " ms");
}
function calculate_sim_grid(){
	
	var starttime = current_time;
	global.depth_array = array_create(global.sim_grid_count);	
	for(var i = global.sim_grid_count-1; i >= 0; i--)
	{
		global.depth_array[i] = array_create(global.sim_grid_count);
		for(var k = global.sim_grid_count-1; k >=0; k--){
			global.depth_array[i][k] = array_create(4, -1);
			var x_coord = i*global.sim_grid_size-(global.play_area_radius);
			var y_coord = k*global.sim_grid_size -(global.play_area_radius);
			global.depth_array[i][k][0] = x_coord;
			global.depth_array[i][k][1] = y_coord;
			global.depth_array[i][k][2] = get_full_z_depth(x_coord, y_coord ,global.grid_mass);
			//global.depth_array[i][k][3] = get_vert_alpha(x_coord, y_coord);
		}
	}
	log_grid_update_performance_time(current_time - starttime);
	show_debug_message("Full grid calculated in " + string(current_time - starttime) + " ms");
}


function trigger_spiral_grid_update(x_coord, y_coord){
	var d_array_start_x = max(0,round(x_coord + global.play_area_radius- radius)/global.sim_grid_size);
	var d_array_start_y =max(0, round(y_coord + global.play_area_radius - radius)/global.sim_grid_size);
	obj_game.grid_update_start_x = 	d_array_start_x;
	obj_game.grid_update_start_y = d_array_start_y;
	obj_game.grid_update_curr_x = d_array_start_x;
	obj_game.grid_update_curr_y = d_array_start_y;
	
}
function trigger_grid_update(_level = noone, _start_x = 0, _start_y= 0,_delta_m = 0){
	if(global.spiralUpdate){
		create_spiral_grid_update_struct(_level,_start_x,_start_y,_delta_m)
	}else{
		if(array_length(obj_game.grid_updates)<3)
			create_grid_update_struct(_level);
		}
}
function create_grid_update_struct(_level = noone){
	if(_level == noone)
		_level = obj_game.level;
	array_push(obj_game.grid_updates,{
	start_x: 0,
	start_y: 0,
	curr_x: 0,
	curr_y: 0,
	level: _level,
	finished: false
	})
	
}

function get_full_z_depth(_x,_y,_mass){
	var g_depth = get_gravitational_force_at_point(_x, 
	_y,_mass);
	if(abs(g_depth) >1)
		return g_depth + get_edge_falloff(_x, _y);
	else
	return (get_edge_falloff(_x, _y))
}

function get_edge_percentage(_x, _y, _r = 0){
	return clamp(1-((power(_x -global.play_area_radius,2) + power(_y-global.play_area_radius,2) ) /global.play_area_radius_sq),0,1);
	
}
function get_edge_falloff(_x, _y){
	
	
	var edgDist = get_edge_percentage(_x, _y) * global.edgeFalloff;
	return edgDist;
}
function async_sim_grid_update(grid_struct){
	var	_level = grid_struct.level;
	var update_count = 0;
	var startTime = current_time;
	var temp_curr_y = grid_struct.curr_y;
	if(global.gridDebugMessages)
		show_debug_message ("Grid Simulation Update started at coordinate (" + string(grid_struct.curr_x) + ", " + string(grid_struct.curr_y) + ")");
	for(var i = grid_struct.curr_x; i <= global.sim_grid_count; i++)
	{
		if(i>= global.sim_grid_count){
			log_grid_update_performance_time(current_time - startTime);
			if(global.fullGrid)
				//update_grid_points_in_buffer(grid_struct.curr_x,grid_struct.curr_y, update_count);
			grid_struct.finished = true;
			return;
		}
		for(var k = temp_curr_y; k < global.sim_grid_count; k++){
			global.depth_array[@i][@k][@2] = get_full_z_depth(i*global.sim_grid_size -(global.play_area_radius),k*global.sim_grid_size-(global.play_area_radius),global.grid_mass);
			
			if(global.fullGrid)
				set_grid_point_vertices(i,k)
			update_count++;
			if(update_count > global.grid_update_chunk/((array_length(_level.components)+1)
			//*array_length(obj_game.grid_updates)
			)){
				log_grid_update_performance_time(current_time - startTime);
				if(global.fullGrid){
					//set_grid_point_vertices(grid_struct.curr_x,grid_struct.curr_y);
				}
				grid_struct.curr_x =i;
				grid_struct.curr_y =k;
				return;
			}
		}
		temp_curr_y = 0;
	}
}
function create_spiral_grid_update_struct(_level = noone, _start_x = 0, _start_y= 0,_delta_m = 0){
	if(_level == noone)
		_level = obj_game.level;
	array_push(obj_game.spiral_grid_updates,{
	start_x: int64(_start_x),
	start_y: int64(_start_y),
	curr_x: int64(_start_x),
	curr_y: int64(_start_y),
	curr_i: 0,
	count: power(global.sim_grid_count,2),
	modifier: 1,
	n: 0,
	n_index: 1,
	delta_m: _delta_m,
	level: _level,
	finished: false,
	real_index:0
	})
	
}
function square_dist_from_coord_pair(coordinates_1, coordinates_2){
	return (power(coordinates_1[0] - coordinates_2[0],2) + power(coordinates_1[1] - coordinates_2[1],2));	
}
function async_spiral_sim_grid_update(grid_struct){
	var	_level = grid_struct.level;
	var update_count = 0;
	var startTime = current_time;
	var temp_curr_y = grid_struct.curr_y;
	var temp_curr_x = grid_struct.curr_x;
	var temp_curr_i = grid_struct.curr_i;
	var temp_curr_n = grid_struct.n;
	var temp_curr_n_index = grid_struct.n_index;
	var temp_modifier = grid_struct.modifier;
	var coordinates = sim_grid_index_to_world_coordinate(grid_struct.start_x, grid_struct.start_y);
	var panic_button = 0;
	var panic_limit = grid_struct.count* 2;
	
	if(global.debugMode == DebugMode.SCREEN){
		show_debug_message("Beginning frame spiral grid at count number " + string(temp_curr_i) + " modulo number " + string(temp_curr_n) + " and modulo index " + string(temp_curr_n_index) + " with grid dimension " + string(global.sim_grid_count));	
	}
	while(temp_curr_i <= grid_struct.count){
		if(temp_curr_i >= grid_struct.count){
			log_grid_update_performance_time(current_time - startTime);
			//if(global.fullGrid)
				//update_grid_points_in_buffer(grid_struct.curr_x,grid_struct.curr_y, update_count);
			grid_struct.finished = true;
			return;
		}
		for(var k = temp_curr_n_index; k < temp_curr_n*2; k++){
			update_count++;
			if(update_count > global.grid_update_chunk/array_length(obj_game.spiral_grid_updates)
			){
				//log_grid_update_performance_time(current_time - startTime);
				if(global.fullGrid){
					//update_grid_points_in_buffer(grid_struct.curr_x,grid_struct.curr_y, update_count-1);
				}
				grid_struct.curr_x = temp_curr_x;
				grid_struct.curr_y = temp_curr_y;
				grid_struct.curr_i = temp_curr_i;
				grid_struct.n = temp_curr_n;
				grid_struct.n_index = k;
				grid_struct.modifier = temp_modifier;
				return;
			}
			grid_struct.real_index++;
			if(global.debugMode == DebugMode.SCREEN){
				//show_debug_message("Modifying coordinate (" + string(temp_curr_x) + ", " + string(temp_curr_y) + ") at count number " + string(temp_curr_i) + " modulo number " + string(temp_curr_n) + " modulo index " + string(k) + " and real index " + string(grid_struct.real_index));	
			}
			if(panic_button>panic_limit){
				show_debug_message("Something horribly wrong has happened in async_spiral_grid_update resulting in what would be an endless loop. exiting now");
				grid_struct.finished = true;
				return;
			}
			if(k<temp_curr_n){
					//temp_curr_y += temp_modifier;
				if(temp_curr_y + temp_modifier > array_length(global.depth_array)){
					var edge_limit = temp_curr_n + temp_curr_x;
					var remaining_steps = temp_curr_n - k - 1;
					if(edge_limit < array_length(global.depth_array)){
						temp_modifier *= -1;
						k = remaining_steps;
						temp_curr_x = edge_limit;
						temp_curr_n ++;
					}else{
						if(temp_curr_y - k-1 < 0){
							
							temp_curr_n += 2;
							temp_curr_y = 0;
							temp_curr_x = temp_curr_x -1;
							k = (temp_curr_y - k-1)*-1;
						}else{
							temp_curr_y = 	temp_curr_y - k - 1;
							temp_modifier *= -1;
							temp_curr_x = array_length(global.depth_array)-1;
							k = edge_limit - array_length(global.depth_array)-1;
							temp_curr_n ++;
						}
					}
				}else if (temp_curr_y + temp_modifier < 0){
					
					
				}else{
					temp_curr_y += temp_modifier;
				}
			}
			if(k>=temp_curr_n){
				
					//temp_curr_x += temp_modifier;	
				if(temp_curr_x + temp_modifier > array_length(global.depth_array)){
					var edge_limit = -temp_curr_n + temp_curr_y;
					var remaining_steps = temp_curr_n*2 - k - 1;
					if(edge_limit > 0){
						temp_modifier *= -1;
						temp_curr_y = edge_limit;
						temp_curr_n ++;
						k = remaining_steps + temp_curr_n;
					}else{
						if(temp_curr_y - k-1 < 0){
							
							temp_curr_n += 2;
							temp_curr_y = 0;
							temp_curr_x = temp_curr_x -1;
							k = (temp_curr_y - k-1)*-1;
						}else{
							temp_curr_y = 	temp_curr_y - k - 1;
							temp_modifier *= -1;
							temp_curr_x = array_length(global.depth_array)-1;
							k = edge_limit - array_length(global.depth_array)-1;
							temp_curr_n ++;
						}
					}
					
				}else if (temp_curr_x + temp_modifier < 0){
					
					
				}else{
					temp_curr_x += temp_modifier;	
				}
				
			}
			if(temp_curr_x >= array_length(global.depth_array) || temp_curr_y >= array_length(global.depth_array)
			|| temp_curr_x < 0 || temp_curr_y < 0){
				show_debug_message("Exceeded limits at coordinate (" + string(temp_curr_x) + ", " + string(temp_curr_y) + ") at count number " + string(temp_curr_i) + " modulo number " + string(temp_curr_n) + " and modulo index " + string(k));	
				
				continue;
			}
			if(grid_struct.delta_m == 0)
				global.depth_array[@temp_curr_x][@temp_curr_y][@2] = get_full_z_depth(global.depth_array[@temp_curr_x][@temp_curr_y][0],global.depth_array[@temp_curr_x][@temp_curr_y][1],global.grid_mass);
			else{
				//global.depth_array[@temp_curr_x][@temp_curr_y][@2] += 150;
				
				var gravMod = modify_struct_gravitational_field(grid_struct.delta_m, square_dist_from_coord_pair(coordinates, global.depth_array[@temp_curr_x][@temp_curr_y]));
				if(abs(gravMod)< 0.1){	
					show_debug_message("ending spiral update due to insignificant force: " + string(gravMod));
					grid_struct.finished = true;
					return;
				}
				
				global.depth_array[@temp_curr_x][@temp_curr_y][@2] += gravMod;
			}
			if(global.debugMode < DebugMode.NONE){
				 obj_game.debug_x= global.depth_array[@temp_curr_x][@temp_curr_y][0];
				 obj_game.debug_y =  global.depth_array[@temp_curr_x][@temp_curr_y][1];
			}
			var coord_index = sim_grid_index_from_coord([temp_curr_x, temp_curr_y]);
			if(global.fullGrid && !array_contains(obj_game.updated_grid_points, coord_index ))
				array_push( obj_game.updated_grid_points, coord_index);

			temp_curr_i++;
		}
		if(temp_curr_n = 0){
			if(temp_curr_x > array_length(global.depth_array) || temp_curr_y > array_length(global.depth_array)
			|| temp_curr_x < 0 || temp_curr_y < 0)
				continue;
			
			global.depth_array[@temp_curr_x][@temp_curr_y][@2] = get_full_z_depth(global.depth_array[@temp_curr_x][@temp_curr_y][0],global.depth_array[@temp_curr_x][@temp_curr_y][1],global.grid_mass);
		
			var coord_index = sim_grid_index_from_coord([temp_curr_x, temp_curr_y]);
			if(global.fullGrid && !array_contains(obj_game.updated_grid_points, coord_index ))
				array_push( obj_game.updated_grid_points, coord_index);
			update_count++;
			temp_curr_i++;
		}
		temp_curr_n_index = 0;
		temp_curr_n++;
		temp_modifier *= -1;
	}
}
function ai_player(){
	if(current_time > lastShot+shotDelay){
		var baseXVector = -(level.endpoint.v2x-level.start.v2x)/2;
		var baseYVector = (level.endpoint.v2y-level.start.v2y)/2;
		for(var i = 0; i <array_length(level.components); i++){
			baseXVector -= 	(level.components[i].v2x-level.start.v2x)/array_length(level.components)* (level.components[i].r+level.components[i].damage)/100;	
			baseYVector += 	(level.components[i].v2y-level.start.v2y)/array_length(level.components) * (level.components[i].r+level.components[i].damage)/100;
		}
		cursor_x = level.start.v2x + launch_vector_x;
		cursor_y = level.start.v2y + launch_vector_y;
		if(launch_vector_x == 0)
			launch_vector_x =  /*random_range(.2, .4)*/-.75 *baseXVector
		if(launch_vector_y == 0)
			launch_vector_y = 0
			//baseYVector*.75
					
		simulate_trajectory(level.start.v2x, level.start.v2y, launch_vector_x, launch_vector_y,shot_preview_x, shot_preview_y, shot_preview_r, shot_preview_mult);
		create_projectile(level.start.v2x, level.start.v2y, launch_vector_x, launch_vector_y);	
		simShotCount++;
			if(simShotCount>7){
				simShotCount = 0;
				launch_vector_x =  random_range(.2, .4) *baseXVector
				launch_vector_y = random_range(.2, .4) *baseYVector
				lastShot = current_time+4000;
			}else{
				lastShot = current_time;
			}
		}	
}
function sim_grid_coord_from_index(i){
	var x_coord = floor(i/global.sim_grid_count);
	var y_coord = int64(i%global.sim_grid_count);
	return [x_coord, y_coord];
	
}
function sim_grid_index_from_coord(coord){
	return coord[0]* global.sim_grid_count + coord[1];
	
}

////LEGACY FUNCTIONS FOR INSURANCE
//function async_sim_grid_update(grid_struct){
//	var	_level = grid_struct.level;
//	if(obj_game.grid_update_start_x == -1 || obj_game.grid_update_start_y == -1){
//		if(!obj_game.grid_update_pending){
//			return;
//		}else{
			
//			obj_game.grid_update_pending = false;
//			trigger_grid_update();
//			return;
				
//		}
//	}
//	var update_count = 0;
//	var startTime = current_time;
//	var temp_curr_y = obj_game.grid_update_curr_y;
//	if(global.gridDebugMessages)
//		show_debug_message ("Grid Simulation Update started at coordinate (" + string(obj_game.grid_update_curr_x) + ", " + string(obj_game.grid_update_curr_y) + ")");
//	for(var i = obj_game.grid_update_curr_x; i <= global.sim_grid_count; i++)
//	{
//		if(i>= global.sim_grid_count){
//			var endIndex = i*global.sim_grid_count;
//			var startIndex = grid_update_curr_x * global.sim_grid_count + obj_game.grid_update_curr_y;
			
//			log_grid_update_performance_time(current_time - startTime);
//			//show_debug_message("updated sim grid indices " + string(startIndex) + " through " + string(endIndex) + " out of " + string(power(global.sim_grid_count,2))+ " in " + string(current_time-startTime) + " ms"); 
				
//			if(global.fullGrid)
//				update_grid_points_in_buffer(grid_update_curr_x,grid_update_curr_y, update_count);
//			obj_game.grid_update_start_x = -1;
//			obj_game.grid_update_start_y = -1;
//			obj_game.grid_update_curr_x = obj_game.grid_update_start_x;
//			obj_game.grid_update_curr_y = obj_game.grid_update_start_y;
			
//			if(global.gridDebugMessages)
//				show_debug_message ("Grid Simulation Update Completed at coordinate (" + string(obj_game.grid_update_curr_x) + ", " + string(obj_game.grid_update_curr_y) + ")");
//			obj_game.grid_trigger = true;
//			//if(global.fullGrid)
//			//	fill_grid_buffer(global.fullGrid);
//			return;
//		}
//		for(var k = temp_curr_y; k < global.sim_grid_count; k++){
//			if(obj_game.grid_update_deltas[2] == 0){
//				global.depth_array[@i][@k][@2] = get_gravitational_force_at_point(i*global.sim_grid_size -(global.play_area_radius), 
//				k*global.sim_grid_size-(global.play_area_radius),global.grid_mass);
//				var alpha = clamp(((power(i*global.sim_grid_size -(global.play_area_radius),2) + power(k*global.sim_grid_size-(global.play_area_radius),2) ) /global.play_area_radius_sq),0,1);
//				var edgDist = alpha * global.edgeFalloff;
//				global.depth_array[i][k][2] += edgDist;
//			}else{
//				var dist =  power(global.depth_array[@i][@k][@0]-obj_game.grid_update_deltas[0],2) +  power(global.depth_array[@i][@k][@1]-obj_game.grid_update_deltas[1],2)
//				global.depth_array[@i][@k][@2] += modify_struct_gravitational_field(obj_game.grid_update_deltas[2], dist);
				
//			}
//			if(global.gridDebugMessages){
//				show_debug_message("Sim Grid Coordinate (" + string(i) + ", " + string(k) + ") assigned at update count " + string(update_count)); 	
//			}
//			update_count++;
//			if(update_count > obj_game.grid_update_chunk/(array_length(_level.components)+1)){
//				var endIndex = i*global.sim_grid_count + k;
//				var startIndex = obj_game.grid_update_curr_x * global.sim_grid_count + obj_game.grid_update_curr_y;
				
//				log_grid_update_performance_time(current_time - startTime);
//				if(global.gridDebugMessages|| global.inBrowser)
//					show_debug_message ("Grid Simulation Update Ended at coordinate (" + string(i) + ", " + string(k) + ") after " + string(update_count) + " updates");
//				if(global.fullGrid){
//					update_grid_points_in_buffer(grid_update_curr_x,grid_update_curr_y, update_count-1);
//				}
//				//show_debug_message("updated sim grid indices " + string(startIndex) + " through " + string(endIndex) + " out of " + string(power(global.sim_grid_count,2))+ " in " + string(current_time-startTime) + " ms\nCurrent Update Count: " + string(update_count)); 
//				obj_game.grid_update_curr_x =i;
//				obj_game.grid_update_curr_y =k;
//				obj_game.grid_trigger = true;
//				return;
//			}
//		}
//		temp_curr_y = 0;
//	}
//}