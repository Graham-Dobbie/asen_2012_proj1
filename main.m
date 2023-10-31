
%% House keeping
clc; 
close all; 
clear; 

%% Read in Calibration Data 
static_test = readmatrix('Static Test Stand Calibration Case 1.xlsx');

% Parse data
weight = static_test(:,1);
F1 = static_test(:,4) - static_test(:,2); % Adjusting for voltage offset
F2 = static_test(:,5) - static_test(:,1);% Adjusting for voltage offset

% Getting the Adjusted Applied Load
Weight_T1 = static_test(:,1) .* ( F1 ./ ( F1 + F2) );
Weight_T2 = static_test(:,1) .* ( F2 ./ ( F1 + F2) ); 

% Plotting Adjusted Applied Load
figure(3)
tiledlayout(2,1)

% F1 data
nexttile
scatter(Weight_T1 ,F1)
xlabel("Applied Load (lb)")
ylabel("Measured Voltage (mV)")
title("F1 Data")
hold on
legend('F1')

% F2 data
nexttile
scatter(Weight_T2,F2, 'Color', 'g')
xlabel("Applied Load (lb)")
ylabel("Measured Voltage (mV)")
title("F2 Data")
legend('F2')


%% Fit model to calibration data
polyorder = 1;
% Fit linear model to adjusted applied weight data
[F1poly,S1] = polyfit(Weight_T1, F1, polyorder);
[F2poly,S2] = polyfit(Weight_T2, F2, polyorder);

% Create linspace to plan a polyval
x = 0:max(Weight_T1)+1;
x2 = 0:max(Weight_T2)+1;

% Ployval for both F1 and F2 data fit
[weight_fit1, delta1] = polyval(F1poly, x, S1);
[weight_fit2, delta2] = polyval(F2poly,x2, S2);

% Calculating error lines for the linear model using 2 sigma
scale_error = 1 % Load cell error

error_F1_pos = weight_fit1 + 2.*delta1 + 2*scale_error;
error_F1_neg = weight_fit1 - 2.*delta1 - 2*scale_error;


% Plotting F1 data with line of best fit 
figure(1)
scatter(Weight_T1,F1)
hold on
plot(x, weight_fit1)
mean(F1)
plot(x, error_F1_pos)
plot(x, error_F1_neg)
ylabel("Volts (mV)")
xlabel("Weight (lb)")

% Error bars for F2 data
error_F2_pos = weight_fit2+ 2.*delta2 + 2*scale_error;
error_F2_neg = weight_fit2-2.*delta2 - 2*scale_error;

% Plotting F1 data with line of best fit 
figure(2)
scatter(Weight_T2,F2)
hold on
plot(x2, weight_fit2)
mean(F2)
plot(x2, error_F2_pos)
plot(x2, error_F2_neg)
ylabel("Volts (mV)")
xlabel("Weight (lbs)")

%% Applying the model to run data

file_paths = ["testrun1.mat", "testrun2.mat", "testrun3.mat", "testrun4.mat", "testrun5.mat", "testrun6.mat", "testrun7.mat", "testrun8.mat", "testrun9.mat", "testrun10.mat"]

for i = 1:length(file_paths)
    plot_data(file_paths(i), F1poly, S1, F2poly, S2, scale_error)
end


function plot_data(test_data_filepath, F1poly, S1, F2poly, S2, scale_error, figure_number)
    % load test run data
    raw_data = load(test_data_filepath);
    % Parse data
    [load_cell_data, time_data ] = deal( raw_data.mV, raw_data.time);
    
    F1_data = load_cell_data(:,1);
    F2_data = load_cell_data(:,2);
    
    
    % Apply model to loadcell data and convert voltage to force
    [F1_load, F1_error] = polyval( F1poly, F1_data, S1);
    [F2_load, F2_error] = polyval( F2poly, F2_data, S2);
    
    % Plot converted thrust data overtime
    figure;
    hold on;
    plot(time_data, F1_load, "b-", time_data, F2_load, "r-");
    xlabel("Time since launch (s)");
    ylabel("Thrust (lb)");
    legend("F1 Thrust", "F2 Thrust");
    title("Total Ploted Thrust Data over Time")


    
    cropped_time_data = transpose(time_data((time_data > 1.80) & (time_data < 2.5)));
    cropped_F1_data = F1_load((time_data > 1.80) & (time_data < 2.5));
    cropped_F2_data = F2_load((time_data > 1.80) & (time_data < 2.5));
    cropped_F1_error = 2.*F1_error((time_data > 1.80) & (time_data < 2.5)) + 2*scale_error;
    cropped_F2_error = 2.*F2_error((time_data > 1.80) & (time_data < 2.5)) + 2*scale_error;
    
    
    figure;
    hold on;
    plot( cropped_time_data, cropped_F1_data, "b-", cropped_time_data, cropped_F2_data, "r-");
    xlabel("Time since launch (s)");
    ylabel("Thrust (lb)");
    legend("F1 Thrust", "F2 Thrust");
    title("Cropped Ploted Thrust Data over Time")
    
    combined_thrust = cropped_F1_data + cropped_F2_data;
    combined_thrust_error  = sqrt(cropped_F1_error.^2+ cropped_F2_error.^2);
    
    sample_idx = 1:10:length(cropped_time_data);
    sample_time = cropped_time_data(sample_idx);
    sample_thrust = combined_thrust(sample_idx);
    sample_error = combined_thrust_error(sample_idx);
    
    figure;
    hold on;
    plot( cropped_time_data, combined_thrust, "k-");
    errorbar(sample_time, sample_thrust, sample_error, "LineStyle","none");
    xlabel("Time since launch (s)");
    ylabel("Thrust (lb)");
    legend("Total Thrust", "Thrust 2 sig error");
    
    title("Cropped Ploted Thrust Data over Time");
end


