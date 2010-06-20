function varargout = trEPR_GUI_info(varargin)
% TREPR_GUI_INFO M-file for trEPR_GUI_info.fig
%      TREPR_GUI_INFO, by itself, creates a new TREPR_GUI_INFO or raises the existing
%      singleton*.
%
%      H = TREPR_GUI_INFO returns the handle to a new TREPR_GUI_INFO or the handle to
%      the existing singleton*.
%
%      TREPR_GUI_INFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREPR_GUI_INFO.M with the given input arguments.
%
%      TREPR_GUI_INFO('Property','Value',...) creates a new TREPR_GUI_INFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trEPR_GUI_info_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trEPR_GUI_info_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_info

% Last Modified by GUIDE v2.5 19-Jun-2010 12:30:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trEPR_GUI_info_OpeningFcn, ...
                   'gui_OutputFcn',  @trEPR_GUI_info_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before trEPR_GUI_info is made visible.
function trEPR_GUI_info_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trEPR_GUI_info (see VARARGIN)

% Choose default command line output for trEPR_GUI_info
handles.output = hObject;

% set window title
set(hObject,'Name','trEPR toolbox : Information about spectrum');

% Add the name of the current mfile to the handles structure
% Used e.g. in the closeGUI function to conveniently determine whether it
% is called from within this function (see there for details).
handles.mfilename = mfilename;

% register function handle for closing function
set(handles.figure1,'CloseRequestFcn',@closeGUI);

% Add command line arguments to the handles structure assuming that these
% are property value pairs. Used to get callerFunction and callerHandle.
if iscell(varargin)
    for k=2 : 2 : length(varargin)
        handles = setfield(handles,varargin{k-1},varargin{k});
    end
end

% Set application data (at this stage only empty structures)
data = cell(1); % store the data (spectra) together with their information
configuration = struct(); % store the configuration information for the GUI
% --- store important control values, such as the currently active spectrum etc.
control = struct(...
    'dsc', struct(...
    'fileName','',...
    'fileType',''...
    )...
);
appdataHandles = struct();

setappdata(handles.figure1,'data',data);
setappdata(handles.figure1,'configuration',configuration);
setappdata(handles.figure1,'control',control);
setappdata(handles.figure1,'handles',appdataHandles);

% add handle of this GUI to handles structure of the calling gui in case
% this function has been called from another GUI
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
    callerHandles = guidata(handles.callerHandle);
    callerHandles = setfield(...
        callerHandles,...
        mfilename,...
        handles.figure1);
    guidata(handles.callerHandle,callerHandles);
end

% Get appdata from parent window
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')    
    callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)        

        % Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);
        
        data = parentAppdata.data;
        setappdata(handles.figure1,'data',data);
        setappdata(handles.figure1,'configuration',configuration);
        setappdata(handles.figure1,'handles',handles);
    end
    guidata(handles.callerHandle,callerHandles);
end

% Display Information of currently active spectrum on opening
if exist('data','var') && ~isempty(data{1})
    if isfield(handles,'Spectra')
        % Get names of spectra for selection popupmenu
        for k=1:length(handles.Spectra)
            [path name ext] = fileparts(...
                data{handles.Spectra{k}}.filename...
                );
            namesOfSpectra{k} = sprintf('%s%s',name,ext);
        end
        set(handles.multipleFilesPopupmenu,'String',namesOfSpectra);
        % Set current active spectrum to the first in the list
        handles.Spectrum = handles.Spectra{1};
    else
        % Set number of spectrum to display information for in case it is
        % not called with the optional parameter
        if ~isfield(handles,'Spectrum')
            handles.Spectrum = parentAppdata.control.spectra.active;
        end
        % Set selection popupmenu
        [path name ext] = fileparts(...
            data{handles.Spectrum}.filename...
            );
        set(handles.multipleFilesPopupmenu,'String',...
            sprintf('%s%s',name,ext)...
            );
    end

    if_refreshFields(hObject, eventdata, handles);
    
    guidata(handles.callerHandle,callerHandles);
end

% Update handles structure
guidata(hObject, handles);

handles.hash = if_makeHash(hObject);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trEPR_GUI_info wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trEPR_GUI_info_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function headerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to headerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of headerEdit as text
%        str2double(get(hObject,'String')) returns contents of headerEdit as a double


% --- Executes during object creation, after setting all properties.
function headerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to headerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closePushbutton.
function closePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to closePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%close;
closeGUI(hObject, eventdata, handles);


function dscFilenameEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.dscFilenameEdit,'String')) || ...
    ~exist(get(handles.dscFilenameEdit,'String'),'file')
    set(handles.dscFileShowButton,'Enable','Off');
    set(handles.dscFileLoadButton,'Enable','Off');
else
    appdata.control.dsc.fileName = get(handles.dscFilenameEdit,'String');
    set(handles.dscFileShowButton,'Enable','On');
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end


% --- Executes during object creation, after setting all properties.
function dscFilenameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dscFilenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function microwaveAttenuationEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.microwaveAttenuationEdit,'String'))
    set(...
    	handles.microwaveAttenuationEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.bridge.attenuation = [];
else
    set(...
    	handles.microwaveAttenuationEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.bridge.attenuation = ...
        str2double(get(handles.microwaveAttenuationEdit,'String'));
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function microwaveAttenuationEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to microwaveAttenuationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function microwaveFrequencyEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.microwaveFrequencyEdit,'String'))
    set(...
    	handles.microwaveFrequencyEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.bridge.MWfrequency = [];
else
    set(...
    	handles.microwaveFrequencyEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.bridge.MWfrequency = ...
        str2double(get(handles.microwaveFrequencyEdit,'String'));
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function microwaveFrequencyEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to microwaveFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function temperatureEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.temperatureEdit,'String'))
    set(...
    	handles.temperatureEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.temperature = [];
else
    set(...
    	handles.temperatureEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.temperature = ...
        str2double(get(handles.temperatureEdit,'String'));
end
% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function temperatureEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to temperatureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function laserRepetitionRateEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.laserRepetitionRateEdit,'String'))
    set(...
    	handles.laserRepetitionRateEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.laser.repetitionRate = [];
else
    set(...
    	handles.laserRepetitionRateEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.laser.repetitionRate = ...
        str2double(get(handles.laserRepetitionRateEdit,'String'));
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function laserRepetitionRateEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserRepetitionRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function laserWavelengthEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.laserWavelengthEdit,'String'))
    set(...
    	handles.laserWavelengthEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.laser.wavelength = [];
else
    set(...
    	handles.laserWavelengthEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.laser.wavelength = ...
        str2double(get(handles.laserWavelengthEdit,'String'));
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function laserWavelengthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to laserWavelengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addParamApplyButton.
function addParamApplyButton_Callback(hObject, eventdata, handles)

if_parentAppdataRefresh(hObject);


% --------------------------------------------------------------------
function closeGUI(varargin)
% hObject    handle to hideAllDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handle variable input arguments, because the 'CloseRequestFcn' does not
% accept to get additional parameters passed by the function call
if nargin == 3
    hObject = varargin{1};
    eventdata = varargin{2};
    handles = varargin{3};
else
    handles = guidata(gcbo);
end

if if_checkForNecessaryFields(handles.figure1)
    selection = questdlg(...
        sprintf('%s %s\n - %s\n - %s\n\n%s',...
        'There are empty, but necessary fields left in the GUI.',...
        'Do you want to',...
        'cancel the closing of the GUI and further edit, or ',...
        'close anyway (what can cause errors later)?',...
        'In any case you can later on edit these parameters again.'),...
        'Empty, but necessary fields exist. Really quit?',...
        'Cancel',...
        'Close',...
        'Cancel');

    switch selection,
        case 'Cancel',
            return;
        otherwise
            % Add spectrum to parentAppdata.control.spectra.missing in case
            % it is not already listed there
            % Get appdata from parent window
            if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
                callerHandles = guidata(handles.callerHandle);
                if isfield(callerHandles,mfilename)
                	% Get appdata of the parent GUI
                    parentAppdata = getappdata(callerHandles.figure1);
                    if isempty(ind(parentAppdata.control.spectra.missing,handles.Spectrum))
                        parentAppdata.control.spectra.missing{end+1} = handles.Spectrum;
                        setappdata(...
                            callerHandles.figure1,...
                            'control',...
                            parentAppdata.control);
                    end
                end
                % Switch on button to complete these parameters
                set(...
                    callerHandles.spectraCompleteParametersButton,...
                    'Enable','On');
            end    
    end
else
    % Remove spectrum from parentAppdata.control.spectra.missing in case it
    % was listed there
    % Get appdata from parent window
    if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
        callerHandles = guidata(handles.callerHandle);
        if isfield(callerHandles,mfilename)
        	% Get appdata of the parent GUI
            parentAppdata = getappdata(callerHandles.figure1);
            if ind(parentAppdata.control.spectra.missing,handles.Spectrum)
                parentAppdata.control.spectra.missing(...
                    ind(parentAppdata.control.spectra.missing,handles.Spectrum)) = [];
                setappdata(...
                    callerHandles.figure1,...
                    'control',...
                    parentAppdata.control);
            end
        end
        % If there are no spectra any more with missing parameters, switch
        % button to complete these parameters to off.
        if isempty(parentAppdata.control.spectra.missing)
            set(...
                callerHandles.spectraCompleteParametersButton,...
                'Enable','Off');
        end
    end
end

if ~strcmp(handles.hash,if_makeHash(handles.figure1))
    % Add id of spectrum to parentAppdata.control.spectra.modified
    % Get appdata from parent window
    if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
        callerHandles = guidata(handles.callerHandle);
        if isfield(callerHandles,mfilename)
        	% Get appdata of the parent GUI
            parentAppdata = getappdata(callerHandles.figure1);
            if isempty(parentAppdata.control.spectra.modified) || ...
                    isempty(ind(parentAppdata.control.spectra.modified,handles.Spectrum))
                if isempty(parentAppdata.control.spectra.modified) || ...
                        isempty(parentAppdata.control.spectra.modified{1})
                    parentAppdata.control.spectra.modified{1} = ...
                        handles.Spectrum;
                else
                    parentAppdata.control.spectra.modified{end+1} = ...
                        handles.Spectrum;
                end
                setappdata(...
                    callerHandles.figure1,...
                    'control',...
                    parentAppdata.control);
            end
        end
    end
end

% removes handle of this GUI from handles structure of the calling gui in
% case this function has been called from another GUI
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
    callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)
        ownHandle = getfield(callerHandles,mfilename);
        callerHandles = rmfield(...
            callerHandles,...
            mfilename);
    end
    guidata(handles.callerHandle,callerHandles);
    delete(ownHandle);
elseif isfield(handles,'mfilename') && strcmpi(handles.mfilename,mfilename)
    delete(gcf);
else
    delete(getfield(handles,mfilename));
    handles = rmfield(handles,mfilename);
    guidata(hObject,handles);
end



function fieldStepEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fieldStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fieldStepEdit as text
%        str2double(get(hObject,'String')) returns contents of fieldStepEdit as a double


% --- Executes during object creation, after setting all properties.
function fieldStepEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldStartEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fieldStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fieldStartEdit as text
%        str2double(get(hObject,'String')) returns contents of fieldStartEdit as a double


% --- Executes during object creation, after setting all properties.
function fieldStartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fieldEndEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fieldEndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fieldEndEdit as text
%        str2double(get(hObject,'String')) returns contents of fieldEndEdit as a double


% --- Executes during object creation, after setting all properties.
function fieldEndEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldEndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeLengthTimeEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.timeLengthTimeEdit,'String'))
    set(...
    	handles.timeLengthTimeEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.transient.length = [];
else
    set(...
    	handles.timeLengthTimeEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.transient.length = ...
        str2double(get(handles.timeLengthTimeEdit,'String'));
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function timeLengthTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeLengthTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeLengthPointsEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.timeLengthPointsEdit,'String'))
    set(...
    	handles.timeLengthPointsEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.transient.points = [];
else
    set(...
    	handles.timeLengthPointsEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.transient.points = ...
        str2double(get(handles.timeLengthPointsEdit,'String'));
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function timeLengthPointsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeLengthPointsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeEndEdit_Callback(hObject, eventdata, handles)
% hObject    handle to timeEndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeEndEdit as text
%        str2double(get(hObject,'String')) returns contents of timeEndEdit as a double


% --- Executes during object creation, after setting all properties.
function timeEndEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeEndEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function timeStepEdit_Callback(hObject, eventdata, handles)
% hObject    handle to timeStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeStepEdit as text
%        str2double(get(hObject,'String')) returns contents of timeStepEdit as a double


% --- Executes during object creation, after setting all properties.
function timeStepEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeStepEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function microwavePowerEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.microwavePowerEdit,'String'))
    set(...
    	handles.microwavePowerEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.bridge.MWpower.value = [];
else
    set(...
    	handles.microwavePowerEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.bridge.MWpower.value = ...
        str2double(get(handles.microwavePowerEdit,'String'));
end
MWpowerUnits = get(handles.microwavePowerUnitPopupmenu,'String');
appdata.data{handles.Spectrum}.parameters.bridge.MWpower.unit = ...
    MWpowerUnits{get(handles.microwavePowerUnitPopupmenu,'Value')};

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function microwavePowerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to microwavePowerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fieldUnitPopupmenu.
function fieldUnitPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

fieldUnits = get(handles.fieldUnitPopupmenu,'String');
appdata.data{handles.Spectrum}.axes.yaxis.unit = ...
    fieldUnits{get(handles.fieldUnitPopupmenu,'Value')};

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function fieldUnitPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldUnitPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in timeUnitPopupmenu.
function timeUnitPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

timeUnits = get(handles.timeUnitPopupmenu,'String');
appdata.data{handles.Spectrum}.axes.xaxis.unit = ...
    timeUnits{get(handles.timeUnitPopupmenu,'Value')};

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function timeUnitPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeUnitPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sensitivityEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.sensitivityEdit,'String'))
    appdata.data{handles.Spectrum}.parameters.recorder.sensitivity.value = [];
else
    appdata.data{handles.Spectrum}.parameters.recorder.sensitivity.value = ...
        str2double(get(handles.sensitivityEdit,'String'));
end
sensitivityUnits = get(handles.sensitivityUnitPopupmenu,'String');
if strcmp(sensitivityUnits{get(handles.sensitivityUnitPopupmenu,'Value')},'unit')
    appdata.data{handles.Spectrum}.parameters.bridge.sensitivity.unit = '';
else
    appdata.data{handles.Spectrum}.parameters.bridge.sensitivity.unit = ...
        sensitivityUnits{get(handles.sensitivityUnitPopupmenu,'Value')};
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function sensitivityEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivityEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function videoGainEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.videoGainEdit,'String'))
    appdata.data{handles.Spectrum}.parameters.bridge.videogain.value = [];
else
    appdata.data{handles.Spectrum}.parameters.bridge.videogain.value = ...
        str2double(get(handles.videoGainEdit,'String'));
end
videoGainUnits = get(handles.videoGainUnitPopupmenu,'String');
if iscell(videoGainUnits)
    appdata.data{handles.Spectrum}.parameters.bridge.videogain.unit = ...
        videoGainUnits{get(handles.videoGainUnitPopupmenu,'Value')};
else
    appdata.data{handles.Spectrum}.parameters.bridge.videogain.unit = ...
        videoGainUnits;
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function videoGainEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoGainEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bandwidthEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.bandwidthEdit,'String'))
    appdata.data{handles.Spectrum}.parameters.bridge.bandwidth.value = [];
else
    appdata.data{handles.Spectrum}.parameters.bridge.bandwidth.value = ...
        str2double(get(handles.bandwidthEdit,'String'));
end
bandwidthUnits = get(handles.bandwidthUnitPopupmenu,'String');
if iscell(bandwidthUnits)
    appdata.data{handles.Spectrum}.parameters.bridge.bandwidth.unit = ...
        bandwidthUnits{get(handles.bandwidthUnitPopupmenu,'Value')};
else
    appdata.data{handles.Spectrum}.parameters.bridge.bandwidth.unit = ...
        bandwidthUnits;
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function bandwidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bandwidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bridgeTypeEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{handles.Spectrum}.parameters.bridge.type = ...
    get(handles.bridgeTypeEdit,'String');

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function bridgeTypeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bridgeTypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resonatorTypeEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{handles.Spectrum}.parameters.resonator.type = ...
    get(handles.resonatorTypeEdit,'String');

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function resonatorTypeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resonatorTypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dscFileBrowseButton.
function dscFileBrowseButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

dscFormats = get(handles.dscFormatPopupmenu,'String');
switch dscFormats{get(handles.dscFormatPopupmenu,'Value')}
    case 'unrecognized (show only)'
        [FileName,PathName,FilterIndex] = uigetfile(...
            '*.*',...
            'Select file to load',...
            'MultiSelect','off');
        if ischar(FileName)
            appdata.control.dsc.fileName = [PathName FileName];
            appdata.control.dsc.fileType = 'unrecognized (show only)';
            set(handles.dscFilenameEdit,'String',[PathName FileName]);
            set(handles.dscFileShowButton,'Enable','On');
        end
    case 'metaGen dsc'
        [FileName,PathName,FilterIndex] = uigetfile(...
            '*.dsc',...
            'Select file to load',...
            'MultiSelect','off');
        if ischar(FileName)
            appdata.control.dsc.fileName = [PathName FileName];
            appdata.control.dsc.fileType = 'unrecognized (show only)';
            set(handles.dscFilenameEdit,'String',[PathName FileName]);
            set(handles.dscFileShowButton,'Enable','On');
        end
    case 'Bruker DSC'
        [FileName,PathName,FilterIndex] = uigetfile(...
            '*.DSC',...
            'Select file to load',...
            'MultiSelect','off');
        if ischar(FileName)
            appdata.control.dsc.fileName = [PathName FileName];
            appdata.control.dsc.fileType = 'unrecognized (show only)';
            set(handles.dscFilenameEdit,'String',[PathName FileName]);
            set(handles.dscFileShowButton,'Enable','On');
        end
    case 'XML'
        [FileName,PathName,FilterIndex] = uigetfile(...
            '*.xml',...
            'Select file to load',...
            'MultiSelect','off');
        if ischar(FileName)
            appdata.control.dsc.fileName = [PathName FileName];
            appdata.control.dsc.fileType = 'unrecognized (show only)';
            set(handles.dscFilenameEdit,'String',[PathName FileName]);
            set(handles.dscFileShowButton,'Enable','On');
        end
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end


% --- Executes on selection change in dscFormatPopupmenu.
function dscFormatPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

dscFormats = get(handles.dscFormatPopupmenu,'String');
if ~strcmp(appdata.control.dsc.fileType,dscFormats{get(handles.dscFormatPopupmenu,'Value')})
    set(handles.dscFilenameEdit,'String','');
    appdata.control.dsc.fileName = '';
end
appdata.control.dsc.fileType = ...
    dscFormats{get(handles.dscFormatPopupmenu,'Value')};

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end


% --- Executes during object creation, after setting all properties.
function dscFormatPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dscFormatPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dscFileShowButton.
function dscFileShowButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

trEPR_GUI_filedisplay(...
    'File',...
    appdata.control.dsc.fileName,...
    'LineNumbers',...
    true);

% --- Executes on button press in dscFileLoadButton.
function dscFileLoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to dscFileLoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in microwavePowerUnitPopupmenu.
function microwavePowerUnitPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

MWpowerUnits = get(handles.microwavePowerUnitPopupmenu,'String');
appdata.data{handles.Spectrum}.parameters.bridge.MWpower.unit = ...
    MWpowerUnits{get(handles.microwavePowerUnitPopupmenu,'Value')};

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function microwavePowerUnitPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to microwavePowerUnitPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function averagesEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(get(handles.averagesEdit,'String'))
    set(...
    	handles.averagesEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
    appdata.data{handles.Spectrum}.parameters.recorder.averages = [];
else
    set(...
    	handles.averagesEdit,...
        'BackgroundColor',...
        [1 1 1]);
    appdata.data{handles.Spectrum}.parameters.recorder.averages = ...
        str2double(get(handles.averagesEdit,'String'));
end

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function averagesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to averagesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function labelEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{handles.Spectrum}.label = ...
   get(handles.labelEdit,'String');

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function labelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to labelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeStartEdit_Callback(hObject, eventdata, handles)
% hObject    handle to timeStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeStartEdit as text
%        str2double(get(hObject,'String')) returns contents of timeStartEdit as a double


% --- Executes during object creation, after setting all properties.
function timeStartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sensitivityUnitPopupmenu.
function sensitivityUnitPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

sensitivityUnits = get(handles.sensitivityUnitPopupmenu,'String');
appdata.data{handles.Spectrum}.parameters.recorder.sensitivity.unit = ...
    sensitivityUnits{get(handles.sensitivityUnitPopupmenu,'Value')};

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function sensitivityUnitPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivityUnitPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in videoGainUnitPopupmenu.
function videoGainUnitPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

videoGainUnits = get(handles.videoGainUnitPopupmenu,'String');
appdata.data{handles.Spectrum}.parameters.bridge.videogain.unit = ...
    videoGainUnits{get(handles.videoGainUnitPopupmenu,'Value')};

% Refresh handles and appdata of the current GUI
guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function videoGainUnitPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to videoGainUnitPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in bandwidthUnitPopupmenu.
function bandwidthUnitPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to bandwidthUnitPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns bandwidthUnitPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bandwidthUnitPopupmenu


% --- Executes during object creation, after setting all properties.
function bandwidthUnitPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bandwidthUnitPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fileNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to fileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileNameEdit as text
%        str2double(get(hObject,'String')) returns contents of fileNameEdit as a double


% --- Executes during object creation, after setting all properties.
function fileNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function if_parentAppdataRefresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Get appdata from parent window
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
	callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)
    	% Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);
        % Set changed parameters of parentAppdata
        parentAppdata.data{handles.Spectrum} = ...
            appdata.data{handles.Spectrum};
        % Refresh appdata of the parent GUI
        parentAppdataFieldnames = fieldnames(parentAppdata);
        for k=1:length(parentAppdataFieldnames)
            setappdata(...
                callerHandles.figure1,...
                parentAppdataFieldnames{k},...
                getfield(parentAppdata,...
                parentAppdataFieldnames{k})...
                );
        end
    end
end


% --- Create "hash" of all fields
function hash = if_makeHash(hObject)
% Get handles of the current GUI
handles = guidata(hObject);

hashRelevantEditFields = {...
    'fieldStartEdit',...
    'fieldEndEdit',...
    'fieldStepEdit',...
    'timeStartEdit',...
    'timeEndEdit',...
    'timeStepEdit',...
    'timeLengthTimeEdit',...
    'timeLengthPointsEdit',...
    'laserWavelengthEdit',...
    'laserRepetitionRateEdit',...
    'microwaveFrequencyEdit',...
    'microwaveAttenuationEdit',...
    'microwavePowerEdit',...
    'averagesEdit',...
    'temperatureEdit',...
    'labelEdit',...
    'sensitivityEdit',...
    'videoGainEdit',...
    'bandwidthEdit',...
    'digitizerEdit',...
    'bridgeTypeEdit',...
    'resonatorTypeEdit'...
    };
hashRelevantPopupFields = {...
    'fieldUnitPopupmenu',...
    'timeUnitPopupmenu',...
    'microwavePowerUnitPopupmenu',...
    'sensitivityUnitPopupmenu',...
    'videoGainUnitPopupmenu',...
    'bandwidthUnitPopupmenu',...
    'fieldProbePopupmenu'...
    };
hash = '';
for k=1:length(hashRelevantEditFields)
    hash = sprintf('%s%s',...
        hash,...
        get(getfield(handles,hashRelevantEditFields{k}),'String')...
        );
end
for k=1:length(hashRelevantPopupFields)
    hash = sprintf('%s%s',...
        hash,...
        num2str(...
        get(getfield(handles,hashRelevantPopupFields{k}),'Value')...
        )...
        );
end

% Refresh handles of the current GUI
guidata(hObject,handles);


% --- Check for necessary fields
function TF = if_checkForNecessaryFields(hObject)
% Get handles of the current GUI
handles = guidata(hObject);

TF = logical(false);

necessaryFields = {...
    'fieldStartEdit',...
    'fieldEndEdit',...
    'fieldStepEdit',...
    'timeStartEdit',...
    'timeEndEdit',...
    'timeStepEdit',...
    'timeLengthTimeEdit',...
    'timeLengthPointsEdit',...
    'laserWavelengthEdit',...
    'laserRepetitionRateEdit',...
    'microwaveFrequencyEdit',...
    'microwaveAttenuationEdit',...
    'averagesEdit',...
    'temperatureEdit',...
    'labelEdit'...
    };
for k = 1:length(necessaryFields)
    if isempty(get(getfield(handles,necessaryFields{k}),'String'))
        TF = logical(true);
    end
end



% --- Populate fields with the parameters of the currently active spectrum
function if_refreshFields(hObject, eventdata, handles)

% Get appdata from parent window
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
	callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)
    	% Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);
    end
end

data = parentAppdata.data;

% Display parameters that should always be there
set(...
    handles.fieldStartEdit,...
    'String',...
    num2str(min(data{handles.Spectrum}.axes.yaxis.values)));
set(...
    handles.fieldEndEdit,...
    'String',...
    num2str(max(data{handles.Spectrum}.axes.yaxis.values)));
set(...
    handles.fieldStepEdit,...
    'String',...
    num2str(data{handles.Spectrum}.axes.yaxis.values(2)-...
    data{handles.Spectrum}.axes.yaxis.values(1)));
set(handles.fieldUnitPopupmenu,'Value',...
    ind(get(handles.fieldUnitPopupmenu,'String'),...
    data{handles.Spectrum}.axes.yaxis.unit));
set(...
    handles.timeStartEdit,...
    'String',...
    num2str(min(data{handles.Spectrum}.axes.xaxis.values)));
set(...
    handles.timeEndEdit,...
    'String',...
    num2str(max(data{handles.Spectrum}.axes.xaxis.values)));
set(...
    handles.timeStepEdit,...
    'String',...
    num2str(data{handles.Spectrum}.axes.xaxis.values(2)-...
    data{handles.Spectrum}.axes.xaxis.values(1)));
set(handles.timeUnitPopupmenu,'Value',...
    ind(get(handles.timeUnitPopupmenu,'String'),...
    data{handles.Spectrum}.axes.xaxis.unit));
set(...
    handles.labelEdit,...
    'String',...
    data{handles.Spectrum}.label);
set(...
    handles.fileNameEdit,...
    'String',...
    data{handles.Spectrum}.filename);

% Mark fields with red background that are necessary but not filled
if isempty(get(handles.fieldStartEdit,'String'))
    set(...
        handles.fieldStartEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.fieldStartEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.fieldEndEdit,'String'))
    set(...
        handles.fieldEndEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.fieldEndEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.fieldStepEdit,'String'))
    set(...
        handles.fieldStepEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.fieldStepEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.timeStartEdit,'String'))
    set(...
        handles.timeStartEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.timeStartEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.timeEndEdit,'String'))
    set(...
        handles.timeEndEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.timeEndEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.timeStepEdit,'String'))
    set(...
        handles.timeStepEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.timeStepEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.labelEdit,'String'))
    set(...
        handles.labelEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.labelEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.fileNameEdit,'String'))
    set(...
        handles.fileNameEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.fileNameEdit,...
        'BackgroundColor',...
        [1 1 1]);
end

if isfield(data{handles.Spectrum},'header')
    for k=1:length(data{handles.Spectrum}.header)
        header{k} = sprintf('%i: %s',k,...
            data{handles.Spectrum}.header{k});
    end
    set(...
        handles.headerEdit,...
        'String',...
        header);
else
    set(...
        handles.headerEdit,...
        'String',...
        '');
end
if isfield(data{handles.Spectrum}.parameters.bridge,'MWfrequency')
    set(...
        handles.microwaveFrequencyEdit,...
        'String',...
        data{handles.Spectrum}.parameters.bridge.MWfrequency);
else
    set(...
        handles.microwaveFrequencyEdit,...
        'String',...
        '');
end
if isempty(get(handles.microwaveFrequencyEdit,'String'))
    set(...
        handles.microwaveFrequencyEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.microwaveFrequencyEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isfield(data{handles.Spectrum}.parameters.bridge,'attenuation')
    set(...
        handles.microwaveAttenuationEdit,...
        'String',...
        data{handles.Spectrum}.parameters.bridge.attenuation);
else
    set(...
        handles.microwaveAttenuationEdit,...
        'String',...
        '');
end
if isempty(get(handles.microwaveAttenuationEdit,'String'))
	set(...
    	handles.microwaveAttenuationEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.microwaveAttenuationEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isfield(data{handles.Spectrum}.parameters.bridge,'MWpower')
	set(...
    	handles.microwavePowerEdit,...
        'String',...
        data{handles.Spectrum}.parameters.bridge.MWpower.value);
else
	set(...
    	handles.microwavePowerEdit,...
        'String',...
        '');
end
	if isfield(data{handles.Spectrum}.parameters.bridge,'videogain')
    set(...
    	handles.videoGainEdit,...
        'String',...
        data{handles.Spectrum}.parameters.bridge.videogain.value);
else
	set(...
    	handles.videoGainEdit,...
        'String',...
        '');
end
	if isfield(data{handles.Spectrum}.parameters.bridge,'bandwidth')
	set(...
    	handles.bandwidthEdit,...
        'String',...
        data{handles.Spectrum}.parameters.bridge.bandwidth.value);
else
	set(...
    	handles.bandwidthEdit,...
        'String',...
        '');
end
if isfield(data{handles.Spectrum}.parameters,'laser')
	if isfield(data{handles.Spectrum}.parameters.laser,'wavelength')
    	set(...
        	handles.laserWavelengthEdit,...
            'String',...
            data{handles.Spectrum}.parameters.laser.wavelength);
    else
    	set(...
        	handles.laserWavelengthEdit,...
            'String',...
            '');
    end
    if isfield(data{handles.Spectrum}.parameters.laser,'repetitionRate')
        set(...
        	handles.laserRepetitionRateEdit,...
            'String',...
            data{handles.Spectrum}.parameters.laser.repetitionRate);
    else
    	set(...
        	handles.laserRepetitionRateEdit,...
            'String',...
            '');
    end
else
	set(...
    	handles.laserWavelengthEdit,...
        'String',...
        '');
    set(...
    	handles.laserRepetitionRateEdit,...
        'String',...
        '');
	end
if isempty(get(handles.laserWavelengthEdit,'String'))
    set(...
        handles.laserWavelengthEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.laserWavelengthEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isempty(get(handles.laserRepetitionRateEdit,'String'))
    set(...
        handles.laserRepetitionRateEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.laserRepetitionRateEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isfield(data{handles.Spectrum}.parameters,'temperature')
    set(...
        handles.temperatureEdit,...
        'String',...
        data{handles.Spectrum}.parameters.temperature);
else
    set(...
        handles.temperatureEdit,...
        'String',...
        '');
end
if isempty(get(handles.temperatureEdit,'String'))
    set(...
        handles.temperatureEdit,...
        'BackgroundColor',...
        [1 0.8 0.8]);
else
    set(...
        handles.temperatureEdit,...
        'BackgroundColor',...
        [1 1 1]);
end
if isfield(data{handles.Spectrum}.parameters,'transient')
    if isfield(data{handles.Spectrum}.parameters.transient,'points')
        set(...
            handles.timeLengthPointsEdit,...
            'String',...
            num2str(data{...
            handles.Spectrum}.parameters.transient.points));
    else
        set(...
            handles.timeLengthPointsEdit,...
            'String',...
            '');
    end                    
    if isfield(data{handles.Spectrum}.parameters.transient,'length')
        set(...
            handles.timeLengthTimeEdit,...
            'String',...
            num2str(data{...
            handles.Spectrum}.parameters.transient.length));
    else
        set(...
            handles.timeLengthTimeEdit,...
            'String',...
            '');
    end                    
end
if isfield(data{handles.Spectrum}.parameters,'recorder')
    if isfield(data{handles.Spectrum}.parameters.recorder,'sensitivity')
        set(...
            handles.sensitivityEdit,...
            'String',...
            num2str(data{...
            handles.Spectrum}.parameters.recorder.sensitivity.value));
    else
        set(...
            handles.sensitivityEdit,...
            'String',...
            '');
    end
    if isfield(data{handles.Spectrum}.parameters.recorder.sensitivity,'unit') && ...
            ~isempty(data{handles.Spectrum}.parameters.recorder.sensitivity.unit)
        set(handles.sensitivityUnitPopupmenu,'Value',...
            ind(get(handles.sensitivityUnitPopupmenu,'String'),...
            data{handles.Spectrum}.parameters.recorder.sensitivity.unit));
    else
        set(handles.sensitivityUnitPopupmenu,'Value',1);
    end
    if isfield(data{handles.Spectrum}.parameters.recorder,'averages')
        set(...
            handles.averagesEdit,...
            'String',...
            num2str(data{...
            handles.Spectrum}.parameters.recorder.averages));
        if isempty(get(handles.averagesEdit,'String'))
            set(...
                handles.averagesEdit,...
                'BackgroundColor',...
                [1 0.8 0.8]);
        else
            set(...
                handles.averagesEdit,...
                'BackgroundColor',...
                [1 1 1]);
        end
    else
        set(...
            handles.averagesEdit,...
            'String',...
            '');
    end                    
end

% Refresh handles of the current GUI
guidata(hObject,handles);


% --- Executes on selection change in multipleFilesPopupmenu.
function multipleFilesPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to multipleFilesPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns multipleFilesPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from multipleFilesPopupmenu
if isfield(handles,'Spectra')
    % Check whether parameters of still displayed spectrum have been
    % modified and if so, add this spectrum to
    % parentAppdata.control.spectra.modified
    if ~strcmp(handles.hash,if_makeHash(handles.figure1))
        % Add id of spectrum to parentAppdata.control.spectra.modified
        % Get appdata from parent window
        if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
            callerHandles = guidata(handles.callerHandle);
            if isfield(callerHandles,mfilename)
                % Get appdata of the parent GUI
                parentAppdata = getappdata(callerHandles.figure1);
                if isempty(parentAppdata.control.spectra.modified) || ...
                        isempty(ind(parentAppdata.control.spectra.modified,handles.Spectrum))
                    if isempty(parentAppdata.control.spectra.modified) || ...
                            isempty(parentAppdata.control.spectra.modified{1})
                        parentAppdata.control.spectra.modified{1} = ...
                            handles.Spectrum;
                    else
                        parentAppdata.control.spectra.modified{end+1} = ...
                            handles.Spectrum;
                    end
                    setappdata(...
                        callerHandles.figure1,...
                        'control',...
                        parentAppdata.control);
                end
            end
        end
    end
    % Check whether the currently displayed spectrum is complete and if so,
    % delete it from parentAppdata.control.spectra.missing. Otherwise, add
    % it to parentAppdata.control.spectra.missing
    if if_checkForNecessaryFields(handles.figure1)
        % Add spectrum to parentAppdata.control.spectra.missing in case
        % it is not already listed there
        % Get appdata from parent window
        if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
            callerHandles = guidata(handles.callerHandle);
            if isfield(callerHandles,mfilename)
            	% Get appdata of the parent GUI
                parentAppdata = getappdata(callerHandles.figure1);
                if isempty(ind(parentAppdata.control.spectra.missing,handles.Spectrum))
                    parentAppdata.control.spectra.missing{end+1} = handles.Spectrum;
                    setappdata(...
                        callerHandles.figure1,...
                        'control',...
                        parentAppdata.control);
                end
            end
            % Switch on button to complete these parameters
            set(...
                callerHandles.spectraCompleteParametersButton,...
                'Enable','On');
        end    
    else
        % Remove spectrum from parentAppdata.control.spectra.missing in
        % case it was listed there
        % Get appdata from parent window
        if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
            callerHandles = guidata(handles.callerHandle);
            if isfield(callerHandles,mfilename)
                % Get appdata of the parent GUI
                parentAppdata = getappdata(callerHandles.figure1);
                if ind(parentAppdata.control.spectra.missing,handles.Spectrum)
                    parentAppdata.control.spectra.missing(...
                        ind(parentAppdata.control.spectra.missing,handles.Spectrum)) = [];
                    setappdata(...
                        callerHandles.figure1,...
                        'control',...
                        parentAppdata.control);
                end
            end
            % If there are no spectra any more with missing parameters,
            % switch button to complete these parameters to off.
            if isempty(parentAppdata.control.spectra.missing)
                set(...
                    callerHandles.spectraCompleteParametersButton,...
                    'Enable','Off');
            end
        end
    end
    % Set currently displayed spectrum to the one selected
    handles.Spectrum = handles.Spectra{get(hObject,'Value')};
    % Refresh the fields
    if_refreshFields(hObject, eventdata, handles);
    % Get handles of the current GUI and set new hash value
    handles = guidata(hObject);
    handles.hash = if_makeHash(hObject);
    % Update handles structure
    guidata(hObject, handles);
end



% --- Executes during object creation, after setting all properties.
function multipleFilesPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to multipleFilesPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function digitizerEdit_Callback(hObject, eventdata, handles)
% hObject    handle to digitizerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of digitizerEdit as text
%        str2double(get(hObject,'String')) returns contents of digitizerEdit as a double


% --- Executes during object creation, after setting all properties.
function digitizerEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to digitizerEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fieldProbePopupmenu.
function fieldProbePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to fieldProbePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns fieldProbePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fieldProbePopupmenu


% --- Executes during object creation, after setting all properties.
function fieldProbePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fieldProbePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


