/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset;
    wire [31:0] debug_alu_out;
    assign reset = ~rst_n;

    single_cycle_cpu cpu (
        .clk(clk),
        .reset(reset),
        .debug_alu_out(debug_alu_out)
    );
    
  // All output pins must be assigned. If not used, assign to 0.
    assign uo_out = debug_alu_out[7:0];
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

  // List all unused inputs to prevent warnings
    wire _unused = &{ena, ui_in, uio_in, debug_alu_out[31:8], 1'b0};
  
endmodule




module single_cycle_cpu (
    input wire clk,
    input wire reset,
    output wire [31:0] debug_alu_out
);

    wire [31:0] PC, PC_next, instr;
    wire [31:0] rd1, rd2, imm32, aluResult;
    wire [31:0] ReadData_from_mem;
    wire [31:0] SrcB_mux_out;
    wire [31:0] Result_mux_out;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [31:0] PCTarget;
    wire [31:0] PC_Plus4;
    wire Zero;

    reg RegWrite, MemWrite, MemRead, ALUSrc, ResultSrc;
    reg PCSrc;
    reg [1:0] ImmSrc;
    reg [2:0] ALUControl;

    ProgramCounter u_pc (.clk(clk), .reset(reset), .PC_next(PC_next), .PC(PC));
    PCplus4 u_pcplus4 (.fromPC(PC), .NextPC(PC_Plus4));

    adder_pctarget u_pc_target_adder (
        .pc_val(PC),
        .imm_val(imm32),
        .pc_target(PCTarget)
    );

    mux_pcsrc u_mux_pc (
        .data_in_0(PC_Plus4),
        .data_in_1(PCTarget),
        .sel(PCSrc),
        .data_out(PC_next)
    );

    instr_mem u_imem (.addr(PC), .instr(instr));

    assign rs1_addr = instr[19:15];
    assign rs2_addr = instr[24:20];
    assign rd_addr  = instr[11:7];
    assign debug_alu_out = aluResult;

    sign_extend u_sext (.ImmSrc(ImmSrc), .instr(instr), .imm32(imm32));

    regfile u_rf (
        .clk(clk), .reset(reset), .we(RegWrite),
        .rs1(rs1_addr), .rs2(rs2_addr),
        .rd(rd_addr), .wd(Result_mux_out),
        .rd1(rd1), .rd2(rd2)
    );

    mux_alusrc u_mux_alu (
        .data_in_0(rd2),
        .data_in_1(imm32),
        .sel(ALUSrc),
        .data_out(SrcB_mux_out)
    );

    ALU u_alu (
        .SrcA(rd1), .SrcB(SrcB_mux_out),
        .ALUControl(ALUControl),
        .ALUResult(aluResult),
        .Zero(Zero)
    );

    data_memory u_dmem (
        .clk(clk), .MemWrite(MemWrite), .MemRead(MemRead),
        .addr(aluResult), .WriteData(rd2),
        .ReadData(ReadData_from_mem)
    );

    mux_resultsrc u_mux_res (
        .data_in_0(aluResult),
        .data_in_1(ReadData_from_mem),
        .sel(ResultSrc),
        .data_out(Result_mux_out)
    );

    always @(*) begin
        RegWrite = 0; ImmSrc = 2'b00; ALUSrc = 0; MemRead = 0;
        MemWrite = 0; ResultSrc = 0; ALUControl = 3'b000; PCSrc = 0;

        case (instr[6:0])
            7'b0000011: begin // lw
                RegWrite = 1; ALUSrc = 1; MemRead = 1; ResultSrc = 1; ImmSrc = 2'b00;
            end

            7'b0100011: begin // sw
                ImmSrc = 2'b01; ALUSrc = 1; MemWrite = 1;
            end

            7'b0110011: begin // R-type
                RegWrite = 1; ImmSrc = 2'b00;
                case ({instr[30], instr[14:12]})
                    4'b0_000: ALUControl = 3'b000;
                    4'b1_000: ALUControl = 3'b001;
                    4'b0_111: ALUControl = 3'b010;
                    4'b0_110: ALUControl = 3'b011;
                    4'b0_010: ALUControl = 3'b101;
                    default:  ALUControl = 3'b000;
                endcase
            end

            7'b1100011: begin // beq
                ImmSrc = 2'b10;
                ALUSrc = 0;
                ALUControl = 3'b001;
                PCSrc = Zero;
            end
        endcase
    end

endmodule

