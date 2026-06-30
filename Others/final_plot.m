function final_plot(rd,resultfolder,spec,STF,best_spec,f_range,proc_file)
try
    medfignm = [resultfolder,'\median-',num2str(rd),'.png'];
    %%%%%%%%% Median spectra %%%%%%%%%%
    figure('Visible','off')
%     figure()
    subplot(1,3,1)
    % Individual
    for i = 1:height(spec)
        loglog(proc_file.freq,spec(i,:),'Color',[0.5,0.5,0.5],'LineWidth',3)
        hold on
    end
    % Median
    loglog(proc_file.freq,median(spec),'r','LineWidth',3)
    loglog(proc_file.freq(f_range),best_spec(f_range),'b:','LineWidth',3)
    xlim([proc_file.bpdown+1 proc_file.bpup+1])
    hold off
    xlabel('Frequency (Hz)')
    ylabel('Normalized Amplitude')
    set(gca,'FontSize',12)
    text(0.65,0.98,['L2norm = ',num2str(proc_file.L2norm)],'units','normalized','FontSize',12)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%% Median STF %%%%%%%%%%%%
%     STF = smoothdata(STF,'movmedian',20);
    subplot(1,3,2)
    % Individual
    for i = 1:height(STF)
%         STF(i,:) = smoothdata(STF(i,:),'movmedian',20);
        plot((1:width(STF))*proc_file.tar_hd.delta,STF(i,:)/max(STF(i,:)),'color',[0.5 0.5 0.5],'LineWidth',3)
        hold on
    end
    % Median
    median_STF = median(STF(:,:));
    stfLine = plot((1:length(median_STF))*proc_file.tar_hd.delta,median_STF(1:end)/max(median_STF),'LineWidth',3);
    hold on;
    % Set division points and colors
    DivY=[-inf,0,inf];
    ColorList=[0 0 255;255 0 0];

    % Construct color list, modify colors, and draw auxiliary lines
    YData=stfLine.YData;
    CData=repmat([0,0,0,255],[length(YData),1]);
    for i=1:height(ColorList)
        yline(DivY(i),'LineWidth',1,'LineStyle','--','Color',[0,0,0])
        tBool=(YData>=DivY(i))&(YData<=DivY(i+1));
        CData(tBool,1:3)=repmat(ColorList(i,:),[sum(tBool),1]);
    end
    pause(1e-10)
    set(stfLine.Edge,'ColorBinding','interpolated','ColorData',uint8(CData)')
    yline(0,':k','LineWidth',2)
    hold off
    [~,mid_xaxis] = max(median_STF);
%     xlim([proc_file.est_STD*proc_file.tar_hd.delta proc_file.est_STD*3*proc_file.tar_hd.delta])
    xlim([(mid_xaxis-50)*proc_file.tar_hd.delta (mid_xaxis+50)*proc_file.tar_hd.delta])
    ylim([-2 2])
    xlabel('Time (s)')
    ylabel('Normalized Ampilitude')
    set(gca,'FontSize',12)
    set(gca,'XTick',[])
    
    % filled STF
    subplot(1,3,3)
    patch_plot((1:length(median_STF))*proc_file.tar_hd.delta,median_STF/max(median_STF),0,'r','b','y','y');
    box on
%     xlim([proc_file.est_STD*proc_file.tar_hd.delta proc_file.est_STD*3*proc_file.tar_hd.delta])
    xlim([(mid_xaxis-50)*proc_file.tar_hd.delta (mid_xaxis+50)*proc_file.tar_hd.delta])
    ylim([-2 2])
    xlabel('Time (s)')
    set(gcf,"Units","normalized","Position",[0 0.1 1 0.8])
    set(gca,'FontSize',12)
    set(gca,'XTick',[])
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saveas(gcf,medfignm);
catch
    disp(['There is no STF output for round',num2str(rd)])
end

