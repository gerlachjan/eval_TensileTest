
function [xx,fxx] = bestfit3(du01,du02,du03,f01,f02,f03)
 [du01,order01]    = unique(du01);
 f01               = f01(order01);
 [du02,order02]    = unique(du02);
 f02               = f02(order02);
 [du03,order03]    = unique(du03);
 f03               = f03(order03);

%define points for interpolation
xx  = linspace(0,10,20000);

%interpolation of forces w.r.t same x-points xx
if du01 == 0
    fxx1 = 0;
    fxx2 = interp1(du02,f02,xx);
    fxx3 = interp1(du03,f03,xx);
elseif du02 == 0
    fxx1 = interp1(du01,f01,xx);
    fxx2 = 0;
    fxx3 = interp1(du03,f03,xx);
elseif du03 == 0
    fxx1 = interp1(du01,f01,xx);
    fxx2 = interp1(du02,f02,xx);
    fxx3 = 0;
else
    fxx1 = interp1(du01,f01,xx);
    fxx2 = interp1(du02,f02,xx);
    fxx3 = interp1(du03,f03,xx);
end

%calculation of force averarge w.r.t xx
fxx = 1/3*(fxx1 + fxx2 + fxx3);

% figure(2)
% hold on
% plot(du01,f01,du02,f02,du03,f03)
% plot(xx,fxx,':.')
end



