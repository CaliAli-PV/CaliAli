function [X,Y]=get_random_points(x,y,minAllowableDistance,numberOfPoints,plotme)

p = randperm(length(y),length(y));
y=y(p);
x=x(p);
% Initialize first point.
X = x(1);
Y = y(1);
% Try dropping down more points.
count=2;
for k=2:length(x)
  % Get a trial point.

  thisX = x(k);
  thisY = y(k);
  % See how far is is away from existing keeper points.
  distances = sqrt((thisX-X).^2 + (thisY - Y).^2);
  minDistance = min(distances);
  if minDistance >= minAllowableDistance
    X(count) = thisX;
    Y(count) = thisY;
    count = count + 1;
  end
  if count>numberOfPoints
    break  
  end   
end

if plotme
plot(X, Y, 'b*');
set(gca, 'YDir','reverse')
end
% grid on;