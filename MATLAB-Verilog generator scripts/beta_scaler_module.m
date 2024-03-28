clc
clearvars

load L5.mat
%J = [0 -1 -1; -1 0 -1 ;-1 -1 0 ]; % weight matrix
% J = [ 0    -1   -1    1    2
%     -1     0   -1    1    2
%     -1    -1    0    1    2
%      1     1    1    0   -2
%      2     2    2   -2    0];
W = J;
%% tuning parameters
%LUT_type = 'full';  % full for regular LUT 
LUT_type = 'short'; % 2's complement LUT

max_num_neighbors =max(degree(graph(W)));
overflow_b = ceil(log2(max_num_neighbors+1));

%fixed point format of WEIGHT and beta bits ([s]a.b) , NOT input bits!!
weight_a  =4;
weight_b = 5;
beta_a  = 4;
beta_b = 5;
%fixed point format of input bits ([s]a.b)// has to be the same as LUT
in_a  = 4; % this is the chopped version of I_i after scaling
in_b =3;

right_shift_bits = weight_b + beta_b - in_b; %% the ignored bits from LSB

if(right_shift_bits<0), error('input fraction cannot be more than weight fraction + beta fraction'); end
if(in_a > 1+weight_a+overflow_b+beta_a), error('input integer cannot be more than (weight integer + overflow + beta integer + 1)'); end


h_bit_width = weight_a + weight_b +1 ;
i_bit_width = in_a + in_b +1;
beta_bit_width = beta_a + beta_b +1;

%enter range of analog input
if strcmp(LUT_type,'full')
    in_min = -2^in_a;  %enter your analog lowest input
elseif strcmp(LUT_type,'short')
    in_min = -2^in_a + 2^(-in_b);  %enter your analog lowest input
end
in_max = 2^in_a - 2^(-in_b);  %enter your highest analog input

% nmin = dec2q(in_min, 1+weight_a+overflow_b+beta_a, in_b,'bin')
% pmax = dec2q(in_max, 1+weight_a+overflow_b+beta_a, in_b,'bin')
nmin = bin(fi(in_min, 1, 2+weight_a+overflow_b+beta_a+ in_b, in_b,'RoundingMethod','convergent'));
pmax = bin(fi(in_max, 1, 2+weight_a+overflow_b+beta_a +in_b, in_b,'RoundingMethod','convergent'));

fileID = fopen('beta_scaler_module.txt','w');

fprintf(fileID,'`timescale 1ns / 1ps\n(* use_dsp = "yes" *) module beta_scaler (');
fprintf(fileID,'unscaled_Iin, beta, scaled_Iin);\n');



fprintf(fileID,'\nimport PSL_pkg :: *;');
fprintf(fileID,'\nparameter right_shift_bits = %s;',int2str(right_shift_bits));


fprintf(fileID,'\n\ninput signed [h_bit_width + %s - 1:0] unscaled_Iin;',int2str(overflow_b));
fprintf(fileID,' // word length = h_bit_width + %s (i.e. s[%s+%s][%s])', int2str(overflow_b), int2str(weight_a),int2str(overflow_b),int2str(weight_b));
fprintf(fileID,'\ninput signed [beta_bit_width - 1:0] beta;');
fprintf(fileID,' // word length = beta_bit_width (i.e. s[%s][%s])', int2str(beta_a),int2str(beta_b));
fprintf(fileID,'\noutput reg signed [i_bit_width - 1:0] scaled_Iin;');
fprintf(fileID,' // word length = i_bit_width (i.e. s[%s][%s])', int2str(in_a),int2str(in_b));



fprintf(fileID,'\n\n//Temporary variable for full precision result before scaling back');
fprintf(fileID,'\nreg signed [h_bit_width + %s + beta_bit_width -1:0] full_precision_result;',int2str(overflow_b));
fprintf(fileID,' // total word length (WL) = WL1 + WL2 = %s + %s = %s (i.e. s[%s][%s])',int2str(1+weight_a+overflow_b+weight_b),int2str(1+beta_a+beta_b), int2str(1+weight_a+overflow_b+1+beta_a+weight_b+beta_b), int2str(1+weight_a+overflow_b+beta_a),int2str(weight_b+beta_b));
fprintf(fileID,'\nreg signed [h_bit_width + %s + beta_bit_width - right_shift_bits -1:0] scaled_Iin_temp;',int2str(overflow_b));
fprintf(fileID,' // word length %s (i.e. s[%s][%s])', int2str(1+weight_a+overflow_b+1+beta_a+weight_b+beta_b-right_shift_bits), int2str(1+weight_a+overflow_b+beta_a),int2str(in_b));
fprintf(fileID,'\nreg  [h_bit_width + %s + beta_bit_width - right_shift_bits -1:0] nmin = %s''b%s;',int2str(overflow_b),int2str(overflow_b+h_bit_width+beta_bit_width-right_shift_bits), nmin);
fprintf(fileID,' //%s in s[%s][%s]',num2str(in_min), int2str(1+weight_a+overflow_b+beta_a),int2str(in_b));
fprintf(fileID,'\nreg  [h_bit_width + %s + beta_bit_width - right_shift_bits -1:0] pmax = %s''b%s;',int2str(overflow_b),int2str(overflow_b+h_bit_width+beta_bit_width-right_shift_bits), pmax);
fprintf(fileID,' //%s in s[%s][%s]',num2str(in_max), int2str(1+weight_a+overflow_b+beta_a),int2str(in_b));



fprintf(fileID,'\n\nalways @*  begin\n');
fprintf(fileID,'\n    full_precision_result = unscaled_Iin * beta; // Perform the multiplication in full precision');
fprintf(fileID,'\n    scaled_Iin_temp = full_precision_result >>> right_shift_bits; // Scale back the result to match the fixed-point format');

fprintf(fileID,'\n\n    if ($signed(scaled_Iin_temp) > $signed(pmax))\n');

% input_nmin = dec2q(in_min,in_a, in_b,'bin')
% input_pmax = dec2q(in_max, in_a, in_b,'bin')
input_nmin = bin(fi(in_min,1, in_a+in_b+1, in_b,'RoundingMethod','convergent'));
input_pmax = bin(fi(in_max,1, in_a+in_b+1, in_b,'RoundingMethod','convergent'));

fprintf(fileID,'        scaled_Iin <= %s''b%s;', int2str(i_bit_width), input_pmax);
fprintf(fileID,' //%s in s[%s][%s]',num2str(in_max), int2str(in_a), int2str(in_b));
fprintf(fileID,'\n    else if ($signed(scaled_Iin_temp) < $signed(nmin))\n');
fprintf(fileID,'        scaled_Iin <= %s''b%s;', int2str(i_bit_width), input_nmin);
fprintf(fileID,' //%s in s[%s][%s]',num2str(in_min), int2str(in_a), int2str(in_b));
fprintf(fileID,'\n    else\n');
fprintf(fileID,'        scaled_Iin <= scaled_Iin_temp[i_bit_width-1:0];');

fprintf(fileID,'\nend\n\n');
fprintf(fileID,'endmodule');

fclose(fileID);

