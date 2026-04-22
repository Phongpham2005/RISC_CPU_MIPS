`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2025 07:45:56 PM
// Design Name: 
// Module Name: tb_RF
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


module tb_register_file;

    reg clk = 0;
    reg reset = 1;

    reg        reg_write;
    reg  [2:0] read_reg1, read_reg2;
    reg  [2:0] write_reg;
    reg [15:0] write_data;

    wire [15:0] read_data1, read_data2;

    // Clock 10ns
    always #5 clk = ~clk;

    // Instantiate Register File
    register_file RF (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        $display("=== TEST REGISTER FILE ===");

        // -------------------------
        // 1. Reset
        // -------------------------
        reg_write = 0;
        read_reg1 = 0;
        read_reg2 = 0;
        write_reg = 0;
        write_data = 0;

        #20 reset = 0;
        #10;

        $display("[RESET] R0=%h R1=%h R2=%h",
                 RF.R[0], RF.R[1], RF.R[2]);

        // -------------------------
        // 2. Write to R1
        // -------------------------
        @(posedge clk);
        reg_write = 1;
        write_reg = 3'd1;
        write_data = 16'h1111;

        @(posedge clk);
        reg_write = 0;

        $display("[WRITE] R1=%h (expect 1111)", RF.R[1]);

        // -------------------------
        // 3. Write to R2
        // -------------------------
        @(posedge clk);
        reg_write = 1;
        write_reg = 3'd2;
        write_data = 16'h2222;

        @(posedge clk);
        reg_write = 0;

        $display("[WRITE] R2=%h (expect 2222)", RF.R[2]);

        // -------------------------
        // 4. Attempt write to R0 ($ZERO)
        // -------------------------
        @(posedge clk);
        reg_write = 1;
        write_reg = 3'd0;
        write_data = 16'hFFFF;

        @(posedge clk);
        reg_write = 0;

        $display("[ZERO] R0=%h (expect 0000)", RF.R[0]);

        // -------------------------
        // 5. Read test (async read)
        // -------------------------
        read_reg1 = 3'd1;
        read_reg2 = 3'd2;
        #1;

        $display("[READ] read_data1=%h (R1)", read_data1);
        $display("[READ] read_data2=%h (R2)", read_data2);

        // -------------------------
        // Finish
        // -------------------------
        $display("=== END TEST REGISTER FILE ===");
        #20 $finish;
    end

endmodule

