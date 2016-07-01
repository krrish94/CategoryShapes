function model_3d = train_nrsfm(cls, train_set)
% TRAIN_NRSFM  Given a train set and a class label, TRAIN_NRSFM creates a
% 3D model using NRSfM.


% Declaring global variables
globals;


%% Pre-processing

% Fetching user-configurable parameters
params = get_params();
% Check which of the points are NaN
md = isnan(train_set.points(1:end/2,:));
% Set all those points to zeros
points = train_set.points;
points_bak = points;
points(isnan(points))=0;

% Load segmentation masks
try
    seg.poly_x = train_set.poly_x;
    seg.poly_y = train_set.poly_y;
catch
    seg = train_set.mask;
end


% Setup variables for converting to PASCAL 3D frame

% Load partnames
load(fullfile(datadir,'partNames',cls));
% Load VOC keypoint metadata
load(fullfile(datadir,'voc_kp_metadata'));

% Get the index of the class in the Pascal dataset
cInd = find(ismember(metadata.categories,cls));

% Sort keypoint names (usually not needed, as metadata is already sorted in
% lexicographic order)
[~,I] = sort(metadata.kp_names{cInd});
% Create an array of indices ranging from 1 to nKps, where nKps is the
% number of keypoints for the current class
invI(I) = 1:numel(I);

% Get information about the right-handed coordinate system of the current
% class (I'm unclear on this)
rightCoordSys = metadata.right_coordinate_sys{cInd};
rightCoordSys(1:6) = invI(rightCoordSys(:));
% Get corresponding part name information
names = partNames(rightCoordSys);


%% Run NRSfM

% Inputs to NRSfM
% points: 2D points, md: missing data binary matrix (0s wherever 2D points
% were NaNs), params.nrsfm.nBasis: number of basis vectors to output, seg:
% segmentation masks (set of polygons), train_set.imsize: image sizes of
% each image in the train set, train_set.bbox: bboxes of training
% instances, params.nrsfm.tol: termination tolerance (in terms of
% proportional change in likelihood), params.nrsfm.max_em_iter: maximum
% number of EM iterations, rightCoordSys: (???), train_set.rotP3d: rotation
% information (from Pascal 3D annotations) for training instances

% Run NRSfM
[P3, S_bar, V, RO, Tr, Z, sigma_sq, ~, ~, ~, ~, c] = em_sfm(points, md, ...
    params.nrsfm.nBasis, seg, train_set.imsize, train_set.bbox, ...
    params.nrsfm.to, params.nrsfm.max_em_iter, rightCoordSys, ...
    train_set.rotP3d);

% Outputs from NRSfM
% P3: 3D points, S_bar: mean shape, V: deformation basis (refer to the
% em_sfm function documentation on how the deformation basis is formed),
% R0: rotation matrices (for all instances), Tr: translation vectors (for
% all instances), Z: deformation weights (for all instances), sigma_sq:
% (co)variance of the Gaussian noise assumed (noise in keypoint locations),
% c: scale coefficients for estimated parameters (???) (for all instances)


%% Post-processing

% Class label
model_3d.class = cls;
% Mean shape
model_3d.S_bar = S_bar;
% Deformation basis vectors
model_3d.defBasis = V;
% Part names
model_3d.part_names = train_set.labels;
% Variance in Gaussian noise assumed over keypoint locations
model_3d.sigma_sq = sigma_sq;
% Estimated 3D structure
model_3d.points3 = P3;
% Estimated 3D motion (rotation and translation), per instance
model_3d.rots = RO;
model_3d.trs = Tr;
% Deformation weights for each of the basis vectors, for each instance
model_3d.def_weights = Z;
% Image ids for each training instance
model_3d.voc_image_id = train_set.voc_image_id;
% VOC rec ids for each training instance
if(isfield(train_set,'voc_rec_id'))
    model_3d.voc_rec_id = train_set.voc_rec_id;
end
% Bbox detections for each training instance
model_3d.bbox = train_set.bbox;
% 2D point locations for each instance
model_3d.points2 = points_bak;
% User-configurable parameters
model_3d.params = params;
% Scale factors for each training instance
model_3d.c = c;
% Segmentation masks for each training instance
model_3d.seg = seg;
% Writing out other relevant data fields to the trained model struct
if(isfield(train_set,'flip'))
    model_3d.flip = train_set.flip;
end
if(isfield(train_set,'subtype'))
    model_3d.subtype = train_set.subtype;
end
if(isfield(train_set,'rotP3d'))
    model_3d.rotP3d = train_set.rotP3d;
end

end
