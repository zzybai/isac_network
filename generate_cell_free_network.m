%% generate_cell_free_network
% Script to model the deployment of access points (APs) and users in a
% cell-free wireless network scenario. The APs and users are uniformly
% distributed inside a 300 m by 300 m square area.

%% Simulation parameters
areaSize = 300;             % Dimension of the square area (meters)
numAPs = 12;                % Number of access points (base stations)
numUsers = 8;               % Number of user equipments

%% Random deployment of APs and users
% Set a fixed seed to make the randomly generated layout reproducible.
rng(2024, 'twister');

% The locations are generated assuming a uniform distribution over the area.
apPositions = areaSize * rand(numAPs, 2);
userPositions = areaSize * rand(numUsers, 2);

%% Geometry between APs and users
% Compute the distances and azimuth angles (in radians) from every AP to
% every user. The resulting matrices have the size [numAPs x numUsers].
deltaX = bsxfun(@minus, userPositions(:, 1).', apPositions(:, 1));
deltaY = bsxfun(@minus, userPositions(:, 2).', apPositions(:, 2));

distanceMatrix = hypot(deltaX, deltaY);
angleMatrix = atan2(deltaY, deltaX);

%% Persist the generated deployment
% Save the random layout so the coordinates are available after the script
% finishes running. The MAT-file keeps the variables in MATLAB format, while
% the CSV files can be inspected with other tools.
outputDir = fullfile(pwd, 'deployment_data');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

matFile = fullfile(outputDir, 'cell_free_deployment.mat');
save(matFile, 'apPositions', 'userPositions', 'distanceMatrix', 'angleMatrix');

writematrix(apPositions, fullfile(outputDir, 'ap_positions.csv'));
writematrix(userPositions, fullfile(outputDir, 'user_positions.csv'));
writematrix(distanceMatrix, fullfile(outputDir, 'ap_user_distances.csv'));
writematrix(angleMatrix, fullfile(outputDir, 'ap_user_angles_rad.csv'));

%% Visualization
figure;
hold on; grid on; box on;
scatter(apPositions(:, 1), apPositions(:, 2), 80, 'filled', 'DisplayName', 'APs');
scatter(userPositions(:, 1), userPositions(:, 2), 80, '^', 'filled', 'DisplayName', 'Users');

xlabel('x (m)');
ylabel('y (m)');
title('Cell-Free Network Deployment');
legend('Location', 'bestoutside');
axis([0 areaSize 0 areaSize]);
hold off;

% Persist the visualization alongside the saved deployment data.
saveas(gcf, fullfile(outputDir, 'cell_free_deployment.png'));

%% Display coordinates in the command window
disp('Access Point Coordinates (x, y) in meters:');
disp(apPositions);

disp('User Coordinates (x, y) in meters:');
disp(userPositions);

disp('Distances from each AP (rows) to each user (columns) in meters:');
disp(distanceMatrix);

disp('Angles from each AP (rows) to each user (columns) in radians:');
disp(angleMatrix);
