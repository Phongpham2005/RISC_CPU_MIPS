`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: intruction memory
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


module instruction_memory (
    input  [15:0] addr,      
    output [15:0] instr     
);

    reg [15:0] memory [0:255];

    `ifndef SYNTHESIS
    initial begin
        $readmemh("program.mem", memory);
        $display("Instruction memory loaded from program.mem");
    end
    `endif
    assign instr = memory[addr[15:1]]; 

endmodule

