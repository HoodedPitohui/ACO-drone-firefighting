clear all
close all
clc
tic; %start the program timer

%% Set File Names

regionNames = {'northwest', 'northeast', 'pascascades', 'southpuget', 'southeast'};
fileStoreLoc = '../data-manipulation/';
fireDataSheet = strcat(fileStoreLoc, regionNames, '-samples', '.xlsx');
numTrialsPerRegion = 10;
for i = 1: numTrialsPerRegion
    sheetName{i} = strcat('sheet', num2str(i - 1));
end

%% Problem Preparation
%get the fires and drones

droneNo = 5; %agents in CVRP


%% Initial Parameters


environment.maxIter = 10; %1
iterations = 5;
for i = 1: iterations
    %cycle through for 10 - 50 ants
    
    droneNo = 5; %agents in CVRP
    for k = 1: length(regionNames)
        for j = 1: numTrialsPerRegion
            environment.fires{k, j} = createFires(fireDataSheet{k}, sheetName{j});
            graph{k, j} = createGraph(environment.fires{k, j}.locX, environment.fires{k, j}.locY, environment.fires{k, j}.locZ);
        end
    end
    for j = 1: length(regionNames)
        for k = 1: numTrialsPerRegion
            rho = 1 * (i + 2) / 10;
            time(j, k) = aco3(graph{j, k}, environment, droneNo, 10, j, k, rho);
        end
    end
    totalTimeTable{i} = time;
    tavg{i} = mean(time(:));
end



%% Format data output and store as excel files

