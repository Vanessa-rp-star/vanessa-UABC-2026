/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire [3:0] A = ui_in[3:0];
    wire [3:0] B = ui_in[7:4];
    wire [2:0] op = uio_in[2:0];

    reg [7:0] result;

    always @(*) begin
        case (op)
            3'b000: result = A + B;                         // ADD
            3'b001: result = A - B;                         // SUB
            3'b010: result = A & B;                         // AND
            3'b011: result = A | B;                         // OR
            3'b100: result = A ^ B;                         // XOR
            3'b101: result = ($signed(A) < $signed(B)) ? 1 : 0; // SLT
            default: result = 8'b0;
        endcase
    end

    assign uo_out  = result;
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    wire _unused = &{ena, clk, rst_n, uio_in[7:3], 1'b0};

endmodule

  

 


     
           


