clear all
close all
clc
%% Problem Preparation
%get the fires and drones
[fireIntensity, fireLocX, fireLocY] = createFires();
[droneCapac, droneLocX, droneLocY] = createDrones();

%Create the graph
[graph] = createGraph(fireLocX, fireLocY);

%Draw the graph
figure
subplot(2, 4, 1)
drawGraph(graph);
subplot(2, 4, 2);
drawGraphWithDrones(graph, droneLocX, droneLocY);

%% Initial Parameters
maxIter = 2;
antNo = 5;
droneNo = 5; %agents in CVRP

tau0 = 10 * 1 / (graph.n * mean(graph.edges(:) ) );
eta = 1 ./ graph.edges; %edge desirability

%Start the process of creating a 3D tau matrix
tau = tau0 * ones(graph.n, graph.n);
for i = 1: 1: droneNo - 1
    tau(:,:,i + 1) = tau0 * ones(graph.n, graph.n);
end

rho = 0.5; % Evaporation rate 
alpha = 1;  % Pheromone exponential parameters 
beta = 1;  % Desirability exponetial paramter
%% Main Loop of ACO

%initial base conditions
bestFitness = inf(droneNo, 1);
bestTour = [];
colony = [];
%colony = zeros(0, droneNo);
allAntsFitness = [];
bestOverallFitness = inf;
for i = 1: maxIter
    tempFitness = 0;
    %create ants
    for j = 1: droneNo
        
        colony = createColonies(graph, fireIntensity, droneCapac(j), j, colony, antNo, tau(:,:,j), eta, alpha, beta);
        for k = 1: antNo 
            %calculate fitnesses of all ants in a specific drone ant colony
            colony(j).ant(k).fitness = fitnessFunction(colony(j).ant(k).tour, colony(j).ant(k).fireSum(1) , droneCapac(j),  graph);
        end
%         allAntsFitness(:, :, j) = [colony(j).ant(:).fitness];
%         [minVal, minIndex] = min(allAntsFitness(1, 2, j))

        %to do: can be optimized later for shorter search time
        for k = 1: 1: antNo
            if bestFitness(j, 1) > colony(j).ant(k).fitness(1, 2)
                bestFitness(j, 1) = colony(j).ant(k).fitness(1, 2);
                bestTour{j} = colony(j).ant(k).tour;
            else
            end
        end
    
        %Find the best ant of this colony
        colony(j).queen.tour = bestTour{j};
        colony(j).queen.fitness = bestFitness(j, 1);
%         
        %Update pheromone matrix
        tau = updatePheromone(tau, j, colony);
        
        %Evaporation
        tau(:, :, j) = (1 - rho) .* tau(:, :, 1);
        outmsg = ['Iteration #', num2str(i), 'Drone #' , num2str(j), 'Fitness # ', num2str(colony(j).queen.fitness(1, 1)) ];
        disp(outmsg)
        subplot(2, 4, 1)
        title(['Iteration #' , num2str((i-1) * 5 + j) ])
        subplot(2, 4, 3)
%         cla
        
        %Visualize best tour and pheromone concentration
        drawBestTour(colony(j), j, graph);
        subplot(2, 4, 4)
%         cla
        %drawPheromone(tau(:, :, j), j, graph);
        drawnow
        tempFitness = tempFitness + colony(j).queen.fitness;
    end
    if (tempFitness < bestOverallFitness)
        subplot(2, 4, 5)
        cla
        for j = 1: droneNo
            drawBestTour(colony(k), k, graph);
        end
        bestOverallFitness = tempFitness;
    else
    end
end
