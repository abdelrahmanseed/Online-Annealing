`include "PSL_pkg.sv" // Import the package which contains parameters like beta_bit_width

module beta_counter(
    input logic CLK,
    input logic RESET,
    input logic GE,
    input logic weight_load_DONE,
    input logic [PSL_pkg::beta_bit_width-1:0] beta_v [PSL_pkg::num_beta-1:0],
    input logic [31:0] num_clk_cycles,
    output reg [PSL_pkg::beta_bit_width-1:0] beta
);

// Use package parameters
import PSL_pkg::*;

// Internal signals
logic [31:0] counter;
logic [31:0] current_beta_index;

// Counter and beta index update logic
always_ff @(posedge CLK) begin
    if (RESET) begin
        counter <= 32'b0;
        current_beta_index <= 32'b0; // Reset to the first beta
        beta <= beta_v[0]; // Output the first beta immediately on reset
    end else if (GE && weight_load_DONE) begin
        // Increment counter when GE and weight_load_DONE are HIGH
        if (counter == num_clk_cycles - 1) begin
            // Reset counter and move to the next beta
            counter <= 32'b0;
            // Check if we are at the last beta, if not, move to next
            if (current_beta_index < num_beta - 1) begin
                beta <= beta_v[current_beta_index + 1]; // Assign the next value of beta_v to beta
                current_beta_index <= current_beta_index + 1; // Then increment the index
            end
            // If we are at the last beta, do not increment current_beta_index (hold value)
        end else begin
            counter <= counter + 1;
        end
    end
    // Note: When GE or weight_load_DONE is LOW, do nothing (counter does not increment)
end

endmodule