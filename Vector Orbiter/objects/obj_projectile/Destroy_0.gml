/// @description Insert description here
// You can write your code in this editor
audio_play_sound(Endplosion, 0, false, .5/global.liveProjectiles);
var explosion = instance_create_layer(x,y,"Instances", obj_explosion);
explosion.color = make_color_hsv(projectile.color,global.component_saturation,global.component_value);
explosion.points = points;
explosion.radius = projectile.r;
explosion.lifespan = projectile.r*fps/10