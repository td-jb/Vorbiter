// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
#region vertex manipulation functions
function set_grid_shader(){

	shader_set(shd_grid_shader);
	var deptha = shader_get_uniform(shd_grid_shader, "f_depth_alpha");
	var outline = shader_get_uniform(shd_grid_shader, "f_outline");
	var maxAlpha = shader_get_uniform(shd_grid_shader, "f_max_alpha");
	var cosP = shader_get_uniform(shd_grid_shader, "f_cos_pulse");
	var pHeight = shader_get_uniform(shd_grid_shader, "f_pulse_height");
	shader_set_uniform_f(deptha, global.Law.sqPlayRadius);
	shader_set_uniform_f(outline, floor(global.Graphics.screenScale));
	shader_set_uniform_f(maxAlpha, global.Settings.gridAlpha.value);	
	if(global.Law.inBrowser)
		shader_set_uniform_f(pHeight, 1000);	
	else
		shader_set_uniform_f(pHeight, -250);	
	var p_f = ((global.Game.roomFrame)%((global.Law.physRate*4*global.Game.pulseRate)))/(global.Law.physRate*4*global.Game.pulseRate);
	shader_set_uniform_f(cosP, p_f);
}
function create_vertex_format(){
	
	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_colour();
	vertex_format_add_texcoord();
	return vertex_format_end();
}
function create_sphere(_x, _y, _r, _precision ){

	
}

function fill_grid_buffer(full = false){
		var starttime = current_time;
		var count_x =global.sim_grid_count;
		var count_y =global.sim_grid_count;
		var d_array_start_x = 0;
		var d_array_start_y = 0;
		var grid_ratio = 1;
			
		if( !full){
			d_array_start_x = round(global.Graphics.gridOffsetX + global.Law.playRadius)/global.sim_grid_size;
			d_array_start_y = round(global.Graphics.gridOffsetY + global.Law.playRadius)/global.sim_grid_size;
			grid_ratio = global.Graphics.gridSize/global.sim_grid_size;
			count_x = global.Graphics.gridCountX;
			count_y = global.Graphics.gridCountY;
			
		}
		
			
		vertex_begin(global.Graphics.vertBuffer,global.Law.gridVertexFormat);
		for(var i = 1; i < count_x; i++){
			for(var k = 1; k <count_y; k++){
				var depth_x_1_index = d_array_start_x + i*grid_ratio;
				var depth_x_2_index = d_array_start_x + (i-1)*grid_ratio;
				var depth_y_1_index = d_array_start_y + (k)*grid_ratio;
				set_grid_point_vertices(depth_x_1_index, depth_y_1_index, grid_ratio, true);
			}//draw_line_width(i * global.Graphics.gridSize + global.Graphics.gridOffsetX, global.Graphics.gridStartY, i * global.Graphics.gridSize + global.Graphics.gridOffsetX, grid_height, (global.Graphics.gridSize*5)/global.Settings.baseGridSize.value );	
	
		}

		vertex_end(global.Graphics.vertBuffer);
		var endTime = current_time - starttime;
		log_grid_vertex_performance_time(endTime);
		if(global.gridDebugMessages || global.Law.inBrowser)
			show_debug_message("Full sim grid set with " + string(global.frame_vert_count) + " vertices in time " + string(endTime));
		global.frame_vert_count = 0;
}
function set_grid_point_vertices(depth_x_1_index,depth_y_1_index, grid_ratio = 1, init = false){
	var vert_index = -1;
	if(!init)
	{
					
		vertex_begin(global.Graphics.updateBuffer,global.Law.gridVertexFormat);
		vert_index = global.depth_array[depth_x_1_index][depth_y_1_index][3];
	}
	var depth_x_2_index = depth_x_1_index - grid_ratio;
	var depth_y_2_index = depth_y_1_index -grid_ratio;
	var startVert = global.frame_vert_count;
	if(depth_x_1_index >= array_length(global.depth_array) ||depth_y_1_index >= array_length(global.depth_array) ||
	depth_x_2_index < 0 || depth_y_2_index <0){
		return;
	}
	var x_1 = global.depth_array[depth_x_1_index][depth_y_1_index][0];
	var y_1 = global.depth_array[depth_x_1_index][depth_y_1_index][1];
	var x_2 = global.depth_array[depth_x_2_index][depth_y_2_index][0];
	var y_2 = global.depth_array[depth_x_2_index][depth_y_2_index][1];
	var x1_p = power(x_1,2);
	var x2_p = power(x_2,2);
	var y1_p = power(y_1,2);
	var y2_p = power(y_2,2);
	if(x1_p + y1_p > global.Law.sqPlayRadius && x2_p + y2_p > global.Law.sqPlayRadius)
		return;
	//var alpha = global.depth_array[depth_x_1_index][depth_y_1_index][3];
				
	var alpha = 1;
	if(os_browser == browser_firefox || os_browser == browser_unknown)
		alpha = get_vert_alpha(x_1, y_1);
		//
	var x_alpha = alpha;
	var y_alpha = alpha;
	var thickness = global.Settings.gridThickness.value;
	var scaleMod =  power(2,min(max(0,ceil(global.Graphics.screenScale /global.Settings.gridScaleFactor.value)),3));
	if(!global.Settings.fullGrid.value){
		thickness *= global.Graphics.screenScale;
		if(((global.Graphics.screenScale)%global.Settings.gridScaleFactor.value) > global.Settings.gridScaleFactor.value/2 && global.Graphics.screenScale <4){
			if((depth_x_1_index%scaleMod) != 0){
				y_alpha *= 1-((global.Graphics.screenScale*2) %global.Settings.gridScaleFactor.value)/global.Settings.gridScaleFactor.value;
				y_2 += thickness;
			}
			if((depth_y_1_index%scaleMod)!=0){
				x_alpha *= 1-((global.Graphics.screenScale*2) %global.Settings.gridScaleFactor.value)/global.Settings.gridScaleFactor.value;
				x_2 += thickness
			}
		}
	}
	var x_thickness = thickness;
	var y_thickness = thickness;
	if((depth_x_1_index%scaleMod) == 0){
		y_thickness = thickness/2;
	}
	if((depth_y_1_index%scaleMod)==0){
		x_thickness = thickness/2;
	}
	var z_1 = global.depth_array[depth_x_1_index][depth_y_1_index][2];
	var z_2 = global.depth_array[depth_x_2_index][depth_y_1_index][2];
	var z_3 = global.depth_array[depth_x_1_index][depth_y_2_index][2];
	var z_4 = global.depth_array[depth_x_2_index][depth_y_2_index][2];
					
	//draw horizontal line
	z_1 = clamp(z_1,0,global.Law.depthAlpha);
	z_2 = clamp(z_2,0,global.Law.depthAlpha);
	z_3 = clamp(z_3,0,global.Law.depthAlpha);
	z_4 = clamp(z_4,0,global.Law.depthAlpha);
	var alph_1 = 1
	//-(z_1/global.Law.depthAlpha);
	var alph_2 = 1
	//-(z_2/global.Law.depthAlpha)
	var alph_3 = 1
	//-(z_3/global.Law.depthAlpha)
	if(init)
	{
		global.depth_array[depth_x_1_index][depth_y_1_index][3] = global.frame_vert_count;
		add_grid_point_verts_to_buffer(global.Graphics.vertBuffer,x_1,y_1,x_2,y_2,z_1,z_2,z_3, z_4,thickness, thickness, alph_1,alph_2,alph_3,global.backgroundColor, x_alpha, y_alpha )
	}else{
		add_grid_point_verts_to_buffer(global.Graphics.updateBuffer,x_1,y_1,x_2,y_2,z_1,z_2,z_3, z_4,x_thickness, y_thickness,1, 1, 1,global.backgroundColor)
		var delta_vert = global.frame_vert_count + vert_index;
			
		vertex_end(global.Graphics.updateBuffer);
		if(global.gridDebugMessages|| global.Law.inBrowser)
			show_debug_message("Update sim grid set from " + string(vert_index) + " to "  + string(vert_index + global.frame_vert_count) + " vertices");
		if(vert_index < 0){
			show_debug_message("Vertex update attempted at index: " + string(vert_index) + " for coordinate (" + string(depth_x_1_index) + ", " + string(depth_y_1_index) +") aborted");	
			return;
		}
		vertex_update_buffer_from_vertex(global.Graphics.vertBuffer,vert_index,global.Graphics.updateBuffer);
		vert_index = -1;
	//if(global.gridDebugMessages)
		//show_debug_message("Sim Grid Coordinate (" + string(i) + ", " + string(k) +") assigned vertices " + string(startVert) + " through " + string(global.frame_vert_count));
				
	
	}
}
function update_grid_points_in_buffer(start_x, start_y,range){
	var startTime = current_time;
	var updateCount = 0
	var temp_start_y = start_y;
	if(global.gridDebugMessages || global.Law.inBrowser)
		show_debug_message("Sim Grid Vertex Update started at coordinates (" + string(start_x) + ", " + string(start_y) +") with range: " + string(range)); 
	if(!global.vertCopyRate){
		vertex_begin(global.Graphics.updateBuffer,global.Law.gridVertexFormat);
		var vert_index = -1;	
	}
	for(var j = start_x; j < global.sim_grid_count;j++){
		if(updateCount > range){
			
				//show_debug_message("Update Grid Coordinate (" + string(j) + ", " + string(l) +") break at update count " + string(updateCount));
				break;
		}
		for (var l = temp_start_y; l <global.sim_grid_count; l++){
			
			if(updateCount > range){
				break;
			}
			if(j == 0 || l == 0){
			if(global.gridDebugMessages)
				//show_debug_message("Update Grid Coordinate (" + string(j) + ", " + string(l) +") skipped due to index at update count " + string(updateCount));
				updateCount++;
				continue;
			}
			
			var x_1 = global.depth_array[j][l][0];
			var y_1 = global.depth_array[j][l][1];
			var x_2 = global.depth_array[j-1][l-1][0];
			var y_2 = global.depth_array[j-1][l-1][1];
			var x1_p = power(x_1,2);
			var x2_p = power(x_2,2);
			var y1_p = power(y_1,2);
			var y2_p = power(y_2,2);
			
			if(x1_p + y1_p > global.Law.sqPlayRadius && x2_p + y2_p > global.Law.sqPlayRadius){
				//show_debug_message("Update Grid Coordinate (" + string(j) + ", " + string(l) +") skipped due to range of position (" + string(x_1) + ", " + string(y_1)+ ") at update count " + string(updateCount));
				updateCount++;
				continue;
			}
			if(vert_index ==-1)
			{
				if(global.depth_array[j][l][3] != -1)
					vert_index = global.depth_array[j][l][3];
			
			}
			var frameStartVert = vert_index + global.frame_vert_count;
			//var alpha = global.depth_array[depth_x_1_index][depth_y_1_index][3];
			var alpha = 1
			if(os_browser == browser_firefox || os_browser == browser_unknown)
				alpha = get_vert_alpha(x_1, y_1);
			var x_alpha = alpha;
			var y_alpha = alpha;
			var thickness = global.Settings.gridThickness.value;
	
			var scaleMod = power(2,min(ceil(global.Graphics.screenScale/global.Settings.gridScaleFactor.value),4));
			var x_thickness = thickness;
			var y_thickness = thickness;
			if((j%scaleMod) == 0){
				y_thickness = thickness/2;
			}
			if((l%scaleMod)==0){
				x_thickness = thickness/2;
			}
			var z_1 = global.depth_array[j][l][2];
			var z_2 = global.depth_array[j-1][l][2];
			var z_3 = global.depth_array[j][l-1][2];
			var z_4 = global.depth_array[j-1][l-1][2];
			//var alph_1 = alpha *(1-(z_1/global.Law.depthAlpha));
			//var alph_2 = alpha *(1-(z_2/global.Law.depthAlpha))
			//var alph_3 = alpha *(1-(z_3/global.Law.depthAlpha))
			
			add_grid_point_verts_to_buffer(global.Graphics.updateBuffer,x_1,y_1,x_2,y_2,z_1,z_2,z_3, z_4,x_thickness, y_thickness,1, 1, 1,global.backgroundColor)
			var delta_vert = global.frame_vert_count + vert_index;
			if(global.gridDebugMessages)
				show_debug_message("Update Grid Coordinate (" + string(j) + ", " + string(l) +") assigned vertices " + string(frameStartVert) + " through " + string(delta_vert) + " at update count " + string(updateCount));
			updateCount++;
			
			if(global.vertCopyRate){
				vertex_end(global.Graphics.updateBuffer);
				if(global.gridDebugMessages|| global.Law.inBrowser)
					show_debug_message("Update sim grid set from " + string(vert_index) + " to "  + string(vert_index + global.frame_vert_count) + " vertices");
				if(vert_index < 0){
					show_debug_message("Vertex update attempted at index: " + string(vert_index) + " for start coordinate (" + string(start_x) + ", " + string(start_y) +") aborted");	
					return;
				}
				vertex_update_buffer_from_vertex(global.Graphics.vertBuffer,vert_index,global.Graphics.updateBuffer);
				vert_index = -1;
			}
		}
		temp_start_y = 0;
		
	}
	if(!global.vertCopyRate){
		vertex_end(global.Graphics.updateBuffer);
		if(global.gridDebugMessages|| global.Law.inBrowser)
			show_debug_message("Update sim grid set from " + string(vert_index) + " to "  + string(vert_index + global.frame_vert_count) + " vertices");
		if(vert_index < 0){
			show_debug_message("Vertex update attempted at index: " + string(vert_index) + " for start coordinate (" + string(start_x) + ", " + string(start_y) +") aborted");	
			return;
		}
		vertex_update_buffer_from_vertex(global.Graphics.vertBuffer,vert_index,global.Graphics.updateBuffer);
	}
	if(global.gridDebugMessages|| global.Law.inBrowser)
		show_debug_message("buffer updated successfully");
	
	global.frame_vert_count = 0;
	log_grid_vertex_performance_time(current_time - startTime);
}

function add_grid_point_verts_to_buffer(_buffer, x_1, y_1, x_2,y_2,z_1,z_2,z_3, z_4, x_thickness, y_thickness, alph_1, alph_2, alph_3, col, x_alph = 1, y_alph = 1){
		// Draw Horizontal Line
		
		if(global.Settings.fullGrid.value){
			var uvs = sprite_get_uvs(spr_grid, 0);
			var tex_1 = 0.45;
			var tex_2 = 0.55;
			add_vert_to_buffer(_buffer, x_1, y_1, z_1,x_alph, col, uvs[0], uvs[1]);
			add_vert_to_buffer(_buffer, x_1, y_2, z_3, x_alph, col,uvs[0], uvs[3]);		
			add_vert_to_buffer(_buffer, x_2, y_1, z_2, x_alph, col, uvs[2],uvs[1]);
		
			add_vert_to_buffer(_buffer, x_2, y_1, z_2, x_alph, col, uvs[2], uvs[1]);		
			add_vert_to_buffer(_buffer, x_1, y_2, z_3, x_alph, col, uvs[0],uvs[3]);
			add_vert_to_buffer(_buffer, x_2, y_2, z_4, x_alph, col,uvs[2],uvs[3]);
					
		}else{
			var uvs = sprite_get_uvs(spr_blank, 0);
			var tex_1 = 0.45;
			var tex_2 = 0.55;
			add_vert_to_buffer(_buffer, x_1, y_1, z_1,x_alph* alph_1, col, 0, 0);
			add_vert_to_buffer(_buffer, x_2, y_1, z_2, x_alph*alph_2, col,0, 0);		
			add_vert_to_buffer(_buffer, x_1, y_1+ x_thickness, z_1, x_alph* alph_1, col,0,0);
		
			add_vert_to_buffer(_buffer, x_2, y_1, z_2, x_alph*alph_2, col, 0,0);		
			add_vert_to_buffer(_buffer, x_1, y_1+ x_thickness, z_1, x_alph* alph_1, col,0,0);
			add_vert_to_buffer(_buffer, x_2, y_1+ x_thickness, z_2, x_alph* alph_2, col,0,0);
					
					
			//draw vertical line
		
			add_vert_to_buffer(_buffer, x_1, y_1, z_1,y_alph* alph_1, col,0,0);
			add_vert_to_buffer(_buffer, x_1, y_2, z_3,y_alph* alph_3, col,0,0);
			add_vert_to_buffer(_buffer, x_1+ y_thickness, y_1, z_1,y_alph* alph_1,col,0,0);
					
			add_vert_to_buffer(_buffer, x_1, y_2, z_3,y_alph* alph_3, col,0,0);
			add_vert_to_buffer(_buffer, x_1+ y_thickness, y_1, z_1,y_alph* alph_1, col,0,0);
			add_vert_to_buffer(_buffer, x_1+ y_thickness, y_2, z_3,y_alph* alph_3, col,0,0);
		}
}
function add_vert_to_buffer(_buffer, _x, _y, _z, alph, col, tex_1 = 0.5, tex_2 =0.5){
	vertex_position_3d(_buffer, _x,_y, _z);
	vertex_color(_buffer, col, alph)
	vertex_texcoord(_buffer,tex_1,tex_2);
	global.frame_vert_count++;
}
#endregion
#region camera/viewspace functions
function reset_view_min_max(){
	global.Graphics.prevMaxX = global.Graphics.maxProjectileX;
	global.Graphics.prevMaxY = global.Graphics.maxProjectileY;
	global.Graphics.prevMinX = global.Graphics.minProjectileX;
	global.Graphics.prevMinY = global.Graphics.minProjectileY;
	global.Graphics.minProjectileX = infinity;
	global.Graphics.maxProjectileX = -infinity;
	global.Graphics.minProjectileY = infinity;
	global.Graphics.maxProjectileY = -infinity;
}
function modify_min_max_from_struct(obj_struct, _check_offset = 100, _set_offset = 100, _r_mult = 2){
	var _r = get_actual_radius(obj_struct)*_r_mult;
	if(get_struct_x_position(obj_struct) - _r - _check_offset  < global.Graphics.minProjectileX)
		global.Graphics.minProjectileX = get_struct_x_position(obj_struct) - _r - _set_offset;
	if(get_struct_y_position(obj_struct) - _r- _check_offset <global.Graphics.minProjectileY)
		global.Graphics.minProjectileY = get_struct_y_position(obj_struct) - _r- _set_offset;
	if(get_struct_x_position(obj_struct) + _r+  _check_offset  > global.Graphics.maxProjectileX)
		global.Graphics.maxProjectileX = get_struct_x_position(obj_struct) + _r+ _set_offset;
	if(get_struct_y_position(obj_struct) + _r+ _check_offset  > global.Graphics.maxProjectileY)
		global.Graphics.maxProjectileY = get_struct_y_position(obj_struct) + _r+ _set_offset;
}
function set_camera_view(){
	/// function sketch
	// determine component minima and maxima
	// record last frame min/max
	// project next minima/maxima
	reset_view_min_max();
	modify_min_max_from_struct(obj_game.level.start)
		
	modify_min_max_from_struct(obj_game.level.endpoint)
	var componentCount = array_length(level.components);
	for (var i = 0; i < componentCount; i++){
		modify_min_max_from_struct(level.components[i], 100, 200);
	}
	
	with(obj_projectile){
		//if(projectile.v2x- projectile.r*4 < global.Graphics.minProjectileX)
		//	global.Graphics.minProjectileX = (projectile.v2x - projectile.r*4 );
		//if(projectile.v2y - projectile.r*4 < global.Graphics.minProjectileY)
		//	global.Graphics.minProjectileY = (projectile.v2y -projectile.r*4 );		
		//if(projectile.v2x + projectile.r*4 >global.Graphics.maxProjectileX)
		//	global.Graphics.maxProjectileX = (projectile.v2x +projectile.r*4 );
		//if(projectile.v2y+ projectile.r*4  >global.Graphics.maxProjectileY )
		//	global.Graphics.maxProjectileY = (projectile.v2y + projectile.r*4 );
		modify_min_max_from_struct(projectile,0,0,4);
	}
	if(!instance_exists(obj_main_menu)){
		modify_min_max_from_struct(global.Input, 20*global.Graphics.screenScale, 20*global.Graphics.screenScale)
	}
	var lerpFactor = 0.16;
	if(instance_exists(obj_main_menu))
		lerpFactor = 0.0001;
	var projectile_x_spread = lerp((global.Graphics.prevMaxX - global.Graphics.prevMinX) ,(global.Graphics.maxProjectileX - global.Graphics.minProjectileX ),lerpFactor);
	var projectile_y_spread =  lerp((global.Graphics.prevMaxY - global.Graphics.prevMinY) ,(global.Graphics.maxProjectileY - global.Graphics.minProjectileY ),lerpFactor);
	var widRat = projectile_x_spread/global.Graphics.minWidth;
	var heiRat = projectile_y_spread/global.Graphics.minHeight;
	var targetScale = widRat;
	global.ratio = "width";
	if(heiRat > widRat){
		targetScale = heiRat;
		global.ratio = "height";	
	}
	
	if(abs(targetScale - global.Graphics.screenScale) > global.Graphics.screenScale*global.Settings.scaleRate.value){
		if(targetScale > global.Graphics.screenScale){
			global.Graphics.screenScale += (global.Graphics.screenScale * global.Settings.scaleRate.value);	
		}
		if(targetScale < global.Graphics.screenScale - (global.Graphics.screenScale*global.Settings.scaleRate.value) && global.Graphics.stopTimer <= 0){
			global.Graphics.screenScale -= (global.Settings.scaleRate.value * global.Graphics.screenScale);
		}
	}else{
		if(global.Graphics.stopTimer <= 0)
			global.Graphics.screenScale = targetScale;	
	
	}
	global.Graphics.screenScale = clamp(global.Graphics.screenScale, global.Graphics.minScale, global.Graphics.maxScale);
	if(global.Graphics.stopTimer <= 0){
		global.Graphics.targetX = (global.Graphics.minProjectileX + global.Graphics.maxProjectileX)/2 - (global.Graphics.minWidth * global.Graphics.screenScale)/2;
	}
	if(global.Graphics.stopTimer <= 0){
		global.Graphics.targetY =   (global.Graphics.minProjectileY + global.Graphics.maxProjectileY)/2 - (global.Graphics.minHeight * global.Graphics.screenScale)/2;
	}
	var yDist = abs(global.Graphics.targetY - global.Graphics.currY);
	var xDist = abs(global.Graphics.targetX - global.Graphics.currX);
	var yRatio = yDist/xDist;
	global.Graphics.currY = lerp(global.Graphics.currY, global.Graphics.targetY, min(10/fps,.16));
	global.Graphics.currX = lerp(global.Graphics.currX, global.Graphics.targetX,  min(10/fps,.16));
	global.Graphics.currWidth = global.Graphics.minWidth * global.Graphics.screenScale;
	global.Graphics.currHeight = global.Graphics.minHeight* global.Graphics.screenScale;
	if(global.Law.threeD){
		camera_set_view_pos(global.camera, global.Graphics.currX, global.Graphics.currY);
		camera_set_view_size(global.camera, global.Graphics.currWidth, global.Graphics.currHeight);
		global.view_matrix = camera_get_view_mat(global.camera);
		if(!global.Law.inBrowser){
			global.view_matrix[5] *= -1;
			global.view_matrix[13] *= -1;
		}
		camera_set_view_mat(global.camera, global.view_matrix);
		camera_apply(view_camera[0]);
	}else{
		camera_set_view_pos(view_camera[0], global.Graphics.currX, global.Graphics.currY);
		camera_set_view_size(view_camera[0], global.Graphics.currWidth, global.Graphics.currHeight);
	}
	if(global.Graphics.stopTimer<= 0){
		set_grid_variables();
	}
}
function set_grid_variables(){
		global.Graphics.gridSize = max(global.Settings.baseGridSize.value, global.Settings.baseGridSize.value* power(2,min(max(0,ceil(global.Graphics.screenScale /global.Settings.gridScaleFactor.value)-1),3)));
		var grid_buffer = 5;
		global.Graphics.gridCountX = ceil(global.Graphics.currWidth/global.Graphics.gridSize) + grid_buffer * 2;
		global.Graphics.gridCountY = ceil(global.Graphics.currHeight/global.Graphics.gridSize)+ grid_buffer * 2;
		global.Graphics.gridWidth =global.Graphics.currWidth*1.5;
		global.Graphics.gridHeight =global.Graphics.currHeight*1.5;
		global.Graphics.gridStartX = global.Graphics.currX;
		global.Graphics.gridStartY = global.Graphics.currY;
		global.Graphics.gridOffsetX = global.Graphics.gridStartX - (global.Graphics.currX % global.Graphics.gridSize)-grid_buffer*global.Graphics.gridSize;
		global.Graphics.gridOffsetY = global.Graphics.gridStartY - (global.Graphics.currY% global.Graphics.gridSize) -grid_buffer*global.Graphics.gridSize;
}
function get_view_space_center_x(){
	return global.Graphics.currX + global.Graphics.currWidth/2;	
}

function get_view_space_center_y(){
	return global.Graphics.currY + global.Graphics.currHeight/2;	
}

#endregion
#region draw functions
function draw_grid(){
	if(!global.Law.threeD){
		draw_set_color(make_color_hsv(color_get_hue(global.backgroundColor),global.Settings.colorSaturation.value,.25 * global.Settings.colorValue.value));
		var alpha =1;
		draw_set_alpha(alpha);
		for(var i = 0; i < global.Graphics.gridCountX-2; i++){
			for(var k = 0; k < global.Graphics.gridCountY-2; k++){
				var z_x_1 = 0
				var z_x_2 =  0
				var z_x_3 =  0
				var z_y_1 =0
				var z_y_2 = 0
				var z_y_3 = 0
				var x_1 = i * global.Graphics.gridSize + global.Graphics.gridOffsetX  ;
				var y_1 = k * global.Graphics.gridSize + global.Graphics.gridOffsetY  ;
				var x_2 = (i+1) * global.Graphics.gridSize + global.Graphics.gridOffsetX ;
				var y_2 = (k+1) * global.Graphics.gridSize + global.Graphics.gridOffsetY ;
				if(global.debugMode< DebugMode.NONE){
					draw_set_alpha(1);
					draw_text(x_1 + z_x_1+10, y_1+z_y_1 ,"X: " + string(round(x_1 + z_x_1)) + "\nY: " + string(round(y_1+ z_y_1)));	
				}
			
				var depthFactor = 1;
				draw_line_width(x_1 + z_x_1,y_1 + z_y_1, x_1+z_x_3, y_2 + z_y_3, (global.Graphics.gridSize*3*depthFactor)/global.Settings.baseGridSize.value )
				//depthFactor =(1-abs((z_x_1 + z_x_2 + z_y_1 + z_y_2)/4)/(global.Graphics.gridSize/2))
				depthFactor =1 ;
				draw_line_width(x_1+ z_x_1,y_1+ z_y_1, x_2+ z_x_2, y_1+ z_y_2, (global.Graphics.gridSize*3*depthFactor)/global.Settings.baseGridSize.value )
			}
		}
	}
	else{
		
		gpu_set_zwriteenable(true)
		//gpu_set_ztestenable(true);
		gpu_set_alphatestenable(true);
		gpu_set_tex_filter(true)
		if(os_browser != browser_firefox && os_browser != browser_unknown)
			set_grid_shader();
		var tex_index = ceil(global.Graphics.screenScale)%5;
		var sprite = spr_grid;
		var texture= sprite_get_texture( sprite,tex_index)
		if(!global.Settings.fullGrid.value)
			texture= sprite_get_texture( spr_blank,0)
		vertex_submit(global.Graphics.vertBuffer,pr_trianglelist,texture);
		if(os_browser != browser_firefox && os_browser != browser_unknown)
			shader_reset();
		gpu_set_ztestenable(false)
		gpu_set_zwriteenable(false)
		gpu_set_alphatestenable(false);
	}
}
function draw_game(_main, _x, _y, _scale, _level = noone){
	if(_level == noone){
		_level = obj_game.level;	
	}
	if(global.intro || postGame){
		return;	
	}
	if(_main){
		draw_background();
		gpu_set_depth(global.Law.baseDepth);
		if(global.Law.inBrowser){
			camera_apply(global.camera);
			gpu_set_alphatestenable(true)
		}
		draw_grid();
		if(global.show_ui&& !global.Game.levelComplete && !global.Game.reset)
			draw_preview_trajectory();
	}
	draw_components(_x, _y, _scale, _level)
	draw_end_point(_x, _y, _scale, _level);
	if(_main && !global.Game.levelComplete && !global.Game.reset){
		draw_shoot_cursor();
		draw_projectiles();
		draw_explosions();
	}
	if( _level == obj_game.level && !global.Game.levelComplete && !global.Game.reset)
		draw_start_point(_x, _y, _scale,_level);
	if(_main && !global.Game.levelComplete && !global.Game.reset){
		draw_aim_cursor();
		draw_debug();
	}
	
}
function draw_debug(){
	//var _array_start_x = round(global.Graphics.gridOffsetX + global.Law.playRadius)/global.sim_grid_size;
	//var _array_start_y = round(global.Graphics.gridOffsetY + global.Law.playRadius)/global.sim_grid_size;
	if(global.spiralUpdate &&  global.debugMode < DebugMode.NONE){
		draw_set_alpha(1);
		draw_set_color(c_lime);
		draw_circle(debug_x, debug_y, global.Settings.baseGridSize.value/2, false);	
	
	}
	//if(global.debugMode == DebugMode.SCREEN){
	//	for(var i = 0; i< global.sim_grid_count; i++){
	//		var x_index = i;
	//		for (var k= 0; k< global.sim_grid_count;k++){
	//			var y_index =  k;
	//			var _x = global.depth_array[x_index][y_index][0]
	//			var _y = global.depth_array[x_index][y_index][1]
	//			draw_text(_x,_y, string(global.depth_array[x_index][y_index][2]) +"\n" + string(get_gravitational_force_at_point(_x,_y, global.Law.gridMass)))
				
					
	//		}
			
	//	}
		
	//}
}
function draw_background(){
	
	draw_set_alpha(.5);
	if(global.Law.roundEdge)
		gpu_set_depth(global.Law.edgeFalloff);
	draw_set_color(make_color_hsv(color_get_hue(global.backgroundColor),global.Settings.colorSaturation.value,.25 * global.Settings.colorValue.value));
	draw_set_circle_precision(128)
	draw_circle(0,0, global.Law.playRadius+10*global.Graphics.screenScale,false);
	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_circle(0,0, global.Law.playRadius,false);
	
}
function draw_preview_trajectory(){
 
	draw_set_color(global.projectileColor);
	gpu_set_depth(global.Law.baseDepth)
	if(!global.editMode){	
		for(var i = 0; i<global.Law.trajectoryLength-2; i++){
			if( obj_game.shot_preview_mult[i] == -1 ||  obj_game.shot_preview_mult[i+2]== -1)
				continue;
			//var _x_1 = global.Graphics.shotPreviews[i].v2x;
			//var _y_1 = global.Graphics.shotPreviews[i].v2y;
			//var _r_1 = global.Graphics.shotPreviews[i].r;
			//var _m_1 = global.Graphics.shotPreviews[i].mult;
			
			//var _x_2 = global.Graphics.shotPreviews[i+2].v2x;
			//var _y_2 = global.Graphics.shotPreviews[i+2].v2y;
			var _x_1 = obj_game.shot_preview_x[i];
			var _y_1 = obj_game.shot_preview_y[i];
			var _r_1 = obj_game.shot_preview_r[i];
			var _m_1 = obj_game.shot_preview_mult[i];
			
			var _x_2 = obj_game.shot_preview_x[i+2];
			var _y_2 = obj_game.shot_preview_y[i+2];
			
			var alpha =(power(_x_2,2) + power(_y_2,2))/global.Law.sqPlayRadius;
			var edgDist = alpha * global.Law.edgeFalloff;
			if(alpha >= 1)
				return;
			if(global.objectDepth){
				gpu_set_depth((get_gravity_depth_at_coordinate(_x_2,_y_2))/global.Law.depthMod - 10);
			}else if(global.Law.roundEdge){
				gpu_set_depth(edgDist );
			}
			var hue  = (color_get_hue( global.projectileColor) +  ((1-_m_1)*global.Law.hueMult))%256;
			draw_set_color(make_color_hsv( hue, global.Settings.colorSaturation.value, global.Settings.colorValue.value))
			draw_set_alpha(0.1 * (1-i/global.Law.trajectoryLength));
			draw_line_width(_x_1,_y_1,_x_2,_y_2, _r_1*2);
		}
	}
	draw_set_alpha(1);	
}
function draw_components(_x, _y, _scale, _level){
	
	if(global.objectDepth){
		gpu_set_depth(global.Law.baseDepth)
		gpu_set_zwriteenable(true)
		gpu_set_ztestenable(true);
	}
	draw_set_circle_precision(32/global.Law.circlePrecision)
	draw_set_alpha(1);
	for(var i = 0; i < array_length(_level.components); i++){
		switch(_level.components[i].name){
			case "circle":
				draw_set_circle_precision(power(2,ceil(log2(_level.components[i].dr)))/global.Law.circlePrecision)
				var baseRadiiSq = power((_level.endpoint.r)+(_level.components[i].r ),2);
				var endDistSq = get_struct_square_distance(_level.endpoint, _level.components[i])-baseRadiiSq;
				var combinedRadiiSq = power((_level.endpoint.dr)+(_level.components[i].dr),2)-baseRadiiSq;
				var hue = lerp(global.Settings.neutralHue.value,global.Settings.dangerHue.value, combinedRadiiSq/endDistSq);
				draw_set_color(make_color_hsv(hue,global.Settings.colorSaturation.value,global.Settings.colorValue.value));
				if(global.objectDepth){
					gpu_set_depth((get_gravity_depth_at_coordinate(get_struct_x_position( _level.components[i]), get_struct_y_position( _level.components[i]), (_level.components[i].dr))))
				}else{
					
					gpu_set_depth(global.Law.baseDepth)
			
				}
				var radius =  (_level.components[i].dr);
				draw_set_alpha(0.1)
				var true_x = _x + get_struct_x_position( _level.components[i])* _scale;
				var true_y = _y+ get_struct_y_position( _level.components[i]) * _scale;
				draw_circle(true_x,true_y, radius * (1+global.Law.multiplierRadiusMod)* _scale , false);
			
				draw_set_alpha(1)
				draw_circle(true_x,true_y, radius* _scale, false);
				draw_set_color(c_black);
				draw_circle(true_x,true_y, radius* _scale*0.75, false);
			break;	
			case "square":
				draw_set_color(make_color_hsv(global.Settings.neutralHue.value,global.Settings.colorSaturation.value,global.Settings.colorValue.value));
				if(global.objectDepth){
					gpu_set_depth((get_gravity_depth_at_coordinate(_level.components[i].v2x,  _level.components[i].v2y, (_level.components[i].r))))
				}else{
					
					gpu_set_depth(global.Law.baseDepth)
			
				}
				var width =  (_level.components[i].r)*_scale;
				//draw_set_alpha(0.1)
				var true_x = _x + get_struct_x_position(_level.components[i]) * _scale;
				var true_y = _y+ get_struct_y_position(_level.components[i]) * _scale;
				//draw_rectangle(true_x- (width),true_y- (width), true_x + width, true_y + width , false);
				draw_set_alpha(1)
				draw_rectangle(true_x- (width),true_y- (width), true_x + width, true_y + width , false);
				draw_set_color(c_black);
				draw_rectangle(true_x- (width)*.25,true_y- (width)*.25, true_x + width*.25, true_y + width*.25 , false);
			break;
		}
		if(global.objectDepth){
			gpu_set_depth(global.Law.baseDepth)
		}
	}
}
function draw_shoot_cursor(){
	draw_set_color(global.backgroundColor);
	if(!global.editMode){
		if(global.Input.shooting && global.show_ui){
			draw_set_alpha(.4);
			draw_line_width(get_struct_x_position(level.start),get_struct_y_position(level.start),global.Input.cursorX, global.Input.cursorY,10* global.Graphics.screenScale)
			draw_set_alpha(1);
			draw_circle(global.Input.cursorX, global.Input.cursorY, 5 * global.Graphics.screenScale,!global.Input.shooting);	
		}
	}
}
function draw_aim_cursor(){
	
	draw_set_alpha(1);
	if(!global.Input.shooting&& global.show_ui){
		draw_set_color(c_black)
		draw_circle(global.Input.cursorX, global.Input.cursorY, 5 * global.Graphics.screenScale-1,false);
		draw_set_color(make_color_hsv(color_get_hue(global.projectileColor),global.Settings.colorSaturation.value,global.Settings.colorValue.value/2));
		draw_circle(global.Input.cursorX, global.Input.cursorY, 5 * global.Graphics.screenScale,!global.Input.shooting);	
		if(global.debugMode< DebugMode.NONE){
			draw_text(global.Input.cursorX, global.Input.cursorY + 10,"X: " + string(global.Input.cursorX) + "\nY: " + string(global.Input.cursorY));	
		}
		if(!instance_exists(obj_main_menu) && last_shot_position[0] != infinity){
			draw_set_color(global.goodColor);
			draw_set_alpha(0.5)
			draw_circle(last_shot_position[0], last_shot_position[1], 5 * global.Graphics.screenScale-1,true);
			draw_text(last_shot_position[0] + 5, last_shot_position[1] + 5 , "last shot");
		}
	}
	if(global.debugMode< DebugMode.NONE){
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_text(get_struct_x_position(level.endpoint),get_struct_y_position(level.endpoint) ,"X: " + string(get_struct_x_position(level.endpoint)) + "\nY: " + string(get_struct_y_position(level.endpoint)));	
	}
	draw_set_alpha(1)
}
function draw_projectiles(){
	with(obj_projectile){
		var alpha = 1;
		alpha =1-clamp(((power(x,2) + power(y,2) + power(projectile.r,2)) /global.Law.sqPlayRadius),0,1);
		if(global.objectDepth){
			gpu_set_depth(get_gravity_depth_at_coordinate(x,y)/global.Law.depthMod -10);
		}else if(global.Law.roundEdge){
			var edgDist =(1-alpha) * global.Law.edgeFalloff;
		
			gpu_set_depth(edgDist);
		}
		if(instance_exists(obj_main_menu)){
			var title = "RETIBROV";
			var title_length = string_length(title);	
			var scale = projectile.r/5;
			var character = string_char_at(title,projectile._id%title_length+1)
		}
		var precision = power(2, ceil(log2(projectile.r)))/global.Law.circlePrecision;
		var hue  = (projectile.color +  ((1-projectile.mult)*global.Law.hueMult))%256;
		draw_set_color(make_color_hsv( hue, global.Settings.colorSaturation.value, global.Settings.colorValue.value))
		for(var i = 2; i <array_length(x_trail); i++){
			var start_x = x;
			var start_y = y;
			 	start_x = x_trail[max(i-2, 0)];
				start_y = y_trail[max(i-2, 0)];
			//gpu_set_depth(get_gravity_depth_at_coordinate(start_x,start_y)/global.Law.depthMod);
			
				draw_set_alpha ((1 )-i/array_length(x_trail));
			var dist_sq = power(x-start_x,2) + power(y-start_y,2);
			draw_set_circle_precision(4);
			if(!instance_exists(obj_main_menu)){
				draw_set_alpha (((1 + global.Input.boost*0.5 )-i/array_length(x_trail))*.25);
				draw_circle(start_x,start_y, ((projectile.r) + global.Game.pulseFactor)/((i)/array_length(x_trail)+1), true);
			}else{
				//draw_set_alpha ((1-i/array_length(x_trail))/2);
				//var x_off = string_width(character)*(scale*(1-i/array_length(x_trail)));
				//var y_off = string_height(character)*(scale*(1-i/array_length(x_trail)));
				//draw_text_transformed(start_x-x_off,start_y-y_off,character,scale*(1-(i/array_length(x_trail))),scale*(1-(i/array_length(x_trail))),0);
			}
		}
		draw_set_circle_precision(precision)
	
		draw_set_alpha(1);
		var opa = min(0.6,(projectile.r/obj_game.level.endpoint.r)) + 0.2;
		opa *= alpha;
		var real_color = make_color_hsv(hue,  global.Settings.colorSaturation.value, global.Settings.colorValue.value* opa);
		if(!instance_exists(obj_main_menu)){
			if(opa<1){
				draw_set_alpha(max(0.2,alpha));
				draw_circle(x, y, projectile.r + global.Game.pulseFactor + 1, true);	
			}
			
			draw_set_alpha(alpha*.4);
			
			if(global.Input.boost && projectile.r > global.Law.pRadius){
				
				draw_set_color(make_color_hsv(global.Settings.neutralHue.value,255,255 ));
				draw_line_width(x,y, x-projectile.x_vel/2, y-projectile.y_vel/2, projectile.r*2);
					
			}if(global.Input.brake && projectile.r > global.Law.pRadius){
				
				draw_set_color(make_color_hsv(global.Settings.dangerHue.value,255,255 ));
				draw_line_width(x,y, x+projectile.x_vel/2, y+projectile.y_vel/2, projectile.r*2);
			}
			draw_set_alpha(1);
			draw_set_color(real_color);
			draw_circle(x, y, projectile.r+ global.Game.pulseFactor, false);
		
	
		}else{
			var x_off = string_width(character)*scale/2;
			var y_off = string_height(character)*scale/2;
			draw_text_transformed(x-x_off,y-y_off,character,scale,scale,0);
		}
		if(multiTimer >0){
			var point_text =string( num_separator( power(projectile.mult,2),",")) + "X";
			var width = string_width(point_text);
			var pointcolor = real_color;
			if(global.Law.roundEdge){
				alpha = clamp(((power(multi_x + projectile.x_vel/fps-width/2,2) + power(multi_y + projectile.y_vel/fps,2) ) /global.Law.sqPlayRadius),0,1);
				var edgDist = alpha * global.Law.edgeFalloff;
				gpu_set_depth(edgDist);
			}
			var p_scale = 2*global.Graphics.screenScale*(log10(projectile.mult));
			draw_text_transformed_color(multi_x + projectile.x_vel/fps-width/2,
			multi_y + projectile.y_vel/fps,
			point_text,
			p_scale,
			p_scale,
			0,pointcolor,pointcolor,pointcolor,pointcolor, 
			1);
		}
		if(global.debugMode == DebugMode.SCREEN){
			draw_set_alpha(1)
			draw_set_color(c_white);
			draw_text(x, y- 12, string(force));
			
		}
	}
}
function draw_explosions(){
	draw_set_alpha(1);
	global.Graphics.explosionCount = 0;
	with(obj_explosion){
		var alpha = 1/timePercentage;
	
		global.Graphics.explosionCount+= .05*radius;
		for(var i = 0; i < lineCount; i++){
			var x_vector = sin( random_range(0,2*pi))*10*radius * global.Graphics.screenScale;
			var y_vector = cos(random_range(0,2*pi))* 10*radius* global.Graphics.screenScale;
			draw_set_color(color);

			if(global.objectDepth){
			gpu_set_depth(get_gravity_depth_at_coordinate(x+ (x_vector * timePercentage),y + (y_vector * timePercentage))/global.Law.depthMod);
			}else if(global.Law.roundEdge){
				alpha = clamp(((power(x+ (x_vector * timePercentage*.9),2) + power(y+ (y_vector * timePercentage*.9),2) ) /global.Law.sqPlayRadius),0,1);
				var edgDist = alpha * global.Law.edgeFalloff;
				alpha = (1-alpha) * (1/timePercentage);
				gpu_set_depth(edgDist);
			}		
			draw_set_alpha(alpha);
			draw_line_width(x+(x_vector * timePercentage*0.9),y+ (y_vector * timePercentage * 0.9), x+ (x_vector * timePercentage), y + (y_vector * timePercentage), 2* global.Graphics.screenScale);
		}
		if(points != 0)	{
			var point_text = num_separator(points, ",");
			var width = string_width(point_text);
			var pointcolor = global.badColor;
			if(points>0)
				pointcolor = global.goodColor;
			if(global.Law.roundEdge){
				alpha = clamp(((power(x-width/2 + text_x_vector * timePercentage,2) + power(y+text_y_vector*timePercentage,2) ) /global.Law.sqPlayRadius),0,1);
				var edgDist = alpha * global.Law.edgeFalloff;
				gpu_set_depth(edgDist);
			}
			draw_text_transformed_color(x-width/2 + text_x_vector * timePercentage,
			y+text_y_vector*timePercentage,
			point_text,
			2*global.Graphics.screenScale,
			2*global.Graphics.screenScale,
			0,pointcolor,pointcolor,pointcolor,pointcolor, 
			min(1,(timePercentage) * 2));
		}
	}
	shake_fx_params.g_Magnitude = global.Graphics.explosionCount;
	fx_set_parameters(shake_layer,shake_fx_params);
}
function draw_start_point(_x, _y, _scale, _level){
	set_gpu_depth_from_struct(_level.start);
	draw_set_alpha(1);
	draw_set_circle_precision(16/global.Law.circlePrecision)
	var value = global.Settings.colorValue.value* global.Law.baseShotDelay/(global.Game.shotDelay/2)
	draw_set_color(make_color_hsv( color_get_hue(global.backgroundColor), global.Settings.colorSaturation.value, value ));
	
	var true_x = _x + get_struct_x_position(_level.start) * _scale;
	var true_y = _y + get_struct_y_position(_level.start) * _scale;
	draw_circle(true_x, true_y ,_level.start.r * _scale,false);
	draw_circle(true_x, true_y ,_level.start.r* _scale,true);
}
function draw_end_point(_x, _y, _scale, _level){
	
	if(global.objectDepth){
		gpu_set_depth(global.Law.baseDepth);
		gpu_set_zwriteenable(false)
		gpu_set_ztestenable(false);
	}
	draw_set_circle_precision(16/global.Law.circlePrecision)
	set_gpu_depth_from_struct(level.endpoint);
	draw_set_circle_precision(32/global.Law.circlePrecision)
	draw_set_color(global.projectileColor);
	if(global.Game.reset)
		draw_set_color(global.badColor);
	if(global.objectDepth){
		gpu_set_zwriteenable(true)
		gpu_set_ztestenable(true);
	}
	draw_set_alpha(0.1)
	var endRad =   (_level.endpoint.dr) ;
	var true_x = _x + get_struct_x_position(_level.endpoint) * _scale;
	var true_y = _y + get_struct_y_position(_level.endpoint) * _scale;
	var _pulse = global.Game.cosPulse;
	if( _level != obj_game.level)
		_pulse = 0;
	draw_circle(true_x, true_y, endRad * (1+global.Law.multiplierRadiusMod) * _scale ,false);
	draw_set_alpha(1);	
	draw_circle(true_x, true_y ,endRad * _scale ,false);
	draw_set_color(c_black);
	draw_circle(true_x, true_y ,max(_level.endpoint.r  - _level.endpoint.damage -10 +_pulse,_level.endpoint.tr) * _scale ,false);
	if(_level == obj_game.level){
		draw_game(false, 
				get_struct_x_position(obj_game.level.endpoint), 
				get_struct_y_position(obj_game.level.endpoint),
				(obj_game.level.endpoint.tr + global.Game.cosPulse)/global.Law.playRadius,
				global.levels.array[(global.currentLevel + 1)%array_length(global.levels.array)]);
		if(!global.Game.levelComplete && !global.Game.reset){
			draw_set_color(global.goodColor);
			draw_circle(true_x, true_y ,_level.endpoint.tr * _scale,true);
			draw_set_color(global.projectileColor);
			var gravRings = ((current_time-global.Game.roomStart)/2000* global.simRate) %1;
			draw_set_alpha(gravRings *.5 + .25);
			draw_circle(true_x, true_y ,_level.endpoint.tr* _scale - gravRings*_level.endpoint.tr * _scale,true);
			draw_set_alpha(((gravRings + .5)%1 ) *.5 + .25);
			draw_circle(true_x,true_y, _level.endpoint.tr* _scale - ((gravRings + .5)%1)*_level.endpoint.tr* _scale,true);
		}
	}
}
#endregion
function set_gpu_depth_from_point(x_coord, y_coord, radius = 1){
	if(global.objectDepth){
		gpu_set_depth(get_gravity_depth_at_coordinate(x_coord, y_coord, radius)/global.Law.depthMod);
	}else if(global.Law.roundEdge){
		var	alpha =clamp(((power(x_coord,2) + power(y_coord,2)) /global.Law.sqPlayRadius),0,1);
		var edgDist = alpha * global.Law.edgeFalloff;
		alpha = 1-alpha
		gpu_set_depth(edgDist);
	}
	
}
function set_gpu_depth_from_struct(obj_struct){
	set_gpu_depth_from_point(get_struct_x_position(obj_struct), get_struct_y_position(obj_struct), get_actual_radius(obj_struct)/2);
}
function reset_colors(){
	
	
	global.backgroundColor = make_color_hsv(255,global.Settings.colorSaturation.value,global.Settings.colorValue.value);
	global.goodColor = make_color_hsv(global.Settings.goodHue.value, global.Settings.colorSaturation.value, global.Settings.colorValue.value);
	global.projectileColor = make_color_hsv(global.Settings.projectileHue.value, global.Settings.colorSaturation.value, global.Settings.colorValue.value);
	global.badColor = make_color_hsv(global.Settings.badHue.value, global.Settings.colorSaturation.value, global.Settings.colorValue.value);
	trigger_grid_update();
}
function get_vert_alpha(x_index, y_index){
	var x1_p = power(x_index,2);
	var y1_p = power(y_index,2);
	var maxAlph = global.Settings.gridAlpha.value;
	//if(global.Law.inBrowser){
	//	maxAlph *= 2;	
	//}
	var alpha = 1 -clamp(((x1_p + y1_p) /global.Law.sqPlayRadius),0,1);
	return alpha * maxAlph;
}
//LEGACY STUFF SAVED FOR EMERGENCY
				//if(global.grid_solid){
				//		var z_4 = global.depth_array[i-1][k-1][2];
				//		vertex_position_3d(global.Graphics.vertBuffer, x_1 ,y_1 ,z_1+0.1);
				//		vertex_color(global.Graphics.vertBuffer, c_black, alpha);
				//		vertex_texcoord(global.Graphics.vertBuffer,0,0);
				//		vertex_position_3d(global.Graphics.vertBuffer, x_2,y_1 ,z_2+0.1);
				//		vertex_color(global.Graphics.vertBuffer, c_black, alpha);
				//		vertex_texcoord(global.Graphics.vertBuffer,1,0);
				//		vertex_position_3d(global.Graphics.vertBuffer, x_2+ thickness,y_2+ thickness, z_4+0.1);
				//		vertex_color(global.Graphics.vertBuffer, c_black, alpha)
				//		vertex_texcoord(global.Graphics.vertBuffer,1,1);
						
				//		vertex_position_3d(global.Graphics.vertBuffer, x_1 ,y_1 ,z_1+0.1);
				//		vertex_color(global.Graphics.vertBuffer, c_black, alpha);
				//		vertex_texcoord(global.Graphics.vertBuffer,0,0);
				//		vertex_position_3d(global.Graphics.vertBuffer, x_2+ thickness,y_2+ thickness, z_4+0.1);
				//		vertex_color(global.Graphics.vertBuffer, c_black, alpha)
				//		vertex_texcoord(global.Graphics.vertBuffer,1,1);
				//		vertex_position_3d(global.Graphics.vertBuffer, x_1 + thickness,y_2, z_3+0.1);
				//		vertex_color(global.Graphics.vertBuffer, c_black, alpha)
				//		vertex_texcoord(global.Graphics.vertBuffer,0,1);
				//}