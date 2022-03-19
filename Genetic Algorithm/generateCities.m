function [cities] = generateCities(numberOfCities, range)
%generateCities Generates cities on random locations.

%    cities = rand(3,numberOfCities) * range;
  xValues = [84 89 78 61 64 8 68 60 10 5 34 22 48 51 97 93 13 26 65 80 37 71 36 35 57 91 79 43 4 95 82 40 14 70 75 33 59 99 27 85 32 87 38 58 1 66 100 46 42 19 52 24 92 29 50 74 9 25 7 21 73 96 90 72 12 77 62 54 86 28 6 45 53 94 83 11 76 49 88 30 44 98 67 15 69 31 17 63 23 18 41 81 56 2 3 20 16 55 47 39];
  yValues = [4 23 70 40 11 17 61 66 36 14 29 20 97 69 65 3 22 77 1 62 60 2 24 34 10 78 42 95 21 16 92 46 52 86 27 12 67 68 94 84 51 39 85 25 8 87 31 32 99 47 28 63 26 5 76 37 18 81 57 19 83 100 88 64 74 58 53 9 41 98 43 54 13 44 33 30 49 89 96 71 35 15 90 73 7 82 59 50 55 72 93 45 48 6 91 80 56 75 38 79];
  zValues = [20 85 54 88 65 61 98 40 89 11 30 52 47 73 84 37 95 62 51 82 77 1 2 12 49 32 80 72 18 50 10 92 33 75 67 96 8 69 22 59 100 70 6 74 66 57 29 46 68 71 83 64 28 76 45 25 56 35 99 81 24 60 79 26 55 97 13 44 43 78 21 87 31 36 16 94 14 4 41 42 23 53 38 17 7 91 48 19 3 93 9 15 90 27 86 63 34 39 58 5];

  cities(1,:) = xValues(1,:);
  cities(2,:) = yValues(1,:);
  cities(3,:) = zValues(1,:);
  
end

