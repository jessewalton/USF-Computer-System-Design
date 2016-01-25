`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:39:44 02/03/2015
// Design Name:   soda_machine_wrapper
// Module Name:   E:/CSD Lab/automagically/lab04/lab04/test_everything_at_once.v
// Project Name:  lab04
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: soda_machine_wrapper
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_everything_at_once;

	// Inputs
	reg quarter_switch;
	reg nickel_switch;
	reg dime_switch;
	reg soda_switch;
	reg diet_switch;
	reg reset;
	reg clk;

	// Outputs
	wire soda_given;
	wire diet_given;
	wire [2:0] change_count;

	// Instantiate the Unit Under Test (UUT)
	soda_machine_wrapper uut (
		.quarter_switch(quarter_switch), 
		.nickel_switch(nickel_switch), 
		.dime_switch(dime_switch), 
		.soda_switch(soda_switch), 
		.diet_switch(diet_switch), 
		.soda_given(soda_given), 
		.diet_given(diet_given), 
		.change_count(change_count), 
		.reset(reset), 
		.clk(clk)
	);
	
	always begin
		clk = ~clk;
		#5;
	end

	initial begin
		// Initialize Inputs
		quarter_switch = 0;
		nickel_switch = 0;
		dime_switch = 0;
		soda_switch = 0;
		diet_switch = 0;
		reset = 1;
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 0;
		#10;
		reset = 1;
	   nickel_switch = 1;
		#10;
		nickel_switch=0;
		#10;
		dime_switch = 1;
		#10;
		dime_switch = 0;
		#10;
		 nickel_switch = 1;
		#10;
		nickel_switch=0;
		#10;
		dime_switch = 1;
		#10;
		dime_switch = 0;
		#10;
		nickel_switch = 1;
		#10;
		nickel_switch=0;
		#10;
		dime_switch = 1;
		#10;
		dime_switch = 0;
		
		#10;
		soda_switch = 1;
		diet_switch = 1;
		
		#100;
		diet_switch = 0;
		#100;
		soda_switch = 0;
		#100;
		
		
		
        
		// Add stimulus here

	end
      
endmodule

