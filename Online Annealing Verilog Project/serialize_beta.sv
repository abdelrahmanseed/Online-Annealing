`timescale 1ns / 1ps


module serialize_beta(axi_clk, bram_read_clk, weight_read_trigger, beta_ram, beta_read_addr,  beta_v, beta_load_DONE);

import PSL_pkg :: *;

input axi_clk;
input bram_read_clk;
input weight_read_trigger;

input [31:0] beta_ram;
output reg[beta_bram_addr_bit_width-1:0] beta_read_addr;
output reg beta_load_DONE;

output reg [beta_bit_width-1:0] beta_v [num_beta-1:0];

enum {WAIT_TRIGGER, READ_COEFF} state;
initial state = WAIT_TRIGGER;
reg READ_START=0;
reg [W_R_clk_ratio-1:0] READ_FLAG =0;
int kB =0;
     
     
always @ (posedge bram_read_clk) begin   
    case (state)
      READ_COEFF  : begin
                    beta_load_DONE <=0;
                    for (kB =0; kB< num_beta; kB = kB+1) begin
                      if (kB== num_beta -1)
                         beta_v[kB] <= beta_ram;
                      else beta_v[kB] <= beta_v[kB+1]; 
                    end
                    
                    if (beta_read_addr == num_beta-1+2) begin
                      state <= WAIT_TRIGGER;
                    end
                    else beta_read_addr <= beta_read_addr +1;             
                    end 
         
     WAIT_TRIGGER  : begin
                     beta_load_DONE <= 1; 
                     beta_read_addr  <= 0;
                     if(READ_START) state <= READ_COEFF;
                     end
     default:        beta_load_DONE <=0;
     endcase
     
     if(READ_FLAG!=0) READ_START <= 1;
     else READ_START<=0;
                     
end


// just to hold the fast AXI clk's trigger sufficient enough cycles for the slow BRAM read clk
logic[4:0] i;
always @ (posedge axi_clk) begin 
        READ_FLAG[0]<=weight_read_trigger;
        for (i =0; i< W_R_clk_ratio-1; i = i+1) begin
           READ_FLAG[i+1]<=READ_FLAG[i]; 
        end
end

endmodule
