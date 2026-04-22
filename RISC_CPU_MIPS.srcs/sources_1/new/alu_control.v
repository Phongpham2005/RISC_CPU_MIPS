`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: alu control
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
module alu_control (
    input [2:0] ALUOp,
    input [3:0] opcode,
    input [2:0] funct,
    output reg [4:0] alu_ctrl
);
    always @(*) begin
        case (ALUOp)
            3'b000: alu_ctrl = 5'b00000; // ADDI / ADD
            3'b001: alu_ctrl = 5'b00010; // Branch / SUB
            
            3'b010: begin // R-Type (ALU0 & ALU1)
                if (opcode == 4'b0000) begin // ALU0 (Unsigned)
                    case (funct)
                        3'b000: alu_ctrl = 5'b00001; // ADDU
                        3'b001: alu_ctrl = 5'b00011; // SUBU
                        3'b010: alu_ctrl = 5'b00101; // MULTU
                        3'b011: alu_ctrl = 5'b00111; // DIVU
                        3'b100: alu_ctrl = 5'b01000; // AND
                        3'b101: alu_ctrl = 5'b01001; // OR
                        3'b110: alu_ctrl = 5'b01010; // NOR
                        3'b111: alu_ctrl = 5'b01011; // XOR
                    endcase
                end else begin // ALU1 (Signed)
                    case (funct)
                        3'b000: alu_ctrl = 5'b00000; // ADD
                        3'b001: alu_ctrl = 5'b00010; // SUB
                        3'b010: alu_ctrl = 5'b00100; // MULT
                        3'b011: alu_ctrl = 5'b00110; // DIV
                        3'b100: alu_ctrl = 5'b01100; // SLT
                        3'b101: alu_ctrl = 5'b01110; // SEQ
                        3'b110: alu_ctrl = 5'b01101; // SLTU
                        3'b111: alu_ctrl = 5'b00000; // JR
                    endcase
                end
            end

            3'b011: begin // ALU2 (Shift)
                case (funct)
                    3'b000: alu_ctrl = 5'b10000; // SHR
                    3'b001: alu_ctrl = 5'b10001; // SHL
                    3'b010: alu_ctrl = 5'b10010; // ROR
                    3'b011: alu_ctrl = 5'b10011; // ROL
                    default: alu_ctrl = 5'b00000;
                endcase
            end

            3'b100: alu_ctrl = 5'b10101; //  LH / SH
            
            3'b101: begin // Special I-Type & FP16
                if (opcode == 4'b0100) alu_ctrl = 5'b01100; // SLTI / SLT
                if (opcode == 4'b1110) begin
                    case(funct)
                        3'b000: alu_ctrl = 5'b11100; // FP_ADD
                        3'b001: alu_ctrl = 5'b11101; // FP_SUB
                        3'b010: alu_ctrl = 5'b11110; // FP_MUL
                        3'b011: alu_ctrl = 5'b11111; // FP_DIV
                        default: alu_ctrl = 5'b00000;
                    endcase
                end
            end
            
            3'b110: alu_ctrl = 5'b01111; // MFSR (Pass input2)
            
            default: alu_ctrl = 5'b00000;
        endcase
    end
endmodule