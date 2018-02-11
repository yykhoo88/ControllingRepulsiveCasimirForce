function varargout = options(varargin)
    % OPTIONS M-file for options.fig
    %      options(mainFigureHandle) opens a window to edit certain parameters
    %      in the handles belonging to the main figure. The boolean return
    %      value is true if any parameters were changed, otherwise false.
    %
    %      The parameters that can be changed are:
    %       * handles.rabiRatio
    %       * handles.nFrames
    %
    %      The default values for these parameters are retrieved from:
    %       * handles.rabiRatioDefault
    %       * handles.nFramesDefault

    % Last Modified by GUIDE v2.5 06-Oct-2009 11:27:15

    % Copyright 2009 The MathWorks, Inc.
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @options_OpeningFcn, ...
                       'gui_OutputFcn',  @options_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end
% End initialization code - DO NOT EDIT

% --- Executes just before options is made visible.
function options_OpeningFcn(hObject, eventData, handles, varargin) %#ok
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to options (see VARARGIN)

    if length(varargin) ~= 1 || ~ishandle(varargin{1})
        error('Invalid arguments');
    end

    handles.mainWindowHandle = varargin{1};
    parentHandles = guidata(handles.mainWindowHandle);

    handles.parametersChanged = false;


    set(handles.rabiRatio, 'String', num2str(parentHandles.rabiRatio));
    set(handles.nFrames, 'String', num2str(parentHandles.nFrames));
    set(handles.rotatingFrameBlochSphere, 'Value', parentHandles.rotatingFrameMode);

    % Choose default command line output for options
    handles.output = handles.parametersChanged;


    % Update handles structure
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = options_OutputFcn(hObject, eventData, handles) %#ok
    % Wait for the figure to signal it has finished execution.
    uiwait(handles.figure1);

    % If the user closed the window, we do nothing
    if ~ishandle(handles.figure1)
        varargout{1} = false;
        return;
    end    

    % Update handles
    handles = guidata(hObject);

    % If any parameters have changed
    if handles.parametersChanged
        parentHandles = guidata(handles.mainWindowHandle);

        rabiRatio = str2double(get(handles.rabiRatio,'String'));
        nFrames = round(str2double(get(handles.nFrames,'String')));
        rotatingFrameMode = get(handles.rotatingFrameBlochSphere, 'Value'); 
        
        parentHandles.rabiRatio = rabiRatio;
        parentHandles.nFrames = nFrames;
        parentHandles.rotatingFrameMode = rotatingFrameMode;

        guidata(handles.mainWindowHandle, parentHandles);
    end

    % Return true if any parameters have changed
    varargout{1} = handles.parametersChanged;

    % And close window
    delete(handles.figure1);
end

% Validate and mark as changed the new value of rabiRatio
function rabiRatio_Callback(hObject, eventData, handles) %#ok
    rabiRatio = str2double(get(handles.rabiRatio,'String'));

    % Ensure rabiRatio is positive definite.
    if rabiRatio <= 0 
        rabiRatio = 1;  
    end 

    set(handles.rabiRatio,'String',num2str(rabiRatio));

    handles.parametersChanged = true;
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function rabiRatio_CreateFcn(hObject, eventData, handles) %#ok
    % hObject    handle to rabiRatio (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% Validate and mark as changed the new value of nFrames
function nFrames_Callback(hObject, eventData, handles) %#ok
    nFrames = round( str2double(get(handles.nFrames,'String')) );

    % Ensure nFrames is >= 2.
    if nFrames < 2 
        nFrames = 2;  
    end 

    set(handles.nFrames,'String',num2str(nFrames));

    handles.parametersChanged = true;
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function nFrames_CreateFcn(hObject, eventData, handles) %#ok
    % hObject    handle to nFrames (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% Close window. If any changes have been made, they will be saved by the
% output function, triggered by uiresume.
function optSet_Callback( hObject, eventData, handles) %#ok
    uiresume(handles.figure1);
end

% Set all of the parameters to the default values
function defaults_Callback(hObject, eventData, handles) %#ok
    parentHandles = guidata(handles.mainWindowHandle);

    set(handles.rabiRatio, 'String', num2str(parentHandles.rabiRatioDefault));
    set(handles.nFrames, 'String', num2str(parentHandles.nFramesDefault));
    set(handles.rotatingFrameBlochSphere, 'Value', parentHandles.rotatingFrameModeDefault);
    
    handles.parametersChanged = true;
    guidata(hObject, handles);
end

% Close window without saving changes.
function optsCancel_Callback( hObject, eventData, handles) %#ok
    handles.parametersChanged = false;
    uiresume(handles.figure1);
end


% Set / clear the 'Rotating Frame' Bloch sphere display mode.
function rotatingFrameBlochSphere_Callback(hObject, eventdata, handles) %#ok
    handles.parametersChanged = true; 
    guidata(hObject, handles);
end