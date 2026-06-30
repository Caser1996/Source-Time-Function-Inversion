%{
    This program is used to define the STF range in x-axis by searching the 
    closest 0-crossing points with the maximum STF point
%}

function [lp, rp] = def_STF_xlim(STF)
    in_set = curveintersect(1:length(STF),STF,1:length(STF),zeros(1,length(STF)));
    [~, ind1] = max(STF);
    if ind1 < max(in_set)
        absDiff = abs(ind1 - in_set);
        [~, ind2] = min(absDiff);
        if in_set(ind2) > ind1
            lp = in_set(ind2-1);
            rp = in_set(ind2);
        else
            lp = in_set(ind2);
            rp = in_set(ind2+1);
        end
    elseif ind1 < min(in_set)
        lp = 2*ind1 - min(in_set);
        rp = min(in_set);
    elseif ind1 > max(in_set)
        lp = max(in_set);
        rp = 2*ind1 - max(in_set);
    elseif isempty(in_set) == 1
        lp=[];
        rp=[];
    end
    lp=roundn(lp,0);
    rp=roundn(rp,0);
    return