%{ This function is used to eliminate the bias curve (from median/average)
function [list,index] = CutBiasNd(curve,ave_curve,sigma,range)
% if strcmp(mode,'time') == 0
%     perc = erf(sigma/sqrt(2));
%     [~,downfreq] = find(proc_file.freq > proc_file.bpdown);
%     downfreq = downfreq(1);
%     % upfreq = downfreq+round((width(curve)-downfreq)/2);
%     upfreq = width(curve);
%     curve = curve(:,downfreq:upfreq);
%     median_curve = median(curve);
%     varia = zeros(height(curve),width(curve));
%     for curve_num = 1 : height(curve)
%         varia(curve_num,:) = abs((curve(curve_num,:) - median_curve)./proc_file.freq(downfreq:upfreq).^2);
%     end
%     varia = sum(varia');
%     [~,index] = find(varia>(perc*max(varia)));
% else
    perc = erf(sigma/sqrt(2));
    curve = curve(:,range);
    
    mean_curve = ave_curve(:,range);
    for curve_num = 1 : height(curve)
        varia(curve_num,:) = abs((curve(curve_num,:) - mean_curve));
    end
    varia = sum(varia');
    [list,index] = find(varia < (perc*max(varia)));
% end

