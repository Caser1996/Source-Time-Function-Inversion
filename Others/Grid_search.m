function [best_spec,spec,L2norm_min,Mw,fc,Eta,Stress_drop] = Grid_search(spec,f_range,freq,k,Ml,pre_para)
%% grid search (Kaneko & Shearer, 2014; Boatwright, 1978; Brune, 1970)%%
Ml = roundn(Ml,-1);
if nargin == 5
    Mw_range = Ml-0.2 : 0.05 : Ml+0.2;
    fc_range = 0 : 0.1 : 10;
    Eta_range = 0.1 : 0.1 : 5;
elseif nargin == 6
    Mw_range = pre_para(2)-0.3 : 0.01 : pre_para(2)+0.3;
    fc_range = max(pre_para(3)-0.3,0.1) : 0.01 : pre_para(3)+0.3;
    Eta_range = max(pre_para(4)-0.3,0.1) : 0.01 : pre_para(4)+0.3;
end
V_S = 3.46;
L2norm_min = 10e100;
gsmode = 1;
%manu
% Mw_range = 3.42;% : 0.01 : 2.8;
% fc_range =  ;%; : 0.1 : 8;
% Eta_range = 1.66;% : 0.1 : 3;


%% pre-assign matrix
if gsmode == 1
    total_len = length(Mw_range)*length(fc_range)*length(Eta_range);
    Mw_list = zeros(total_len,1);
    fc_list = zeros(total_len,1);
    Eta_list = zeros(total_len,1);
    Error_matrix = ones(length(freq),total_len);
    Error_list = ones(1,total_len);
    theo_spec = zeros(length(freq),total_len);
    ind = 0;
    for Mw = Mw_range
        for fc = fc_range
            for Eta = Eta_range
                ind = ind + 1;
                Mw_list(ind) = Mw;
                fc_list(ind) = fc;
                Eta_list(ind) = Eta;
            end
        end
    end
    
    parfor i = f_range
        theo_spec(i,:)=(10.^(1.5.*Mw_list+9.1))./sqrt(1+(freq(i)./fc_list).^(2.*Eta_list));
        Error_matrix(i,:) = log10(theo_spec(i,:)/spec(i));
    end
%     Error_matrix = transpose(Error_matrix);
    Error_list = sqrt(sum(Error_matrix(f_range,:).^2./freq(f_range)')./length(f_range));
%     Error_list = sqrt(sum(Error_matrix.^2./freq)/length(f_range));
    [~,index] = min(Error_list);
    Mw = Mw_list(index);
    fc = fc_list(index);
    Eta = Eta_list(index);
    L2norm_min = Error_list(index);
    M0=10^(1.5*Mw+9.1);
end

%% stupid loop
% Grid search
if gsmode == 2
    theo_spec=zeros(1,width(spec));
    Error=zeros(1,width(spec));
    tmp_spec=zeros(1,width(spec));
    for Mw = Mw_range
        for fc = fc_range
            for Eta = Eta_range
                Sum_error=0;
                for i = f_range
    %                 Boatwright
                    theo_spec(i)=(10^(1.5*Mw+9.1))/sqrt(1+(freq(i)/fc)^(2*Eta));
                    Error(i)=log10(theo_spec(i)/spec(i));
    %                 Error(i)=theo_spec(i)-spec(i);
                    Sum_error=Sum_error+(Error(i).^2)/freq(i);
    %                 Brune   Eta=1
    %                 theo_spec(i)=(10^(1.5*Mw+9.1))/(1+(freq(i)/fc));  
                end
                L2norm=sqrt(Sum_error/length(f_range));
                if L2norm < L2norm_min
                        tmp_spec=theo_spec;
                        L2norm_min = L2norm;
                        Mw_min = Mw;
                        fc_min = fc;
                        Eta_min = Eta;
                end
            end
        end
    end
    
    % format shortE
    M0=10^(1.5*Mw_min+9.1);
    Mw=Mw_min;
    fc=fc_min;
    Eta=Eta_min;
end
%% best spectrum in whole freq range
% for i = 1 : length(f_range)
best_spec=(M0)./sqrt(1+(freq/fc).^(2*Eta));
% end

%% Stress drop %%
Rup_radius=k*V_S*1000/fc;
Stress_drop=(7/16)*(M0/Rup_radius^3);
