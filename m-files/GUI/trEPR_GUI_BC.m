function varargout = trEPR_GUI_BC(varargin)
% TREPR_GUI_BC M-file for trEPR_GUI_BC.fig
%      TREPR_GUI_BC, by itself, creates a new TREPR_GUI_BC or raises the existing
%      singleton*.
%
%      H = TREPR_GUI_BC returns the handle to a new TREPR_GUI_BC or the handle to
%      the existing singleton*.
%
%      TREPR_GUI_BC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREPR_GUI_BC.M with the given input arguments.
%
%      TREPR_GUI_BC('Property','Value',...) creates a new TREPR_GUI_BC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trEPR_GUI_BC_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trEPR_GUI_BC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_BC

% Last Modified by GUIDE v2.5 15-Apr-2010 12:07:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trEPR_GUI_BC_OpeningFcn, ...
                   'gui_OutputFcn',  @trEPR_GUI_BC_OutputFcn, ...
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


% --- Executes just before trEPR_GUI_BC is made visible.
function trEPR_GUI_BC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trEPR_GUI_BC (see VARARGIN)

% Choose default command line output for trEPR_GUI_BC
handles.output = hObject;

set(hObject,'Name','trEPR toolbox : baseline correction');

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
    'spectra', struct(...
    'active',0,...
    'visible',cell(1)...
    )...
);

setappdata(handles.figure1,'data',data);
setappdata(handles.figure1,'configuration',configuration);
setappdata(handles.figure1,'control',control);

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

% Get appdata from parent window necessary for BLC
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
    callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)

        % Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);
        
        data = parentAppdata.data;
        control.spectra = parentAppdata.control.spectra;
        setappdata(handles.figure1,'data',data);
        setappdata(handles.figure1,'control',control);

    end
    guidata(handles.callerHandle,callerHandles);
end

% Update listbox with spectra names
if ~isempty(control.spectra.visible)
    if_spectraVisibleListbox_Refresh(hObject);
    if_axis_Refresh(hObject);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trEPR_GUI_BC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trEPR_GUI_BC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function spectraScrollSlider_Callback(hObject, eventdata, handles)
% hObject    handle to spectraScrollSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

set(handles.positionInTimePointsEdit,'String',...
    num2str(floor(get(handles.spectraScrollSlider,'Value')))...
    );
appdata.data{appdata.control.spectra.active}.t = ...
    floor(get(handles.spectraScrollSlider,'Value'));
set(handles.positionInTimeValueEdit,'String',...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values(...
    appdata.data{appdata.control.spectra.active}.t));

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

if_axis_Refresh(hObject);


% --- Executes during object creation, after setting all properties.
function spectraScrollSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraScrollSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in correctionMethodPopupmenu.
function correctionMethodPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to correctionMethodPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns correctionMethodPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from correctionMethodPopupmenu


% --- Executes during object creation, after setting all properties.
function correctionMethodPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to correctionMethodPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function positionInTimePointsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to positionInTimePointsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionInTimePointsEdit as text
%        str2double(get(hObject,'String')) returns contents of positionInTimePointsEdit as a double


% --- Executes during object creation, after setting all properties.
function positionInTimePointsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positionInTimePointsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function leftFitAreaSlider_Callback(hObject, eventdata, handles)
% hObject    handle to leftFitAreaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function leftFitAreaSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftFitAreaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function leftFitAreaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to leftFitAreaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of leftFitAreaEdit as text
%        str2double(get(hObject,'String')) returns contents of leftFitAreaEdit as a double


% --- Executes during object creation, after setting all properties.
function leftFitAreaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to leftFitAreaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function rightFitAreaSlider_Callback(hObject, eventdata, handles)
% hObject    handle to rightFitAreaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function rightFitAreaSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightFitAreaSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function rightFitAreaEdit_Callback(hObject, eventdata, handles)
% hObject    handle to rightFitAreaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rightFitAreaEdit as text
%        str2double(get(hObject,'String')) returns contents of rightFitAreaEdit as a double


% --- Executes during object creation, after setting all properties.
function rightFitAreaEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rightFitAreaEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in leftFitAreaPickButton.
function leftFitAreaPickButton_Callback(hObject, eventdata, handles)
% hObject    handle to leftFitAreaPickButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rightFitAreaPickButton.
function rightFitAreaPickButton_Callback(hObject, eventdata, handles)
% hObject    handle to rightFitAreaPickButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function additionalFitPoint1Slider_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint1Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function additionalFitPoint1Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint1Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function additionalFitPoint1Position_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint1Position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of additionalFitPoint1Position as text
%        str2double(get(hObject,'String')) returns contents of additionalFitPoint1Position as a double


% --- Executes during object creation, after setting all properties.
function additionalFitPoint1Position_CreateFcn(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint1Position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function additionalFitPoint2Slider_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint2Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function additionalFitPoint2Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint2Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function additionalFitPoint2Position_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint2Position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of additionalFitPoint2Position as text
%        str2double(get(hObject,'String')) returns contents of additionalFitPoint2Position as a double


% --- Executes during object creation, after setting all properties.
function additionalFitPoint2Position_CreateFcn(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint2Position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in additionalFitPoint1Checkbox.
function additionalFitPoint1Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint1Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of additionalFitPoint1Checkbox


% --- Executes on button press in additionalFitPoint2Checkbox.
function additionalFitPoint2Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint2Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of additionalFitPoint2Checkbox


% --- Executes on button press in additionalFitPoint1PickButton.
function additionalFitPoint1PickButton_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint1PickButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in additionalFitPoint2PickButton.
function additionalFitPoint2PickButton_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint2PickButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function positionInTimeValueEdit_Callback(hObject, eventdata, handles)
% hObject    handle to positionInTimeValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionInTimeValueEdit as text
%        str2double(get(hObject,'String')) returns contents of positionInTimeValueEdit as a double


% --- Executes during object creation, after setting all properties.
function positionInTimeValueEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positionInTimeValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closeGUI(hObject, eventdata, handles);


% --- Executes on button press in correctionGoButton.
function correctionGoButton_Callback(hObject, eventdata, handles)
% hObject    handle to correctionGoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in correctionResetButton.
function correctionResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to correctionResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in spectraVisibleListbox.
function spectraVisibleListbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraVisibleListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

% Set currently active spectrum
if ~isempty(appdata.control.spectra.visible)
    appdata.control.spectra.active = appdata.control.spectra.visible{...
        get(handles.spectraVisibleListbox,'Value')...
        };
    if_spectraVisibleListbox_Refresh(hObject);
end

% Refresh appdata of the current GUI
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_axis_Refresh(hObject);


% --- Executes during object creation, after setting all properties.
function spectraVisibleListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraVisibleListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
    else
        ownHandle = handles.figure1;
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



% --- Refresh visible spectra listbox
function if_spectraVisibleListbox_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Extract names of visible Spectra from appdata
visSpectraNames = cell(1);
if isempty(appdata.control.spectra.visible{1})
    visSpectraNames = cell(1);
    appdata.control.spectra.active = 0;
    set(handles.spectraVisibleListbox,'Enable','Inactive');
    cla(handles.axes1,'reset');
    cla(handles.axes2,'reset');
    set(handles.timeEditIndex,'Enable','Inactive');
else
    set(handles.spectraVisibleListbox,'Enable','On');
    set(handles.positionInTimePointsEdit,'Enable','On');
    set(handles.positionInTimeValueEdit,'Enable','On');
    for k=1:length(appdata.control.spectra.visible)
        [pathstr, name, ext, versn] = fileparts(...
            appdata.data{...
            appdata.control.spectra.visible{k}}.filename...
            );
        visSpectraNames{k} = [name ext];
    end
end

% Fix problem with currently selected item
maxValue = length(visSpectraNames);
selectedValue = get(handles.spectraVisibleListbox,'Value');
if selectedValue > maxValue
    set(handles.spectraVisibleListbox,'Value',maxValue);
end

% Set currently active spectrum
% Use a trick to determine whether it is the first load
if isempty(get(handles.spectraVisibleListbox,'String'))
    set(handles.spectraVisibleListbox,...
        'Value',...
        appdata.control.spectra.active);
else
    appdata.control.spectra.active = appdata.control.spectra.visible{...
        get(handles.spectraVisibleListbox,'Value')...
        };
end

% Set listbox display
set(handles.spectraVisibleListbox,'String',visSpectraNames);

% If there are no visible spectra any more, set appdata, turn off elements
% and return 
if isempty(appdata.control.spectra.active)
    appdata.control.spectra.active = 0;
    set(handles.spectraVisibleListbox,'Enable','Inactive');
    cla(handles.axes1,'reset');
    cla(handles.axes2,'reset');
    set(handles.positionInTimePointsEdit,'Enable','On');
    set(handles.positionInTimeValueEdit,'Enable','On');
    set(handles.spectraScrollSlider,'Enable','Off');
    % Refresh handles and appdata of the current GUI
    guidata(gcbo,handles);
    appdataFieldnames = fieldnames(appdata);
    for k=1:length(appdataFieldnames)
      setappdata(...
          handles.figure1,...
          appdataFieldnames{k},...
          getfield(appdata,appdataFieldnames{k})...
          );
    end
    return;
else
    set(handles.spectraVisibleListbox,'Enable','On');
    set(handles.positionInTimePointsEdit,'Enable','On');
    set(handles.positionInTimeValueEdit,'Enable','On');
    set(handles.spectraScrollSlider,'Enable','On');
end

% Set slider values and display of these values accordingly for the
% currently active spectrum
set(handles.positionInTimePointsEdit,'String',...
    appdata.data{appdata.control.spectra.active}.t);
set(handles.positionInTimeValueEdit,'String',...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values(...
    appdata.data{appdata.control.spectra.active}.t));

set(handles.spectraScrollSlider,'Min',1);
set(handles.spectraScrollSlider,'Max',...
    length(...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values));
set(handles.spectraScrollSlider,'Value',...
    appdata.data{appdata.control.spectra.active}.t);


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


% --- Refresh plot window (axis)
function if_axis_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if isempty(appdata.control.spectra.visible{1})
    cla(handles.axes1,'reset');
    return
end

% Get visible spectra

% Plot visible spectra
data = appdata.data{appdata.control.spectra.active}.data;
[ yDim, xDim ] = size(data);
xaxis = appdata.data{appdata.control.spectra.active}.axes.xaxis.values;
yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values;
% Convert G -> mT
if strcmp(appdata.data{appdata.control.spectra.active}.axes.yaxis.unit,'G')
    yaxis = yaxis / 10;
end

set(handles.spectraScrollSlider,'Enable','On');
set(handles.spectraScrollSlider,'Min',1);
set(handles.spectraScrollSlider,'Max',xDim);
set(handles.spectraScrollSlider,'SliderStep',[1/xDim, 10/xDim]);

% Reset current axis
cla(handles.axes1,'reset');
% Convert G -> mT
if strcmp(appdata.data{appdata.control.spectra.active}.axes.yaxis.unit,'G')
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values / 10;
    Db0 = appdata.data{appdata.control.spectra.active}.Db0 / 10;
else
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values;
    Db0 = appdata.data{appdata.control.spectra.active}.Db0;
end
plot(...
    handles.axes1,...
    yaxis + Db0,...
    appdata.data{appdata.control.spectra.active}.data(...
    :,floor(appdata.data{appdata.control.spectra.active}.t)...
    )...
    );
endOfSpectrum = mean(...
    appdata.data{appdata.control.spectra.active}.data(...
    :,length(xaxis)-10:length(xaxis)...
    ),...
    2);
plot(...
    handles.axes2,...
    yaxis + Db0,...
    endOfSpectrum...
    );
xLimits = [...
    yaxis(1) ...
    yaxis(end) ...                
    ];
yLimits = [...
    min(min(appdata.data{appdata.control.spectra.active}.data)) ...
    max(max(appdata.data{appdata.control.spectra.active}.data)) ...                
    ];
set(...
    handles.axes1,...
    'XLim',...
    [yaxis(1) yaxis(end)]...
    );
set(...
    handles.axes2,...
    'XLim',...
    [yaxis(1) yaxis(end)]...
    );
set(...
    handles.axes1,...
    'YLim',...
    [...
    min(min(appdata.data{appdata.control.spectra.active}.data))*1.05 ...
    max(max(appdata.data{appdata.control.spectra.active}.data))*1.05 ...                
    ]...
    );
set(...
    handles.axes2,...
    'YLim',...
    [...
    min(endOfSpectrum)*1.2 ...
    max(endOfSpectrum)*1.2 ...                
    ]...
    );

xlabel(handles.axes1,sprintf('{\\it magnetic field} / mT'));
ylabel(handles.axes1,sprintf('{\\it intensity} / a.u.'));
xlabel(handles.axes2,sprintf('{\\it magnetic field} / mT'));
ylabel(handles.axes2,sprintf('{\\it intensity} / a.u.'));

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


