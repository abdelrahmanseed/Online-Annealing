`timescale 1ns / 1ps
module xoshiro (clk, xoshiro_out);
  parameter n=2; 
  parameter [n-1:0] seed = 32'b10101011110011000110111011111110; 
  input clk;
  output [n-1:0] xoshiro_out;

            logic [3:0][n-1:0] s = '0;
            logic [3:0][n-1:0] s_reg;
            logic [n-1:0] prng = '0;
//            reg reseed =1'b0;
            
            initial   s_reg[0][n-1:0] = seed;
            
            always @*
            begin
                s[2] = s_reg[2] ^ s_reg[0];
                s[3] = s_reg[3] ^ s_reg[1];
                s[1] = s_reg[1] ^ s[2];
                s[0] = s_reg[0] ^ s[3];
                s[2] = s[2] ^ (s_reg[1] << 9);
                s[3] = {s[3][20:0],s[3][31:21]};
            end

            always @(posedge(clk))
            begin
                s_reg[0] <= s[0];
                s_reg[1] <= s[1];
                s_reg[2] <= s[2];
                s_reg[3] <= s[3];
                prng <= s[0] + s[3];

//                if (reseed == 1'b1) begin
                  
//                end
            end

            assign xoshiro_out = prng[n-1:0];
  


endmodule


