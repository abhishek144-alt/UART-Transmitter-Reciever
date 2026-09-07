`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2026 01:23:14
// Design Name: 
// Module Name: transmitter
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


module transmitter(input clk,enb, wr_enb, rst, input[7:0]data_in, output reg tx ,output busy );
parameter idle_state = 2'b00;
parameter start_state =2'b01;
parameter data_state = 2'b10;
parameter stop_state = 2'b11;
reg [7:0]data;
reg [2:0]index;
reg[1:0]state = idle_state;
always@(posedge clk)
begin 
if (rst)begin
state <= idle_state;
data <= 8'h00;
index <= 3'h0;
tx <= 1'b1;
end
else 
begin
case(state)
idle_state :
begin
if(wr_enb)
begin
state <= start_state;
data <= data_in;
index<= 3'h0;
end
else
state <= idle_state;
end
start_state :
begin 
if(enb)
begin
tx <= 1'b0;
state <= data_state;
end
else begin
state <= start_state;
end
end
data_state :
begin
if(enb)
begin
if(index == 3'h7)
state <= stop_state;
else  
index <= index + 3'b1;
tx <= data[index];
end
end
stop_state :
begin
if(enb)
begin 
tx <=1'b1;
state <= idle_state;
end
end
default : begin
tx <= 1'b1;
state <= idle_state;
end
endcase
end
end
assign busy = (state != idle_state);
endmodule
