/// @description Insert description here
// You can write your code in this editor
if(projectile == noone || x == infinity || x == NaN || y == infinity || y == NaN)
	return;
if(multiTimer>=0){
	multiTimer--;
}
frame++;
projectile.frameMult = 0;
startTime = current_time;
if(global.Game.levelComplete || !window_has_focus()){
	log_projectile_performance_time(current_time-startTime);
	return;
}
apply_special_abilities(projectile);
//for(var i = 0; i< global.simRate; i++){
increase_projectile_radius(projectile)
var dist = apply_projectile_struct_interaction(projectile, obj_game.level.endpoint, startTime);
if( dist == -1)
	return;
set_projectile_engine_sound(dist);
for(var i= 0; i < array_length(obj_game.level.components); i++){
		dist= apply_projectile_struct_interaction(projectile, obj_game.level.components[i], startTime )
		if( dist == -1)
			return;
}
log_projectile_trail();
apply_projectile_velocity(projectile);
projectile_boundary_check(projectile);
log_projectile_performance_time(current_time-startTime);
//}
