`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/11 21:51:17
// Design Name: 
// Module Name: fifo_wrapper
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


module fifo_wrapper #(
    parameter WRITE_DATA_WIDTH = 8,
    parameter READ_DATA_WIDTH  = 8,
    parameter WRITE_FIFO_DEPTH = 1024
)
(   // global signals
    input  wire                        clk,
    input  wire                        rstn,
    output wire                        reset_finish,
    // write interface
    input  wire [WRITE_DATA_WIDTH-1:0] data_write,
    input  wire                        start_write,
    output reg  [1:0]                  write_status,
    output  [($clog2(WRITE_FIFO_DEPTH)+1)-1:0] wr_data_count,
    // read interface
    input  wire                        start_read,
    output reg  [READ_DATA_WIDTH-1:0]  data_read,
    output reg  [1:0]                  read_status,
    output  [($clog2((WRITE_FIFO_DEPTH * WRITE_DATA_WIDTH) / READ_DATA_WIDTH)+1)-1:0]  rd_data_count
);
    reg  start_write_d;
    reg  start_read_d;
    wire start_write_pulse = (start_write_d == 1'b0) && (start_write == 1'b1);
    wire start_read_pulse  = (start_read_d == 1'b0)  && (start_read == 1'b1);
    always @(posedge clk ) begin
        if(!rstn) begin
            start_write_d <= 1'b0;
            start_read_d  <= 1'b0;
        end
        else begin
            start_write_d <= start_write;
            start_read_d  <= start_read;
        end
    end

    // write machine
    localparam IDLE          = 2'b00 ;
    localparam WORK          = 2'b01 ;
    localparam DONE          = 2'b10 ;
    localparam WRITE_FAILURE = 2'b01 ;
    localparam WRITE_SUCCESS = 2'b10 ;
    wire                        full;
    wire                        wr_ack;
    reg  [1:0]                  state_write;
    reg  [WRITE_DATA_WIDTH-1:0] data_write_d;
    reg                         wr_en;
    always @(posedge clk ) begin
        if(!rstn)
        begin
            state_write  <= IDLE;
            data_write_d <= {WRITE_DATA_WIDTH{1'b0}};
            write_status <= 2'b00;
            wr_en        <= 1'b0;
        end
        else
        begin
            case(state_write)
            IDLE:
            begin
                if(start_write_pulse)
                begin
                    state_write  <= WORK;
                    write_status <= 2'b00;
                end
                else
                    state_write <= IDLE;
            end
            WORK:
            begin
                data_write_d <= data_write;
                if(full)
                begin
                    state_write  <= IDLE;
                    write_status <= WRITE_FAILURE;
                end
                else
                begin
                    if(wr_en == 1'b0)
                    begin
                        wr_en <= 1'b1;
                    end
                    else
                    begin
                        wr_en       <= 1'b0;
                        state_write <= DONE;
                    end
                end
            end
            DONE:
            begin
                    if(wr_ack)
                    begin
                        state_write  <= IDLE;
                        write_status <= WRITE_SUCCESS;
                    end
            end
            endcase
        end
    end

    // read machine
    localparam READ_FAILURE = 2'b01 ;
    localparam READ_SUCCESS = 2'b10 ;
    wire                        empty;
    wire                        valid;
    reg  [1:0]                  state_read;
    reg                         rd_en;
    wire [READ_DATA_WIDTH-1:0]  dout;
    always @(posedge clk ) begin
        if(!rstn)
        begin
            state_read   <= IDLE;
            data_read    <= {READ_DATA_WIDTH{1'b0}};
            read_status  <= 2'b00;
            rd_en        <= 1'b0;
        end
        else
        begin
            case(state_read)
            IDLE:
            begin
                if(start_read_pulse)
                begin
                    state_read  <= WORK;
                    read_status <= 2'b00;
                end
                else
                    state_read <= IDLE;
            end
            WORK:
            begin
                if(empty)
                begin
                    state_read   <= IDLE;
                    read_status  <= READ_FAILURE;
                end
                else
                begin
                    if(rd_en == 1'b0)
                    begin
                        rd_en <= 1'b1;
                    end
                    else
                    begin
                        rd_en       <= 1'b0;
                        state_read  <= DONE;
                    end
                end
            end
            DONE:
            begin
                if(valid)
                begin
                    data_read    <= dout;
                    state_read   <= IDLE;
                    read_status  <= READ_SUCCESS;
                end
            end
            default:
                state_read <= IDLE;
            endcase
        end
    end


// fifo_generator_0 fifo_1024x8 (
//   .clk(clk),                    // input wire clk
//   .srst(~rstn),                 // input wire srst
//   .din(data_write_d),           // input wire [WRITE_DATA_WIDTH-1 : 0] din
//   .wr_en(wr_en),                // input wire wr_en
//   .rd_en(rd_en),                // input wire rd_en
//   .dout(dout),                  // output wire [READ_DATA_WIDTH-1 : 0] dout
//   .full(full),                  // output wire full
//   .almost_full(almost_full),    // output wire almost_full
//   .wr_ack(wr_ack),              // output wire wr_ack
//   .overflow(overflow),          // output wire overflow
//   .empty(empty),                // output wire empty
//   .almost_empty(almost_empty),  // output wire almost_empty
//   .valid(valid),                // output wire valid
//   .underflow(underflow),        // output wire underflow
//   .data_count(data_count)      //  output wire [9 : 0] data_count
// );
 localparam READ_FIFO_DEPTH = (WRITE_FIFO_DEPTH * WRITE_DATA_WIDTH) / READ_DATA_WIDTH;
 wire wr_rst_busy;
 wire rd_rst_busy;
 assign reset_finish = ~wr_rst_busy && ~rd_rst_busy;
 xpm_fifo_sync #(
      .CASCADE_HEIGHT(0),        // DECIMAL
      .DOUT_RESET_VALUE("0"),    // String
      .ECC_MODE("no_ecc"),       // String
      .FIFO_MEMORY_TYPE("block"), // String
      .FIFO_READ_LATENCY(1),     // DECIMAL
      .FIFO_WRITE_DEPTH(WRITE_FIFO_DEPTH),   // DECIMAL
      .FULL_RESET_VALUE(1),      // DECIMAL
      .PROG_EMPTY_THRESH(10),    // DECIMAL
      .PROG_FULL_THRESH(10),     // DECIMAL
      .RD_DATA_COUNT_WIDTH($clog2(READ_FIFO_DEPTH)+1),   // DECIMAL
      .READ_DATA_WIDTH(READ_DATA_WIDTH),      // DECIMAL
      .READ_MODE("std"),         // String
      .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_ADV_FEATURES("1414"), // String
      .WAKEUP_TIME(0),           // DECIMAL
      .WRITE_DATA_WIDTH(WRITE_DATA_WIDTH),     // DECIMAL
      .WR_DATA_COUNT_WIDTH($clog2(WRITE_FIFO_DEPTH)+1)    // DECIMAL
   )
   user_xpm_fifo_sync(
      .almost_empty(),   // 1-bit output: Almost Empty : When asserted, this signal indicates that
                                     // only one more read can be performed before the FIFO goes to empty.

      .almost_full(),     // 1-bit output: Almost Full: When asserted, this signal indicates that
                                     // only one more write can be performed before the FIFO is full.

      .data_valid(valid),       // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                     // that valid data is available on the output bus (dout).

      .dbiterr(),             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
                                     // a double-bit error and data in the FIFO core is corrupted.

      .dout(dout),                   // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                     // when reading the FIFO.

      .empty(empty),                 // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                     // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                     // initiating a read while empty is not destructive to the FIFO.

      .full(full),                   // 1-bit output: Full Flag: When asserted, this signal indicates that the
                                     // FIFO is full. Write requests are ignored when the FIFO is full,
                                     // initiating a write when the FIFO is full is not destructive to the
                                     // contents of the FIFO.

      .overflow(),           // 1-bit output: Overflow: This signal indicates that a write request
                                     // (wren) during the prior clock cycle was rejected, because the FIFO is
                                     // full. Overflowing the FIFO is not destructive to the contents of the
                                     // FIFO.

      .prog_empty(),       // 1-bit output: Programmable Empty: This signal is asserted when the
                                     // number of words in the FIFO is less than or equal to the programmable
                                     // empty threshold value. It is de-asserted when the number of words in
                                     // the FIFO exceeds the programmable empty threshold value.

      .prog_full(),         // 1-bit output: Programmable Full: This signal is asserted when the
                                     // number of words in the FIFO is greater than or equal to the
                                     // programmable full threshold value. It is de-asserted when the number of
                                     // words in the FIFO is less than the programmable full threshold value.

      .rd_data_count(rd_data_count), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
                                     // number of words read from the FIFO.

      .rd_rst_busy(rd_rst_busy),     // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
                                     // domain is currently in a reset state.

      .sbiterr(),             // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
                                     // and fixed a single-bit error.

      .underflow(),         // 1-bit output: Underflow: Indicates that the read request (rd_en) during
                                     // the previous clock cycle was rejected because the FIFO is empty. Under
                                     // flowing the FIFO is not destructive to the FIFO.

      .wr_ack(wr_ack),               // 1-bit output: Write Acknowledge: This signal indicates that a write
                                     // request (wr_en) during the prior clock cycle is succeeded.

      .wr_data_count(wr_data_count), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
                                     // the number of words written into the FIFO.

      .wr_rst_busy(wr_rst_busy),     // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
                                     // write domain is currently in a reset state.

      .din(data_write_d),                     // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                     // writing the FIFO.

      .injectdbiterr(1'b0), // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .injectsbiterr(1'b0), // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                     // the ECC feature is used on block RAMs or UltraRAM macros.

      .rd_en(rd_en),                 // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                     // signal causes data (on dout) to be read from the FIFO. Must be held
                                     // active-low when rd_rst_busy is active high.

      .rst(~rstn),                     // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                     // unstable at the time of applying reset, but reset must be released only
                                     // after the clock(s) is/are stable.

      .sleep(1'b0),                 // 1-bit input: Dynamic power saving- If sleep is High, the memory/fifo
                                     // block is in power saving mode.

      .wr_clk(clk),               // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                     // free running clock.

      .wr_en(wr_en)                  // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                     // signal causes data (on din) to be written to the FIFO Must be held
                                     // active-low when rst or wr_rst_busy or rd_rst_busy is active high
   );
endmodule
