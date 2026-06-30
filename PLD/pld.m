function[ASTF,dhat,T,eps,t,e]= pld(data,GF,T1,niter,threshold,pat)
% DOES THE PLD inversion process for the ASTF from a data seismogram
% and a GF seismogram.   The P-wave seismograms are expected to be 
% alligned so that the P-wave arrival time occurs in the sample
% T1, and the GF begins at the P-wave arrival time.
% Also, it is assumed that they have been padded with zeros to
% a sufficient length of time to avoid wrap-arounds. (i.e. more than
% double).  T-T1 is the estimate of the duration of the STF
% you pick from the misfit tradeoff curve.
% niter is the number of iterations (ie inverse damping)
% t,e is the tradeoff curve
% threshold is the acceptable misfit. i.e. 0.3

N=length(data);
e0=(T1)/N;
epsilon=e0:.005:0.4;

ne=length(epsilon);
e=zeros(ne,1);
t=zeros(ne,1);

foldt=zeros(N,1);
fnewt=zeros(N,1);
fneww=fft(fnewt);
GT=zeros(N,1);
dataw=fft(data);
GFw=fft(GF);
Gstarw=conj(GFw);
tau=max(abs(GFw));
tau=tau^2;
tau=1/tau;

for i=1:N
 GT(i)=GF(N-i+1);
end;
GTw=fft(GT);

nit=niter;
% LOOP OVER EPSILONS

for i=1:ne

   eps=epsilon(i);
   T=round(eps*N);
   t(i)=T;

   %set up inverse problem	


   % iterate over n
   for j=1:nit
     foldt=fnewt;
     foldw=fneww;
     clear dum
     f=fft(foldt);
     res=dataw-GFw.*f;
     dum=Gstarw.*res;
     gneww=foldw+tau.*dum;
     gnewt=real(ifft(gneww));
     fnewt=posproj(gnewt,T1,T,pat);
     fneww=fft(fnewt);
   end
   % end iterations for this T.

       dhat=real(ifft(fneww.*GFw));

   sum1=0; sum2=0;
   for j=1:N
    sum1=sum1+(data(j)-dhat(j))^2;
    sum2=sum2+(data(j))^2;
   end
   e(i)=sum1/sum2;
end

e_diff=diff(e);
e_diff(end+1)=e_diff(end);
% plot eps vs T

%% automatic pick of tradeoff parameter
% figure
% subplot(2,1,1)
% plot(t,e)
% ylabel('Epsilon')
% xlabel('T')
% xlim([t(1) t(end)])
%         disp('Pick T') %% hand pick start
%         [x y] = ginput(1);
%         T=round(x);
%         display(T);    %% hand pick end
[pks,locs] = findpeaks(e_diff,t);
for i=1:length(locs)
    j=find(t==locs(i));
%    if e(j)<=threshold && ( abs(pks(i))<=-0.01*min(pks) || pks(i+1)<=pks(i))
    if e(j)<=threshold && abs(pks(i))<=0.001
        T=locs(i);
        break;
    end
end

% if e(j)> threshold %%pick failed
%     T=0;ASTF=0;dhat=0;eps=0;t=0;
%     display('############### Warning ################')
%     display('# PLD cannot find trade-off parameter! #')
%     display('#              T is set to 0!          #')
%     display('# All output parameters are set to 0!  #')
%     display('############### Warning ################')
%     return;
% end
% hold on;
% plot(t(j),e(j),'ro');
% subplot(2,1,2)
% plot(t,e_diff)
% hold on;
% plot(t(j),e_diff(j),'ro');
% ylabel('Diff epsilon')
% xlabel('T')
% xlim([t(1) t(end)])

% iterate over n
foldt=zeros(N,1);
fnewt=zeros(N,1);
fneww=fft(fnewt);
for j=1:nit
     foldt=fnewt;
     foldw=fneww;
     clear dum
     f=fft(foldt);
     res=dataw-GFw.*f;
     dum=Gstarw.*res;
     gneww=foldw+tau.*dum;
     gnewt=real(ifft(gneww));
     fnewt=posproj(gnewt,T1,T,pat);
     fneww=fft(fnewt);
 end

dhat=real(ifft(fneww.*GFw));
ASTF=fnewt;
sum1=0; sum2=0;
for j=1:N
    sum1=sum1+(data(j)-dhat(j))^2;
    sum2=sum2+(data(j))^2;
end
eps=sum1/sum2;
%close
