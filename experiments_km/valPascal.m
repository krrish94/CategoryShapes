% Open up a Pascal (train) file and validate my understanding of the
% wireframe model, keypoint conventions, etc.


% Declaring global variables
globals;

% % Run the following set of lines once to set up all required variables
% class = 'car';
% load(fullfile(cachedir, class, 'shapeModelNRSFM'));
% data = prepPascalData(class);
% [train,~] = prep_data(data.train,1,params.nrsfm.flip);

% PASCAL_DIR contains the path to the directory containing Pascal images
% Load an image from the directory
curIdx = 4;

% Get the number of training samples
numTrain = length(train_model.rotP3d);

% Read in image
im = imread(fullfile(PASCAL_DIR, [train.voc_image_id{curIdx}, '.jpg']));
% Read in bbox corresponding to the current detection
bbox = train.bbox(curIdx,:);

% Get 2D locations of keypoints
kps2d = train_model.points2([curIdx,numTrain+curIdx],:);

% Retain only non-NaN keypoints
% isnan(kps2d) returns the set of indices that are NaN. We sum them along
% each col. In order for a column to be valid, the number of NaNs in that
% column must sum to 0.
kps2d = kps2d(:,sum(isnan(kps2d),1) == 0);

% Get 3D locations of keypoints
kps3d = train_model.points3([curIdx, numTrain+curIdx, (2*numTrain)+curIdx],:);

% Get camera intrinsics

% Display the image and the bbox
imshow(im);
hold on;
rectangle('Position', [bbox(1), bbox(2), bbox(3), bbox(4)], ...
    'EdgeColor', 'g', 'LineWidth', 3);
hold off;


% Clearing variables that are of no significant use
clear curIdx
clear im
clear bbox
% clear kps2d
% vclear kps3d
clear numTrain
