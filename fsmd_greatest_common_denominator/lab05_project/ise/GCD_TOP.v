`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:54:23 02/10/2015 
// Design Name: 
// Module Name:    GCD_TOP 
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
module GCD_TOP( start, x_in, y_in, reset, gcd_out, gcd_done, clk);
    input [0:0] start;
    input [3:0] x_in;
    input [3:0] y_in;
    input [0:0] reset;
    output [3:0] gcd_out;
    output reg [0:0] gcd_done;
    input [0:0] clk;
    //////////////////
	 
	 reg [0:0] x_ld;
	 reg [0:0] y_ld;
	 reg [0:0] x_sel;
	 reg [0:0] y_sel;
	 reg [0:0] d_ld;
	 
	 wire x_neq_y, x_lt_y;
	 
	 wire [3:0] d_out;
	 
	 assign gcd_out = d_out;
	 
	 //////////////////
   parameter state01 = 3'b000;
   parameter state02 = 3'b001;
   parameter state03 = 3'b010;
   parameter state04 = 3'b011;
   parameter state05 = 3'b100;
   parameter state06 = 3'b101;
   parameter state07 = 3'b110;
   parameter state08 = 3'b111;
	
	datapath_gcd my_gcd_math(x_sel, y_sel, x_ld, y_ld, x_in, y_in, d_ld, x_neq_y, x_lt_y, d_out, clk, reset);

   (* FSM_ENCODING="SEQUNTIAL", SAFE_IMPLEMENTATION="YES", SAFE_RECOVERY_STATE="state01" *) reg [2:0] state = state01;

   always@(posedge clk)
      if (reset) begin
			y_sel=0;
			x_sel=0;
			y_ld=0;
			x_ld=0;
			d_ld=0;
			gcd_done=0;
         state <= state01;
      end
      else
         (* PARALLEL_CASE *) case (state)
            state01 : begin
				d_ld=0;
				
               if (!start)
                  state <= state01;
              
               else
                  state <= state02;
            end
////////////////////////////////////////////////////							
            state02 : begin
					x_sel=0;
					y_sel=0;
					x_ld=1;
					y_ld=1;
				
				state <= state03;
              
            end				
////////////////////////////////////////////////////				
            state03 : begin
				x_ld=0;
				y_ld=0;
				x_sel=1;
				y_sel=1;
               if (!x_neq_y) begin
						 
                  state <= state06;
               end else if (x_lt_y)
                  state <= state04;
               else
                  state <= state05;
            end
///////////////////////////////////////////////////				
            state04 : begin
				
				y_ld=1;
				
               state<=state03;
            end
//////////////////////////////////////////////////				
            state05 : begin
             x_ld=1;
				  state<=state03;
            end
/////////////////////////////////////////////////				
            state06 : begin
				d_ld=1;
				gcd_done=1;
				   
				state<=state01;				
            end
//////////////////////////////////////
          
            
            default : begin  // Fault Recovery
               state <= state01;
            end   
         endcase

   // Add other output equations as necessary
						
	 
endmodule
