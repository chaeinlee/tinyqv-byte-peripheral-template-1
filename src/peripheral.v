/*
 * Copyright (c) 2025 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Change the name of this module to something that reflects its functionality and includes your name for uniqueness
// For example tqvp_yourname_spi for an SPI peripheral.
// Then edit tt_wrapper.v line 38 and change tqvp_example to your chosen module name.
module tqvp_example (
    input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input         rst_n,        // Reset_n - low to reset.

    input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                                // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.

    output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                // Note that uo_out[0] is normally used for UART TX.

    input [3:0]   address,      // Address within this peripheral's address space

    input         data_write,   // Data write request from the TinyQV core.
    input [7:0]   data_in,      // Data in to the peripheral, valid when data_write is high.
    
    output [7:0]  data_out      // Data out from the peripheral, set this in accordance with the supplied address
);

    / Shift register for 4 most recent samples
    reg [7:0] samples[0:3];
    reg [7:0] filter_out;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1)
                samples[i] <= 8'd0;
            filter_out <= 8'd0;
        end else if (data_write) begin
            // Shift samples
            samples[3] <= samples[2];
            samples[2] <= samples[1];
            samples[1] <= samples[0];
            samples[0] <= ui_in;

            // FIR computation: simple average (coeffs = [1,1,1,1])
            filter_out <= (samples[0] + samples[1] + samples[2] + samples[3]) >> 2;
        end
    end

    // Drive outputs
    assign uo_out   = filter_out;

    // Address map
    // 0: FIR output
    // 1: Current input sample
    // others: 0
    assign data_out = (address == 4'h0) ? filter_out :
                      (address == 4'h1) ? ui_in      :
                                           8'd0;

endmodule
