clc; 
close all; 
clear; 

%reading in data 
static_test = readmatrix('Static Test Stand Calibration Case 1.xlsx');

%convert mv to lbs


raw_data = load("testrun1.mat");
[load_cell_data, time_data ] = deal( raw_data.mV, raw_data.time);

F1_data = load_cell_data(:,1);
F2_data = load_cell_data(:,2);

fit_model_F1 = @(load_cell_voltage) mvToForce(load_cell_voltage, f1_poly);
fit_model_F2 = @(load_cell_voltage) mvToForce(load_cell_voltage, f2_poly);

F1_load = fit_model_F1(F1_data);
F2_load = fit_model_F2(F2_data);


figure(3);
hold on;

plot(time_data, F1_load, "b-", time_data, F2_load, "g-");
xlabel("Time since launch (s)");
ylabel("Thrust (lb)");
legend("F1 Thrust", "F2_Thrust");





function force = mvToForce(mv_data, poly)
    force = poly(1)*mv_data + poly(2);
end


