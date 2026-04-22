`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: register aray
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

module register_file (
    input clk,
    input reset,
    input reg_write,
    input [2:0] read_reg1,
    input [2:0] read_reg2,
    input [2:0] write_reg,
    input [15:0] write_data,
    output [15:0] read_data1,
    output [15:0] read_data2
);

    reg [15:0] R [0:7];
    integer i;

    // Read Logic
    assign read_data1 = (read_reg1 == 0) ? 0 : R[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 0 : R[read_reg2];

    // Write logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<8; i=i+1) R[i] <= 0;
        end else if (reg_write && write_reg != 0) begin
            R[write_reg] <= write_data;
        end
    end
endmodule

