/// @description This event tracks the level completion state, the user's inputs, and the states of the camera and grid
set_cursor_type();
finished_grid_updates = array_create(0);
var startTime = current_time;
for(var i = 0; i < min(array_length(grid_updates),1); i++){
	async_sim_grid_update(grid_updates[i]);
	if(grid_updates[i].finished){
		array_push( finished_grid_updates, i);	
	}
}
for(var i = array_length(finished_grid_updates)-1; i >=0; i--){
	array_delete(grid_updates,finished_grid_updates[i],1);
	
}log_grid_update_performance_time(current_time - startTime);
startTime = current_time;
for(var i = 0; i < array_length(updated_grid_points); i++){
	var coords = index_to_sim_grid_coordinate(updated_grid_points[i]);
	set_grid_point_vertices(coords[0], coords[1]);
}log_grid_vertex_performance_time(current_time - startTime);
updated_grid_points = array_create(0);
if(global.debugMode != DebugMode.SCREEN || room_frame%5 == 0){
	finished_spiral_grid_updates = array_create(0);
	for(var i = 0; i < array_length(spiral_grid_updates); i++){
		async_spiral_sim_grid_update(spiral_grid_updates[i]);
		if(spiral_grid_updates[i].finished){
			array_push( finished_spiral_grid_updates, i);	
		}
	}
	for(var i = array_length(finished_spiral_grid_updates)-1; i >=0; i--){
		array_delete(spiral_grid_updates,finished_spiral_grid_updates[i],1);
	
	}
}

if(!global.intro && window_has_focus()){
	if(!postGame){
		level_end_update();
	}
	else{
	
		if( mouse_check_button_released(mb_any)){
			end_postgame();
		}	
		return;
	}
	
	set_cursor_delta();
	increment_game_timers();
	if(!global.editMode){
		if(level_end_check()){
			return;	
		}
	}
	if(room == game_room){
		if(!postGame)
			process_user_inputs();
	}
	else{
		ai_player();
	}
}
set_cursor_position();
set_camera_view();
if(global.threeD && !global.fullGrid){
	if(grid_x_count != prev_grid_x_count 
	|| grid_y_count != prev_grid_y_count
	|| prev_grid_x_offset != grid_x_offset 
	|| prev_grid_y_offset != grid_y_offset 
	|| prev_grid_thickness != global.grid_thickness||
	grid_trigger == true)
	{
	    fill_grid_buffer();
	}
}
register_previous_grid_details();