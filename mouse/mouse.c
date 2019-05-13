/*
 * Userspace program that communicates with the vga_ball device driver
 * through ioctls
 *
 * Stephen A. Edwards
 * Columbia University
 */

#include <stdio.h>
#include "vga_ball.h"
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

//for mouse
#include <stdlib.h>
#include <arpa/inet.h>
#include "usbmouse.h"
#include "read_mouse.h" 


int vga_ball_fd;

// for mouse
struct libusb_device_handle *mouse;
uint8_t endpoint_address;

void print_coordinate_info() {
  vga_ball_arg_t vla;

	if (ioctl(vga_ball_fd, VGA_BALL_READ_COORD, &vla)) {
		perror("ioctl(VGA_BALl_READ_COORD) failed");
		return;
	}
	//printf("(%d, %d)", vla.x, vla.y);
  printf("\n");
}

//Write the coordinates to the display 
void write_coordinates(vga_ball_arg_t* c)
{
	vga_ball_arg_t vla;
	vla = *c;
	printf("HERE(%d, %d)", vla.x, vla.y);
	if (ioctl(vga_ball_fd, VGA_BALL_WRITE_COORD, &vla)) {
		perror("ioctl(VGA_BALL_WRITE_COORD) failed");
		return;
	}
}

int main()
{

  vga_ball_arg_t vla;
  //-----------------------MOUSE_START-------------------------

  //button_1 is horizontal_sweep
  int pos_button_1_x = 500; 
  int pos_button_1_y = 350;

  //button_2 is trigger_voltage
  int pos_button_2_x = 500; 
  int pos_button_2_y = 425;

  int inputx = 320;
  int inputy = 240;
  int inputclick = 0;

  int x_distance = 50;
  int y_distance = 75;
  int x_width = 16;
  int y_width = 16

  //save trigger_voltage and horizontal sweep value
  int trigger_voltage = 2 // default 2, range(1.0 to 3.0)
  int sweep_value = 2   // default us 1, range is (1~100) 
  int trigger_slope = 1
  //the logic is drop all data except every sweep_value sample.
  char str[50] = "without mouse click";

  /* --------get mouse position and button start---- */
  // struct sockaddr_in serv_addr;
  struct mouse_info mouse0;
  init_mouse();
  /* --------get mouse position and button END---- */
  //-----------------------mouse_END------------------------
  
  int flag = 0;
  int flag2 =0;
  int a =0;
 // int i;
  static const char filename[] = "/dev/vga_ball";


# define COLORS 9

  printf("VGA ball Userspace program started\n");

  if ( (vga_ball_fd = open(filename, O_RDWR)) == -1) {
    fprintf(stderr, "could not open %s\n", filename);
    return -1;
  }

  printf("initial state: ");
 // print_background_color();
  print_coordinate_info();
  write_coordinates(&vla);
    printf("initial state: ");
 // print_background_color();
  print_coordinate_info();

  while(1) {
   // set_background_color(&colors[i % COLORS ],600,200);
    //print_background_color();
  
  //-----------------------MOUSE_START-------------------------
  // struct sockaddr_in serv_addr;

    read_mouse(&mouse0);
    printf("position of x, y are: %d %d; left click is %d\n",mouse0.x,mouse0.y,mouse0.button);

  //-----------------------mouse_END------------------------
		
  //-----------------------parameter------------------------
    inputx = mouse0.x;
    inputy = mouse0.y;
    inputclick = mouse0.button; // mouse0.button/click is 0, 1, or 2. left click is 1

    if (mouse0.button == 1){
      if (pos_button_1_y<inputy && inputy<pos_button_1_y + x_width){ 
        if ( pos_button_1_x<inputx && inputx<pos_button_1_x + x_width){
          trigger_voltage = trigger_voltage + 0.5; str = "click add trigger_voltage";}
        else if ( pos_button_1_x + x_distance<inputx && inputx<pos_button_1_x + (x_distance+x_width)){
          trigger_voltage = trigger_voltage - 0.5; str = "click add trigger_voltage";}
        // else {continue;}
      }
      else if (pos_button_1_y+y_distance<inputy && inputy<pos_button_1_y+(y_distance+y_width)){ 
        if ( pos_button_1_x<inputx && inputx<pos_button_1_x + x_width){
          // sweep_value = sweep_value *2; str = "click button sweep_value x2";}
          trigger_slope = 0; str = "click button trigger_slope minus";}
        else if ( pos_button_1_x + x_distance<inputx && 
          inputx<pos_button_1_x + (x_distance+x_width)){
          // sweep_value = sweep_value /2; str = "click button sweep_value /2";}
          trigger_slope = 1; str = "click button trigger_slope pos";}
        // else {continue;}
      }
      printf("trigger_voltage: %d, trigger_slope: %d, the button state: %s", trigger_voltage,trigger_slope,str);
    }

  //-----------------------parameter END------------------------ 
    vla.x = mouse0.x;
    vla.y = mouse0.y;
    vla.trigger_voltage = trigger_voltage
    vla.sweep_value = sweep_value
    vla.trigger_slope = trigger_slope
		//printf("XandY(%d, %d)", vla.x, vla.y);
    		print_coordinate_info();
    		write_coordinates(&vla);
		a =a+1;
		printf("a:%d",a);

    		usleep(400000);

		//printf("XandY(%d, %d)", vla.x, vla.y);
    		print_coordinate_info();
    		write_coordinates(&vla);
		usleep(400000);
		a=a+1;
		printf("a:%d",a);

  }
  
  printf("VGA BALL Userspace program terminating\n");
  return 0;
}
