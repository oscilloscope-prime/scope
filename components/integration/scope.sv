/*
 * Avalon memory-mapped peripheral that generates VGA & ADC interface
 *
 * Oscilloscope Project
 */


module scope(	input logic        	clk,
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

	logic    ADC_DoSth;
	
	logic	[3:0] disp0, disp1, disp2, disp3, disp4, disp5;

	logic [8:0] sample;
	assign sample [8:0] = ADC_REG[11:3];

	logic valid; 
	assign valid = 1;

	logic full;
	logic [11:0] trig;
	logic rising; 


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


logic first = 1'b1;

logic [9:0] a_display;
logic [9:0] a_input = 10'b0;
logic [15:0] dout_display;
logic [15:0] din_input;
logic  we_input;
assign we_input = valid;
assign din_input = sample;



memory m1(clk, a1, din1, we1, dout1),
       m2(clk, a2, din2, we2, dout2);

vga_counters counters(.clk50(clk), .*);

always_comb begin

  if (first) begin
    a1 = a_display;
    a2 = a_input;
    din2 = din_input;
    dout_display = dout1;
    we1 = 1'b0;
    we2 = we_input;
  end else begin
    a1 = a_input;
    a2 = a_display;
    din2 =  dout1;
    dout_display =din_input;
    we1 = we_input;
    we2 =  1'b0;
  end
  end


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


     end else if (chipselect && write) begin
	
       case (address)


         3'h0 : posX <= writedata;
         3'h1 : posY <= writedata;
	 

		
	 //3'h0 : din_input<= writedata[10:0];
		
	 //3'h1 : posY <= writedata[10:0];	
	


       endcase
	end   
	



   always_comb begin
	a_display = hcount[10:1];
      {VGA_R, VGA_G, VGA_B} = {8'h0, 8'h0, 8'h0};
      if (VGA_BLANK_n )begin
	if (dout_display[9:0] == vcount[9:0])
		{VGA_R, VGA_G, VGA_B} = {8'h00, 8'h00, 8'hff};

	else if(vcount[9:0] == 150 )
		{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'h00};

	else if ( (hcount[10:0]%30 == 0 || vcount[9:0]%15 == 0 ) && (vcount[9:0]<301) )
   		{VGA_R, VGA_G, VGA_B} = {8'hff, 8'hff, 8'hff};
	

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
	
	fromADC data4mADC(.mclk(clk), .ds(ADC_DoSth), .cs(ADC_CS_N), .dout(ADC_DOUT), .out(ADC_REG));

	bin2dec b2d(.bin_data(ADC_REG), .dec0(disp0), .dec1(disp1), .dec2(disp2), .dec3(disp3), .dec4(disp4), .dec5(disp5));
	
	hex7seg h0(.in(disp0), .out(HEX0));
	hex7seg h1(.in(disp1), .out(HEX1));
	hex7seg h2(.in(disp2), .out(HEX2));
	hex7seg h3(.in(disp3), .out(HEX3));
	hex7seg h4(.in(disp4), .out(HEX4));
	hex7seg h5(.in(disp5), .out(HEX5));


/* ================================================================================Tvisha's stuff=========================================================================================== */	

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
module fromADC (mclk, ds, cs, dout, out);

	input logic mclk, ds, cs, dout; 
	output logic [11:0] out;
	logic [5:0] counter = 6'd 0;

	logic [11:0] shiftreg;

	logic load_data = 1'd 1; //check this if we have issues displaying	
	
	always_ff @ ( posedge mclk )
	begin

		if (!cs && ds && counter <= 6'd 11)
		begin
			shiftreg = {shiftreg[10:0], dout};
			counter <= counter + 6'd 1;
			load_data <= 1'd 1;
		end

		else if(cs && !ds && load_data)
		begin
			//counter = 6'd 0; 
			//out <= shiftreg;
			out[11:0] <= shiftreg[11:0];
			counter = 6'd 0;
			load_data <= 1'd 0;
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







/* ================================================================================Tvisha's Modules========================================================================================= */	


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

