function basisShapeModel = mainTrain(class, exptID, paramStruct)
% MAINTRAIN  Main script to perform training, i.e., learn a basis shape
% model on Pascal3D, given the class label and optional parameters


% If parameters are not passed, initialize the parameter struct to be empty
if(nargin<3)
    paramStruct = {};
end

% If an experiment ID isn't passed, let it be ''
if(nargin<2)
    exptID = '';
end


% Run the startup script
startup;

% Declaring global variables
globals;

% Create a subdir in the cache directory, if the subdir does not already
% exist
mkdirOptional(fullfile(cachedir,class));

% Load the parameter struct
params = get_params(paramStruct);
% Initialize the class of the parameter struct
params.class = class;


% Prepare data for NRSfM
data = prepPascalData(class);

% Run NRSFM and cache model / Load cached models if they exist
nrsfmModel = runTrainNRSFM(data,class);

% Run and cache basis shape model
basisShapeModel = trainBasisShapes(nrsfmModel, class, exptID);

end
