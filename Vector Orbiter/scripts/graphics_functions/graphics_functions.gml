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
	shader_set_uniform_f(deptha, global.play_area_radius_sq);
	shader_set_uniform_f(outline, floor(global.screenScale));
	shader_set_uniform_f(maxAlpha, global.grid_alpha);	
	if(global.inBrowser)
		shader_set_uniform_f(pHeight, 1000);	
	else
		shader_set_uniform_f(pHeight, -250);	
	var p_f = ((current_time-room_start)%((4000*pulseRate)))/(4000*pulseRate);
	shader_set_uniform_f(cosP, p_f);
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
			d_array_start_x = round(grid_x_offset + global.play_area_radius)/global.sim_grid_size;
			d_array_start_y = round(grid_y_offset + global.play_area_radius)/global.sim_grid_size;
			grid_ratio = global.grid_size/global.sim_grid_size;
			count_x = grid_x_count;
			count_y = grid_y_count;
			
		}
		
			
		vertex_begin(global.v_buff,global.grid_vertex_format);
		for(var i = 1; i < count_x; i++){
			for(var k = 1; k <count_y; k++){
				var depth_x_1_index = d_array_start_x + i*grid_ratio;
				var depth_x_2_index = d_array_start_x + (i-1)*grid_ratio;
				var depth_y_1_index = d_array_start_y + (k)*grid_ratio;
				set_grid_point_vertices(depth_x_1_index, depth_y_1_index, grid_ratio, true);
			}//draw_line_width(i * global.grid_size + grid_x_offset,grid_start_y, i * global.grid_size + grid_x_offset, grid_height, (global.grid_size*5)/global.base_grid_size );	
	
		}

		vertex_end(global.v_buff);
		grid_trigger = false;
		var endTime = current_time - starttime;
		log_grid_vertex_performance_time(endTime);
		if(global.gridDebugMessages || global.inBrowser)
			show_debug_message("Full sim grid set with " + string(global.frame_vert_count) + " vertices in time " + string(endTime));
		global.frame_vert_count = 0;
}
function set_grid_point_vertices(depth_x_1_index,depth_y_1_index, grid_ratio = 1, init = false){
	var vert_index = -1;
	if(!init)
	{
					
		vertex_begin(global.u_buff,global.grid_vertex_format);
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
	if(x1_p + y1_p > global.play_area_radius_sq && x2_p + y2_p > global.play_area_radius_sq)
		return;
	//var alpha = global.depth_array[depth_x_1_index][depth_y_1_index][3];
				
	var alpha = 1;
	if(os_browser == browser_firefox || os_browser == browser_unknown)
		alpha = get_vert_alpha(x_1, y_1);
		//
	var x_alpha = alpha;
	var y_alpha = alpha;
	var thickness = global.grid_thickness;
	var scaleMod =  power(2,min(max(0,ceil(global.screenScale /global.gridScaleFactor)),3));
	if(!global.fullGrid){
		thickness *= global.screenScale;
		if(((global.screenScale)%global.gridScaleFactor) > global.gridScaleFactor/2 && global.screenScale <4){
			if((depth_x_1_index%scaleMod) != 0){
				y_alpha *= 1-((global.screenScale*2) %global.gridScaleFactor)/global.gridScaleFactor;
				y_2 += thickness;
			}
			if((depth_y_1_index%scaleMod)!=0){
				x_alpha *= 1-((global.screenScale*2) %global.gridScaleFactor)/global.gridScaleFactor;
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
	z_1 = clamp(z_1,0,global.z_alpha);
	z_2 = clamp(z_2,0,global.z_alpha);
	z_3 = clamp(z_3,0,global.z_alpha);
	z_4 = clamp(z_4,0,global.z_alpha);
	var alph_1 = 1
	//-(z_1/global.z_alpha);
	var alph_2 = 1
	//-(z_2/global.z_alpha)
	var alph_3 = 1
	//-(z_3/global.z_alpha)
	if(init)
	{
		global.depth_array[depth_x_1_index][depth_y_1_index][3] = global.frame_vert_count;
		add_grid_point_verts_to_buffer(global.v_buff,x_1,y_1,x_2,y_2,z_1,z_2,z_3, z_4,thickness, thickness, alph_1,alph_2,alph_3,global.bg_color, x_alpha, y_alpha )
	}else{
		add_grid_point_verts_to_buffer(global.u_buff,x_1,y_1,x_2,y_2,z_1,z_2,z_3, z_4,x_thickness, y_thickness,1, 1, 1,global.bg_color)
		var delta_vert = global.frame_vert_count + vert_index;
			
		vertex_end(global.u_buff);
		if(global.gridDebugMessages|| global.inBrowser)
			show_debug_message("Update sim grid set from " + string(vert_index) + " to "  + string(vert_index + global.frame_vert_count) + " vertices");
		if(vert_index < 0){
			show_debug_message("Vertex update attempted at index: " + string(vert_index) + " for coordinate (" + string(depth_x_1_index) + ", " + string(depth_y_1_index) +") aborted");	
			return;
		}
		vertex_update_buffer_from_vertex(global.v_buff,vert_index,global.u_buff);
		vert_index = -1;
	//if(global.gridDebugMessages)
		//show_debug_message("Sim Grid Coordinate (" + string(i) + ", " + string(k) +") assigned vertices " + string(startVert) + " through " + string(global.frame_vert_count));
				
	
	}
}
function update_grid_points_in_buffer(start_x, start_y,range){
	var startTime = current_time;
	var updateCount = 0
	var temp_start_y = start_y;
	if(global.gridDebugMessages || global.inBrowser)
		show_debug_message("Sim Grid Vertex Update started at coordinates (" + string(start_x) + ", " + string(start_y) +") with range: " + string(range)); 
	if(!global.vertCopyRate){
		vertex_begin(global.u_buff,global.grid_vertex_format);
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
			
			if(x1_p + y1_p > global.play_area_radius_sq && x2_p + y2_p > global.play_area_radius_sq){
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
			var thickness = global.grid_thickness;
	
			var scaleMod = power(2,min(ceil(global.screenScale/global.gridScaleFactor),4));
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
			//var alph_1 = alpha *(1-(z_1/global.z_alpha));
			//var alph_2 = alpha *(1-(z_2/global.z_alpha))
			//var alph_3 = alpha *(1-(z_3/global.z_alpha))
			
			add_grid_point_verts_to_buffer(global.u_buff,x_1,y_1,x_2,y_2,z_1,z_2,z_3, z_4,x_thickness, y_thickness,1, 1, 1,global.bg_color)
			var delta_vert = global.frame_vert_count + vert_index;
			if(global.gridDebugMessages)
				show_debug_message("Update Grid Coordinate (" + string(j) + ", " + string(l) +") assigned vertices " + string(frameStartVert) + " through " + string(delta_vert) + " at update count " + string(updateCount));
			updateCount++;
			
			if(global.vertCopyRate){
				vertex_end(global.u_buff);
				if(global.gridDebugMessages|| global.inBrowser)
					show_debug_message("Update sim grid set from " + string(vert_index) + " to "  + string(vert_index + global.frame_vert_count) + " vertices");
				if(vert_index < 0){
					show_debug_message("Vertex update attempted at index: " + string(vert_index) + " for start coordinate (" + string(start_x) + ", " + string(start_y) +") aborted");	
					return;
				}
				vertex_update_buffer_from_vertex(global.v_buff,vert_index,global.u_buff);
				vert_index = -1;
			}
		}
		temp_start_y = 0;
		
	}
	if(!global.vertCopyRate){
		vertex_end(global.u_buff);
		if(global.gridDebugMessages|| global.inBrowser)
			show_debug_message("Update sim grid set from " + string(vert_index) + " to "  + string(vert_index + global.frame_vert_count) + " vertices");
		if(vert_index < 0){
			show_debug_message("Vertex update attempted at index: " + string(vert_index) + " for start coordinate (" + string(start_x) + ", " + string(start_y) +") aborted");	
			return;
		}
		vertex_update_buffer_from_vertex(global.v_buff,vert_index,global.u_buff);
	}
	if(global.gridDebugMessages|| global.inBrowser)
		show_debug_message("buffer updated successfully");
	
	global.frame_vert_count = 0;
	log_grid_vertex_performance_time(current_time - startTime);
}

function add_grid_point_verts_to_buffer(_buffer, x_1, y_1, x_2,y_2,z_1,z_2,z_3, z_4, x_thickness, y_thickness, alph_1, alph_2, alph_3, col, x_alph = 1, y_alph = 1){
		// Draw Horizontal Line
		
		if(global.fullGrid){
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
function set_camera_view(){
	/// function sketch
	// determine component minima and maxima
	// record last frame min/max
	// project next minima/maxima
	// 
	prevMaxX = maxProjectileX;
	prevMaxY = maxProjectileY;
	prevMinX = minProjectileX;
	prevMinY = minProjectileY;
	minProjectileX = 99999;
	maxProjectileX = -99999;
	minProjectileY = 99999;
	maxProjectileY = -99999;
	if(get_struct_x_position(obj_game.level.start) - level.start.r*2- 100  < minProjectileX)
		minProjectileX = get_struct_x_position(obj_game.level.start) - level.start.r*2- 100 ;
		
	if( get_struct_y_position(obj_game.level.start) - level.start.r*2- 100 <minProjectileY)
		minProjectileY = get_struct_y_position(obj_game.level.start) - level.start.r*2- 100 ;
	if(get_struct_x_position(obj_game.level.start) - level.start.r*2+  100  > maxProjectileX)
		maxProjectileX = get_struct_x_position(obj_game.level.start) + level.start.r*2+ 100 ;
	if( get_struct_y_position(obj_game.level.start) + level.start.r*2- 100  > maxProjectileY)
		maxProjectileY = get_struct_y_position(obj_game.level.start) + level.start.r*2+ 100 ;
	
		
	if(level.endpoint.v2x - level.endpoint.r < minProjectileX){
		minProjectileX = level.endpoint.v2x - level.endpoint.r * 2 - 100 ;
	}
	if(level.endpoint.v2y - level.endpoint.r < minProjectileY){
		minProjectileY = level.endpoint.v2y - level.endpoint.r* 2 - 100 ;
	}
	if(level.endpoint.v2x + level.endpoint.r > maxProjectileX){
		maxProjectileX = level.endpoint.v2x + level.endpoint.r * 2+ 100 ;
	}
	
	if(level.endpoint.v2y + level.endpoint.r > maxProjectileY){
		maxProjectileY = level.endpoint.v2y + level.endpoint.r * 2+ 100 ;
	}
	
	var componentCount = array_length(level.components);
	for (var i = 0; i < componentCount; i++){
				
		if(level.components[i].v2x - (level.components[i].r + level.components[i].damage)*2- 200  < minProjectileX){
			minProjectileX = level.components[i].v2x - (level.components[i].r + level.components[i].damage) * 2- 200 ;
		}
		if(level.components[i].v2y - (level.components[i].r + level.components[i].damage)*2 - 100 < minProjectileY){
			minProjectileY = level.components[i].v2y - (level.components[i].r + level.components[i].damage) *2 - 200 ;
		}
		if(level.components[i].v2x + (level.components[i].r + level.components[i].damage)*2 + 100 > maxProjectileX){
			maxProjectileX = level.components[i].v2x + (level.components[i].r + level.components[i].damage) * 2+ 200 ;
		}
	
		if(level.components[i].v2y + (level.components[i].r + level.components[i].damage) * 2+ 100  > maxProjectileY){
			maxProjectileY = level.components[i].v2y + (level.components[i].r + level.components[i].damage) * 2+ 200 ;
		}
	
	}
	
	with(obj_projectile){
		if(projectile.v2x- projectile.r*4 < obj_game.minProjectileX)
			obj_game.minProjectileX = (projectile.v2x - projectile.r*4 );
		if(projectile.v2y - projectile.r*4 < obj_game.minProjectileY)
			obj_game.minProjectileY = (projectile.v2y -projectile.r*4 );		
		if(projectile.v2x + projectile.r*4 >obj_game.maxProjectileX)
			obj_game.maxProjectileX = (projectile.v2x +projectile.r*4 );
		if(projectile.v2y+ projectile.r*4  >obj_game.maxProjectileY )
			obj_game.maxProjectileY = (projectile.v2y + projectile.r*4 );
	}
	if(room == game_room){
		
		if(obj_game.cursor_x - 20*global.screenScale  < obj_game.minProjectileX){
			obj_game.minProjectileX = obj_game.cursor_x- 20*global.screenScale ;
		
		}
		if(obj_game.cursor_y- 20*global.screenScale  < obj_game.minProjectileY){
			obj_game.minProjectileY = obj_game.cursor_y - 20*global.screenScale ;
		
		}	
		if(obj_game.cursor_x +20*global.screenScale> obj_game.maxProjectileX){
			obj_game.maxProjectileX = obj_game.cursor_x + 20*global.screenScale ;
		
		}
		if(obj_game.cursor_y +20*global.screenScale> obj_game.maxProjectileY){
			obj_game.maxProjectileY = obj_game.cursor_y+20*global.screenScale;
		
		}
	}
	var lerpFactor = 0.16;
	if(room != game_room)
		lerpFactor = 0.0001;
	var projectile_x_spread = lerp((prevMaxX - prevMinX) ,(maxProjectileX - minProjectileX ),lerpFactor);
	var projectile_y_spread =  lerp((prevMaxY - prevMinY) ,(maxProjectileY - minProjectileY ),lerpFactor);
	var widRat = projectile_x_spread/minWidth;
	var heiRat = projectile_y_spread/minHeight;
	var targetScale = widRat;
	global.ratio = "width";
	if(heiRat > widRat){
		targetScale = heiRat;
		global.ratio = "height";	
	}
	
	if(abs(targetScale - global.screenScale) > global.screenScale*scaleRate){
		if(targetScale > global.screenScale){
			global.screenScale += (global.screenScale * scaleRate);	
		}
		if(targetScale < global.screenScale - (global.screenScale*scaleRate) && stopTimer <= 0){
			global.screenScale -= (scaleRate * global.screenScale);
		}
	}else{
		if(stopTimer <= 0)
			global.screenScale = targetScale;	
	
	}
	global.screenScale = clamp(global.screenScale,minScale, maxScale);
	if(stopTimer <= 0){
		targetX = (minProjectileX + maxProjectileX)/2 - (minWidth * global.screenScale)/2;
	}
	if(stopTimer <= 0){
		targetY =   (minProjectileY + maxProjectileY)/2 - (minHeight * global.screenScale)/2;
	}
	var yDist = abs(targetY - currY);
	var xDist = abs(targetX - currX);
	var yRatio = yDist/xDist;
	currY = lerp(currY, targetY, min(10/fps,.16));
	currX = lerp(currX, targetX,  min(10/fps,.16));
	currWidth = minWidth * global.screenScale;
	currHeight = minHeight* global.screenScale;
	if(global.threeD){
		camera_set_view_pos(global.camera,currX, currY);
		camera_set_view_size(global.camera,currWidth, currHeight);
		global.view_matrix = camera_get_view_mat(global.camera);
		if(!global.inBrowser){
			global.view_matrix[5] *= -1;
			global.view_matrix[13] *= -1;
		}
		//global.view_matrix[12] *= -1;
		//global.view_matrix[14] *= -1;
		camera_set_view_mat(global.camera, global.view_matrix);
		//camera_set_proj_mat(global.camera, global.projection_matrix);
		camera_apply(view_camera[0]);
	}else{
		camera_set_view_pos(view_camera[0],currX, currY);
		camera_set_view_size(view_camera[0],currWidth, currHeight);
	}
	if(stopTimer<= 0){
		global.grid_size = max(global.base_grid_size, global.base_grid_size* power(2,min(max(0,ceil(global.screenScale /global.gridScaleFactor)-1),3)));
		var grid_buffer = 5;
		grid_x_count = ceil(currWidth/global.grid_size) + grid_buffer * 2;
		var base_y_count = ceil(currHeight/global.grid_size)
		grid_y_count = ceil(currHeight/global.grid_size)+ grid_buffer * 2;
		grid_width = currWidth*1.5;
		grid_height = currHeight*1.5;
		grid_start_x = currX;
		grid_start_y = currY;
		grid_x_offset = grid_start_x - (currX % global.grid_size)-grid_buffer*global.grid_size;
		grid_y_offset = grid_start_y - (currY% global.grid_size) -grid_buffer*global.grid_size;
	}
}
#region draw functions
function draw_grid(){
	if(!global.threeD){
		draw_set_color(make_color_hsv(color_get_hue(global.bg_color),global.component_saturation,.25 * global.component_value));
		var alpha =1;
		draw_set_alpha(alpha);
		for(var i = 0; i < grid_x_count-2; i++){
			for(var k = 0; k < grid_y_count-2; k++){
				var z_x_1 = 0
				var z_x_2 =  0
				var z_x_3 =  0
				var z_y_1 =0
				var z_y_2 = 0
				var z_y_3 = 0
				var x_1 = i * global.grid_size + grid_x_offset  ;
				var y_1 = k * global.grid_size + grid_y_offset  ;
				var x_2 = (i+1) * global.grid_size + grid_x_offset ;
				var y_2 = (k+1) * global.grid_size + grid_y_offset ;
				if(global.debugMode< DebugMode.NONE){
					draw_set_alpha(1);
					draw_text(x_1 + z_x_1+10, y_1+z_y_1 ,"X: " + string(round(x_1 + z_x_1)) + "\nY: " + string(round(y_1+ z_y_1)));	
				}
			
				var depthFactor = 1;
				draw_line_width(x_1 + z_x_1,y_1 + z_y_1, x_1+z_x_3, y_2 + z_y_3, (global.grid_size*3*depthFactor)/global.base_grid_size )
				//depthFactor =(1-abs((z_x_1 + z_x_2 + z_y_1 + z_y_2)/4)/(global.grid_size/2))
				depthFactor =1 ;
				draw_line_width(x_1+ z_x_1,y_1+ z_y_1, x_2+ z_x_2, y_1+ z_y_2, (global.grid_size*3*depthFactor)/global.base_grid_size )
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
		var tex_index = ceil(global.screenScale)%5;
		var sprite = spr_grid;
		var texture= sprite_get_texture( sprite,tex_index)
		if(!global.fullGrid)
			texture= sprite_get_texture( spr_blank,0)
		vertex_submit(global.v_buff,pr_trianglelist,texture);
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
		gpu_set_depth(baseDepth);
		if(global.inBrowser){
			camera_apply(global.camera);
			gpu_set_alphatestenable(true)
		}
		draw_grid();
		if(global.show_ui)
			draw_preview_trajectory();
	}
	draw_components(_x, _y, _scale, _level)
	draw_end_point(_x, _y, _scale, _level);
	if(_main){
		draw_shoot_cursor();
		draw_projectiles();
		draw_explosions();
	}
	if(!levelComplete && !reset && _level == obj_game.level)
		draw_start_point(_x, _y, _scale,_level);
	if(_main){
		draw_aim_cursor();
		draw_debug();
	}
	
}
function draw_debug(){
	if(global.spiralUpdate &&  global.debugMode < DebugMode.NONE){
		draw_set_alpha(1);
		draw_set_color(c_lime);
		draw_circle(debug_x, debug_y, global.base_grid_size/2, false);	
	
	}
}
function draw_background(){
	
	draw_set_alpha(.5);
	if(global.roundEdge)
		gpu_set_depth(global.edgeFalloff);
	draw_set_color(make_color_hsv(color_get_hue(global.bg_color),global.component_saturation,.25 * global.component_value));
	draw_set_circle_precision(128)
	draw_circle(0,0, global.play_area_radius+10*global.screenScale,false);
	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_circle(0,0, global.play_area_radius,false);
	
}
function draw_preview_trajectory(){
 
	draw_set_color(global.projectile_color);

	if(!global.editMode){	
		for(var i = 0; i<array_length(shot_preview_x)-2; i++){
			var alpha =(power(shot_preview_x[i+2],2) + power(shot_preview_y[i+2],2))/global.play_area_radius_sq;
			var edgDist = alpha * global.edgeFalloff;
			if(alpha >= 1)
				return;
			if(global.objectDepth){
				gpu_set_depth((get_gravity_depth_at_coordinate(shot_preview_x[i+2],shot_preview_y[i+2]))/global.depthMod - 10);
			}else if(global.roundEdge){
				gpu_set_depth(edgDist );
			}
			var hue  = (color_get_hue( global.projectile_color) +  ((1-shot_preview_mult[i])*global.hueMult))%256;
			draw_set_color(make_color_hsv( hue, global.component_saturation, global.component_value))
			draw_set_alpha(0.1 * (1-i/array_length(shot_preview_x)));
			draw_line_width(shot_preview_x[i],shot_preview_y[i],shot_preview_x[i+2],shot_preview_y[i+2], shot_preview_r[i]*2);
		}
	}
	draw_set_alpha(1);	
}
function draw_components(_x, _y, _scale, _level){
	
	if(global.objectDepth){
		gpu_set_depth(baseDepth)
		gpu_set_zwriteenable(true)
		gpu_set_ztestenable(true);
	}
	draw_set_circle_precision(32/circle_precision_factor)
	draw_set_alpha(1);
	for(var i = 0; i < array_length(_level.components); i++){
		switch(_level.components[i].name){
			case "circle":
				draw_set_circle_precision(power(2,ceil(log2(_level.components[i].dr)))/circle_precision_factor)
				var baseRadiiSq = power((_level.endpoint.r)+(_level.components[i].r ),2);
				var endDistSq = get_struct_square_distance(_level.endpoint, _level.components[i])-baseRadiiSq;
				var combinedRadiiSq = power((_level.endpoint.dr)+(_level.components[i].dr),2)-baseRadiiSq;
				var hue = lerp(global.neutral_hue,global.danger_hue, combinedRadiiSq/endDistSq);
				draw_set_color(make_color_hsv(hue,global.component_saturation,global.component_value));
				if(global.objectDepth){
					gpu_set_depth((get_gravity_depth_at_coordinate(_level.components[i].v2x,  _level.components[i].v2y, (_level.components[i].dr))))
				}else{
					
					gpu_set_depth(baseDepth)
			
				}
				var radius =  (_level.components[i].dr);
				draw_set_alpha(0.1)
				var true_x = _x + _level.components[i].v2x* _scale;
				var true_y = _y+ _level.components[i].v2y * _scale;
				draw_circle(true_x,true_y, radius * (1+global.multiplierRadiusMod)* _scale , false);
			
				draw_set_alpha(1)
				draw_circle(true_x,true_y, radius* _scale, false);
				draw_set_color(c_black);
				draw_circle(true_x,true_y, radius* _scale*0.75, false);
			break;	
			case "square":
				draw_set_color(make_color_hsv(global.neutral_hue,global.component_saturation,global.component_value));
				if(global.objectDepth){
					gpu_set_depth((get_gravity_depth_at_coordinate(_level.components[i].v2x,  _level.components[i].v2y, (_level.components[i].r))))
				}else{
					
					gpu_set_depth(baseDepth)
			
				}
				var width =  (_level.components[i].r)*_scale;
				//draw_set_alpha(0.1)
				var true_x = _x + _level.components[i].v2x* _scale;
				var true_y = _y+ _level.components[i].v2y * _scale;
				//draw_rectangle(true_x- (width),true_y- (width), true_x + width, true_y + width , false);
				draw_set_alpha(1)
				draw_rectangle(true_x- (width),true_y- (width), true_x + width, true_y + width , false);
				draw_set_color(c_black);
				draw_rectangle(true_x- (width)*.25,true_y- (width)*.25, true_x + width*.25, true_y + width*.25 , false);
			break;
		}
		if(global.objectDepth){
			gpu_set_depth(baseDepth)
		}
	}
}
function draw_shoot_cursor(){
	draw_set_color(global.bg_color);
	if(!global.editMode){
		if(shooting&& global.show_ui){
			draw_set_alpha(.4);
			draw_line_width(get_struct_x_position(level.start),get_struct_y_position(level.start),cursor_x, cursor_y,10* global.screenScale)
			draw_set_alpha(1);
			draw_circle(cursor_x, cursor_y, 5 * global.screenScale,!shooting);	
		}
	}
}
function draw_aim_cursor(){
	
		draw_set_alpha(1);
	if(!shooting && global.show_ui){
		draw_set_color(c_black)
		draw_circle(cursor_x, cursor_y, 5 * global.screenScale-1,false);
		draw_set_color(make_color_hsv(color_get_hue(global.projectile_color),global.component_saturation,global.component_value/2));
		draw_circle(cursor_x, cursor_y, 5 * global.screenScale,!shooting);	
		if(global.debugMode< DebugMode.NONE){
			draw_text(cursor_x, cursor_y + 10,"X: " + string(cursor_x) + "\nY: " + string(cursor_y));	
		}
		if(room == game_room && last_shot_position[0] != infinity){
			draw_set_color(global.good_color);
			draw_set_alpha(0.5)
			draw_circle(last_shot_position[0], last_shot_position[1], 5 * global.screenScale-1,true);
			draw_text(last_shot_position[0] + 5, last_shot_position[1] + 5 , "last shot");
		}
	}
	if(global.debugMode< DebugMode.NONE){
		draw_set_alpha(1);
		draw_set_color(c_white);
		draw_text(level.endpoint.v2x,level.endpoint.v2y ,"X: " + string(level.endpoint.v2x) + "\nY: " + string(level.endpoint.v2y));	
	}
			draw_set_alpha(1)
}
function draw_projectiles(){
	proj_index = 0;
	with(obj_projectile){
		var alpha = 1;
		alpha =1-clamp(((power(x,2) + power(y,2) + power(projectile.r,2)) /global.play_area_radius_sq),0,1);
		if(global.objectDepth){
			gpu_set_depth(get_gravity_depth_at_coordinate(x,y)/global.depthMod -10);
		}else if(global.roundEdge){
			var edgDist =(1-alpha) * global.edgeFalloff;
		
			gpu_set_depth(edgDist);
		}
		if(room != game_room){
			var title = "RETIBROV";
			var title_length = string_length(title);	
			var scale = projectile.r/5;
			var character = string_char_at(title,projectile._id%title_length+1)
		}
		var precision = power(2, ceil(log2(projectile.r)))/obj_game.circle_precision_factor;
		var hue  = (projectile.color +  ((1-projectile.mult)*global.hueMult))%256;
		draw_set_color(make_color_hsv( hue, global.component_saturation, global.component_value))
		for(var i = 2; i <array_length(x_trail); i++){
			var start_x = x;
			var start_y = y;
			 	start_x = x_trail[max(i-2, 0)];
				start_y = y_trail[max(i-2, 0)];
			//gpu_set_depth(get_gravity_depth_at_coordinate(start_x,start_y)/global.depthMod);
			
				draw_set_alpha ((1 )-i/array_length(x_trail));
			var dist_sq = power(x-start_x,2) + power(y-start_y,2);
			draw_set_circle_precision(4);
			if(room == game_room){
				draw_set_alpha (((1 + global.boost*0.5 )-i/array_length(x_trail))*.25);
				draw_circle(start_x,start_y, ((projectile.r) + obj_game.pulseFactor)/((i)/array_length(x_trail)+1), true);
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
		var real_color = make_color_hsv(hue,  global.component_saturation, global.component_value* opa);
		if(room == game_room){
			if(opa<1){
				draw_set_alpha(max(0.2,alpha));
				draw_circle(x, y, projectile.r + obj_game.pulseFactor + 1, true);	
			}
			
			draw_set_alpha(alpha*.4);
			
			if(global.boost&& projectile.r > global.projectileRadius){
				
				draw_set_color(make_color_hsv(global.neutral_hue,255,255 ));
				draw_line_width(x,y, x-projectile.x_vel/2, y-projectile.y_vel/2, projectile.r*2);
					
			}if(global.brake&& projectile.r > global.projectileRadius){
				
				draw_set_color(make_color_hsv(global.danger_hue,255,255 ));
				draw_line_width(x,y, x+projectile.x_vel/2, y+projectile.y_vel/2, projectile.r*2);
			}
			draw_set_alpha(1);
			draw_set_color(real_color);
			draw_circle(x, y, projectile.r+ obj_game.pulseFactor, false);
		
	
		}else{
			var x_off = string_width(character)*scale/2;
			var y_off = string_height(character)*scale/2;
			draw_text_transformed(x-x_off,y-y_off,character,scale,scale,0);
		}
		if(multiTimer >0){
			var point_text =string( num_separator( power(projectile.mult,2),",")) + "X";
			var width = string_width(point_text);
			var pointcolor = real_color;
			if(global.roundEdge){
				alpha = clamp(((power(multi_x + projectile.x_vel/fps-width/2,2) + power(multi_y + projectile.y_vel/fps,2) ) /global.play_area_radius_sq),0,1);
				var edgDist = alpha * global.edgeFalloff;
				gpu_set_depth(edgDist);
			}
			var p_scale = 2*global.screenScale*(log10(projectile.mult));
			draw_text_transformed_color(multi_x + projectile.x_vel/fps-width/2,
			multi_y + projectile.y_vel/fps,
			point_text,
			p_scale,
			p_scale,
			0,pointcolor,pointcolor,pointcolor,pointcolor, 
			1);
		}
	}
}
function draw_explosions(){
	draw_set_alpha(1);
	explosion_count = 0;
	with(obj_explosion){
		var alpha = 1/timePercentage;
	
		obj_game.explosion_count+= .05*radius;
		for(var i = 0; i < lineCount; i++){
			var x_vector = sin( random_range(0,2*pi))*10*radius * global.screenScale;
			var y_vector = cos(random_range(0,2*pi))* 10*radius* global.screenScale;
			draw_set_color(color);

			if(global.objectDepth){
			gpu_set_depth(get_gravity_depth_at_coordinate(x+ (x_vector * timePercentage),y + (y_vector * timePercentage))/global.depthMod);
			}else if(global.roundEdge){
				alpha = clamp(((power(x+ (x_vector * timePercentage*.9),2) + power(y+ (y_vector * timePercentage*.9),2) ) /global.play_area_radius_sq),0,1);
				var edgDist = alpha * global.edgeFalloff;
				alpha = (1-alpha) * (1/timePercentage);
				gpu_set_depth(edgDist);
			}		
			draw_set_alpha(alpha);
			draw_line_width(x+(x_vector * timePercentage*0.9),y+ (y_vector * timePercentage * 0.9), x+ (x_vector * timePercentage), y + (y_vector * timePercentage), 2* global.screenScale);
		}
		if(points != 0)	{
			var point_text = num_separator(points, ",");
			var width = string_width(point_text);
			var pointcolor = global.bad_color;
			if(points>0)
				pointcolor = global.good_color;
			if(global.roundEdge){
				alpha = clamp(((power(x-width/2 + text_x_vector * timePercentage,2) + power(y+text_y_vector*timePercentage,2) ) /global.play_area_radius_sq),0,1);
				var edgDist = alpha * global.edgeFalloff;
				gpu_set_depth(edgDist);
			}
			draw_text_transformed_color(x-width/2 + text_x_vector * timePercentage,
			y+text_y_vector*timePercentage,
			point_text,
			2*global.screenScale,
			2*global.screenScale,
			0,pointcolor,pointcolor,pointcolor,pointcolor, 
			min(1,(timePercentage) * 2));
		}
	}
	shake_fx_params.g_Magnitude = explosion_count;
	fx_set_parameters(shake_layer,shake_fx_params);
}
function draw_start_point(_x, _y, _scale, _level){
	set_gpu_depth_from_struct(_level.start);
	draw_set_alpha(1);
	draw_set_circle_precision(16/circle_precision_factor)
	var value = global.component_value* baseShotDelay/(shotDelay/2)
	draw_set_color(make_color_hsv( color_get_hue(global.bg_color), global.component_saturation, value ));
	
	var true_x = _x + get_struct_x_position(_level.start) * _scale;
	var true_y = _y + get_struct_y_position(_level.start) * _scale;
	draw_circle(true_x, true_y ,_level.start.r * _scale,false);
	draw_circle(true_x, true_y ,_level.start.r* _scale,true);
}
function draw_end_point(_x, _y, _scale, _level){
	
	if(global.objectDepth){
		gpu_set_depth(baseDepth);
		gpu_set_zwriteenable(false)
		gpu_set_ztestenable(false);
	}
	draw_set_circle_precision(16/circle_precision_factor)
	set_gpu_depth_from_struct(level.endpoint);
	draw_set_circle_precision(32/circle_precision_factor)
	draw_set_color(global.projectile_color);
	if(reset)
		draw_set_color(global.bad_color);
	if(global.objectDepth){
		gpu_set_zwriteenable(true)
		gpu_set_ztestenable(true);
	}
	draw_set_alpha(0.1)
	var endRad =   (_level.endpoint.dr) ;
	var true_x = _x + get_struct_x_position(_level.endpoint) * _scale;
	var true_y = _y + get_struct_y_position(_level.endpoint) * _scale;
	var _pulse = cosPulse;
	if( _level != obj_game.level)
		_pulse = 0;
	draw_circle(true_x, true_y, endRad * (1+global.multiplierRadiusMod) * _scale ,false);
	draw_set_alpha(1);	
	draw_circle(true_x, true_y ,endRad * _scale ,false);
	draw_set_color(c_black);
	draw_circle(true_x, true_y ,max(_level.endpoint.r  - _level.endpoint.damage -10 +_pulse,_level.endpoint.tr) * _scale ,false);
	if(_level == obj_game.level){
		draw_game(false, 
				get_struct_x_position(obj_game.level.endpoint), 
				get_struct_y_position(obj_game.level.endpoint),
				(obj_game.level.endpoint.tr + cosPulse)/global.play_area_radius,
				global.levels.array[min( global.currentLevel + 1, array_length(global.levels.array) - 1)]);
		if(!levelComplete && !reset){
			draw_set_color(global.good_color);
			draw_circle(true_x, true_y ,_level.endpoint.tr * _scale,true);
			draw_set_color(global.projectile_color);
			var gravRings = ((current_time-room_start)/2000* global.simRate) %1;
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
		gpu_set_depth(get_gravity_depth_at_coordinate(x_coord, y_coord, radius)/global.depthMod);
	}else if(global.roundEdge){
		var	alpha =clamp(((power(x_coord,2) + power(y_coord,2)) /global.play_area_radius_sq),0,1);
		var edgDist = alpha * global.edgeFalloff;
		alpha = 1-alpha
		gpu_set_depth(edgDist);
	}
	
}
function set_gpu_depth_from_struct(obj_struct){
	set_gpu_depth_from_point(obj_struct.v2x, obj_struct.v2y, (obj_struct.dr)/2);
}
function reset_colors(){
	
	
	global.bg_color = make_color_hsv(255,global.component_saturation,global.component_value);
	global.good_color = make_color_hsv(color_get_hue(c_lime), global.component_saturation, global.component_value);
	global.projectile_color = make_color_hsv(color_get_hue(c_aqua), global.component_saturation, global.component_value);
	global.bad_color = make_color_hsv(color_get_hue(c_red), global.component_saturation, global.component_value);
	trigger_grid_update();
}
function get_vert_alpha(x_index, y_index){
	var x1_p = power(x_index,2);
	var y1_p = power(y_index,2);
	var maxAlph = global.grid_alpha;
	//if(global.inBrowser){
	//	maxAlph *= 2;	
	//}
	var alpha = 1 -clamp(((x1_p + y1_p) /global.play_area_radius_sq),0,1);
	return alpha * maxAlph;
}
//LEGACY STUFF SAVED FOR EMERGENCY
				//if(global.grid_solid){
				//		var z_4 = global.depth_array[i-1][k-1][2];
				//		vertex_position_3d(global.v_buff, x_1 ,y_1 ,z_1+0.1);
				//		vertex_color(global.v_buff, c_black, alpha);
				//		vertex_texcoord(global.v_buff,0,0);
				//		vertex_position_3d(global.v_buff, x_2,y_1 ,z_2+0.1);
				//		vertex_color(global.v_buff, c_black, alpha);
				//		vertex_texcoord(global.v_buff,1,0);
				//		vertex_position_3d(global.v_buff, x_2+ thickness,y_2+ thickness, z_4+0.1);
				//		vertex_color(global.v_buff, c_black, alpha)
				//		vertex_texcoord(global.v_buff,1,1);
						
				//		vertex_position_3d(global.v_buff, x_1 ,y_1 ,z_1+0.1);
				//		vertex_color(global.v_buff, c_black, alpha);
				//		vertex_texcoord(global.v_buff,0,0);
				//		vertex_position_3d(global.v_buff, x_2+ thickness,y_2+ thickness, z_4+0.1);
				//		vertex_color(global.v_buff, c_black, alpha)
				//		vertex_texcoord(global.v_buff,1,1);
				//		vertex_position_3d(global.v_buff, x_1 + thickness,y_2, z_3+0.1);
				//		vertex_color(global.v_buff, c_black, alpha)
				//		vertex_texcoord(global.v_buff,0,1);
				//}