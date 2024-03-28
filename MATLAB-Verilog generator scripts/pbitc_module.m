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
%RNG = 'LFSR';
RNG = 'xoshiro';


max_num_neighbors =max(degree(graph(W)));
% max_num_neighbors =5;

fileID = fopen('pbitc_module.txt','w');

fprintf(fileID,'`timescale 1ns / 1ps\nmodule pbitc (GE, weight_load_DONE, clk, beta, h_n, ');

for p =1:max_num_neighbors
    fprintf(fileID,'J_n%s, ',int2str(p-1));
end

for p =1:max_num_neighbors
    fprintf(fileID,'s_in%s, ',int2str(p-1));
end

fprintf(fileID,'s_out, reset_flip_counter, enable_flip_counter, counter);');


fprintf(fileID,'\n\nimport PSL_pkg :: *;\n');
fprintf(fileID,'parameter [n-1:0] seed = 32''b10101011110011001010101111001100;\n\n');
fprintf(fileID,'\ninput GE;\ninput clk;\n');
fprintf(fileID,'input weight_load_DONE;\n');
fprintf(fileID,'\ninput reset_flip_counter;');
fprintf(fileID,'\ninput enable_flip_counter;');
fprintf(fileID,'\noutput  [15:0] counter; \n');

fprintf(fileID,'\ninput [j_bit_width-1:0] ');

for p =1:max_num_neighbors
    if p == max_num_neighbors
        fprintf(fileID,'J_n%s;',int2str(p-1));
    else
        fprintf(fileID,'J_n%s, ',int2str(p-1));
    end
end


fprintf(fileID,'\ninput [h_bit_width-1:0] h_n;');
fprintf(fileID,'\ninput [beta_bit_width-1:0] beta;');
fprintf(fileID,'\ninput ');

for p =1:max_num_neighbors
    if p == max_num_neighbors
        fprintf(fileID,'s_in%s;',int2str(p-1));
    else
        fprintf(fileID,'s_in%s, ',int2str(p-1));
    end
end

fprintf(fileID,'\noutput reg s_out; \n');


fprintf(fileID,'\nlogic [i_bit_width-1:0] Iin;\n');
if strcmp(LUT_type,'short')
    fprintf(fileID,'logic [i_bit_width-1:0] Iin_LUT;\n');
end
fprintf(fileID, 'logic [n-1:0] LUT_out;\n');
fprintf(fileID,'logic [n-1:0] %s_out;\n',RNG);

fprintf(fileID,'\nweight weight_i (');
for p =1:max_num_neighbors
    fprintf(fileID,'.s_in%s(s_in%s), ',int2str(p-1),int2str(p-1));
end

fprintf(fileID,'.h_n(h_n), ');

for p =1:max_num_neighbors
    fprintf(fileID,'.J_n%s(J_n%s), ',int2str(p-1),int2str(p-1));
end
fprintf(fileID,'.beta(beta), .Iin(Iin));');


if strcmp(RNG,'LFSR')
    fprintf(fileID,'\n%s_n  #(.seed(seed), .n(n)) %s_i(.clk(clk), .%s_out(%s_out));\n',RNG,RNG,RNG,RNG);
elseif strcmp(RNG,'xoshiro')
    fprintf(fileID,'\n%s  #(.seed(seed), .n(n)) %s_i(.clk(clk), .%s_out(%s_out));\n',RNG,RNG,RNG,RNG);
end

if strcmp(LUT_type,'short')
    fprintf(fileID,'LUT_bias Lut_i (.Iin(Iin_LUT[i_bit_width-2:0]), .Out(LUT_out));\n');
elseif strcmp(LUT_type,'full')
    fprintf(fileID,'LUT_bias Lut_i (.Iin(Iin), .Out(LUT_out));\n');
end

fprintf(fileID,'\nreg [15:0] count = 0;');
fprintf(fileID,'\n\n// should this be triggered whenever we have a change in LUT_out, which changes whenever Input to the LUT changes\n');
fprintf(fileID, 'always @ (posedge clk or posedge reset_flip_counter) begin\n');

fprintf(fileID,'\n    if (reset_flip_counter)\n');
fprintf(fileID,'        count <= 0;\n');

fprintf(fileID,'    else if (GE ==1''b1 && weight_load_DONE == 1''b1) begin\n');

if strcmp(LUT_type,'short')

    fprintf(fileID, '\n         if (Iin[i_bit_width-1]==0) begin // positive input');

    if strcmp(RNG,'LFSR')
        fprintf(fileID,'\n               if (LUT_out == %s_out) s_out = 1''b0; // zeroed at tie other than all 1, irrespective of sign of input\n',RNG);
    else
        fprintf(fileID, '\n               if (LUT_out == 32''b11111111111111111111111111111111) s_out = 1''b1;');
        fprintf(fileID,'\n               else if (LUT_out == %s_out) s_out = 1''b0; // zeroed at tie other than all 1, irrespective of sign of input\n',RNG);
    end
    fprintf(fileID, '               else s_out = (LUT_out > %s_out) ? 1''b1 : 1''b0 ;\n',RNG);
    fprintf(fileID, '         end\n');

    fprintf(fileID, '\n         else if (Iin[i_bit_width-1]==1) begin //negative input');
    if strcmp(RNG,'LFSR')
        fprintf(fileID,'\n               if (LUT_out == %s_out) s_out = 1''b0; // zeroed at tie other than all 1, irrespective of sign of input\n',RNG);
    else

        fprintf(fileID, '\n               if (LUT_out == 32''b11111111111111111111111111111111) s_out = 1''b0;');
        fprintf(fileID,'\n               else if (LUT_out == %s_out) s_out = 1''b0; // zeroed at tie other than all 1, irrespective of sign of input\n',RNG);
    end
    fprintf(fileID, '               else s_out = (LUT_out > %s_out) ? 1''b0 : 1''b1 ;\n',RNG);
    fprintf(fileID, '         end\n');

elseif strcmp(LUT_type,'full')
    if strcmp(RNG,'LFSR')
        fprintf(fileID,'        s_out = (LUT_out > %s_out) ? 1''b1 : 1''b0 ;\n',RNG);
    else
        fprintf(fileID,'        if (LUT_out == 32''b11111111111111111111111111111111) s_out = 1''b1;\n');
        fprintf(fileID,'        else s_out = (LUT_out > %s_out) ? 1''b1 : 1''b0 ;\n',RNG);
    end
end

fprintf(fileID,'\n        if (enable_flip_counter)\n');
fprintf(fileID,'            count <= count + 1;\n');
fprintf(fileID,'    end\n');

fprintf(fileID,'end\n');

if strcmp(LUT_type,'short')
    fprintf(fileID,'\nalways@* begin\n');
    fprintf(fileID, '    if(Iin[i_bit_width-1]==1) Iin_LUT = -Iin; // 2''s complement: exact same implementation happens (tested) Iin_LUT = ~Iin + 1''b1;\n');
    fprintf(fileID,'    else Iin_LUT = Iin;\n');
    fprintf(fileID,'end\n');
end

fprintf(fileID,'\nassign counter = count;\n');
fprintf(fileID,'\nendmodule');
fclose(fileID);
