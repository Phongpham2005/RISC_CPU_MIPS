`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 08:32:34 PM
// Design Name: 
// Module Name: module harzard
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


module hazard_detection_unit(
    input        idex_MemRead,
    input  [2:0] idex_rt,
    input  [2:0] ifid_rs,
    input  [2:0] ifid_rt,
    output       stall_ifid,
    output       bubble_idex
);
    assign stall_ifid  = idex_MemRead && ((idex_rt == ifid_rs) || (idex_rt == ifid_rt));
    assign bubble_idex = stall_ifid;

endmodule
