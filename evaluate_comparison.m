%% Comprehensive Evaluation: Numerical IK vs MLP-Based IK

clear; clc; close all;

load('ik_net_dh_v4.mat', 'net');
fprintf('Loaded ik_net_dh_v4.mat\n');

L_home = 105*ones(6,1);
p_home = [0; 0; 210];
lb = 105*ones(6,1); ub = 320*ones(6,1);
w1 = 10; w2 = 0.1;
opts = optimoptions('fmincon','Display','none','Algorithm','sqp');

start_offsets = [0, pi/2, pi, 3*pi/2];
offset_labels = {'0°', '90°', '180°', '270°'};

%% ============================================================
%% SECTION 1: Solve all trajectories and collect data
%% ============================================================
fprintf('\n===== Solving all trajectories =====\n');

results = struct();
idx = 0;

for patternID = [1, 2]
    for si = 1:length(start_offsets)
        idx = idx + 1;
        offset = start_offsets(si);

        if patternID == 1
            tspan = offset:deg2rad(5):(offset + 2*pi);
            z_tip = 350*ones(1,length(tspan));
            x_tip = 100*sign(cos(tspan)).*sin(tspan).*cos(tspan).^2;
            y_tip = 100*sign(cos(tspan)).*cos(tspan).^2;
            patName = 'Figure-8';
        else
            tspan = offset:deg2rad(3):(offset + 2*pi);
            z_tip = 360*ones(1,length(tspan));
            x_tip = 100*cos(tspan);
            y_tip = 100*sin(tspan);
            patName = 'Circle';
        end
        pattern_traj = [x_tip; y_tip; z_tip];

        % Approach
        p_start = pattern_traj(:,1);
        t_ap = linspace(0, 1, 51);
        approach_traj = p_home + (p_start - p_home) .* t_ap;
        full_traj = [approach_traj, pattern_traj];
        num_points = size(full_traj, 2);
        n_ap = size(approach_traj, 2);

        % --- Numerical ---
        L_prev = L_home;
        L_num = zeros(6, num_points);
        xyz_num = zeros(3, num_points);
        time_num = zeros(1, num_points);

        for i = 1:num_points
            task = full_traj(:,i);
            fun = @(L) w1*norm(task-fwk(L))^2 + w2*norm(L-L_prev)^2;
            tic_step = tic;
            try
                L_num(:,i) = fmincon(fun,L_prev,[],[],[],[],lb,ub,@phaseAngleConstraints,opts);
            catch
                L_num(:,i) = fmincon(fun,L_prev,[],[],[],[],lb,ub,[],opts);
            end
            time_num(i) = toc(tic_step);
            xyz_num(:,i) = fwk(L_num(:,i));
            L_prev = L_num(:,i);
        end

        % --- Neural Network ---
        L_net_sol = zeros(6, num_points);
        xyz_net = zeros(3, num_points);
        time_net = zeros(1, num_points);
        L_prev_nn = L_home;

        for i = 1:num_points
            task = full_traj(:,i);
            tic_step = tic;
            L_pred = net([task; L_prev_nn]);
            L_pred = min(max(L_pred, 105), 320);
            time_net(i) = toc(tic_step);
            L_net_sol(:,i) = L_pred;
            xyz_net(:,i) = fwk(L_pred);
            L_prev_nn = L_pred;
        end

        % Store results
        results(idx).patName = patName;
        results(idx).offset_label = offset_labels{si};
        results(idx).full_traj = full_traj;
        results(idx).pattern_traj = pattern_traj;
        results(idx).approach_traj = approach_traj;
        results(idx).n_ap = n_ap;
        results(idx).xyz_num = xyz_num;
        results(idx).xyz_net = xyz_net;
        results(idx).L_num = L_num;
        results(idx).L_net = L_net_sol;
        results(idx).time_num = time_num;
        results(idx).time_net = time_net;
        results(idx).error_num = vecnorm(full_traj - xyz_num);
        results(idx).error_net = vecnorm(full_traj - xyz_net);
        results(idx).pat_idx = (n_ap+1):num_points;

        fprintf('  %s %s done\n', patName, offset_labels{si});
    end
end

%% ============================================================
%% SECTION 2: Summary Table (printed + saved)
%% ============================================================
fprintf('\n===== TABLE: Error Summary (Pattern Phase Only) =====\n');
fprintf('%-18s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s | %-8s\n', ...
    'Trajectory', 'Num Mean', 'Num Max', 'Num Std', 'Num Med', ...
    'NN Mean', 'NN Max', 'NN Std', 'NN Med');
fprintf('%s\n', repmat('-', 1, 110));

table_data = {};
for k = 1:length(results)
    r = results(k);
    e_num = r.error_num(r.pat_idx);
    e_net = r.error_net(r.pat_idx);
    label = sprintf('%s %s', r.patName, r.offset_label);
    fprintf('%-18s | %7.2f  | %7.2f  | %7.2f  | %7.2f  | %7.2f  | %7.2f  | %7.2f  | %7.2f\n', ...
        label, mean(e_num), max(e_num), std(e_num), median(e_num), ...
        mean(e_net), max(e_net), std(e_net), median(e_net));
    table_data{k} = {label, mean(e_num), max(e_num), std(e_num), median(e_num), ...
        mean(e_net), max(e_net), std(e_net), median(e_net)};
end

%% ============================================================
%% SECTION 3: Speed Comparison Table
%% ============================================================
fprintf('\n===== TABLE: Computation Time Per Step =====\n');
fprintf('%-18s | %-12s | %-12s | %-10s\n', 'Trajectory', 'Num (ms)', 'NN (ms)', 'Speedup');
fprintf('%s\n', repmat('-', 1, 60));

all_time_num = [];
all_time_net = [];
for k = 1:length(results)
    r = results(k);
    t_num_ms = mean(r.time_num(r.pat_idx)) * 1000;
    t_net_ms = mean(r.time_net(r.pat_idx)) * 1000;
    label = sprintf('%s %s', r.patName, r.offset_label);
    fprintf('%-18s | %10.3f   | %10.4f   | %8.0fx\n', label, t_num_ms, t_net_ms, t_num_ms/t_net_ms);
    all_time_num = [all_time_num, r.time_num(r.pat_idx)];
    all_time_net = [all_time_net, r.time_net(r.pat_idx)];
end
fprintf('%s\n', repmat('-', 1, 60));
fprintf('%-18s | %10.3f   | %10.4f   | %8.0fx\n', 'OVERALL MEAN', ...
    mean(all_time_num)*1000, mean(all_time_net)*1000, mean(all_time_num)/mean(all_time_net));

%% ============================================================
%% FIGURE 1: Position Error Over Trajectory Steps (per pattern)
%% ============================================================
for patternID = [1, 2]
    if patternID == 1, pat_range = 1:4; pat_title = 'Figure-8';
    else, pat_range = 5:8; pat_title = 'Circle'; end

    fig1 = figure('Position', [50 50 1200 400], 'Color', 'w');
    for sub = 1:4
        k = pat_range(sub);
        r = results(k);
        pat_steps = r.pat_idx;

        subplot(1,4,sub);
        plot(r.error_num(pat_steps), 'b-', 'LineWidth', 1.5); hold on;
        plot(r.error_net(pat_steps), 'r-', 'LineWidth', 1.5);
        xlabel('Step'); ylabel('Position Error (mm)');
        title(sprintf('Start %s', r.offset_label));
        legend('Numerical', 'MLP', 'Location', 'best');
        grid on;
        set(gca, 'FontSize', 10);
    end
    sgtitle(sprintf('%s Pattern: Position Error Over Trajectory', pat_title), 'FontSize', 14, 'FontWeight', 'bold');
    saveas(fig1, sprintf('fig_error_steps_%s.png', lower(pat_title)));
    saveas(fig1, sprintf('fig_error_steps_%s.fig', lower(pat_title)));
end

%% ============================================================
%% FIGURE 2: Box Plot of Errors (all 8 trajectories)
%% ============================================================
fig2 = figure('Position', [50 50 1000 500], 'Color', 'w');

all_errors_num = [];
all_errors_net = [];
group_num = [];
group_net = [];
labels_all = {};

for k = 1:length(results)
    r = results(k);
    e_num = r.error_num(r.pat_idx)';
    e_net = r.error_net(r.pat_idx)';
    label = sprintf('%s\n%s', r.patName, r.offset_label);
    labels_all{k} = label;

    all_errors_num = [all_errors_num; e_num];
    all_errors_net = [all_errors_net; e_net];
    group_num = [group_num; k*ones(length(e_num),1)];
    group_net = [group_net; k*ones(length(e_net),1)];
end

subplot(1,2,1);
boxplot(all_errors_num, group_num, 'Labels', labels_all);
ylabel('Position Error (mm)'); title('Numerical (fmincon)');
grid on; set(gca, 'FontSize', 9);

subplot(1,2,2);
boxplot(all_errors_net, group_net, 'Labels', labels_all);
ylabel('Position Error (mm)'); title('MLP-Based');
grid on; set(gca, 'FontSize', 9);

sgtitle('Error Distribution Across Trajectories', 'FontSize', 14, 'FontWeight', 'bold');
saveas(fig2, 'fig_boxplot_errors.png');
saveas(fig2, 'fig_boxplot_errors.fig');

%% ============================================================
%% FIGURE 3: Bar Chart — Mean & Max Error Comparison
%% ============================================================
fig3 = figure('Position', [50 50 1400 600], 'Color', 'w');

mean_num = zeros(1, length(results));
mean_net = zeros(1, length(results));
max_num = zeros(1, length(results));
max_net = zeros(1, length(results));
bar_labels = {};

for k = 1:length(results)
    r = results(k);
    e_num = r.error_num(r.pat_idx);
    e_net = r.error_net(r.pat_idx);
    mean_num(k) = mean(e_num);
    mean_net(k) = mean(e_net);
    max_num(k) = max(e_num);
    max_net(k) = max(e_net);
    bar_labels{k} = sprintf('%s %s', r.patName(1:3), r.offset_label);
end

subplot(1,2,1);
bar_data_mean = [mean_num; mean_net]';
b1 = bar(bar_data_mean);
b1(1).FaceColor = [0.2 0.4 0.8];
b1(2).FaceColor = [0.9 0.3 0.2];
set(gca, 'XTickLabel', bar_labels, 'FontSize', 12);
ylabel('Mean Error (mm)', 'FontSize', 13); title('Mean Position Error', 'FontSize', 14);
legend('Numerical', 'MLP', 'Location', 'northwest', 'FontSize', 11);
grid on;

subplot(1,2,2);
bar_data_max = [max_num; max_net]';
b2 = bar(bar_data_max);
b2(1).FaceColor = [0.2 0.4 0.8];
b2(2).FaceColor = [0.9 0.3 0.2];
set(gca, 'XTickLabel', bar_labels, 'FontSize', 12);
ylabel('Max Error (mm)', 'FontSize', 13); title('Maximum Position Error', 'FontSize', 14);
legend('Numerical', 'MLP', 'Location', 'northwest', 'FontSize', 11);
grid on;

sgtitle('Error Comparison: Numerical vs MLP', 'FontSize', 16, 'FontWeight', 'bold');
saveas(fig3, 'fig_bar_errors.png');
saveas(fig3, 'fig_bar_errors.fig');

%% ============================================================
%% FIGURE 4: 2D Trajectory Overlay (Top-Down XY View)
%% ============================================================
for patternID = [1, 2]
    if patternID == 1, pat_range = 1:4; pat_title = 'Figure-8';
    else, pat_range = 5:8; pat_title = 'Circle'; end

    fig4 = figure('Position', [50 50 1000 900], 'Color', 'w');
    for sub = 1:4
        k = pat_range(sub);
        r = results(k);
        pi2 = r.pat_idx;

        subplot(2,2,sub);
        plot(r.full_traj(1,pi2), r.full_traj(2,pi2), 'k--', 'LineWidth', 2); hold on;
        plot(r.xyz_num(1,pi2), r.xyz_num(2,pi2), 'b-', 'LineWidth', 1.5);
        plot(r.xyz_net(1,pi2), r.xyz_net(2,pi2), 'r-', 'LineWidth', 1.5);
        plot(r.full_traj(1,pi2(1)), r.full_traj(2,pi2(1)), 'go', 'MarkerSize', 10, 'LineWidth', 2);
        xlabel('X (mm)'); ylabel('Y (mm)');
        title(sprintf('Start %s', r.offset_label));
        legend('Desired', 'Numerical', 'MLP', 'Start', 'Location', 'best');
        axis equal; grid on;
        set(gca, 'FontSize', 10);
    end
    sgtitle(sprintf('%s: Trajectory Tracking (Top-Down XY)', pat_title), 'FontSize', 14, 'FontWeight', 'bold');
    saveas(fig4, sprintf('fig_trajectory_xy_%s.png', lower(pat_title)));
    saveas(fig4, sprintf('fig_trajectory_xy_%s.fig', lower(pat_title)));
end

%% ============================================================
%% FIGURE 5: Computation Time Comparison (Bar)
%% ============================================================
fig5 = figure('Position', [50 50 800 400], 'Color', 'w');

time_means = zeros(length(results), 2);
for k = 1:length(results)
    r = results(k);
    time_means(k, 1) = mean(r.time_num(r.pat_idx)) * 1000; % ms
    time_means(k, 2) = mean(r.time_net(r.pat_idx)) * 1000; % ms
end

subplot(1,2,1);
b5 = bar(time_means);
b5(1).FaceColor = [0.2 0.4 0.8];
b5(2).FaceColor = [0.9 0.3 0.2];
set(gca, 'XTickLabel', bar_labels, 'FontSize', 9);
ylabel('Time per step (ms)'); title('Computation Time');
legend('Numerical', 'MLP');
grid on;

subplot(1,2,2);
speedup = time_means(:,1) ./ time_means(:,2);
bar(speedup, 'FaceColor', [0.2 0.7 0.3]);
set(gca, 'XTickLabel', bar_labels, 'FontSize', 9);
ylabel('Speedup (x)'); title('MLP Speedup Factor');
grid on;

sgtitle('Computation Time: Numerical vs MLP', 'FontSize', 14, 'FontWeight', 'bold');
saveas(fig5, 'fig_speed_comparison.png');
saveas(fig5, 'fig_speed_comparison.fig');

%% ============================================================
%% FIGURE 6: Cumulative Error Distribution (CDF)
%% ============================================================
fig6 = figure('Position', [50 50 900 400], 'Color', 'w');

% Collect all pattern-phase errors
all_pat_err_num = [];
all_pat_err_net = [];
for k = 1:length(results)
    r = results(k);
    all_pat_err_num = [all_pat_err_num, r.error_num(r.pat_idx)];
    all_pat_err_net = [all_pat_err_net, r.error_net(r.pat_idx)];
end

subplot(1,2,1);
[f1, x1] = ecdf(all_pat_err_num);
[f2, x2] = ecdf(all_pat_err_net);
plot(x1, f1*100, 'b-', 'LineWidth', 2); hold on;
plot(x2, f2*100, 'r-', 'LineWidth', 2);
xlabel('Position Error (mm)'); ylabel('Cumulative %');
title('All Trajectories');
legend('Numerical', 'MLP', 'Location', 'southeast');
grid on; set(gca, 'FontSize', 11);

% Per pattern
subplot(1,2,2);
err_8_net = []; err_O_net = [];
for k = 1:4
    r = results(k); err_8_net = [err_8_net, r.error_net(r.pat_idx)];
end
for k = 5:8
    r = results(k); err_O_net = [err_O_net, r.error_net(r.pat_idx)];
end
[f3, x3] = ecdf(err_8_net);
[f4, x4] = ecdf(err_O_net);
plot(x3, f3*100, 'm-', 'LineWidth', 2); hold on;
plot(x4, f4*100, 'c-', 'LineWidth', 2);
xlabel('Position Error (mm)'); ylabel('Cumulative %');
title('MLP Error by Pattern');
legend('Figure-8', 'Circle', 'Location', 'southeast');
grid on; set(gca, 'FontSize', 11);

sgtitle('Cumulative Distribution of Position Errors', 'FontSize', 14, 'FontWeight', 'bold');
saveas(fig6, 'fig_cdf_errors.png');
saveas(fig6, 'fig_cdf_errors.fig');

%% ============================================================
%% FIGURE 7: Tendon Length Profiles (one example per pattern)
%% ============================================================
for patternID = [1, 2]
    if patternID == 1, k = 1; pat_title = 'Figure-8';
    else, k = 5; pat_title = 'Circle'; end

    r = results(k);
    pi2 = r.pat_idx;

    fig7 = figure('Position', [50 50 1200 600], 'Color', 'w');
    tendon_names = {'L_1', 'L_2', 'L_3', 'L_4', 'L_5', 'L_6'};
    for t = 1:6
        subplot(2,3,t);
        plot(r.L_num(t, pi2), 'b-', 'LineWidth', 1.5); hold on;
        plot(r.L_net(t, pi2), 'r--', 'LineWidth', 1.5);
        xlabel('Step'); ylabel('Length (mm)');
        title(tendon_names{t});
        if t == 1, legend('Numerical', 'MLP', 'Location', 'best'); end
        grid on; ylim([100 325]);
        set(gca, 'FontSize', 10);
    end
    sgtitle(sprintf('%s (Start 0°): Tendon Length Profiles', pat_title), 'FontSize', 14, 'FontWeight', 'bold');
    saveas(fig7, sprintf('fig_tendons_%s.png', lower(pat_title)));
    saveas(fig7, sprintf('fig_tendons_%s.fig', lower(pat_title)));
end

%% ============================================================
%% FIGURE 8: 3D Trajectory Comparison (static)
%% ============================================================
for patternID = [1, 2]
    if patternID == 1, k = 1; pat_title = 'Figure-8';
    else, k = 5; pat_title = 'Circle'; end

    r = results(k);
    pi2 = r.pat_idx;

    fig8 = figure('Position', [50 50 700 550], 'Color', 'w');
    plot3(r.full_traj(1,pi2), r.full_traj(2,pi2), r.full_traj(3,pi2), 'k--', 'LineWidth', 2); hold on;
    plot3(r.xyz_num(1,pi2), r.xyz_num(2,pi2), r.xyz_num(3,pi2), 'b-', 'LineWidth', 2);
    plot3(r.xyz_net(1,pi2), r.xyz_net(2,pi2), r.xyz_net(3,pi2), 'r-', 'LineWidth', 1.5);
    xlabel('X (mm)'); ylabel('Y (mm)'); zlabel('Z (mm)');
    title(sprintf('%s: 3D Trajectory (Start 0°)', pat_title));
    legend('Desired', 'Numerical', 'MLP', 'Location', 'best');
    grid on; axis equal; view(-45, 30);
    set(gca, 'FontSize', 11);
    saveas(fig8, sprintf('fig_3d_%s.png', lower(pat_title)));
    saveas(fig8, sprintf('fig_3d_%s.fig', lower(pat_title)));
end

%% ============================================================
%% OVERALL SUMMARY
%% ============================================================
fprintf('\n\n========================================\n');
fprintf('       OVERALL SUMMARY\n');
fprintf('========================================\n');
fprintf('All pattern errors (excluding approach):\n');
fprintf('  Numerical: Mean=%.3f, Max=%.3f, Std=%.3f mm\n', ...
    mean(all_pat_err_num), max(all_pat_err_num), std(all_pat_err_num));
fprintf('  MLP:       Mean=%.3f, Max=%.3f, Std=%.3f mm\n', ...
    mean(all_pat_err_net), max(all_pat_err_net), std(all_pat_err_net));
fprintf('  MLP 95th percentile: %.3f mm\n', prctile(all_pat_err_net, 95));
fprintf('\nSpeed:\n');
fprintf('  Numerical: %.3f ms/step avg\n', mean(all_time_num)*1000);
fprintf('  MLP:       %.4f ms/step avg\n', mean(all_time_net)*1000);
fprintf('  Speedup:   %.0fx\n', mean(all_time_num)/mean(all_time_net));
fprintf('\nFigures saved as PNG + FIG in: %s\n', pwd);
fprintf('========================================\n');
