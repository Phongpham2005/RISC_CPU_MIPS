# 16-bit RISC MIPS CPU Design

Thiết kế và mô phỏng bộ vi xử lý single CPU RISC 16-bit theo kiến trúc MIPS rút gọn, hỗ trợ xử lý số nguyên, số thực (FP16) và các lệnh rẽ nhánh phức tạp.

## 📋 Tổng quan dự án
Dự án này triển khai một lõi CPU RISC cơ bản nhưng mạnh mẽ, được tối ưu hóa để chạy trên các dòng FPGA của Xilinx. Hệ thống bao gồm đầy đủ các khối chức năng từ ALU, Register File cho đến bộ xử lý số thực và bộ nhớ.

## 🛠 Môi trường phát triển
* **Công cụ:** Vivado Design Suite v2025.1 (64-bit).
* **Ngôn ngữ:** Verilog HDL.
* **Nền tảng:** Windows/Linux 64-bit.

## 🏗 Kiến trúc tập lệnh (ISA)
CPU sử dụng định dạng lệnh 16-bit: `Opcode [15:12] | Rs [11:9] | Rd/Rt [8:6] | Immediate/Address [5:0]`.

Các nhóm lệnh hỗ trợ:
- **ALU0 (Unsigned):** ADDU, SUBU, AND, OR, MULTU, DIVU.
- **ALU1 (Signed):** ADD, SLT, MULT.
- **ALU2 (Shift/Rotate):** SHL, ROR.
- **Memory:** LH (Load Halfword), SH (Store Halfword).
- **Special Registers:** MTHI, MTLO, MFHI, MFLO (Dành cho kết quả phép nhân/chia).
- **Control Flow:** BNEQ (Branch Not Equal), JUMP, HALT.
- **Floating Point:** Hỗ trợ tính toán số thực chuẩn **FP16** (Add, Sub, Mul, Div).

## 🚀 Hướng dẫn sử dụng trên Vivado

### 1. Khởi động Project
1. Mở **Vivado 2025.1**.
2. Sử dụng Tcl Console để `cd` vào thư mục chứa source code hoặc chọn **Open Project** dẫn đến file `.xpr`.

### 2. Chạy Mô phỏng (Simulation)
Project được thiết kế để kiểm tra tự động thông qua Testbench.
1. Tại cửa sổ **Sources**, chọn file Testbench của bạn (ví dụ: `cpu_tb.v`) làm **Top Module**.
2. Nhấn **Run Simulation** > **Run Behavioral Simulation**.

### 3. Xem kết quả Testbench
Kết quả mô phỏng không chỉ hiển thị dạng sóng (Waveform) mà còn được **in trực tiếp trong Log
