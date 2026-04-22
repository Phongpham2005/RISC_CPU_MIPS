`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 10:00:45 PM
// Design Name: 
// Module Name: data_memory
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


module data_memory(
    input clk,
    input mem_write,
    input mem_read,
    input [15:0] address,
    input [15:0] write_data,
    output [15:0] read_data
);
    //Memory
    reg [15:0] memory [0:1023];

    wire [9:0] word_addr = address[10:1];

    assign read_data = (mem_read) ? memory[word_addr] : 16'b0;

    always @(posedge clk) begin
        if (mem_write) begin
            memory[word_addr] <= write_data;
        end
    end
endmodule
