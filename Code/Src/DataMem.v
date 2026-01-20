`timescale 1ns / 1ps

module DataMem(
    input wire mem_read,
    input wire mem_write,
    input wire [8:0] addr,        // 9-bit address for 512x32 memory
    input wire [31:0] write_data,
    output reg [31:0] read_data
);

    // 512 x 32-bit Data Memory (2KB)
    reg [31:0] data_memory [0:511];
    
    integer i;
    
    // Initialize memory
    initial begin
        // Initialize all memory locations to 0
        for (i = 0; i < 512; i = i + 1) begin
            data_memory[i] = 32'b0;
        end
        
        // Initialize some test data at specific addresses
        // Region 0: Read/Write/Execute allowed
        data_memory[0] = 32'h00000001;  // Test data at address 0x0000
        data_memory[1] = 32'h00000002;  // Test data at address 0x0004
        data_memory[2] = 32'h00000003;  // Test data at address 0x0008
        
        // Region 1: Read/Execute only (simulate read-only memory)
        data_memory[256] = 32'h12345678;  // Address 0x0400 (in region 1)
        data_memory[257] = 32'h9ABCDEF0;  // Address 0x0404
        data_memory[258] = 32'h11111111;  // Address 0x0408
        
        // Region 2: No access (but we'll still initialize for testing)
        data_memory[512] = 32'hDEADBEEF;  // Address 0x0800 (in region 2)
        data_memory[513] = 32'hCAFEBABE;  // Address 0x0804
        
        $display("Data Memory Initialized:");
        $display("Region 0 (0x0000-0x0FFF): Read/Write/Execute allowed");
        $display("Region 1 (0x1000-0x1FFF): Read/Execute only (no write)");
        $display("Region 2 (0x2000-0x2FFF): No access");
        $display("Default: All other regions - No access");
    end

    // Memory Read Operation
    always @(*) begin
        if (mem_read) begin
            if (addr < 512) begin
                read_data = data_memory[addr];
                $display("DATA MEM READ: Address=%h, Data=%h, Time=%0t", 
                         {23'b0, addr, 2'b00}, read_data, $time);
            end else begin
                read_data = 32'h00000000;
                $display("DATA MEM READ: Invalid Address=%h, Time=%0t", 
                         {23'b0, addr, 2'b00}, $time);
            end
        end else begin
            read_data = 32'h00000000;
        end
    end

    // Memory Write Operation
    always @(posedge mem_write) begin
        if (mem_write) begin
            if (addr < 512) begin
                data_memory[addr] = write_data;
                $display("DATA MEM WRITE: Address=%h, Data=%h, Time=%0t", 
                         {23'b0, addr, 2'b00}, write_data, $time);
            end else begin
                $display("DATA MEM WRITE: Invalid Address=%h, Time=%0t", 
                         {23'b0, addr, 2'b00}, $time);
            end
        end
    end

    // Monitor memory accesses for debugging
    always @(*) begin
        if (mem_read && mem_write) begin
            $display("WARNING: Simultaneous read and write at Time=%0t", $time);
        end
    end

endmodule