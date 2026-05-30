%% Train NN V4: DAgger-augmented data
% Larger dataset with noise-augmented L_prev
% Saves to ik_net_dh_v4.mat

clear; clc;
load('ik_dataset_dh_v4.mat');

fprintf('Dataset V4: %d samples\n', size(input_data, 2));

%% Create NN
net = feedforwardnet([128 64 32], 'trainscg');

net.trainParam.epochs = 5000;
net.trainParam.max_fail = 200;
net.trainParam.min_grad = 1e-10;
net.trainParam.show = 25;
net.trainParam.goal = 0;

net.layers{1}.transferFcn = 'tansig';
net.layers{2}.transferFcn = 'tansig';
net.layers{3}.transferFcn = 'tansig';
net.layers{4}.transferFcn = 'purelin';

net.divideParam.trainRatio = 0.70;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0.15;

%% Train
fprintf('Training...\n');
[net, tr] = train(net, input_data, output_data);

%% Evaluate
y = net(input_data);
perf = mse(net, output_data, y);
fprintf('\nTendon MSE: %.2f (RMSE: %.2f mm)\n', perf, sqrt(perf));

fprintf('Evaluating tip errors on 500 samples...\n');
n_test = min(500, size(input_data,2));
idx = randperm(size(input_data,2), n_test);
pos_err = zeros(1, n_test);
for i = 1:n_test
    target = input_data(1:3, idx(i));
    L_pred = net(input_data(:, idx(i)));
    L_pred = min(max(L_pred, 105), 320);
    pos_err(i) = norm(target - fwk(L_pred));
end
fprintf('Mean tip error: %.2f mm\n', mean(pos_err));
fprintf('Max  tip error: %.2f mm\n', max(pos_err));
fprintf('Median: %.2f | 95th: %.2f mm\n', median(pos_err), prctile(pos_err,95));

save('ik_net_dh_v4.mat', 'net', 'tr');
fprintf('\nSaved as ik_net_dh_v4.mat (with training record)\n');
