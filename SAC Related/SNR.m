% calculate Signal 2 Noise ratio
function [snr] = SNR(delta,data,onset)
Signal=0;
Noise=0;
for move = 0 :delta: 5
%     disp(round(((onset)+move)/hd.delta))
    Signal=Signal+data(round(((onset)+move)/delta))^2;
    Noise=Noise+data(round(((onset)-move)/delta))^2;
end
snr=sqrt(Signal/Noise);
% disp(['SNR = ',num2str(snr)])
return
