/// @description Insert description here
// You can write your code in this editor
if(global.intro||!global.show_ui)
	return;

draw_set_color(c_white);
var topLeftString =  "Score: " + num_separator(global.score, ",");
if(global.debugMode != DebugMode.NONE){
	switch(global.debugMode){
		case DebugMode.SCREEN:
			topLeftString += "\nScreen Debug";
			break;
		case DebugMode.PERFORMANCE:
			topLeftString += "\nPerformance Debug";
			break;
		case DebugMode.INPUT:
			topLeftString += "\nglobal.Input Debug";
			break;
		
	}
	if(global.debugMode  == DebugMode.SCREEN){
			
		topLeftString += ("\nWindow Width: " + string(window_get_width()) + 
		"\nWindow Height: " + string(window_get_height()) + 
		"\nRoom Width: " + string(room_width)
		+"\nRoom Height: " + string(room_height)
		+"\nView Width: " + string(view_wport[0])
		+"\nView Height: " + string(view_hport[0])
		+"\nCam Width: " + string(camera_get_view_width(view_camera[0]))
		+"\nCam Height: " + string(camera_get_view_height(view_camera[0]))
		+"\nDisp Width: " + string(display_get_width()) + 
		"\nDisp Height: " + string(display_get_height()))
		topLeftString += "\nStart X: " + string(global.Graphics.currX)+ " Start Y: " + string(global.Graphics.currY);
		topLeftString += "\nEnd X: " + string(global.Graphics.currX+global.Graphics.currWidth)+ " End Y: " + string(global.Graphics.currY+global.Graphics.currHeight);
		topLeftString += "\nCurr Width: " + string(global.Graphics.currWidth) + " Curr Height: " + string(global.Graphics.currHeight);
		topLeftString += "\ntarget X: " + string(global.Graphics.targetX);
		topLeftString += "\ntarget Y: " + string(global.Graphics.targetY);
		topLeftString += "\ntarget Width: " + string(global.Graphics.currWidth*global.Graphics.screenScale);
		topLeftString += "\ntarget Height: " + string(global.Graphics.currHeight * global.Graphics.screenScale);
		topLeftString += "\nScreen Scale: " + string(global.Graphics.screenScale);
		topLeftString += "\nGrid X Count: " + string(global.Graphics.gridCountX) + " Grid Y Count: " + string(global.Graphics.gridCountX) + " Sim Count: " + string(global.sim_grid_count);
		topLeftString += "\nGrid X Offset: " + string(global.Graphics.grid_x_offset) + " Grid Y Offset: " + string(global.Graphics.grid_y_offset);
		topLeftString += "\nGrid Width: " + string(global.Graphics.gridWidth) + " Grid Height: " + string(global.Graphics.gridHeight);
		topLeftString += "\nGrid Size: " + string(global.grid_size) + " Grid Calc Width: " + string(global.grid_size * global.Graphics.gridCountX);
		topLeftString += "\nMin Projectile X: " + string(global.Graphics.minProjectileX) + " Max Projectile X: " + string(global.Graphics.maxProjectileX);
		topLeftString += "\nMin Projectile Y: " + string(global.Graphics.minProjectileY) + " Max Projectile Y: " + string(global.Graphics.maxProjectileY);
		topLeftString += "\nActive Grid Updates: " + string(array_length( obj_game.spiral_grid_updates) +array_length( obj_game.grid_updates));

	}
	if(global.debugMode == DebugMode.PERFORMANCE){
		
		if(!global.Law.inBrowser){
			log_sum_performance_time();
		}
		if(fps < global.Law.physRate)
			global.Law.physRate = fps;
		topLeftString += "\nFPS:           " + string(fps) + " Min: " + string(global.Law.physRate);
		topLeftString += "\nShot Preview:  " + string(global.trajectoryTime) + " ms (" + string(global.trajectoryTime*100/global.sumTime) + "%) Max: " + string(global.maxTrajectoryTime);
		topLeftString += "\nProjectiles:   " + string(global.projectileTime) + " ms (" + string(global.projectileTime*100/global.sumTime) + "%) Max: " + string(global.maxProjectileTime);
		topLeftString += "\nGrid Update:   " + string(global.gridUpdateTime) + " ms (" + string(global.gridUpdateTime*100/global.sumTime) + "%) Max: " + string(global.maxGridUpdateTime);
		topLeftString += "\nGrid Verts:    " + string(global.gridVertexTime) + " ms (" + string(global.gridVertexTime*100/global.sumTime) + "%) Max: " + string(global.maxVertexTime);
		topLeftString += "\nGame Draw:     " + string(global.drawTime) + " ms (" + string(global.drawTime*100/global.sumTime) + "%) Max: " + string(global.maxDrawTime);
		if(!global.Law.inBrowser){
			topLeftString += "\nSum Time:      " + string(global.sumTime) + " Max: " + string(global.maxSumTime);
			topLeftString += "\nCalc Framerate:" + string(round(1000/global.sumTime));
		}
	}
	if(global.debugMode == DebugMode.INPUT){
		topLeftString += "\nLMB: " + string(mouse_check_button(mb_left));
		topLeftString += "\nRMB: " + string(mouse_check_button(mb_right));
		topLeftString += "\nScroll Up: " + string(mouse_wheel_up()) + " Scroll Down: " + string(mouse_wheel_down());
		topLeftString += "\nIn Window: " + string(obj_game.mouseInWindow);
		topLeftString += "\n Locked: " + string(window_mouse_get_locked());
		
	}
		
	if(global.Law.inBrowser){
		
		topLeftString += "\nWebGl Enabled: " + string(webgl_enabled);	
	}
}
draw_text(textMargin , textMargin, topLeftString);
var bottom_right_x = display_get_gui_width() -textMargin;
var bottom_right_y = display_get_gui_height()-textMargin;

var timePercentage = (current_time%2000)/2000
timePercentage = clamp(timePercentage, 0, 1);
var prompt_width = sprite_get_width(spr_back) * sprite_scale;
