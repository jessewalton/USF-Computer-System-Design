`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:31:22 01/30/2015 
// Design Name: 
// Module Name:    led_driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module led_driver_wrapper( led_value, leds, write_to_leds, clk, reset );
	input [7:0] led_value;
	output reg [7:0] leds;
	input write_to_leds;
	input clk;
	input reset;
	
	always @(posedge clk or posedge reset) begin
		if(reset) leds <= 0;
		else if(write_to_leds) leds <= led_value;
	end

endmodule
