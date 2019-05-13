/*
 * Avalon memory-mapped peripheral that generates VGA
 *
 * Stephen A. Edwards
 * Columbia University
 */

module vga_ball(input logic        clk,
	        input logic 	   reset,
		input logic [15:0]  writedata,
		input logic 	   write,
		input 		   chipselect,
		input logic [2:0]  address,

		output logic [7:0] VGA_R, VGA_G, VGA_B,
		output logic 	   VGA_CLK, VGA_HS, VGA_VS,
		                   VGA_BLANK_n,
		output logic 	   VGA_SYNC_n,

		input   logic [8:0] sample,
		input  logic 	    valid, //ish took out the [1:0], only need 1 bit for this
		output logic 	    full, //ish took out the [1:0], only need 1 bit for this
		output logic [11:0] trig,
		output logic 	    rising //ish took out the [1:0], only need 1 bit for this;
		);

   logic [10:0]	   hcount;
   logic [9:0]     vcount;

   logic [7:0] 	   background_r, background_g, background_b;
   logic [10:0]     posX;
   logic [9:0]      posY;	
   logic [10:0]     dummy; 

   logic [1:0] flag;  
   logic [1:0] flag2;



//some variables for memory 

	      /*input logic        clk,*/
	      logic [9:0]  a1;
	      logic [15:0]  din1;
	      logic we1;
	      logic [15:0] dout1;

 	      logic [9:0]  a2;
	      logic [15:0]  din2;
	      logic we2;
	      logic [15:0] dout2;

		logic [7:0] shape;
		logic [2:0] a_m;

		logic [15:0] shape_p;
		logic [3:0] a_p;

		logic [15:0] shape_mi;
		logic [3:0] a_mi;
		
		logic [15:0] shape_t;
		logic [3:0] a_t;

		logic [15:0] shape_r;
		logic [3:0] a_r;

		logic [15:0] shape_p1;
		logic [3:0] a_p1;

		logic [15:0] shape_mi1;
		logic [3:0] a_mi1;
mouse mouse(.*);

plus p(.*), p1(clk, shape_p1,a_p1);
minus m(.*), mi1(clk, shape_mi1,a_mi1);
T t(.*);
R r(.*);

//plus p1(shape_p1,a_p1);
//minus mi1(shape_mi1,a_mi1);
//initializing the buffers
  //buffer 1
//memory m1(clk,a,din,we,dout);

// buffer 2 
   //memory m2( .* );

logic first = 1'b1;

logic [9:0] a_display;
logic [9:0] a_input = 10'b0;
logic [15:0] dout_display;
logic [15:0] din_input;
logic  we_input;
assign we_input = valid;
assign din_input = sample;
assign din1 = din_input;
assign din2 = din_input;


memory m1(clk, a1, din1, we1, dout1),
       m2(clk, a2, din2, we2, dout2);

always_comb begin


  if (first) begin
    a1 = a_display;
    a2 = a_input;
    //din2 = din_input;
    dout_display = dout1;
    we1 = 1'b0;
    we2 = we_input;
  end else begin
    a1 = a_input;
    a2 = a_display;
    //din1 =  din_input;
    dout_display =dout2;
    we1 = we_input;
    we2 =  1'b0;
  end
  end


/*
assign a1 = first ? a_display : 12'b0;
assign din1 = first ? 16'b0 : 16'b0;
assign we1 = first ? 1'b0 : we_input;

assign dout_display = first ? dout1 : dout2;*/

vga_counters counters(.clk50(clk), .*);

//initializing the buffers
  //buffer 1
//memory m1(clk,a,din,we,dout);
//memory m1(.*);
  always_ff @(posedge clk)
	begin
	if (reset)begin 
	full  <= 1'b1;
	a_input = 10'b0;
	first = 1'b1;
	end
		if (valid)begin
			if(full)begin
			full <= 1'b0;
			end
			if(a_input == 10'd639) begin
				a_input <= 10'b0;
				full <= 1'b1;
				first<= ~ first;
			
			end
			else begin
				a_input <=  a_input + 10'b1;	
			end	

		end 
	end


   always_ff @(posedge clk)
     if (reset) begin
	background_r <= 8'h0;
	background_g <= 8'h0;
	background_b <= 8'h80;
	
	posX <= 8'd50;
	posY <= 8'd50;
	flag <= 1'd0;
	flag2 <= 1'd0;
	dummy <= hcount;

	//we_input<=0;
	//posX <= dout_display;
	//first <=0;
	
     end else if (chipselect && write) begin
	
       case (address)


// this part is irrelevant cause nothing is coming from software?
	
	 //3'h0 : background_r <= writedata;
	 //3'h1 : background_g <= writedata;
	 //3'h2 : background_b <= writedata;
         3'h0 : posX <= writedata;
         3'h1 : posY <= writedata;
 	 3'h2 : rising <= writedata;
         3'h3 : trig <= writedata;
	 

		
	 //3'h0 : din_input<= writedata[10:0];
		
	 //3'h1 : posY <= writedata[10:0];	
	


       endcase
	end   
	

assign a_m  = vcount - posY;
assign a_p  = vcount - 350;
assign a_mi  = vcount - 350;
assign a_t  = vcount - 325;
assign a_r  = vcount - 400;

assign a_p1  = vcount - 425;
assign a_mi1  = vcount - 425;
   always_comb begin
	a_display = hcount[10:1];
      {VGA_R, VGA_G, VGA_B} = {8'h0, 8'h0, 8'h0};
      if (VGA_BLANK_n )begin
	//if( (hcount[10:0]< posX+30) && (hcount[10:0] > posX-30) && (vcount[9:0]>posY-15) && (vcount[9:0] < posY + 15) )
	//if (((hcount[10:0] - posX)*(hcount[10:0]- posX)) + (4*(vcount[9:0]- posY)*(vcount[9:0]- posY)) < 900)
	//if ( (vcount[9:0] == posY) &&( (hcount[10:0]< posX+30) && (hcount[10:0] > posX-30) ) )
	if( ((hcount[10:1]< posX+8) && (hcount[10:1] >= posX) && (vcount[9:0]>=posY) && (vcount[9:0] < posY + 8) ) && (shape[hcount[10:1] - posX]))
		//if (shape[hcount[10:1] - posX])
		{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff};
	else if( ((hcount[10:1]< 550+16) && (hcount[10:1] >= 550) && (vcount[9:0]>=350) && (vcount[9:0] < 350 + 16) ) && (shape_p[hcount[10:1] - 550]))
		//if (shape[hcount[10:1] - posX])
		{VGA_R, VGA_G, VGA_B} = {8'h00, 8'hff, 8'h00};

	else if( ((hcount[10:1]< 500+16) && (hcount[10:1] >= 500) && (vcount[9:0]>=350) && (vcount[9:0] < 350 + 16) ) && (shape_mi[hcount[10:1] - 500]))
		{VGA_R, VGA_G, VGA_B} = {8'h00, 8'hff, 8'h00};

	else if( ((hcount[10:1]< 450+16) && (hcount[10:1] >= 450) && (vcount[9:0]>=325) && (vcount[9:0] < 325 + 16) ) && (shape_t[hcount[10:1] - 450]))
		{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff};


	else if( ((hcount[10:1]< 450+16) && (hcount[10:1] >= 450) && (vcount[9:0]>=400) && (vcount[9:0] < 400 + 16) ) && (shape_r[hcount[10:1] - 450]))
		{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff};
	
	else if( ((hcount[10:1]< 550+16) && (hcount[10:1] >= 550) && (vcount[9:0]>=425) && (vcount[9:0] < 425 + 16) ) && (shape_p1[hcount[10:1] - 550]))
		//if (shape[hcount[10:1] - posX])
		{VGA_R, VGA_G, VGA_B} = {8'h00, 8'hff, 8'h00};

	else if( ((hcount[10:1]< 500+16) && (hcount[10:1] >= 500) && (vcount[9:0]>=425) && (vcount[9:0] < 425 + 16) ) && (shape_mi1[hcount[10:1] - 500]))
		{VGA_R, VGA_G, VGA_B} = {8'h00, 8'hff, 8'h00};
	//else if ( (hcount[10:1]< 550+15) && (hcount[10:1] > 550-15) && (vcount[9:0]>350-15) && (vcount[9:0] < 350 + 15) )
		//{VGA_R, VGA_G, VGA_B} = {8'h00, 8'hff, 8'h00};
	//else if ( (hcount[10:1]< 500+15) && (hcount[10:1] > 500-15) && (vcount[9:0]>350-15) && (vcount[9:0] < 350 + 15) )
		//{VGA_R, VGA_G, VGA_B} = {8'h00, 8'hff, 8'h00};






	else if (dout_display[9:0] == vcount[9:0])
		{VGA_R, VGA_G, VGA_B} = {8'h00, 8'h00, 8'hff};

	else if(vcount[9:0] == 150 )
		{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'h00};

	else if ( (hcount[10:0]%30 == 0 || vcount[9:0]%15 == 0 ) && (vcount[9:0]<301) )
   		{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff};

	//else if (dout[9:0] == vcount[9:0])
		//{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff};

/*
	if (hcount[10:6] == 5'd3   &&
	    vcount[9:0]== 10'd1023)
	  {VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff};*/
	

	else
	  {VGA_R, VGA_G, VGA_B} =
             //{background_r, background_g, background_b};
		{ 8'hff, 8'h00, 8'hff };
	end
       
   end
	       
endmodule
//v Line: 72

module vga_counters(
 input logic 	     clk50, reset,
 output logic [10:0] hcount,  // hcount[10:1] is pixel column
 output logic [9:0]  vcount,  // vcount[9:0] is pixel row
 output logic 	     VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);

/*
 * 640 X 480 VGA timing for a 50 MHz clock: one pixel every other cycle
 * 
 * HCOUNT 1599 0             1279       1599 0
 *             _______________              ________
 * ___________|    Video      |____________|  Video
 * 
 * 
 * |SYNC| BP |<-- HACTIVE -->|FP|SYNC| BP |<-- HACTIVE
 *       _______________________      _____________
 * |____|       VGA_HS          |____|
 */
   // Parameters for hcount
   parameter HACTIVE      = 11'd 1280,
             HFRONT_PORCH = 11'd 32,
             HSYNC        = 11'd 192,
             HBACK_PORCH  = 11'd 96,   
             HTOTAL       = HACTIVE + HFRONT_PORCH + HSYNC +
                            HBACK_PORCH; // 1600
   
   // Parameters for vcount
   parameter VACTIVE      = 10'd 480,
             VFRONT_PORCH = 10'd 10,
             VSYNC        = 10'd 2,
             VBACK_PORCH  = 10'd 33,
             VTOTAL       = VACTIVE + VFRONT_PORCH + VSYNC +
                            VBACK_PORCH; // 525

   logic endOfLine;
   
   always_ff @(posedge clk50 or posedge reset)
     if (reset)          hcount <= 0;
     else if (endOfLine) hcount <= 0;
     else  	         hcount <= hcount + 11'd 1;

   assign endOfLine = hcount == HTOTAL - 1;
       
   logic endOfField;
   
   always_ff @(posedge clk50 or posedge reset)
     if (reset)          vcount <= 0;
     else if (endOfLine)
       if (endOfField)   vcount <= 0;
       else              vcount <= vcount + 10'd 1;

   assign endOfField = vcount == VTOTAL - 1;

   // Horizontal sync: from 0x520 to 0x5DF (0x57F)
   // 101 0010 0000 to 101 1101 1111
   assign VGA_HS = !( (hcount[10:8] == 3'b101) &
		      !(hcount[7:5] == 3'b111));
   assign VGA_VS = !( vcount[9:1] == (VACTIVE + VFRONT_PORCH) / 2);

   assign VGA_SYNC_n = 1'b0; // For putting sync on the green signal; unused
   
   // Horizontal active: 0 to 1279     Vertical active: 0 to 479
   // 101 0000 0000  1280	       01 1110 0000  480
   // 110 0011 1111  1599	       10 0000 1100  524
   assign VGA_BLANK_n = !( hcount[10] & (hcount[9] | hcount[8]) ) &
			!( vcount[9] | (vcount[8:5] == 4'b1111) );

   /* VGA_CLK is 25 MHz
    *             __    __    __
    * clk50    __|  |__|  |__|
    *        
    *             _____       __
    * hcount[0]__|     |_____|
    */
   assign VGA_CLK = hcount[0]; // 25 MHz clock: rising edge sensitive
   
endmodule

/*mse[0] = 1'b11111110;
mse[1] = 1'b11111100;
mse[2] = 1'b11111000;
mse[3] = 1'b11111000;
mse[4] = 1'b11111100;
mse[5] = 1'b11001110;
mse[6] = 1'b10000111;
mse[7] = 1'b00000011;*/

//MOUSE 
module mouse(input logic clk, output logic [7:0] shape, input logic [2:0] a_m);

logic [7:0]     mse[7:0];

initial begin
mse[0] = 8'b01111111;
mse[1] = 8'b00111111;
mse[2] = 8'b00011111;
mse[3] = 8'b00011111;
mse[4] = 8'b00111111;
mse[5] = 8'b01110011;
mse[6] = 8'b11100001;
mse[7] = 8'b11000000;
end

always_ff @(posedge clk) begin 
shape <= mse[a_m];
end
endmodule 



// + 
module plus(input logic clk, output logic [15:0] shape_p, input logic [3:0] a_p);

logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b0000000000000000;
mse[1] = 16'b0000000000000000;
mse[2] = 16'b0000001111000000;
mse[3] = 16'b0000001111000000;
mse[4] = 16'b0000001111000000;
mse[5] = 16'b0000001111000000;
mse[6] = 16'b0011111111111100;
mse[7] = 16'b0011111111111100;
mse[8] = 16'b0011111111111100;
mse[9] = 16'b0011111111111100;
mse[10] =16'b0000001111000000;
mse[11] =16'b0000001111000000;
mse[12] =16'b0000001111000000;
mse[13] =16'b0000001111000000;
mse[14] =16'b0000000000000000;
mse[15] =16'b0000000000000000;
end

always_ff @(posedge clk) begin 
shape_p <= mse[a_p];
end
endmodule 

// - 
module minus(input logic clk, output logic [15:0] shape_mi, input logic [3:0] a_mi);

logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b0000000000000000;
mse[1] = 16'b0000000000000000;
mse[2] = 16'b0000000000000000;
mse[3] = 16'b0000000000000000;
mse[4] = 16'b0000000000000000;
mse[5] = 16'b0000000000000000;
mse[6] = 16'b0011111111111100;
mse[7] = 16'b0011111111111100;
mse[8] = 16'b0011111111111100;
mse[9] = 16'b0011111111111100;
mse[10] =16'b0000000000000000;
mse[11] =16'b0000000000000000;
mse[12] =16'b0000000000000000;
mse[13] =16'b0000000000000000;
mse[14] =16'b0000000000000000;
mse[15] =16'b0000000000000000;
end

always_ff @(posedge clk) begin 
shape_mi <= mse[a_mi];
end
endmodule 

// T 
module T(input logic clk, output logic [15:0] shape_t, input logic [3:0] a_t);

logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b1111111111111111;
mse[1] = 16'b1111111111111111;
mse[2] = 16'b1111111111111111;
mse[3] = 16'b1111111111111111;
mse[4] = 16'b0000001111000000;
mse[5] = 16'b0000001111000000;
mse[6] = 16'b0000001111000000;
mse[7] = 16'b0000001111000000;
mse[8] = 16'b0000001111000000;
mse[9] = 16'b0000001111000000;
mse[10] =16'b0000001111000000;
mse[11] =16'b0000001111000000;
mse[12] =16'b0000001111000000;
mse[13] =16'b0000001111000000;
mse[14] =16'b0000001111000000;
mse[15] =16'b0000001111000000;
end

always_ff @(posedge clk) begin 
shape_t <= mse[a_t];
end
endmodule 

// R 
module R(input logic clk, output logic [15:0] shape_r, input logic [3:0] a_r);
//assign a_m  = vcount - posY;
logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b1111111111111111;
mse[1] = 16'b1111111111111111;
mse[2] = 16'b1111000000001111;
mse[3] = 16'b1111000000001111;
mse[4] = 16'b1111000000001111;
mse[5] = 16'b1111000000001111;
mse[6] = 16'b1111000000001111;
mse[7] = 16'b1111000000001111;
mse[8] = 16'b1111111111111111;
mse[9] = 16'b1111111111111111;
mse[10] =16'b0000000111101111;
mse[11] =16'b0000001111001111;
mse[12] =16'b0000011110001111;
mse[13] =16'b0000111100001111;
mse[14] =16'b0001111000001111;
mse[15] =16'b0011111000001111;
end

always_ff @(posedge clk) begin 
shape_r <= mse[a_r];
end
endmodule

// 0
module zero(input logic clk, output logic [15:0] shape_o, input logic [3:0] a_o);

logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b1111111111111111;
mse[1] = 16'b1111111111111111;
mse[2] = 16'b1111000000001111;
mse[3] = 16'b1111000000001111;
mse[4] = 16'b1111000000001111;
mse[5] = 16'b1111000000001111;
mse[6] = 16'b1111000000001111;
mse[7] = 16'b1111000000001111;
mse[8] = 16'b1111000000001111;
mse[9] = 16'b1111000000001111;
mse[10] =16'b1111000000001111;
mse[11] =16'b1111000000001111;
mse[12] =16'b1111000000001111;
mse[13] =16'b1111000000001111;
mse[14] =16'b1111111111111111;
mse[15] =16'b1111111111111111;
end

always_ff @(posedge clk) begin 
shape_o <= mse[a_o];
end
endmodule


// 1
module one(input logic clk, output logic [15:0] shape_one, input logic [3:0] a_one);

logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b1111111100000000;
mse[1] = 16'b1111011110000000;
mse[2] = 16'b1111001111000000;
mse[3] = 16'b1111000111100000;
mse[4] = 16'b1111000011110000;
mse[5] = 16'b1111000001111000;
mse[6] = 16'b1111000000000000;
mse[7] = 16'b1111000000000000;
mse[8] = 16'b1111000000000000;
mse[9] = 16'b1111000000000000;
mse[10] =16'b1111000000000000;
mse[11] =16'b1111000000000000;
mse[12] =16'b1111111111111111;
mse[13] =16'b1111111111111111;
mse[14] =16'b1111111111111111;
mse[15] =16'b1111111111111111;
end

always_ff @(posedge clk) begin 
shape_one <= mse[a_one];
end
endmodule


// 2
module two(input logic clk, output logic [15:0] shape_two, input logic [3:0] a_two);

logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b1111111100000000;
mse[1] = 16'b1111000111100000;
mse[2] = 16'b1111000001111000;
mse[3] = 16'b1111000000111100;
mse[4] = 16'b1111000000011110;
mse[5] = 16'b1111000000001111;
mse[6] = 16'b1111000000000000;
mse[7] = 16'b1111111111111111;
mse[8] = 16'b1111111111111111;
mse[9] = 16'b0000000000001111;
mse[10] =16'b0000000000001111;
mse[11] =16'b0000000000001111;
mse[12] =16'b1111111111111111;
mse[13] =16'b1111111111111111;
mse[14] =16'b1111111111111111;
mse[15] =16'b1111111111111111;
end

always_ff @(posedge clk) begin 
shape_two <= mse[a_two];
end
endmodule


// 3
module th(input logic clk, output logic [15:0] shape_th, input logic [3:0] a_th);

logic [15:0]     mse[15:0];

initial begin
mse[0] = 16'b1111111111111111;
mse[1] = 16'b1111111111111111;
mse[2] = 16'b1111111111111111;
mse[3] = 16'b1111000000000000;
mse[4] = 16'b1111000000000000;
mse[5] = 16'b1111000000000000;
mse[6] = 16'b1111000000000000;
mse[7] = 16'b1111111111111111;
mse[8] = 16'b1111111111111111;
mse[9] = 16'b1111111111111111;
mse[10] =16'b1111000000000000;
mse[11] =16'b1111000000000000;
mse[12] =16'b1111000000000000;
mse[13] =16'b1111111111111111;
mse[14] =16'b1111111111111111;
mse[15] =16'b1111111111111111;
end

always_ff @(posedge clk) begin 
shape_th <= mse[a_th];
end
endmodule





// 16 X 8 synchronous RAM with old data read-during-write behavior
module memory(input logic        clk,
	      input logic [9:0]  a,
	      input logic [15:0]  din,
	      input logic 	 we,
	      output logic [15:0] dout);

//we have 1280 pixels, so 1280 digits coming in each of 16 bits
   
   logic [15:0] 			 mem [639:0];
   integer j;
   integer flag;
   initial begin

   for(j = 0; j < 639; j = j+1) 
	/*if (j%30==0 && flag ==1) begin
		flag = 0;
	end
	else if(j%30==0 && flag ==0)begin
		flag = 1;
	end

	if(flag ==0)begin
   		mem[j] = 16'd120;
	end
	else if(flag ==1)begin*/
   		mem[j] = 16'd180;
	//end

end

   always_ff @(posedge clk) begin
      if (we) mem[a] <= din;
      dout <= mem[a];
   end
        
endmodule
