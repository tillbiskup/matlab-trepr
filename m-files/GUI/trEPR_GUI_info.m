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

% Last Modified by GUIDE v2.5 25-Apr-2010 15:00:36

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

% add handle of this GUI to handles structure of the calling gui in case
% this function has been called from another GUI
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
    callerHandles = guidata(handles.callerHandle);
    callerHandles = setfield(...
        callerHandles,...
        mfilename,...
        hObject);
    guidata(handles.callerHandle,callerHandles);
end

% Display Information of currently active spectrum on opening
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
    callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)

        % Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);
        
        [path name ext] = fileparts(...
            parentAppdata.data{parentAppdata.control.spectra.active}.filename...
            );
        
        set(handles.headlineText,'String',...
            strrep(...
            get(handles.headlineText,'String'),...
            'FILENAME',...
            sprintf('"%s"',name)...
            ));

        % Display only something if there is something to display
        if parentAppdata.control.spectra.active > 0
            set(...
                handles.headerEdit,...
                'String',...
                parentAppdata.data{parentAppdata.control.spectra.active}.header);
            set(...
                handles.microwaveFrequencyEdit,...
                'String',...
                parentAppdata.data{parentAppdata.control.spectra.active}.parameters.bridge.MWfrequency);
            set(...
                handles.microwaveAttenuationEdit,...
                'String',...
                parentAppdata.data{parentAppdata.control.spectra.active}.parameters.bridge.attenuation);
            set(...
                handles.laserWavelengthEdit,...
                'String',...
                parentAppdata.data{parentAppdata.control.spectra.active}.parameters.laser.wavelength);
            set(...
                handles.laserRepetitionRateEdit,...
                'String',...
                parentAppdata.data{parentAppdata.control.spectra.active}.parameters.laser.repetitionRate);
            set(...
                handles.temperatureEdit,...
                'String',...
                parentAppdata.data{parentAppdata.control.spectra.active}.parameters.temperature);
        else
            set(handles.headerEdit,'String',cell(0));
        end

    end
    guidata(handles.callerHandle,callerHandles);
end

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

close;


function dscFilenameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dscFilenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dscFilenameEdit as text
%        str2double(get(hObject,'String')) returns contents of dscFilenameEdit as a double


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


% --- Executes on button press in savePushbutton.
function savePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in newPushbutton.
function newPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to newPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function microwaveAttenuationEdit_Callback(hObject, eventdata, handles)
% hObject    handle to microwaveAttenuationEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of microwaveAttenuationEdit as text
%        str2double(get(hObject,'String')) returns contents of microwaveAttenuationEdit as a double


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
% hObject    handle to microwaveFrequencyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of microwaveFrequencyEdit as text
%        str2double(get(hObject,'String')) returns contents of microwaveFrequencyEdit as a double


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
% hObject    handle to temperatureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of temperatureEdit as text
%        str2double(get(hObject,'String')) returns contents of temperatureEdit as a double


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
% hObject    handle to laserRepetitionRateEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of laserRepetitionRateEdit as text
%        str2double(get(hObject,'String')) returns contents of laserRepetitionRateEdit as a double


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
% hObject    handle to laserWavelengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of laserWavelengthEdit as text
%        str2double(get(hObject,'String')) returns contents of laserWavelengthEdit as a double


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
% hObject    handle to addParamApplyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
    callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)

        % Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);

        parentAppdata.data{parentAppdata.control.spectra.active}.parameters.bridge.MWfrequency = ...
            str2double(get(handles.microwaveFrequencyEdit,'String'));
        parentAppdata.data{parentAppdata.control.spectra.active}.parameters.bridge.attenuation = ...
            str2double(get(handles.microwaveAttenuationEdit,'String'));
        parentAppdata.data{parentAppdata.control.spectra.active}.parameters.laser.wavelength = ...
            str2double(get(handles.laserWavelengthEdit,'String'));
        parentAppdata.data{parentAppdata.control.spectra.active}.parameters.laser.repetitionRate = ...
            str2double(get(handles.laserRepetitionRateEdit,'String'));
        parentAppdata.data{parentAppdata.control.spectra.active}.parameters.temperature = ...
            str2double(get(handles.temperatureEdit,'String'));

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
    guidata(handles.callerHandle,callerHandles);
end

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
