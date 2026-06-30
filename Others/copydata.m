function copydata(filefolders,tarno,egfno,rd)

tars = dir([filefolders(tarno).folder,'\',filefolders(tarno).name,'\*.SAC']);
egfs = dir([filefolders(egfno).folder,'\',filefolders(egfno).name,'\*.SAC']);
pre_tars = dir('..\data\target events\Rotated\*.SAC');
pre_egfs = dir('..\data\egf events\Rotated\*.SAC');
copyfile([filefolders(tarno).folder,'\',filefolders(tarno).name,'\*.SAC'],'..\data\target events\Raw\')
copyfile([filefolders(egfno).folder,'\',filefolders(egfno).name,'\*.SAC'],'..\data\egf events\Raw\')
disp(['Round ',num2str(rd),' : (tar No.',num2str(tarno),') is copied (raw)'])
pause(0.5)
disp(['Round ',num2str(rd),' : (egf No.',num2str(egfno),') is copied (raw)'])

% if height(pre_tars) ~= 0 && height(pre_egfs) ~=0
%     filenum = round(rand(1)*height(pre_tars));
%     [tar1,~]=load_sac([pre_tars(filenum).folder,'\',pre_tars(filenum).name]);
%     filenum = round(rand(1)*height(tars));
%     [tar2,~]=load_sac([tars(filenum).folder,'\',tars(filenum).name]);
%     filenum = round(rand(1)*height(pre_egfs));
%     [egf1,~]=load_sac([pre_egfs(filenum).folder,'\',pre_egfs(filenum).name]);
%     filenum = round(rand(1)*height(egfs));
%     [egf2,~]=load_sac([egfs(filenum).folder,'\',egfs(filenum).name]);
%     if strcmp( [num2str(tar1.nzyear),'-',num2str(tar1.nzjday),'-',num2str(tar1.nzhour),'-',num2str(tar1.nzmin),'-',num2str(tar1.nzsec)], ...
%                [num2str(tar2.nzyear),'-',num2str(tar2.nzjday),'-',num2str(tar2.nzhour),'-',num2str(tar2.nzmin),'-',num2str(tar2.nzsec)]) ~= 1
%         for tar = 1 : height(tars)
%             copyfile([tars(tar).folder,'\',tars(tar).name],['..\data\target events\Raw\',tars(tar).name])
%         end
%         disp(['Round ',num2str(rd),' : (tar No.',num2str(tarno),') is copied (raw)'])
%     else
%         disp(['Round ',num2str(rd),' : Rotated tar SAC files already exist'])
%     end
%     if strcmp( [num2str(egf1.nzyear),'-',num2str(egf1.nzjday),'-',num2str(egf1.nzhour),'-',num2str(egf1.nzmin),'-',num2str(egf1.nzsec)], ...
%                [num2str(egf2.nzyear),'-',num2str(egf2.nzjday),'-',num2str(egf2.nzhour),'-',num2str(egf2.nzmin),'-',num2str(egf2.nzsec)]) ~= 1
%         for egf = 1 : height(egfs)
%             copyfile([egfs(egf).folder,'\',egfs(egf).name],['..\data\egf events\Raw\',egfs(egf).name])
%         end
%         disp(['Round ',num2str(rd),' : (egf No.',num2str(egfno),') is copied (raw)'])
%     else
%         disp(['Round ',num2str(rd),' : Rotated egf SAC files already exist'])
%     end
%     return;
% elseif height(pre_tars) == 0 && height(pre_egfs) ~=0
%     for tar = 1 : height(tars)
%             copyfile([tars(tar).folder,'\',tars(tar).name],['..\data\target events\Raw\',tars(tar).name])
%     end
%     disp(['Round ',num2str(rd),' : (tar No.',num2str(tarno),') is copied (raw)'])
%     filenum = round(rand(1)*height(pre_egfs));
%     [egf1,~]=load_sac([pre_egfs(filenum).folder,'\',pre_egfs(filenum).name]);
%     filenum = round(rand(1)*height(egfs));
%     [egf2,~]=load_sac([egfs(filenum).folder,'\',egfs(filenum).name]);
%     if strcmp( [num2str(egf1.nzyear),'-',num2str(egf1.nzjday),'-',num2str(egf1.nzhour),'-',num2str(egf1.nzmin),'-',num2str(egf1.nzsec)], ...
%                [num2str(egf2.nzyear),'-',num2str(egf2.nzjday),'-',num2str(egf2.nzhour),'-',num2str(egf2.nzmin),'-',num2str(egf2.nzsec)]) ~= 2 
%         for egf = 1 : height(egfs)
%             copyfile([egfs(egf).folder,'\',egfs(egf).name],['..\data\egf events\Raw\',egfs(egf).name])
%         end
%         disp(['Round ',num2str(rd),' : (egf No.',num2str(egfno),') is copied (raw)'])
%     else
%         disp(['Round ',num2str(rd),' : Rotated egf SAC files already exist'])
%     end
%     return;
% elseif height(pre_tars) ~= 0 && height(pre_egfs) ==0
%     for egf = 1 : height(egfs)
%             copyfile([egfs(egf).folder,'\',egfs(egf).name],['..\data\egf events\Raw\',egfs(egf).name])
%     end
%     disp(['Round ',num2str(rd),' : (egf No.',num2str(egfno),') is copied (raw)'])
%     filenum = round(rand(1)*height(pre_tars));
%     [tar1,~]=load_sac([pre_tars(filenum).folder,'\',pre_tars(filenum).name]);
%     filenum = round(rand(1)*height(tars));
%     [tar2,~]=load_sac([tars(filenum).folder,'\',tars(filenum).name]);
%     if strcmp( [num2str(tar1.nzyear),'-',num2str(tar1.nzjday),'-',num2str(tar1.nzhour),'-',num2str(tar1.nzmin),'-',num2str(tar1.nzsec)], ...
%                [num2str(tar2.nzyear),'-',num2str(tar2.nzjday),'-',num2str(tar2.nzhour),'-',num2str(tar2.nzmin),'-',num2str(tar2.nzsec)]) ~= 1
%         for tar = 1 : height(tars)
%             copyfile([tars(tar).folder,'\',tars(tar).name],['..\data\target events\Raw\',tars(tar).name])
%         end
%         disp(['Round ',num2str(rd),' : (tar No.',num2str(tarno),') is copied (raw)'])
%     else
%         disp(['Round ',num2str(rd),' : Rotated tar SAC files already exist'])
%     end
% elseif height(pre_tars) == 0 && height(pre_egfs) ==0
%     for tar = 1 : height(tars)
%             copyfile([tars(tar).folder,'\',tars(tar).name],['..\data\target events\Raw\',tars(tar).name])
%     end
%     disp(['Round ',num2str(rd),' : (tar No.',num2str(tarno),') is copied (raw)'])
%     for egf = 1 : height(egfs)
%             copyfile([egfs(egf).folder,'\',egfs(egf).name],['..\data\egf events\Raw\',egfs(egf).name])
%     end
%     disp(['Round ',num2str(rd),' : (egf No.',num2str(egfno),') is copied (raw)'])
% end