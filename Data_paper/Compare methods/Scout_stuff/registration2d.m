function registration=registration2d(fixed,moving,varargin)
% REGISTRATION_EXAMPLE2D 2D example for image registration
%
% registration_example2d()
%
% See also REGISTRATION_EXECUTE

% Copyright (c) 2012 Daniel Forsberg
% danne.forsberg@outlook.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Default parameters, applicable for all image registration

% phase, optical-flow, polyomial-expansion
method = 'optical-flow';

% translation, affine, non-rigid
transformationModel = 'affine';

% scale parameters
startScale = 3;
stopScale = 1;
iterationsPerScale = [4];

% true/false, will set useTensorMagnitudeRepresentation to true if method
% is set to 'phase'
multiModal = false;

% true/false, will set logDomain to true if transformationModel is set to
% 'non-rigid'
symmetric = true;

%% only relevant for multi-modal and polynomial-expansion/optical-flow
% number of channels
numberOfChannels = [16 12 8];

%% only relevant for polynomial expansion 
% linear, quadratic
signalModel = 'linear';

%% only relevent for phase
fixedCertainty = [];
movingCertainty = [];

%% only relevant for non-rigid
% sum, compositive, diffeomorphic
accumulationMethod = 'compositive';

% regularization
fluidRegularizationData = [1];
fluidRegularization = true;
elasticRegularizationData = [1];
elasticRegularization = true;

% perform accumulation in the log-domain
logDomain = false;

% BCH approximation mode, only relevant if logDomain is true;
BCHmode = 'A';

% apply certainty in regularization and accumulation
applyCertainty = false;

%% display
display = true;
displayFinal = true;
gamma = 0.7;
recordMovie = false;
movieName = 'test.avi';

%% evaluate
evaluate = false;

%% Overwrites default parameter
for k=1:2:length(varargin)
  eval([varargin{k},'=varargin{',int2str(k+1),'};']);
end;

%%
% Set data and transform original data

global registration;

registration.moving = moving;
registration.fixed=fixed;
minScale = 0.6;
maxScale = 1.4;
minShear = -0.4;
maxShear = 0.4;
minTranslation = -20;
maxTranslation = 20;
% 
% switch transformationModel
%     case 'translation'
%         transformationMatrix = create_transformation_matrix2d(...
%             'translationX',uniform(minTranslation, maxTranslation, [1,1]),...
%             'translationY',uniform(minTranslation, maxTranslation, [1,1]));
%         registration.fixed = affine_transformation(registration.moving,transformationMatrix);
%     case 'rigid'
%         transformationMatrix = create_transformation_matrix2d(...
%             'translationX',uniform(minTranslation, maxTranslation, [1,1]),...
%             'translationY',uniform(minTranslation, maxTranslation, [1,1]),...
%             'phiZ',uniform(-pi/6, pi/6, [1,1]));
%         registration.fixed = affine_transformation(registration.moving,transformationMatrix);
%     case 'affine'
%         transformationMatrix = create_transformation_matrix2d(...
%             'translationX',uniform(minTranslation, maxTranslation, [1,1]),...
%             'translationY',uniform(minTranslation, maxTranslation, [1,1]),...
%             'scaleX',uniform(minScale, maxScale, [1,1]),...
%             'scaleY',uniform(minScale, maxScale, [1,1]),...
%             'shearXY',uniform(minShear, maxShear, [1,1]),...
%             'shearYX',uniform(minShear, maxShear, [1,1]));
%         registration.fixed = affine_transformation(registration.moving,transformationMatrix);
%     case 'non-rigid'
%         displacementField = field_exponentiation(...
%             create_nonrigid_displacement_field2d(...
%             size(registration.moving),'maxDisplacement',20));
%         registration.fixed = deformation(...
%             registration.moving,displacementField,'linear');
% end

%% Set registration parameters
% phase, optical-flow, polyomial-expansion
registration.method = method;

% translation, affine, non-rigid
registration.transformationModel = transformationModel;

% scale, level
registration.multiLevelMode = 'resolution';

registration.dims = ndims(registration.fixed);
registration.interpolation = 'cubic';

registration.startScale = startScale;
registration.stopScale = stopScale;
registration.iterationsPerScale = iterationsPerScale;

% true/false
registration.multiModal = multiModal;

% true/false, will set logDomain to true if transformationModel is set to
% 'non-rigid'
registration.symmetric = symmetric;

%% Number of channels only relevant for multi-modal and
% polynomial-expansion/optical-flow
registration.numberOfChannels = numberOfChannels;

%% Local signal model for polynomial expansion transformation
% linear, quadratic
registration.signalModel = signalModel;

%% Certainty mask to use for phase estimation
% only relevent for phase
registration.fixedCertainty = fixedCertainty;
registration.movingCertainty = movingCertainty;

%% Only relevant for non-rigid
% sum, compositive, diffeomorphic
registration.accumulationMethod = accumulationMethod;

% regularization
registration.fluidRegularizationData = fluidRegularizationData;
registration.fluidRegularization = fluidRegularization;
registration.elasticRegularizationData = elasticRegularizationData;
registration.elasticRegularization = elasticRegularization;

% apply certainty in regularization and accumulation
registration.applyCertainty = applyCertainty;

% perform accumulation in the log-domain
registration.logDomain = logDomain;

% BCH approximation mode, only relevant if logDomain is true;
registration.BCHmode = BCHmode;

%% Display
registration.display = false;
registration.displayFinal = false;
registration.gamma = gamma;
registration.recordMovie = recordMovie;
registration.movieName = movieName;

%% Evaluate
registration.evaluate = evaluate;

%% Run registration
registration_execute();