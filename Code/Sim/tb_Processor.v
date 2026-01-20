`timescale 1ns / 1ps

module tb_Processor();

    // ---------------- I/O Signals ----------------
    reg  clk;
    reg  rst;

    // ---------------- DUT Instance ----------------
    Top_Processor_PMP Processor_inst (
        .Clock(clk),
        .Reset(rst)
    );

    // ---------------- Clock Generation ----------------
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50 MHz
    end

    // ---------------- Reset Logic ----------------
    initial begin
        rst = 1;
        #100;  // Longer reset period
        rst = 0;
    end

    // ---------------- Enhanced Monitoring ----------------
    // Monitor actual signals using hierarchical references
    wire [31:0] debug_alu_result = Processor_inst.datapath.ALU_Result;
    wire [7:0] debug_pmp_addr = Processor_inst.datapath.data_pmp_addr;
    wire debug_mem_read = Processor_inst.datapath.Mem_Read;
    wire debug_mem_write = Processor_inst.datapath.Mem_Write;
    wire debug_data_pmp_ok = Processor_inst.datapath.data_pmp_ok;
    wire debug_instr_pmp_ok = Processor_inst.datapath.instr_pmp_ok;
    wire [7:0] debug_pc = Processor_inst.datapath.PC;
    wire [31:0] debug_instr = Processor_inst.datapath.Instruction;
    wire [6:0] debug_opcode = Processor_inst.datapath.Opcode;
    
    reg [7:0] last_pc;
    integer violation_count = 0;
    
    // PMP Region definitions (8-bit)
    parameter [7:0] REGION0_END   = 8'h3F;  // Region 0: R/W/X allowed
    parameter [7:0] REGION1_START = 8'h40;  // Region 1: R/X only  
    parameter [7:0] REGION1_END   = 8'h7F;
    parameter [7:0] REGION2_START = 8'h80;  // Region 2: No access
    parameter [7:0] REGION2_END   = 8'hBF;
    
    always @(posedge clk) begin
        if (!rst) begin
            // Log instruction fetches with PMP status
            $display("[%0t] FETCH: PC=0x%h, Instr=0x%h, Opcode=0x%h, Instr_PMP=%b", 
                    $time, debug_pc, debug_instr, debug_opcode, debug_instr_pmp_ok);
            
            // Log memory accesses with PMP results
            if (debug_mem_read || debug_mem_write) begin
                $display("[%0t] MEM: PC=0x%h, Addr=0x%h, R=%b, W=%b, Data_PMP=%b", 
                        $time, debug_pc, debug_pmp_addr, 
                        debug_mem_read, debug_mem_write, debug_data_pmp_ok);
                
                // Check for expected violations
                if (!debug_data_pmp_ok) begin
                    violation_count = violation_count + 1;
                    $display("*** PMP VIOLATION #%0d DETECTED! ***", violation_count);
                    
                    // Identify which violation type
                    case (debug_pmp_addr)
                        8'h80: $display("*** VIOLATION: Load from Region 2 (NO ACCESS)");
                        8'h40: $display("*** VIOLATION: Store to Region 1 (READ ONLY)");
                        8'hC0: $display("*** VIOLATION: Access to Default Region (NO ACCESS)");
                        default: $display("*** VIOLATION: Unknown protected address");
                    endcase
                end
            end
            
            // Log instruction PMP violations (jump to protected region)
            if (!debug_instr_pmp_ok && debug_pc >= REGION2_START) begin
                $display("*** INSTRUCTION PMP VIOLATION: Jump to protected region 0x%h ***", debug_pc);
                violation_count = violation_count + 1;
            end
            
            last_pc <= debug_pc;
        end
    end

    // Monitor for specific expected violations at instruction boundaries
    reg [2:0] instruction_phase = 0;
    
    always @(posedge clk) begin
        if (!rst) begin
            case (debug_pc)
                8'h18: begin // PC where violation 1 should occur (load from 0x80)
                    if (instruction_phase == 0) begin
                        $display("\n=== EXPECTED: Violation 1 - Load from Region 2 (0x80) ===");
                        instruction_phase = 1;
                    end
                end
                8'h1C: begin // PC where violation 2 should occur (store to 0x40)
                    if (instruction_phase == 1) begin
                        $display("=== EXPECTED: Violation 2 - Store to Region 1 (0x40) ===");
                        instruction_phase = 2;
                    end
                end
                8'h24: begin // PC where violation 3 should occur (jump to 0x80)
                    if (instruction_phase == 2) begin
                        $display("=== EXPECTED: Violation 3 - Jump to Region 2 (0x80) ===");
                        instruction_phase = 3;
                    end
                end
                8'h28: begin // PC where violation 4 should occur (load from 0xC0)
                    if (instruction_phase == 3) begin
                        $display("=== EXPECTED: Violation 4 - Load from Default Region (0xC0) ===");
                        instruction_phase = 4;
                    end
                end
            endcase
        end
    end

    // ---------------- Simulation Control ----------------
    initial begin
        $display("\n===============================================");
        $display("   RISC-V Processor with 8-bit PMP Test Start");
        $display("===============================================\n");
        $display("PMP Regions Configuration:");
        $display("Region 0 (0x00-0x3F): Read/Write/Execute allowed");
        $display("Region 1 (0x40-0x7F): Read/Execute only (no write)");
        $display("Region 2 (0x80-0xBF): No access");
        $display("Default (0xC0-0xFF): No access");
        $display("");
        $display("Expected PMP Violations:");
        $display("1. Load from region 2 (0x80) - NO ACCESS");
        $display("2. Store to region 1 (0x40) - READ ONLY");
        $display("3. Jump to region 2 (0x80) - NO EXECUTE");
        $display("4. Load from default region (0xC0) - NO ACCESS");
        $display("===============================================\n");

        // Wait for execution to complete
        #10000;
        
        // Additional time for any pending operations
        #1000;

        $display("\n===============================================");
        $display("   Simulation Complete - RESULTS SUMMARY");
        $display("===============================================");
        $display("Total PMP Violations Detected: %0d", violation_count);
        
        if (violation_count == 4) begin
            $display("SUCCESS: All 4 expected PMP violations were detected!");
        end else if (violation_count > 0) begin
            $display("PARTIAL: %0d violations detected (expected 4)", violation_count);
        end else begin
            $display("FAILURE: No PMP violations detected!");
            $display("Check if:");
            $display("  - Instructions are executing correctly");
            $display("  - PMP addresses match the test program");
            $display("  - PMP checker is properly connected");
        end
        
        $display("===============================================\n");
        $finish;
    end

    // Safety timeout
    initial begin
        #20000;
        $display("ERROR: Simulation timeout!");
        $display("Last PC: 0x%h", last_pc);
        $finish;
    end

    // Performance monitoring
    integer cycle_count = 0;
    always @(posedge clk) begin
        if (!rst) cycle_count <= cycle_count + 1;
    end

endmodule