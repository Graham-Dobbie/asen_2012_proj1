clc; 
close all; 
clear; 

%reading in data 
static_test = readmatrix('Static Test Stand Calibration Case 1.xlsx');


%convert mv to lbs 

weight = static_test(:,1);
F1 = static_test(:,4) - static_test(:,2);
F2 = static_test(:,5) - static_test(:,1);

Weight_T = static_test(:,1) .* ( F1 ./ ( F1 + F2) );
Weight_T2 = static_test(:,1) .* ( F2 ./ ( F1 + F2) ); 

figure(3)
tiledlayout(2,1)
nexttile
scatter(Weight_T ,F1)
hold on
legend('F1')

nexttile
scatter(Weight_T2,F2, 'Color', 'g')
legend('F2')

polyorder = 1;
[F1poly,S1] = polyfit(F1, Weight_T, polyorder);
[F2poly,S2] = polyfit(F2, Weight_T2, polyorder);


x = 0:max(F1)+10;
x2 = 0:max(F2)+20;
[weight_fit1, delta1] = polyval(F1poly, x, S1);
[weight_fit2, delta2] = polyval(F2poly,x2, S2);

sigma_y1 = sqrt(1/(length(x)-2) * sum((weight_fit1-Weight_T).^2));
sigma_y2 = sqrt(1/(length(x2)-2) * sum((weight_fit2-Weight_T2).^2));


figure(1)
scatter(Weight_T,F1)
hold on
plot(weight_fit1,x)
mean(F1)
%plot(weight_fit1+2.*sigma_y1,x)
%plot(weight_fit1-2.*sigma_y1,x)
ylabel("Volts (mV)")
xlabel("Weight (lbs)")

figure(2)
scatter(Weight_T2,F2)
hold on
plot(weight_fit2,x2)
mean(F2)

%plot(weight_fit2+2.*sigma_y2,x2)
%plot(weight_fit2-2.*sigma_y2,x2)
ylabel("Volts (mV)")
xlabel("Weight (lbs)")



% Use f offset for uncertainty for voltage 
% 
% Need to know how to propogate error through the whole problem


