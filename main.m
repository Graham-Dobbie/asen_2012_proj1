clc; 
close all; 
clear; 

%reading in data 
static_test = readmatrix('Static Test Stand Calibration Case 1.xlsx');


%convert mv to lbs 

weight = static_test(:,1);
F1 = static_test(:,4);
F2 = static_test(:,5);

plot(F2,weight, 'Color', 'g')
hold on
plot(F1,weight)
legend('F2','F1')
hold off 

polyorder = 1;
[F1poly,S1] = polyfit(F1, weight, polyorder);
[F2poly,S2] = polyfit(F2, weight, polyorder);

x = 0:max(F1)+10;
x2 = 0:max(F2)+20;
[weight_fit1, delta1] = polyval(F1poly, x, S1);
[weight_fit2, delta2] = polyval(F2poly,x2, S2);


figure(1)
scatter(F1, weight)
hold on
plot(x,weight_fit1)

figure(2)
scatter(F2,weight )
hold on
plot(x2,weight_fit2)

hold off

%below here is test stuff 
sigma_y1 = sqrt(1/(length(x)-2) * sum((weight_fit1-weight).^2));
sigma_y2 = sqrt(1/(length(x2)-2) * sum((weight_fit2-weight).^2));
figure(3);
plot(x,weight_fit1+2.*sigma_y1)
hold on
plot(x2,weight_fit2+2.*sigma_y2)
figure(4)
hold on
plot(x,weight_fit1.*sigma_y1)
plot(x2,weight_fit2.*sigma_y2)





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




function force = mvToForce(mv_data, poly)
    force = poly(1)*mv_data + poly(2);
end


