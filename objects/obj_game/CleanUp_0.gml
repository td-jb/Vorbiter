/// @description Insert description here
// You can write your code in this editor
if(endSound != noone)
	audio_stop_sound(endSound);
	
audio_stop_sound(shootingSound);
audio_stop_sound(multSound);
audio_emitter_free(endEmitter);