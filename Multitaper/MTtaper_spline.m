%Based on Wenzheng Gong 2022
function [resample_temsepc_signal,resample_egfsepc_signal,resample_stfspec,resample_fre] = MTtaper(temsignal1,egfsignal1,delta,tbp,kspec)
df=0.01;
temsignal = taper(temsignal1,0.05,0.9);
egfsignal = taper(egfsignal1,0.05,0.9);
[temfre,temsepc_signal] = mtspec(delta,temsignal,tbp,kspec); 
[egffre,egfsepc_signal] = mtspec(delta,egfsignal,tbp,kspec);
temsepc_signal = sqrt(temsepc_signal*length(temsignal)/2);
egfsepc_signal = sqrt(egfsepc_signal*length(egfsignal)/2);
resample_fre = temfre(1):df:temfre(end);
resample_temsepc_signal = spline(temfre,temsepc_signal,resample_fre);
resample_egfsepc_signal = spline(egffre,egfsepc_signal,resample_fre);
resample_temsepc_signal = smooth(resample_temsepc_signal,10,'moving');
resample_egfsepc_signal = smooth(resample_egfsepc_signal,10,'moving');
resample_stfspec = resample_temsepc_signal./resample_egfsepc_signal;
return