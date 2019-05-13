#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/time.h>

//for mouse
#include "usbmouse.h"
#include "read_mouse.h" 
#include <string.h>
#include <arpa/inet.h>

//defining colors for tiles
#define emptycolor 0x00
#define textcolor 0x80
//can change at any moment, doesn't matter
//emptycolor is for 0 
//textcolor is for 1

//tile encodings, font is 8x8, including buttons

int bytesmouse; //bytes read from mouse

int main(){
	//screen starts at 0,0 on upper left
	//the corner of the button position, the others corners are {(x,y+8),(x+8,y),(x+8,y+8)}

	//button_1 is horizontal_sweep
	int pos_button_1_x = 480; 
	int pos_button_1_y = 360;

	//button_2 is trigger_voltage
	int pos_button_2_x = 480; 
	int pos_button_2_y = 380;

	int inputx = 320;
	int inputy = 240;
	int inputclick = 0;

	int x_distance = 32;
	int y_distance = 24;
	int x_width = 16;
	int y_width = 16

	//save trigger_voltage and horizontal sweep value
	int trigger_voltage = 2	// default 2, range(1.0 to 3.0)
	int sweep_value = 2 	// default us 1, range is (1~100) 
	//the logic is drop all data except every sweep_value sample.
	char str[50] = "without mouse click";

	/* --------get mouse position and button start---- */
	struct mouse_info mouse0;
	init_mouse();
	/* --------get mouse position and button END---- */

	while (1){
		read_mouse(&mouse0); //info sent from rex in a buffer
		printf("position of x, y are: %d %d; left click is %d\n",mouse0.x,mouse0.y,mouse0.button);
		inputx = mouse0.x;
		inputy = mouse0.y;
		inputclick = mouse0.button; // mouse0.button/click is 0, 1, or 2. left click is 1

		if (mouse0.button == 1){
			if (pos_button_1_y<inputy && inputy<pos_button_1_y + x_width){ 
				if ( pos_button_1_x<inputx && inputx<pos_button_1_x + x_width){
					trigger_voltage = trigger_voltage + 0.5; str = "click add trigger_voltage";}
				else if ( pos_button_1_x + x_distance<inputx && inputx<pos_button_1_x + (x_distance+x_width)){
					trigger_voltage = trigger_voltage - 0.5; str = "click add trigger_voltage";}
				else {continue;}
			}
			else if (pos_button_1_y+24<inputy && inputy<pos_button_1_y+40){ 
				if ( pos_button_1_x<inputx && inputx<pos_button_1_x + x_width){
					sweep_value = sweep_value *2; str = "click button sweep_value x2";}
				else if ( pos_button_1_x + x_distance<inputx && 
					inputx<pos_button_1_x + (x_distance+x_width) && 
					sweep_value > 1){
					sweep_value = sweep_value /2; str = "click button sweep_value /2";}
				else {continue;}
			}
			printf("trigger_voltage: %d, sweep_value: %d, the button state: %s", trigger_voltage,sweep_value,str);
		}
		//infinite while ends
	}
//main ends
}

