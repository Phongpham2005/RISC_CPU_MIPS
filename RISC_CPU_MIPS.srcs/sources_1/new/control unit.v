`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: control unit
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




module control_unit (
    input  [3:0] opcode,
    output reg RegDst,
    output reg Branch,
    output reg MemToReg,
    output reg RegWrite,
    output reg MemWrite,
    output reg MemRead,
    output reg ALUSrc,
    output reg [2:0] ALUOp, 
    output reg Jump,
    output reg Halt
);

    always @(*) begin
        // Reset defaults
        RegDst   = 0;
        Branch   = 0; 
        MemToReg = 0; 
        RegWrite = 0; 
        MemWrite = 0; 
        MemRead  = 0; 
        ALUSrc   = 0;
        Jump     = 0;
        Halt     = 0;
        ALUOp    = 3'b000;

        case (opcode)
            // --- R-Type ---
            4'b0000: begin RegDst=1; RegWrite=1; ALUOp=3'b010; end // ALU0 (Unsigned)
            4'b0001: begin RegDst=1; RegWrite=1; ALUOp=3'b010; end // ALU1 (Signed/JR)
            4'b0010: begin RegDst=1; RegWrite=1; ALUOp=3'b011; end // ALU2 (Shift)

            // --- Immediate ---
            4'b0011: begin RegWrite=1; ALUSrc=1; ALUOp=3'b000; end // ADDI
            4'b0100: begin RegWrite=1; ALUSrc=1; ALUOp=3'b101; end // SLTI 

            // --- Branch ---
            4'b0101: begin Branch=1; ALUOp=3'b001; end // BNEQ
            4'b0110: begin Branch=1; ALUOp=3'b001; end // BGTZ

            // --- Jump ---
            4'b0111: begin Jump=1; end // JUMP
            
            // --- Memory (LH/SH) ---
            4'b1000: begin RegWrite=1; ALUSrc=1; MemRead=1; MemToReg=1; ALUOp=3'b100; end // LH
            4'b1001: begin ALUSrc=1; MemWrite=1; ALUOp=3'b100; end // SH

            // --- Special Registers ---
            4'b1010: begin RegDst=1; RegWrite=1; ALUOp=3'b110; end // MFSR
            4'b1011: begin ALUOp=3'b111; end // MTSR

            // --- FP16
            4'b1110: begin RegDst=1; RegWrite=1; ALUOp=3'b101; end

            // --- Halt ---
            4'b1111: Halt = 1;
        endcase
    end
endmodule