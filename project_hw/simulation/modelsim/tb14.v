`timescale 1 ns / 100 ps

module tb14();

//input to DUT

	reg clk;
	reg ADC_DOUT;

//out from DUT
	
	//wire ADC_DoSth;
	wire ADC_CS_N;
	wire ADC_SCLK;
	wire ADC_DIN;
	//wire [15:0]  ADC_REG;
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	

//instantiate the DUT
	
	vga_ball Test1 (
		.clk(clk),
		//.ADC_DoSth(ADC_DoSth),
		.ADC_CS_N(ADC_CS_N),
		.ADC_SCLK(ADC_SCLK),
		.ADC_DIN(ADC_DIN),
		.ADC_DOUT(ADC_DOUT),
		//.ADC_REG(ADC_REG),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5)
	);

//create 50MHz clock and DOUT
always
	#10 clk = ~clk;
always
	#80 ADC_DOUT = ~ADC_DOUT;

//initial block
initial
begin

	$display($time, " << Starting Simulation >> ");	
	clk = 1'b 0;
	ADC_DOUT = 1'b 0;

	#600000;
	$display($time, "<< Simulation Complete >>");
	$stop;	

end

endmodule



