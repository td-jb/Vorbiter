/// @description Insert description here
// You can write your code in this editor

dead = false;
engineSound = noone;
multiTimer = 0;
multiLifespan = 60;
multi_x = 0;
multi_y = 0;
frame = 0;
force = 0;
startTime = current_time;
teleport_target = noone;
if(global.liveProjectiles < 150){
	engineSound = audio_play_sound(Engine,global.liveProjectiles,true,0.2);
	//if(global.liveProjectiles%2 == 0)
	//multiplierSound = audio_play_sound(multiplier_1, global.liveProjectiles, true,  1, audio_sound_get_track_position(obj_game.endSound));
	//else
	//	multiplierSound = audio_play_sound(multiplier, global.liveProjectiles, true,  1, audio_sound_get_track_position(obj_game.endSound));
	
		//audio_sound_pitch(multiplierSound, global.Game.pulseRate);
		//audio_sound_gain(multiplierSound,0,0.05);
}

x_trail = array_create(global.Settings.trailLength.value);
y_trail = array_create(global.Settings.trailLength.value);


for(var i =0; i < array_length(x_trail); i++){
	x_trail[i] = x;
	y_trail[i] = y;
	
}
points = 0;
invincibility = true;
hit_list = array_create(0);
bounceSound = noone;
projectile = noone;