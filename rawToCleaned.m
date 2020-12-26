function [u,f] = RawToCleaned(u_raw,f_raw)
if sum(u_raw) == 0
    disp('Die Datenreihe existiert nicht.')
    u = 0;
    f = 0;
else
    
    [val,idx_top] = max(f_raw);

    u = u_raw(1:idx_top);
    f = f_raw(1:idx_top);

    idx_temp = find(f < 250,1,'Last');
    
    if isempty(idx_temp)
        idx_temp =1;
    end

    u = u(idx_temp:end);
    f = f(idx_temp:end);
    
    du_origin   = u(1);
    u           = u-du_origin;


end

end