/*
 * Avalon memory-mapped peripheral that generates VGA & ADC interface
 *
 * Oscilloscope Project
 */


module vga_ball(	input logic        	clk,
                input logic 	   	reset,
                input logic [15:0]  writedata,
                input logic 	   	write,
                input 		   		chipselect,
                input logic [2:0]  	address,

				//VGA logic
                output logic [7:0] 	VGA_R, VGA_G, VGA_B,
                output logic 	   	VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n,
                output logic 	   	VGA_SYNC_n,

				//ADC logic
				output logic		ADC_CS_N,
				output logic 		ADC_SCLK,
				output logic 		ADC_DIN, 
				input logic			ADC_DOUT,
				
				output logic [6:0] 	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
			);

	logic [11:0] ADC_REG; 
	logic [11:0] PREV_ADC_REG; 

	logic    ADC_DoSth;
	
	logic	[3:0] disp0, disp1, disp2, disp3, disp4, disp5;

	logic [8:0] sample;
	assign sample [8:0] = ADC_REG[11:3];

	logic ready;
	logic valid; 
	//assign valid = 1;

	logic full;

	logic [11:0] trig;
	//assign trig = 12'd 2; //trigger looks for 2V

	logic rising;
	assign rising = 1'b 1; //for rising edge. toggle to 0 for falling 


/* ================================================================================vga stuff=========================================================================================== */	

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

/* ======================================================================== ADDING MOUSE ===================================================================== */

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

/* ======================================================================== ADDING MOUSE ===================================================================== */

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

vga_counters counters(.clk50(clk), .*);

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


  always_ff @(posedge clk)
	begin
	if (reset)begin 
	full  <= 1'b0; //changed to 0
	a_input = 10'b0;
	first = 1'b1;
	end
	if (valid)begin
		if(!full)
		begin
		full <= 1'b0;
		end
		if(a_input == 10'd639) begin
			a_input <= 10'b0;
			full <= 1'b1;
			first<= ~ first;
		end
		else begin
			a_input <=  a_input + 10'b1;	
			full <= full;
		end	
	end 
	else if (!valid) begin
		full <= full;
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


     end else if (chipselect && write) begin
	
       case (address)


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

/* ================================================================================vga stuff=========================================================================================== */	

	clockdiv cd(.clk(clk), .en(ADC_SCLK));
	
	dosomething ds(.clk(clk), .en(ADC_DoSth));
	
	chipselect cs(.mclk(clk), .ds(ADC_DoSth), .csn(ADC_CS_N));
	
	toADC data2ADC(.mclk(clk), .ds(ADC_DoSth), .cs(ADC_CS_N), .din(ADC_DIN));
	
	fromADC data4mADC(.mclk(clk), .ds(ADC_DoSth), .cs(ADC_CS_N), .dout(ADC_DOUT), .out(ADC_REG), .ready(ready), .ADC_REG_PREV(ADC_REG_PREV));
	
	sendData send2vga(.mclk(clk), .*);

	bin2dec b2d(.bin_data(ADC_REG), .dec0(disp0), .dec1(disp1), .dec2(disp2), .dec3(disp3), .dec4(disp4), .dec5(disp5));
	
	hex7seg h0(.in(disp0), .out(HEX0));
	hex7seg h1(.in(disp1), .out(HEX1));
	hex7seg h2(.in(disp2), .out(HEX2));
	hex7seg h3(.in(disp3), .out(HEX3));
	hex7seg h4(.in(disp4), .out(HEX4));
	hex7seg h5(.in(disp5), .out(HEX5));


/* ================================================================================vga stuff=========================================================================================== */	

endmodule

module clockdiv(input logic clk, output logic en);

   parameter clockDivisor = 4'd 4 ;
   //register stores the value of clock cycles
   logic [3:0] i = 4'd 0; 

   always_ff @( posedge clk )  
   begin

     i <= i + 4'd 1;
     //resetting the clock
     if ( i >= (clockDivisor-1)) 
     begin  
      	i <= 4'd 0;
     end

   end

   assign en = (i<clockDivisor/2)?1'b0:1'b1;

endmodule


module dosomething(input logic clk, output logic en);

	logic [3:0] counter = 4'd 0; 
	logic up_down = 1'd 0;

	always_ff @( posedge clk )
	begin

		if(counter == 4'd 0 && up_down == 1'd 0)
		begin
			up_down <= 1'd 1;
			counter <= counter + 4'd 1;
		end
		else if(counter == 4'd 1 && up_down == 1'd 1)
		begin
			up_down <= 1'd 0;
			counter <= counter + 4'd 1;
		end
		else if (counter == 4'd 2 && up_down == 1'd 0)
		begin
			counter <= counter + 4'd 1;
		end
		else
		begin
			counter <= 4'd 0;
		end

	end

	assign en = up_down;

endmodule


module chipselect(input logic mclk, input logic ds, output logic csn);

	logic [5:0] counter_down = 6'd 0; //counter(we need 12 cycles of low, 1 cycle of high)
	logic [5:0] counter_up = 6'd 0;
	logic chipselect = 1'd 1; //to control the value of chipselect
	logic hold1, hold2, hold3; //to introduce a cycle of delay on chipselect
	
	
	always_ff @ ( posedge mclk )
	begin

		if(ds && counter_up <= 6'd 20 && counter_down == 6'd 0)
		begin
			chipselect <= 1'd 1;
			counter_up <= counter_up + 6'd 1;
		end
		
		else if(ds && counter_up == 6'd 21 && counter_down == 6'd 0)
		begin
			chipselect <= 1'd 0;
			counter_down <= counter_down + 6'd 1;
			counter_up <= 6'd 0;
		end

		else if(ds && counter_up == 6'd 0 && counter_down <= 6'd 12)
		begin
			chipselect <= 1'd 0;
			counter_down <= counter_down + 6'd 1;
		end

		else if(chipselect == 1'd 0 && counter_down == 6'd 13)
		begin
			counter_down <= 6'd 0;
			counter_up <= 6'd 0;
			chipselect <= 1'd 1;
		end	
		hold1 <= chipselect;
		hold2 <= hold1;
		hold3 <= hold2;
		
	end

	assign csn = hold3;

endmodule


//controls the D_in signal
module toADC (input logic mclk, input logic ds, input logic cs, output logic din);
//make a shift register to send data to ADC

	logic [5:0] shiftreg = 6'b 100010; //initialize shift reg to 0s
	logic [5:0] counter = 6'd 0;
	
	always_ff @ ( posedge mclk ) 
	begin

		if (!cs && ds && counter < 6'd 6 )
		begin
			din <= shiftreg[5];
			shiftreg [5:1] <= shiftreg[4:0];
			shiftreg [0] <= 1'd 0;
			counter <= counter + 6'd 1;
		end

		else if(counter == 6'd 6 && !ds && cs)
		begin
			din <= din;
			shiftreg <= 6'b 100010;
			counter <= 6'd 0;
		end
		
		else
			din <= din;

	end

endmodule

//controls the D_out signal
module fromADC (mclk, ds, cs, dout, ready, out, ADC_REG_PREV);

	input logic mclk, ds, cs, dout; 
	output logic [11:0] out;
	output logic [11:0] ADC_REG_PREV;
	output logic ready;
	logic [5:0] counter = 6'd 0;

	logic [11:0] shiftreg = 12'd 0;

	logic load_data = 1'd 1; //check this if we have issues displaying	
	
	always_ff @ ( posedge mclk )
	begin

		if (counter == 6'd 0)
			ADC_REG_PREV[11:0] <= shiftreg[11:0];
		if (!cs && ds && counter <= 6'd 11)
		begin
			shiftreg = {shiftreg[10:0], dout};
			counter <= counter + 6'd 1;
			load_data <= 1'd 1;
			ready <= 1'd 0;
			ADC_REG_PREV[11:0] <= ADC_REG_PREV[11:0];
		end

		else if(cs && !ds && load_data)
		begin
			//counter = 6'd 0; 
			//out <= shiftreg;
			out[11:0] <= shiftreg[11:0];
			counter = 6'd 0;
			load_data <= 1'd 0;
			ready <= 1'd 1;
		end
		
	end 

endmodule 

module sendData (input logic mclk, input logic ready, input logic [11:0] trig, input logic full, output logic valid, input logic [11:0] ADC_REG, input logic [11:0] PREV_ADC_REG);

	always_ff @ ( posedge mclk )
	begin

		if(full && (ADC_REG > trig) && (PREV_ADC_REG < ADC_REG) ) //changed from trig to ADC_REG
			valid <= 1'd 1;
		else
		begin
			if(ready && !full)
				valid <= 1'd 1;
			else if(ready && full)
				valid <= 1'd 0;
			else
				valid <= 1'd 0;
		end
	
	end
endmodule

module hex7seg (input logic [3:0] in, output logic [0:7] out);

	logic [6:0] pre_seg_dis;
	always @ (*)
	begin

		case(in)
		
			4'h1: pre_seg_dis = 7'b1111001;		
			4'h2: pre_seg_dis = 7'b0100100;		
			4'h3: pre_seg_dis = 7'b0110000;		
			4'h4: pre_seg_dis = 7'b0011001;		
			4'h5: pre_seg_dis = 7'b0010010;		
			4'h6: pre_seg_dis = 7'b0000010;		
			4'h7: pre_seg_dis = 7'b1111000;		
			4'h8: pre_seg_dis = 7'b0000000;		
			4'h9: pre_seg_dis = 7'b0011000;		
			4'ha: pre_seg_dis = 7'b0001000;
			4'hb: pre_seg_dis = 7'b0000011;		
			4'hc: pre_seg_dis = 7'b1000110;		
			4'hd: pre_seg_dis = 7'b0100001;		
			4'he: pre_seg_dis = 7'b0000110;		
			4'hf: pre_seg_dis = 7'b0001110;		
			4'h0: pre_seg_dis = 7'b1000000;				
		
		endcase

	end
	
	assign out = pre_seg_dis;

endmodule


module bin2dec (input logic [11:0] bin_data, output logic [3:0] dec0, output logic [3:0] dec1, output logic [3:0] dec2, output logic [3:0] dec3, output logic [3:0] dec4, output logic [3:0] dec5);

	always @ (*)
	begin
	dec0 = (bin_data*409600/4096 ) %10;
	dec1 = (bin_data*409600/4096 /10) %10;
	dec2 = (bin_data*409600/4096 /100) %10;
	dec3 = (bin_data*409600/4096 /1000) %10;
	dec4 = (bin_data*409600/4096 /10000) %10;
	dec5 = (bin_data*409600/4096 /100000) %10;
	end

endmodule







/* ================================================================================VGA Modules========================================================================================= */	


module vga_counters(
 input logic 	     clk50, reset,
 output logic [10:0] hcount,  // hcount[10:1] is pixel column
 output logic [9:0]  vcount,  // vcount[9:0] is pixel row
 output logic 	     VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n, VGA_SYNC_n);


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

   		mem[j] = 16'd180;
	//end

end

   always_ff @(posedge clk) begin
      if (we) mem[a] <= din;
      dout <= mem[a];
   end
        
endmodule
