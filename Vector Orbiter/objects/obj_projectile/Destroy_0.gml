/// @description Insert description here
// You can write your code in this editor

var expSound = audio_play_sound(hitfx, 0, false, .2);
audio_sound_pitch(expSound, 50/projectile.r)
var explosion = instance_create_layer(x,y,"Instances", obj_explosion);
explosion.color = make_color_hsv(projectile.color,global.Settings.colorSaturation.value,global.Settings.colorValue.value);
explosion.points = points;
explosion.radius = projectile.r;
explosion.lifespan = projectile.r*global.Law.physRate/100