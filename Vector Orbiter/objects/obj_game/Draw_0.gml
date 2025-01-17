/// @description Insert description here
// You can write your code in this editor

//camera_set_proj_mat(main_camera,global.projection_matrix);
//camera_set_view_mat(main_camera, global.view_matrix);
//view_set_camera(0, global.camera);
//camera_apply(main_camera);

var startTime = current_time;
if(global.intro || postGame){
	return;	
}
draw_background();
gpu_set_depth(baseDepth);
draw_set_circle_precision(32/circle_precision_factor)
if(global.inBrowser){
	camera_apply(global.camera);
	gpu_set_alphatestenable(true)
}
draw_grid();
if(global.show_ui)
	draw_preview_trajectory();
if(global.objectDepth){
	gpu_set_depth(baseDepth)
	gpu_set_zwriteenable(true)
	gpu_set_ztestenable(true);
}
draw_components()
draw_shoot_cursor();
if(global.objectDepth){
	gpu_set_depth(baseDepth);
	gpu_set_zwriteenable(false)
	gpu_set_ztestenable(false);
}
draw_set_circle_precision(16/circle_precision_factor)
draw_projectiles();
draw_start_point();
draw_end_point();
if(global.objectDepth){
	gpu_set_depth(baseDepth);
	gpu_set_zwriteenable(false)
	gpu_set_ztestenable(false);
}
draw_explosions();
gpu_set_depth(baseDepth);
draw_aim_cursor();
log_draw_performance_time(current_time - startTime);
global.drawTime = get_array_average(global.drawTimeArray);
shader_reset();
if(global.spiralUpdate &&  global.debugMode < DebugMode.NONE){
	draw_set_alpha(1);
	draw_set_color(c_lime);
	draw_circle(debug_x, debug_y, global.base_grid_size/2, false);	
	
}