clear
clc
tic

%只走z轴
% dt = 0.02;
% tspan1 = 0:dt:1;
% p1 = [0; 0; 210];
% p2 = [0; 0; 560]; % 第二段圆轨迹的起点
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% % 合并两段轨迹
% viaPoint = viaPoint1;
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);

%只走x轴
% tspan2 = 0:0.02:1; 
% p1 = [0; 0; 540];
% p2 = [150; 0; 540];
% z_tip2 = (1 - tspan2) .* p1(3) + tspan2 .* p2(3);
% x_tip2 = (1 - tspan2) .* p1(1) + tspan2 .* p2(1);
% y_tip2 = (1 - tspan2) .* p1(2) + tspan2 .* p2(2);
% viaPoint2 = [x_tip2; y_tip2; z_tip2];
% tspan1 = 0:0.02:1; 
% p1 = [0; 0; 210];
% p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% % 合并两段轨迹
% viaPoint = [viaPoint1, viaPoint2];
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);

%只走y轴
% tspan2 = 0:0.02:1; 
% p1 = [0; 0; 540];
% p2 = [0; 150; 540];
% z_tip2 = (1 - tspan2) .* p1(3) + tspan2 .* p2(3);
% x_tip2 = (1 - tspan2) .* p1(1) + tspan2 .* p2(1);
% y_tip2 = (1 - tspan2) .* p1(2) + tspan2 .* p2(2);
% viaPoint2 = [x_tip2; y_tip2; z_tip2];
% tspan1 = 0:0.02:1; 
% p1 = [0; 0; 210];
% p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% % 合并两段轨迹
% viaPoint = [viaPoint1, viaPoint2];
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);


% 定义起始点和终止点
% tspan2 = 0:0.02:1; 
% p1 = [0; 200; 380];
% p2 = [-150; -0; 520];
% z_tip2 = (1 - tspan2) .* p1(3) + tspan2 .* p2(3);
% x_tip2 = (1 - tspan2) .* p1(1) + tspan2 .* p2(1);
% y_tip2 = (1 - tspan2) .* p1(2) + tspan2 .* p2(2);
% viaPoint2 = [x_tip2; y_tip2; z_tip2];
% tspan1 = 0:0.02:1; 
% p1 = [0; 0; 210];
% p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% % 合并两段轨迹
% viaPoint = [viaPoint1, viaPoint2];
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);

% 8 
 tspan2 = 0:deg2rad(5):2*pi;
 z_tip2 = 520*ones(1,length(tspan2));
 x_tip2 = 100*sign((cos(tspan2))).*(sin(tspan2)).*cos(tspan2).^2;
 y_tip2 = 100*sign(cos(tspan2)).*cos(tspan2).^2;
 viaPoint2 = [x_tip2; y_tip2; z_tip2];
 tspan1 = 0:0.02:1; 
 p1 = [0; 0; 210];
 p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
 z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
 x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
 y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
 viaPoint1 = [x_tip1; y_tip1; z_tip1];
% % 合并两段轨迹
 viaPoint = [viaPoint1, viaPoint2];
 x_tip = viaPoint(1,:);
 y_tip = viaPoint(2,:);
 z_tip = viaPoint(3,:);

% O
tspan2 = 0:deg2rad(3):2*pi;
z_tip2 = 530*ones(1,length(tspan2));
x_tip2 = 100*cos(tspan2);
y_tip2 = 100*sin(tspan2);
viaPoint2 = [x_tip2; y_tip2; z_tip2];
tspan1 = 0:0.02:1; 
p1 = [0; 0; 210];
p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
 y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
 viaPoint1 = [x_tip1; y_tip1; z_tip1];
% %合并两段轨迹
viaPoint = [viaPoint1, viaPoint2];
 x_tip = viaPoint(1,:);
 y_tip = viaPoint(2,:);
z_tip = viaPoint(3,:);

% Oval%
% tspan2 = 0:deg2rad(360/((10/0.16))):6*pi;
% z_tip2 = (10*tspan2+90)*.5+ 480;
% x_tip2 = 100*cos(tspan2-2);
% y_tip2 = 100*sin(tspan2);
% viaPoint2 = [x_tip2; y_tip2; z_tip2];
% tspan1 = 0:0.02:1; 
% p1 = [0; 0; 210];
% p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% %合并两段轨迹
% viaPoint = [viaPoint1, viaPoint2];
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);

% Spinning
%interval = deg2rad(5);
%tspan2 = 0:interval:5*pi;
%x_tip2 = 7*sign(cos(tspan2)).*tspan2.*cos(tspan2).^2;
%y_tip2 = -7*sign(sin(tspan2)).*tspan2.*sin(tspan2).^2;
%z_tip2 = 525*ones(1,length(tspan2));
%viaPoint2 = [x_tip2; y_tip2; z_tip2];
%tspan1 = 0:0.02:1; 
%p1 = [0; 0; 210];
%p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
%z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
%x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
%y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
%viaPoint1 = [x_tip1; y_tip1; z_tip1];
% 合并两段轨迹
%viaPoint = [viaPoint1, viaPoint2];
%x_tip = viaPoint(1,:);
%y_tip = viaPoint(2,:);
%z_tip = viaPoint(3,:);

% star 
% tspan2 = 0:deg2rad(16):10*pi;
% x_tip2 = 10*((7-5)*cos(tspan2) + 10*cos((2/5)*tspan2));
% y_tip2 = 10*((7-5)*sin(tspan2) - 10*sin((2/5)*tspan2));
% z_tip2 = 540*ones(1,length(tspan2));
% viaPoint2 = [x_tip2; y_tip2; z_tip2];
% tspan1 = 0:0.02:1; 
% p1 = [0; 0; 210];
% p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% % 合并两段轨迹
% viaPoint = [viaPoint1, viaPoint2];
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);

% Square
% interval = deg2rad(3);
% tspan2 = 0:interval:2*pi;
% x_tip2 = 100*sign(cos(tspan2)).*cos(tspan2).^2;
% y_tip2 = 100*sign(sin(tspan2)).*sin(tspan2).^2;
% z_tip2 = 540*ones(1,length(tspan2));
% viaPoint2 = [x_tip2; y_tip2; z_tip2];
% tspan1 = 0:0.02:1; 
% p1 = [0; 0; 210];
% p2 = viaPoint2(:, 1); % 第二段圆轨迹的起点
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% % 合并两段轨迹
% viaPoint = [viaPoint1, viaPoint2];
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);

% 椭圆轨迹
% a = 120; % 长轴
% b = 80;  % 短轴
% z_height = 540; 
% interval = deg2rad(3); 
% tspan2 = 0:interval:2*pi; 
% x_tip2 = a * cos(tspan2);
% y_tip2 = b * sin(tspan2);
% z_tip2 = z_height * ones(1, length(tspan2));
% viaPoint2 = [x_tip2; y_tip2; z_tip2];
% tspan1 = 0:0.02:1;
% p1 = [0; 0; 210]; 
% p2 = viaPoint2(:, 1);
% z_tip1 = (1 - tspan1) .* p1(3) + tspan1 .* p2(3);
% x_tip1 = (1 - tspan1) .* p1(1) + tspan1 .* p2(1);
% y_tip1 = (1 - tspan1) .* p1(2) + tspan1 .* p2(2);
% viaPoint1 = [x_tip1; y_tip1; z_tip1];
% viaPoint = [viaPoint1, viaPoint2];
% x_tip = viaPoint(1,:);
% y_tip = viaPoint(2,:);
% z_tip = viaPoint(3,:);

% random_trajectory
% num_turns = 5; % 圈数
% num_points = 200; % 轨迹上的点数
% z_start = 600; % 螺旋起始高度
% z_end = 100;  % 螺旋结束高度
% r_start = 20; % 起始半径
% r_end = 150; % 结束半径
% theta = linspace(0, num_turns * 2 * pi, num_points); % 角度从 0 到 num_turns * 2π
% z_tip = linspace(z_start, z_end, num_points); % Z 方向逐渐下降
% r_tip = linspace(r_start, r_end, num_points); % 半径逐渐增大
% x_tip = r_tip .* cos(theta); % X 方向
% y_tip = r_tip .* sin(theta); % Y 方向
% viaPoint = [x_tip; y_tip; z_tip]; % 目标点矩阵

save('viaPointData.mat', 'viaPoint');
ax = 400;
L0 = [105; 105; 105; 105; 105; 105];  % 初始值
L_prev = L0;                          % 初始化 L_prev 为 L0
L = [];                               % 空矩阵保存结果
% 初始化雅可比矩阵存储
J = cell(1, size(L,2)); % 存储每一步的雅可比矩阵
lambda = zeros(1, size(L,2)); % 存储每一步的最大特征值

for i = 1:length(viaPoint)

    task = viaPoint(:,i);

    % if isempty(L_prev)
    %     L_prev = L0;
    %     J{i} = pinv(task/L(:,i));
    % else
    %     J{i} = pinv(task/L(:,i-1));
    % end
    % 
    % [u, s, v] = svd(J{i});
    % lambda(i) = max((eig(s'*s)));

    % 定义目标函数
    w1 = 10;   % 位置权重
    w2 = 0.1;  % 平滑权重
    fun = @(L) w1 * norm(task - fwk(L))^2 + w2 * norm(L - L_prev)^2;
    
    % 优化约束
    A = [];   % 无线性不等式约束
    b = [];
    lb = 105 * ones(6,1);  % 下界（其他）
    ub = 320 * ones(6,1);  % 上界（其他）
    % lb = max(105 * ones(6,1));  % 下界(圆轨迹)
    % ub = min(320 * ones(6,1));  % 上界(圆轨迹)
    
    % 定义非线性约束
    nonlcon = @(L) phaseAngleConstraints(L);

    % 优化选项
    options = optimoptions('fmincon', ...
    'Display', 'iter', ...
    'Algorithm', 'sqp', ...
    'MaxIterations', 5000, ...
    'MaxFunctionEvaluations', 20000, ...
    'ConstraintTolerance', 1e-6, ...
    'OptimalityTolerance', 1e-8);
    
    % 调用 fmincon 优化
    [L(:,i), fval(i)] = fmincon(fun, L_prev, A, b, [], [], lb, ub, [], options);
    
    % 保存结果
    L_prev = L(:,end);  % 更新 L_prev 为当前解
end

% save('jacobian.m','J','lambda');

% 初始化 q
q = zeros(6, size(L, 2));  % 假设 L 已经定义并有值

% 显示所有路径点对应的 L 值
fprintf('\nAll lengths for the trajectory:\n');
for i = 1:size(L, 2)  % 遍历每个路径点
    
    % 每个电机走的步长
    q_11 = L(1,i) - 105;
    q_12 = L(2,i) - 105;
    q_13 = L(3,i) - 105;
    q_14 = (L(1,i) + L(2,i)) / 2 - 105;
    q_15 = (L(2,i) + L(3,i)) / 2 - 105;
    q_16 = (L(1,i) + L(3,i)) / 2 - 105;
    
    q_24 = L(4,i) - 105;
    q_25 = L(5,i) - 105;
    q_26 = L(6,i) - 105;
    
    q_1 = q_11;
    q_2 = q_12;
    q_3 = q_13;
    q_4 = q_14 + q_24;
    q_5 = q_15 + q_25;
    q_6 = q_16 + q_26;
    
    % 存储到 q
    q(:,i) = [q_1; q_2; q_3; q_4; q_5; q_6];
    
    % 打印调试信息
    fprintf('Point %d:\n', i);
    for j = 1:6  % 遍历每个 L 的值
        fprintf('  L%d = %.6f mm\n', j, L(j, i));
    end
    disp('q values:');
    disp(q(:,i));  % 打印当前点的 q 值
end

toc

% 绘制结果
% figure(1)
% hold on
% for j = 1:6
%     subplot(3, 2, j)
%     plot(L(j, 52:end), 'linewidth', 1)
%     ylabel('Length (mm)')
%     xlabel('Point index')
%     title(['L' num2str(j)])
% end
% 
% figure(2);
% plot3(viaPoint(1, :), viaPoint(2, :), viaPoint(3, :), 'r-', 'LineWidth', 1.5);
% hold on;
% for i = 1:size(L, 2)
%     predicted_point = fwk(L(:, i));
%     plot3(predicted_point(1), predicted_point(2), predicted_point(3), 'bo');
% end
% set(gca,'zdir','reverse')
% legend('Target Trajectory', 'Predicted Points');
% title('Trajectory Fitting');


%% This part shows the vertically-placed view using the `drawAnimation()` function. %%
% GIF 文件名
gif_filename = 'animation.gif';

% 创建动画并保存为 GIF
for i = 1:size(L, 2)
    % 调用 drawAnimation 函数
    [pcplot, tip(:, i), sim_angle(:, i)] = drawAnimation(L(:, i), ax);

    % 更新轨迹线
    hold on;
    plt = plot3(tip(1, 1:i), tip(2, 1:i), tip(3, 1:i), 'r-', 'LineWidth', 1);
    hold off;

    % 获取当前帧
    frame = getframe(gcf);
    img = frame2im(frame); % 将帧转换为图像
    [img_indexed, colormap] = rgb2ind(img, 256); % 将图像转换为索引颜色模式

    % 将帧保存为 GIF
    if i == 1
        % 创建 GIF 文件（覆盖模式）
        imwrite(img_indexed, colormap, gif_filename, 'gif', 'LoopCount', inf, 'DelayTime', 0.1);
    else
        % 追加帧到 GIF 文件
        imwrite(img_indexed, colormap, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
    end
end

%% Analysis
% gif_name = 'analysis.gif';
% figure(3); % 确保 figure(3) 是当前窗口
% set(gcf, 'color', 'w');
% 
% tic
% for j = 1:size(L,2)
% 
%     % 调用 Analysis，tip 累积
%     [draw, tip] = Analysis(L(:, j), x_tip, y_tip, z_tip, j);
% 
%     % 获取当前帧
%     frame = getframe(gcf); % 获取 figure(3) 的当前图像
%     img = frame2im(frame); % 将帧转换为图像
%     [img_indexed, colormap] = rgb2ind(img, 256); % 转换为索引颜色
% 
%     % 保存为 GIF
%     if j == 1
%         % 创建 GIF 文件（覆盖模式）
%         imwrite(img_indexed, colormap, gif_name, 'gif', 'LoopCount', inf, 'DelayTime', 0.1);
%     else
%         % 追加帧到 GIF 文件
%         imwrite(img_indexed, colormap, gif_name, 'gif', 'WriteMode', 'append', 'DelayTime', 0.1);
%     end
% 
%     % 避免过快刷新
%     pause(0.05)
% 
% end
% toc

%%画正运动学轨迹