`timescale 1ns / 1ps
(* use_dsp = "yes" *) module beta_scaler (unscaled_Iin, beta, scaled_Iin);

import PSL_pkg :: *;
parameter right_shift_bits = 3;

input signed [h_bit_width + 3 - 1:0] unscaled_Iin; // word length = h_bit_width + 3 (i.e. s[6+3][3])
input signed [beta_bit_width - 1:0] beta; // word length = beta_bit_width (i.e. s[6][3])
output reg signed [i_bit_width - 1:0] scaled_Iin; // word length = i_bit_width (i.e. s[6][3])

//Temporary variable for full precision result before scaling back
reg signed [h_bit_width + 3 + beta_bit_width -1:0] full_precision_result; // total word length (WL) = WL1 + WL2 = 13 + 10 = 23 (i.e. s[16][6])
reg signed [h_bit_width + 3 + beta_bit_width - right_shift_bits -1:0] scaled_Iin_temp; // word length 20 (i.e. s[16][3])
reg  [h_bit_width + 3 + beta_bit_width - right_shift_bits -1:0] nmin = 20'b11111111111000000001; //-63.875 in s[16][3]
reg  [h_bit_width + 3 + beta_bit_width - right_shift_bits -1:0] pmax = 20'b00000000000111111111; //63.875 in s[16][3]

always @*  begin

    full_precision_result = unscaled_Iin * beta; // Perform the multiplication in full precision
    scaled_Iin_temp = full_precision_result >>> right_shift_bits; // Scale back the result to match the fixed-point format

    if ($signed(scaled_Iin_temp) > $signed(pmax))
        scaled_Iin <= 10'b0111111111; //63.875 in s[6][3]
    else if ($signed(scaled_Iin_temp) < $signed(nmin))
        scaled_Iin <= 10'b1000000001; //-63.875 in s[6][3]
    else
        scaled_Iin <= scaled_Iin_temp[i_bit_width-1:0];
end

endmodule