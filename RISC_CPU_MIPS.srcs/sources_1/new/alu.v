`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: alu
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

module alu (
    input  [15:0] input1,
    input  [15:0] input2,
    input  [4:0]  alu_ctrl,
    output reg [15:0] result,
    output zero
);

`ifndef SYNTHESIS
// ================= FP16 SUPPORT (SIMULATION ONLY) =================
function real f16_to_real;
    input [15:0] val;
    reg sign;
    reg [4:0] exp;
    reg [9:0] mant;
    real r_mant;
    begin
        sign = val[15];
        exp  = val[14:10];
        mant = val[9:0];
        if (exp == 0 && mant == 0)
            f16_to_real = 0.0;
        else begin
            r_mant = 1.0 + (mant / 1024.0);
            if (sign)
                f16_to_real = -r_mant * (2.0 ** (exp - 15));
            else
                f16_to_real =  r_mant * (2.0 ** (exp - 15));
        end
    end
endfunction

function [15:0] real_to_f16;
    input real r_val;
    reg sign;
    integer exp_int;
    real abs_val;
    real tmp_mant;
    reg [9:0] mant_bits;
    reg [4:0] exp_bits;
    begin
        if (r_val == 0.0)
            real_to_f16 = 16'b0;
        else begin
            if (r_val < 0) begin
                sign = 1;
                abs_val = -r_val;
            end else begin
                sign = 0;
                abs_val = r_val;
            end

            exp_int = $rtoi($ln(abs_val) / $ln(2.0));
            if (abs_val < (2.0 ** exp_int))
                exp_int = exp_int - 1;

            tmp_mant  = abs_val / (2.0 ** exp_int);
            mant_bits = $rtoi((tmp_mant - 1.0) * 1024.0);
            exp_bits  = exp_int + 15;

            real_to_f16 = {sign, exp_bits, mant_bits};
        end
    end
endfunction
// ================================================================
`endif

    always @(*) begin
        result = 16'd0;

        case (alu_ctrl)
            // Arithmetic
            5'b00000: result = $signed(input1) + $signed(input2); // ADD
            5'b00010: result = $signed(input1) - $signed(input2); // SUB
            5'b00001: result = input1 + input2;                   // ADDU
            5'b00011: result = input1 - input2;                   // SUBU

            // Logic
            5'b01000: result = input1 & input2;                   // AND
            5'b01001: result = input1 | input2;                   // OR
            5'b01010: result = ~(input1 | input2);                // NOR
            5'b01011: result = input1 ^ input2;                   // XOR

            // Compare
            5'b01100: result = ($signed(input1) < $signed(input2)); // SLT
            5'b01101: result = (input1 < input2);                   // SLTU
            5'b01110: result = (input1 == input2);                  // SEQ

            // Shift / Rotate
            5'b10000: result = input2 >> input1[3:0];              // SHR
            5'b10001: result = input2 << input1[3:0];              // SHL
            5'b10010: result = (input2 >> input1[3:0]) |
                               (input2 << (16 - input1[3:0]));     // ROR
            5'b10011: result = (input2 << input1[3:0]) |
                               (input2 >> (16 - input1[3:0]));     // ROL

            // Address calc
            5'b10101: result = (input1[15:1] + input2) << 1;

            // Pass-through
            5'b01111: result = input2;

`ifndef SYNTHESIS
            // ================= FP16 (SIMULATION ONLY) =================
            5'b11100: result = real_to_f16(
                                f16_to_real(input1) + f16_to_real(input2)); // FP_ADD
            5'b11101: result = real_to_f16(
                                f16_to_real(input1) - f16_to_real(input2)); // FP_SUB
            5'b11110: result = real_to_f16(
                                f16_to_real(input1) * f16_to_real(input2)); // FP_MUL
            5'b11111: result = real_to_f16(
                                f16_to_real(input1) / f16_to_real(input2)); // FP_DIV
`else
            // ================= FPGA SAFE =================
            5'b11100,
            5'b11101,
            5'b11110,
            5'b11111: result = 16'd0;
`endif

            default: result = 16'd0;
        endcase
    end

    assign zero = (result == 16'd0);

endmodule