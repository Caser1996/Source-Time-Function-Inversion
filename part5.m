
%% part 5 - Plot all STFs&spectra in one figure for each egf pairs and remove the distinct ones from average(median)
% map      fitted exp
%          fitted exp
% STF      fitted exp
%          fitted exp
% spec     fitted exp
%          fitted exp
clc;clear;close all;
%%%%%%%%% Add path %%%%%%%%%%%
addpath(genpath('E:\Seismology\STF\src\'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

eventsheet = readtable('E:\Seismology\STF\supp info\Kumanto from Hinet.xlsx','sheet','Eventlist');
Stasheet = readtable('E:\Seismology\STF\supp info\Kumanto from Hinet.xlsx','sheet','Station');

%for one in one
% resultfd= '..\Results\Yangbi\yangbi result in egf pairs(new)\';
pre_fig_rsfd = '';  % used to skip complete processing
pre_para_rsfd = 'E:\Seismology\STF\Results\Kumanto\figure in targets\'; % used to skip grid search
% outputfd = '../Results/Yangbi/yangbi figure in egf pairs(new)\';
% mkdir(outputfd)
%for all in one
resultfd = 'E:\Seismology\STF\Results\Kumanto\result in targets\';
outputfd = 'E:\Seismology\STF\Results\Kumanto\figure in targets\';
mkdir(outputfd)

rslist = correct_list(resultfd);
delta = 0.01;
load('E:\Seismology\STF\supp info\Kumanto_invi_nospline_nolog.mat');
% freq = spline(freq,freq,0.01:0.01:freq(end));
% freq = 0.01:0.01:5
STF_fftfreq = load('E:\Seismology\STF\supp info\Kumanto_STF_fft.txt');
source_para = zeros(height(rslist),7);
gs_mode = 3; % 2=detail 1=no 3=yes
spec_sel_mode = 1; % 1=redo 0=preset others=all
STF_sel_mode = 1; % 1=redo 0=preset others=all
figurevisible = 'on';
for tarnum = 1:height(rslist)
    if str2double(rslist(tarnum).name) ~= 153
        continue;
    end
%     disp(['Drawing figure for pair No.',rslist(tarnum).name '.'])
%     if ~exist([pre_fig_rsfd,rslist(tarnum).name,'.png'],'file')
%         disp('result eliminated')
%         continue;
%     end

    % filename = target number
    tarno = rslist(tarnum).name;

    % filename ~= target number
%     tarno = strsplit(rslist(tarnum).name,' ');
%     tarno = tarno{2};

    Ml = eventsheet.Mag(str2double(tarno));

    sg_spec_list = dir([rslist(tarnum).folder, '\', rslist(tarnum).name, '\*spec.txt']);
    sg_STF_list = dir([rslist(tarnum).folder, '\', rslist(tarnum).name, '\*STF.txt']);
    P_list = dir([rslist(tarnum).folder, '\', rslist(tarnum).name, '\*tarPwin.txt']);
    fit_list = dir([rslist(tarnum).folder, '\', rslist(tarnum).name, '\*fitPwin.txt']);
    tmpspec_list = dir([rslist(tarnum).folder, '\', rslist(tarnum).name, '\*spectmp.txt']);
    sg_STF = [];
    sg_spec = [];
    sg_P = [];
    sg_fit = [];
    STF_fftspec = [];
    sta_list = {};
    staloc_list = [];
%     if height(sg_spec_list) == 0 || height(sg_STF_list) == 0
%         continue;
%     end
    
%     if height(sg_STF_list) < 3
%         disp('no enough stations')
%         continue;
%     end
    
%     while height(sg_STF_list) - height(tmpspec_list) ~= 0
%         [~,index] = sortrows({sg_STF_list.date}.'); sg_STF_list = sg_STF_list(index(end:-1:1)); clear index
%         [~,index] = sortrows({sg_spec_list.date}.'); sg_spec_list = sg_spec_list(index(end:-1:1)); clear index
%         [~,index] = sortrows({P_list.date}.'); P_list = P_list(index(end:-1:1)); clear index
%         [~,index] = sortrows({fit_list.date}.'); fit_list = fit_list(index(end:-1:1)); clear index
%         delete([sg_STF_list(1).folder,'\',sg_STF_list(1).name])
%         delete([sg_spec_list(1).folder,'\',sg_spec_list(1).name])
%         delete([P_list(1).folder,'\',P_list(1).name])
%         delete([fit_list(1).folder,'\',fit_list(1).name])
%         sg_STF_list(1) = [];
%         sg_spec_list(1) = [];
%         P_list(1) = [];
%         fit_list(1) = [];
%         [~,index] = sortrows({sg_STF_list.name}.'); sg_STF_list = sg_STF_list(index); clear index
%         [~,index] = sortrows({sg_spec_list.name}.'); sg_spec_list = sg_spec_list(index); clear index
%         [~,index] = sortrows({P_list.name}.'); P_list = P_list(index); clear index
%         [~,index] = sortrows({fit_list.name}.'); fit_list = fit_list(index); clear index
%     end

    for sg_tarnum = 1 : height(sg_STF_list)
        tmpspec = load([sg_spec_list(sg_tarnum).folder, '\', sg_spec_list(sg_tarnum).name]);
        tmpSTF = load([sg_STF_list(sg_tarnum).folder, '\', sg_STF_list(sg_tarnum).name]);
        tmp_P = load([P_list(sg_tarnum).folder, '\', P_list(sg_tarnum).name]);
        tmp_fit = load([fit_list(sg_tarnum).folder, '\', fit_list(sg_tarnum).name]);
        tmp_fftspec = load([tmpspec_list(sg_tarnum).folder, '\', tmpspec_list(sg_tarnum).name]);
        [~, ind_STF] = max(tmpSTF);
        tmpSTF = circshift(tmpSTF,(-ind_STF)+(-roundn(length(tmpSTF)/2,0))); % match the max value point to a same index
        [~, ind] = max(size(tmpSTF));
        station_name = strsplit(P_list(sg_tarnum).name,'-');
        stanum = find(strcmp(Stasheet.Station,strtrim(station_name{2}))==1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% add this
%         if strcmp(station_name{2},'U')
%             station_name = station_name{1};
%         else
%             station_name = [station_name{1},'.',station_name{2}];
%         end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %for single pair
%         sta_list = [sta_list;strtrim(station_name{2})];
        %for multiple pair
%         if length([station_name{1},'-',strtrim(station_name{2})]) == 7
%             stationname = ['0',station_name{1},'-',strtrim(station_name{2})];
%         else
        stationname = [station_name{1},'-',strtrim(station_name{2})];
%         end
        sta_list = [sta_list;stationname];


        staloc_list =[staloc_list;Stasheet.Latitude(stanum),Stasheet.Longitude(stanum)];


        STFrange = 250 : 450; %1 : length(tmpSTF);
        ini_Hz = freq(2);
        spec_ini = find(freq>=ini_Hz);
        spec_ini = spec_ini(1);
        spec_endHz =  find(freq>=30);
        spec_end = spec_endHz(1);%length(tmpspec);
        if Ml < 2
            fit_spec_end = find(freq>=30);
        else
            fit_spec_end = find(freq>=7);
        end
        fit_spec_end = fit_spec_end(1);
        specrange = spec_ini : spec_end;%length(sg_spec(1,:));
        fit_specrange = spec_ini : fit_spec_end;
        STF_fftfreq_iniHz = find(STF_fftfreq>=ini_Hz);
        STF_fftfreq_iniHz = STF_fftfreq_iniHz(1);
        STF_fftfreq_40Hz = find(STF_fftfreq>=40);
        STF_fftfreq_40Hz = STF_fftfreq_40Hz(1);
        switch ind
            case 1
                sg_STF = [sg_STF, (tmpSTF/max(tmpSTF))];
                sg_P = [sg_P, tmp_P];
                sg_fit = [sg_fit, tmp_fit];
                nfft = 2*length(tmpspec);
                F=abs(fft(tmpSTF,nfft));
                f=((1/delta)/nfft)*(1:nfft/2);
                f=f';
                F=F(1:nfft/2); 
                STF_fftspec = [STF_fftspec,F];
            case 2
                sg_STF = [sg_STF; tmpSTF/max(tmpSTF)];
                sg_P = [sg_P; tmp_P];
                sg_fit = [sg_fit; tmp_fit];
                nfft = 2*length(tmpspec);
                F=abs(fft(tmpSTF,nfft));
                f=((1/delta)/nfft)*(1:nfft/2);
                f=f';
                F=F(1:nfft/2); 
                STF_fftspec = [STF_fftspec;F];
                
        end
        if (max(log10(tmpspec(specrange))) <= 3*log10(tmpspec(specrange(1))) || 1 == 2) ...
                && sum(tmpspec<0) == 0
            switch ind
            case 1
                sg_spec = [sg_spec,tmpspec];% (tmpspec/max(tmpspec))];
%                 STF_fftspec = [STF_fftspec,tmp_fftspec];
            case 2
                sg_spec = [sg_spec;tmpspec];% (tmpspec/max(tmpspec))];
%                 STF_fftspec = [STF_fftspec;tmp_fftspec];
            end
        end
%         if max(tmp_fftspec) <= 3*tmp_fftspec(1) || 1 == 2
%             switch ind
%             case 1
%                 STF_fftspec = [STF_fftspec,(tmp_fftspec/tmp_fftspec(1))];
%             case 2
%                 STF_fftspec = [STF_fftspec;(tmp_fftspec/tmp_fftspec(1))];
%             end
%         end
    end
    
%     if ismember(str2double(rslist(tarnum).name),manu_rm_num) == 1 
%         disp('skip')
%         continue;
%     end
    
    figure('visible',figurevisible)


    [~,index] = sort_nat(sta_list);
    sta_list = sta_list(index);
    sg_P = sg_P(index,:);
    sg_fit = sg_fit(index,:);
    clear index

    switch height(sg_STF)
        case 1
            ave_STF = sg_STF;
        case 0
            continue;
        otherwise
            ave_STF = median(sg_STF);
    end

    switch height(sg_spec)
        case 1
            ave_spec = sg_spec;
            
        case 0
            continue;
        otherwise
            for specnum = 1 : height(sg_spec)
                sg_spec(specnum, :) = smooth(sg_spec(specnum, :),20);
            end
            ave_spec = mean(sg_spec);
            
    end

    switch height(STF_fftspec)
        case 1
            ave_fft_spec = STF_fftspec;
        case 0 
            continue;
        otherwise
            for specnum = 1 : height(STF_fftspec)
                STF_fftspec(specnum, :) = smooth(STF_fftspec(specnum, :),20);
            end
            ave_fft_spec = geomean(STF_fftspec);
    end

    errorsigma = 1.2;
    [STF_suitable, STFindex] = CutBiasNd(sg_STF,ave_STF,errorsigma,STFrange);
    [spec_suitable, specindex] = CutBiasNd(sg_spec,ave_spec,errorsigma,specrange);
    [fftspec_suitable, fftspecindex] = CutBiasNd(STF_fftspec,ave_fft_spec,errorsigma,specrange);
    elim_num = max(height(sg_STF) - length(STF_suitable),height(sg_spec) - length(spec_suitable));
%     elim_num = 0;
    sg_STF = sg_STF(STFindex,:);
    sg_spec = sg_spec(specindex,:);
    STF_fftspec = STF_fftspec(fftspecindex,:);
%     new_sg_spec = [];
%     freq_x = [0.01:0.01:freq(specrange(1)),freq(specrange)];
%     for specnum = 1 : height(sg_spec)
%         new_sg_spec=[new_sg_spec;ones(1,length(0.01:0.01:freq(specrange(1)))),sg_spec(specnum,specrange)];
%     end

    switch height(sg_STF)
        case 1
            ave_STF = sg_STF;
        case 0
            continue;
        otherwise
            ave_STF = median(sg_STF);
    end

    switch height(sg_spec)
        case 1
            ave_spec = sg_spec;
        case 0
            continue;
        otherwise
            ave_spec = mean(sg_spec);
    end

%     switch height(new_sg_spec)
%         case 1
%             ave_spec = new_sg_spec;
%         case 0
%             continue;
%         otherwise
%             ave_spec = mean(new_sg_spec);
%     end

    switch height(STF_fftspec)
        case 1
            ave_fft_spec = STF_fftspec;
        case 0
            continue;
        otherwise
            ave_fft_spec = median(STF_fftspec);
    end
    
    re_STF = mean(sg_STF);
    ave_spec = smooth(ave_spec,40);
    ave_fft_spec = smooth(ave_fft_spec,40);

    if exist([pre_para_rsfd, rslist(tarnum).name, ' bestspec.mat'],'file') && 1==gs_mode
        load([pre_para_rsfd, rslist(tarnum).name, ' bestspec.mat']);
        load([pre_para_rsfd, rslist(tarnum).name, ' source_para.mat']);
        Mw = invi_source_para(2);
        fc = invi_source_para(3);
        Eta = invi_source_para(4);
        Stress_drop = invi_source_para(5);
        L2norm = invi_source_para(6);
        % gain correction
        Ml_0=10^(1.5*Ml+9.1);
        ave_spec = Ml_0*ave_spec/ave_spec(1);
        M0 = 10^(1.5*Mw+9.1);
    elseif exist([pre_para_rsfd, rslist(tarnum).name, ' bestspec.mat'],'file') && 2==gs_mode
        % gain correction
        Ml_0=10^(1.5*Ml+9.1);
        ave_spec = Ml_0*ave_spec/ave_spec(1);
        load([pre_para_rsfd, rslist(tarnum).name, ' source_para.mat']);
        [best_spec, ave_spec, L2norm, Mw, fc, Eta, Stress_drop] = Grid_search(ave_spec,fit_specrange,freq,0.32,Ml,invi_source_para);
        M0 = 10^(1.5*Mw+9.1);
    elseif 3==gs_mode
        % gain correction
        Ml_0=10^(1.5*Ml+9.1);
        ave_spec = Ml_0*ave_spec/ave_spec(1);
        [best_spec, ave_spec, L2norm, Mw, fc, Eta, Stress_drop] = Grid_search(ave_spec,fit_specrange,freq,0.32,Ml);
        M0 = 10^(1.5*Mw+9.1);
    else
        error('Wrong grid search mode')
    end

     % spectra single&average
%     subplot(3,5,11:12)
    subplot(2,4,5)
    hold on
    for specnum = 1 : height(sg_spec)
        if specnum == 1
            loglog(freq(specrange),sg_spec(specnum,specrange)/sg_spec(specnum,specrange(1)),'color',[0.5 0.5 0.5],'Linewidth',0.6,'HandleVisibility','on')
        else
            loglog(freq(specrange),sg_spec(specnum,specrange)/sg_spec(specnum,specrange(1)),'color',[0.5 0.5 0.5],'Linewidth',0.6,'HandleVisibility','off')
        end
    end
    loglog(freq(specrange),ave_spec(specrange)/ave_spec(specrange(1)),'r:','Linewidth',2)
%     xlim([freq(specrange(1)),freq(specrange(end))])
    xlim([freq(spec_ini),freq(spec_end)]) % 
    ylabel('Normalized Amplitude')
    
    try
        [Er, ~] = Er_est(best_spec,Mw,fc,3.46,5.8,2.449,freq(specrange));
    catch
        Er = -12345;
    end
    source_para(tarnum,:) = [str2double(tarno), Mw, fc, Eta, Stress_drop,L2norm,Er];
    invi_source_para = [str2double(tarno), Mw, fc, Eta, Stress_drop,L2norm,Er];
%     loglog(freq,best_spec/best_spec(specrange(1)),'b','lineWidth',2)%/ave_spec(specrange(1))
    loglog(freq,best_spec/ave_spec(specrange(1)),'b','lineWidth',2)%
%     fft_spec = abs(fft(ave_STF,2*length(ave_spec)));
%     fft_spec = smooth(fft_spec,20);
%     colororder({'k','k'})
%     yyaxis right
%     loglog(freq(specrange),fft_spec(specrange)/fft_spec(specrange(1)),'g-','LineWidth',2)
% %     loglog(freq(specrange),ave_fft_spec(specrange)/ave_fft_spec(specrange(1)),'k-','LineWidth',2)
% 
%     set(gca,'Fontsize',10,'ytick',[],'yticklabel',[],'Yscale','log','Xscale','log')
%     ylim([0 1.4])
%     yyaxis left

    lgd = legend('Invi Spec','Ave Spec','Fit Spec','STF-base FFT','location','southwest');
    SD_disp = num2str(roundn(Stress_drop/1e6,-2));
    ax = gca;
    axPos = ax.Position;
    rect = [axPos(1) + axPos(3) - 0.21, axPos(2) + axPos(4) - 0.1, 0.2, 0.1];
    annotation('textbox',rect , 'String',[ ' Mw=',num2str(Mw), ' fc=',num2str(fc),' n=',num2str(Eta),newline,...
               'Δσ=',SD_disp, 'MPa',' L2=',num2str(roundn(L2norm,-2))],...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'top','EdgeColor','none')
%     title(lgd,[ ' Mw=',num2str(Mw), ' fc=',num2str(fc), ' n=',num2str(Eta),newline,...
%                 'Δσ=',SD_disp, 'MPa',' L2=',num2str(roundn(L2norm,-2))])%%%How to show e** format
%     M0_disp = floor(log10(abs(M0))) + 1;
%     if M0_disp>=10
%         sed_y_str = ['^',num2str(floor(mod(M0_disp,100)/10)),'^',num2str(mod(M0_disp,10))];
%         fir_y_str = ['^',num2str(floor(mod(M0_disp-1,100)/10)),'^',num2str(mod(M0_disp-1,10))];
%     else
%         sed_y_str = ['^',num2str(mod(M0_disp,10))];
%         fir_y_str = ['^',num2str(mod(M0_disp-1,10))];
%     end
%     set(gca,'Fontsize',10,'Ytick',[0.1 1]*(10^M0_disp),'Yticklabel',{['10',fir_y_str],['10',sed_y_str]},'Xscale','log','Yscale','log')
%     ylim([0.09 2]*10^M0_disp)
    set(gca,'Fontsize',10,'Ytick',[0.1 1],'Yticklabel',{'10^-^1','10^0'},'Xscale','log','Yscale','log')
    ylim([0.09 2])

    ylabel('Normalized Amplitude')
    hold off
    box on

    % STF single&average
%     subplot(3,5,6:7)
    subplot(2,4,2)
    hold on
    for STFnum = 1 : height(sg_STF)
        if STFnum == 1
            plot((1:width(STFrange))*delta,sg_STF(STFnum,STFrange)./max(sg_STF(STFnum,STFrange)),'color',[0.5 0.5 0.5],'Linewidth',0.6,'HandleVisibility','on')
        else
            plot((1:width(STFrange))*delta,sg_STF(STFnum,STFrange)./max(sg_STF(STFnum,STFrange)),'color',[0.5 0.5 0.5],'Linewidth',0.6,'HandleVisibility','off')
        end
    end
%     plot(1:width(sg_tar),mean(sg_tar./max(mean(sg_tar))),'r:','Linewidth',2)
    sm_ave_STF = ave_STF(STFrange)/abs(max(max(ave_STF(STFrange))));
    
%     smooth(ave_STF(STFrange)/abs(max(max(ave_STF(STFrange)))));

%     plot((1:width(STFrange))*delta,sm_ave_STF,'r','Linewidth',3)
    ylim([-0.5 2])
    xlim([delta width(STFrange)*delta])
%     ylabel('Normalized Amplitude')
%     xlim([1 rp-lp+20]*delta)
    box on
    
    set(gca,'Fontsize',10,'ytick',[],'yticklabel',[])
%     set(gca,'Fontsize',10,'xtick',[],'xticklabel',[])
    ylabel('Normalized Amplitude')
    legend('Invi Station STF','Average STF','location','northeast')

    % fit&P window panel
%     subplot(3,5,[3,4,5,8,9,10,13,14,15])
    subplot(2,4,[3,4,7,8])
    hold on
    VR_list=[];
    for win_num = 1 : height(sg_P)
        redu_P = roundn((1-sum((sg_P(win_num,:) - sg_fit(win_num,:)).^2)/sum(sg_P(win_num,:).^2))*100,-2);
        VR_list = [VR_list;win_num,redu_P];
    end
    [~,VR_index] = sort(VR_list(:,2));
    VR_list=VR_list(VR_index,:);
    elim_list = VR_list(1:elim_num,1);

    for win_num = 1 : height(sg_P)
        if ismember(win_num,elim_list)
            plot(1:width(sg_P),sg_P(win_num,:)/max(sg_P(win_num,:))+(2*(win_num-1)),'color',[0.588, 0.588, 0.588],'LineStyle','-','LineWidth',2)
            plot(1:width(sg_fit),sg_fit(win_num,:)/max(sg_fit(win_num,:))+(2*(win_num-1)),'color',[0.392, 0.392, 0.392],'LineStyle',':','LineWidth',2)
        else
            plot(1:width(sg_P),sg_P(win_num,:)/max(sg_P(win_num,:))+(2*(win_num-1)),'color','r','LineStyle','-','LineWidth',2)
            plot(1:width(sg_fit),sg_fit(win_num,:)/max(sg_fit(win_num,:))+(2*(win_num-1)),'color','b','LineStyle',':','LineWidth',2)
        end
    end

    ylim([-1 1+2*height(sg_P)])
    xlim([1 width(sg_P)])
    box on
    set(gca,'Fontsize',10,'xtick',[],'xticklabel',[])
    set(gca,'Fontsize',10,'ytick',0:2:2*(height(sg_P)-1),'yticklabel',sta_list)
    legend('Target P-wave data','Fitted data','location','northeast')

    % fft base on STF

    subplot(2,4,6)
    hold on
    % fft from origianl STF
%     for tmp_spec_num = 1 : height(STF_fftspec)
%         if tmp_spec_num == 1
%             plot_fftspec = smooth(STF_fftspec(tmp_spec_num,STF_fftfreq_iniHz:STF_fftfreq_40Hz),40);
%             plot_fftspec = plot_fftspec';
%             loglog(STF_fftfreq(STF_fftfreq_iniHz:STF_fftfreq_40Hz),STF_fftspec(tmp_spec_num,STF_fftfreq_iniHz:STF_fftfreq_40Hz)/STF_fftspec(tmp_spec_num,STF_fftfreq_iniHz),...
%                 'color',[0.5 0.5 0.5],'HandleVisibility','on')
%         else
%             plot_fftspec = smooth(STF_fftspec(tmp_spec_num,STF_fftfreq_iniHz:STF_fftfreq_40Hz),40);
%             plot_fftspec = plot_fftspec';
%             loglog(STF_fftfreq(STF_fftfreq_iniHz:STF_fftfreq_40Hz),STF_fftspec(tmp_spec_num,STF_fftfreq_iniHz:STF_fftfreq_40Hz)/STF_fftspec(tmp_spec_num,STF_fftfreq_iniHz),...
%                 'color',[0.5 0.5 0.5],'HandleVisibility','off')
%         end
%     end
%     loglog(STF_fftfreq(STF_fftfreq_iniHz:STF_fftfreq_40Hz),ave_fft_spec(STF_fftfreq_iniHz:STF_fftfreq_40Hz)/max(ave_fft_spec(STF_fftfreq_iniHz)),'color','g','linewidth',2)
% %     ylim([0 max(ave_spec(specrange))/ave_spec(specrange(1))+0.1])
% %     xlim([STF_fftfreq(STF_fftfreq_1Hz),STF_fftfreq(specrange(end))])
%     xlim([STF_fftfreq(STF_fftfreq_iniHz),freq(spec_end)]) 

    % fft from origianl STF
    for tmp_spec_num = 1 : height(STF_fftspec)
        if tmp_spec_num == 1
            loglog(f(specrange),STF_fftspec(tmp_spec_num,specrange)/STF_fftspec(tmp_spec_num,specrange(1)),...
                'color',[0.5 0.5 0.5],'HandleVisibility','on')
        else
            loglog(f(specrange),STF_fftspec(tmp_spec_num,specrange)/STF_fftspec(tmp_spec_num,specrange(1)),...
                'color',[0.5 0.5 0.5],'HandleVisibility','off')
        end
    end
    loglog(f(specrange),ave_fft_spec(specrange)/ave_fft_spec(specrange(1)),'color','g','linewidth',2)
    
    nfft = 2*length( ave_fft_spec);
    F=abs(fft(re_STF,nfft));
    f=((1/delta)/nfft)*(1:nfft/2);
    f=f';
    F=F(1:nfft/2);
%     loglog(f(specrange),F(specrange)/F(specrange(1)),'color','g','linewidth',2)
    xlim([f(specrange(1)),freq(spec_end)]) 

    ylabel('Normalized Amplitude')
%     set(gca,'Fontsize',10,'ytick',[0.1,1]*10^M0_disp,'yticklabel',{['10',fir_y_str],['10',sed_y_str]},'Yscale','log','Xscale','log')
%     ylim([0.09,2]*10^M0_disp)
    set(gca,'Fontsize',10,'Ytick',[0.1 1],'Yticklabel',{'10^-^1','10^0'},'Xscale','log','Yscale','log')
    ylim([0.09 2])
    legend('Invi Spec','Ave Spec','location','southwest')
    hold off
    box on

    % STF from spec
    subplot(2,4,2)
    plot((1:width(STFrange))*delta,re_STF(STFrange),'r','Linewidth',3)
    hold off

    % map panel
%     subplot(3,5,1:2)
    subplot(2,4,1)
    for stanum = 1 : height(staloc_list)
        if stanum == 1
            geoplot(staloc_list(stanum,1),staloc_list(stanum,2),'color','b','Marker','^','MarkerSize',8,'HandleVisibility','on')
            hold on
        else
            geoplot(staloc_list(stanum,1),staloc_list(stanum,2),'color','b','Marker','^','MarkerSize',8,'HandleVisibility','off')
        end
    end
    geoplot(eventsheet.Latitude(str2double(tarno)),eventsheet.Longitude(str2double(tarno)),'color','r','Marker','pentagram','MarkerSize',20,'MarkerFaceColor','r')
    geolimits([32 34],[130,132])
    geobasemap streets
    legend('Station','Hypocenter')

    set(gcf,"Units",'normalized','Position',[-0.8,0.1,0.8,0.8])
    saveas(gcf, [outputfd, '\', rslist(tarnum).name, '.png']);
    save([outputfd, rslist(tarnum).name, ' STF.mat'],'ave_STF','-mat')
    save([outputfd, rslist(tarnum).name, ' spec.mat'],'ave_spec','-mat')
    save([outputfd, rslist(tarnum).name, ' bestspec.mat'],'best_spec','-mat')
    save([outputfd, rslist(tarnum).name, ' source_para.mat'],'invi_source_para','-mat')
%     clear ave_STF
%     clear ave_spec
%     clear best_spec
%     clear invi_source_para
    clear gca
end