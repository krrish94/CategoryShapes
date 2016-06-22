function train_model = runTrainNRSFM(data,class)
% TRAIN_MODEL  Run and cache NRSFM. Load cached NRSFM model if available.


% Declaring global variables
globals;

% Load params, if global params struct is not present (get_params() returns
% the global params struct if it exists).
params = get_params();

% Path to cached NRSFM model
shapeModelNRSFMFile = fullfile(cachedir,class,'shapeModelNRSFM.mat');

fprintf('\n%%%%%%%%%%%% NRSFM %%%%%%%%%%%%\n');

% If cached model is found, load train_model from it
if(exist(shapeModelNRSFMFile,'file'))
    fprintf('Loading cached NRSFM model from \n%s\n',shapeModelNRSFMFile);
    load(shapeModelNRSFMFile,'train_model');
% Else, run NRSFM
else
    % Setup training data struct (filter instances and normalize keypoints)
    [train,~] = prep_data(data.train,1,params.nrsfm.flip);
    
    % Train model
    fprintf('Train Non Rigid SFM model \n');    
    train_model = train_nrsfm(params.class,train);
    
    % Caching trained NRSFM model
    fprintf('Caching NRSFM model in \n%s\n',shapeModelNRSFMFile);
    save(shapeModelNRSFMFile,'train_model');
end

end