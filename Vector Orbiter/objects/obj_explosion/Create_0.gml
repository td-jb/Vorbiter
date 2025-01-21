/// @description Insert description here
// You can write your code in this editor
color = c_white;
timeNow = 0;
timePercentage = 0;
lifespan = fps;
lineCount = 5;
alarm[0] = lifespan;
points = 0;
radius = 10;

	text_x_vector = sin( random_range(0,2*pi))*5 *  global.screenScale;
	text_y_vector = cos(random_range(0,2*pi))* 5 * global.screenScale;