% function [tfun,stfpf,stf_spe] = mt_deconv(dt,x,y,tbp,kspec)
function [tfun] = mt_deconv(dt,x,y,tbp,kspec)

% 
% Multitaper deconvolution
%

nfft = length(x);

% Get DPSS

[vn,lambda] = dpss(nfft,tbp,kspec);
% Demean

% x = x - mean(x);
% y = y - mean(y);


for i = 1:kspec

%    junk1 = [x.*vn(:,i) ; zeros(nfft-1,1)];
%    junk2 = [y.*vn(:,i) ; zeros(nfft-1,1)];
   junk1 = x.*vn(:,i);
   junk2 = y.*vn(:,i);
   yk_i(:,i) = fft(junk1);
   yk_j(:,i) = fft(junk2);
   
end

% Complex eigenspectra 

nfft2 = length(yk_i);
% For now, assume unit weights
% *********
% TO DO
% *********

dyk_i = yk_i;
dyk_j = yk_j;

% Force zero mean process
% %
% for i = 1:kspec
%   dyk_i(:,i) = dyk_i(:,i) - sum(real(dyk_i(:,i)))/(nfft);
%   dyk_j(:,i) = dyk_j(:,i) - sum(real(dyk_j(:,i)))/(nfft);
% end

% Calculate power spectra

% si = sum(abs(dyk_i).^2, 2); 
sj = sum(abs(dyk_j).^2, 2);


eps = 0.0001 * sum(sj)/real(nfft);

% Initialize xspec

xspec(1:nfft2) = 0;
for i = 1:nfft2
   
   % Deconvolution
   
   xspec(i) = sum ( dyk_i(i,:) .* conj(dyk_j(i,:)) );  
   
%    xspec(i) = xspec(i) / (sj(i));
   xspec(i) = xspec(i) / (sj(i)+eps);
 
end
% Zero mean process

% xspec = xspec - sum(real(xspec))/nfft;


% Sym fft
% *******
% TO DO
% *******
% stf_spe = abs(xspec(1:floor(nfft2/2)+1));
% stf_spe(2:end-1)= stf_spe(2:end-1);
% stfpf = 1/(dt*nfft2)*(0:floor(nfft2/2));


tfun = ifft(xspec);


return






