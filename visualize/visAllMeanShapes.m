function visAllMeanShapes(classes,id)
% VISALLMEANSHAPES  Given a set of classes, visualize the mean shapes for
% those classes.


% Number of classes
N = length(classes);

% For each of the classes
for i=1:length(classes)
    % Create a subplot
    subplot(ceil(sqrt(N)),ceil(sqrt(N)),i);
    % Get full path to the directory containing shape models
    shapeModels = jobDirs(classes{i},id,'shapeModel');
    % Load shapemodels from that directory
    tmp = load(shapeModels);
    showMeshTri(struct('vertices',tmp.shapeModelOpt.S,'faces',tmp.shapeModelOpt.tri));
    colormap jet
    view(3);
end

end