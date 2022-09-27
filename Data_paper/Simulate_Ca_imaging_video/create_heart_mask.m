function BW=create_heart_mask(d1,d2)

t = linspace(-pi,pi, 350);
X =      t .* sin( pi * .9*sin(t)./t);
Y = -abs(t) .* cos(pi * sin(t)./t);
X=X-min(X);X=X./max(X);
Y=Y-min(Y);Y=Y./max(Y);

X=X*d2*0.6+d2*0.2;
Y=Y*d1*0.6+d1*0.2;

BW = poly2mask(X,Y,d1,d2);