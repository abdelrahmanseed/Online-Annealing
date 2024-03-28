`timescale 1ns / 1ps

module PSL( reset, sys_clock_clk_n, sys_clock_clk_p, pci_exp_rxn, pci_exp_rxp, pci_exp_txn, pci_exp_txp, pcie_clk_clk_n, pcie_clk_clk_p, pcie_rst_n);

import PSL_pkg :: *;

input reset;
input sys_clock_clk_n;
input sys_clock_clk_p;

//PCIe
input [7:0] pci_exp_rxn;
input [7:0] pci_exp_rxp;
output [7:0] pci_exp_txn;
output [7:0] pci_exp_txp;
input [0:0] pcie_clk_clk_n;
input [0:0] pcie_clk_clk_p;
input pcie_rst_n;

wire axi_clk;
wire bram_read_clk;
wire [num_pbits-1:0] s;

//tictoc counter
wire reset_tictoc; 
wire [31:0] tictoc_counter_limit;
wire only_weight_load_DONE;
wire weight_load_DONE;

//flip_counter
wire reset_ref_counter;
wire reset_flip_counter;
wire enable_flip_counter;
wire [available_clocks*16-1:0] counter;

wire clock1, clock2, clock3, clock4, clock5;
wire [j_bit_width-1:0] J_n [length_J_array-1:0];
wire [h_bit_width-1:0] h_n [num_pbits-1:0];
wire [beta_bit_width-1:0] beta_v [num_beta-1:0];

wire [31:0]J_ram;
wire [j_bram_addr_bit_width-1:0] J_read_addr;
wire [31:0] h_ram;
wire [31:0] beta_ram;


wire [h_bram_addr_bit_width-1:0] h_read_addr;
wire [beta_bram_addr_bit_width-1:0] beta_read_addr;

wire s_ram;
wire [s_bram_addr_bit_width-1:0] s_write_addr;
wire s_write_enb;
  
wire GE; //global_enable
wire frozen; // flag to detect if p-bits are frozen after TICTOC time is elasped

wire weight_read_trigger;

wire [31:0] num_clk_cycles;

//wire [269:0] beta_v;


wire RESET_beta; // RESET flag to start a new experiment

wire [beta_bit_width-1:0] beta; // Corrected output to match expected width

wire beta_load_DONE;


serialize_J sJ ( .axi_clk(axi_clk), .bram_read_clk(bram_read_clk), .weight_read_trigger(weight_read_trigger), .J_ram(J_ram), .J_read_addr(J_read_addr), .J_n(J_n), .weight_load_DONE(only_weight_load_DONE));
serialize_h sH ( .axi_clk(axi_clk), .bram_read_clk(bram_read_clk), .weight_read_trigger(weight_read_trigger), .h_ram(h_ram), .h_read_addr(h_read_addr), .h_n(h_n));
serialize_beta sB (.axi_clk(axi_clk), .bram_read_clk(bram_read_clk), .weight_read_trigger(weight_read_trigger), .beta_ram(beta_ram), .beta_read_addr(beta_read_addr), .beta_v(beta_v), .beta_load_DONE(beta_load_DONE));

assign weight_load_DONE = only_weight_load_DONE & beta_load_DONE;

tictoc_counter tc (.reset_tictoc(reset_tictoc), .tictoc_counter_limit(tictoc_counter_limit), .tictoc_clk(axi_clk), .global_enable(GE), .complete(frozen)); // this module doesn't depend on any other module or ref_counter
beta_counter bc (.GE(GE), .weight_load_DONE(weight_load_DONE), .beta(beta), .beta_v(beta_v), .CLK(axi_clk), .RESET(RESET_beta),  .num_clk_cycles(num_clk_cycles));

flip_counter fp (.reset_ref_counter(reset_ref_counter), .ref_clk(axi_clk), .reset_flip_counter(reset_flip_counter), .enable_flip_counter(enable_flip_counter)); //this triggers the flip counter in pbitc

design_1_wrapper wrapper
       (.J_ram(J_ram),
        .J_read_addr(J_read_addr),
        .axi_clk(axi_clk),
        .bram_read_clk(bram_read_clk),
        .clock1_0(clock1),
        .clock2_0(clock2),
        .clock3_0(clock3),
        .clock4_0(clock4),
        .clock5_0(clock5),
        .flip_counter_value_slv_0(counter),
        .frozen_value_0(frozen),
        .h_ram(h_ram),
        .h_read_addr(h_read_addr),
        .pci_exp_rxn(pci_exp_rxn),
        .pci_exp_rxp(pci_exp_rxp),
        .pci_exp_txn(pci_exp_txn),
        .pci_exp_txp(pci_exp_txp),
        .pcie_clk_clk_n(pcie_clk_clk_n),
        .pcie_clk_clk_p(pcie_clk_clk_p),
        .pcie_rst_n(pcie_rst_n),
        .reset(reset),
        .reset_ref_counter_value_0(reset_ref_counter),
        .reset_tictoc_value_0(reset_tictoc),
        .s_ram(s_ram),
        .s_write_addr(s_write_addr),
        .s_write_enb(s_write_enb),
        .sys_clock_clk_n(sys_clock_clk_n),
        .sys_clock_clk_p(sys_clock_clk_p),
        .tictoc_counter_limit_value_0(tictoc_counter_limit),
        .weight_load_done_value_0(weight_load_DONE),
        .weight_read_trigger_value_0(weight_read_trigger),
        .beta_ram(beta_ram),
        .beta_read_addr(beta_read_addr),
        .num_clk_cycles_value_0(num_clk_cycles),
        .reset_beta_reset_beta_0(RESET_beta)
        );
        

     
        
      
                
pbitc #(.seed(32'b10100010111001100100100111111110)) bit0 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[0]), .J_n0(J_n[0]),.J_n1(J_n[1]),.J_n2(J_n[2]),.J_n3(J_n[3]),.J_n4(J_n[4]),.J_n5(J_n[4]),.s_in0(s[1]),.s_in1(s[3]),.s_in2(s[9]),.s_in3(s[18]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[0]), .reset_flip_counter(reset_flip_counter), .enable_flip_counter(enable_flip_counter), .counter(counter [15 -: 16])); 
pbit #(.seed(32'b11101011101011111100100010110011)) bit2 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[2]), .J_n0(J_n[5]),.J_n1(J_n[10]),.J_n2(J_n[11]),.J_n3(J_n[12]),.J_n4(J_n[9]),.J_n5(J_n[13]),.s_in0(s[1]),.s_in1(s[5]),.s_in2(s[11]),.s_in3(s[20]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[2])); 
pbit #(.seed(32'b11000001010000000111111100101001)) bit4 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[4]), .J_n0(J_n[6]),.J_n1(J_n[14]),.J_n2(J_n[18]),.J_n3(J_n[19]),.J_n4(J_n[20]),.J_n5(J_n[21]),.s_in0(s[1]),.s_in1(s[3]),.s_in2(s[5]),.s_in3(s[7]),.s_in4(s[13]),.s_in5(s[22]),.s_out(s[4])); 
pbit #(.seed(32'b01011010001010001101100111001100)) bit6 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[6]), .J_n0(J_n[15]),.J_n1(J_n[26]),.J_n2(J_n[27]),.J_n3(J_n[28]),.J_n4(J_n[25]),.J_n5(J_n[29]),.s_in0(s[3]),.s_in1(s[7]),.s_in2(s[15]),.s_in3(s[24]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[6])); 
pbit #(.seed(32'b00100001001111110001100011101011)) bit8 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[8]), .J_n0(J_n[22]),.J_n1(J_n[30]),.J_n2(J_n[33]),.J_n3(J_n[34]),.J_n4(J_n[35]),.J_n5(J_n[35]),.s_in0(s[5]),.s_in1(s[7]),.s_in2(s[17]),.s_in3(s[26]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[8])); 
pbit #(.seed(32'b10011111110111110111010010001011)) bit19 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[19]), .J_n0(J_n[8]),.J_n1(J_n[42]),.J_n2(J_n[63]),.J_n3(J_n[66]),.J_n4(J_n[67]),.J_n5(J_n[68]),.s_in0(s[1]),.s_in1(s[10]),.s_in2(s[18]),.s_in3(s[20]),.s_in4(s[22]),.s_in5(1'b0),.s_out(s[19])); 
pbit #(.seed(32'b00111001010111001111010010001001)) bit21 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[21]), .J_n0(J_n[17]),.J_n1(J_n[49]),.J_n2(J_n[64]),.J_n3(J_n[71]),.J_n4(J_n[72]),.J_n5(J_n[70]),.s_in0(s[3]),.s_in1(s[12]),.s_in2(s[18]),.s_in3(s[22]),.s_in4(s[24]),.s_in5(1'b0),.s_out(s[21])); 
pbit #(.seed(32'b10000100101100011110100111110000)) bit23 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[23]), .J_n0(J_n[24]),.J_n1(J_n[54]),.J_n2(J_n[69]),.J_n3(J_n[73]),.J_n4(J_n[75]),.J_n5(J_n[76]),.s_in0(s[5]),.s_in1(s[14]),.s_in2(s[20]),.s_in3(s[22]),.s_in4(s[26]),.s_in5(1'b0),.s_out(s[23])); 
pbit #(.seed(32'b10010100010011010011000000011110)) bit25 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock1), .beta(beta), .h_n(h_n[25]), .J_n0(J_n[32]),.J_n1(J_n[60]),.J_n2(J_n[74]),.J_n3(J_n[77]),.J_n4(J_n[79]),.J_n5(J_n[78]),.s_in0(s[7]),.s_in1(s[16]),.s_in2(s[22]),.s_in3(s[24]),.s_in4(s[26]),.s_in5(1'b0),.s_out(s[25])); 
pbitc #(.seed(32'b00010101011011011010100000000100)) bit1 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[1]), .J_n0(J_n[0]),.J_n1(J_n[5]),.J_n2(J_n[6]),.J_n3(J_n[7]),.J_n4(J_n[8]),.J_n5(J_n[9]),.s_in0(s[0]),.s_in1(s[2]),.s_in2(s[4]),.s_in3(s[10]),.s_in4(s[19]),.s_in5(1'b0),.s_out(s[1]), .reset_flip_counter(reset_flip_counter), .enable_flip_counter(enable_flip_counter), .counter(counter [31 -: 16])); 
pbit #(.seed(32'b00100110001000001001111010010000)) bit3 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[3]), .J_n0(J_n[1]),.J_n1(J_n[14]),.J_n2(J_n[15]),.J_n3(J_n[16]),.J_n4(J_n[17]),.J_n5(J_n[13]),.s_in0(s[0]),.s_in1(s[4]),.s_in2(s[6]),.s_in3(s[12]),.s_in4(s[21]),.s_in5(1'b0),.s_out(s[3])); 
pbit #(.seed(32'b11001110110111111011101111011010)) bit5 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[5]), .J_n0(J_n[10]),.J_n1(J_n[18]),.J_n2(J_n[22]),.J_n3(J_n[23]),.J_n4(J_n[24]),.J_n5(J_n[25]),.s_in0(s[2]),.s_in1(s[4]),.s_in2(s[8]),.s_in3(s[14]),.s_in4(s[23]),.s_in5(1'b0),.s_out(s[5])); 
pbit #(.seed(32'b01010111100111100101011010001011)) bit7 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[7]), .J_n0(J_n[19]),.J_n1(J_n[26]),.J_n2(J_n[30]),.J_n3(J_n[31]),.J_n4(J_n[32]),.J_n5(J_n[29]),.s_in0(s[4]),.s_in1(s[6]),.s_in2(s[8]),.s_in3(s[16]),.s_in4(s[25]),.s_in5(1'b0),.s_out(s[7])); 
pbit #(.seed(32'b00010010000101011111100100010111)) bit9 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[9]), .J_n0(J_n[2]),.J_n1(J_n[36]),.J_n2(J_n[37]),.J_n3(J_n[38]),.J_n4(J_n[39]),.J_n5(J_n[39]),.s_in0(s[0]),.s_in1(s[10]),.s_in2(s[12]),.s_in3(s[18]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[9])); 
pbit #(.seed(32'b00110011100001111101110010110111)) bit11 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[11]), .J_n0(J_n[11]),.J_n1(J_n[40]),.J_n2(J_n[44]),.J_n3(J_n[45]),.J_n4(J_n[43]),.J_n5(J_n[46]),.s_in0(s[2]),.s_in1(s[10]),.s_in2(s[14]),.s_in3(s[20]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[11])); 
pbit #(.seed(32'b01100010100111010001101101101100)) bit13 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[13]), .J_n0(J_n[20]),.J_n1(J_n[41]),.J_n2(J_n[47]),.J_n3(J_n[50]),.J_n4(J_n[51]),.J_n5(J_n[52]),.s_in0(s[4]),.s_in1(s[10]),.s_in2(s[12]),.s_in3(s[14]),.s_in4(s[16]),.s_in5(s[22]),.s_out(s[13])); 
pbit #(.seed(32'b01111011011110001101100101000111)) bit15 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[15]), .J_n0(J_n[27]),.J_n1(J_n[48]),.J_n2(J_n[56]),.J_n3(J_n[57]),.J_n4(J_n[55]),.J_n5(J_n[58]),.s_in0(s[6]),.s_in1(s[12]),.s_in2(s[16]),.s_in3(s[24]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[15])); 
pbit #(.seed(32'b00011110000011000011010000110110)) bit17 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock2), .beta(beta), .h_n(h_n[17]), .J_n0(J_n[33]),.J_n1(J_n[53]),.J_n2(J_n[59]),.J_n3(J_n[61]),.J_n4(J_n[62]),.J_n5(J_n[62]),.s_in0(s[8]),.s_in1(s[14]),.s_in2(s[16]),.s_in3(s[26]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[17])); 
pbitc #(.seed(32'b01001001011110010100101101011000)) bit10 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[10]), .J_n0(J_n[7]),.J_n1(J_n[36]),.J_n2(J_n[40]),.J_n3(J_n[41]),.J_n4(J_n[42]),.J_n5(J_n[43]),.s_in0(s[1]),.s_in1(s[9]),.s_in2(s[11]),.s_in3(s[13]),.s_in4(s[19]),.s_in5(1'b0),.s_out(s[10]), .reset_flip_counter(reset_flip_counter), .enable_flip_counter(enable_flip_counter), .counter(counter [47 -: 16])); 
pbit #(.seed(32'b00000101011111100010110010111001)) bit12 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[12]), .J_n0(J_n[16]),.J_n1(J_n[37]),.J_n2(J_n[47]),.J_n3(J_n[48]),.J_n4(J_n[49]),.J_n5(J_n[46]),.s_in0(s[3]),.s_in1(s[9]),.s_in2(s[13]),.s_in3(s[15]),.s_in4(s[21]),.s_in5(1'b0),.s_out(s[12])); 
pbit #(.seed(32'b10010110011110000000001110101010)) bit14 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[14]), .J_n0(J_n[23]),.J_n1(J_n[44]),.J_n2(J_n[50]),.J_n3(J_n[53]),.J_n4(J_n[54]),.J_n5(J_n[55]),.s_in0(s[5]),.s_in1(s[11]),.s_in2(s[13]),.s_in3(s[17]),.s_in4(s[23]),.s_in5(1'b0),.s_out(s[14])); 
pbit #(.seed(32'b11000000011001011100101000001111)) bit16 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[16]), .J_n0(J_n[31]),.J_n1(J_n[51]),.J_n2(J_n[56]),.J_n3(J_n[59]),.J_n4(J_n[60]),.J_n5(J_n[58]),.s_in0(s[7]),.s_in1(s[13]),.s_in2(s[15]),.s_in3(s[17]),.s_in4(s[25]),.s_in5(1'b0),.s_out(s[16])); 
pbit #(.seed(32'b01000111111100111101001001101111)) bit18 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[18]), .J_n0(J_n[3]),.J_n1(J_n[38]),.J_n2(J_n[63]),.J_n3(J_n[64]),.J_n4(J_n[65]),.J_n5(J_n[65]),.s_in0(s[0]),.s_in1(s[9]),.s_in2(s[19]),.s_in3(s[21]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[18])); 
pbit #(.seed(32'b00110111111111010101011000100011)) bit20 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[20]), .J_n0(J_n[12]),.J_n1(J_n[45]),.J_n2(J_n[66]),.J_n3(J_n[69]),.J_n4(J_n[68]),.J_n5(J_n[70]),.s_in0(s[2]),.s_in1(s[11]),.s_in2(s[19]),.s_in3(s[23]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[20])); 
pbit #(.seed(32'b01111100100011010001010000100101)) bit22 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[22]), .J_n0(J_n[21]),.J_n1(J_n[52]),.J_n2(J_n[67]),.J_n3(J_n[71]),.J_n4(J_n[73]),.J_n5(J_n[74]),.s_in0(s[4]),.s_in1(s[13]),.s_in2(s[19]),.s_in3(s[21]),.s_in4(s[23]),.s_in5(s[25]),.s_out(s[22])); 
pbit #(.seed(32'b11101010100011110011111101000101)) bit24 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[24]), .J_n0(J_n[28]),.J_n1(J_n[57]),.J_n2(J_n[72]),.J_n3(J_n[77]),.J_n4(J_n[76]),.J_n5(J_n[78]),.s_in0(s[6]),.s_in1(s[15]),.s_in2(s[21]),.s_in3(s[25]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[24])); 
pbit #(.seed(32'b00111111001110101100010001111000)) bit26 (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock3), .beta(beta), .h_n(h_n[26]), .J_n0(J_n[34]),.J_n1(J_n[61]),.J_n2(J_n[75]),.J_n3(J_n[79]),.J_n4(J_n[80]),.J_n5(J_n[80]),.s_in0(s[8]),.s_in1(s[17]),.s_in2(s[23]),.s_in3(s[25]),.s_in4(1'b0),.s_in5(1'b0),.s_out(s[26])); 



s_read_out sR (.bram_read_clk(bram_read_clk), .s(s), .s_ram(s_ram), .s_write_addr(s_write_addr), .s_write_enb(s_write_enb));


endmodule
