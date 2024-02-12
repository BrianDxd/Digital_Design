clc; close all

b = 1;
a = [1 0.9821];
freqz(b,a); %frequency response

n = linspace(-pi,pi,100);
rng default  %initialize random number generator;

impulse = [1, zeros(1,length(n)-1)]; %create impulse
len_impulse = length(impulse);
impulse_fxp = fi(impulse,1,1+7,7);
%matlab floating point precision

coeff = -0.9821; %have a floating and fixed point model
y0 = zeros(1,len_impulse);
y1 = 0;
coeff_fxp = fi(coeff,1,1+7,7);
y0_fxp = fi(y0,1,1+7,7);
y1_fxp = fi(y1,1,1+7,7);

for i=1:len_impulse
    y0(i) = (coeff * y1) + impulse(i);
    y1 = y0(i);

    y0_fxp(i) = (coeff_fxp * y1_fxp) + impulse_fxp(i);
    y1_fxp = y0_fxp(i);
end

figure
hold on
stem(0:1:len_impulse-1, impulse);
stem(0:1:len_impulse-1, y0);
stem(0:1:len_impulse-1, y0_fxp);
hold off

legend('original signal','filtered floating point','filtered fixed point')

fileID = fopen('impulseResponse.txt','w'); %print out values for comparison to RTL outputs
for k = 1:length(y0_fxp)
    fprintf(fileID, '%s\n', hex(y0_fxp(k)));
end
fclose(fileID);