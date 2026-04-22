`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 08:19:25 PM
// Design Name: 
// Module Name: forward module
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


module forwarding_unit (
    input  [2:0] idex_rs,
    input  [2:0] idex_rt,
    input        exmem_RegWrite,
    input  [2:0] exmem_rd,
    input        memwb_RegWrite,
    input  [2:0] memwb_rd,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @* begin
        ForwardA = 2'b00; // 00: ID/EX.rd1
        ForwardB = 2'b00; // 00: ID/EX.rd2

        // EX hazard
        if (exmem_RegWrite && (exmem_rd != 3'd0) && (exmem_rd == idex_rs))
            ForwardA = 2'b10; // EX/MEM.alu_res
        if (exmem_RegWrite && (exmem_rd != 3'd0) && (exmem_rd == idex_rt))
            ForwardB = 2'b10;

        // MEM hazard (only if not already taken by EX)
        if (memwb_RegWrite && (memwb_rd != 3'd0) && (memwb_rd == idex_rs) && (ForwardA == 2'b00))
            ForwardA = 2'b01; // MEM/WB write-back
        if (memwb_RegWrite && (memwb_rd != 3'd0) && (memwb_rd == idex_rt) && (ForwardB == 2'b00))
            ForwardB = 2'b01;
    end
endmodule