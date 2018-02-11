function guiTrans(varargin)

% Copyright 2009 The MathWorks, Inc.

    % guiTrans A GUI for animating hydrogen atomic transitions

    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @guiTrans_OpeningFcn, ...
                       'gui_OutputFcn',  @(hObject,eventData,handles)(0), ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    gui_mainfcn(gui_State, varargin{:});
end

% --- Executes just before guiTrans is made visible.
function guiTrans_OpeningFcn(hObject, eventData, handles, varargin) %#ok
    % Load psiList
    handles.psiList = getPsiList();
    
    % List of default simulation parameters
    handles.rabiRatioDefault = 20;
    handles.nFramesDefault = 101;
    handles.rotatingFrameModeDefault = 0;
    handles.thresholdProb = [0.05 0.5];
    
    % Initialise some simulation parameters
    handles.rabiRatio = handles.rabiRatioDefault;
    handles.nFrames = handles.nFramesDefault;
    handles.rotatingFrameMode = handles.rotatingFrameModeDefault;
    
    % Lookup table and states for start/stop toggle button
    handles.startstop_stopped = 1;
    handles.startstop_running = 2;
    handles.startstop_lookup = {'Start';'Stop'};
    guidata(hObject, handles);
    
    % Lookup table and states for electric dipole selection rules.
    handles.electricDipole_valid = 1;
    handles.electricDipole_invalid = 2;
    handles.electricDipole_text_lookup = { ...
                {'This is a valid electric','dipole transition'},...
                {'This is not a valid','electric dipole transition'} };
    handles.electricDipole_color_lookup = { ...
                [ 0.7569, 0.8667, 0.7765 ], ...
                [ 0.9255, 0.8392, 0.8392 ]};
    
    
    % Initialise the state to 'startstop_stopped'
    iStartstop_set(hObject, handles.startstop_stopped);
    
    % Lookup table for possible values of N, listed in the drop-down boxes.
    % Maps (entry number in listbox) -> n
    handles.possibleN = unique([handles.psiList.N]);
    
    % Set initial N value
    handles.N1 = handles.possibleN(1);
    handles.N2 = handles.possibleN(1);
    guidata(hObject, handles);
    
    set(handles.selN1,'String', handles.possibleN );
    set(handles.selN2,'String', handles.possibleN );
    set(handles.selN1,'Value', 1);
    set(handles.selN2,'Value', 1);
    
    % Initialise the mechanism for selection of L and M values.
    handles.L1 = iUpdateLList(handles.selL1,handles.N1, 0);
    handles.L2 = iUpdateLList(handles.selL2,handles.N2, 0);
    handles.M1 = iUpdateMList(handles.selM1,handles.N1, handles.L1, 0);
    handles.M2 = iUpdateMList(handles.selM2,handles.N2, handles.L2, 0);
      
    % Flag to mark the plot's history as discontinuous. This means that the 
    % history traces of views such as the Bloch sphere plot or dipole moment 
    % plot need to be cleared at the next frame draw.
    handles.plotHistoryDiscontinuity = false;
    
    % Initially, the auto-threshold mode is disabled.
    handles.autothreshold = false;
    
    guidata(hObject, handles);
    
    
    iSelectionRuleValidityDisplay(hObject);
    
    iResetAnimation(hObject);
    
    % Set the threshold slider and textbox values.
    iUpdateThresholdInterface(hObject, handles.thresholdProb(1),handles.thresholdProb(2));
end

% Updates the list of possible choices of L.
function newL = iUpdateLList(hObject, N, oldL)
    % hObject is the L dropbox handle
    % N is the new N value
    handles = guidata(hObject);
    
    % List of indices of entries in psiList with N = <selected N>
    iN = ([handles.psiList.N] == N); 
    
    % Create a list of the L values that psiList contains for this selected N.
    possibleL = unique( [handles.psiList(iN).L] );
    
    % Set the listbox's entries to the angular momentum state names
    set(hObject,'String', lookupLNomenclature(possibleL) );
    
    % Choose the current value of L to be the same as the old, if possible,
    % else set it to the first possible value
    newIndex = find(possibleL==oldL);
    
    if isempty(newIndex)
        newIndex = 1;
    end
    
    % Update the list's selected value, and capture the L it represents
    set(hObject,'Value',newIndex);
    newL = possibleL(newIndex);
    
    % Save the array mapping the user's selection to an angular momentum value.
    set(hObject,'UserData',possibleL);
end

% Updates the list of possible choices of M
function newM = iUpdateMList(hObject, N, L, oldM)
    % hObject is the M dropbox handle
    % N,L are the new N,L values
    handles = guidata(hObject);
    
    % Find the list of possible M values for the current N,L.
    iN = ([handles.psiList.N] == N);
    subPsiList = handles.psiList(iN);
    iNM = ([subPsiList.L] == L);
    possibleM = unique( [subPsiList(iNM).M] );
    
    % Set the listbox's entries to the possible angular momentum z-projection
    % values.
    set(hObject,'String', possibleM );
    
    % Choose the current value of M to be the same as the old, if possible,
    % else set it to the first possible value
    newIndex = find(possibleM==oldM);
    
    if isempty(newIndex)
        newIndex = 1;
    end
    
    % Update the list's selected value, and capture the M it represents
    set(hObject,'Value',newIndex);
    newM = possibleM(newIndex);
    
    % Save the array mapping the user's selection to an 'M' value
    set(hObject,'UserData',possibleM);
end

% --- Executes during object creation, after setting all properties, solely
% to set background colour.
function object_CreateFcn(hObject, eventData, handles) %#ok
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% Updates the electric dipole transition valid/invalid label.
function iSelectionRuleValidityDisplay(hObject)
    handles = guidata(hObject);
    
    valid = isElectricDipoleTransition( handles.N1, handles.L1, handles.M1,...
                                        handles.N2, handles.L2, handles.M2 );
    
    if valid
        labelText = ...
            handles.electricDipole_text_lookup{handles.electricDipole_valid};
        labelColor = ...
            handles.electricDipole_color_lookup{handles.electricDipole_valid};
    else
        labelText = ...
            handles.electricDipole_text_lookup{handles.electricDipole_invalid};
         labelColor = ...
            handles.electricDipole_color_lookup{handles.electricDipole_invalid};
    end
    
    set( handles.validElectricDipoleText, 'String', labelText);
    set( handles.validElectricDipoleText, 'BackgroundColor', labelColor);
    
    guidata(hObject, handles);
end

% --- Executes on selection change in selN1.
function selN1_Callback(hObject, eventData, handles) %#ok
    % We know this is a valid choice, as it is picked from handles.possibleN.
    nIndex = get(hObject,'Value');
    handles.N1 = handles.possibleN(nIndex);
    
    % Propagate the changes down the line, by updates the L and then the M
    % list boxes.
    handles.L1 = iUpdateLList(handles.selL1,handles.N1,handles.L1);
    handles.M1 = iUpdateMList(handles.selM1,handles.N1,handles.L1,handles.M1);
    
    guidata(hObject,handles);
    iSelectionRuleValidityDisplay(hObject)
    iResetAnimation(hObject);
end

% --- Executes on selection change in selL1.
function selL1_Callback(hObject, eventData, handles) %#ok
    possibleL = get(hObject,'UserData');
    
    handles.L1 = possibleL(get(hObject,'Value'));
    handles.M1 = iUpdateMList(handles.selM1,handles.N1,handles.L1,handles.M1);
    
    guidata(hObject,handles);
    iSelectionRuleValidityDisplay(hObject)
    iResetAnimation(hObject);
end

% --- Executes on selection change in selM1.
function selM1_Callback(hObject, eventData, handles) %#ok
    possibleM = get(hObject,'UserData');
    
    handles.M1 = possibleM(get(hObject,'Value'));
    
    guidata(hObject,handles);
    iSelectionRuleValidityDisplay(hObject)
    iResetAnimation(hObject);
end

% --- Executes on selection change in selN2.
function selN2_Callback(hObject, eventData, handles) %#ok
    % We know this is a valid choice, as it is picked from handles.possibleN.
    nIndex = get(hObject,'Value');
    handles.N2 = handles.possibleN(nIndex);
    
    % Propagate the changes down the line, by updating the L and then the M
    % list boxes.
    handles.L2 = iUpdateLList(handles.selL2,handles.N2,handles.L2);
    handles.M2 = iUpdateMList(handles.selM2,handles.N2,handles.L2,handles.M2);
    
    guidata(hObject,handles);
    iSelectionRuleValidityDisplay(hObject)    
    iResetAnimation(hObject);
end

% --- Executes on selection change in selL2.
function selL2_Callback(hObject, eventData, handles) %#ok
    possibleL = get(hObject,'UserData');
    
    handles.L2 = possibleL(get(hObject,'Value'));
    handles.M2 = iUpdateMList(handles.selM2,handles.N2,handles.L2,handles.M2);
    
    guidata(hObject,handles);
    iSelectionRuleValidityDisplay(hObject)
    iResetAnimation(hObject);
end

% --- Executes on selection change in selM2.
function selM2_Callback(hObject, eventData, handles) %#ok
    possibleM = get(hObject,'UserData');
    
    handles.M2 = possibleM(get(hObject,'Value'));
    
    guidata(hObject,handles);
    iSelectionRuleValidityDisplay(hObject)
    iResetAnimation(hObject);
end

% --- Executes on button press in startstop.
function startstop_Callback(hObject, eventData, handles) %#ok
    % Toggle state ...
    iStartstop_state = get(hObject,'UserData');
    iStartstop_state = 3-iStartstop_state;
    iStartstop_set(hObject,iStartstop_state);
    
    
    % If the user clicked start...
    if iStartstop_state == handles.startstop_running
        % Disable the time slider, textbox, state select dropbox and options
        % objects
        set(handles.slider,'Enable','Inactive');
        set(handles.simPro,'Enable','Inactive');
        
        set(handles.selN1,'Enable','Inactive');
        set(handles.selL1,'Enable','Inactive');
        set(handles.selM1,'Enable','Inactive');
        set(handles.selN2,'Enable','Inactive');
        set(handles.selL2,'Enable','Inactive');
        set(handles.selM2,'Enable','Inactive');
        
        set(handles.options,'Enable','Inactive');
        
        % Run the transition animation.
        iDisplayAnimation(hObject);
        
        % If the window has been closed, exit.
        if ~ishandle(handles.axes)
            return;
        end
        
        % Once animation has completed, change state to 'stopped'
        iStartstop_set(hObject,handles.startstop_stopped);
    end
    
    % Re-enable the time slider, textbox, state select dropbox and options
    % objects
    set(handles.slider,'Enable','On');
    set(handles.simPro,'Enable','On');
    
    set(handles.selN1,'Enable','On');
    set(handles.selL1,'Enable','On');
    set(handles.selM1,'Enable','On');
    set(handles.selN2,'Enable','On');
    set(handles.selL2,'Enable','On');
    set(handles.selM2,'Enable','On');
    
    set(handles.options,'Enable','On');
end

% Set the state of the start/stop button / animation. 'state' is one of
% handles.startstop_stopped and handles.startstop_running. hObject is a
% handle to any object in the gui.
function iStartstop_set(hObject, state)
    handles = guidata(hObject);
    
    set(handles.startstop,'String',handles.startstop_lookup(state));
    set(handles.startstop,'UserData',state);
end

% Returns the current state of the animation. 'state' is one of 
% handles.startstop_stopped and handles.startstop_running.
function state = iStartstop_state(hObject)
    handles = guidata(hObject);
    
    state = get(handles.startstop,'UserData');
end

% Sets the current simulation time to 't', and updates appropriate gui
% elements to reflect this. hObject is a handle to any object in the gui.
function iCurSimTime_set(hObject,t)
    handles = guidata(hObject);
    
    handles.curSimTime = t;
    
    % Update the slider and the text box displaying the simulation progress.
    set(handles.slider,'Value',t);
    set(handles.simPro,'String',num2str(t));
    
    guidata(hObject,handles);
end

% Executes on simulation progress slider movement, and when the contents of
% the simulation progress textbox is changed.
function simProgress_change_Callback(hObject, eventData, handles) %#ok
    if hObject == handles.simPro
        % If the simulation progress textbox has been changed
        val = str2double(get(hObject,'String'));
        
        % Sanitise input (0<=val<=1)
        if val >=1
            val = 1;
        elseif val <= 0
            val = 0;
        end
    elseif hObject == handles.slider
        % If the simulation progress slider has been changed
        val = get(hObject,'Value');
    else
        error('Callback from unexpected source');
    end
    
    % Set the current time to the selected time
    iCurSimTime_set(hObject,val);
    
    handles = guidata(hObject);
    
    % Mark the plot's history as discontinuous. This means that the history
    % trace of views such as the Bloch sphere plot or dipole moment plot will
    % be deleted at the next frame draw
    handles.plotHistoryDiscontinuity = true;
    
    guidata(hObject,handles);
    
    % And draw the frame (if necessary)
    iUpdateFrame(hObject);
end


% Initialise / load all of the variables needed for animation, and
% completely draw / create necessary graphical components.
function iResetAnimation(hObject)
    handles = guidata(hObject);
    
    % Set startstop state to 'Stop'
    iStartstop_set(hObject,handles.startstop_stopped);
    
    % Reset the animation time
    handles.curSimTime = 0;
    set(handles.slider,'Value',0);
    set(handles.simPro,'String',num2str(0));
    
    % Generate a time vector, one element for each frame of the animation.
    handles.tVec = linspace(0,1,handles.nFrames);
    
    % Find the appropriate wavefunctions chosen by the user.
    [handles.psi1 handles.dim1] = getPsiFromNLM(handles.psiList, ...
                                        handles.N1,handles.L1,handles.M1);
    [handles.psi2 handles.dim2] = getPsiFromNLM(handles.psiList, ...
                                        handles.N2,handles.L2,handles.M2);

    % If psi1 and psi2 need to be resized onto the same grid before animation 
    % starts, set a flag, and just calculate the bounding radius
    % for the first wavefunction, else calculate the transition bounding
    % radius.
    if isequal(handles.dim1,handles.dim2)
        handles.resizeNecessary = false;
        handles.dim = handles.dim1;
        handles.transitionBoundingRadius = findWavefunctionsBoundingRadius(...
            min(handles.thresholdProb), handles.dim, handles.psi1, handles.psi2);
    else
        handles.resizeNecessary = true;
        handles.transitionBoundingRadius = findWavefunctionsBoundingRadius(...
            min(handles.thresholdProb), handles.dim1, handles.psi1);
    end
    
   
    % Plot the initial wavefunction visualisation
    plotPsi( handles.axes, handles.psi1, handles.dim1, ...
                    handles.thresholdProb(1), handles.thresholdProb(2), ...
                    handles.transitionBoundingRadius);
    
    % Enable 3d axes rotation on the main visualisation
    rotate3d(handles.axes,'on');
    axis vis3d
    view(3);
    
    % Plot the initial Bloch sphere visualisation
    blochSpherePlot( handles.axesBlochSphere, 0, 0);
    
    
    % Enable time slider and textbox
    set(handles.slider,'Enable','On');
    set(handles.simPro,'Enable','On');
    
    guidata(hObject,handles);
    
    % If autothresholding is required, /and/ no grid resizing is necessary:
    if handles.autothreshold && ~handles.resizeNecessary
        iAutothresholdWavefunctions(hObject)
    end
end

% Resizes both wavefunctions onto the same grid, suitable for animation. If
% autothreshold is selected, we will execute it.
function iResizeWavefunctions(hObject)
    handles = guidata(hObject);
    
    % If a resize is not marked as necessary
    if ~handles.resizeNecessary
        return
    end
    
    [psi1_2, handles.dim] = resizeWavefunctionGrid(...
                {handles.psi1 handles.psi2}, ...
                {handles.dim1 handles.dim2},...
                length(handles.dim1));

    handles.psi1 = psi1_2{1};
    handles.psi2 = psi1_2{2};
    
    
    xMin = min(handles.dim);
    xMax = max(handles.dim);
    
    axis( handles.axes, [xMin xMax xMin xMax xMin xMax]);
    
    handles.resizeNecessary = 0;
    guidata(hObject,handles);
    
    % Now, do we need to autothreshold?
    if handles.autothreshold
        iAutothresholdWavefunctions(hObject);
    end
end

% iAnimationUpdateCallback is called on every iteration of the animation loop by
% animateTransition, called from iDisplayAnimation. On each iteration, it
% decides whether to stop the animation (by asserting the done flag), and
% updates the graphical elements dependant on the current simulation time.
function done = iAnimationUpdateCallback( hObject, t)
    % Update the current simulation time.
    iCurSimTime_set( hObject, t);
    
    handles = guidata( hObject );
    
    % If the user clicked stop, set the 'done' flag
    if iStartstop_state(hObject) == handles.startstop_stopped 
        done = true;
    else
        done = false;
    end
end

% Display a transition animation. The animation time starts at
% handles.curSimTime, and proceeds until the end of handles.tVec is
% reached, the animation state changed to startstop_stopped, or the 
% animation axes cease to exist.
function iDisplayAnimation(hObject)
    handles = guidata(hObject);
    
    % If the animation finished, and is being run again, reset curSimTime and
    % mark the plot history as discontinuous.
    if handles.curSimTime == handles.tVec(end)
        handles.curSimTime = 0;
        handles.plotHistoryDiscontinuity = true;
        guidata(hObject,handles);
    end
    
    % If iResetAnimation has only used a placeholder wavefunction, and has not
    % resized the initial and final wavefunctions onto the same grid...
    if handles.resizeNecessary
        iResizeWavefunctions(hObject);
        handles = guidata(hObject);
        
        % And update the isosurface bounding radius.
        handles.transitionBoundingRadius = findWavefunctionsBoundingRadius(...
                min(handles.thresholdProb), handles.dim,handles.psi1,handles.psi2);

        guidata(hObject,handles);
    end
    
    % If we need to clear the histories of Bloch sphere view as the system has 
    % been updated in a discontinuous fashion.
    if handles.plotHistoryDiscontinuity
        % Reset the Bloch sphere plot
        blochSpherePlot( handles.axesBlochSphere, 'ClearHistory');    

        handles.plotHistoryDiscontinuity = false;
        guidata(hObject,handles);
    end
    
    % The points in time the animation should be run over.
    tRemainingVec = handles.tVec( handles.tVec >= handles.curSimTime );
    
    % Generate an options structure to be passed to animateTransition
    options.BoundingRadius = handles.transitionBoundingRadius;
    options.Thresholds = handles.thresholdProb;
    options.MainAxes = handles.axes;
    options.BlochSphereAxes = handles.axesBlochSphere;
    options.LoopCallback = @(t)iAnimationUpdateCallback( hObject, t);    
    
    % If 'Rotating Frame' mode is to be enabled
    if handles.rotatingFrameMode
        options.RotatingFrameMode = 'on';
    end
    
    % It is possible for the window to be closed in mid-animation, if this
    % happens an exception will be raised when we try and plot the wavefunction 
    % in animateTransition().
    % Here we arrange to silently catch any exceptions due to the window being
    % closed, and return cleanly.
    try
        animateTransition( tRemainingVec, handles.dim, ...
                    handles.psi1, handles.psi2, options);
    catch err
        if ~ishandle(hObject)
            % If the window has been closed, exit cleanly
            return
        else
            rethrow(err);
        end
    end
end


% Ensures that the frame is redrawn promptly. Called after any settings
% that affect the display are updated. This is used to redraw the plots
% when parameters are changed, but the animation is paused. An example of such
% a situation is when the threshold sliders are moved.
function iUpdateFrame(hObject)
    handles = guidata(hObject);
    
    % If the animation is running, the animation update loop will soon redraw
    % the frame, so we have nothing to do.
    if iStartstop_state(hObject) ~= handles.startstop_stopped 
        return
    end
    
    % If iResetAnimation has only used a placeholder wavefunction, and has not
    % resized the initial and final wavefunctions onto the same grid...
    if handles.resizeNecessary
        iResizeWavefunctions(hObject);
        handles = guidata(hObject);
        
        % And update the isosurface bounding radius.
        handles.transitionBoundingRadius = findWavefunctionsBoundingRadius(...
            min(handles.thresholdProb), handles.dim,handles.psi1,handles.psi2);
    end
    
    % And plot 1 frame (as curSimTime is a scalar) of the animation
    animateTransition( handles.curSimTime, handles.dim, ...
                        handles.psi1, handles.psi2, ...
                        'BoundingRadius', handles.transitionBoundingRadius, ...
                        'Thresholds', handles.thresholdProb, ...
                        'MainAxes', handles.axes, ...
                        'BlochSphereAxes', handles.axesBlochSphere);
end


% Outer threshold slider movement
function threshOuter_Callback(hObject, eventData, handles) %#ok
    newOuterThreshold = get(hObject,'Value');
    
    iUpdateThresholdInterface(hObject,newOuterThreshold,handles.thresholdProb(2));
end

% Inner threshold slider movement
function threshInner_Callback(hObject, eventData, handles) %#ok
    newInnerThreshold = get(hObject,'Value');
    
    iUpdateThresholdInterface(hObject,handles.thresholdProb(1),newInnerThreshold);
end

% Outer threshold textbox change
function threshtextOuter_Callback(hObject, eventData, handles) %#ok
    newOuterThreshold = str2double(get(hObject,'String'));
    
    iUpdateThresholdInterface(hObject,newOuterThreshold,handles.thresholdProb(2));
end

% Inner threshold textbox change
function threshtextInner_Callback(hObject, eventData, handles) %#ok
    newInnerThreshold = str2double(get(hObject,'String'));
    
    iUpdateThresholdInterface(hObject,handles.thresholdProb(1),newInnerThreshold);
end

% Updates the threshold textboxes and sliders with the given values, after
% clipping the given values to the allowable range
function iUpdateThresholdInterface(hObject, thresholdOuter, thresholdInner)
    % Sanitise inputs (0<thresholds<1)
    if thresholdOuter >=1
        thresholdOuter = 0.99;
    elseif thresholdOuter <= 0
        thresholdOuter = 0.01;
    end
    
    if thresholdInner >=1
        thresholdInner = 0.99;
    elseif thresholdInner <= 0
        thresholdInner = 0.01;
    end
    
    handles = guidata(hObject);
    handles.thresholdProb(1) = thresholdOuter;
    handles.thresholdProb(2) = thresholdInner;
    
    
    % Update threshold textboxes
    set(handles.threshtextOuter,'String',num2str(thresholdOuter));
    set(handles.threshtextInner,'String',num2str(thresholdInner));
    
    % Update threshold sliders
    set(handles.threshOuter,'Value',thresholdOuter);
    set(handles.threshInner,'Value',thresholdInner);
    
    % Update the isosurface bounding radius:
    handles.transitionBoundingRadius = findWavefunctionsBoundingRadius(...
            min(handles.thresholdProb), handles.dim,handles.psi1,handles.psi2);
    guidata(hObject,handles);
    
    % And (ensure) redraw:
    iUpdateFrame(hObject);
end

% Executes on select / deselect of Auto-threshold tickbox
function autothresh_Callback(hObject, eventData, handles) %#ok
    % When the autothreshold variable is true, we will automatically set the
    % threshold any time the wavefunction pair is changed. However, we cannot
    % do this until the wavefunctions are resized onto identical grids (which
    % is not until the user has finished selecting the wavefunctions, and
    % clicked on 'start'). Thus, in most cases, the actual autothreshold
    % function is called just after we have resized, by iResizeWavefunctions()
    
    handles.autothreshold = get(hObject,'Value');
    
    % Disable / enable the manual threshold sliders & textboxes
    if handles.autothreshold
        enableState = 'Inactive';
    else
        enableState = 'On';
    end
    
    set(handles.threshOuter,'Enable',enableState);
    set(handles.threshtextOuter,'Enable',enableState);
    set(handles.threshInner,'Enable',enableState);
    set(handles.threshtextInner,'Enable',enableState);
    
    guidata(hObject, handles);
    
    % If a resize is not necessary, and autothreshold has just been selected
    if handles.autothreshold && ~handles.resizeNecessary
        iAutothresholdWavefunctions(hObject);
    end
end

% Automatically sets the probability threshold for the wavefunction 
% visulisation, and then updates the plot.
function iAutothresholdWavefunctions(hObject)
    handles = guidata(hObject);
    % If iResetAnimation has only used a placeholder wavefunction, and has not
    % resized the initial and final wavefunctions onto the same grid yet...
    if handles.resizeNecessary
        iResizeWavefunctions(hObject);
        handles = guidata(hObject);
    end
    
    thresholds_1 = autoThreshold( handles.psi1 );
    thresholds_2 = autoThreshold( handles.psi2 );
    
    thresholdOuter = min(thresholds_1(1), thresholds_2(1));
    thresholdInner = max(thresholds_1(2), thresholds_2(2));
    
    iUpdateThresholdInterface(hObject, thresholdOuter, thresholdInner);
end

% Opens the options dialog. This can only happen when the animation is not
% running (as the button is grayed out in this case). 
function options_Callback(hObject, eventData, handles) %#ok
    % If 'changed' is true, the options dialog changed some parameters in our
    % 'handles'
    changed = options(handles.figure1);
    
    if changed
        % The parameters have changed, so start from a clean slate
        iResetAnimation(hObject);
    end
end
