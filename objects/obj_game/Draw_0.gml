/// @description Insert description here
// You can write your code in this editor

//camera_set_proj_mat(main_camera,global.projection_matrix);
//camera_set_view_mat(main_camera, global.view_matrix);
//view_set_camera(0, global.camera);
//camera_apply(main_camera);

var startTime = current_time;
draw_game(true,0,0,1, level);
log_draw_performance_time(current_time - startTime);
global.drawTime = get_array_average(global.drawTimeArray);
shader_reset();