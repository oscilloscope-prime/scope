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


static unsigned char  A[] = {B00000000,
	B00011000,
	B00100100,
	B01000010,
	B01111110,
	B01000010,
	B01000010,
	B00000000};
static unsigned char  B[] = {B00000000,
	B01111000,
	B01000100,
	B01111000,
	B01000110,
	B01000010,
	B01111100,
	B00000000};
static unsigned char  C[] = {B00000000,
	B00111100,
	B01100010,
	B01000000,
	B01000000,
	B01100010,
	B00111100,
	B00000000};
static unsigned char  D[] = {B00000000,
	B01111100,
	B01000110,
	B01000010,
	B01000010,
	B01000110,
	B01111100,
	B00000000};
static unsigned char   E[] = {B00000000,
	B01111110,
	B01000000,
	B01111000,
	B01000000,
	B01000000,
	B01111110,
	B00000000};
static unsigned char   F[] = {B00000000,
	B01111110,
	B01000000,
	B01000000,
	B01111000,
	B01000000,
	B01000000,
	B00000000};
static unsigned char   G[] = {B00000000,
	B00111100,
	B01000010,
	B01000000,
	B01001110,
	B01000010,
	B01111010,
	B00000000};
static unsigned char   H[] = {B00000000,
	B01000010,
	B01000010,
	B01111110,
	B01000010,
	B01000010,
	B01000010,
	B00000000};
static unsigned char   I[] = {B00000000,
	B01111110,
	B00011000,
	B00011000,
	B00011000,
	B00011000,
	B01111110,
	B00000000};
static unsigned char   J[] = {B00000000,
	B01111110,
	B00001000,
	B00001000,
	B00001000,
	B01001000,
	B01111000,
	B00000000};
static unsigned char   K[] = {B00000000,
	B01000100,
	B01001000,
	B01010000,
	B01101000,
	B01000100,
	B01000010,
	B00000000};
static unsigned char   L[] = {B00000000,
	B01000000,
	B01000000,
	B01000000,
	B01000000,
	B01000000,
	B01111110,
	B00000000};
static unsigned char   M[] = {B00000000,
	B01000010,
	B01100110,
	B01011010,
	B01000010,
	B01000010,
	B01000010,
	B00000000};
static unsigned char   N[] = {B00000000,
	B01000010,
	B01100010,
	B01010010,
	B01001010,
	B01000110,
	B01000010,
	B00000000};
static unsigned char   O[] = {B00000000,
	B00111100,
	B01000010,
	B01000010,
	B01000010,
	B01000010,
	B00111100,
	B00000000};
static unsigned char   P[] = {B00000000,
	B01111100,
	B01000010,
	B01000010,
	B01111100,
	B01000000,
	B01000000,
	B00000000};
static unsigned char   Q[] = {B00000000,
	B00111100,
	B01000010,
	B01000010,
	B01001010,
	B01000100,
	B00111010,
	B00000000};
static unsigned char   R[] = {B00000000,
	B01111000,
	B01000100,
	B01000100,
	B01111000,
	B01000100,
	B01000010,
	B00000000};
static unsigned char   S[] = {B00000000,
	B00111110,
	B01000000,
	B01111100,
	B00000010,
	B00000010,
	B01111100,
	B00000000};
static unsigned char   T[] = {B00000000,
	B01111110,
	B00011000,
	B00011000,
	B00011000,
	B00011000,
	B00011000,
	B00000000};
static unsigned char   U[] = {B00000000,
	B01000010,
	B01000010,
	B01000010,
	B01000010,
	B01000010,
	B00111100,
	B00000000};
static unsigned char   V[] = {B00000000,
	B01000010,
	B01000010,
	B01000010,
	B01000010,
	B00100100,
	B00011000,
	B00000000};
static unsigned char   W[] = {B00000000,
	B01000010,
	B01000010,
	B01000010,
	B01011010,
	B01100110,
	B01000010,
	B00000000};
static unsigned char   X[] = {B00000000,
	B01000010,
	B00100100,
	B00011000,
	B00011000,
	B00100100,
	B01000010,
	B00000000};
static unsigned char   Y[] = {B00000000,
	B01000010,
	B01000010,
	B00100100,
	B00011000,
	B00011000,
	B00011000,
	B00000000};
static unsigned char   Z[] = {B00000000,
	B01111110,
	B00000100,
	B00001000,
	B00010000,
	B00100000,
	B01111110,
	B00000000};
static unsigned char period[]=B00000000,
	B00000000,
	B00000000,
	B00000000,
	B00000000,
	B00011000,
	B00011000,
	B00000000};
static unsigned char   zero[] = {B00000000,
	B00111100,
	B01100110,
	B01010010,
	B01001010,
	B01100110,
	B00111100,
	B00000000};
static unsigned char   one[] = {B00000000,
	B00111000,
	B01001000,
	B00001000,
	B00001000,
	B00001000,
	B01111110,
	B00000000};
static unsigned char   two[] = {B00000000,
	B00111100,
	B01000010,
	B00000100,
	B00011000,
	B00100000,
	B01111110,
	B00000000};
static unsigned char   three[] = {B00000000,
	B00111110,
	B00000010,
	B00001100,
	B00000010,
	B01000010,
	B00111100,
	B00000000};
static unsigned char   four[] = {B00000000,
	B00001100,
	B00010100,
	B00100100,
	B01111110,
	B00000100,
	B00000100,
	B00000000};
static unsigned char   five[] = {B00000000,
	B01111110,
	B01000000,
	B01111100,
	B00000010,
	B01000010,
	B00111100,
	B00000000};
static unsigned char   six[] = {B00000000,
	B01111000,
	B01000100,
	B01000000,
	B01111110,
	B01000010,
	B01111110,
	B00000000};
static unsigned char   seven[] = {B00000000,
	B01111100,
	B01000100,
	B00000100,
	B00001110,
	B00000100,
	B00000100,
	B00000000};
static unsigned char   eight[] = {B00000000,
	B00111100,
	B01000010,
	B00111100,
	B01000010,
	B01000010,
	B00111100,
	B00000000};
static unsigned char   nine[] = {B00000000,
	B01111110,
	B01000010,
	B01111110,
	B00000010,
	B00100010,
	B00011110,
	B00000000};
static unsigned char   lessthan[] = {B00000000,
	B00000000,
	B00011110,
	B01100000,
	B01100000,
	B00011110,
	B00000000,
	B00000000};
static unsigned char   greaterthan[] = {B00000000,
	B00000000,
	B01111000,
	B00000110,
	B00000110,
	B01111000,
	B00000000,
	B00000000};
static unsigned char   plussign[] = {B00000000,
	B00000000,
	B00011000,
	B00111100,
	B00111100,
	B00011000,
	B00000000,
	B00000000};
static unsigned char   minussign[] = {B00000000,
	B00000000,
	B00000000,
	B00111100,
	B00111100,
	B00000000,
	B00000000,
	B00000000};
static unsigned char   equalssign[] = {B00000000,
	B00000000,
	B00000000,
	B00111100,
	B00000000,
	B00111100,
	B00000000,
	B00000000};
static unsigned char   dividesign[] = {B00000000,
	B00000010,
	B00000100,
	B00001000,
	B00010000,
	B00100000,
	B01000000,
	B00000000};
static unsigned char   buttonplus[] = {B11111111,
	B10000001,
	B10011001,
	B10111101,
	B10111101,
	B10011001,
	B10000001,
	B11111111};
static unsigned char   buttonless[] = {B11111111,
	B10000001,
	B10000001,
	B10111101,
	B10111101,
	B10000001,
	B10000001,
	B11111111};
static unsigned char   buttondivide[] = {B11111111,
	B10000001,
	B10000101,
	B10001001,
	B10010001,
	B10100001,
	B10000001,
	B11111111};
static unsigned char   buttonmultiply[] = {B11111111,
	B10000001,
	B10100101,
	B10011001,
	B10011001,
	B10100101,
	B10000001,
	B11111111};
static unsigned char   percentagesign[] = {B00000000,
	B00000010,
	B00100100,
	B00001000,
	B00010000,
	B00100100,
	B01000000,
	B00000000};


//all functions that use value changes go here, called from main, inside nested switch cases
//what should the default be though?

static unsigned char numberarray[] = {zero[], one[], two[], three[], four[], five[], six[], seven[], eight[], nine[]};

//define current value to be the last displayed value for given position (up to 3 values), haven't coded this yet
//default value must be defined outside of main, be accessed by the functions, and main must update value contiuously
//is this even possible?

//need to get these from number array

unsigned char currenthp[]{plussign[],zero[],zero[],zero[]}; //default set to +000, range -320 to 320
unsigned char currenths[]{zero[],five[],zero[],zero[]};//default set to 0500, range 1-1000
unsigned char currentvp[]{plussign[],zero[],zero[],zero[]};//default set to +000, range -240 to 240
unsigned char currentvs[]{zero[],zero[],five[]};//default set to 005, range 1-10
unsigned char currentts[]{plussign[]};//default to plus sign
unsigned char currenttv[]{two[],period[],zero[]};//default set to 2.0, range 0.1-3.9

void horizontalsweepdivide(){
//default divide to be by 10
	if (currenths[0] == zero[] && currenths[1] == zero[] && currenths[2] == zero[]){
		currenths[] = currenths[]; //prevents going to less than one unit
	}
	else{
		//division sequence
		if (currenths[0]==one[]&&currenths[1]==zero[]&&currenths[2]==zero[]&&currenths[3]==zero[]){currenths[]={zero[],one[],zero[],zero[]};} //division for 1000
		else if (currenths[1] == zero[]){
			if (currenths[2] == zero[]){currenths[] = currenths[];}//division for 00x0
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],zero[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],zero[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],zero[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],zero[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],zero[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],zero[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],zero[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],zero[],eight[]};}
			else{currenths[]={zero[],zero[],zero[],nine[]};}
		}
		else if (currenths[1] == one[]){//division for 01x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],one[],zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],one[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],one[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],one[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],one[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],one[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],one[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],one[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],one[],eight[]};}
			else{currenths[]={zero[],zero[],one[],nine[]};}
		}
		else if (currenths[1] == two[]){//division for 02x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],two[].zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],two[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],two[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],two[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],two[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],two[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],two[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],two[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],two[],eight[]};}
			else{currenths[]={zero[],zero[],two[],nine[]};}
		}
		else if (currenths[1] == three[]){//division for 03x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],three[].zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],three[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],three[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],three[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],three[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],three[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],three[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],three[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],three[],eight[]};}
			else{currenths[]={zero[],zero[],three[],nine[]};}
		}
		else if (currenths[1] == four[]){//division for 04x0
			if (currenths[2] == zero[]){currenths[] = {zero[], zero[],four[].zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],four[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],four[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],four[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],four[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],four[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],four[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],four[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],four[],eight[]};}
			else{currenths[]={zero[],zero[],four[],nine[]};}
		}
		else if (currenths[1] == five[]){//division for 05x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],five[].zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],five[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],five[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],five[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],five[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],five[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],five[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],five[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],five[],eight[]};}
			else{currenths[]={zero[],zero[],five[],nine[]};}
		}
		else if (currenths[1] == six[]){//division for 06x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],six[],zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],six[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],six[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],six[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],six[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],six[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],six[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],six[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],six[],eight[]};}
			else{currenths[]=zero[],zero[],six[],nine[]};}
		}
		else if (currenths[1] == seven[]){//division for 07x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],seven[].zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],seven[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],seven[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],seven[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],seven[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],seven[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],seven[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],seven[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],seven[],eight[]};}
			else{currenths[]={zero[],zero[],seven[],nine[]};}
		}
		else if (currenths[1] == eight[]){//division for 08x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],eight[],zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],eight[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],eight[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],eight[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],eight[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],eight[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],eight[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],eight[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],eight[],eight[]};}
			else{currenths[]={zero[],zero[],eight[],nine[]};}
		}
		else {//division for 09x0
			if (currenths[2] == zero[]){currenths[] = {zero[],zero[],nine[],zero[]};}
			else if (currenths[2]==one[]){currenths[] = {zero[],zero[],nine[],one[]};}
			else if (currenths[2]==two[]){currenths[] = {zero[],zero[],nine[],two[]};}
			else if (currenths[2]==three[]){currenths[] = {zero[],zero[],nine[],three[]};}
			else if (currenths[2]==four[]){currenths[] = {zero[],zero[],nine[],four[]};}
			else if (currenths[2]==five[]){currenths[] = {zero[],zero[],nine[],five[]};}
			else if (currenths[2]==six[]){currenths[] = {zero[],zero[],nine[],six[]};}
			else if (currenths[2]==seven[]){currenths[] = {zero[],zero[],nine[],seven[]};}
			else if (currenths[2]==eight[]){currenths[] = {zero[],zero[],nine[],eight[]};}
			else{currenths[]={zero[],zero[],nine[],nine[]};}
		}
	}
}
void horizontalsweepmultiply(){
//default multiply by 10
	if (currenths[0] == one[]) {
		currenths[] = currenths[];//prevents going past 4 digits
	}
	else if (currenths[0] == zero[] && (currenths[1] == (two[] || three[] ||four[] || five[] || six[] || seven[] || eight[] || nine[] )) ){
		currenths[]=currenths[];//prevents multiplication by 10 past 100
	}
	else if (currenths[0] == zero[] && curenths[1] == one[] && (currenths[2] != zero[] || currenths[3] != zero[])){
		currenths[] = currenths[];//prevents multiplication by 10 past 100
	}
	else{
		//multiplication sequence
		if (currenths[2] == zero[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],zero[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],zero[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],zero[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],zero[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],zero[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],zero[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],zero[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],zero[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],zero[],eight[],zero[]};}
			else{currenths[]={zero[],zero[],nine[],zero[]};}
		}
		else if (currenths[2] == one[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],one[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],one[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],one[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],one[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],one[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],one[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],one[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],one[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],one[],eight[],zero[]};}
			else{currenths[]={zero[],one[],nine[],zero[]};}
		}
		else if (currenths[2] == two[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],two[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],two[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],two[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],two[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],two[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],two[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],two[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],two[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],two[],eight[],zero[]};}
			else{currenths[]={zero[],two[],nine[],zero[]};}
		}
		else if (currenths[2] == three[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],three[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],three[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],three[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],three[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],three[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],three[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],three[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],three[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],three[],eight[],zero[]};}
			else{currenths[]={zero[],three[],nine[],zero[]};}
		}
		else if (currenths[2] == four[]){
			if (currenths[3] == zero[]){currenths[] = {zero[], four[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],four[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],four[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],four[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],four[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],four[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],four[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],four[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],four[],eight[],zero[]};}
			else{currenths[]={zero[],four[],nine[],zero[]};}
		}
		else if (currenths[2] == five[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],five[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],five[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],five[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],five[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],five[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],five[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],five[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],five[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],five[],eight[],zero[]};}
			else{currenths[]={zero[],five[],nine[],zero[]};}
		}
		else if (currenths[2] == six[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],six[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],six[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],six[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],six[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],six[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],six[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],six[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],six[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],six[],eight[],zero[]};}
			else{currenths[]={zero[],six[],nine[],zero[]};}
		}
		else if (currenths[2] == seven[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],seven[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],seven[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],seven[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],seven[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],seven[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],seven[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],seven[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],seven[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],seven[],eight[],zero[]};}
			else{currenths[]={zero[],seven[],nine[],zero[]};}
		}
		else if (currenths[2] == eight[]){
			if (currenths[3] == zero[]){currenths[] = {zero[],eight[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],eight[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],eight[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],eight[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],eight[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],eight[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],eight[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],eight[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],eight[],eight[],zero[]};}
			else{currenths[]={zero[],eight[],nine[],zero[]};}
		}
		else {
			if (currenths[3] == zero[]){currenths[] = {zero[],nine[].zero[],zero[]};}
			else if (currenths[3]==one[]){currenths[] = {zero[],nine[],one[],zero[]};}
			else if (currenths[3]==two[]){currenths[] = {zero[],nine[],two[],zero[]};}
			else if (currenths[3]==three[]){currenths[] = {zero[],nine[],three[],zero[]};}
			else if (currenths[3]==four[]){currenths[] = {zero[],nine[],four[],zero[]};}
			else if (currenths[3]==five[]){currenths[] = {zero[],nine[],five[],zero[]};}
			else if (currenths[3]==six[]){currenths[] = {zero[],nine[],six[],zero[]};}
			else if (currenths[3]==seven[]){currenths[] = {zero[],nine[],seven[],zero[]};}
			else if (currenths[3]==eight[]){currenths[] = {zero[],nine[],eight[],zero[]};}
			else{currenths[]={zero[],nine[],nine[],zero[]};}
		}
	}
}
void horizontalpositionplus(){
	//range -320 to 320
	//increments of 10 ?
	if (currenthp[1] == four[] || currenthp[1] == five[] || currenthp[1] == six[] || currenthp[1] == seven[] || currenthp[1] == eight[] || currenthp[1] == nine[]){
		currenthp[] = currenthp[]; //prevents out of range calculations
	}
	else if (currenthp[0]==plussign[] && currenthp[1]==three[] && (currenthp[2] == three[] || currenthp[2] == two[] || currenthp[2] == four[] || currenthp[2] == five[] || currenthp[2] == six[] || currenthp[2] == seven[] || currenthp[2] == eight[] || currenthp[2] == nine[])){
		currenthp[] = currenthp[];//prevents out of range calculations for positive integers
	}
	else if (currenthp[0] == plussign[] && currenthp[1] == three[] && (currenthp[2]==two[] || (currenthp[2]==one[] && currenthp[3] != zero[]))){
		currenthp[] = currenthp[];//prevents out of range calculations for positive integers
	}
	else if (currenthp[0] == minussign[] ){
		//addition for negative numbers
		if (currethp[1]==three[]){
			if (currenthp[2]==zero[]){currenthp[]={minussign[],two[],nine[],zero[]};}
			else if (currenthp[2]==one[]){currenthp[]={minussign[],three[],zero[],zero[]};}
			else if (currenthp[2]==two[]){currenthp[]={minussign[],three[],one[],zero[]};}
			else {currenthp[]=currenthp[];}
		}
		else if (currenthp[1]==two[]){
			if (currenthp[2]==zero[]){currenthp[]={minussign[],one[],nine[],zero[]};}
			else if (currenthp[2]==one[]){currenthp[]={minussign[],two[],zero[],zero[]};}
			else if (currenthp[2]==two[]){currenthp[]={minussign[],two[],one[],zero[]};}
			else if (currenthp[2]==three[]){currenthp[]={minussign[],two[],two[],zero[]};}
			else if (currenthp[2]==four[]){currenthp[]={minussign[],two[],three[],zero[]};}
			else if (currenthp[2]==five[]){currenthp[]={minussign[],two[],four[],zero[]};}
			else if (currenthp[2]==six[]){currenthp[]={minussign[],two[],five[],zero[]};}
			else if (currenthp[2]==seven[]){currenthp[]={minussign[],two[],six[],zero[]};}
			else if (currenthp[2]==eight[]){currenthp[]={minussign[],two[],seven[],zero[]};}
			else{currenthp[]={minussign[],two[],eight[],zero[]};}
		}
		else if (currenthp[1]=one[]){
			if (currenthp[2]==zero[]){currenthp[]={minussign[],zero[],nine[],zero[]};}
			else if (currenthp[2]==one[]){currenthp[]={minussign[],one[],zero[],zero[]};}
			else if (currenthp[2]==two[]){currenthp[]={minussign[],one[],one[],zero[]};}
			else if (currenthp[2]==three[]){currenthp[]={minussign[],one[],two[],zero[]};}
			else if (currenthp[2]==four[]){currenthp[]={minussign[],one[],three[],zero[]};}
			else if (currenthp[2]==five[]){currenthp[]={minussign[],one[],four[],zero[]};}
			else if (currenthp[2]==six[]){currenthp[]={minussign[],one[],five[],zero[]};}
			else if (currenthp[2]==seven[]){currenthp[]={minussign[],one[],six[],zero[]};}
			else if (currenthp[2]==eight[]){currenthp[]={minussign[],one[],seven[],zero[]};}
			else{currenthp[]={minussign[],one[],eight[],zero[]};}
		}
		else{//addition for -0xx
			if (currenthp[2]==one[]){currenthp[]={minussign[],zero[],zero[],zero[]};}
			else if (currenthp[2]==two[]){currenthp[]={minussign[],zero[],one[],zero[]};}
			else if (currenthp[2]==three[]){currenthp[]={minussign[],zero[],two[],zero[]};}
			else if (currenthp[2]==four[]){currenthp[]={minussign[],zero[],three[],zero[]};}
			else if (currenthp[2]==five[]){currenthp[]={minussign[],zero[],four[],zero[]};}
			else if (currenthp[2]==six[]){currenthp[]={minussign[],zero[],five[],zero[]};}
			else if (currenthp[2]==seven[]){currenthp[]={minussign[],zero[],six[],zero[]};}
			else if (currenthp[2]==eight[]){currenthp[]={minussign[],zero[],seven[],zero[]};}
			else if (currenthp[2]==nine){currenthp[]={minussign[],zero[],eight[],zero[]};}
			else {currenthp[]= {plussign[],zero[],zero[],zero[]};}
		}
	}
	else if (currenthp[0] == plussign[]){
		//addition for positive numbers
		if (currethp[1]==three[]){ //addition for 3xx
			if (currenthp[2]==zero[]){currenthp[]={plussign[],three[],one[],zero[]};}
			else if (currenthp[2]==one[]){currenthp[]={plussign[],three[],two[],zero[]};}
			else {currenthp[]=currenthp[];}
		}
		else if (currenthp[1]==two[]){//addition for 2xx
			if (currenthp[2]==zero[]){currenthp[]={plussign[],two[],one[],zero[]};}
			else if (currenthp[2]==one[]){currenthp[]={plus[],two[],two[],zero[]};}
			else if (currenthp[2]==two[]){currenthp[]={plussign[],two[],three[],zero[]};}
			else if (currenthp[2]==three[]){currenthp[]={plussign[],two[],four[],zero[]};}
			else if (currenthp[2]==four[]){currenthp[]={plussign[],two[],five[],zero[]};}
			else if (currenthp[2]==five[]){currenthp[]={plussign[],two[],six[],zero[]};}
			else if (currenthp[2]==six[]){currenthp[]={plussign[],two[],seven[],zero[]};}
			else if (currenthp[2]==seven[]){currenthp[]={plussign[],two[],eight[],zero[]};}
			else if (currenthp[2]==eight[]){currenthp[]={plussign[],two[],nine[],zero[]};}
			else{currenthp[]={plussign[],three[],zero[],zero[]};}
		}
		else if (currenthp[1]=one[]){//addition for 1xx
			if (currenthp[2]==zero[]){currenthp[]={plussign[],one[],one[],zero[]};}
			else if (currenthp[2]==one[]){currenthp[]={plus[],one[],two[],zero[]};}
			else if (currenthp[2]==two[]){currenthp[]={plussign[],one[],three[],zero[]};}
			else if (currenthp[2]==three[]){currenthp[]={plussign[],one[],four[],zero[]};}
			else if (currenthp[2]==four[]){currenthp[]={plussign[],one[],five[],zero[]};}
			else if (currenthp[2]==five[]){currenthp[]={plussign[],one[],six[],zero[]};}
			else if (currenthp[2]==six[]){currenthp[]={plussign[],one[],seven[],zero[]};}
			else if (currenthp[2]==seven[]){currenthp[]={plussign[],one[],eight[],zero[]};}
			else if (currenthp[2]==eight[]){currenthp[]={plussign[],one[],nine[],zero[]};}
			else{currenthp[]={plussign[],two[],zero[],zero[]};}
		}
		else{//addition for 0xx
			if (currenthp[2]==zero[]){currenthp[]={plussign[],zero[],one[],zero[]};}
			else if (currenthp[2]==one[]){currenthp[]={plus[],zero[],two[],zero[]};}
			else if (currenthp[2]==two[]){currenthp[]={plussign[],zero[],three[],zero[]};}
			else if (currenthp[2]==three[]){currenthp[]={plussign[],zero[],four[],zero[]};}
			else if (currenthp[2]==four[]){currenthp[]={plussign[],zero[],five[],zero[]};}
			else if (currenthp[2]==five[]){currenthp[]={plussign[],zero[],six[],zero[]};}
			else if (currenthp[2]==six[]){currenthp[]={plussign[],zero[],seven[],zero[]};}
			else if (currenthp[2]==seven[]){currenthp[]={plussign[],zero[],eight[],zero[]};}
			else if (currenthp[2]==eight[]){currenthp[]={plussign[],zero[],nine[],zero[]};}
			else{currenthp[]={plussign[],one[],zero[],zero[]};}
		}
	}
	else{
		currenthp[] = currenthp[];//should not be used ever, but is here as a fallback
	}
}
void horizontalsweepplus(){
	if (currenths[0] == one[] || (currenths[0] == zero[] && currenths[1] == nine[] && currenths[2] == nine[] && (currenths[3] == one[] || currenths[3] == two[] || currenths[3] ==  three[] || currenths[3] == four[] || currenths[3] ==  five[] || urrenths[3] ==  six[] || currenths[3] == seven[] || currenths[3] == eight[] || currenths[3] == nine[]))){
		//default addition by 10
		currenths[] = currenths[];//prevents addition past 1000
	}
}
void verticalpositionplus(){

}
void verticalsweepplus(){

}
void triggerslopeplus(){
	if (currentts[0]== minussign[]){
		currentts[0] = plussign[];
	}
	else{
		currentts[0] = plussign[];
	}
}
void triggervoltageplus(){

}
void horizontalpositionminus(){

}
void horiontalsweepminus(){

}
void verticalpositionminus(){
	if (currenthp[1] == four[] || currenthp[1] == five[] || currenthp[1] == six[] || currenthp[1] == seven[] || currenthp[1] == eight[] || currenthp[1] == nine[]){
		currenthp[] = currenthp[]; //prevents out of range calculations
	}
	else if (currenthp[0]==minussign[] && currenthp[1]==three[] && (currenthp[2] == three[] || currenthp[2] == two[] || currenthp[2] == four[] || currenthp[2] == five[] || currenthp[2] == six[] || currenthp[2] == seven[] || currenthp[2] == eight[] || currenthp[2] == nine[])){
		currenthp[] = currenthp[];//prevents out of range calculations for negative integers
	}
	
	else{
		currenthp[] = currenthp[];//should never be reached, is here as fallback, might be deleted completely
	}
}
void verticalsweepminus(){

}
void triggerslopeminus(){
	if (currentts[0] == plussign[]){
		currentts[0] = minussign[];
	}
	else{
		currentts[0] = minussign[];
	}
}
void triggervoltageminus(){

}

int bytesmouse; //bytes read from mouse

int main(){
	//screen starts at 0,0 on upper left
	int 1sx = //button x start, not yet decided
	int 1ex = 1sx + 8;//button x end
	int 2sx = 1ex + 8;
	int 2ex = 2sx + 8;
	int 3sx = 2ex + 8;
	int 3ex = 3sx + 8;
	int 4sx = 3ex + 8;
	int 4ex = 4sx + 8;
	int 1sy = //button y start, not yet decided
	int 1ey = 1sy + 8; //button y end
	int 2sy = 1ey + 8;
	int 2ey = 2sy + 8;
	int 3sy = 2ey + 24;
	int 3ey = 3sy + 8;
	int 4sy = 3ey + 8;
	int 4ey = 4sy + 8;
	int 5sy = 4ey + 24;
	int 5ey = 5sy + 8;
	int 6sy = 5ey + 8;
	int 6ey = 6sy + 8;

	/* --------get mouse position and button start---- */
	struct mouse_info mouse0;
	init_mouse();
	/* --------get mouse position and button END---- */

	while (1){
		read_mouse(&mouse0); //info sent from rex in a buffer
		printf("position of x, y are: %d %d; left click is %d\n",mouse0.x,mouse0.y,mouse0.button);

	if (mouse0.button == 1){
	//values from mouse - position
	int inputx = mouse0.x;
	int inputy = mouse0.y;
	//value might not be needed if rex sends click info directly instead of having me check
	int inputclick = mouse0.button; // mouse0.button/click is 0, 1, or 2. left click is 1
	if (inputclick==1){
	switch (inputx){
    	case 1sx … 1ex:
    	    switch (inputy){
    	    	//case 1sy...1ey does not exist
                case 2sy … 2ey:
				//button for multiplying horizontal position sweep
					(horizontalsweepmultiply);
				//all other cases do not exist
                default:
                	continue
                //internal switch 1 ends
            	}
		case 2sx … 2ex:
    	    switch (inputy){
                case 1sy … 1ey:
					(horizontalpositionplus);
                case 2sy … 2ey:
                	(horizontalsweepplus);
                case 3sy ... 3ey:
                	(verticalpositionplus);
                case 4sy ... 4ey:
                	(verticalsweepplus);
                case 5sy ... 5ey:
                	(triggerslopeplus);
                case 6sy ... 6ey:
					(triggervoltageplus);
                default:
                	continue;
                //internal switch 2 ends
                }
		case 3sx … 3ex:
    	    switch (inputy){
                case 1sy … 1ey:
					(horizontalpositionminus);
                case 2sy … 2ey:
                	(horiontalsweepminus);
                case 3sy ... 3ey:
                	(verticalpositionminus);
                case 4sy ... 4ey:
                	(verticalsweepminus);
                case 5sy ... 5ey:
                	(triggerslopeminus);
                case 6sy ... 6ey:
                	(triggervoltageminus);
                default:
                	continue;
                //internal switch 3 ends
                }
    	case 4sx … 4ex:
    	    switch (inputy){
    	    	//case 1sy...1ey does not exist
                case 2sy … 2ey:
				//button for multiplying horizontal position sweep
					(horizontalsweepdivide);
				//all other cases do not exist
                default:
                	continue;
                //internal switch 4 ends
            	}
    	default:
    		continue;
    //external switch ends
	}
	//if click ends/ not clicked
	}
	else{
		continue;
	}
	//if bytesmouse ends
	}
	else{
		printf("There is no data coming from the mouse. \n");
		break;
	}
	//infinite while ends
	}
//main ends
}
//letters and symbols are static
//numbers change, so they should be in a separate thing for addition

