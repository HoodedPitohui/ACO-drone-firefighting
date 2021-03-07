clear all
close all
clc
%% Problem Preparation
%get the fires and drones
fires = createFires();
[drones] = createDrones();

%Create the graph
[graph] = createGraph(fires.locX, fires.locY);

%Draw the graph
figure
subplot(2, 4, 1)
drawGraph(graph);
subplot(2, 4, 2);
drawGraphWithDrones(graph, drones);

%% Initial Parameters
maxIter = 5;
antNo = 5;
droneNo = 5; %agents in CVRP

tau0 = 10 * 1 / (graph.n * mean(graph.edges(:) ) );
eta = 1 ./ graph.edges; %edge desirability

%Start the process of creating a 3D tau matrix
tau = tau0 * ones(graph.n, graph.n);
for t = 1: 1: droneNo - 1
    tau(:,:,t + 1) = tau0 * ones(graph.n, graph.n);
end

rho = 0.5; % Evaporation rate 
alpha = 1;  % Pheromone exponential parameters 
beta = 1;  % Desirability exponetial paramter
%% Main Loop of ACO

%initial base conditions
bestFireFitness = inf(1, droneNo);
bestFireDist = zeros(1, droneNo); %best fire's distance
bestTour = [];
colony = [];
%colony = zeros(0, droneNo);
allAntsFitness = [];
bestOverallFitness = inf;
t = 1;
while t <= maxIter
    tempFitness = 0;
    %create ants
    for d = 1: droneNo
        
        colony = createColonies(graph, fires.intensity, drones.capac(d), d, colony, antNo, tau(:,:,d), eta, alpha, beta);
        for k = 1: antNo 
            %calculate fitnesses of all ants in a spec  ific drone ant colony
            colony(d).ant(k).distFitness = distFitnessFunction(drones, d, colony(d).ant(k).tour,  graph);
            colony(d).ant(k).fireFitness = fireFitnessFunction(colony(d).ant(k).fireSum, drones.capac(d));
        end
%         allAntsFitness(:, :, j) = [colony(j).ant(:).fitness];
%         [minVal, minIndex] = min(allAntsFitness(1, 2, j))

        %to do: can be optimized later for shorter search time
        for k = 1: 1: antNo
            if bestFireFitness(1, d) > colony(d).ant(k).fireFitness
                bestFireFitness(1, d) = colony(d).ant(k).fireFitness;
                bestTour{d} = colony(d).ant(k).tour;
                bestFireDist(1, d) = colony(d).ant(k).distFitness;
            else
            end
        end
    
        %Find the best ant of this colony
        colony(d).queen.tour = bestTour{d};
        colony(d).queen.fireFitness = bestFireFitness(1, d);
%         
        %Update pheromone matrix
        tau = updatePheromone(tau, d, colony);
        
        %Evaporation
        tau(:, :, d) = (1 - rho) .* tau(:, :, 1);
        outmsg = ['Iteration #', num2str(t), 'Drone #' , num2str(d), 'Fitness # ', num2str(colony(d).queen.fireFitness(1, 1)) ];
        disp(outmsg)
        subplot(2, 4, 1)
        title(['Iteration #' , num2str((t-1) * 5 + d) ])
        subplot(2, 4, 3)
%         cla
        
        %Visualize best tour and pheromone concentration
        drawBestTour(colony(d), drones, d, graph);
        subplot(2, 4, 4)
%         cla
%         drawPheromone(tau(:, :, d), d, graph);
        drawnow
        tempFitness = tempFitness + colony(d).queen.fireFitness;
    end
    if t ~= maxIter
       cla(subplot(2, 4, 3))
    else
    end
    if (tempFitness < bestOverallFitness)
        cla(subplot(2, 4, 5))
        for d = 1: droneNo
            drawBestTour(colony(d), drones, d, graph);
        end
        bestOverallFitness = tempFitness;
    else
    end
    t = t + 1;
end
