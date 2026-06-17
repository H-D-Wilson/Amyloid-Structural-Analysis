function [mapfv, map_x, map_y, map_z, R] = AlignToZAxis(mapfv, map_x, map_y, map_z)
% AlignToZAxis - Standardises and automates the axial positioning of fibrils.
% Optimises the legacy Trace_y manual framework by algorithmically aligning the 
% primary fibril axis to the global Z-axis. This workflow eliminates 
% user-to-user variability and enforces pipeline uniformity before downstream analysis.
%
% Methodology: Implements a 3D linear translation to the centroid, followed by 
% a Rodrigues' rotation matrix optimisation based on calculated fibril endpoints.

    % --- Extract vertices ---
    V = mapfv.vertices;

    % --- Center vertices ---
    Vmean = mean(V, 1);
    V0 = V - Vmean;

    % =========================================================
    % Estimate fibril axis via terminal endpoint averaging
    % =========================================================
    zmin = min(V0(:,3));
    zmax = max(V0(:,3));

    % Average spatial points near each terminal boundary to define the core axis
    endWidth = 5;   

    end1 = mean(V0(V0(:,3) < zmin + endWidth, :), 1);
    end2 = mean(V0(V0(:,3) > zmax - endWidth, :), 1);

    mainAxis = (end2 - end1)';
    mainAxis = mainAxis / norm(mainAxis);

    target = [0; 0; 1];

    % =========================================================
    % Compute rotation matrix using Rodrigues formula
    % =========================================================
    v = cross(mainAxis, target);
    s = norm(v);
    c = dot(mainAxis, target);

    if s < 1e-8
        % Vectors are already parallel or anti-parallel
        if c > 0
            R = eye(3);   
        else
            % Apply 180-degree rotation about the x-axis
            R = [1 0 0;
                 0 -1 0;
                 0 0 -1];
        end
    else
        % Cross-product skew-symmetric matrix configuration
        vx = [  0    -v(3)  v(2);
               v(3)   0    -v(1);
              -v(2)  v(1)   0   ];

        R = eye(3) + vx + vx^2 * ((1 - c) / s^2);
    end

    % =========================================================
    % Transform vertices to new unified coordinate system
    % =========================================================
    V_rot = (R * V0')';
    mapfv.vertices = V_rot + Vmean;

    % =========================================================
    % Rotate and reconstruct coordinate grids
    % =========================================================
    sz = size(map_x);

    coords = [map_x(:), map_y(:), map_z(:)];
    coords0 = coords - Vmean;

    coords_rot = (R * coords0')' + Vmean;

    map_x = reshape(coords_rot(:,1), sz);
    map_y = reshape(coords_rot(:,2), sz);
    map_z = reshape(coords_rot(:,3), sz);

    % =========================================================
    % Track and log alignment metric
    % =========================================================
    angle = acosd(max(min(c,1),-1));
    fprintf('Alignment angle successfully resolved: %.3f degrees\n', angle);

end
