% Energy estimation
function [ER,scaled_E] = Er_est(best_spec,Mw,fc,Vs,Vp,rho_h,freq)
[~, max_f_ind] = find(freq >= 10 * fc);
if isempty(max_f_ind)
    f_range = 1 : length(freq);
else
    f_range = 1 : max_f_ind(1);
end
spline_range = freq(1):0.005:10*fc;
inter_spec = spline(freq(f_range),best_spec(f_range),spline_range);
sumErho=0;
for j = 1:length(spline_range)   
%     Erho=((0.005*(spline_range(j)-1))^2)*(inter_spec(j)^2)*0.005;
    Erho=(0.005*((spline_range(j)))^2)*(inter_spec(j)^2)*0.005;
    sumErho=sumErho+Erho;
end
fac1=8*pi/(15*rho_h*1000*(Vs*1000)^5);
fac2=8*pi/(10*rho_h*1000*(Vp*1000)^5);
ER = (fac1+fac2)*sumErho;
scaled_E = ER/(10^(1.5*Mw+9.1));
