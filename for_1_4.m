%{
This program presents a deconvution procedure using multitaper/projected-Lander-Weber
methods between a target earthquake and an empirical Green's Function earthquake for 
resolving the STF of the former.

Author: Tao Mo
Affiliation: ESS SUSTech
Date: 2022.10.02
Contact: casertao1996@gmail.com

Seismic displacement waveform is composed of the information from: 
(1) source - hypocenter
(2) path effect - propogation
(3) instrumental response - reciever
in the form of convolution.

Hartzell (1978) put forward a method that a smaller aftershock can serve as an empirical 
Green's Function of a larger earthquakes with similar hypocenter locations and focal 
mechanisms. In other words, the source information of the large earthquake can be 
resolved by deconvolving the waveform data of the small earthquake from the larger one. 

u = STF * eGF
u   - Displacement waveform of large(target) earthquake
STF - Source time function of large(target) earthquake
eGF - Dsiplacement waveform of small(egf) earthquake

Note: 
1,  This program is coding under MATLAB R2022a version
2,  Basically and therorectically it is only possible to separate the P and S waves with a distance over 10° 
    However, this program is designed to extract the STF for events with magnitude of 1< M <3 whose SNR
    will be extremly low under a distance over 10°. Here still exists the problems.
3,  TBC......

Update information: 
{
[Version - Date - Adjustments])
1.0  -  2022.10.12  -   Auto-recognize the E/N/Z component pairs of the same station for rotation
1.1  -  2022.10.18  -   Add P & S option. Now the deconvolution can be applied in seperated 
                        P and S waves or whole waveform.
1.2  -  2022.10.25  -   Auto-save the plot figure
1.3  -  2022.11.05  -   Auto-search the minimum absolute value of STF which reduce energy loss when
                        conv STF with eGF
1.4  -  2022.11.11  -   Downsample the sacfile and trim to required length
2.0  -  2022.11.25  -   Now the program can due with batch files with a pre-generated egf pairs data
                        (or auto select egf pairs base on user defined criterion)
2.1  -  2022.11.30  -   Now the program can automatically adpat the two types of the byte-order of
                        sac files; No need to change the endian type now
2.2  -  2023.03.22  -   Figure resize and re-structure
2.3  -  2023.05.18  -   Auto-adjust the filter range by different magnitude
3.1  -  2023.09.11  -   Rewrite all module into functions and use parfor for parallel processing
%}

%%%%%%% Initialization %%%%%%%
clc;clear;close all;warning('off');format short;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Add path %%%%%%%%%%%
addpath(genpath('E:\Seismology\STF\src\'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Pre-assign parameters %%%
Pwavelen = 8;                       % P wave window length (s) [Make sure this window will not mix with S wave]
Swavelen = 16;                      % S wave window length (s)
Waveback = -2;                      % Move length (s) [positive-forward;negavite-back]
kspec = 7;                         % Number of spectrum window used in Multitaper method
tbp = (kspec+1)/2;                  % Time bandwidth product (duration times spectral width) generally = (kspec+1)/2
xorr_thershold = 0.6;               % The lower bound of cross correlation coefficient (quality control)
faces = [4 3 2 1];                  % Patch faces
%%%%%%%%% Wave mode %%%%%%%%%%
% Wavemode = 'P';
% Wavemode = 'S';
% Wavemode = 'W';
Wavemode = 'PS';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% Raw data subpath %%%%%%%
% data_subfolder = '\sacdata\inputhd_sac';
data_subfolder='';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Eventpath %%%%%%%%%%
eventlist = correct_list('E:\Seismology\2016 Kumanto\Kumamoto(new)\');
% [~,index] = sortrows({eventlist.name}.'); eventlist = eventlist(index(end:-1:1)); clear index; % downward order
% tarlist = correct_list('E:\Seismology\2021 Yangbi data\Target with manu onset');

resultfd = 'E:\Seismology\STF\Results\Kumanto\result in egf pairs(Mainshock)\';
% tar_resultfd = '..\Results\Yangbi\yangbi result in targets(new)\';
% fig_resultfd = '..\Results\Yangbi\yangbi figure(new)\';

mkdir(resultfd)
% mkdir(tar_resultfd)
% mkdir(fig_resultfd)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% EGF pairs excel %%%%%%%
% !!!!!!!!!!!!!!Notice!!!!!!!!!!!!!!
% make sure the event number in the EGFpairs sheet is the same as in the file list
EGFpairs = readtable('E:\Seismology\STF\supp info\Kumanto_new.xlsx','sheet','Mainshock');
eventsheet = readtable('E:\Seismology\STF\supp info\Kumanto_new.xlsx','sheet','Eventlist');
% [uniqueA, firstIdx, ~] = unique(EGFpairs(:,1), 'stable');
% EGFpairs = EGFpairs(firstIdx,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Wake up MP pool %%%%%%%
max_cores = maxNumCompThreads - 1; 
startMatlabPool(max_cores)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%% Main EGF %%%%%%%%%%%
startpoint = 605;
% endpoint = 4472;
% startpoint = startpoint - 1;
% endpoint = endpoint - 1;
figurevisible = 'off';
%% part 1 - Extracting STFs&spectra 
% for pair = 780 : height(EGFpairs)                                                                                           % loop for target event 
for pair = 1 : height(EGFpairs) 
    disp(pair)
    tarno = EGFpairs{pair,1};
    egfno = EGFpairs{pair,2};

%     tarfd = correct_list([eventlist(tarno).folder, '\', eventlist(tarno).name]);
%     if exist(['E:\Seismology\2021 Yangbi data\Target with manu onset\', num2str(tarno)],'dir') ~= 0 % for 2021Yangbi or any other events with picked targets
%         tarfd = correct_list(['E:\Seismology\2021 Yangbi data\Target with manu onset\', num2str(tarno)]); 
%     else 
%         continue;
%     end
    tarfd = correct_list([eventlist(tarno).folder, '\', eventlist(tarno).name]);
    egffd = correct_list([eventlist(egfno).folder, '\', eventlist(egfno).name]);
    
    pair_resultfd = [resultfd,'[',num2str(EGFpairs{pair,5}),'] ' ,num2str(tarno) ,' - ',num2str(egfno)];
    mkdir(pair_resultfd)
%     spmd
%         for tar = labindex : max_cores : height(tarfd)
        for tar = 1 : height(tarfd)
%             try 
                [tar_hd, tar_data] = load_sac([tarfd(tar).folder, '\', tarfd(tar).name]);
                if contains(tar_hd.kcmpnm, 'Z') == 0 && contains(tar_hd.kcmpnm, 'U') == 0
                    continue;
                end
                if exist([pair_resultfd, '\complete'],'dir') == 0
                    for egf = 1 : height(egffd)
                        [egf_hd, egf_data] = load_sac([egffd(egf).folder, '\', egffd(egf).name]);
                        if strcmp(tar_hd.kstnm, egf_hd.kstnm) == 1 && ...
                           strcmp(tar_hd.kcmpnm, egf_hd.kcmpnm) == 1
                           
                            [bpup,bpdown,est_STD] = bp_STD(tar_hd.mag);
                                if bpup >= (0.5/tar_hd.delta)
                                    bpup = (0.5/tar_hd.delta)-0.1;
                                end
                            bpdown = bpdown;
                            [tar_data, egf_data] = Pre_process(tar_data, egf_data, tar_hd.delta, bpdown, bpup);
                            
                            %%%%%% Below is for the circumstances that the record time is not the
                            %%%%%% event time(otherwise Time_cor = 0)
%                             tar_eventtime = strsplit(eventsheet.DateTime{tarno},'T');
%                             tar_eventtime = strsplit(tar_eventtime{2});
%                             Time_cor_tar = 
%                             egf_eventtime = strsplit(eventsheet.DateTime{egfno},'T');
%                             egf_eventtime = str2double(egf_eventtime{2}(5:end));
%                             if tar_eventtime > mod(tar_hd.user0,100)
%                                 Time_cor_tar = tar_eventtime - mod(tar_hd.user0,100);
%                             else
%                                 Time_cor_tar = tar_eventtime + 60 - mod(tar_hd.user0,100);
%                             end
% 
%                             if egf_eventtime > mod(egf_hd.user0,100)
%                                 Time_cor_egf = egf_eventtime - mod(egf_hd.user0,100);
%                             else
%                                 Time_cor_egf = egf_eventtime + 60 - mod(egf_hd.user0,100);
%                             end

                            Time_cor_tar = 0; Time_cor_egf = 0;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            % gain correction for theoretical onset (in case)
                            if tar_hd.t3 - tar_hd.b < 0
                                targc = 60;
                            else
                                targc = 0;
                            end
                            

                            if egf_hd.t3 - egf_hd.b < 0
                                egfgc = 60;
                            else
                                egfgc = 0;
                            end

%                             targc = 0; egfgc = 0;
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                            tarPlen = tar_hd.t3 + targc + Waveback - tar_hd.b + Time_cor_tar: tar_hd.delta : tar_hd.t3 + targc - tar_hd.b + Pwavelen + Time_cor_tar;
                            tarPwin = tar_data(round(tarPlen/tar_hd.delta));
                            egfPlen = egf_hd.t3 + egfgc - 10 - egf_hd.b + Time_cor_egf: egf_hd.delta : egf_hd.t3 + egfgc - egf_hd.b + Time_cor_egf + 20;
                            egfPwin = egf_data(round(egfPlen/tar_hd.delta));
        
                            % Preprocess for cross-correlation statement
                            CC_bpup = 327.6 * exp( -1.226 * egf_hd.mag ); % This relation is induced from fig.3 in page 60/418 of the book "Encyclopedia of earthquake engineering" (Beer et al., 2015)
                            if CC_bpup >= (0.5/tar_hd.delta)
                                CC_bpup = (0.5/tar_hd.delta) - 0.1;
                            end
                            [CC_tarPwin, CC_egfPwin] = Pre_process(tarPwin, egfPwin, tar_hd.delta, 0.5, CC_bpup);
                            max_coe = 0;
                            ts = 0;
                            for egf_point = 1 : length(CC_egfPwin) - length(CC_tarPwin)
                                temp_egfPwin = CC_egfPwin(egf_point:egf_point+length(CC_tarPwin)-1);
                                [cc, lags] = xcorr(CC_tarPwin,temp_egfPwin,0,'coeff');
                                    if max(cc) > max_coe
                                        max_coe = max(cc);
                                        ts = egf_point;
                                    end
                            end
                            if max_coe >= 0%xorr_thershold
                                egfPwin = egfPwin(ts:ts+length(tarPwin)-1);
            
%                                 [tarPwin, egfPwin] = Pre_process(tarPwin, egfPwin, tar_hd.delta, 0.1, bpup);
                                [tarspec, egfspec, STFspec, freq] = MTtaper_spline(  tarPwin, egfPwin, ...
                                                                                        tar_hd.delta, kspec, tbp);
%                                 STFspec = spline(freq,STFspec,bpdown:0.01:bpup);
%                                 freq = spline(freq,freq,bpdown:0.01:bpup);
%                                 save('..\supp info\yangbi_mainshock.mat','freq')
%                                 if ~exist('..\supp info\STF_fft.txt','file')
%                                     f_fid = fopen('..\supp info\STF_fft.txt','w+');
%                                     for f_point = 1 : length(f)
%                                         fprintf(f_fid,'%f  ',f(f_point));
%                                     end
%                                     fclose(f_fid);
%                                 end
%                                 disp([num2str(freq(1)), '-', num2str(freq(500)), '-', num2str(freq(end)), '-' ])
                                STF = mt_deconv(tar_hd.delta, tarPwin, egfPwin, tbp, kspec)/tar_hd.delta;
                                nfft = 2*length(STFspec);
                                F=abs(fft(STF,nfft));
                                f=((1/tar_hd.delta)/nfft)*(1:nfft/2);
                                f=f';
                                F=F(1:nfft/2); 
                                tmp_spec = smooth(F,20);
%                                 tmp_spec = spline(f,tmp_spec,bpdown-0.:0.01:bpup);

                                if ~exist('E:\Seismology\STF\supp info\Kumanto_STF_fft.txt','file')
                                    f_fid = fopen('E:\Seismology\STF\supp info\Kumanto_STF_fft.txt','w+');
                                    for f_point = 1 : length(f)
                                        fprintf(f_fid,'%f  ',f(f_point));
                                    end
                                    fclose(f_fid);
                                end
                                fitPwin = cconv(STF, egfPwin, length(STF))*tar_hd.delta;
                                fitPwin = fitPwin';
            
                                STF = circshift(STF,round(0.5*length(STF)));
%                                 STF(STF<0) = 0;
                                STF_fil = filtering(STF,tar_hd.delta,0.01,CC_bpup,2);
                                STF_fil(STF_fil<0) = 0;
                                
                                STF_cut = STF_fil;

%                                 STF_cut = STF(round(0.5*length(STF)-100):round(0.5*length(STF)+100));

                                redu_P = roundn((1-sum((tarPwin - fitPwin).^2)/sum(tarPwin.^2))*100,-2);
                                
                                % plot figure
                                fignm = [strtrim(tar_hd.kstnm),'.',strtrim(tar_hd.kcmpnm),'.png']; %strtrim(tar_hd.knetwk),'.',
                                figpath = [pair_resultfd, '\', fignm];
                                figure('Visible',figurevisible)
                                %%%%% target displacement %%%%%
                                subplot(3,4,1:2)
                                plot((1 : height(tar_data))*tar_hd.delta, tar_data)
                                hold on
                                max_tar = max(abs(tar_data(round(tarPlen/tar_hd.delta))));
                                min_tar = min(tar_data( round(tarPlen/tar_hd.delta)));
                                tarPver = [ tarPlen(1),min_tar;tarPlen(end),min_tar;...
                                           tarPlen(end),max_tar;tarPlen(1),max_tar];
%                                 tarPver = [ tar_hd.t3 + targc - tar_hd.b,min_tar;(tar_hd.t3 + targc - tar_hd.b + Pwavelen),min_tar;...
%                                            (tar_hd.t3 + targc - tar_hd.b + Pwavelen),max_tar;tar_hd.t3 + targc - tar_hd.b,max_tar];
                                patch('Faces',faces,'Vertices',tarPver,'FaceColor','red','FaceAlpha',.3,'EdgeColor','none');
                                hold off
%                                 title([strtrim(tar_hd.knetwk),'.',strtrim(tar_hd.kstnm),'.',strtrim(tar_hd.kcmpnm),'.target'])
                                title([strtrim(tar_hd.kstnm),'.',strtrim(tar_hd.kcmpnm),'.target  M = ',num2str(tar_hd.mag)])
                                set(gca,'FontSize',12)
                                xlabel('Time (s)')
                                ylabel('Amplitude')
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                                %%%%%% target cut window %%%%%%
                                % Time series
                                subplot(3,4,5)
                                plot((1:length(tarPwin))*tar_hd.delta,tarPwin)
                                title('target P waveform')
                                xlabel('Time (s)')
                                ylabel('Amplitude')
                                set(gca,'FontSize',12)
                                % Spectrum
                                subplot(3,4,6)
                                loglog(freq,tarspec)
                                xlim([freq(1) bpup])
                                title('target P spectrum')
                                xlabel('Frequency(Hz)')
                            %     xticks([0.02,0.05,0.1,0.2,0.5,1,2])
                            %     xticklabels({'0.02','0.05','0.1','0.2','0.5','1','2'})
                            %     ylabel('Amplitude')
                                set(gca,'FontSize',12)
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                %%%%%% egf displacement %%%%%%%
                                subplot(3,4,3:4)
                                plot((1:height(egf_data))*egf_hd.delta,egf_data)
                                max_egf = max(abs(egf_data(round(egfPlen/egf_hd.delta))));
                                min_egf = min(egf_data( round(egfPlen/egf_hd.delta)));
                                egfPver = [ egfPlen(1),min_egf;egfPlen(end),min_egf;...
                                           egfPlen(end),max_egf;egfPlen(1),max_egf];
%                                 egfPver = [ egf_hd.t3 + egfgc - egf_hd.b,min_egf;(egf_hd.t3 + egfgc - egf_hd.b + Pwavelen),min_egf;...
%                                            (egf_hd.t3 + egfgc - egf_hd.b + Pwavelen),max_egf;egf_hd.t3 + egfgc - egf_hd.b,max_egf];
                                hold on
                                patch('Faces',faces,'Vertices',egfPver,'FaceColor','red','FaceAlpha',.3,'EdgeColor','none');
                                hold off
%                                 title([strtrim(egf_hd.knetwk),'.',strtrim(egf_hd.kstnm),'.',strtrim(egf_hd.kcmpnm),'.egf'])
                                title([strtrim(egf_hd.kstnm),'.',strtrim(egf_hd.kcmpnm),'.egf'])
                                set(gca,'FontSize',12)
                                xlabel('Time (s)')
                                ylabel('Amplitude')
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                                %%%%%%% egf cut window %%%%%%%%
                                % Time series
                                subplot(3,4,7)
                                plot((1:length(egfPwin))*tar_hd.delta,egfPwin)
                                title('egf P waveform')
                                xlabel('Time (s)')
                                text(0.55*Pwavelen,1.3*max(egfPwin),['xcorr coeff = ',num2str(roundn(max_coe,-2))],'fontsize',10)
                                set(gca,'FontSize',12)
                                ylim([1.5*min(egfPwin) 1.5*max(egfPwin)])
                                % Spectrum
                                subplot(3,4,8)
                                loglog(freq,egfspec)
                                xlim([freq(1) bpup])
                                title('egf P spectrum')
                                xlabel('Frequency(Hz)')
                                set(gca,'FontSize',12)
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                                %%%%%%% STF & specturm %%%%%%%%
                                % STF
                                subplot(3,4,9)
                                patch_plot((1:length(STF_cut))*tar_hd.delta,STF_cut/max(STF_cut),0,'r','b','y','y');
                                box on
%                                 xlim([est_STD*tar_hd.delta est_STD*3*tar_hd.delta])
                                set(gca,'FontSize',12)
                                title('Source Time Function')
                                ylabel('Normalized Amplitude')
                                xlabel('Time (s)')
                                ylim([-0.5 1.5])
%                                 xlim([0.4 0.6])
                                % Spectrum
                                subplot(3,4,10)
%                                 loglog(0.01:0.01:freq(end),STFspec)
                                loglog(freq,STFspec)
                                xlim([0 bpup])
                                title('STF spectrum')
                                ylabel('Amplitude')
                                xlabel('Frequency (Hz)')
                                set(gca,'FontSize',12)
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                                %%%%%%%%% Predicted %%%%%%%%%%%
                                subplot(3,4,11:12)
                                plot((1:length(tarPwin))*tar_hd.delta,tarPwin,'r','LineWidth',2)
                                hold on
                                plot((1:length(fitPwin))*tar_hd.delta,fitPwin,':b','LineWidth',1.5)
                                hold off
                                legend('Observation','Predicted','FontSize',12)
                                xlabel('Time (s)')
                                title(['Predicted seismograms',' VR = ',num2str(redu_P),'%'])
                                set(gca,'FontSize',12)
                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                                %%%%%%%%% figure option %%%%%%%
                                set(gcf,"Units",'normalized','Position',[0.1 0.1 0.8 0.8])
                                saveas(gcf,figpath);
            
                                if redu_P > 60
            %                         disp([resultfd '\',strtrim(tar_hd.kstnm), ' - ', strtrim(tar_hd.kcmpnm),'_STF.txt'])
                                    % STF
                                    STF_fid = fopen([pair_resultfd '\', num2str(pair), '-',strtrim(tar_hd.kstnm), ...
                                                    ' - ', strtrim(tar_hd.kcmpnm),'_STF.txt'],'w+');
                                    for STF_point1 = 1 : length(STF_fil)
                                        fprintf(STF_fid,'%f  ',STF_fil(STF_point1));
                                    end
                                    fclose(STF_fid);
                                    %spec
                                    spec_fid = fopen([pair_resultfd '\', num2str(pair), '-',strtrim(tar_hd.kstnm), ...
                                                      ' - ', strtrim(tar_hd.kcmpnm),'_spec.txt'],'w+');
                                    for spec_point = 1 : length(STFspec)
                                        fprintf(spec_fid,'%f  ',STFspec(spec_point));
                                    end
                                    fclose(spec_fid);
                                    % P wave window
                                    P_exp = fopen([pair_resultfd '\', num2str(pair), '-',strtrim(tar_hd.kstnm), ...
                                                      ' - ', strtrim(tar_hd.kcmpnm),'_tarPwin.txt'],'w+');
                                    for Pwin_point = 1 : length(tarPwin)
                                        fprintf(P_exp,'%f  ', tarPwin(Pwin_point));
                                    end
                                    fclose(P_exp);
                                    % Fit wave window
                                    fit_exp = fopen([pair_resultfd '\', num2str(pair), '-',strtrim(tar_hd.kstnm), ...
                                                  ' - ', strtrim(tar_hd.kcmpnm),'_fitPwin.txt'],'w+');
                                    for fitwin_point = 1 : length(fitPwin)
                                        fprintf(fit_exp,'%f  ', fitPwin(fitwin_point));
                                    end
                                    fclose(fit_exp);
                                        
                                    %fft from STF
                                    tmp_spfc_fid = fopen([pair_resultfd '\', num2str(pair), '-',strtrim(tar_hd.kstnm), ...
                                                  ' - ', strtrim(tar_hd.kcmpnm),'_spectmp.txt'],'w+');
                                    for tmp_spec_point = 1 : length(tmp_spec)
                                        fprintf(tmp_spfc_fid,'%f  ', tmp_spec(tmp_spec_point));
                                    end
                                    fclose(tmp_spfc_fid);

                                end
                            end
                        else
                            continue;
                        end
                    end
                else
                    continue;
                end
%             catch
%                 mkdir([pair_resultfd, '\', num2str(pair), '-', strtrim(tar_hd.kstnm), ' - ', strtrim(tar_hd.kcmpnm) ,' - errorlog'])
%                 continue;
%             end
        end
%         mkdir([pair_resultfd, '\complete'])
%     end  %spmd
%     save('E:\Seismology\STF\supp info\Kumanto_invi_nospline.mat','freq')
end                                                                                                                        % end of target list loop
