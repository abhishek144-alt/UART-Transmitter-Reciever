`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2026 14:41:23
// Design Name: 
// Module Name: uart_top
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
// Module Name: uart_top (fixed)
//
// Replaces the draft that referenced undeclared signals (tx, clk_enb,
// rx_clk, tx_clk) and used positional port connections that didn't match
// the actual port order of baud_rate_generator, transmitter, or reciever.
//
// baud_rate_generator has exactly 3 ports: clk, tx_enb, rx_enb (no rst).
// transmitter has 7 ports: clk, enb, wr_enb, rst, data_in, tx, busy.
// reciever has 7 ports: clk, rst, rdy_clr, enb, rx, rdy, data_out.
//
// Named connections are used throughout so a typo'd or reordered port
// causes an immediate, clear elaboration error instead of a silent
// misconnection.
//
// Design: internal loopback - transmitter's serial tx feeds directly into
// reciever's rx internally (tx_temp). No external UART pins are exposed,
// matching the original data-level-only port list. Say the word if you'd
// rather expose tx/rx as real external pins instead.
//////////////////////////////////////////////////////////////////////////////////
module uart_top(
    input        clk,
    input        rst,
    input        wr_enb,
    input  [7:0] data_in,
    input        rdy_clr,
    output       rdy,
    output       busy,
    output [7:0] data_out
);

    wire tx_enb;    // 1x baud tick, drives transmitter
    wire rx_enb;    // 16x oversample tick, drives reciever
    wire tx_temp;   // internal serial line: transmitter.tx -> reciever.rx

    baud_rate_generator bg (
        .clk    (clk),
        .tx_enb (tx_enb),
        .rx_enb (rx_enb)
    );

    transmitter us (
        .clk     (clk),
        .enb     (tx_enb),
        .wr_enb  (wr_enb),
        .rst     (rst),
        .data_in (data_in),
        .tx      (tx_temp),
        .busy    (busy)
    );

    reciever ur (
        .clk      (clk),
        .rst      (rst),
        .rdy_clr  (rdy_clr),
        .enb      (rx_enb),
        .rx       (tx_temp),
        .rdy      (rdy),
        .data_out (data_out)
    );

endmodule