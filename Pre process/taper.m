function [wave_taper] = taper(wave,f1,f2)
%taper
wave_taper = wave;
index_taper1 = fix(f1*length(wave));
index_taper2 = fix(f2*length(wave));
for i=1:1:index_taper1
    wave_taper(i) = wave(i)*exp(2*(i-index_taper1));
end
for i=index_taper2:1:length(wave)
    wave_taper(i) = wave(i)*exp(2*(index_taper2 - i));
end

end