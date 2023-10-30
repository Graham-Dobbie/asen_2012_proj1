clc; 
close all; 
clear; 

%reading in data 
static_test = readmatrix('Static Test Stand Calibration Case 1.xlsx');


%convert mv to lbs 

weight = static_test(:,1);
F1 = static_test(:,4) - static_test(:,2);
F2 = static_test(:,5) - static_test(:,1);

Weight_T1 = static_test(:,1) .* ( F1 ./ ( F1 + F2) );
Weight_T2 = static_test(:,1) .* ( F2 ./ ( F1 + F2) ); 

figure(3)
tiledlayout(2,1)
nexttile
scatter(Weight_T1 ,F1)
hold on
legend('F1')

nexttile
scatter(Weight_T2,F2, 'Color', 'g')
legend('F2')

polyorder = 1;
[F1poly,S1] = polyfit(Weight_T1, F1, polyorder);
[F2poly,S2] = polyfit(Weight_T2, F2, polyorder);

x = 0:max(Weight_T1)+1;
x2 = 0:max(Weight_T2)+1;
[weight_fit1, delta1] = polyval(F1poly, x, S1);
[weight_fit2, delta2] = polyval(F2poly,x2, S2);

sigma_y1 = sqrt(1/(length(x)-2) * sum((weight_fit1-Weight_T1).^2));
sigma_y2 = sqrt(1/(length(x2)-2) * sum((weight_fit2-Weight_T2).^2));

scale_error = 1

error_F1_pos = weight_fit1 + 2.*delta1 + 2*scale_error;
error_F1_neg = weight_fit1 - 2.*delta1 - 2*scale_error;

figure(1)
scatter(Weight_T1,F1)
hold on
plot(x, weight_fit1)
mean(F1)
plot(x, error_F1_pos)
plot(x, error_F1_neg)
ylabel("Volts (mV)")
xlabel("Weight (lbs)")

error_F2_pos = weight_fit2+ 2.*delta2 + 2*scale_error;
error_F2_neg = weight_fit2-2.*delta2 - 2*scale_error;

figure(2)
scatter(Weight_T2,F2)
hold on
plot(x2, weight_fit2)
mean(F2)
plot(x2, error_F2_pos)
plot(x2, error_F2_neg)
ylabel("Volts (mV)")
xlabel("Weight (lbs)")


raw_data = load("testrun1.mat");
[load_cell_data, time_data ] = deal( raw_data.mV, raw_data.time);

F1_data = load_cell_data(:,1);
F2_data = load_cell_data(:,2);

fit_model_F1 = @(load_cell_voltage) mvToForce(load_cell_voltage, F1poly);
fit_model_F2 = @(load_cell_voltage) mvToForce(load_cell_voltage, F2poly);

F1_load = fit_model_F1(F1_data);
F2_load = fit_model_F2(F2_data);


figure(5);
hold on;

plot(time_data, F1_load, "b-", time_data, F2_load, "r-");
xlabel("Time since launch (s)");
ylabel("Thrust (lb)");
legend("F1 Thrust", "F2 Thrust");
title("Total Ploted Thrust Data over Time")

cropped_time_data = transpose(time_data((time_data > 1.80) & (time_data < 2.5)));
cropped_F1_data = F1_load((time_data > 1.80) & (time_data < 2.5));
cropped_F2_data = F2_load((time_data > 1.80) & (time_data < 2.5));

figure(6);
hold on;
plot( cropped_time_data, cropped_F1_data, "b-", cropped_time_data, cropped_F2_data, "r-");
xlabel("Time since launch (s)");
ylabel("Thrust (lb)");
legend("F1 Thrust", "F2 Thrust");
title("Cropped Ploted Thrust Data over Time")

combined_thrust = cropped_F1_data + cropped_F2_data;


figure(7);
hold on;
plot( cropped_time_data, combined_thrust, "k-");
xlabel("Time since launch (s)");
ylabel("Thrust (lb)");
legend("Total Thrust");
title("Cropped Ploted Thrust Data over Time");





function force = mvToForce(mv_data, poly)
    force = poly(1)*mv_data + poly(2);
end


