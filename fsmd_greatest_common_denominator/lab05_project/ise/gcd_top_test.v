`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:41:06 02/10/2015
// Design Name:   GCD_TOP
// Module Name:   C:/Users/c4u06/Downloads/csd_lab3/Automagically_GCD/gcd_top_test.v
// Project Name:  Automagically_GCD
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: GCD_TOP
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module gcd_top_test;

	// Inputs
	reg [0:0] start;
	reg [3:0] x_in;
	reg [3:0] y_in;
	reg [0:0] reset;
	reg [0:0] clk;

	// Outputs
	wire [3:0] gcd_out;
	wire [0:0] gcd_done;

	// Instantiate the Unit Under Test (UUT)
	GCD_TOP uut (
		.start(start), 
		.x_in(x_in), 
		.y_in(y_in), 
		.reset(reset), 
		.gcd_out(gcd_out), 
		.gcd_done(gcd_done), 
		.clk(clk)
	);

	always begin
		clk = ~clk;
		#5;
	end

	initial begin
		// Initialize Inputs
		start = 0;
		x_in = 0;
		y_in = 0;
		reset = 1;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
		reset = 0;
		
		x_in = 14;
		y_in = 6;
		#10;
		start = 1;
		#10;
		start = 0;
		#60;
		
		
		
        
		// Add stimulus here

	end
      
endmodule

