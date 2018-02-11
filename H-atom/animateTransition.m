function animateTransition(tVec, dim, psi1, psi2, varargin)
% animateTransition Displays an animation of a state transition
%   animateTransition animates the transition between two states, psi1 and psi2,
%   on a common grid, dim. The animation is displayed by sequencially evaluating
%   the current state at the times given by the elements of tVec. t = 0
%   represents the initial state (psi1) and t = 1 represents the final state
%   (psi2). Additional parameters are set by passing in property-value pairs.
%
%   Note that if the figure displaying the animation is closed during the
%   animation, various errors will be raised (depending on where in the
%   animation cycle the figure is closed). To cleanly handle this, one should
%   wrap the call to animateTransition in a try-catch loop, and catch and ignore
%   any errors that occur if ishghandle() returns false for the figure's handle.
%
%   (Optional) Properties :
%
%     MainAxes
%       An axes handle to plot the wavefunction visualisation to. If this
%       property is not set, the current axes are used.
%
%     BlochSphereAxes
%       An axes handle to plot the Bloch sphere visualisation to. If this
%       property is not set, this visualisation is not generated.
%
%     RotatingFrameMode
%       Either 'on' or 'off'. Enable / disable the rotating frame display of the
%       Bloch sphere. In this picture, the rotation around the sphere is 
%       cancelled out, leaving the state vector to move from 'north' to 'south'
%       as the transition progresses. By default, this is set to 'off'.
%
%     RabiRatio
%       The Rabi ratio parameter used to calculate the transitional state.
%       If this parameter is not set, the default value of 20 is used.
%       For more information see calculateTransitionalState.
%
%     LoopCallback
%       A function handle to call before every pass of the animation loop. The
%       function should take one parameter, the current simulation time, and
%       return a boolean variable, which, if true, causes the animation to exit.
%
%     Thresholds
%       A vector of two elements, the first element of which is the
%       outer isosurface value, the second element being the inner isosurface
%       value. The inner and outer isosurface values are expressed as a fraction
%       of the wavefunction's peak probability density. If this parameter is
%       not set, the thresholds are automatically chosen.
%
%     InterFrameSleep
%       The time to sleep between frames, in seconds. If this parameter is not
%       set, the default value of 0 (as fast as possible) is used.
%
%     BoundingRadius
%       Sets the main plot's axis bounds to +/- BoundingRadius. For more
%       information see plotPsi.
%
%   Example :
%
%     To animate the transition between two wavefunctions, psi1 and psi2, in
%     100 frames, plotting the initial and final states, and the Bloch sphere
%     projection :
%       figure;
%       plotPsi( psi1, dim);
%       figure;
%       plotPsi( psi2, dim);
%       figure;
%       axBloch = axes();
%       figure;
%       animateTransition( linspace(0,1,100), dim, psi1, psi2, ...
%                                   'BlochSphereAxes', axBloch);

% Copyright 2009 The MathWorks, Inc.

%   Parse the input arguments

% The default parameters
defaultRabiRatio = 20;
defaultInterFrameSleep = 0;

% The (constant) value the Bloch sphere's phi is set to when the rotating frame
% mode is selected.
phiRotatingFrameModeConstant = -pi/5;


% Setup and use an inputParser
p = inputParser;
p.FunctionName = 'animateTransition';

% The axes handles must be Handle Graphics objects. We use the current axes
% if none are provided.
p.addParamValue('MainAxes', gca, @ishghandle );
p.addParamValue('BlochSphereAxes', [], @ishghandle );

% The rotating frame mode flag must be either 'on' or 'off'
p.addParamValue('RotatingFrameMode', 'off', ...
                        @(str)( ischar(str) && any(strcmp( str, {'on', 'off'})) )  );

% The Rabi ratio must be a float.
p.addParamValue('RabiRatio', defaultRabiRatio, @isfloat );

% The loop callback must be a function handle.
p.addParamValue('LoopCallback', [], @(h)isa(h, 'function_handle') );

% The thresholds must be a float vector of length 2.
p.addParamValue('Thresholds', [], @(x)( isfloat(x) && length(x)==2 ) );

% The inter-frame sleep time must be a float that is non-negative.
p.addParamValue('InterFrameSleep', defaultInterFrameSleep, ...
                                            @(x)( isfloat(x) && x>=0 ) );

% The bounding radius must be a float that is greater than zero.
p.addParamValue('BoundingRadius', [], @(x)( isfloat(x) && x > 0) );


p.parse( varargin{:} );


% Create a structure, usingDefaults, with each field representing a parameter
% name as found in inputParser.Results, with each field having a boolean value
% representing whether the default argument is being used. E.g. for the optional
% parameter BlochSphereAxes, usingDefaults.BlochSphereAxes is true is the user
% did not specify this parameter, and we are using the default.
usingDefaults = struct();

fields = fieldnames(p.Results);
for i = 1:numel(fields)
    usingDefaults.( fields{i} ) = any( strcmp( fields{i}, p.UsingDefaults) );
end



%   Ensure the input arguments are reasonable sane

% Are the wavefunctions self consistent
inferredGridSize = length(dim)*[1 1 1];
if ~isequal( size(psi1), inferredGridSize ) || ...
   ~isequal( size(psi2), inferredGridSize )
    error('Wavefunction:invalidArgument', ...
        ['psi1 and psi2 must be on a cubic grid described by dim, but there '...
            'is a mismatch between the size of the wavefunction(s) and the '...
            'length of dim']);
end




%   Now start setting up for the animation.


% Choose the thresholds, if the user did not provide them.
if usingDefaults.Thresholds
    thresholds_1 = autoThreshold( psi1 );
    thresholds_2 = autoThreshold( psi2 );

    thresholds(1) = min(thresholds_1(1), thresholds_2(1));
    thresholds(2) = max(thresholds_1(2), thresholds_2(2)); 
else
    % Use the provided thresholds
    thresholds = p.Results.Thresholds;
end


% Set the bounding radius, if the user did not specify it
if usingDefaults.BoundingRadius
    boundingRadius = ...
             findWavefunctionsBoundingRadius( min(thresholds), dim, psi1, psi2);
else
    boundingRadius = p.Results.BoundingRadius;
end


% If the user did not specify axes, set the axes view to something sensible.
if usingDefaults.MainAxes
    view( p.Results.MainAxes, 3);
end



% Calculate the initial state
[psiInit, thetaInit, phiInit] = ...
      calculateTransitionalState(psi1, psi2, tVec(1), p.Results.RabiRatio); 

% If required (axes parameter passed in), draw the initial Bloch Sphere plot
if ~usingDefaults.BlochSphereAxes
    % If rotating wave mode is on, set phi to a constant value
    if strcmp( p.Results.RotatingFrameMode, 'on')
        phiInit = phiRotatingFrameModeConstant;
    end
    
    blochSpherePlot( p.Results.BlochSphereAxes, thetaInit, phiInit);
end


%   Now run the animation.
 
% For all elements of tVec
for t = tVec   

    % If a loop callback has been requested
    if ~usingDefaults.LoopCallback
        done = feval( p.Results.LoopCallback, t );
        if done 
            return;
        end
    end
    
    [psi, theta, phi] = calculateTransitionalState(psi1, psi2, t, ...
                                                        p.Results.RabiRatio);   
    
    % Plot the wavefunction visualisation
    plotPsi( p.Results.MainAxes, psi, dim, ...
                        thresholds(1), thresholds(2), boundingRadius);
    
    
    % Plot the Bloch sphere visualisation, if required.
    if ~usingDefaults.BlochSphereAxes
        % If rotating wave mode is on, set phi to a constant value
        if strcmp( p.Results.RotatingFrameMode, 'on')
            phi = phiRotatingFrameModeConstant;
        end
        
        blochSpherePlot( p.Results.BlochSphereAxes, theta, phi, 'replot');
    end

    % Force a redraw
    drawnow
    
    % Sleep for the required time
    pause( p.Results.InterFrameSleep );
end









