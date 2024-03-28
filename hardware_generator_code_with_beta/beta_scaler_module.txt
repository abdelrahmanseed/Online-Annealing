`timescale 1ns / 1ps
(* use_dsp = "yes" *) module beta_scaler (unscaled_Iin, beta, scaled_Iin);

import PSL_pkg :: *;
parameter right_shift_bits = 7;

input signed [h_bit_width + 3 - 1:0] unscaled_Iin; // word length = h_bit_width + 3 (i.e. s[4+3][5])
input signed [beta_bit_width - 1:0] beta; // word length = beta_bit_width (i.e. s[4][5])
output reg signed [i_bit_width - 1:0] scaled_Iin; // word length = i_bit_width (i.e. s[4][3])

//Temporary variable for full precision result before scaling back
reg signed [h_bit_width + 3 + beta_bit_width -1:0] full_precision_result; // total word length (WL) = WL1 + WL2 = 13 + 10 = 23 (i.e. s[12][10])
reg signed [h_bit_width + 3 + beta_bit_width - right_shift_bits -1:0] scaled_Iin_temp; // word length 16 (i.e. s[12][3])
reg  [h_bit_width + 3 + beta_bit_width - right_shift_bits -1:0] nmin = 16'b1111111110000001; //-15.875 in s[12][3]
reg  [h_bit_width + 3 + beta_bit_width - right_shift_bits -1:0] pmax = 16'b0000000001111111; //15.875 in s[12][3]

always @*  begin

    full_precision_result = unscaled_Iin * beta; // Perform the multiplication in full precision
    scaled_Iin_temp = full_precision_result >>> right_shift_bits; // Scale back the result to match the fixed-point format

    if ($signed(scaled_Iin_temp) > $signed(pmax))
        scaled_Iin <= 8'b01111111; //15.875 in s[4][3]
    else if ($signed(scaled_Iin_temp) < $signed(nmin))
        scaled_Iin <= 8'b10000001; //-15.875 in s[4][3]
    else
        scaled_Iin <= scaled_Iin_temp[i_bit_width-1:0];
end

endmodule