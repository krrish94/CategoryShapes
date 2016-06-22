function dirName = jobDirs(class, jobID, tag)
% JOBDIRS  Returns a specific directory you're looking for in cached models
% for a particular class. The directory you're looking for is detemined by
% the values of the 'jobID' and 'tag' parameters.


% Declaring global variables
globals;

% Directory containing the cached training data for the class
clsDir = fullfile(cachedir,class);

% Create a function handle that concatenates two strings
jobcat = @(x)strcat(x,jobID);

% Directory containing various states
statesDir = fullfile(clsDir,jobcat('statesDir'));
% Directory containing inferred shapes
inferredShapesDir = fullfile(clsDir,jobcat('inferredShapes'));
% Directory containing meshes
meshesDir = fullfile(clsDir,jobcat('meshes'));
% Directory containing depth map
dmapDir = fullfile(clsDir,jobcat('depthMap'));
% Directory containing SIRFS (Shape, Illumination, and Reflectance from
% Shading) data
sirfsDir = fullfile(clsDir,jobcat('sirfs'));
% Directory containing shape model optimization data
shapeModelOptFile = fullfile(clsDir,strcat(jobcat('shapeModelOpt'),'.mat'));
% Directory containing the shape model NRSfM data
shapeModelNRSFMFile = fullfile(clsDir,'shapeModelNRSFM.mat');
% Directory containing the eval meshes data
evalMeshesFile = fullfile(clsDir,strcat(jobcat('evalMeshes'),'.mat'));
% Directory containing the eval depth data
evalDepthFile = fullfile(clsDir,strcat(jobcat('evalDepth'),'.mat'));

% Depending on the argument passed in 'tag', we return the appropriate dir
switch tag
    case 'state'
        dirName = statesDir;
    case 'inferredShape'
        dirName = inferredShapesDir;
    case 'mesh'
        dirName = meshesDir;
    case 'dmap'
        dirName = dmapDir;
    case 'sirfs'
        dirName = sirfsDir;
    case 'shapeModel'
        dirName = shapeModelOptFile;
    case 'nrsfm'
        dirName = shapeModelNRSFMFile;
    case 'evalMesh'
        dirName = evalMeshesFile;
    case 'evalDepth'
        dirName = evalDepthFile;
    otherwise
        error('Which directory name do you want?');
end

end