//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec4 v_vPos;
uniform float f_depth_alpha;
uniform float f_max_alpha;
uniform float f_outline;

vec3 hueShift( vec3 color, float hueAdjust ){

    const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
    const vec3  kRGBToI      = vec3 (0.596, -0.275, -0.321);
    const vec3  kRGBToQ      = vec3 (0.212, -0.523, 0.311);

    const vec3  kYIQToR     = vec3 (1.0, 0.956, 0.621);
    const vec3  kYIQToG     = vec3 (1.0, -0.272, -0.647);
    const vec3  kYIQToB     = vec3 (1.0, -1.107, 1.704);

    float   YPrime  = dot (color, kRGBToYPrime);
    float   I       = dot (color, kRGBToI);
    float   Q       = dot (color, kRGBToQ);
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    hue += hueAdjust;

    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    vec3    yIQ   = vec3 (YPrime, I, Q);

    return vec3( dot (yIQ, kYIQToR), dot (yIQ, kYIQToG), dot (yIQ, kYIQToB) );

}
void main()
{
	//vec2 offsetX;
	//offsetX.x = f_outline;
	//vec2 offsetY;
	//offsetY.y = f_outline;
	float alpha = (1.0 - (pow(v_vPos.x,2.0) + pow(v_vPos.y,2.0))/f_depth_alpha);
	//alpha += ceil(texture2D( gm_BaseTexture, v_vTexcoord + offsetX).a);
	//alpha += ceil(texture2D( gm_BaseTexture, v_vTexcoord - offsetX).a);
	//alpha += ceil(texture2D( gm_BaseTexture, v_vTexcoord + offsetY).a);
	//alpha += ceil(texture2D( gm_BaseTexture, v_vTexcoord - offsetY).a);
	vec4 new_color = vec4(hueShift( v_vColour.rgb, v_vPos.z/-1000.0).rgb, v_vColour.a *alpha * f_max_alpha);
    gl_FragColor = new_color * texture2D( gm_BaseTexture, v_vTexcoord );
    //gl_FragColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
}