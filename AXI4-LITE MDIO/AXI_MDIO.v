`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/16 18:41:33
// Design Name: 
// Module Name: AXI_MDIO
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


module AXI_MDIO #(
        parameter integer ADDR_WIDTH = 12,
        parameter integer DATA_WIDTH = 32,
        parameter integer PHY_ADDR   = 5'b00101,
        parameter integer AXI_CLK_FREQ_HZ = 100_000_000,
        parameter integer MDC_CLK_FREQ_HZ = 1_000_000
)
(       // Global Signals
        input  wire                     S_AXI_ACLK,
        input  wire                     S_AXI_ARESETN,
        // AW Channel
        input  wire [ADDR_WIDTH-1:0]    S_AXI_AWADDR,
        input  wire [2:0]               S_AXI_AWPROT,
        input  wire                     S_AXI_AWVALID,
        output wire                     S_AXI_AWREADY,
        // W Channel
        input  wire [DATA_WIDTH-1:0]    S_AXI_WDATA,
        input  wire [DATA_WIDTH/8-1:0]  S_AXI_WSTRB,
        input  wire                     S_AXI_WVALID,
        output wire                     S_AXI_WREADY,
        // B Channel
        output wire [1:0]               S_AXI_BRESP,
        output wire                     S_AXI_BVALID,
        input  wire                     S_AXI_BREADY,
        // AR Channel
        input  wire [ADDR_WIDTH-1:0]    S_AXI_ARADDR,
        input  wire [2:0]               S_AXI_ARPROT,
        input  wire                     S_AXI_ARVALID,
        output wire                     S_AXI_ARREADY,
        // R Channel
        output wire [DATA_WIDTH-1:0]    S_AXI_RDATA,
        output wire [1:0]               S_AXI_RRESP,
        output wire                     S_AXI_RVALID,
        input  wire                     S_AXI_RREADY,
        // MDIO Interface
        output MDC,
        input  MDIO_I,
        output MDIO_O,
        output MDIO_T,
        input  Interrupt_n,
        output Reset_n
    );
    // Reset PHY 50ms (after power up or assert S_AXI_ARESETN)
    reg [31:0] reset_counter;
    initial begin
        reset_counter <= 32'h0000_0000;
    end
    always @(posedge S_AXI_ACLK) begin
        if(!S_AXI_ARESETN)
        begin
            reset_counter <= 32'h0000_0000;
        end
        else
        begin
            if(reset_counter != 32'd5_000)
            begin
                reset_counter <= reset_counter + 1'b1;
            end
            else if(reset_counter == 32'd5_000)
            begin
                reset_counter <= reset_counter;
            end
        end
    end
    assign Reset_n = (reset_counter == 32'd5_000);
    // AXI State Machine
    localparam OKAY     = 2'b00;
    localparam EXOKAY   = 2'b01;
    localparam SLVERR   = 2'b10;
    localparam DECERR   = 2'b11;
    
    reg [3:0]            axi_state;
    reg                  s_axi_awready;
    reg                  s_axi_wready;
    reg                  s_axi_bvalid;
    reg [1:0]            s_axi_bresp;
    reg                  s_axi_arready;
    reg [DATA_WIDTH-1:0] s_axi_rdata;
    reg                  s_axi_rvalid;
    reg [1:0]            s_axi_rresp;

    assign      S_AXI_AWREADY = s_axi_awready;
    assign      S_AXI_WREADY  = s_axi_wready;
    assign      S_AXI_BVALID  = s_axi_bvalid;
    assign      S_AXI_BRESP   = s_axi_bresp;
    assign      S_AXI_ARREADY = s_axi_arready;
    assign      S_AXI_RDATA   = s_axi_rdata;
    assign      S_AXI_RRESP   = s_axi_rresp;
    assign      S_AXI_RVALID  = s_axi_rvalid;
    wire        w_handshake   = S_AXI_WREADY  && S_AXI_WVALID;
    wire        aw_handshake  = S_AXI_AWREADY && S_AXI_AWVALID;
    wire        b_handshake   = S_AXI_BVALID  && S_AXI_BREADY;
    wire        ar_handshake  = S_AXI_ARVALID && S_AXI_ARREADY;
    wire        r_handshake   = S_AXI_RVALID  && S_AXI_RREADY;

    reg [4:0]   wr_addr;
    reg [4:0]   rd_addr;
    reg [15:0]  wr_data;
    reg [15:0]  rd_data;
    reg [4:0]   phy_addr;

    reg         rd_begin_flag;
    reg         rd_finish_flag;
    reg         wr_begin_flag;
    reg         wr_finish_flag;
    reg         arbitration_flag;

    always @(posedge S_AXI_ACLK ) begin
        if(!S_AXI_ARESETN)
        begin
            axi_state        <= 4'd0;
            s_axi_awready    <= 1'b0;
            s_axi_wready     <= 1'b0;
            s_axi_bvalid     <= 1'b0;
            s_axi_arready    <= 1'b0;
            s_axi_rvalid     <= 1'b0;
            s_axi_rdata      <= 32'h0000_0000;
            s_axi_rresp      <= OKAY;
            s_axi_bresp      <= OKAY; 
            wr_addr          <= 5'd0;
            rd_addr          <= 5'd0;
            wr_data          <= 16'd0;
            phy_addr         <= PHY_ADDR;
            rd_begin_flag    <= 1'b0;
            wr_begin_flag    <= 1'b0; 
            arbitration_flag <= 1'b0;
        end
        else
        begin
            case(axi_state)
            4'd0:
            begin
                s_axi_awready <= 1'b1;
                s_axi_arready <= 1'b1;
                axi_state     <= 4'd1;
            end
            4'd1:
            begin
                if(aw_handshake && ar_handshake)
                begin
                    s_axi_awready     <= 1'b0;
                    wr_addr           <= S_AXI_AWADDR[2 +: 5];
                    s_axi_arready     <= 1'b0;
                    arbitration_flag  <= 1'b1;
                end
                else
                begin
                    if(aw_handshake)
                    begin
                            s_axi_awready <= 1'b0;
                            axi_state     <= 4'd2;
                            wr_addr       <= S_AXI_AWADDR[2 +: 5];
                            s_axi_arready <= 1'b0;
                            s_axi_wready  <= 1'b1;
                    end
                    else if(ar_handshake)
                    begin
                        s_axi_arready <= 1'b0;
                        s_axi_awready <= 1'b0;
                        if(S_AXI_ARADDR[1:0] == 2'b00)
                        begin
                            rd_addr       <= S_AXI_ARADDR[2 +: 5];
                            if(rd_begin_flag == 1'b0)
                            begin
                                rd_begin_flag <= 1'b1;
                            end
                        end
                        else
                        begin
                            s_axi_rvalid <= 1'b1;
                            s_axi_rresp  <= SLVERR;
                        end
                    end
                    if(rd_begin_flag == 1'b1)
                    begin
                        rd_begin_flag <= 1'b0;
                        axi_state     <= 4'd3;
                    end
                    if(r_handshake)
                    begin
                        s_axi_rvalid <= 1'b0;
                        s_axi_rresp  <= OKAY;
                        axi_state    <= 4'd0;
                    end
                end
                if(arbitration_flag == 1'b1)
                begin
                    s_axi_rvalid <= 1'b1;
                    s_axi_rresp  <= SLVERR;
                    if(r_handshake)
                    begin
                        s_axi_rvalid     <= 1'b0;
                        s_axi_rresp      <= OKAY;
                        axi_state        <= 4'd2;
                        s_axi_wready     <= 1'b1;
                        arbitration_flag <= 1'b0;
                    end
                end
            end
            4'd2:
            begin
                if(w_handshake)
                begin
                    s_axi_wready  <= 1'b0;
                    wr_data       <= S_AXI_WDATA[0 +: 16];
                    if(S_AXI_AWADDR[1:0] == 2'b00)
                    begin
                        if(wr_begin_flag == 1'b0)
                        begin
                            wr_begin_flag <= 1'b1;
                        end    
                    end
                    else
                    begin
                        s_axi_bvalid  <= 1'b1;
                        s_axi_bresp   <= SLVERR;
                    end
                end
                if(wr_begin_flag == 1'b1)
                begin
                    wr_begin_flag <= 1'b0;
                    axi_state     <= 4'd4;                   
                end
                if(b_handshake)
                begin
                    s_axi_bvalid <= 1'b0;
                    axi_state    <= 4'd0;
                    s_axi_bresp  <= OKAY;
                end
            end
            4'd3:
            begin
                if(rd_finish_flag)
                begin
                    s_axi_rvalid <= 1'b1;
                    s_axi_rdata  <= {16'h0000,rd_data};
                    s_axi_rresp  <= OKAY;
                    axi_state    <= 4'd5;
                end
            end
            4'd4:
            begin
                if(wr_finish_flag)
                begin
                    s_axi_bvalid <= 1'b1;
                    s_axi_bresp  <= OKAY;
                    axi_state    <= 4'd6;
                end  
            end
            4'd5:
            begin
                if(r_handshake)
                begin
                    s_axi_rvalid <= 1'b0;
                    axi_state    <= 4'd0;
                end
            end
            4'd6:
            begin
                if(b_handshake)
                begin
                    s_axi_bvalid <= 1'b0;
                    axi_state    <= 4'd1;
                end
            end
            endcase
        end
    end
    // MDC Generator
    reg                mdc_state;
    reg                mdc;
    reg [7:0]          mdc_clk_counter;
    localparam integer MDC_HALF_PERIOD_CYCLES = AXI_CLK_FREQ_HZ / (2 * MDC_CLK_FREQ_HZ);
    localparam integer MDC_PERIOD_CYCLES      = AXI_CLK_FREQ_HZ / MDC_CLK_FREQ_HZ;
    localparam integer MDC_RISING_COUNT       = MDC_HALF_PERIOD_CYCLES - 1;
    localparam integer MDC_FALLING_COUNT      = MDC_PERIOD_CYCLES - 1;
    assign             MDC = mdc;
    always @(posedge S_AXI_ACLK ) begin
        if(!S_AXI_ARESETN)begin
            mdc                 <= 1'b0;
            mdc_clk_counter     <= 8'd0;
            mdc_state           <= 1'b0;
        end
        else
        begin
            case(mdc_state)
            1'b0:
            begin
                mdc_clk_counter <= 8'd0;
                mdc             <= 1'b0;
                if(wr_begin_flag || rd_begin_flag)
                begin
                    mdc_state <= 1'b1;
                end
            end
            1'b1:
            begin
                if(mdc_clk_counter == MDC_FALLING_COUNT)
                begin
                    mdc_clk_counter <= 8'd0;
                    mdc             <= ~mdc;
                end
                else if(mdc_clk_counter == MDC_RISING_COUNT)
                begin
                    mdc             <= ~mdc;
                    mdc_clk_counter <= mdc_clk_counter + 8'd1;
                end
                else
                begin
                    mdc_clk_counter <= mdc_clk_counter + 8'd1;  
                end
                if(wr_finish_flag || rd_finish_flag)
                begin
                    mdc_state <= 1'b0;
                end
            end
            endcase
        end
    end
    // MDIO Transaction Generator
        reg [3:0]  state;
        reg        mdio_oe;
        reg        mdio;
        reg [5:0]  PRE_counter;
        reg [4:0]  bit_counter;
        reg        wr_flag;
        reg        rd_flag;
        reg        rd_wait;
        assign     MDIO_O = mdio;
        assign     MDIO_T = ~mdio_oe;
        always @(posedge S_AXI_ACLK ) begin
            if(!S_AXI_ARESETN)begin
                state             <= 4'd0;
                mdio_oe           <= 1'b0;
                mdio              <= 1'b1;
                PRE_counter       <= 6'd0;
                bit_counter       <= 5'd0;
                rd_data           <= 16'd0;
                rd_wait           <= 1'b0;
                wr_finish_flag    <= 1'b0;
                rd_finish_flag    <= 1'b0;
                wr_flag           <= 1'b0;
                rd_flag           <= 1'b0;
            end
            else
            begin
                case(state)
                4'd0:
                begin
                    if(wr_begin_flag)
                    begin
                        mdio_oe        <= 1'b1;
                        wr_flag        <= 1'b1;
                    end
                    else if(rd_begin_flag)
                    begin
                        mdio_oe        <= 1'b1;
                        rd_flag        <= 1'b1;
                    end
                    if((wr_flag == 1'b1))
                    begin
                        if(mdc_clk_counter == MDC_RISING_COUNT)
                        begin
                            PRE_counter <= PRE_counter + 1'b1;
                        end 
                        if(PRE_counter == 6'd32)
                        begin
                            state       <= 4'd1;
                            PRE_counter <= 6'd0;
                        end
                    end
                    else if((rd_flag == 1'b1))
                    begin
                        if(mdc_clk_counter == MDC_RISING_COUNT)
                        begin
                            PRE_counter <= PRE_counter + 1'b1;
                        end 
                        if(PRE_counter == 6'd32)
                        begin
                            state       <= 4'd1;
                            PRE_counter <= 6'd0;
                        end                        
                    end
                end
                4'd1:
                begin
                    if(wr_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT && mdio == 1'b1)
                        begin
                            mdio <= 1'b0;
                        end
                        else if(mdc_clk_counter == MDC_FALLING_COUNT && mdio == 1'b0)
                        begin
                            mdio  <= 1'b1;
                            state <= 4'd2;
                        end                        
                    end
                    else if(rd_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT && mdio == 1'b1)
                        begin
                            mdio <= 1'b0;
                        end
                        else if(mdc_clk_counter == MDC_FALLING_COUNT && mdio == 1'b0)
                        begin
                            mdio  <= 1'b1;
                            state <= 4'd2;
                        end                            
                    end
                end
                4'd2:
                begin
                    if(wr_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT && mdio == 1'b1)
                        begin
                            mdio <= 1'b0;
                        end
                        else if(mdc_clk_counter == MDC_FALLING_COUNT && mdio == 1'b0)
                        begin
                            mdio     <= 1'b1;
                            state    <= 4'd3;
                        end
                    end
                    else if(rd_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT && bit_counter == 5'd0)
                        begin
                            mdio <= 1'b1;
                            bit_counter <= bit_counter + 1'b1;
                        end
                        else if(mdc_clk_counter == MDC_FALLING_COUNT && bit_counter == 5'd1)
                        begin
                            bit_counter <= 5'd0;
                            mdio        <= 1'b0;
                            state       <= 4'd3;
                        end                        
                    end
                end
                4'd3:
                begin
                    if(wr_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            mdio            <= phy_addr[4 - bit_counter];
                            bit_counter     <= bit_counter + 1'b1;
                            if(bit_counter == 5'd4)
                            begin
                                bit_counter <= 5'd0;
                                state       <= 4'd4;
                            end
                        end
                    end
                    else if(rd_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            mdio            <= phy_addr[4 - bit_counter];
                            bit_counter     <= bit_counter + 1'b1;
                            if(bit_counter == 5'd4)
                            begin
                                bit_counter <= 5'd0;
                                state       <= 4'd4;
                            end
                        end                       
                    end
                end
                4'd4:
                begin
                    if(wr_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            mdio            <= wr_addr[4 - bit_counter];
                            bit_counter     <= bit_counter + 1'b1;
                            if(bit_counter == 5'd4)
                            begin
                                bit_counter <= 5'd0;
                                state       <= 4'd5;
                            end
                        end
                    end
                    else if(rd_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            mdio            <= rd_addr[4 - bit_counter];
                            bit_counter     <= bit_counter + 1'b1;
                            if(bit_counter == 5'd4)
                            begin
                                bit_counter <= 5'd0;
                                state       <= 4'd5;
                            end
                        end                        
                    end
                end
                4'd5:
                begin
                    if(wr_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            if(bit_counter == 5'd0)
                            begin
                                mdio <= 1'b1;
                                bit_counter <= bit_counter + 1'b1;
                            end
                            else if(bit_counter == 5'd1)
                            begin
                                mdio        <= 1'b0;
                                state       <= 4'd6;
                                bit_counter <= 5'd0;
                            end
                        end   
                    end
                    else if(rd_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            if(bit_counter == 5'd0)
                            begin
                                mdio        <= 1'b1;
                                mdio_oe     <= 1'b0;
                                bit_counter <= bit_counter + 1'b1;
                            end
                            else if(bit_counter == 5'd1)
                            begin
                                state       <= 4'd6;
                                bit_counter <= 5'd0;
                            end
                        end 
                    end
                end
                4'd6:
                begin
                    if(wr_flag)
                    begin
                    if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            mdio            <= wr_data[15 - bit_counter];
                            bit_counter     <= bit_counter + 1'b1;
                            if(bit_counter == 5'd15)
                            begin
                                bit_counter <= 5'd0;
                                state       <= 4'd7;
                            end
                        end
                    end
                    else if(rd_flag)
                    begin
                    if(mdc_clk_counter == MDC_RISING_COUNT)
                        begin
                            if(rd_wait == 1'b0)
                            begin
                                rd_wait <= 1'b1;
                            end
                            else
                            begin
                                rd_data[15 - bit_counter]   <= MDIO_I;
                                bit_counter                 <= bit_counter + 1'b1;
                                if(bit_counter == 5'd15)
                                begin
                                    bit_counter <= 5'd0;
                                    state       <= 4'd7;
                                    rd_wait     <= 1'b0;
                                end
                            end
                        end                        
                    end
                end
                4'd7:
                begin
                    if(wr_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            mdio              <= 1'b1;
                            state             <= 4'd8;
                            wr_finish_flag    <= 1'b1;
                        end 
                    end
                    else if(rd_flag)
                    begin
                        if(mdc_clk_counter == MDC_FALLING_COUNT)
                        begin
                            mdio              <= 1'b1;
                            state             <= 4'd8;
                            rd_finish_flag    <= 1'b1;
                        end                        
                    end
                end
                4'd8:
                begin
                    if(wr_flag)
                    begin
                        wr_finish_flag <= 1'b0;
                        state          <= 4'd0;
                        mdio_oe        <= 1'b0;
                        wr_flag        <= 1'b0;
                    end
                    else if(rd_flag)
                    begin
                        rd_finish_flag <= 1'b0;
                        mdio_oe        <= 1'b0;
                        state          <= 4'd0;  
                        rd_flag        <= 1'b0;                  
                    end
                end
                endcase
            end
        end

endmodule