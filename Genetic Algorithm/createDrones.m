function [drones] = createDrones(fires, droneNo) %create the drones
    %all of the drones start in the same place, and have the same
    %intensities, with their x and y starting points and fire values depending on
    %averages of the fire locations, and the z value being set to 0
    
    drones.capac = zeros(1, droneNo);
    for i = 1: droneNo
        drones.capac(1, i) = mean(fires.intensity) * (length(fires.loc(1,:)) / droneNo);
    end
    drones.loc(1,:) = zeros(1, droneNo);
    for i = 1: droneNo
        drones.loc(1, i) = min(fires.loc(1,:)) + (max(fires.loc(1,:))) - min(fires.loc(1,:)) / droneNo * 3;
    end
    
    drones.loc(2,:) = zeros(1, droneNo);
    for i = 1: droneNo
        drones.loc(2, i) = min(fires.loc(2,:)) - 0.25;
    end
    drones.loc(3,:) = zeros(1, droneNo);

    % control trial
%     drones.capac = [3 6 9 12 15];
%     drones.locX = [10 10 10 10 10];
%     drones.locY = [0 0 0 0 0];
%     drones.locZ = [0 0 0 0 0];
end
