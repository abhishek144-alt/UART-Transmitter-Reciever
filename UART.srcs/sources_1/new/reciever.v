`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2026 02:47:22
// Design Name: 
// Module Name: reciever
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reciever(input clk,rst,rdy_clr,enb,rx, output reg rdy,output reg [7:0]data_out );
parameter start_state =2'b00;
parameter data_out_state = 2'b01;
parameter stop_state = 2'b10;
reg [1:0] state = start_state;
reg [3:0] sample =4'h0;
reg [3:0]index =4'h0;
reg [7:0] temp_register =8'h0;

    always@(posedge clk)
    begin
    if(rst)
    begin
    state <= 1'b0;
    rdy <= 0;
    data_out = 0;
    sample <=4'h0;
    index <= 4'h0;
    temp_register <= 8'h0;
    end
   
  
    else
    begin
    if(rdy_clr)
    rdy <=0;
    if (enb)
    case(state)
    start_state : begin
    if (rx == 1'b0) begin 
    if(sample == 4'hF) begin
     state <= data_out_state;
            sample        <= 4'h0;
            index         <= 4'h0;
            temp_register <= 8'h0;
    end
    else 
    sample <= sample + 1'b1;
 end 
 else  
  sample <= 4'h0;
  end
    data_out_state :
    begin 
    sample <= sample + 1'b1;
    if(sample == 4'h8)
    begin
    temp_register[index]<= rx;
    index <= index  + 1'b1;
    end 
    if (index == 8 && sample == 15)
    state <= stop_state;
    end
    stop_state : begin 
    if (sample == 4'hF) begin
    
    state <= start_state;
    data_out <= temp_register;
    rdy <= 1'b1;
    sample <= 4'h0;
    
    end
    else  begin
    sample = sample + 1'b1;
    end
    end
    default : begin
     state <= start_state;
     end 
     endcase
     end
     end

endmodule
