`timescale 1ns / 1ps
module s_read_out( bram_read_clk, s, s_ram, s_write_addr, s_write_enb);


import PSL_pkg :: *;


input bram_read_clk;

output reg s_ram;
output reg [s_bram_addr_bit_width-1:0] s_write_addr;
output reg s_write_enb;

input [num_pbits-1:0] s;   
    
int ss = 0;
always @ (posedge bram_read_clk) begin

s_write_enb <= 1'b1;
s_write_addr <= ss;
s_ram <= s[ss];

ss = ss+1;

    if (ss== num_pbits) begin 
     ss = 0;
    end


end


endmodule
