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

%fixed point format of WEIGHT bits ([s]a.b) , NOT input bits!!
weight_a  = 6;
weight_b = 3;

h_bit_width = weight_a + weight_b +1 ;

fileID = fopen('weight_module.txt','w');

fprintf(fileID,'`timescale 1ns / 1ps\nmodule weight (');


for p =1:max_num_neighbors
    fprintf(fileID,'s_in%s, ',int2str(p-1));
end

fprintf(fileID,'h_n, ');


for p =1:max_num_neighbors
    fprintf(fileID,'J_n%s, ',int2str(p-1));
end

fprintf(fileID,'beta, Iin);\n');



fprintf(fileID,'import PSL_pkg :: *;\n\noutput reg[i_bit_width-1:0] Iin;');
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


fprintf(fileID,'\n\n// Temporary ports ');
fprintf(fileID,'\n// these are defined for sign extension of J''s and h. This way there will be no overflow no matter what ');
overflow_b = ceil(log2(max_num_neighbors+1));

fprintf(fileID,'\nwire [j_bit_width-1+%s:0] ',int2str(overflow_b));

for p =1:max_num_neighbors
    if p == max_num_neighbors
        fprintf(fileID,'J_n%s_temp;',int2str(p-1));
    else
        fprintf(fileID,'J_n%s_temp, ',int2str(p-1));
    end
end


fprintf(fileID,'\nwire [h_bit_width-1+%s:0] h_temp;\n\n\n',int2str(overflow_b));


for p =1:max_num_neighbors
    fprintf(fileID,'assign J_n%s_temp = {{%s{J_n%s[j_bit_width-1]}},J_n%s};\n',int2str(p-1),int2str(overflow_b),int2str(p-1),int2str(p-1));
end
fprintf(fileID,'assign h_temp =    {{%s{h_n[h_bit_width-1]}},h_n};\n',int2str(overflow_b));



fprintf(fileID,'\n\nreg  [h_bit_width-1+%s:0] unscaled_Iin;',int2str(overflow_b));


fprintf(fileID,'\n\nalways @*  begin\n');
fprintf(fileID,'    unscaled_Iin = ');

for p =1:max_num_neighbors
    fprintf(fileID,'(s_in%s ? J_n%s_temp :%s''b0) + ',int2str(p-1),int2str(p-1),int2str(overflow_b + h_bit_width));
end

fprintf(fileID,'h_temp;');


fprintf(fileID,'\nend\n');

fprintf(fileID,'\nbeta_scaler bsc (.unscaled_Iin(unscaled_Iin), .beta(beta), .scaled_Iin(Iin));\n');
fprintf(fileID,'\nendmodule');

fclose(fileID);

