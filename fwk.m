 function [p_02, R_02] = fwk(L)
    % 确保L是列向量
    L = L(:);
    
    % Constants
    D = 12; % Geometry constant

    % Segment lengths
    ds_1 = (L(1) + L(2) + L(3)) / 3;
    ds_2 = (L(4) + L(5) + L(6)) / 3;

    % 计算曲率之前的安全检查
    sum_L1 = sum(L(1:3));
    sum_L2 = sum(L(4:6));
    
    % 计算曲率项
    term1 = sum(L(1:3).^2) - (L(1)*L(2) + L(2)*L(3) + L(3)*L(1));
    term2 = sum(L(4:6).^2) - (L(4)*L(5) + L(5)*L(6) + L(6)*L(4));
    
    % 确保项为非负
    term1 = max(0, term1);
    term2 = max(0, term2);
    
    % 计算曲率
    k_1 = 2 * sqrt(term1) / (D * sum_L1);
    k_2 = 2 * sqrt(term2) / (D * sum_L2);
    
    % 防止除零
    k_1 = max(k_1, 1e-6);
    k_2 = max(k_2, 1e-6);

    % 计算方向角
    phi_1 = atan2(3*(L(2)-L(3)), sqrt(3)*(2*L(1)-L(2)-L(3)));
    phi_2 = atan2(3*(L(5)-L(6)), sqrt(3)*(2*L(4)-L(5)-L(6)));

    % 计算弯曲角
    theta_1 = k_1 * ds_1;
    theta_2 = k_2 * ds_2;

    % 计算位置
    x_01 = (1/k_1) * (1-cos(theta_1)) * cos(phi_1);
    y_01 = (1/k_1) * (1-cos(theta_1)) * sin(phi_1);
    z_01 = (1/k_1) * sin(theta_1);
    p_01 = [x_01; y_01; z_01];

    R_01 = rotz(rad2deg(phi_1)) * roty(rad2deg(theta_1)) * rotz(rad2deg(-phi_1));

    x_12 = (1/k_2) * (1-cos(theta_2)) * cos(phi_2);
    y_12 = (1/k_2) * (1-cos(theta_2)) * sin(phi_2);
    z_12 = (1/k_2) * sin(theta_2);
    p_12 = [x_12; y_12; z_12];

    R_12 = rotz(rad2deg(phi_2)) * roty(rad2deg(theta_2)) * rotz(rad2deg(-phi_2));
    R_02 = R_01 * R_12;

    % Final position
    p_02 = p_01 + R_01 * p_12;
    p_02 = p_02(:, end);
end

