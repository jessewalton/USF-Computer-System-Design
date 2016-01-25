`timescale 1ns / 1ps



module soda_machine(
		quarter_switch,
		nickel_switch,
		dime_switch,
		soda_switch,
		diet_switch,
		change,
		give_soda,
		give_diet,
		reset,
		clk
    );


input reset, clk;
input quarter_switch, dime_switch, nickel_switch, soda_switch, diet_switch;
output reg give_soda, give_diet, change;


parameter state_00cents  = 5'b00000;
parameter state_05cents  = 5'b00001;
parameter state_10cents  = 5'b00010;
parameter state_15cents  = 5'b00011;
parameter state_20cents  = 5'b00100;
parameter state_25cents  = 5'b00101;
parameter state_30cents  = 5'b00110;
parameter state_35cents  = 5'b00111;
parameter state_40cents  = 5'b01000;
parameter state_45cents = 5'b01001;
parameter state_50cents = 5'b01010;
parameter state_55cents = 5'b01011;
parameter state_60cents = 5'b01100;
parameter state_65cents = 5'b01101;

parameter state_selectSoda = 5'b01110;
parameter state_giving_change_pulse = 5'b01111;
parameter state_giving_diet_pulse = 5'b10000;
parameter state_giving_regular_pulse = 5'b10001;


parameter wait_state = 5'b10010;
/*
parameter <state21> = 5'b10011;
parameter <state21>  = 5'b10100;
parameter <state22> = 5'b10101;
parameter <state23> = 5'b10110;
parameter <state24> = 5'b10111;
parameter <state25> = 5'b11000;
parameter <state26> = 5'b11001;
parameter <state27> = 5'b11010;
parameter <state28> = 5'b11011;
parameter <state29> = 5'b11100;
parameter <state30> = 5'b11101;
parameter <state31> = 5'b11110;
parameter <state32> = 5'b11111;
*/

(* FSM_ENCODING="SEQUENTIAL", SAFE_IMPLEMENTATION="YES", SAFE_RECOVERY_STATE="5'b00000" *) 
reg [4:0] next_state = 5'b00000, return_state = 5'b00000;

wire quarter, dime, nickel, regular, diet;


debounceIndex dbquarter(.reset(reset), .clk(clk), .noisy(quarter_switch), .clean(quarter));
debounceIndex dbdime(.reset(reset), .clk(clk), .noisy(dime_switch), .clean(dime));
debounceIndex dbnickel(.reset(reset), .clk(clk), .noisy(nickel_switch), .clean(nickel));
debounceIndex dbregular(.reset(reset), .clk(clk), .noisy(soda_switch), .clean(regular));
debounceIndex dbdiet(.reset(reset), .clk(clk), .noisy(diet_switch), .clean(diet));

/*
assign quarter = quarter_switch;
assign dime = dime_switch;
assign nickel = nickel_switch;
assign regular = soda_switch;
assign diet = diet_switch;
*/



/* change management state machine */ 
always@(posedge clk) begin

   if (reset) begin
      next_state <= state_00cents;
		give_soda <= 0;
		give_diet <= 0;
		change <= 0;
	end
   else begin
      case (next_state)

         wait_state: begin
            if(quarter || dime || nickel)
               next_state <= next_state;
            else
               next_state <= return_state;
         end
		
         state_00cents : begin // .00           // initial state (.00)
            if (nickel) begin                   // if a nickel is inserted
               next_state <= wait_state;        // move to intermediate wait state
               return_state <= state_05cents;   // assign next state after wait (.05)
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_10cents;
            end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_25cents;
            end
            else // No Op
               next_state <= state_00cents;
         end
			
         state_05cents : begin // .05
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_10cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_15cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_30cents;
            end
            else
               next_state <= state_05cents;
         end
			
         state_10cents : begin // .10
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_15cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_20cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_35cents;
            end
            else
               next_state <= state_10cents;
         end
			
         state_15cents : begin // .15
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_20cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_25cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_40cents;
            end
            else
               next_state <= state_15cents;
         end
			
         state_20cents : begin // .20
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_25cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_30cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_45cents;
            end
            else
               next_state <= state_20cents;
         end
			
         state_25cents : begin // .25
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_30cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_35cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_50cents;
            end
            else
               next_state <= state_25cents;
         end
			
         state_30cents : begin // .30
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_35cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_40cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_55cents;
            end
            else
               next_state <= state_30cents;
         end
			
         state_35cents : begin // .35
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_40cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_45cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_60cents;
            end
            else
               next_state <= state_35cents;
         end
			
         state_40cents : begin // .40
            if (nickel) begin
               next_state <= wait_state;
               return_state <= state_45cents;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= state_50cents;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= state_65cents;
            end
            else
               next_state <= state_40cents;
         end
			
         state_45cents : begin // .45
				// Correct amount paid
            next_state <= state_selectSoda;
         end
			
         state_50cents : begin	// .50
				change <= 1;
				next_state <= state_giving_change_pulse;
				return_state <= state_45cents;
         end
			
         state_55cents : begin // .55
				change <= 1;
				next_state <= state_giving_change_pulse;
				return_state <= state_50cents;
         end
			
         state_60cents : begin // .60
				change <= 1;
				next_state <= state_giving_change_pulse;
				return_state <= state_55cents;
         end
			
         state_65cents : begin // .65
				change <= 1;
				next_state <= state_giving_change_pulse;
				return_state <= state_60cents;
         end
			
         state_selectSoda : begin // Soda
            if (diet) begin
					give_diet <= 1;
               next_state <= state_giving_diet_pulse;
				end
            else if (regular) begin
					give_soda <= 1;
					next_state <= state_giving_regular_pulse;
				end
				// STAY HERE
				// next_state <= state_selectSoda;
         end
		
			
			state_giving_change_pulse : begin
				change <= 0;
				next_state <= return_state;
			end
			
			state_giving_diet_pulse : begin
				give_diet <= 0;
				next_state <= state_00cents;
			end
			
			state_giving_regular_pulse : begin
				give_soda <= 0;
				next_state <= state_00cents;
			end
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			/*
         // ADDITIONAL STATES, NOT YET USED
         <state16> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
			<state17> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state18> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state19> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state20> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state21> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state22> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state23> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state24> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state25> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state26> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state27> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state28> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state29> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state30> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state31> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
         <state32> : begin
            if (nickel) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else if (dime) begin
               next_state <= wait_state;
               return_state <= <state>;
				end
            else if (quarter) begin
               next_state <= wait_state;
               return_state <= <state>;
            end
            else
               next_state <= <state>;
         end
			
			*/

         default : begin  // Fault Recovery
            next_state <= state_00cents;
         end   
			
      endcase /* end case statement */
   end /* end else statement */
end /* end always block */


endmodule