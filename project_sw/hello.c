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

int vga_ball_fd;

/* Read and print the background color 
void print_background_color() {
  vga_ball_arg_t vla;
  
  if (ioctl(vga_ball_fd, VGA_BALL_READ_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_READ_BACKGROUND) failed");
      return;
  }
  printf("%02x %02x %02x\n",
	 vla.background.red, vla.background.green, vla.background.blue);
}

/* Set the background color 
void set_background_color(const vga_ball_color_t *c,unsigned short xcoord, unsigned short ycoord)
{
  vga_ball_arg_t vla;
  vla.x = xcoord;
  vla.y = ycoord;
  vla.background = *c;
  if (ioctl(vga_ball_fd, VGA_BALL_WRITE_BACKGROUND, &vla)) {
      perror("ioctl(VGA_BALL_SET_BACKGROUND) failed");
      return;
  }
}*/
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
  int flag = 0;
  int flag2 =0;
  int a =0;
 // int i;
  static const char filename[] = "/dev/vga_ball";
  vla.x = 30;
  vla.y = 50;
  //static const vga_ball_color_t colors[] = {
   // { 0xff, 0x00, 0x00 }, /* Red */
   // { 0x00, 0xff, 0x00 }, /* Green */
  //  { 0x00, 0x00, 0xff }, /* Blue */
   // { 0xff, 0xff, 0x00 }, /* Yellow */
   // { 0x00, 0xff, 0xff }, /* Cyan */
  //  { 0xff, 0x00, 0xff }, /* Magenta */
  //  { 0x80, 0x80, 0x80 }, /* Gray */
   // { 0x00, 0x00, 0x00 }, /* Black */
    //{ 0xff, 0xff, 0xff }  /* White */
  //};

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
	
		if (flag ==0){
		vla.x = vla.x + 60;
		}
		

		/*if (flag2==0){
		vla.y = vla.y+ 20;
		}
		else 
		{
		vla.y = vla.y -20;
		}*/

		
		if(vla.x > 1250)
		{
		vla.x =30;
		}
		
		/*
		if(vla.y > 465)
		{
		flag2 = 1;
		}
		if(vla.y <16)
		{
		flag2 = 0;
		}*/
	
		//vla.x= 180;
		vla.y= 180;

		//printf("XandY(%d, %d)", vla.x, vla.y);
    		print_coordinate_info();
    		write_coordinates(&vla);
		a =a+1;
		printf("a:%d",a);

    		usleep(400000);

		//vla.x= 120;
		vla.y= 120;

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
