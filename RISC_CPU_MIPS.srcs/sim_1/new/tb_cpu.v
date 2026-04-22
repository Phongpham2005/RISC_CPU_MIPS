`timescale 1ns / 1ps

module tb_cpu;
    reg clk = 0;
    reg reset = 1;
    integer i;

    // Clock 100MHz
    always #5 clk = ~clk;

    CPU test (
        .clk(clk), .reset(reset), .Halt()
    );

    initial begin
        // 1. Reset he thong
        reset = 1;
        #12; 
        reset = 0; 
        
        // 2. KHOI TAO DATA MEMORY CHO FP16 TEST
        #1; 
        test.DM.memory[7] = 16'h3C00; // 1.0 (float)
        test.DM.memory[8] = 16'h4000; // 2.0 (float)

        // 3. Header Log
        $display("==========================================================================================================");
        $display("                                  CPU SYSTEM VERIFICATION REPORT                                          ");
        $display("==========================================================================================================");
        $display(" Time  | PC   | Instr Name     | rs_val  rt_val | ALU Result | MemW | Br/J | RegW Data | HI   LO  ");
        $display("-------|------|----------------|----------------|------------|------|------|-----------|--------------");

        // 4. Chay Simulation
        repeat (300) @(posedge clk); 
        $display("=== TIMEOUT: HALT NOT DETECTED ===");
        $finish;
    end

    // Monitor Logic
    reg [8*10:1] instr_name;
    wire [3:0] op = test.instruction[15:12];
    wire [2:0] funct = test.instruction[2:0];

    always @(posedge clk) begin
        if (!reset) begin
            case(op)
                4'b0000: begin // ALU0
                    case(funct)
                        3'b000: instr_name = "ADDU";
                        3'b001: instr_name = "SUBU";
                        3'b010: instr_name = "MULTU";
                        3'b011: instr_name = "DIVU";
                        3'b100: instr_name = "AND";
                        3'b101: instr_name = "OR";
                        default: instr_name = "ALU0_UNK";
                    endcase
                end
                4'b0001: begin // ALU1
                    case(funct)
                        3'b000: instr_name = "ADD";
                        3'b010: instr_name = "MULT";
                        3'b100: instr_name = "SLT";
                        default: instr_name = "ALU1_UNK";
                    endcase
                end
                4'b0010: begin // Shift
                    case(funct)
                        3'b001: instr_name = "SHL";
                        3'b010: instr_name = "ROR";
                        default: instr_name = "SHIFT";
                    endcase
                end
                4'b0011: instr_name = "ADDI";
                4'b0100: instr_name = "SLTI";
                4'b1000: instr_name = "LH (Mem)";
                4'b1001: instr_name = "SH (Mem)";
                4'b1110: begin // FP16 Ops
                    case(funct)
                        3'b000: instr_name = "FP_ADD";
                        3'b001: instr_name = "FP_SUB";
                        3'b010: instr_name = "FP_MUL";
                        3'b011: instr_name = "FP_DIV";
                        default: instr_name = "FP_UNK";
                    endcase
                end
                4'b1010: begin // MFSR
                     case(funct)
                        3'b100: instr_name = "MFHI";
                        3'b101: instr_name = "MFLO";
                        default: instr_name = "MFSR";
                     endcase
                end
                4'b1011: begin // MTSR
                     case(funct)
                        3'b100: instr_name = "MTHI";
                        3'b101: instr_name = "MTLO";
                        default: instr_name = "MTSR";
                     endcase
                end
                4'b0101: instr_name = "BNEQ";
                4'b0111: instr_name = "JUMP";
                4'b1111: instr_name = "HALT";
                default: instr_name = "UNKNOWN";
            endcase

            // In log
            $display("%4tns | %4h | %-14s | %4h %4h   |    %4h    |  %b   |  %b   | %4h > R%1d | %4h %4h",
                $time,
                test.pc,
                instr_name,
                test.read_data1, test.read_data2,
                test.alu_result,
                test.MemWrite,
                test.take_branch || test.Jump,
                test.write_data, test.write_reg, 
                test.HI, test.LO
            );

            // Kiem tra Halt
            if (test.instruction[15:12] == 4'b1111) begin
                $display("----------------------------------------------------------------------------------------------------------");
                $display(">>> HALT DETECTED AT PC=%h. PROGRAM FINISHED SUCCESSFULLY.", test.pc);
                $display("==========================================================================================================");
                $finish;
            end
        end
    end
endmodule