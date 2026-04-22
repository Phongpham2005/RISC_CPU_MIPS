`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 05:30:37 PM
// Design Name: 
// Module Name: CPU
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 05:30:37 PM
// Design Name: 
// Module Name: CPU
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


module CPU(
    input clk,
    input reset,
    output Halt
);

// --- Special Register ---
    reg [15:0] pc;
    reg [15:0] HI, LO, AT, RA;
    
// --- WIRES ---
    wire [15:0] instruction;
    wire [15:0] read_data1, read_data2, alu_result, mem_data;
    wire [15:0] write_data; 
    wire [2:0] write_reg;
    wire [2:0] read_reg1 = instruction[11:9];
    wire [2:0] read_reg2 = instruction[8:6];
    wire zero;
  
// --- Control Signals ---
    wire RegDst, Branch, MemToReg, RegWrite, MemWrite, MemRead, ALUSrc, Jump, Halt_int;
    wire [2:0] ALUOp;
    wire [4:0] alu_ctrl;
    
// --- Instruction Memory ---
instruction_memory IM (
         .addr(pc),
         .instr(instruction)
);

// --- Control Unit ---
control_unit CU (
        .opcode(instruction[15:12]),
        .RegDst(RegDst), 
        .Branch(Branch), 
        .MemToReg(MemToReg),
        .RegWrite(RegWrite), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead),
        .ALUSrc(ALUSrc), 
        .ALUOp(ALUOp), 
        .Jump(Jump), 
        .Halt(Halt_int)
    );
    
// --- MUX for write register ---
    assign write_reg = RegDst ? instruction[5:3] : instruction[8:6];
    
// --- Register File ---
register_file RF (
        .clk(clk), 
        .reset(reset), 
        .reg_write(RegWrite),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1), 
        .read_data2(read_data2)
    );

// --- ALU Control ---
alu_control ALU_CTRL (
        .ALUOp(ALUOp), 
        .opcode(instruction[15:12]), 
        .funct(instruction[2:0]),
        .alu_ctrl(alu_ctrl)
    );
// --- LOGIC MFSR (Move From Special Register) ---
    reg [15:0] special_read_val;
    always @(*) begin
        case (instruction[2:0]) // funct
            3'b000: special_read_val = 16'd0; // $ZERO
            3'b001: special_read_val = pc;    // $PC
            3'b010: special_read_val = RA;    // $RA
            3'b011: special_read_val = AT;    // $AT
            3'b100: special_read_val = HI;    // $HI
            3'b101: special_read_val = LO;    // $LO
            default: special_read_val = 0;
        endcase
    end
// --- ALU ---
     wire [15:0] sign_ext = {{10{instruction[5]}}, instruction[5:0]};
     wire [15:0] alu_in2 = (ALUOp == 3'b110) ? special_read_val : 
                           (ALUSrc ? sign_ext : read_data2);
alu ALU (
        .input1(read_data1), 
        .input2(alu_in2), 
        .alu_ctrl(alu_ctrl),
        .result(alu_result), 
        .zero(zero)
    );
    
// --- LOGIC MTSR (Move To Special Register) & MULT/DIV Update ---
   always @(posedge clk or posedge reset) begin
        if (reset) begin HI<=0; LO<=0; RA<=0; AT<=0; end
        else begin
            if (ALUOp == 3'b010) begin
                 case (instruction[2:0]) // funct
                    3'b010: {HI, LO} <= $signed(read_data1) * $signed(read_data2); // MULT
                    3'b011: if(read_data2!=0) begin // DIV
                         LO <= $signed(read_data1) / $signed(read_data2); 
                         HI <= $signed(read_data1) % $signed(read_data2); end 
                 endcase
            end
            if (ALUOp == 3'b111) begin // MTSR
                case (instruction[2:0])
                    3'b010: RA <= read_data1;
                    3'b011: AT <= read_data1;
                    3'b100: HI <= read_data1;
                    3'b101: LO <= read_data1;
                endcase
            end
        end
    end
    
// --- Data Memory ---
data_memory DM (
    .clk(clk),
    .mem_write(MemWrite),
    .mem_read(MemRead),
    .address(alu_result),
    .write_data(read_data2),
    .read_data(mem_data)
);

// --- WRITE BACK ---  
    assign write_data = MemToReg ? mem_data : alu_result;
    
// --- PC update --- 
    wire [15:0] pc_plus_2 = pc + 16'd2;
    
// --- Branch Logic --- 
    wire gt_zero = ($signed(read_data1) > 0);
    wire take_branch = (Branch && instruction[15:12]==4'b0101 && !zero) || // BNEQ
                       (Branch && instruction[15:12]==4'b0110 && gt_zero); // BGTZ

// --- Jump Logic ---
    wire [15:0] jump_addr = {pc_plus_2[15:13], instruction[11:0], 1'b0};
    wire is_jr = (instruction[15:12] == 4'b0001 && instruction[2:0] == 3'b111);

    assign Halt = Halt_int;

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 0;
    else if (!Halt) begin
            if (is_jr) pc <= read_data1;
            else if (Jump) pc <= jump_addr;
            else if (take_branch) pc <= pc_plus_2 + (sign_ext << 1); 
            else pc <= pc_plus_2;
        end
    end
endmodule

