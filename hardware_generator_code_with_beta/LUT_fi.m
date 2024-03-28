clc
clearvars
close all

%% Author: Navid Anjum Aadit
% Date: 3/23/2022

%LUT_type = 'full';  % full for regular LUT
 LUT_type = 'short'; % 2's complement LUT

%fixed point format of signed input bits [s]a.b where s = 1
in_a  = 4;
in_b = 3;

%fixed point format of unsigned output bits [s]a.b where s = 0
out_a = 0;
out_b = 32;

%enter ranges of input I
if strcmp(LUT_type,'full')
    in_min = -2^in_a  % minimum possible input
elseif strcmp(LUT_type,'short')
    in_min = 0  % minimum possible input
end
in_max = 2^in_a -2^-in_b  % maximum possible input

%LUT output should be unsigned. Because:
%LFSR is also unsigned & (1+tanh)/2 has no negative values.


precision = 2^(-in_b)

all_inputs = in_min:precision:in_max;
SIGNED = 1; % we could have used sfi and ufi constructs but those don't allow to specify 'RoundingMethod'
if strcmp(LUT_type,'full')
    in = fi(all_inputs,SIGNED , in_a+in_b+1,in_b,'RoundingMethod','convergent'); % signed inputs
elseif strcmp(LUT_type,'short')
    in = fi(all_inputs,~SIGNED , in_a+in_b,in_b,'RoundingMethod','convergent'); % signed inputs
end
out = fi((1+tanh(all_inputs))/2,~SIGNED, out_a+out_b,out_b,'RoundingMethod','convergent'); % unsigned (1+tanh)/2

in_string= regexp(bin(in),'\d*','Match');
out_string = regexp(bin(out),'\d*','Match');

if strcmp(LUT_type,'full')
    in_format = int2str(1+in_a+in_b);
elseif strcmp(LUT_type,'short')
    in_format = int2str(in_a+in_b);
end

out_format = int2str(out_a+out_b);

%writes input and output to a text file
fileID = fopen('LUT_data.txt','w');

fprintf(fileID,'`timescale 1ns / 1ps\n');
fprintf(fileID,'module LUT_bias ( Iin, Out);\n');
fprintf(fileID,'\nimport PSL_pkg :: *;\n');

if strcmp(LUT_type,'full')
fprintf(fileID,'\ninput  [i_bit_width-1:0] Iin;\n');
elseif strcmp(LUT_type,'short')
    fprintf(fileID,'\ninput  [i_bit_width-2:0] Iin;\n');
end
fprintf(fileID,'output reg [n-1:0] Out;\n');

% fprintf(fileID,'// Originallyl I put Inp in the sensitivity list, but I could also replace it with *\n');
fprintf(fileID,'\nalways @ *//( posedge En )\n');
fprintf(fileID,'begin \n');
fprintf(fileID,'case (Iin)\n\n');

for k=1:length(in_string)
    fprintf(fileID,'%s''b%s : Out =', in_format, in_string{k});
    fprintf(fileID,'%s''b%s;\n',out_format, out_string{k});
end

fprintf(fileID,'\nendcase');
fprintf(fileID,'\nend');
fprintf(fileID,'\nendmodule');


fclose(fileID);



plot(all_inputs, out,'s')
