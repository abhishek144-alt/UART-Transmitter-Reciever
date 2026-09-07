`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2026 15:21:26
// Design Name: 
// Module Name: uart_top_tb
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: uart_top_tb (fixed)
//
// Fix: DUT instantiation switched back to NAMED port connections. The
// positional list (rst,data_in,wr_enb,clk,rdy_clr,rdy,busy,data_out) put
// rst on uart_top's clk port and the real clk on the data_in port - so the
// DUT never received a toggling clock after the initial reset pulse,
// which would reproduce the exact all-X waveform seen before. Named
// connections make this class of bug impossible to reintroduce silently.
//////////////////////////////////////////////////////////////////////////////////
module uart_top_tb;
    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg wr_enb;
    wire rdy;
    reg rdy_clr;
    wire [7:0] data_out;
    wire busy;

    uart_top dut (
        .clk      (clk),
        .rst      (rst),
        .wr_enb   (wr_enb),
        .data_in  (data_in),
        .rdy_clr  (rdy_clr),
        .rdy      (rdy),
        .busy     (busy),
        .data_out (data_out)
    );

    initial
    begin
        {clk, rst, data_in, rdy_clr} = 0;
    end
    always #5 clk = ~clk;

    task send_byte(input [7:0] din);
        begin
            @(negedge clk)
            data_in = din;
            wr_enb = 1'b1;
            @(negedge clk)
            wr_enb = 0;
        end
    endtask

    task clear_ready;
        begin
            @(negedge clk)
            rdy_clr = 1'b1;
            @(negedge clk)
            rdy_clr = 1'b0;
        end
    endtask

    initial begin
        @(negedge clk)
        rst = 1'b1;
        @(negedge clk)
        rst = 1'b0;

        send_byte(8'h41);
        wait(!busy);
        wait(rdy);
        $display("recieved date is %h", data_out);
        clear_ready;

        send_byte(8'h41);
        wait(!busy);
        wait(rdy);
        $display("recieved date is %h", data_out);
        clear_ready;

        #400 $finish;
    end
endmodule

