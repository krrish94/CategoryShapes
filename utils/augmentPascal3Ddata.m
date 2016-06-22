function [data3d] = augmentPascal3Ddata(data,class)
% AUGMENTPASCAL3DDATA  Augments Pascal 3D data to the current train and
% test data. Used for evaluation, to align learned models to the Pascal 3D
% frame.


% Declaring global variables
globals;

% Number of data samples
N = length(data);

% Load subtypes for each class
load(fullfile(datadir,'subtypeClusters'));

% Initialize the augmented data with the current data
data3d = data;

% Get the class index of the current class
cInd = pascalClassIndex(class);

% Flag to indicate whether or not annotations for the current class have
% been found
notFound = 0;

% For each image
for i = 1:N
    % Read in the 2D bounding box information
    bbox = data(i).bbox;
    % If it is to be flipped, compute the flipped bounding box
    if(data(i).flip)
        bbox(1) = data(i).imsize(2) + 1 - bbox(1) - bbox(3);
    end
    % Else, compute the bounding box as per convention, i.e., compute (x1,
    % y1, x2, y2) from (x, y, w, h)
    bbox(3:4) = bbox(1:2)+bbox(3:4)-1;
    % Path to the annotations file
    pascal3Dfile = fullfile(PASCAL3Ddir,'Annotations',[class '_pascal'],[data(i).voc_image_id '.mat']);
    % If the file exists
    if(exist(pascal3Dfile,'file'))
        % Load the file
        record = load(pascal3Dfile);
        record = record.record;
        % Get bounding box annotations for the current image
        bboxes = vertcat(record.objects(:).bbox);
        % Retain only those bboxes that correspond to the current class
        bboxes(~strcmp(class,{record.objects(:).class}),:) = 0;
        % Get the indices of the bounding box that have more than 90 %
        % overlap with the ground truth bounding box
        objectInd = (bboxOverlap(bbox,bboxes,0.9));
        % Augment data
        if(objectInd)
            % Viewpoint data for the current instance
            viewpoint = record.objects(objectInd).viewpoint;
            
            [rot,euler] = viewpointToRots(viewpoint);
            data3d(i).rotP3d=rot;
            data3d(i).euler=euler;
            data3d(i).subtype = record.objects(objectInd).cad_index;
            data3d(i).subtype = subtypeClusters{cInd}(data3d(i).subtype);
        end
        data3d(i).objectIndP3d = objectInd;
        if(data3d(i).flip)
            data3d(i).euler = data3d(i).euler.*[-1;1;-1];
            rotX = diag([1,-1,-1]);
            data3d(i).rotP3d = rotX*angle2dcm(data3d(i).euler(1), data3d(i).euler(2)-pi/2, -data3d(i).euler(3),'ZXZ')';
        end
    else
        notFound = notFound+1;
        data3d(i).rotP3d = nan(3,3);
        data3d(i).euler = nan(3,1);
        data3d(i).subtype = nan;
        data3d(i).objectIndP3d = nan;
    end
    
end

if(notFound~=0)
    fprintf('PASCAL 3D annotations not found - %d\n',notFound);
end
end



function [R,euler] = viewpointToRots(vp)

euler = [vp.azimuth vp.elevation vp.theta]' .* pi/180;
rotX = diag([1,-1,-1]);
R1 = angle2dcm(euler(3), euler(2)-pi/2, -euler(1),'ZXZ'); %took a lot of work to figure this formula out !!
euler = euler([3 2 1]);
R = rotX*R1';

end



function isSame = bboxOverlap(bbox1,bboxes,thresh)

bboxes(:,3:4) = [bboxes(:,3)-bboxes(:,1) bboxes(:,4)-bboxes(:,2)];
bbox1(3:4) = [bbox1(:,3)-bbox1(:,1) bbox1(:,4)-bbox1(:,2)];
intersectionArea=rectint(bbox1,bboxes);
x_g = bbox1(1); y_g = bbox1(2);
x_p = bboxes(:,1); y_p = bboxes(:,2);
width_g = bbox1(3); height_g = bbox1(4);
width_p = bboxes(:,3); height_p = bboxes(:,4);
unionCoords=[min(x_g,x_p),min(y_g,y_p),max(x_g+width_g-1,x_p+width_p-1),max(y_g+height_g-1,y_p+height_p-1)];
unionArea=(unionCoords(:,3)-unionCoords(:,1)+1).*(unionCoords(:,4)-unionCoords(:,2)+1);
overlapArea=intersectionArea(:)./unionArea(:);
[~,isSame] = max(overlapArea);

end