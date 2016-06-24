function projectPascal
% PROJECTPASCAL  Testing code for loading a PASCAL3D CAD model and
% projecting it onto an image


% Storing important paths in here
paths.pascal3d = '/home/km/ViewpointsAndKeypoints/data/PASCAL3D';
paths.pascalImages = fullfile(paths.pascal3d, 'Images/car_pascal');
paths.pascalAnnotations = fullfile(paths.pascal3d, 'Annotations/car_pascal');
paths.imagenetImages = fullfile(paths.pascal3d, 'Images/car_imagenet');
paths.imagenetAnnotations = fullfile(paths.pascal3d, 'Annotations/car_imagenet');
paths.pascalVOCdevkit = fullfile(paths.pascal3d, 'PASCAL/VOCdevkit');
paths.pathCAD = fullfile(paths.pascal3d, 'CAD/car.mat');

% Add the VOC code directory to path
addpath(fullfile(paths.pascalVOCdevkit, 'VOCcode'));

% Load the CAD model mat file
load(paths.pathCAD)
cads = car;

% Load annotation file list
files = dir(fullfile(paths.pascalAnnotations));

figure(1);
cmap = colormap(jet);
pad_size = 100;
% Skipping the first two files in the directory listing as they correspond
% to . and .. respectively
for imgIdx = 8
    
    % Split the file name into various parts
    fileName = files(imgIdx).name;
    [~, name, ~] = fileparts(fileName);
    
    % Display the image
    subplot(1,2,1);
    fileName = fullfile(paths.pascalImages, [name, '.jpg']);
    I = imread(fileName);
    imshow(I);
    
    [h, w, ~] = size(I);
    mask = ones(h, w, 3);
    mask = padarray(mask, [pad_size pad_size 0]);
    
    hold on;
    
    % Load annotations
    object = load(fullfile(paths.pascalAnnotations, files(imgIdx).name));
    objects = object.record.objects;
    
    % For each annotated objects
    for i = 1:numel(objects)
        % Verify that the object is of the 'car' class
        object = objects(i);
        if strcmp(object.class, 'car') == 0
            continue;
        end
        
        % Plot the 2D bbox
        bbox = object.bbox;
        bbox_draw = [bbox(1), bbox(2), bbox(3)-bbox(1), bbox(4)-bbox(2)];
        rectangle('Position', bbox_draw, 'EdgeColor', 'g', 'LineWidth', 2);
        
        % Get the vertices and faces from the relevant CAD model
        cadIndex = object.cad_index;
        x3d = cads(cadIndex).vertices;
        % Project them to 2D
        x2d = projectCADmodel(x3d, object);
        if isempty(x2d)
            continue
        end
        face = cads(cadIndex).faces;
        
        % Draw the CAD overlap
        index_color = 1 + floor((i-1) * size(cmap,1) / numel(objects));
        patch('vertices', x2d, 'faces', face, ...
            'FaceColor', cmap(index_color,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        
        x2d = x2d + pad_size;
        vertices = [x2d(face(:,1),2) x2d(face(:,1),1) ...
            x2d(face(:,2),2) x2d(face(:,2),1) ...
            x2d(face(:,3),2) x2d(face(:,3),1)];
        % BW is the mask
        BW = mesh_test(vertices, h+2*pad_size, w+2*pad_size);
        
        % create a colorful mask
        for j = 1:3
            tmp = mask(:,:,j);
            tmp(BW) = cmap(index_color,j);
            mask(:,:,j) = tmp;
        end
    end
    hold off;
    
    % Display the mask
    subplot(1,2,2);
    mask = mask(pad_size+1:h+pad_size, pad_size+1:w+pad_size,:);
    imshow(uint8(255*mask));
    axis off;
    axis equal;
    
end

end