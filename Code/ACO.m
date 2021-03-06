clear all
clc
%% Problem Preparation
%get the fires and drones
tic;
fires = createFires();
droneNo = 5; %agents in CVRP
[drones] = createDrones(fires, droneNo);
netFireSum = sum(fires.intensity);
netDroneExtSum = sum(drones.capac);

%Create the graph
[graph] = createGraph(fires.locX, fires.locY, fires.locZ);

%Draw the graph
fig1 = figure('Position', get(0, 'Screensize'));
subplot(2, 4, 1)
drawGraph(graph);
subplot(2, 4, 2);
drawGraphWithDrones(graph, drones);

%% Initial Parameters
maxIter = 10; %1
antNo = 50; %5

tau0 = 10 * 1 / (graph.n * mean(graph.edges(:) ) );
eta = 1 ./ graph.edges; %edge desirability

%Start the process of creating a 3D tau matrix
tau = tau0 * ones(graph.n, graph.n);
for t = 1: 1: droneNo - 1
    tau(:,:,t + 1) = tau0 * ones(graph.n, graph.n);
end

rho = 0.5; % Evaporation rate 
alpha = 1;  % Pheromone exponential parameters 
beta = 1;  % Desirability exponetial parameter

%initial base conditions: extreme ones which the program will obviously
%beat
%purpose is to initialize all of the variables
bestFireFitness = inf(1, droneNo);
bestFireDist = zeros(1, droneNo); %best fire's distance
bestFireFit1 = zeros(1, droneNo);
bestFireFit2 = zeros(1, droneNo);
bestFireFit3 = zeros(1, droneNo);
bestTour = {};
colony = [];
bestOverallFitness = zeros(1, droneNo); %datapoint that shows overall how ideal the whole solution is
allUsedNodes = []; %keeps track of all the nodes that are visited
bestSolutionsFound = zeros(1, droneNo) %check if best solutions are found

%% Main Loop of ACO


t = 1; %fenceposting
% && bestOverallFitness ~= (0.01 * droneNo)
for d = 1: droneNo

    %create ants
    while t <= maxIter && bestSolutionsFound(d) ~= 1
        colony = createColonies(t, graph, fires.intensity, drones.capac(d), d, colony, antNo, tau(:,:,d), eta, alpha, beta, allUsedNodes);
        for k = 1: antNo 
            %calculate fitnesses of all ants in a specific drone ant colony
            colony(d).ant(k).distFitness = distFitnessFunction(drones, d, colony(d).ant(k).tour,  graph);
            [fireOverall, fireFit1, fireFit2, fireFit3] = fireFitnessFunction(colony(d).ant(k), drones.capac(d), droneNo, length(fires.locX));
            
            %stores variables into the colony struct.
            colony(d).ant(k).fireFitness = fireOverall;
            colony(d).ant(k).fireTotDiff = fireFit1;
            colony(d).ant(k).fireEq = fireFit2;
            colony(d).ant(k).fireInt = fireFit3;
        end
        
        %check if any of the ants offer a better solution than the ones
        %found already
        for k = 1: 1: antNo
            if bestFireFitness(1, d) > colony(d).ant(k).fireFitness
                bestFireFitness(1, d) = colony(d).ant(k).fireFitness;
                bestTour{d} = colony(d).ant(k).tour;
                bestFireDist(1, d) = colony(d).ant(k).distFitness;
                bestFireFit1(1, d) = colony(d).ant(k).fireTotDiff;
                bestFireFit2(1, d) = colony(d).ant(k).fireEq;
                bestFireFit3(1, d) = colony(d).ant(k).fireInt;
            else
            end
        end
    
        %Find the best ant of this colony
        colony(d).queen.tour = bestTour{d};
        colony(d).queen.fireTotDiff = bestFireFit1(1, d);
        colony(d).queen.fireEq = bestFireFit2(1, d);
        colony(d).queen.fireInt = bestFireFit3(1, d);
        colony(d).queen.fireFitness = bestFireFitness(1, d);
%         
        %Update pheromone matrix
        tau(:, :, d) = updatePheromone(tau(:, :, d), colony(d));
        
        %Evaporation
        tau(:, :, d) = (1 - rho) .* tau(:, :, d);
        outmsg = ['Iteration = #', num2str(t), ' Drone = #' , num2str(d), ' Fitness = # ', num2str(colony(d).queen.fireFitness(1, 1)) ];
        %enables for tracking of progress by displaying output.
        disp(outmsg)
        subplot(2, 4, 3)
        drawBestTour(colony(d), drones, d, graph);
        title('Best Tour of Iteration # ', num2str(t))
        
        %Visualize best tour and pheromone concentration (for five drones)
        if (d < 6)
            subplot(2, 4, d + 3)
            cla
            drawPheromone(tau(:, :, d), graph);
            drawnow
            title('Pheromones of Drone # ', num2str(d))
        else
        end
        
        %serves if the ultra ideal solution is found so that the code stops
        %iterating
        if colony(d).queen.fireFitness == 0.01 && bestSolutionsFound(d) == 0
           bestSolutionsFound(d) = 1;      
        else
        end
        
        %another progress checking mechanism that gets cleared after every
        %iteration, with the final one for the last drone being the one
        %saved
        if t ~= maxIter
            cla(subplot(2, 4, 3))
        else
        end
        t = t + 1;
    end
    
    %converts all the bestTour nodes to a matrix that denotes all the nodes
    %visited, which is used later
    allUsedNodes = cell2mat(bestTour);
    t = 1;
    if length(allUsedNodes) == length(fires.locX)
        break
    else
    end
end

%% Cooperative Search Part to Target Untargeted Fires

allUnusedNodes = zeros(1, length(fires.intensity) - length(allUsedNodes));
uCounter = 1;

%variable that denotes if less than 5 drones have been used for the
%particular problem
actualNumberDronesUsed = length(bestTour);

%records all the nodes that have not been used, which is used for the
%cooperative solution finding
for i = 1: length(fires.intensity)
    if ~(ismembertol(i, allUsedNodes))
        allUnusedNodes(1, uCounter) = i;
        uCounter = uCounter + 1;
    else
    end
end

droneNumber = 1;
uIntensity = zeros(1, length(allUnusedNodes));
%records intensity of the fires in the unused nodes
for i = 1: length(allUnusedNodes)
    uIntensity(1, i) = fires.intensity(allUnusedNodes(1, i));
end


for i = 1: length(allUnusedNodes)
    while (~(droneNumber > droneNo) && uIntensity(1, i) ~= 0)
        %drones with no fire extinguisher are not rerouted
        if (colony(droneNumber).queen.fireTotDiff <= 0.000000001)
            droneNumber = droneNumber + 1;
        %routing drones and setting new fire values for fires that require
        %the drone to expend all of its fire extinguisher
        elseif (uIntensity(1, i) - colony(droneNumber).queen.fireTotDiff >= 0)    
            uIntensity(1, i) = uIntensity(1, i) - colony(droneNumber).queen.fireTotDiff;
            colony(droneNumber).queen.tour = [colony(droneNumber).queen.tour, allUnusedNodes(1, i)];
            bestTour{droneNumber} = [bestTour{droneNumber}, allUnusedNodes(1, i) + colony(droneNumber).queen.fireTotDiff / fires.intensity(allUnusedNodes(1, i))];
            colony(droneNumber).queen.fireTotDiff = 0;
            droneNumber = droneNumber + 1;
        %if the drone has fire extinguisher left after fighting one fire
        else
            bestTour{droneNumber} = [bestTour{droneNumber}, allUnusedNodes(1, i) + colony(droneNumber).queen.fireTotDiff / fires.intensity(allUnusedNodes(1, i))];
            colony(droneNumber).queen.fireTotDiff = colony(droneNumber).queen.fireTotDiff - uIntensity(1, i);
            uIntensity(1, i) = 0;
            colony(droneNumber).queen.tour = [colony(droneNumber).queen.tour, allUnusedNodes(1, i)];
        end
    end
end
subplot(2, 4, 4)
timeElapsed = toc


%% Graph the Best Tour as a separate figure

%graph best tours
fig2 = figure('Position', get(0, 'Screensize'));

%Graph best tours for all drones that were used
for d = 1: actualNumberDronesUsed
    drawBestTour(colony(d), drones, d, graph);
    bestOverallFitness(1, d) = colony(d).queen.fireFitness;
end
title('Best Overall Tour of All Iterations')

%% Format data output and store as excel files

%Convert to tables so we can set labels for row and columns
droneColNames = string([1, droneNo]);
for i = 1: length(bestTour)
    colName = "Drone #" + num2str(i);
    droneColNames(1, i) = colName;
end

tourTable = cell2table(bestTour, 'VariableNames', droneColNames);
droneIntensityTable = array2table(drones.capac, 'VariableNames', droneColNames);
overallFitnessTable = array2table(bestOverallFitness, 'VariableNames', droneColNames);

%format the tables so we can save them in an excel file with multiple
%sheets
fireColNames = string([1, length(fires.locX)]);
for i = 1: length(fires.locX)
    colName = "Fire #" + num2str(i);
    fireColNames(1, i) = colName;
end
fireIntensityTable = array2table(fires.intensity, 'VariableNames', fireColNames);
rowName = "Time Elapsed";
timeElapsedTable = array2table(timeElapsed, 'RowNames', rowName);
fileName = 'southpuget-trial-data.xlsx';
sheetName = 'trial5';

writetable(tourTable,fileName,'Sheet', sheetName, 'Range', 'A1');
writetable(droneIntensityTable,fileName,'Sheet', sheetName, 'Range', 'A4');
writetable(overallFitnessTable,fileName,'Sheet', sheetName, 'Range', 'A7');
writetable(fireIntensityTable,fileName,'Sheet', sheetName, 'Range', 'A10');
writetable(timeElapsedTable, fileName, 'Sheet', sheetName, 'Range', 'A13');

%save the figures used as png files in the project folder
saveas(fig1, 'southpuget-trial5-tours.png','png');
saveas(fig2, 'southpuget-trial5-best-tour.png','png');

