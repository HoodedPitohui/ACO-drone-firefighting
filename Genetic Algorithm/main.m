clear;
clc;
close all;
global gNumber;

%% Set file names
fireDatasheet = '../data-manipulation/northeast-samples.xlsx';
sheetName = 'sheet7';
trialName = 'trial1';
regionName = 'northeast';
outputExcelName = strcat(trialName,'-', regionName, '-', 'data', '.xlsx');
outputToursName = strcat(trialName, '-', regionName, '-', 'tours', '.png');
outputBestToursName = strcat(trialName, '-', regionName, '-', 'best-tour', '.png');

%% Problem Preparation

tStart = tic;
droneNum = 5;
environment.fires = generateCities(fireDatasheet, sheetName);
[drones] = createDrones(environment.fires, droneNum);
environment.netFireSum = sum(environment.fires.intensity);
drones.netDroneExtSum = sum(drones.capac);
bestPathSoFar = Inf; 

%% Initial Parameters
% Calculating distances between cities according to created city locations.
distances = calculateDistance(environment.fires.loc);
drones.popSize = 100;
drones.crossoverProbability = 0.9;
drones.mutationProbability = 0.05;
generationNumber = 10;
drones.cluster = [];
drones.allUsedNodes = [];
% 
% for d = 1: droneNum
%     % Generate population with random paths.
%     drones.cluster = population(drones.popSize, environment.fires.intensity, drones.allUsedNodes...
%         , d, drones.capac(d), drones.cluster);
%     %nextGeneration = zeros(popSize,numberOfCities);
% end




%Keeping track of minimum paths through every iteration.
%minPathes = zeros(generationNumber,1);
blockedPaths = [];
% Genetic algorithm itself.
for d = 1: droneNum
    drones.cluster = population(drones.popSize, environment.fires.intensity, drones.allUsedNodes...
        , d, drones.capac(d), drones.cluster);
    for gN = 1: generationNumber
        for k = 1: drones.popSize
            drones.cluster(d).pop(k).fireFitness = fireFitnessFunction(...
                drones.cluster(d).pop(k), drones.capac(d), droneNum, ...
                length(environment.fires.intensity));
        end
        tournamentSize=4;
        for k=1: drones.popSize
            % Choosing parents for crossover operation bu using tournament approach.
            tournamentPopFitnesses=zeros( tournamentSize,1);
            for j = 1:tournamentSize
                randomRow = randi(drones.popSize);
                tournamentPopFitnesses(j,1) = drones.cluster(d).pop(randomRow).fireFitness;
            end
            parent1  = min(tournamentPopFitnesses);
            
            %following line necessary as the array of structures isn't
            %conducive to the find command
            tempStorage = struct2table(drones.cluster(d).pop);
            [parent1X,parent1Y] = find(tempStorage.fireFitness == parent1, 1,...
                'first');
            
            parent1Path = drones.cluster(d).pop(parent1X).tour;
            x = 9;
            for j = 1: tournamentSize;
                randomRow = randi(drones.popSize);
                tournamentPopFitnesses(j,1) = drones.cluster(d).pop(randomRow).fireFitness;
            end

            parent2  = min(tournamentPopFitnesses);
            
            %following line necessary as the array of structures isn't
            %conducive to the find command
            [parent2X,parent2Y] = find(tempStorage.fireFitness == parent2, 1,...
                'first');
            parent2Path = drones.cluster(d).pop(parent2X).tour;
            childPath = crossover(parent1Path, parent2Path, drones.crossoverProbability, ...
                drones, environment, d);
            childPath = mutate(childPath, drones.mutationProbability);
            
            
            nextGeneration{k,:} = childPath(1,:);
            nextGenPathInts = [];
            
            %create array that I can then embed into the cell
            %keeps the data structue usage consistent
            for m = 1: length(childPath)
                nextGenPathInts = [nextGenPathInts, environment.fires.intensity(childPath(m))];
            end
            
            %this enables for fire intensity arrays to be stored
            nextGenPathIntCell{k,:} = nextGenPathInts(1,:);
        end
%         fprintf('Minimum path in %d. generation: %f \n', gN, minPath);
        gNumber = gN;
        for k = 1: drones.popSize
            drones.cluster(d).pop(k).tour = cell2mat(nextGeneration(k));
            drones.cluster(d).pop(k).fires = cell2mat(nextGenPathIntCell(k));
            drones.cluster(d).pop(k).fireSum = sum(drones.cluster(d).pop(k).fires);
        end
    end
    for k = 1: drones.popSize
        drones.cluster(d).pop(k).fireFitness = fireFitnessFunction(...
            drones.cluster(d).pop(k), drones.capac(d), droneNum, ...
            length(environment.fires.intensity));
    end
    [bestTour{d}, indexBest(d)] = findBestTour(drones.cluster(d), drones.popSize);
    remainingFireExtinguisher(d) = drones.capac(d) - drones.cluster(d).pop(indexBest(d)).fireSum;
    drones.allUsedNodes = [drones.allUsedNodes, bestTour{d}];
end


%% Cooperative Search Part to Target Untargeted trashs

drones.allUnusedNodes = zeros(1, length(environment.fires.intensity) - length(drones.allUsedNodes));
uCounter = 1;

%variable that denotes if less than 5 drones have been used for the
%particular problem
drones.actualNumberDronesUsed = length(bestTour);

%records all the nodes that have not been used, which is used for the
%cooperative solution finding
for i = 1: length(environment.fires.intensity)
    if ~(ismembertol(i, drones.allUsedNodes))
        drones.allUnusedNodes(1, uCounter) = i;
        uCounter = uCounter + 1;
    else
    end
end

droneNumber = 1;
environment.fires.uIntensity = zeros(1, length(drones.allUnusedNodes));
%records intensity of the trashs in the unused nodes
for i = 1: length(drones.allUnusedNodes)
    environment.fires.uIntensity(1, i) = environment.fires.intensity(drones.allUnusedNodes(1, i));
end

%needs work from here - 4/15
for i = 1: length(drones.allUnusedNodes)
    while (~(droneNumber > droneNum) && environment.fires.uIntensity(1, i) ~= 0)
        %drones with no trash extinguisher are not rerouted
        indTotDiff = drones.capac(d) - drones.cluster(droneNumber).pop(indexBest(droneNumber)).fireSum;
        if (drones.cluster(droneNumber).queen.trashTotDiff <= 0.05)
            droneNumber = droneNumber + 1;
        %routing drones and setting new trash values for trashs that require
        %the drone to expend all of its trash extinguisher
        elseif (environment.trashs.uIntensity(1, i) - drones.colony(droneNumber).queen.trashTotDiff >= 0)    
            environment.trashs.uIntensity(1, i) = environment.trashs.uIntensity(1, i) - drones.colony(droneNumber).queen.trashTotDiff;
            drones.colony(droneNumber).queen.tour = [drones.colony(droneNumber).queen.tour, drones.allUnusedNodes(1, i)];
            bestTour{droneNumber} = [bestTour{droneNumber}, drones.allUnusedNodes(1, i) + drones.colony(droneNumber).queen.trashTotDiff / environment.trashs.intensity(drones.allUnusedNodes(1, i))];
            drones.colony(droneNumber).queen.trashTotDiff = 0;
            droneNumber = droneNumber + 1;
        %if the drone has trash extinguisher left after fighting one trash
        else
            if (environment.trashs.uIntensity(1, i) == environment.trashs.intensity(drones.allUnusedNodes(1, i)))
                bestTour{droneNumber} = [bestTour{droneNumber}, drones.allUnusedNodes(1, i)];
            else
                bestTour{droneNumber} = [bestTour{droneNumber}, drones.allUnusedNodes(1, i)+ environment.trashs.uIntensity(1, i) / environment.trashs.intensity(drones.allUnusedNodes(1, i))]; %+ drones.colony(droneNumber).queen.trashTotDiff / environment.trashs.intensity(drones.allUnusedNodes(1, i))];
            end
            drones.colony(droneNumber).queen.trashTotDiff = drones.colony(droneNumber).queen.trashTotDiff - environment.trashs.uIntensity(1, i);
            environment.trashs.uIntensity(1, i) = 0;
            drones.colony(droneNumber).queen.tour = [drones.colony(droneNumber).queen.tour, drones.allUnusedNodes(1, i)];
        end
    end
end
