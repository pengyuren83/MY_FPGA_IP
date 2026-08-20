`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/12 15:58:14
// Design Name: 
// Module Name: uart_wrapper
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


module uart_wrapper #(
    parameter integer BAUD_RATE  = 115200,
    parameter integer CLOCK_FREQ = 100000000,
    parameter         DATA_WIDTH = 8,
    parameter         PARITY     = "EVEN"
)
(
    input clk,
    input rstn,
    // FIFO Interface
    output reg       start_read_fifo,
    output reg       start_write_fifo,
    input  [7:0]     data_read_fifo,
    output reg [7:0] data_write_fifo,
    input  [1:0]     status_read_fifo,
    input  [1:0]     status_write_fifo,
    // UART Interface
    input  rx_o,
    output tx_o,
    // Status Signals
    output parity_error
);
    // Baud Rate Generator
    localparam [31:0] FCW = (BAUD_RATE * (64'd1 << 32) + CLOCK_FREQ/2)/CLOCK_FREQ;
    reg [32:0] phase_accumulator;
    wire       baud_tick;
    always @(posedge clk ) 
    begin
        if(!rstn)
        begin
            phase_accumulator <= 33'd0;
        end
        else
        begin
            phase_accumulator <= {1'b0,phase_accumulator[31:0]}+ FCW;
        end
    end
    assign baud_tick = phase_accumulator[32];
    reg [32:0] phase_accumulator_rx;
    wire       baud_tick_rx;
    reg        phase_accumulator_rx_rstn;
    always @(posedge clk ) 
    begin
        if(!rstn)
        begin
            phase_accumulator_rx <= 33'h080000000;
        end
        else if(!phase_accumulator_rx_rstn)
        begin
            phase_accumulator_rx <= 33'h080000000;
        end
        else
        begin
            phase_accumulator_rx <= {1'b0,phase_accumulator_rx[31:0]}+ FCW;
        end
    end
    assign baud_tick_rx = phase_accumulator_rx[32];
    // TX Machine
    localparam [3:0] READ_FROM_FIFO        = 4'b0000;
    localparam [3:0] CHECK_STATUS          = 4'b0001;
    localparam [3:0] START_BIT             = 4'b0010;
    localparam [3:0] DATA_BITS             = 4'b0011;
    localparam [3:0] PARITY_BIT            = 4'b0100;
    localparam [3:0] STOP_BIT              = 4'b0101;
    localparam [1:0] PARITY_NONE           = 2'b00;
    localparam [1:0] PARITY_EVEN           = 2'b01;
    localparam [1:0] PARITY_ODD            = 2'b10;
    
    reg [1:0]            parity_mode;
    reg [DATA_WIDTH-1:0] tx_data;
    reg [3:0]            tx_state;
    reg                  tx_d;
    reg [3:0]            tx_bit_counter;
    reg [1:0]            delay_counter;
    assign               tx_o = tx_d;
    wire [1:0]           parity_mode_wire;

    generate
        if(PARITY == "NONE")
            assign parity_mode_wire = PARITY_NONE;
        else if(PARITY == "EVEN")
            assign parity_mode_wire = PARITY_EVEN;
        else if(PARITY == "ODD")
            assign parity_mode_wire = PARITY_ODD;
    endgenerate

    always @(posedge clk ) begin
        if(!rstn)
        begin
            parity_mode     <= parity_mode_wire;
            tx_data         <= {DATA_WIDTH{1'b0}};
            tx_state        <= READ_FROM_FIFO;
            tx_d            <= 1'b1;
            tx_bit_counter  <= 4'd0;
            start_read_fifo <= 1'b0;
            delay_counter   <= 2'd0;
        end
        else
        begin
            case(tx_state)
            READ_FROM_FIFO:
            begin
                start_read_fifo <= 1'b1;
                if(delay_counter == 2'b11)
                begin
                    tx_state        <= CHECK_STATUS;
                    delay_counter   <= 2'd0;
                end
                else
                begin
                    delay_counter <= delay_counter + 2'b01;
                end
            end
            CHECK_STATUS:
            begin
                if(status_read_fifo == 2'b10)
                begin
                    tx_data         <= data_read_fifo[DATA_WIDTH-1:0];
                    tx_state        <= START_BIT;
                    start_read_fifo <= 1'b0;
                end
                else if(status_read_fifo == 2'b01)
                begin
                    start_read_fifo <= 1'b0;
                    tx_state        <= READ_FROM_FIFO;
                end
            end
            START_BIT:
            begin
                if(baud_tick)
                begin
                    tx_d     <= 1'b0;
                    tx_state <= DATA_BITS;
                end
            end
            DATA_BITS:
            begin
                if(baud_tick)
                begin
                    if(tx_bit_counter == DATA_WIDTH-1)
                    begin
                        tx_d           <= tx_data[tx_bit_counter];
                        tx_bit_counter <= tx_bit_counter + 1'b1;
                    end
                    else if(tx_bit_counter == DATA_WIDTH)
                    begin
                        if(parity_mode == PARITY_NONE)
                        begin
                            tx_state       <= STOP_BIT;
                            tx_bit_counter <= 4'd0;
                            tx_d           <= 1'b1;
                        end
                        else 
                        begin
                            tx_state       <= PARITY_BIT;
                            tx_bit_counter <= 4'd0;
                            if(parity_mode == PARITY_EVEN)
                                tx_d <= ^tx_data;
                            else if(parity_mode == PARITY_ODD)
                                tx_d <= ~^tx_data;
                        end
                    end
                    else 
                    begin
                        tx_d           <= tx_data[tx_bit_counter];
                        tx_bit_counter <= tx_bit_counter + 1'b1;
                    end
                end
            end
            PARITY_BIT:
            begin
                if(baud_tick)
                begin
                    tx_state <= STOP_BIT;
                    tx_d     <= 1'b1;
                end
            end
            STOP_BIT:
            begin
                if(baud_tick)
                begin
                    tx_d          <= 1'b1;
                    tx_state      <= READ_FROM_FIFO;
                end
            end    
            default: 
            begin
                    tx_state      <= READ_FROM_FIFO;   
            end
            endcase
        end
    end

    // RX Machine
    localparam [3:0] WAIT_START_BIT        = 4'b0000;
    localparam [3:0] GET_BITS              = 4'b0001;
    localparam [3:0] CHECK_PARITY          = 4'b0010;
    localparam [3:0] WRITE_TO_FIFO         = 4'b0011;
    localparam [3:0] CHECK_RXFIFO_STATUS   = 4'b0100;

    reg        [3:0] rx_state;
    reg        [3:0] rx_bit_counter;
    reg        [DATA_WIDTH+2:0] rx_data;
    reg        [1:0] delay_counter_rx;
    reg        parity_error_reg;
    assign     parity_error = parity_error_reg;

    always @(posedge clk ) begin
        if(!rstn)
        begin
            rx_state                  <= WAIT_START_BIT;
            rx_bit_counter            <= 4'd0;
            rx_data                   <= {DATA_WIDTH+3{1'b0}};
            phase_accumulator_rx_rstn <= 1'b0;
            data_write_fifo           <= {DATA_WIDTH{1'b0}};
            start_write_fifo          <= 1'b0;
            delay_counter_rx          <= 2'd0;
            parity_error_reg          <= 1'b0;
        end
        else
        begin
            case(rx_state)
                WAIT_START_BIT:
                begin
                    if(!rx_o)
                    begin
                        phase_accumulator_rx_rstn <= 1'b1;
                        rx_state                  <= GET_BITS;
                    end
                end
                GET_BITS:
                begin
                    if(baud_tick_rx)
                    begin
                        rx_data[rx_bit_counter] <= rx_o;
                        if(parity_mode == PARITY_NONE)
                        begin
                            if(rx_bit_counter == DATA_WIDTH+1)
                            begin
                                rx_bit_counter            <= 4'd0;
                                phase_accumulator_rx_rstn <= 1'b0;
                                rx_state                  <= WRITE_TO_FIFO;
                            end
                            else
                            begin
                                rx_bit_counter            <= rx_bit_counter + 1'b1;
                            end
                        end
                        else
                        begin
                            if(rx_bit_counter == DATA_WIDTH+2)
                            begin
                                rx_bit_counter            <= 4'd0;
                                phase_accumulator_rx_rstn <= 1'b0;
                                rx_state                  <= CHECK_PARITY;
                            end
                            else
                            begin
                                rx_bit_counter            <= rx_bit_counter + 1'b1;
                            end
                        end
                    end
                end
                CHECK_PARITY:
                begin
                    if((parity_mode == PARITY_EVEN))
                    begin
                        if((rx_data[DATA_WIDTH+1] != ^rx_data[DATA_WIDTH:1]))
                        begin
                            if(delay_counter_rx == 2'b11)
                            begin
                                rx_state         <= WAIT_START_BIT;
                                delay_counter_rx <= 2'd0;
                                parity_error_reg <= 1'b0;
                            end
                            else
                            begin
                                delay_counter_rx <= delay_counter_rx + 2'b01;
                                parity_error_reg <= 1'b1;
                            end
                        end
                        else
                        begin
                            rx_state <= WRITE_TO_FIFO;
                        end
                    end
                    else if(parity_mode == PARITY_ODD)
                    begin
                        if((rx_data[DATA_WIDTH+1] != ~^rx_data[DATA_WIDTH:1]))
                        begin
                            if(delay_counter_rx == 2'b11)
                            begin
                                rx_state         <= WAIT_START_BIT;
                                delay_counter_rx <= 2'd0;
                                parity_error_reg <= 1'b0;
                            end
                            else
                            begin
                                delay_counter_rx <= delay_counter_rx + 2'b01;
                                parity_error_reg <= 1'b1;
                            end
                        end
                        else
                        begin
                            rx_state <= WRITE_TO_FIFO;
                        end
                    end
                end
                WRITE_TO_FIFO:
                begin
                    start_write_fifo <= 1'b1;
                    data_write_fifo  <= rx_data[DATA_WIDTH:1];
                    if(delay_counter_rx == 2'b11)
                    begin
                        rx_state          <= CHECK_RXFIFO_STATUS;
                        delay_counter_rx  <= 2'd0;
                    end
                    else
                    begin
                        delay_counter_rx  <= delay_counter_rx + 2'b01;
                    end
                end
                CHECK_RXFIFO_STATUS:
                begin
                    if(status_write_fifo == 2'b10)
                    begin
                        start_write_fifo <= 1'b0;
                        rx_state         <= WAIT_START_BIT;
                    end
                    else if(status_write_fifo == 2'b01)
                    begin
                        start_write_fifo <= 1'b0;
                        rx_state         <= WAIT_START_BIT;
                    end
                end
                default:
                begin
                        rx_state         <= WAIT_START_BIT;
                end
            endcase
        end
    end





endmodule
