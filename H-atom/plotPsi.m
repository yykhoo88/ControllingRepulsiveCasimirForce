function plotPsi(varargin)
% plotPsi Displays a 3d plot of a wavefunction
%   plotPsi plots a representation of a wavefunction by drawing an inner and an 
%   outer semi-transparent isosurface.
%
%   Syntax :
%
%     ax = plotPsi( psi, dim)
%       Plots the wavefunction psi to the current axes. psi is an NxNxN array
%       containing the wavefunction. dim is an N element vector mapping the 
%       (i,j,k) element of psi to a point in space [dim(i), dim(j), dim(k)].
%       The inner and outer probability isosurfaces are chosen automatically.
%       The returned value is the handle to the axes plotted to.
%
%     ax = plotPsi( psi, dim, thresholdOuter, thresholdInner)
%       Plots the wavefunction in the same fashion as plotPsi( psi, dim), but 
%       draws the isosurfaces at the specified levels. thresholdInner and 
%       thresholdOuter are the inner and outer probability isosurface values, 
%       expressed as a fraction of the peak probability density. 
%
%     ax = plotPsi( psi, dim, thresholdOuter, thresholdInner, rBounding)
%       Plots the wavefunction in the same fashion as 
%       plotPsi( psi, dim, thresholdOuter, thresholdInner), but sets the axis 
%       limits to +/- rBounding.
%
%     ax = plotPsi( ax, ...)
%       All of the preceeding calling patterns can be modified to plot to a 
%       specified set of axes by adding an axes handle to the start of the 
%       argument list. If axes are specified then the 'view' is not changed.
%       If axes are not specified, the default 3d view is set.

% Copyright 2009 The MathWorks, Inc.

%   Parse the input arguments

% If the first argument is an axis handle
if ishandle( varargin{1} )
    % Capture the handle and remove it from the argument list.
    ax = varargin{1};
    remainingArgs = {varargin{2:end}};

    axesSpecified = true;
 else
    % We will use the current axes
    ax = gca;
    remainingArgs = varargin;

    axesSpecified = false;
end


% Ensure the correct number of arguments, noting that we will have already
% removed the axis handle from remainingArgs, if a valid axis handle was the 
% first argument.
if ~any( length(remainingArgs) == [2 4 5] )
    error('Wavefunction:invalidArgument', 'Incorrect number of arguments');
end


% The first 2 remaining arguments are always psi and dim.
psi = remainingArgs{1};
dim = remainingArgs{2};

% Are they self consistent
if ~isequal( size(psi), length(dim)*[1 1 1])
    error('Wavefunction:invalidArgument', ...
        ['psi must be on a cubic grid described by dim, but there is'...
        ' a mismatch between the size of psi and the length of dim']);
end


% If the isosurface thresholds were specified
if length(remainingArgs) > 2
    thresholdOuter = remainingArgs{3};
    thresholdInner = remainingArgs{4};
   
    % Ensure that the thresholds are reasonable
    if thresholdInner <= thresholdOuter
    error('Wavefunction:invalidArgument', ...
        ['The outer (probability) isosurface threshold must be ' ...
        'smaller than the inner threshold']);
    end
else
    % Otherwise calculate them automatically
    thresholdArray = autoThreshold( psi );
    
    thresholdOuter = thresholdArray(1);
    thresholdInner = thresholdArray(2);
end


% If the bounding radius was specified
if length(remainingArgs) > 4
    rBounding = remainingArgs{5};
else
    % Otherwise we set the rBounding to zero, to signify that we will not
    % explicitly set the axis limits.
    rBounding = 0;
end



%   Now that we definitely have sensible arguments, we can begin plotting.


% Calculate the probability density from the wavefunction.
dx = dim(2)-dim(1);
prob = conj(psi).*psi * dx^3;

% Calculate the peak probability density value of the wavefunction, so that we
% can calculate the absolute isosurface values.
maxProb = max( prob(:) );
absoluteThresholdInner = maxProb*thresholdInner;
absoluteThresholdOuter = maxProb*thresholdOuter;



% Ensure we start with a clean set of axes.
cla(ax);


% Calculate the probability isosurfaces
fv1 = isosurface(prob,absoluteThresholdOuter);
fv2 = isosurface(prob,absoluteThresholdInner);

% Scale the generated surfaces onto the axes. This is much faster than
% calling isosurface with X,Y,Z, as we are taking advantage of the fact
% that dim is linearly spaced.
minXDim = min(dim);

fv1.vertices = (fv1.vertices-1)*dx+minXDim;
fv2.vertices = (fv2.vertices-1)*dx+minXDim;


%	Set our axes as the current axes
% First, find the parent figure handle.
h = ancestor(ax,'Figure');

% Then set it as the current figure
set(0,'CurrentFigure',h);

% And set that figure's current axes
set(h,'CurrentAxes',ax);


% Draw the patches depicting our isosurfaces to the current axes.
patch(fv1,'FaceColor','red','EdgeColor','none');
patch(fv2,'FaceColor','blue','EdgeColor','none');


% If we are required to set the axis limits
if rBounding ~= 0
    axis(rBounding*[-1 1 -1 1 -1 1]);
end


% Set the relative scaling (aspect ration) of the x,y,z axes.
daspect([1 1 1]);

grid('on');

% Add lighting to the scene, to bring out the surface details
camlight; 

% Set the lighting algorithm. 'Gouraud' gives reasonable results, and is not too
% slow.
lighting('gouraud');

% Ensure that we use hardware acceleration, if available, to plot.
set(gcf,'Renderer','OpenGL');

% Set the transparency of all surface objects belonging to the axes to a 
% reasonable value.
alpha(0.6);

% If the axes are not specified (so we are using the current axes), set the
% view of the plot to the default for 3d viewing.
if ~axesSpecified
    view(3);
end
