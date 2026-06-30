function [sacout] = trim_sac_resample(sacin,varargin)
    resample_rate = 20;
    samplerate_ratio = resample_rate / (1/sacin(1,3));
    sacout(:,2)=resample(sacin(:,2),100,round(100*samplerate_ratio));
    len = 600/(1/resample_rate);
    sacout(1:len,1)=0.1*(1/resample_rate):(1/resample_rate):600;
    sacout(1:len,3)=sacin(1:len,3);
    sacout(len+1:end,:)=[];
    sacout(80,3)=len;
    sacout(1,3)=1/resample_rate;
return;