`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/14 15:17:39
// Design Name: 
// Module Name: UART_V1_0
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


module UART_V1_0 #(
    parameter BAUD_RATE = 115200,
    parameter CLOCK_FREQ = 100000000,
    parameter UART_DATA_WIDTH = 8,
    parameter PARITY = "EVEN",
    parameter TX_FIFO_DATA_WIDTH =8,
    parameter TX_FIFO_DEPTH = 1024,
    parameter RX_FIFO_DATA_WIDTH = 8,
    parameter RX_FIFO_DEPTH = 1024
)
(   // Global signals
    input   clock,
    input   resetn,
    // UART Interface
    input   rx_o,
    output  tx_o,
    // User FIFO Interface
    input [TX_FIFO_DATA_WIDTH-1:0] din,
    input                          wr_en,
    output[1:0]                    wr_status,

    output[RX_FIFO_DATA_WIDTH-1:0] dout,
    input                          rd_en,
    output[1:0]                    rd_status,
    // Module Status
    output                               init_finish,
    output [$clog2(TX_FIFO_DEPTH*TX_FIFO_DATA_WIDTH/8)+1-1:0] tx_fifo_count,
    output [$clog2(RX_FIFO_DEPTH*RX_FIFO_DATA_WIDTH/8)+1-1:0] rx_fifo_count,
    output                                                    parity_error
);
    wire                                                    tx_fifo_reset_finish;
    wire                                                    tx_tifo_start_write;
    wire [TX_FIFO_DATA_WIDTH-1:0]                           tx_fifo_data_write;
    wire [1:0]                                              tx_fifo_write_status;
    wire [$clog2(TX_FIFO_DEPTH)+1-1:0]                      tx_fifo_wr_data_count;
    wire                                                    tx_tifo_start_read;
    wire [7:0]                                              tx_fifo_data_read;
    wire [1:0]                                              tx_fifo_read_status;
    wire [$clog2(TX_FIFO_DEPTH*TX_FIFO_DATA_WIDTH/8)+1-1:0] tx_fifo_rd_data_count;

    wire                                                    rx_fifo_reset_finish;
    wire                                                    rx_tifo_start_write;
    wire [7:0]                                              rx_fifo_data_write;
    wire [1:0]                                              rx_fifo_write_status;
    wire [$clog2(RX_FIFO_DEPTH*RX_FIFO_DATA_WIDTH/8)+1-1:0] rx_fifo_wr_data_count;
    wire                                                    rx_tifo_start_read;
    wire [RX_FIFO_DATA_WIDTH-1:0]                           rx_fifo_data_read;
    wire [1:0]                                              rx_fifo_read_status;
    wire [$clog2(RX_FIFO_DEPTH*RX_FIFO_DATA_WIDTH/8)+1-1:0] rx_fifo_rd_data_count;

    assign tx_fifo_data_write  = din;
    assign tx_tifo_start_write = wr_en;
    assign wr_status           = tx_fifo_write_status;

    assign dout                = rx_fifo_data_read;
    assign rx_tifo_start_read  = rd_en;
    assign rd_status           = rx_fifo_read_status;

    assign init_finish   = tx_fifo_reset_finish & rx_fifo_reset_finish;
    assign tx_fifo_count = tx_fifo_rd_data_count;
    assign rx_fifo_count = rx_fifo_rd_data_count;
fifo_wrapper #(
    .WRITE_DATA_WIDTH(TX_FIFO_DATA_WIDTH),
    .READ_DATA_WIDTH(8),
    .WRITE_FIFO_DEPTH(TX_FIFO_DEPTH)
)tx_fifo 
(   // global signals
    .clk(clock),                    // input  wire                        clk,
    .rstn(resetn),                   // input  wire                        rstn,
    .reset_finish(tx_fifo_reset_finish),           // output wire                        reset_finish,
                             // // write interface
    .data_write(tx_fifo_data_write),             // input  wire [WRITE_DATA_WIDTH-1:0] data_write,
    .start_write(tx_tifo_start_write),            // input  wire                        start_write,
    .write_status(tx_fifo_write_status),           // output reg  [1:0]                  write_status,
    .wr_data_count(tx_fifo_wr_data_count),          // output  [($clog2(WRITE_FIFO_DEPTH)+1)-1:0] wr_data_count,
                             // // read interface
    .start_read(tx_tifo_start_read),             // input  wire                        start_read,
    .data_read(tx_fifo_data_read),              // output reg  [READ_DATA_WIDTH-1:0]  data_read,
    .read_status(tx_fifo_read_status),            // output reg  [1:0]                  read_status
    .rd_data_count(tx_fifo_rd_data_count)           // output  [($clog2((WRITE_FIFO_DEPTH * WRITE_DATA_WIDTH) / READ_DATA_WIDTH)+1)-1:0]  rd_data_count
);
fifo_wrapper #(
    .WRITE_DATA_WIDTH(8),
    .READ_DATA_WIDTH(RX_FIFO_DATA_WIDTH),
    .WRITE_FIFO_DEPTH(RX_FIFO_DEPTH*RX_FIFO_DATA_WIDTH/8)
)rx_fifo 
(   // global signals
    .clk(clock),                    // input  wire                        clk,
    .rstn(resetn),                   // input  wire                        rstn,
    .reset_finish(rx_fifo_reset_finish),           // output wire                        reset_finish,
                             // // write interface
    .data_write(rx_fifo_data_write),             // input  wire [WRITE_DATA_WIDTH-1:0] data_write,
    .start_write(rx_tifo_start_write),            // input  wire                        start_write,
    .write_status(rx_fifo_write_status),           // output reg  [1:0]                  write_status,
    .wr_data_count(rx_fifo_wr_data_count),          // output  [($clog2(WRITE_FIFO_DEPTH)+1)-1:0] wr_data_count,
                             // // read interface
    .start_read(rx_tifo_start_read),             // input  wire                        start_read,
    .data_read(rx_fifo_data_read),              // output reg  [READ_DATA_WIDTH-1:0]  data_read,
    .read_status(rx_fifo_read_status),            // output reg  [1:0]                  read_status
    .rd_data_count(rx_fifo_rd_data_count)           // output  [($clog2((WRITE_FIFO_DEPTH * WRITE_DATA_WIDTH) / READ_DATA_WIDTH)+1)-1:0]  rd_data_count
);
uart_wrapper #(
    .BAUD_RATE(BAUD_RATE),
    .CLOCK_FREQ(CLOCK_FREQ),
    .DATA_WIDTH(UART_DATA_WIDTH),
    .PARITY(PARITY)
)user_uart
(
    .clk(clock),
    .rstn(resetn),
    // FIFO Interface
    .start_read_fifo(tx_tifo_start_read),
    .start_write_fifo(rx_tifo_start_write),
    .data_read_fifo(tx_fifo_data_read),
    .data_write_fifo(rx_fifo_data_write),
    .status_read_fifo(tx_fifo_read_status),
    .status_write_fifo(rx_fifo_write_status),
    // UART Interface
    .rx_o(rx_o),
    .tx_o(tx_o),
    .parity_error(parity_error)
);
endmodule
