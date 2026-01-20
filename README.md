# RISC-V 32-bit Processor with Physical Memory Protection (PMP)
# Sequential RISC-V Core with Integrated Security Checks (Vivado)

---

## 📌 Overview

This project implements a **32-bit sequential RISC-V processor** enhanced with a **Physical Memory Protection (PMP) checker**, developed and simulated using **Xilinx Vivado**.

The processor follows a **classic five-stage RISC architecture**, executing one instruction completely before moving to the next.  
The PMP unit enforces **memory access permissions** for both **instruction fetches** and **data memory operations**, enabling basic **hardware-level security and isolation**.

A **self-checking testbench** is included to validate correct PMP behavior and to detect **expected access violations** during simulation.

---

## 🧱 Project Structure

├── tb_Processor.v          # Testbench for RISC-V Processor with PMP  
├── PMP_Checker.v           # Physical Memory Protection checker module  
├── Top_Processor_PMP.v    # Top-level RISC-V processor with PMP integration  
├── datapath.v             # RISC-V datapath (IF, ID, EX, MEM, WB)  
├── control.v              # Control unit  
└── README.md  

---

## ✨ Key Features

### 🔁 Sequential Processing
- One instruction completes all five stages before the next begins
- Deterministic and easy-to-debug execution
- Ideal for learning, verification, and academic projects

### 🧠 Five-Stage RISC Architecture

1. **Instruction Fetch (IF)**  
   - Fetches instruction from instruction memory  
   - Updates Program Counter (PC)  
   - Instruction fetch is validated by PMP (Execute permission)

2. **Instruction Decode (ID)**  
   - Decodes opcode and fields  
   - Reads source registers  
   - Generates control signals  

3. **Execution (EX)**  
   - ALU performs arithmetic / logical operations  
   - Effective address calculation for loads and stores  

4. **Memory Access (MEM)**  
   - Load and store operations  
   - PMP checks Read / Write permissions  

5. **Write Back (WB)**  
   - Writes ALU or memory result back to register file  

---

## 🧾 Supported RISC-V Instructions

This processor supports a subset of the **RISC-V RV32I-style ISA**.  
All arithmetic operations are **signed**, and logical operations are **bitwise**.

### 🟦 R-Type Instructions
- add
- sub
- and
- or
- nor *(custom instruction)*
- seq *(set if equal – custom instruction)*
- slt *(set less than)*

NOTE:  
`nor` and `seq` are custom extensions added for educational purposes.  
They are not part of the standard RISC-V ISA but remain ISA-compatible.

---

## 🔐 Physical Memory Protection (PMP)

### PMP Purpose
The PMP unit restricts memory accesses based on:
- Address range
- Access type (Read / Write / Execute)

This simulates **hardware-enforced memory protection**, similar to PMP in real RISC-V implementations.

---

## 🧠 PMP Checker Design

### PMP_Checker Module
- Address width: **8-bit**
- Combinational permission checking
- Enforces access control for:
  - Instruction fetch
  - Data load
  - Data store

### Region-Based PMP Configuration

| Region | Address Range | Permissions |
|------|---------------|-------------|
| Region 0 | 0x00 – 0x3F | Read / Write / Execute |
| Region 1 | 0x40 – 0x7F | Read / Execute only |
| Region 2 | 0x80 – 0xBF | No access |
| Default | 0xC0 – 0xFF | No access |

### Permission Encoding
- [2] Execute
- [1] Write
- [0] Read

Example:
- 3'b111 → R/W/X
- 3'b101 → R/X
- 3'b000 → No access

---

## 🧪 Testbench Functionality

### tb_Processor.v Highlights
- Generates clock and reset
- Instantiates the full RISC-V processor with PMP
- Uses hierarchical references for deep debug visibility
- Logs:
  - Instruction fetches
  - Memory accesses
  - PMP permission results
- Automatically detects and counts violations

---

## 🚨 Expected PMP Violations (Verified in Simulation)

1. Load from Region 2 (0x80) → NO ACCESS  
2. Store to Region 1 (0x40) → WRITE NOT ALLOWED  
3. Jump to Region 2 (0x80) → EXECUTE NOT ALLOWED  
4. Load from Default Region (0xC0) → NO ACCESS  

Simulation reports **PASS** only if all 4 violations are detected.

---

## 📊 Simulation Output Summary

At the end of simulation:
- Total PMP violations detected
- PASS / PARTIAL / FAIL status
- Last Program Counter value (on timeout)

A safety timeout is included to prevent infinite simulation loops.

---

## 🎓 Educational Use Cases

This project is ideal for:
- Understanding RISC-V processor internals
- Learning five-stage RISC datapath design
- Studying hardware-based memory protection
- Academic labs and final-year projects
- Interview preparation (RISC-V + PMP fundamentals)

---

## 🚀 Future Enhancements

- CSR-based PMP configuration (pmpcfg, pmpaddr)
- Multiple PMP entries
- Privilege modes (M/U)
- Exception and trap handling
- Pipeline version of the processor
- Formal verification of PMP rules

---


