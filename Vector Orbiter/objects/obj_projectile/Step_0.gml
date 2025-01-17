/// @description Insert description here
// You can write your code in this editor
if(multiTimer>=0){
	multiTimer--;
}
frame++;
projectile.frameMult = 0;
var startTime = current_time;
if(obj_game.levelComplete || !window_has_focus()){
	log_projectile_performance_time(current_time-startTime);
	return;
}
//for(var i = 0; i< global.simRate; i++){
	increase_projectile_radius(projectile)
	var dist =apply_gravitational_acceleration(obj_game.level.endpoint, x, y,get_projectile_mass(projectile.r), projectile);
	apply_flyby_mod(obj_game.level.endpoint,dist,projectile.r, projectile);
	if( collision_check(obj_game.level.endpoint, dist, projectile.r)){
		var old_mass = (obj_game.level.endpoint.mass);
		add_damage( obj_game.level.endpoint, get_projectile_damage(projectile)) ;
		if(obj_game.level.endpoint.r > obj_game.level.endpoint.tr){
			audio_sound_pitch(obj_game.endSound, obj_game.pulseRate);
		}else{
			audio_sound_pitch(obj_game.endSound, 1);
		}
		audio_play_sound(GoodSound, 0, false, 0.5);
		projectile.color = color_get_hue(global.good_color);
		points =   pi *(power(projectile.r, 2) * power(projectile.mult,2));
		add_points(points);
		instance_destroy();
		
		log_projectile_performance_time(current_time-startTime);
		return;
	}

	var enginePitch = (power(room_width,2)/(dist))/2;
	if((engineSound) != noone)
		audio_sound_pitch(engineSound,enginePitch);
	else{
		if(global.liveProjectiles < 150){
		
			engineSound = audio_play_sound(Engine,global.liveProjectiles,true, 0.5);
		}
	}
	for(var i= 0; i < array_length(obj_game.level.components); i++){
	dist =apply_gravitational_acceleration(obj_game.level.components[i], x, y,get_projectile_mass(projectile.r), projectile);
	apply_flyby_mod(obj_game.level.components[i],dist,projectile.r, projectile);
		if( collision_check(obj_game.level.components[i], dist, projectile.r)){
			
			projectile.color = global.neutral_hue;
			//points =  pi *(projectile.r* projectile.r) * projectile.mult
			add_damage(obj_game.level.components[i], get_projectile_damage(projectile)*2.5);
			audio_play_sound(BadSound, 0, false, 0.5);
			//add_points(0);
			var endDistSquare = power(get_struct_x_position( obj_game.level.components[i]) - get_struct_x_position( obj_game.level.endpoint), 2) + power(get_struct_y_position( obj_game.level.components[i])- get_struct_y_position( obj_game.level.endpoint), 2);
			var startDistSq = power(obj_game.level.components[i].v2x - get_struct_x_position( obj_game.level.start), 2) + power(obj_game.level.components[i].v2y -get_struct_y_position( obj_game.level.start), 2);
			var radSquare = power(obj_game.level.endpoint.r - obj_game.level.endpoint.damage + obj_game.level.components[i].r +obj_game.level.components[i].damage, 2)
			var startRadSquare = power(obj_game.level.start.r + obj_game.level.components[i].r +obj_game.level.components[i].damage, 2)
			
			instance_destroy();
			if(radSquare > endDistSquare || startRadSquare >= startDistSq){
				trigger_reset();
				
			}	
			
			
			log_projectile_performance_time(current_time-startTime);
			return;
		}
	

	}
	if(frame % global.trail_sample_rate == 0){
		for(var i =array_length(x_trail) -1; i > 0; i--){

			x_trail[i] = x_trail[i-1];
			y_trail[i] = y_trail[i-1];
	
		}
		x_trail[0] = x;
		y_trail[0] = y;
	}
	x += (projectile.x_vel * global.simRate/60);
	y += (projectile.y_vel * global.simRate/60);
	projectile.x_pos = x;
	projectile.y_pos = y;
	var distSquare = power( x , 2)+ power(y,2) - power(projectile.r,2);
	var compareSquare = global.play_area_radius_sq;
	var startDist = power(get_struct_x_position(obj_game.level.start) - x, 2) + power(get_struct_y_position(obj_game.level.start) - y, 2);
	var startComp = power(obj_game.level.start.r + projectile.r, 2);
	if(!dead && (distSquare >= compareSquare || (startDist < startComp && current_time - create_time > invincibility))){

		if( bounceSound == noone || !audio_is_playing(bounceSound))
		bounceSound = audio_play_sound(Bounce,0,false,0.5);
		var pitch = floor(random_range(1,4.5))
		if((startDist < startComp && current_time - create_time > invincibility)){
		//points =  - (pi *(projectile.r* projectile.r))/2;
		//add_points(points);
		//projectile.color = color_get_hue(global.bad_color);
			pitch = pitch/4;
			if(instance_exists(bounceSound))
				audio_sound_pitch(bounceSound, pitch);
			var mass = get_projectile_mass(projectile.r);
			obj_game.level.start.d_x += (projectile.r/2* projectile.x_vel/global.minFrameRate);
			
			obj_game.level.start.d_y += (projectile.r/2*projectile.y_vel/global.minFrameRate);
			projectile.x_vel = (-projectile.x_vel * random_range(0.9,1.2));
			projectile.y_vel = (-projectile.y_vel * random_range(0.9,1.2));
			var newX = get_struct_x_position(obj_game.level.start);
			var newY = get_struct_y_position(obj_game.level.start)
			var compCheck = false;
			for(var i = 0; i < array_length( obj_game.level.components); i++){
				if(collision_check(obj_game.level.components[i],get_square_distance(obj_game.level.components[i], newX, newY),obj_game.level.start.r)){
						compCheck = true;
						break;
				}
				
			}
			if(power( newX,2)+power(newY,2)>global.play_area_radius_sq
			|| collision_check(obj_game.level.endpoint,get_square_distance(obj_game.level.endpoint,newX, newY), obj_game.level.start.r)||
			compCheck)
				trigger_reset();
			alarm[0] = fps/4;
			dead = true;
		}else{
			obj_game.stopTimer = 60;
			
			//if(instance_exists(bounceSound))
			//audio_sound_pitch(bounceSound, pitch);
			//projectile.x_vel = (-projectile.x_vel * random_range(0.9,1.2));
			//projectile.y_vel = (-projectile.y_vel * random_range(0.9,1.2));
			instance_destroy();
		}
		
		log_projectile_performance_time(current_time-startTime);
		return;
	}
	
	log_projectile_performance_time(current_time-startTime);
//}
