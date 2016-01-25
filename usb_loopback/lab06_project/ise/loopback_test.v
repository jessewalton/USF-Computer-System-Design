`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:33:07 02/19/2015
// Design Name:   loopback
// Module Name:   E:/CSD Lab/automagically/lab06/lab06/loopback_test.v
// Project Name:  lab06
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: loopback
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module loopback_test;

	// Inputs
	reg [7:0] switches;
	reg rs232_rx;
	reg reset;
	reg clk;

	// Outputs
	wire [7:0] leds;
	wire rs232_tx;

	// Instantiate the Unit Under Test (UUT)
	loopback uut (
		.switches(switches), 
		.leds(leds), 
		.rs232_tx(rs232_tx), 
		.rs232_rx(rs232_rx), 
		.reset(reset), 
		.clk(clk)
	);

	always begin
		clk = ~clk;
		#5;
	end
	
	initial begin
		// Initialize Inputs
		switches = 0;
		rs232_rx = 1;
		reset = 0;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
      reset = 1; 
		#3000000;
		switches = 8'b01100110;
		#1200000;
		switches = 8'b10100000;
		#400000;
		switches = 8'b00001111;
		
		rs232_rx = 0;
		#104167;
		
		rs232_rx = 1;
		#104167;
		rs232_rx = 0;
		#104167;
		rs232_rx = 1;
		#104167;
		rs232_rx = 0;
		#104167;
		rs232_rx = 0;
		#104167;
		rs232_rx = 0;
		#104167;
		rs232_rx = 1;
		#104167;
		rs232_rx = 1;
		#104167;
		
		rs232_rx = 1;
		#104167;
		
		
		

	end
      
endmodule

