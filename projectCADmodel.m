% project the 3D points to generate 2D points according to the viewpoint
function x3d = projectCADmodel(x3d, object)

if isfield(object, 'viewpoint') == 1
    % project the 3D points
    viewpoint = object.viewpoint;
    a = viewpoint.azimuth*pi/180;
    e = viewpoint.elevation*pi/180;
    d = viewpoint.distance;
    f = viewpoint.focal;
    theta = viewpoint.theta*pi/180;
    principal = [viewpoint.px viewpoint.py];
    viewport = viewpoint.viewport;
else
    x3d = [];
    return;
end

if d == 0
    x3d = [];
    return;
end

% camera center
C = zeros(3,1);
C(1) = d*cos(e)*sin(a);
C(2) = -d*cos(e)*cos(a);
C(3) = d*sin(e);

% Rotate coordinate system by theta is equal to rotating the model by -theta.
a = -a;
e = -(pi/2-e);

% rotation matrix
Rz = [cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1];   %rotate by a
Rx = [1 0 0; 0 cos(e) -sin(e); 0 sin(e) cos(e)];   %rotate by e
R = Rx*Rz;

% perspective project matrix
% however, we set the viewport to 3000, which makes the camera similar to
% an affine-camera. Exploring a real perspective camera can be a future work.
M = viewport;
P = [M*f 0 0; 0 M*f 0; 0 0 -1] * [R -R*C];

% project
x3d = P*[x3d ones(size(x3d,1), 1)]';
x3d(1,:) = x3d(1,:) ./ x3d(3,:);
x3d(2,:) = x3d(2,:) ./ x3d(3,:);
x3d = x3d(1:2,:);

% rotation matrix 2D
R2d = [cos(theta) -sin(theta); sin(theta) cos(theta)];
x3d = (R2d * x3d)';
% x = x';

% transform to image coordinates
x3d(:,2) = -1 * x3d(:,2);
x3d = x3d + repmat(principal, size(x3d,1), 1);

end