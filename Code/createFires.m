function [fires] = createFires()
%     t = table2cell(readtable('../data-manipulation/pascascades-samples.xlsx', 'sheet', 'Sheet1'));
%     %convert from cell to array and transpose it (')
%     fires.intensity = cell2mat(t(:, 8))'; 
%     %[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5];
%     fires.locX = cell2mat(t(:, 15))' ./ (10^5); %all are multiplied by 10^5
%     %[0 0 0 5 5 5 10 10 10 15 15 15 20 20 20];
%     fires.locY = cell2mat(t(:, 16))' ./ (10^5);
%     %[5 10 15 5 10 15 5 10 15 5 10 15 5 10 15];
%     fires.locZ = cell2mat(t(:, 6))';
    fires.intensity = [1 1 1 2 2 2 3 3 3 4 4 4 5 5 5];
    fires.locX = [0 0 0 5 5 5 10 10 10 15 15 15 20 20 20];
    fires.locY = [5 10 15 5 10 15 5 10 15 5 10 15 5 10 15];
    fires.locZ = [15 10 5 15 10 5 15 10 5 15 10 5 15 10 5];
end
