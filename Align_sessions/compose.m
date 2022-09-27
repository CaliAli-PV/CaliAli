function [vx,vy] = compose(ax,ay,bx,by)
    [x,y] = ndgrid(0:(size(ax,1)-1), 0:(size(ax,2)-1)); % coordinate image
    x_prime = x + ax; % updated x values
    y_prime = y + ay; % updated y values
    
    % Interpolate vector field b at position brought by vector field a
    bxp = interpn(x,y,bx,x_prime,y_prime,'linear',0); % interpolated bx values at x+a(x)
    byp = interpn(x,y,by,x_prime,y_prime,'linear',0); % interpolated bx values at x+a(x)
    % Compose
    vx = ax + bxp;
    vy = ay + byp;
    
end
