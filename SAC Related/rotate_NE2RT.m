function [R, T] = rotate_NE2RT(N,E,varargin)
%{
Tao mo 2022 ESS-SUSTech 

function to rotate the waveform 
from [N E] 2 [R T] components

INPUT:
N-North Component
E-East Component
    and
AZ-Azimuth between hypocenter and station
    or
STLA-Station latitude
STLO-Station longitude
EVLA-Event latitude
EVLO-Event longitude


OUTPUT:
R-Radial component
T-Tangential component
%}

if length(varargin) == 1
    AZ = varargin{1};
    if AZ>=0 && AZ<=360
        R = cosd(AZ) * N + sind(AZ) * E;
        T = -sind(AZ) * N + cosd(AZ) * E;
    else
        error("Input ERROR!! Azimuth out of range.")
    end
    return;
elseif length(varargin) == 4
    STLA = varargin{1};
    STLO = varargin{2};
    EVLA = varargin{3};
    EVLO = varargin{4};
    if STLO >= -180 && STLO <= 180 && ...
       STLA >= -90  && STLA <= 90  && ...
       EVLO >= -180 && EVLO <= 180 && ...
       EVLA >= -90  && EVLA <= 90
        [~,AZ]=distance(EVLA,EVLO,STLA,STLO);
        R = cosd(AZ) * N + sind(AZ) * E;
        T = -sind(AZ) * N + cosd(AZ) * E;
    else
        error("Input ERROR!! Latitude or Longitude out of range.")
    end
    return;
else
    error("please input (1) azimuth or (2) latitude and longitude of event and station")
end
