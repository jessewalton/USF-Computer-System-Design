`timescale 1ns / 1ps

module lcd4(
    nline,
    rbdat,
    strobe,
    reset,
    CLK,
    hw_lcd_dat,
    hw_lcd_rs,
    hw_lcd_rw,
    hw_lcd_e,
    
    handshake
   
    );
    
    output reg handshake;
    

    input reset;								// use BTNR as reset input
    wire btnr;
    assign btnr = reset;
    input CLK;									// 100 MHz clock input

    output [3:0] hw_lcd_dat;
    output hw_lcd_rs, hw_lcd_rw, hw_lcd_e;

	input nline;  // line number
    input [7:0] rbdat;  // 8-bit ascii data
    input strobe;  // pulse high to write rbdat
    
    reg [6:0] clkCount = 7'b0000000;
	reg oneUSClk = 0;
    
    always @(posedge CLK) begin  // Create a 1us clock
			if(clkCount == 7'b0110001) begin
					clkCount <= 7'b0000000;
					oneUSClk <= ~oneUSClk;
			end
			else begin
					clkCount <= clkCount + 1'b1;
			end
	end
    
    
    reg [3:0] fstate = 0;
    reg [24:0] dcount = 0;
    reg inited = 0;
    reg started = 0;
    reg lcdbusy = 0;
    reg [7:0] tmpdat = 0;
    
    
    reg lcd_rs, lcd_e;
    reg [3:0] lcd_dat;
    
    assign hw_lcd_rs = lcd_rs;
    assign hw_lcd_rw = 0;
    assign hw_lcd_e = lcd_e;
    assign hw_lcd_dat = lcd_dat;
    
    
    reg oldline = 0;
    reg linechange = 0;
    
    
    reg [7:0] rbuf [0:63];
    reg [5:0] rbhead = 0;
    reg [5:0] rbtail = 0;
    
    always @(posedge CLK) begin
        if(strobe) begin
            rbuf[(rbhead + 1) & 6'h3f] <= rbdat;
            rbhead <= (rbhead + 1) & 6'h3f;
        end
    end

    /*reg nline;
    reg [24:0] bigcount;
    always @(posedge oneUSClk) begin
        if (bigcount[19:0] == 0) begin
            rbuf[rbhead + 1] <= 8'h21;
            rbhead <= rbhead + 1;
            bigcount <= bigcount + 1;
            // hw_leds <= !hw_leds;
        end
        else if (bigcount == 6000000) begin
            nline <= !nline;
            bigcount <= 0;
        end
        else begin
            bigcount <= bigcount + 1;
        end
    end*/
    
    
    
    always @(posedge oneUSClk or posedge btnr) begin
        if (oneUSClk) begin
            // handshake <= started && inited && (!linechange) && (!lcdbusy) && (rbhead == rbtail);
            handshake <= (!lcdbusy) && (rbhead == rbtail) && (nline == oldline) && (!linechange);
        end
        
        if(btnr == 1'b1) begin
            fstate <= 0;
            dcount <= 0;
            inited <= 0;
            started <=0;
            lcdbusy <= 0;
            
            oldline <= 0;
            linechange <= 0;
        end
        else if(!started) begin
            if (dcount == 30000) begin
                dcount <=0;
                started <= 1;
                
                linechange <= 0;
            end
            else begin
                dcount <= dcount + 1;
            end
        end
        else begin
            if (!inited) begin
                if (dcount == 0) begin
                    lcd_e <= 1;
                    lcd_dat <= 2;
                    lcd_rs <= 0;
                end
                else if (dcount == 2) begin
                    lcd_e <= 1;
                    lcd_dat <= 15;
                end
                else if (dcount == 42) begin
                    lcd_e <= 1;
                    lcd_dat <= 0;
                end
                else if (dcount == 44) begin
                    lcd_e <= 1;
                    lcd_dat <= 12;
                end
                else if (dcount == 84) begin
                    lcd_e <= 1;
                    lcd_dat <= 0;
                end
                else if (dcount == 86) begin
                    lcd_e <= 1;
                    lcd_dat <= 1;
                end
                else if (dcount == 1540) begin
                    lcd_e <= 1;
                    lcd_dat <= 0;
                end
                else if (dcount == 1542) begin
                    lcd_e <= 1;
                    lcd_dat <= 6;
                end
                else begin
                    lcd_e <= 0;
                end
                
                if (dcount == 3000) begin
                    dcount <= 0;
                    inited <= 1;
                    lcd_rs <= 1;
                    lcdbusy <= 0;
                end
                else begin
                    dcount <= dcount + 1;
                end 
            end
            
            else begin
            
                if (linechange) begin
                    //hw_leds <= 1;
                    if (dcount == 2600) begin
                        lcd_rs <= 0;
                        lcd_dat <= nline ? 12 : 0;
                        //lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2601) begin
                        lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2603) begin
                        lcd_dat <= 0;
                        //lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2604) begin
                        lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2606) begin
                        lcd_e <= 0;
                        dcount <= 0;
                        linechange <= 0;
                        lcd_rs <= 1;
                    end
                    else begin
                        lcd_e <= 0;
                        dcount <= dcount + 1;
                    end
                end
                
                // Good to print things
                else if (lcdbusy) begin
                    //hw_leds <= 1;
                    if (dcount == 2600) begin
                        lcd_dat <= tmpdat[7:4];
                        //lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2601) begin
                        //lcd_dat <= tmpdat[3:0];
                        lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2603) begin
                        lcd_dat <= tmpdat[3:0];
                        //lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2604) begin
                        //lcd_dat <= tmpdat[3:0];
                        lcd_e <= 1;
                        dcount <= dcount + 1;
                    end
                    else if (dcount == 2605) begin
                        lcd_e <= 0;
                        dcount <= 0;
                        lcdbusy <= 0;
                    end
                    else begin
                        lcd_e <= 0;
                        dcount <= dcount + 1;
                    end
                end
                
                
                
                else begin
                    if (nline != oldline) begin
                        linechange <= 1;
                        dcount <= 0;
                        oldline <= nline;
                    end
                    else if (rbhead != rbtail) begin
                        rbtail <= (rbtail + 1) & 6'h3f;
                        tmpdat <= rbuf[(rbtail + 1)& 6'h3f][7:0];
                        lcdbusy <= 1;
                        dcount <= 0;
                    end
                    
       
                end
                
            end
        end
    end
                
                
                
                  
endmodule
