function [triu_adjacency,J_indices] = get_triu_adjacency(J_org, max_num_neighbors)


% J_org =[  0    -1    -1     1     2
%     -1     0    -1     1     2
%     -1    -1     0     1     2
%     1     1     1     0    -2
%     2     2     2    -2     0];

% 
% J_org =         [ 0, +2, +0, +1, +0, -1, -1
%        +2,  0, +0, -1, -1, +3, +0
%         +0, +0,  0, -2, +0, +1, +1
%         +1, -1, -2,  0, +2, +0, +0
%         +0, -1, +0, +2,  0, +0, +1
%         -1, +3, +1, +0, +0,  0, +0
%         -1, +0, +1, +0, +1, +0,  0];

J_org = full(J_org);
J = triu(J_org);
num_pbits = length(J_org);
%max_neighbors = max(degree(graph(J_org)));
% max_neighbors =7

counter = 1;
zero_counter =[];

triu_adjacency = zeros(num_pbits, max_num_neighbors);
J_indices = zeros(size(J));

for i= 1:num_pbits
    n_neighbors = 1;

    col_list = J(1:i,i);
    for j = 1:length(col_list)
        if col_list(j)
            triu_adjacency(i,n_neighbors) = J_indices(j,i);
            n_neighbors = n_neighbors + 1;
        end
    end

    row_list = J(i,i+1:end);
    for j = 1:length(row_list)
        if row_list(j)
            triu_adjacency(i,n_neighbors) = counter;
            J_indices(i, j + i) = counter;
            counter = counter +1;
            n_neighbors = n_neighbors + 1;
        end
    end
    

     for k= n_neighbors:max_num_neighbors
            if isempty(zero_counter)
                triu_adjacency(i, k) = counter;
                zero_counter = counter;
                counter = counter +1;
            else
                triu_adjacency(i, k) = zero_counter;
                zero_counter = [];
            end
     end
end

end