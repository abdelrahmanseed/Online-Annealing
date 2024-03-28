`timescale 1ns / 1ps
module serialize_h ( axi_clk, bram_read_clk, weight_read_trigger, h_ram, h_read_addr,  h_n);

import PSL_pkg :: *;

input axi_clk;
input bram_read_clk;
input weight_read_trigger;

input [31:0]h_ram;
output reg[h_bram_addr_bit_width-1:0] h_read_addr;

output reg [h_bit_width-1:0] h_n [num_pbits-1:0];

enum {WAIT_TRIGGER, READ_COEFF} state;
initial state = WAIT_TRIGGER;
reg READ_START=0;
reg [W_R_clk_ratio-1:0] READ_FLAG =0;
int kh =0;
     
     
always @ (posedge bram_read_clk) begin   
    case (state)
      READ_COEFF  : begin

                    for (kh =0; kh< num_pbits; kh = kh+1) begin
                      if (kh== num_pbits -1)
                         h_n[kh] <= h_ram;
                      else h_n[kh] <= h_n[kh+1]; 
                    end
                    
                    if (h_read_addr == num_pbits-1+2) begin
                      state <= WAIT_TRIGGER;
                    end
                    else h_read_addr <= h_read_addr +1;             
                    end 
         
     WAIT_TRIGGER  : begin 
                     h_read_addr  <= 0;
                     if(READ_START) state <= READ_COEFF;
                     end
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
