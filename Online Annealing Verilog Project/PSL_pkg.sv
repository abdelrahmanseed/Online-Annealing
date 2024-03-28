package PSL_pkg;

    localparam j_bit_width = 10; //single weight bit width
    localparam h_bit_width = 10; //single h bit width
    localparam beta_bit_width = 10; //single beta bit width
    localparam i_bit_width = 8; //single input bit width
    localparam num_beta = 5; // number of beta values
    
    localparam j_bram_addr_bit_width = 15; //address bit width of J BRAM
    localparam h_bram_addr_bit_width = 14; //address bit width of h BRAM
    localparam beta_bram_addr_bit_width = 14; //address bit width of h BRAM
    localparam s_bram_addr_bit_width = 14; //address bit width of s BRAM
    
    localparam n = 32; //LUT_out and xoshiro_out bit width
    localparam num_pbits = 27; //total number of p-bits
    localparam length_J_array = 81;
    localparam available_clocks =3;
    localparam W_R_clk_ratio = 3; // ratio between axi write clk and BRAM read clk frequency

    //localparam [n-1:0] seed = 32'b10101011110011000110111011111110;

endpackage : PSL_pkg