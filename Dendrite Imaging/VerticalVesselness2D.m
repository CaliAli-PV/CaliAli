function vesselness = VerticalVesselness2D(I, sigmas, spacing, tetha_threshold, brightondark, norm)
%VerticalVesselness2D Calculates the vesselness probability map (local 
%                    tubularity) of a 2D input image, emphasizing vertical 
%                    structures.
%
%   vesselness = VerticalVesselness2D(I, sigmas, spacing, tetha_threshold, brightondark, norm)
%
%   Inputs:
%       I :                2D input image.
%       sigmas :           Vector of scales on which the vesselness is computed.
%       spacing :          Input image spacing resolution (e.g., [1;1] for 
%                          isotropic resolution). Used to adjust Gaussian 
%                          filter kernel size.
%       tetha_threshold:   Angle threshold in degrees for emphasizing 
%                          vertical structures.
%       brightondark:      (true/false) True if vessels are bright on a dark 
%                          background, false if dark on bright. Default is false.
%       norm:              (true/false) True for normalized vesselness response, 
%                          false for additive response. Default is true.
%
%   Outputs:
%       vesselness: Maximum vesselness response over scales sigmas.
%
%   Example:
%       V = VerticalVesselness2D(I, 1:5, [1;1], 10, false, true); 
%
%   Notes:
%       - The 'tetha_threshold' parameter controls the emphasis on vertical 
%         structures. A smaller angle emphasizes vertical structures more 
%         strongly.
%       - The 'norm' parameter determines how the vesselness response is 
%         combined across scales. 'true' uses the maximum response, while 
%         'false' sums the responses.


% Set default values for optional inputs
if nargin < 6
    norm = true;  % Default is to normalize the vesselness response
end
if nargin < 5
    brightondark = false; % Default is dark vessels on a bright background
end
if nargin < 4
    tetha_threshold = 10; % Default angle threshold (degrees)
end

% Convert image to single precision
I = single(I);

% Initialize vesselness map
vesselness = zeros(size(I, 1), size(I, 2));

% Loop through each scale (sigma)
for j = 1:length(sigmas)
    [~, Lambda2] = imageEigenvalues(I, sigmas(j), spacing, brightondark, tetha_threshold);
    
    % Invert response if vessels are bright on dark background
    if brightondark == true
        Lambda2 = -Lambda2;
    end

    % Combine vesselness response across scales
    if norm==1
        vesselness = max(cat(3, vesselness, mat2gray(Lambda2)), [], 3); % Normalized maximum response
    elseif norm==0
        vesselness = vesselness + Lambda2;  % Additive response
    elseif norm==2
         vesselness = max(cat(3, vesselness, Lambda2), [], 3); % Normalized maximum response without scaling
    end
    
    clear response Lambda2 Lambda3  % Clear temporary variables
end

% vesselness = vesselness ./ max(vesselness(:)); % should not be really needed
% vesselness(vesselness < 1e-2) = 0;
end

function [Lambda1, Lambda2] = imageEigenvalues(I,sigma,spacing,brightondark,theta_threshold)
% calculates the two eigenvalues for each voxel in a volume

% Calculate the 2D hessian
[Hxx, Hyy, Hxy] = Hessian2D(I,sigma,spacing);

% Correct for scaling
c=sigma.^2;
Hxx = c*Hxx;
Hxy = c*Hxy;
Hyy = c*Hyy;

% reduce computation by computing vesselness only where needed
% S.-F. Yang and C.-H. Cheng, 擢ast computation of Hessian-based
% enhancement filters for medical images, Comput. Meth. Prog. Bio., vol.
% 116, no. 3, pp. 215225, 2014.
B1 = - (Hxx+Hyy);
B2 = Hxx .* Hyy - Hxy.^2;

T = ones(size(B1));

if brightondark == true
    T(B1<0) = 0;
    T(B2==0 & B1 == 0) = 0;
else
    T(B1>0) = 0;
    T(B2==0 & B1 == 0) = 0;
end

clear B1 B2;

indeces = find(T==1);

Hxx = Hxx(indeces);
Hyy = Hyy(indeces);
Hxy = Hxy(indeces);

% Calculate eigen values
[Lambda1i,Lambda2i,theta]=eigvalOfHessian2D(Hxx,Hxy,Hyy,theta_threshold);

clear Hxx Hyy Hxy;

Lambda1 = zeros(size(T));
Lambda2 = zeros(size(T));
Th = zeros(size(T));

Lambda1(indeces) = Lambda1i;
Lambda2(indeces) = Lambda2i;
Th(indeces) = theta;

% some noise removal
Lambda1(~isfinite(Lambda1)) = 0;
Lambda2(~isfinite(Lambda2)) = 0;

Lambda1(abs(Lambda1) < 1e-4) = 0;
Lambda2(abs(Lambda2) < 1e-4) = 0;

Lambda2=medfilt2(mat2gray(Th),round([c,c])+1).*Lambda2;
end


function [Dxx, Dyy, Dxy] = Hessian2D(I,Sigma,spacing)
%  filters the image with an Gaussian kernel
%  followed by calculation of 2nd order gradients, which aprroximates the
%  2nd order derivatives of the image.
%
% [Dxx, Dyy, Dxy] = Hessian2D(I,Sigma,spacing)
%
% inputs,
%   I : The image, class preferable double or single
%   Sigma : The sigma of the gaussian kernel used. If sigma is zero
%           no gaussian filtering.
%   spacing : input image spacing
%
% outputs,
%   Dxx, Dyy, Dxy: The 2nd derivatives

if nargin < 3, Sigma = 1; end

if(Sigma>0)
    F=imgaussian(I,Sigma,spacing);
else
    F=I;
end

% Create first and second order diferentiations
Dy=gradient2(F,'y');
Dyy=(gradient2(Dy,'y'));
clear Dy;

Dx=gradient2(F,'x');
Dxx=(gradient2(Dx,'x'));
Dxy=(gradient2(Dx,'y'));
clear Dx;
end

function D = gradient2(F,option)
% Example:
%
% Fx = gradient2(F,'x');

[k,l] = size(F);
D  = zeros(size(F),class(F));

switch lower(option)
    case 'x'
        % Take forward differences on left and right edges
        D(1,:) = (F(2,:) - F(1,:));
        D(k,:) = (F(k,:) - F(k-1,:));
        % Take centered differences on interior points
        D(2:k-1,:) = (F(3:k,:)-F(1:k-2,:))/2;
    case 'y'
        D(:,1) = (F(:,2) - F(:,1));
        D(:,l) = (F(:,l) - F(:,l-1));
        D(:,2:l-1) = (F(:,3:l)-F(:,1:l-2))/2;
    otherwise
        disp('Unknown option')
end
end

function I=imgaussian(I,sigma,spacing,siz)
% IMGAUSSIAN filters an 1D, 2D color/greyscale or 3D image with an
% Gaussian filter. This function uses for filtering IMFILTER or if
% compiled the fast  mex code imgaussian.c . Instead of using a
% multidimensional gaussian kernel, it uses the fact that a Gaussian
% filter can be separated in 1D gaussian kernels.
%
% J=IMGAUSSIAN(I,SIGMA,SIZE)
%
% inputs,
%   I: 2D input image
%   SIGMA: The sigma used for the Gaussian kernel
%   SPACING: input image spacing
%   SIZ: Kernel size (single value) (default: sigma*6)
%
% outputs,
%   I: The gaussian filtered image
%

if(~exist('siz','var')), siz=sigma*6; end

if(sigma>0)

    % Filter each dimension with the 1D Gaussian kernels\
    x=-ceil(siz/spacing(1)/2):ceil(siz/spacing(1)/2);
    H = exp(-(x.^2/(2*(sigma/spacing(1))^2)));
    H = H/sum(H(:));
    Hx=reshape(H,[length(H) 1]);

    x=-ceil(siz/spacing(2)/2):ceil(siz/spacing(2)/2);
    H = exp(-(x.^2/(2*(sigma/spacing(2))^2)));
    H = H/sum(H(:));
    Hy=reshape(H,[1 length(H)]);

    I=imfilter(imfilter(I,Hx, 'same' ,'replicate'),Hy, 'same' ,'replicate');
end
end

function [Lambda1,Lambda2,x]=eigvalOfHessian2D(Dxx,Dxy,Dyy,theta_threshold)
% This function calculates the eigen values from the
% hessian matrix, sorted by abs value

% Compute the eigenvectors of J, v1 and v2
tmp = sqrt((Dxx - Dyy).^2 + 4*Dxy.^2);
theta = 0.5 * atan2(2 * Dxy, Dxx - Dyy);
% Compute the eigenvalues
mu1 = 0.5*(Dxx + Dyy + tmp);
mu2 = 0.5*(Dxx + Dyy - tmp);

% Sort eigen values by absolute value abs(Lambda1)<abs(Lambda2)
check=abs(mu1)>abs(mu2);

Lambda1=mu1; Lambda1(check)=mu2(check);

Lambda2=mu2; Lambda2(check)=mu1(check);

if abs(theta_threshold)>0
    x=rad2deg(abs(theta));
    x=(x-theta_threshold);
    x(x<0)=0;
    x=1-rescale(x);
    % x=x.^2;
    % Lambda2=Lambda2.*x;
end
end

