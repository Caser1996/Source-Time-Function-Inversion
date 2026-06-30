% Filter and Removed trend & mean value 
% Mostly post few effects on results but occasionally it works
function [tarwin,egfwin]=Pre_process(tarwin,egfwin,delta,varargin)

if length(varargin) == 2
    bpdown = varargin{1};
    bpup   = varargin{2};
else
    bpdown = 0.01;
    bpup   = 2;
end

tarwin = detrend(tarwin);
tarwin = tarwin - mean(tarwin); 
tarwin = detrend(tarwin);
tarwin = taper(tarwin,0.05,0.9);

egfwin = detrend(egfwin);
egfwin = egfwin - mean(egfwin); 
egfwin = detrend(egfwin);
egfwin = taper(egfwin,0.05,0.9);


tarwin = filtering(tarwin,delta,bpdown,bpup,2);
egfwin = filtering(egfwin,delta,bpdown,bpup,2);

tarwin = detrend(tarwin);
tarwin = tarwin - mean(tarwin); 
tarwin = detrend(tarwin);
tarwin = taper(tarwin,0.05,0.9);
% 
egfwin = detrend(egfwin);
egfwin = egfwin - mean(egfwin); 
egfwin = detrend(egfwin);
egfwin = taper(egfwin,0.05,0.9);

return;