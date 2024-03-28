`timescale 1ns / 1ps
module serialize_J ( axi_clk, bram_read_clk, weight_read_trigger, J_ram, J_read_addr, J_n, weight_load_DONE);


import PSL_pkg :: *;

input axi_clk;
input bram_read_clk;
input weight_read_trigger;
output reg weight_load_DONE;

input [31:0]J_ram;
output reg [j_bram_addr_bit_width-1:0] J_read_addr;

output reg [j_bit_width-1:0] J_n [length_J_array-1:0];

enum {WAIT_TRIGGER, READ_COEFF} state;
initial state = WAIT_TRIGGER;
reg READ_START=0;
reg [W_R_clk_ratio-1:0] READ_FLAG =0;
int jh =0;
     
always @ (posedge bram_read_clk) begin   
    case (state)
      READ_COEFF  : begin
                    weight_load_DONE <=0;
                    for (jh =0; jh< length_J_array; jh = jh+1) begin
                      if (jh== length_J_array -1)
                         J_n[jh] <= J_ram;
                      else J_n[jh] <= J_n[jh+1]; 
                    end
                    
                    if (J_read_addr == length_J_array-1+2) //making up for 2 clock cycle latecency
                      state <= WAIT_TRIGGER;
                    else J_read_addr <= J_read_addr +1;             
                    end 
         
     WAIT_TRIGGER  : begin 
                     weight_load_DONE<=1;
                     J_read_addr  <= 0;
                     if(READ_START) state <= READ_COEFF; 
                     end
    default:         weight_load_DONE <=0;
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
