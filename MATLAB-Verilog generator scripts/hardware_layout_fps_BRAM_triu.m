clc
clear all
rng(1247)
close all

load L5.mat
%J = [0 -1 -1; -1 0 -1 ;-1 -1 0 ]; % weight matrix
% J = [ 0    -1   -1    1    2
%     -1     0   -1    1    2
%     -1    -1    0    1    2
%      1     1    1    0   -2
%      2     2    2   -2    0];
W = J;

max_num_neighbors =max(degree(graph(W)));
[triu_adjacency,J_indices] = get_triu_adjacency(W, max_num_neighbors);
n = 32;

%colorMap = readmatrix('colorMap.csv');
colorMap = double(pyrunfile("greedy_color_wrapper.py","colorMap",graph=full(W),strategy= 'DSATUR'));
fprintf('Number of unique colors: %d\n', numel(unique(colorMap)));
save colorMap.mat colorMap
available_colors = length(unique(colorMap));

G= graph(W);

fileID = fopen('hardcoder_test_BRAM_triu.txt','w');

%% RANDOM LFSR SEED
LFSR_min_seed = -2^(n-1);                                                      %minimum seed that can be given to an n bit LFSR
LFSR_max_seed =  2^(n-1) -1;                                                   %maximum seed that can be given to an n bit LFSR
r_seed = randi([LFSR_min_seed LFSR_max_seed],10000,1);                          %random seeds in an array within the range
seed = unique(r_seed) ;                                                        %unique seeds in an array, since our range is large, it may be always unique
seed = seed(randperm(length(seed)));
seed = dec2q(seed,n-1,0,'bin');                                                 %converts seed to n bit binary for fpga (as string)
counter =1;



for j = 1:available_colors
    same_color = find(colorMap==j);
    
    for m = 1:length(same_color)
        
        A = neighbors(G,same_color(m))';
        true_adj=[A zeros(1,max_num_neighbors-length(A))]; % true adjacency of the symmetric graph
        upper_adj = triu_adjacency(same_color(m),:); % adjacency considering upper triangular J
        
        if m ==1
            fprintf(fileID,'pbitc #(.seed(%s''b%s)) bit%s (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock%s), .beta(beta), .h_n(h_n[%s]), ',int2str(n), seed(counter,:),int2str(same_color(m)-1),int2str(j),int2str(same_color(m)-1));
        else
            fprintf(fileID,'pbit #(.seed(%s''b%s)) bit%s (.GE(GE), .weight_load_DONE(weight_load_DONE), .clk(clock%s), .beta(beta), .h_n(h_n[%s]), ',int2str(n), seed(counter,:),int2str(same_color(m)-1),int2str(j),int2str(same_color(m)-1));
        end
        
%         for q = 1:length(W)
        for p =1:max_num_neighbors
            fprintf(fileID,'.J_n%s(J_n[%s]),',int2str(p-1), int2str(upper_adj(p)-1));
        end
        
        
        for p =1:max_num_neighbors
            if (true_adj(p)~=0)
                fprintf(fileID,'.s_in%s(s[%s]),',int2str(p-1), int2str(true_adj(p)-1));
            else
                fprintf(fileID,'.s_in%s(1''b0),',int2str(p-1));
            end
        end
        
        if m ==1
            fprintf(fileID,'.s_out(s[%s]), .reset_flip_counter(reset_flip_counter), .enable_flip_counter(enable_flip_counter), .counter(counter [%s -: 16])); \n',int2str(same_color(m)-1),int2str(j*16-1));
        else
            fprintf(fileID,'.s_out(s[%s])); \n',int2str(same_color(m)-1));
        end
        
        counter =counter+1;
        clear A
    end
end



fclose(fileID);

fprintf('Length of reshaped J = %d\n',max(max(triu_adjacency)))
fprintf('\nnumber of p-bits = %d\n',length(W))



stem(colorMap)
xlabel('index of p-bit')
ylabel('index of clock')
set(gca,'FontSize', 30, 'FontWeight', 'bold')