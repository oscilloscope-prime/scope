#include "usbmouse.h"
#include "read_mouse.h"
#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <arpa/inet.h>
#include <unistd.h>

int main(void)
{
	/* code */
	struct mouse_info mouse0;
	init_mouse();

	for(;;){
		read_mouse(&mouse0);

		printf("position of x, y are: %d %d; left click is %d\n",mouse0.x,mouse0.y,mouse0.button);
	}

	return 0;
}