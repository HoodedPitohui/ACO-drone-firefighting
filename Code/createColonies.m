function [ colony ] = createColonies( graph, fireIntensity, droneCapac, droneNo, colony , antNo, tau, eta, alpha,  beta)
    nodeNo = graph.n;
    for i = 1 : antNo
    
        initial_node = randi( [1 , nodeNo] ); % select a random node 
        colony(droneNo).ant(i).fireSum(1) = fireIntensity(initial_node);
        colony(droneNo).ant(i).tour(1) = initial_node;
        
        %experimental portion
        j = 2;
        while droneCapac > colony(droneNo).ant(i).fireSum && j <= nodeNo
            currentNode =  colony(droneNo).ant(i).tour(end);
%             P_allNodes = tau( currentNode , :  ) .^ alpha .* eta( currentNode , :  )  .^ beta;   
            P_allNodes = tau( currentNode , :  ) .^ alpha .* eta( currentNode , :  )  .^ beta;
            P_allNodes(colony(droneNo).ant(i).tour) = 0 ;  
            % assigning 0 to all the nodes visited so far
            P = P_allNodes ./ sum(P_allNodes)
               
            nextNode = rouletteWheel(P); 
            colony(droneNo).ant(i).tour = [  colony(droneNo).ant(i).tour , nextNode ];
            colony(droneNo).ant(i).fireSum = [colony(droneNo).ant(i).fireSum + fireIntensity(nextNode)];
            j = j + 1;
        end
            
            
%         for j = 2 : nodeNo % to choose the rest of nodes 
%             currentNode =  colony(droneNo).ant(i).tour(end);
%                
%             P_allNodes = tau( currentNode , :  ) .^ alpha .* eta( currentNode , :  )  .^ beta;
%             P_allNodes(colony(droneNo).ant(i).tour) = 0 ;  % assigning 0 to all the nodes visited so far
%             P = P_allNodes ./ sum(P_allNodes);
%                
%             nextNode = rouletteWheel(P); 
%             colony(droneNo).ant(i).tour = [  colony(droneNo).ant(i).tour , nextNode ];
%         end
    
        % complete the tour 
        %colony(droneNo).ant(i).tour = [ colony(droneNo).ant(i).tour , colony(droneNo).ant(i).tour(1)];
    end
end
