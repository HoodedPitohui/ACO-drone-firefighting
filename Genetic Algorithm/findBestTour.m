function [bestTour, index] = findBestTour(cluster, popSize)
    bestTour = cluster.pop(1).tour;
    index = 1;
    bestTourFireFitness = cluster.pop(1).fireFitness;
    for i = 2: popSize
        if (bestTourFireFitness < cluster.pop(i).fireFitness)
            bestTour = cluster.pop(i).tour;
            bestTourFireFitness = cluster.pop(i).fireFitness;
            index = i;
        end
    end
end