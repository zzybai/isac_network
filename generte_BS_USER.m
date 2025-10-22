% 生成基站（AP）和用户（UE）的位置，并保证：
% - 基站之间的最小间距 > 50 米
% - 用户之间的最小间距 > 30 米
% 模拟区域为 300 m × 300 m 的正方形。

%% 参数设置
areaSize = 300;             % 正方形区域边长（米）
numAPs = 12;                % 基站数量（AP）
numUsers = 8;               % 用户数量（UE）
minAPDistance = 50;         % 基站最小间距（米）
minUserDistance = 30;       % 用户最小间距（米）
minUserAPDistance = 20;     % 用户与基站最小间距（米）

%% 随机种子（可复现）
rng(2024, 'twister');

%% 生成满足最小间距约束的基站位置
apPositions = zeros(numAPs, 2);
i = 1;
maxAttemptsPerPoint = 20000;  % 单个点的最大尝试次数，避免极端情况下死循环
attempts = 0;
while i <= numAPs
    candidate = areaSize * rand(1, 2);
    if i == 1
        ok = true;
    else
        diffs = apPositions(1:i-1, :) - candidate;
        d2 = diffs(:, 1).^2 + diffs(:, 2).^2;
        ok = all(d2 >= (minAPDistance^2));
    end
    if ok
        apPositions(i, :) = candidate;
        i = i + 1;
        attempts = 0;
    else
        attempts = attempts + 1;
        if attempts > maxAttemptsPerPoint
            % 重新开始放置，保证能收敛（在当前规模下极少触发）
            i = 1;
            attempts = 0;
        end
    end
end

%% 生成满足最小间距约束的用户位置
userPositions = zeros(numUsers, 2);
i = 1;
attempts = 0;
while i <= numUsers
    candidate = areaSize * rand(1, 2);
    % 检查与所有基站的距离
    diffsAP = apPositions - candidate;
    d2AP = diffsAP(:, 1).^2 + diffsAP(:, 2).^2;
    okAP = all(d2AP >= (minUserAPDistance^2));
    % 检查与已放置用户的距离
    if i == 1
        okUsers = true;
    else
        diffsU = userPositions(1:i-1, :) - candidate;
        d2U = diffsU(:, 1).^2 + diffsU(:, 2).^2;
        okUsers = all(d2U >= (minUserDistance^2));
    end
    ok = okAP && okUsers;
    if ok
        userPositions(i, :) = candidate;
        i = i + 1;
        attempts = 0;
    else
        attempts = attempts + 1;
        if attempts > maxAttemptsPerPoint
            i = 1;
            attempts = 0;
        end
    end
end

%% 保存结果
save('cell_free_deployment.mat', 'apPositions', 'userPositions');
writematrix(apPositions, 'ap_positions.csv');
writematrix(userPositions, 'user_positions.csv');

%% 可视化
figure;
hold on; grid on; box on;
scatter(apPositions(:, 1), apPositions(:, 2), 80, 'filled', 'DisplayName', 'APs');
scatter(userPositions(:, 1), userPositions(:, 2), 80, '^', 'filled', 'DisplayName', 'Users');
xlabel('x (m)');
ylabel('y (m)');
title('Cell-Free Network Deployment (AP \ge 50 m, UE \ge 30 m, UE-AP \ge 20 m)');
legend('Location', 'bestoutside');
axis([0 areaSize 0 areaSize]);
hold off;
saveas(gcf, 'cell_free_deployment.png');

%% 在命令行显示坐标
disp('Access Point Coordinates (x, y) in meters:');
disp(apPositions);
disp('User Coordinates (x, y) in meters:');
disp(userPositions);
