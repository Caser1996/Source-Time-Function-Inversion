function[f]= posproj(g,T1,T,pat)

f=zeros(size(g));

if pat == 1
    for i=1:length(g)
	    if(i>=T1 && i<=T && g(i)>=0)
            f(i)=g(i);
        else
            f(i)=0;
	    end
    end
end

if pat == 0
    for i=1:length(g)
        f(i) = g(i);
    end
end

% remove one point spikes
% for i=2:length(f)-1
%     if f(i-1)==0 && f(i+1)==0
%         f(i)=0;
%     end
% end	

% test for abs
% for i=1:length(g)
% 	if(i>=T1 && i<=T && g(i)>=0)
%         f(i)=g(i);
%     elseif g(i)<0
%         f(i)=abs(g(i));
% 	end
% end
