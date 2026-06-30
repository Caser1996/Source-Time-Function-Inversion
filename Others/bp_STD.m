function [bpup,bpdown,est_STD] = bp_STD(mag)
if mag<=2.0
    bpup = 100;
    bpdown = 1.0;
    est_STD = 10;
elseif 2.0<mag && mag<=2.5
    bpup = 100;
    bpdown = 0.5;
    est_STD = 20;
elseif 2.5<mag && mag<=3.0
    bpup = 50;
    bpdown = 0.2;
    est_STD = 30;
elseif 3.0<mag && mag<=3.5
    bpup = 30;
    bpdown = 0.2;
    est_STD = 50;
elseif 3.5<mag && mag<=4.0
    bpup = 20;
    bpdown = 0.1;
    est_STD = 100;
elseif 4.0<mag && mag<=4.5
    bpup = 10;
    bpdown = 0.08;
    est_STD = 150;
elseif 4.5<mag && mag<=5.0
    bpup = 8;
    bpdown = 0.05;
    est_STD = 200;
elseif 5.0<mag && mag<=5.5
    bpup = 5;
    bpdown = 0.05;
    est_STD = 250;
elseif 5.5<mag && mag<=6.0
    bpup = 3;
    bpdown = 0.02;
    est_STD = 500;
elseif 6.0<mag 
    bpup = 2;
    bpdown = 0.01;
    est_STD = 1000;
else
    error("magnitude out of limit")
end