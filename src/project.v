/*
 * Copyright (c) 2026 Parthiv S
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_alu_6bit # (parameter WIDTH = 6)
    (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IO pads: Input path
    output wire [7:0] uio_out,  // IO pads: Output path
    output wire [7:0] uio_oe,   // IO pads: Enable path (1=out, 0=in)
    input  wire       ena,      // Will go high when design is active
    input  wire       clk,      // Unused (Purely combinational)
    input  wire       rst_n     // Unused (Purely combinational)
);

// --- 1. EXTRACT INPUTS FROM THE PHYSICAL PINS ---
wire [5:0] A  = ui_in[5:0];
wire [5:0] B  = uio_in[5:0];
wire [3:0] alu_opc = { uio_in[7:6], ui_in[7:6] }; 
wire [5:0] result;

always @(*) begin
    case(alu_opc)
        4'b0000: result = A + B;
        4'b0001: result = A - B;
        4'b0010: result = A & B;
        4'b0011: result = A | B;
        4'b0100: result = A ^ B;
        4'b0101: result = A << B[4:0];
        4'b0110: result = A >> B[4:0];
        4'b0111: result = $signed(A) >>> B[4:0];
        4'b1000: result = {{(WIDTH - 1){1'b0}}, ($signed(A) < $signed(B))};
        4'b1001: result = {{(WIDTH - 1){1'b0}}, (A < B)};


        default: result = {WIDTH{1'b0}};
    endcase
end
assign uo_out[7] = 1'b0;
assign uo_out[6] = (result == {WIDTH{1'b0}});
assign uo_out[5:0] = result;

endmodule
