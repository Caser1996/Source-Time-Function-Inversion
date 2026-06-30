%% part 2 - Merge same target STFs with manual selection & quality control (| GCARC | SNR | VR |)
tar_resultfd = 'E:\Seismology\STF\Results\Kumanto\result in targets(Mainshock)\';
% fig_resultfd = '..\Results\Kumanto\result in targets\';

mkdir(tar_resultfd)
% mkdir(fig_resultfd)

resultfd = 'E:\Seismology\STF\Results\Kumanto\result in egf pairs(Mainshock)\';
resultlist = correct_list(resultfd);

for resultnum = 1 : height(resultlist)
    tarnum = strsplit(resultlist(resultnum).name);
    try
        mkdir([tar_resultfd,tarnum{2}])
    catch
        disp('fd existed')
    end
    
%     copyfile([resultlist(resultnum).folder, '\', resultlist(resultnum).name,'\*.txt'],[resultfd,tarnum{1}]); % After modification this would work
    invi_STF = dir([resultlist(resultnum).folder, '\', resultlist(resultnum).name,'\*STF.txt']);
    invi_spec = dir([resultlist(resultnum).folder, '\', resultlist(resultnum).name,'\*spec.txt']);
    invi_fig = dir([resultlist(resultnum).folder, '\', resultlist(resultnum).name,'\*.png']);
    invi_tmpspec = dir([resultlist(resultnum).folder, '\', resultlist(resultnum).name,'\*spectmp.txt']);
    invi_tarP = dir([resultlist(resultnum).folder, '\', resultlist(resultnum).name,'\*tarPwin.txt']);
    invi_fitP = dir([resultlist(resultnum).folder, '\', resultlist(resultnum).name,'\*fitPwin.txt']);
    if height(invi_STF) ~= height(invi_spec)
        error('STF number incoporate with spec num')
    end
    for invi_num = 1 : height(invi_STF)
        if contains([  invi_STF(invi_num).folder, '\', invi_STF(invi_num).name],'ARV') == 0 || ...
            contains([  invi_STF(invi_num).folder, '\', invi_STF(invi_num).name],'VOG') == 0
            copyfile([  invi_STF(invi_num).folder, '\', invi_STF(invi_num).name],...
                     [  tar_resultfd, tarnum{2}, '\',invi_STF(invi_num).name])
            copyfile([  invi_spec(invi_num).folder, '\', invi_spec(invi_num).name],...
                     [  tar_resultfd, tarnum{2}, '\',invi_spec(invi_num).name])
            copyfile([  invi_tmpspec(invi_num).folder, '\', invi_tmpspec(invi_num).name],...
                     [  tar_resultfd, tarnum{2}, '\',invi_tmpspec(invi_num).name])
            copyfile([  invi_tarP(invi_num).folder, '\', invi_tarP(invi_num).name],...
                     [  tar_resultfd, tarnum{2}, '\',invi_tarP(invi_num).name])
            copyfile([  invi_fitP(invi_num).folder, '\', invi_fitP(invi_num).name],...
                     [  tar_resultfd, tarnum{2}, '\',invi_fitP(invi_num).name])

            nm_split = strsplit(invi_STF(invi_num).name,'-'); % check this in command board
            stanm = nm_split{2};
            channm = strsplit(nm_split{3},'_');
            channm = channm{1};
            fig2copy_nm = [stanm(1:end-1),'.',strtrim(channm),'.png']; % should verify base on file names
            copyfile([  invi_spec(invi_num).folder, '\', fig2copy_nm], [tar_resultfd, tarnum{2}, '\', ...
                        resultlist(resultnum).name, ' _ ', fig2copy_nm])
        else
            continue;
        end
    end
end
clear tarnum
