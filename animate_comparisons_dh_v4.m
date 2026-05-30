%% Animation V4 - Uses ik_net_dh_v4.mat (DAgger-trained)
clear; clc;

if ~exist('ik_net_dh_v4.mat', 'file')
    error('Run generate_dataset_dh_v4.m then train_nn_dh_v4.m first!');
end
load('ik_net_dh_v4.mat', 'net');

start_offsets = [0, pi/2, pi, 3*pi/2];
offset_labels = {'Start 0d', 'Start 90d', 'Start 180d', 'Start 270d'};

L_home = 105*ones(6,1);
p_home = [0; 0; 210];

for patternID = [1, 2, 3]
    for si = 1:length(start_offsets)
        offset = start_offsets(si);

        if patternID == 1
            tspan = offset:deg2rad(5):(offset + 2*pi);
            z_tip = 350*ones(1,length(tspan));
            x_tip = 100*sign(cos(tspan)).*sin(tspan).*cos(tspan).^2;
            y_tip = 100*sign(cos(tspan)).*cos(tspan).^2;
            patName = '"8"';
        elseif patternID == 2
            tspan = offset:deg2rad(3):(offset + 2*pi);
            z_tip = 360*ones(1,length(tspan));
            x_tip = 100*cos(tspan);
            y_tip = 100*sin(tspan);
            patName = '"O"';
        else
            % Spiral: only run once (offset 0)
            if si > 1, continue; end
            t_sp = linspace(0, 4*pi, 200);
            r_sp = linspace(40, 120, 200);
            x_tip = r_sp.*cos(t_sp);
            y_tip = r_sp.*sin(t_sp);
            z_tip = linspace(340, 370, 200);
            patName = '"Spiral"';
        end
        pattern_traj = [x_tip; y_tip; z_tip];

        p_start = pattern_traj(:,1);
        t_ap = linspace(0, 1, 51);
        approach_traj = p_home + (p_start - p_home) .* t_ap;

        full_traj = [approach_traj, pattern_traj];
        num_points = size(full_traj, 2);
        n_ap = size(approach_traj, 2);
        titleStr = sprintf('%s - %s', patName, offset_labels{si});

        % ========== NUMERICAL ==========
        fprintf('%s: Numerical...\n', titleStr);
        L_prev = L_home;
        L_num = zeros(6, num_points);
        xyz_num = zeros(3, num_points);
        w1 = 10; w2 = 0.1;
        lb = 105*ones(6,1); ub = 320*ones(6,1);
        opts = optimoptions('fmincon','Display','none','Algorithm','sqp');

        for i = 1:num_points
            task = full_traj(:,i);
            fun = @(L) w1*norm(task-fwk(L))^2 + w2*norm(L-L_prev)^2;
            try
                L_num(:,i) = fmincon(fun,L_prev,[],[],[],[],lb,ub,@phaseAngleConstraints,opts);
            catch
                L_num(:,i) = fmincon(fun,L_prev,[],[],[],[],lb,ub,[],opts);
            end
            xyz_num(:,i) = fwk(L_num(:,i));
            L_prev = L_num(:,i);
        end

        % ========== NEURAL NETWORK ==========
        fprintf('%s: Neural Net...\n', titleStr);
        L_net = zeros(6, num_points);
        xyz_net = zeros(3, num_points);
        L_prev_nn = L_home;

        for i = 1:num_points
            task = full_traj(:,i);
            L_pred = net([task; L_prev_nn]);
            L_pred = min(max(L_pred, 105), 320);
            L_net(:,i) = L_pred;
            xyz_net(:,i) = fwk(L_pred);
            L_prev_nn = L_pred;
        end

        % ========== ERRORS (pattern only) ==========
        pat_idx = (n_ap+1):num_points;
        error_num = vecnorm(full_traj(:,pat_idx) - xyz_num(:,pat_idx));
        error_net = vecnorm(full_traj(:,pat_idx) - xyz_net(:,pat_idx));
        fprintf('  Pattern Mean: Num %.2f | NN %.2f | Max: Num %.2f | NN %.2f\n', ...
            mean(error_num), mean(error_net), max(error_num), max(error_net));

        % ========== ANIMATION (saved as GIF) ==========
        if patternID == 1, pTag = 'fig8';
        elseif patternID == 2, pTag = 'circle';
        else, pTag = 'spiral'; end
        gifName = sprintf('anim_%s_%ddeg.gif', pTag, round(rad2deg(offset)));
        delayTime = 1/30;

        fig = figure('Position', [100 100 1100 500], 'Name', titleStr);

        subplot(1,2,1);
        plot3(approach_traj(1,:), approach_traj(2,:), approach_traj(3,:), '-', 'LineWidth', 1, 'Color', [0.6 0.6 0.6]);
        hold on; grid on; axis equal; box on;
        plot3(pattern_traj(1,:), pattern_traj(2,:), pattern_traj(3,:), 'k:', 'LineWidth', 1);
        plot3(p_home(1), p_home(2), p_home(3), 'gs', 'MarkerSize', 10, 'LineWidth', 2);
        plot3(pattern_traj(1,1), pattern_traj(2,1), pattern_traj(3,1), 'go', 'MarkerSize', 8, 'LineWidth', 2);
        title(sprintf('Numerical - %s', titleStr));
        xlabel('x'); ylabel('y'); zlabel('z');
        axis([-150 150 -150 150 0 500]); view(-45, 30);

        subplot(1,2,2);
        plot3(approach_traj(1,:), approach_traj(2,:), approach_traj(3,:), '-', 'LineWidth', 1, 'Color', [0.6 0.6 0.6]);
        hold on; grid on; axis equal; box on;
        plot3(pattern_traj(1,:), pattern_traj(2,:), pattern_traj(3,:), 'k:', 'LineWidth', 1);
        plot3(p_home(1), p_home(2), p_home(3), 'gs', 'MarkerSize', 10, 'LineWidth', 2);
        plot3(pattern_traj(1,1), pattern_traj(2,1), pattern_traj(3,1), 'go', 'MarkerSize', 8, 'LineWidth', 2);
        title(sprintf('Neural Net - %s', titleStr));
        xlabel('x'); ylabel('y'); zlabel('z');
        axis([-150 150 -150 150 0 500]); view(-45, 30);
        drawnow;

        h1a = gobjects(0); h1b = gobjects(0); h1t = gobjects(0);
        h2a = gobjects(0); h2b = gobjects(0); h2t = gobjects(0);

        for i = 1:num_points
            subplot(1,2,1);
            delete([h1a h1b h1t]);
            [s1,s2] = extract_continuum_points(L_num(:,i));
            h1a = plot3(s1(1,:),s1(2,:),s1(3,:),'-','LineWidth',4,'Color',[0 0.45 0.74]);
            h1b = plot3(s2(1,:),s2(2,:),s2(3,:),'-','LineWidth',4,'Color',[0.64 0.08 0.18]);
            h1t = plot3(xyz_num(1,1:i),xyz_num(2,1:i),xyz_num(3,1:i),'b-','LineWidth',1.5);

            subplot(1,2,2);
            delete([h2a h2b h2t]);
            [s1,s2] = extract_continuum_points(L_net(:,i));
            h2a = plot3(s1(1,:),s1(2,:),s1(3,:),'-','LineWidth',4,'Color',[0 0.45 0.74]);
            h2b = plot3(s2(1,:),s2(2,:),s2(3,:),'-','LineWidth',4,'Color',[0.64 0.08 0.18]);
            h2t = plot3(xyz_net(1,1:i),xyz_net(2,1:i),xyz_net(3,1:i),'r-','LineWidth',1.5);

            drawnow;
            frame = getframe(fig);
            [A, map] = rgb2ind(frame.cdata, 256);
            if i == 1
                imwrite(A, map, gifName, 'gif', 'LoopCount', Inf, 'DelayTime', delayTime);
            else
                imwrite(A, map, gifName, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
            end
            pause(0.02);
        end
        fprintf('  Saved %s\n', gifName);
    end
end
