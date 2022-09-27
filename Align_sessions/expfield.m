function [vx,vy] = expfield(vx, vy)
    % Find n, scaling parameter
    normv2 = vx.^2 + vy.^2;
    m = sqrt(double(max(normv2(:))));
    n = ceil(log2(m/0.5)); % n big enough so max(v * 2^-n) < 0.5 pixel)
    n = max(n,0);          % avoid null values
    
    % Scale it (so it's close to 0)
    vx = vx * 2^-n;
    vy = vy * 2^-n;
    % square it n times
    for i=1:n
        [vx,vy] = compose(vx,vy, vx,vy);
    end
end