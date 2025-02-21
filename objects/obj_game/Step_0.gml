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
	
}
log_grid_update_performance_time(current_time - startTime);
startTime = current_time;
for(var i = 0; i < array_length(updated_grid_points); i++){
	var coords = index_to_sim_grid_coordinate(updated_grid_points[i]);
	set_grid_point_vertices(coords[0], coords[1]);
}
log_grid_vertex_performance_time(current_time - startTime);
updated_grid_points = array_create(0);
if(global.debugMode != DebugMode.SCREEN || global.Game.roomFrame%5 == 0){
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
	
		if( input_any_pressed()){
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
	if(!instance_exists(obj_main_menu)){
		if(!postGame)
			process_user_inputs();
	}
	else{
		ai_player();
	}
}
set_object_positions();
set_cursor_position();
set_camera_view();
if(global.Law.threeD && !global.Settings.fullGrid.value){
	if(global.Graphics.gridCountX != global.Graphics.prev_grid_count_x 
	|| global.Graphics.gridCountY != global.Graphics.prev_grid_count_y
	|| global.Graphics.prev_grid_offset_x != global.Graphics.gridOffsetX 
	|| global.Graphics.prev_grid_offset_y != global.Graphics.gridOffsetY 
	|| global.Graphics.prev_grid_thickness != global.Settings.gridThickness.value)
	{
	    fill_grid_buffer();
	}
}
register_previous_grid_details();