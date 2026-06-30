%Based on Wenzheng Gong 2022
function [resample_temsepc_signal,resample_egfsepc_signal,resample_stfspec,resample] = MTtaper_logspline(temsignal1,egfsignal1,delta,tbp,kspec)
df_log=0.002;  % para 5
temsignal = taper(temsignal1,0.05,0.9);
egfsignal = taper(egfsignal1,0.05,0.9);
[temfre,temsepc_signal] = mtspec(delta,temsignal,tbp,kspec); 
[egffre,egfsepc_signal] = mtspec(delta,egfsignal,tbp,kspec);
% [temnfre,temsepc_noise] = mtspec(temhd.delta,temnoise,8,15); 
% [egfnfre,egfsepc_noise] = mtspec(egfhd.delta,egfnoise,8,15);
temsepc_signal = sqrt(temsepc_signal*length(temsignal)/2);
egfsepc_signal = sqrt(egfsepc_signal*length(egfsignal)/2);
% temsepc_noise = sqrt(temsepc_noise*length(temnoise)/2);
% egfsepc_noise = sqrt(egfsepc_noise*length(egfnoise)/2);
temfre_log = log10(temfre(2:end));
egffre_log = log10(egffre(2:end)); 
%n inlog logspace space
% temnfre_log = log10(temnfre(2:end)); 
% egfnfre_log = log10(egfnfre(2:end)); 
temsepc_signal_log = log10(temsepc_signal(2:end));
egfsepc_signal_log = log10(egfsepc_signal(2:end)); 
% temsepc_noise_log = log10(temsepc_noise(2:end)); 
% egfsepc_noise_log = log10(egfsepc_noise(2:end));
resample_log = temfre_log(1):df_log:temfre_log(end);
resample_temsepc_signal_log = spline(temfre_log,temsepc_signal_log,resample_log);
resample_egfsepc_signal_log = spline(egffre_log,egfsepc_signal_log,resample_log);
% resample_temsepc_noise_log = spline(temnfre_log,temsepc_noise_log,resample_log);
% resample_egfsepc_noise_log = spline(egfnfre_log,egfsepc_noise_log,resample_log);
resample_temsepc_signal_log = smooth(resample_temsepc_signal_log,20,'moving');
resample_egfsepc_signal_log = smooth(resample_egfsepc_signal_log,20,'moving');
resample_temsepc_signal = 10.^resample_temsepc_signal_log;
resample_egfsepc_signal = 10.^resample_egfsepc_signal_log;
% resample_temsepc_noise = 10.^resample_temsepc_noise_log;
% resample_egfsepc_noise = 10.^resample_egfsepc_noise_log;
resample = 10.^resample_log;
resample_stfspec = resample_temsepc_signal./resample_egfsepc_signal;
return