function [ ] = drawBestTour(colony , drones, droneNo, graph) %draw the best tour
    queenTour = colony.queen.tour;
    
    %graph nodes
    for i = 1 : graph.n
    
        X = [graph.node(i).x];
        Y = [graph.node(i).y];
        Z = [graph.node(i).z];
        plot3(X, Y, Z, 'ok', 'markerSize' , 10 , 'MarkerEdgeColor' , 'r' , 'MarkerFaceColor', [1, 0.6, 0.6]);;
        text(X, Y, Z, num2str(i));
        hold on
    end
    
    %different colors for each drone
    color = [mod(0.77 * droneNo, 1), 0.5, 0.5];
    
    if (length(queenTour) >= 1)
        nextNode =  queenTour(1);
    
        x1 = drones.locX(droneNo);
        y1 = drones.locY(droneNo);
        z1 = drones.locZ(droneNo);
    
        x2 = graph.node(nextNode).x;
        y2 = graph.node(nextNode).y;
        z2 = graph.node(nextNode).z;
    
        X = [x1 , x2];
        Y = [y1, y2];
        Z = [z1, z2];
        plot3(X, Y, Z, 'color', color, 'LineWidth', 1 + (droneNo * 0.2));
        
        for i = 1 : length(queenTour) - 1
    
            currentNode = queenTour(i);
            nextNode =  queenTour(i+1);
    
            x1 = graph.node(currentNode).x;
            y1 = graph.node(currentNode).y;
            z1 = graph.node(currentNode).z;
    
            x2 = graph.node(nextNode).x;
            y2 = graph.node(nextNode).y;
            z2 = graph.node(nextNode).z;
    
            X = [x1 , x2];
            Y = [y1, y2];
            Z = [z1, z2];
            plot3(X, Y, Z, 'color', color, 'LineWidth', 1 + (droneNo * 0.2));

        end
    else
    end
    for i = 1: length(drones.locX)
        X = [drones.locX(i)];
        Y = [drones.locY(i)];
        Z = [drones.locZ(i)];
        plot3(X,Y, Z, 'ok', 'MarkerSize', 6, 'MarkerEdgeColor' , 'blue' , 'MarkerFaceColor' , 'blue');
    end
    box('on');
end
