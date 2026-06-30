function wrote = writeintxt(mode, fd, filenm, sta, chan, P_cc, P_ts, S_cc, S_ts, theroshold)
%{
    This program is used to assemble the cross-correlation coefficient as well as 
    the shifttime for both P and S wave and record them into a txt file
%}
if mode == 0
    fid = fopen([fd,'\',filenm, '.txt'],'wt');
    fprintf(fid, '%s \t %s\t %s\t %s\t %s\t\n', 'Station&Channel', 'P_cc', 'P_ts', 'S_cc', 'S_ts');
elseif mode == 1
    fid = fopen([fd,'\',filenm, '.txt'],'a');
end
if (abs(P_ts) < 10 || abs(S_ts) < 10) && P_cc > theroshold
    fprintf(fid,'%s %s\t %.2f\t %.2f\t %.2f\t %.2f\t \n', sta, chan, P_cc, P_ts/100, S_cc, S_ts/100);
end
fclose(fid);
wrote = 1;