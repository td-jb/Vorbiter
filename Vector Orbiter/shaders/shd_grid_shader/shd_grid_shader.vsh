//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vPos;
uniform float f_depth_alpha;
uniform float f_max_alpha;
uniform float f_cos_pulse;
uniform float f_pulse_height;


void main()
{
	float dist_perc =  (1.0-((pow(in_Position.x,2.0) + pow(in_Position.y,2.0))/14745600.0)) + f_cos_pulse*2.0;
	float alpha =0.0;
	float _wave = mod(dist_perc,1.0);
	float _waveHeight = f_pulse_height;
	if(_wave > 0.0 && _wave < 0.01){
		alpha = _waveHeight* cos( 3.14 *20.0 *( _wave/2.0));
	}
	if(_wave > 0.5 && _wave < 0.51){
		alpha = _waveHeight* cos( 3.14 *20.0 *( _wave/2.0));
	}
	if(_wave > 0.25 && _wave < 0.251){
		alpha = _waveHeight* cos( 3.14 *20.0 *( _wave/2.0));
	}
	if(_wave > 0.75 && _wave < 0.751){
		alpha = _waveHeight* cos( 3.14 *20.0 *( _wave/2.0));
	}
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z + alpha , 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
	v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
	v_vPos = object_space_pos;
}
