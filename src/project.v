/*
 * Copyright (c) 2026 Parthiv S
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_alu_6bit # (parameter WIDTH = 6)
(
    input [WIDTH - 1:0] A,
    input [WIDTH - 1:0] B,
    input [3:0] alu_opc,
    input clk,
    input rst_n,
    input ena,
    
    output reg [WIDTH - 1:0] result,
    output reg zero
);

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
    zero = (result == {WIDTH{1'b0}});
end
endmodule
