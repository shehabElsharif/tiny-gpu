`default_nettype none
`timescale 1ns/1ns

// INSTRUCTION FETCHER
// > Retrieves the instruction at the current PC from global data memory
// > Each core has it's own fetcher
module fetcher #(
    parameter PROGRAM_MEM_ADDR_BITS = 8,
    parameter PROGRAM_MEM_DATA_BITS = 16
) (
    input wire clk,
    input wire reset,
    
    // Execution State
    input reg [2:0] core_state,
    input reg [7:0] current_pc,

    // Program Memory
    output reg is_read_valid,
    output reg [PROGRAM_MEM_ADDR_BITS-1:0] read_address,
    input reg is_read_ready,
    input reg [PROGRAM_MEM_DATA_BITS-1:0] read_data,

    // Fetcher Output
    output reg [2:0] fetcher_state,
    output reg [PROGRAM_MEM_DATA_BITS-1:0] instruction,
);
    localparam IDLE = 3'b000, 
        FETCHING = 3'b001, 
        FETCHED = 3'b010;
    
    always @(posedge clk) begin
        if (reset) begin
            fetcher_state <= IDLE;
            is_read_valid <= 0;
            read_address <= 0;
            instruction <= {PROGRAM_MEM_DATA_BITS{1'b0}};
        end else begin
            case (fetcher_state)
                IDLE: begin
                    // Start fetching when core_state = FETCH
                    if (core_state == 3'b001) begin
                        fetcher_state <= FETCHING;
                        is_read_valid <= 1;
                        read_address <= current_pc;
                    end
                end
                FETCHING: begin
                    // Wait for response from program memory
                    if (is_read_ready) begin
                        fetcher_state <= FETCHED;
                        instruction <= read_data; // Store the instruction when received
                        is_read_valid <= 0;
                    end
                end
                FETCHED: begin
                    // Reset when core_state = DECODE
                    if (core_state == 3'b010) begin 
                        fetcher_state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
