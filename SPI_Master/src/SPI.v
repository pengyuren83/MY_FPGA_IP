`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/07/24 11:10:53
// Design Name: 
// Module Name: SPI_RECFG_NCO
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


module SPI #(
    parameter integer SCLK_DIV      =  10,
    parameter integer FRAME_WIDTH   =  32,
    parameter integer DATA_WIDTH    =  24,
    parameter integer CMD_WRITE     =  1'b0,
    parameter integer CMD_READ      =  1'b1,
    parameter integer CPOL          =  1'b0,
    parameter integer CPHA          =  1'b1
    )
    (
    input           clock_i,
    input           rst_n_i,
    input           data_wr_valid_i,
    input   [31:0]  data_i,
    output          cs_n_o,
    output  [31:0]  status_o,
    output  [31:0]  data_o,
    output          sclk_o,
    input           sdi,
    output          sdo_o
    );
    // parameters
    localparam         IDLE  	 		 = 8'b0000_0000_0000_0001;
    localparam         WAIT              = 8'b0000_0000_0000_0010;
    localparam         SEND_ADDR         = 8'b0000_0000_0000_0100;
    localparam         SEND_DATA         = 8'b0000_0000_0000_1000;
    localparam         RECEIVE_DATA      = 8'b0000_0000_0001_0000;
    localparam         DONE              = 8'b0000_0000_0010_0000;
    localparam integer SCLK_HALF_DIV     = SCLK_DIV / 2;
    // Write or Read Tranaction Generate
    reg data_wr_valid_d;
    reg data_wr_valid_d2;
    wire data_wr_valid_pulse;
    always @(posedge clock_i) begin
        if(!rst_n_i) begin
            data_wr_valid_d <= 1'b0;
            data_wr_valid_d2 <= 1'b0;
        end else begin
            data_wr_valid_d <= data_wr_valid_i;
            data_wr_valid_d2 <= data_wr_valid_d;
        end
    end
    assign data_wr_valid_pulse = data_wr_valid_d & ~data_wr_valid_d2;
    // SPI SCLK Generate
    reg [7:0] sclk_counter;
    reg       SCLK_delay;
    reg       SCLK;
    reg       SCLK_d;
    wire      SCLK_rising_edge;
    wire      SCLK_falling_edge;
    wire      sample_edge;
    wire      shift_edge;
    always @(posedge clock_i) begin
        if(!rst_n_i) begin
            sclk_counter        <= 8'd0;
            SCLK                <= CPOL;
        end
        else
        begin
            if(state == RECEIVE_DATA || state == SEND_DATA || state == SEND_ADDR)
            begin
                if(SPI_MODE[0] == 1'b0)
                begin
                    if((bit_counter == DATA_WIDTH-1)&&(shift_edge))
                    begin
                        SCLK         <= CPOL;
                        sclk_counter <= 8'd0;
                    end
                    else
                    begin
                        if(sclk_counter == SCLK_HALF_DIV-1)
                        begin
                            SCLK         <= ~SCLK;
                            sclk_counter <= 8'd0;
                        end
                        else
                        begin
                            sclk_counter <= sclk_counter + 1'b1;
                        end
                    end
                end
                else if(SPI_MODE[0] == 1'b1)
                begin
                    if((bit_counter == DATA_WIDTH-1)&&(sample_edge))
                    begin
                        SCLK         <= CPOL;
                        sclk_counter <= 8'd0;
                    end
                    else
                    begin
                        if(sclk_counter == SCLK_HALF_DIV-1)
                        begin
                            SCLK         <= ~SCLK;
                            sclk_counter <= 8'd0;
                        end
                        else
                        begin
                            sclk_counter <= sclk_counter + 1'b1;
                        end
                    end               
                end
            end
            else
            begin
                        SCLK         <= CPOL;
                        sclk_counter <= 8'd0;
            end
        end
    end
    always @(posedge clock_i) begin
        if(!rst_n_i) begin
            SCLK_delay <= CPOL;
        end else begin
            SCLK_delay <= SCLK;
        end
    end
    assign SCLK_rising_edge  = (SCLK == 1'b1) && (SCLK_delay == 1'b0);
    assign SCLK_falling_edge = (SCLK == 1'b0) && (SCLK_delay == 1'b1);
    // SPI MODE
    wire [1:0] SPI_MODE;
    assign SPI_MODE = {CPOL, CPHA};
    assign shift_edge  = (SPI_MODE == 2'b00) ? SCLK_falling_edge :
                         (SPI_MODE == 2'b01) ? SCLK_rising_edge :
                         (SPI_MODE == 2'b10) ? SCLK_rising_edge :
                         (SPI_MODE == 2'b11) ? SCLK_falling_edge : 1'b0;
    assign sample_edge = (SPI_MODE == 2'b00) ? SCLK_rising_edge :
                         (SPI_MODE == 2'b01) ? SCLK_falling_edge :
                         (SPI_MODE == 2'b10) ? SCLK_falling_edge :
                         (SPI_MODE == 2'b11) ? SCLK_rising_edge : 1'b0;
            
    // SPI Transaction State Machine
    reg [FRAME_WIDTH-1:0]  data_i_d;
    reg [7:0]              state;
    reg                    CS_n;
    reg                    MOSI;
    reg                    write_done;
    reg                    read_done;
    reg                    write_finish;
    reg                    read_finish;
    reg [DATA_WIDTH-1:0]   data_o_d;
    reg [7:0]              wait_counter;
    reg                    wr_type;  
    reg                    CPHA_d;   
    reg [7:0]              bit_counter;      
    wire                   MISO;

    assign      MISO          = sdi;
    assign      sdo_o         = MOSI;
    assign      sclk_o        = SCLK_delay;
    assign      cs_n_o        = CS_n;
    assign      status_o      = {30'd0, read_done, write_done};
    assign      data_o        = {{(FRAME_WIDTH-DATA_WIDTH){1'b0}}, data_o_d};
	always @(posedge clock_i)
	begin
		if(!rst_n_i)
		begin
			state 			    <= IDLE;
			write_done 			<= 1'b0;
            read_done           <= 1'b0;
			MOSI 				<= 1'b0;
			CS_n 				<= 1'b1;
            data_o_d            <= {DATA_WIDTH{1'b0}};
            wait_counter        <= 8'd0;
            CPHA_d              <= CPHA;
            bit_counter         <= 8'd0;
            data_i_d            <= {FRAME_WIDTH{1'b0}};
            write_finish        <= 1'b0;
            read_finish         <= 1'b0;
		end
		else
		begin
			case(state)
				IDLE:
				begin
                    if(data_wr_valid_pulse)
                    begin
                        data_i_d            <= data_i;
                        CS_n                <= 1'b0;
                        write_done          <= 1'b0;
                        read_done           <= 1'b0;
                        wr_type             <= data_i[FRAME_WIDTH-1];
                        state               <= WAIT;
                        wait_counter        <= 8'd0;
                        write_finish        <= 1'b0;
                        read_finish         <= 1'b0;
                    end
				end
                WAIT:
                begin
                    if(wait_counter == 8'd100)
                    begin
                        state               <= SEND_ADDR;
                        wait_counter        <= 8'd0;
                    end
                    else
                    begin
                        wait_counter        <= wait_counter + 1'b1;
                    end

                    if(CPHA_d == 1'b0)
                    begin
                        MOSI                <= data_i_d[FRAME_WIDTH-1];
                    end
                end
                SEND_ADDR:
                begin
                    if(wr_type == CMD_WRITE)
                    begin
                    if(shift_edge)
                    begin
                        MOSI         <= data_i_d[FRAME_WIDTH-1-bit_counter];
                    end
                    else if(sample_edge)
                    begin
                        if(bit_counter == FRAME_WIDTH-DATA_WIDTH-1)
                        begin
                            bit_counter  <= 8'd0;
                            state        <= SEND_DATA;
                        end
                        else
                        begin
                            bit_counter  <= bit_counter + 8'd1;
                        end
                    end
                    end
                    else if(wr_type == CMD_READ)
                    begin
                    if(shift_edge)
                    begin
                        MOSI         <= data_i_d[FRAME_WIDTH-1-bit_counter];
                    end
                    else if(sample_edge)
                    begin
                        if(bit_counter == FRAME_WIDTH-DATA_WIDTH-1)
                        begin
                            bit_counter  <= 8'd0;
                            state        <= RECEIVE_DATA;
                        end
                        else
                        begin
                            bit_counter  <= bit_counter + 8'd1;
                        end
                    end
                    end
                end
                SEND_DATA:
                begin
                    if(sample_edge)
                    begin
                        if(bit_counter == DATA_WIDTH-1)
                        begin
                            bit_counter                        <= 8'd0;
                            write_finish                       <= 1'b1;
                            if(SPI_MODE[0] == 1'b1)
                            begin
                                state <= DONE;
                            end
                        end
                        else
                        begin
                            bit_counter  <= bit_counter + 8'd1;
                        end
                    end
                    else if(shift_edge)
                    begin
                        if((SPI_MODE[0] == 1'b0)&&(write_finish))
                        begin
                            state <= DONE;
                        end
                        MOSI  <= data_i_d[DATA_WIDTH-1-bit_counter];
                    end           
                end
                RECEIVE_DATA:
                begin
                    if(sample_edge)
                    begin
                        MOSI <= 1'b0;
                        if(bit_counter == DATA_WIDTH-1)
                        begin
                            bit_counter                        <= 8'd0;
                            read_finish                        <= 1'b1;
                            data_o_d[DATA_WIDTH-1-bit_counter] <= MISO;
                            if(SPI_MODE[0] == 1'b1)
                            begin
                                state <= DONE;
                            end
                        end
                        else
                        begin
                            data_o_d[DATA_WIDTH-1-bit_counter] <= MISO;
                            bit_counter  <= bit_counter + 8'd1;
                        end
                    end
                    else if(shift_edge)
                    begin
                        MOSI <= 1'b0;
                        if((SPI_MODE[0] == 1'b0)&&(read_finish))
                        begin
                            state <= DONE;
                        end
                    end
                end
                DONE:
                begin
                    if(wait_counter == 8'd100)
                    begin
                        state               <= IDLE;
                        write_done          <= write_finish;
                        read_done           <= read_finish;
                        CS_n                <= 1'b1;
                        wait_counter        <= 8'd0;
                    end
                    else
                    begin
                        wait_counter        <= wait_counter + 1'b1;
                    end
                end
			default:
                begin
                    state 		<= IDLE;
                end
			endcase
		end
	end
endmodule
