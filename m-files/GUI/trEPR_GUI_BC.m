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

% Last Modified by GUIDE v2.5 15-Apr-2010 12:47:17

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
        % Assign necessary control parameters to data structure
        for k = 1:length(data)
            data{k}.blc.area.left = 10;
            data{k}.blc.area.right = 10;
            data{k}.blc.area.addPoint1 = [];
            data{k}.blc.area.addPoint2 = [];
        end
        control.spectra = parentAppdata.control.spectra;
        setappdata(handles.figure1,'data',data);
        setappdata(handles.figure1,'control',control);

    end
    guidata(handles.callerHandle,callerHandles);
end

% Set reload button inactive
set(handles.reloadButton,'Enable','Off');

% Update handles structure
guidata(hObject, handles);

% Update listbox with spectra names
if ~isempty(control.spectra.visible)
    if_spectraVisibleListbox_Refresh(hObject);
    if_axis_Refresh(hObject);
    if_fitArea_Refresh(hObject);
    if_fitPoints_Refresh(hObject);
end

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

if_axis_Refresh(handles.figure1);
if_fitArea_Refresh(handles.figure1);

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
% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

methods = get(hObject,'String');
switch methods{get(hObject,'Value')}
    case '0th polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '0poly';
    case '1st polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '1poly';
    case '2nd polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '2poly';
    case '3rd polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '3poly';
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

value = floor(str2double(get(hObject,'String')));
if value < 1
    appdata.data{appdata.control.spectra.active}.t = 1;
    set(handles.positionInTimePointsEdit,'String','1');
    set(handles.positionInTimeValueEdit,'String',...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1));
elseif value > length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values)
    appdata.data{appdata.control.spectra.active}.t = ...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values);
    set(handles.positionInTimePointsEdit,'String',...
        num2str(...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values)));
    set(handles.positionInTimeValueEdit,'String',...
        num2str(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values(end)));
else
    appdata.data{appdata.control.spectra.active}.t = value;
    set(handles.positionInTimePointsEdit,'String',num2str(value));
    set(handles.positionInTimeValueEdit,'String',...
        num2str(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values(...
        value)));
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_axis_Refresh(handles.figure1);


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

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.blc.area.left = ...
    get(hObject,'Value');
set(handles.leftFitAreaEdit,'String',num2str(get(hObject,'Value')));

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitArea_Refresh(handles.figure1);

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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

value = floor(str2double(get(hObject,'String')));
if value < get(handles.leftFitAreaSlider,'Min')
    appdata.data{appdata.control.spectra.active}.blc.area.left = ...
        get(handles.leftFitAreaSlider,'Min');
    set(handles.leftFitAreaSlider,'Value',...
        get(handles.leftFitAreaSlider,'Min'));
    set(handles.leftFitAreaEdit,'String',...
        num2str(get(handles.leftFitAreaSlider,'Min')));
elseif value > get(handles.leftFitAreaSlider,'Max')
    appdata.data{appdata.control.spectra.active}.blc.area.left = ...
        get(handles.leftFitAreaSlider,'Max');
    set(handles.leftFitAreaSlider,'Value',...
        get(handles.leftFitAreaSlider,'Max'));
    set(handles.leftFitAreaEdit,'String',...
        num2str(get(handles.leftFitAreaSlider,'Max')));
else
    appdata.data{appdata.control.spectra.active}.blc.area.left = value;
    set(handles.leftFitAreaSlider,'Value',value);
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitArea_Refresh(handles.figure1);


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

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.blc.area.right = ...
    get(hObject,'Value');
set(handles.rightFitAreaEdit,'String',num2str(get(hObject,'Value')));

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitArea_Refresh(handles.figure1);


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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

value = floor(str2double(get(hObject,'String')));
if value < get(handles.rightFitAreaSlider,'Min')
    appdata.data{appdata.control.spectra.active}.blc.area.right = ...
        get(handles.rightFitAreaSlider,'Min');
    set(handles.rightFitAreaSlider,'Value',...
        get(handles.rightFitAreaSlider,'Min'));
    set(handles.rightFitAreaEdit,'String',...
        num2str(get(handles.rightFitAreaSlider,'Min')));
elseif value > get(handles.rightFitAreaSlider,'Max')
    appdata.data{appdata.control.spectra.active}.blc.area.right = ...
        get(handles.rightFitAreaSlider,'Max');
    set(handles.rightFitAreaSlider,'Value',...
        get(handles.rightFitAreaSlider,'Max'));
    set(handles.rightFitAreaEdit,'String',...
        num2str(get(handles.rightFitAreaSlider,'Max')));
else
    appdata.data{appdata.control.spectra.active}.blc.area.right = value;
    set(handles.rightFitAreaSlider,'Value',value);
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitArea_Refresh(handles.figure1);


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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.control.point = 'left';
set(handles.figure1,'WindowButtonMotionFcn',@if_trackPointer);
set(handles.figure1,'WindowButtonDownFcn',@if_switchMeasurementPoint);

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


% --- Executes on button press in rightFitAreaPickButton.
function rightFitAreaPickButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.control.point = 'right';
set(handles.figure1,'WindowButtonMotionFcn',@if_trackPointer);
set(handles.figure1,'WindowButtonDownFcn',@if_switchMeasurementPoint);

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


% --- Executes on slider movement.
function additionalFitPoint1Slider_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.blc.area.addPoint1 = ...
    get(hObject,'Value');
set(handles.additionalFitPoint1Position,'String',...
    num2str(get(hObject,'Value')));

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitPoints_Refresh(handles.figure1);


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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

value = floor(str2double(get(hObject,'String')));
if value < 1
    appdata.data{appdata.control.spectra.active}.blc.area.addPoint1 = 1;
    set(handles.additionalFitPoint1Slider,'Value',1);
    set(handles.additionalFitPoint1Position,'String','1');
elseif value > length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values)
    appdata.data{appdata.control.spectra.active}.blc.area.addPoint1 = ...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values);
    set(handles.additionalFitPoint1Slider,'Value',...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values));
    set(handles.additionalFitPoint1Position,'String',...
        num2str(...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values)));
else
    appdata.data{appdata.control.spectra.active}.blc.area.addPoint1 = value;
    set(handles.additionalFitPoint1Slider,'Value',value);
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitPoints_Refresh(handles.figure1);


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

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.blc.area.addPoint2 = ...
    get(hObject,'Value');
set(handles.additionalFitPoint2Position,'String',...
    num2str(get(hObject,'Value')));

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitPoints_Refresh(handles.figure1);


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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

value = floor(str2double(get(hObject,'String')));
if value < 1
    appdata.data{appdata.control.spectra.active}.blc.area.addPoint2 = 1;
    set(handles.additionalFitPoint2Slider,'Value',1);
    set(handles.additionalFitPoint2Position,'String','1');
elseif value > length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values)
    appdata.data{appdata.control.spectra.active}.blc.area.addPoint2 = ...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values);
    set(handles.additionalFitPoint2Slider,'Value',...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values));
    set(handles.additionalFitPoint2Position,'String',...
        num2str(...
        length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values)));
else
    appdata.data{appdata.control.spectra.active}.blc.area.addPoint2 = value;
    set(handles.additionalFitPoint2Slider,'Value',value);
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitPoints_Refresh(handles.figure1);


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

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

switch get(hObject,'Value')
    case 0
        set(handles.additionalFitPoint1Slider,'Enable','Off');
        set(handles.additionalFitPoint1Position,'Enable','Off');
        set(handles.additionalFitPoint1PickButton,'Enable','Off');
        set(appdata.handles.axes1Point1,'Visible','Off');
        set(appdata.handles.axes2Point1,'Visible','Off');
        appdata.data{appdata.control.spectra.active}.blc.area.addPoint1 = [];
    case 1
        set(handles.additionalFitPoint1Slider,'Enable','On');
        set(handles.additionalFitPoint1Position,'Enable','On');
        set(handles.additionalFitPoint1PickButton,'Enable','On');
        appdata.data{appdata.control.spectra.active}.blc.area.addPoint1 = ...
            get(handles.additionalFitPoint1Slider,'Value');
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

if_fitPoints_Refresh(handles.figure1);


% --- Executes on button press in additionalFitPoint2Checkbox.
function additionalFitPoint2Checkbox_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

switch get(hObject,'Value')
    case 0
        set(handles.additionalFitPoint2Slider,'Enable','Off');
        set(handles.additionalFitPoint2Position,'Enable','Off');
        set(handles.additionalFitPoint2PickButton,'Enable','Off');
        set(appdata.handles.axes1Point2,'Visible','Off');
        set(appdata.handles.axes2Point2,'Visible','Off');
        appdata.data{appdata.control.spectra.active}.blc.area.addPoint2 = [];
    case 1
        set(handles.additionalFitPoint2Slider,'Enable','On');
        set(handles.additionalFitPoint2Position,'Enable','On');
        set(handles.additionalFitPoint2PickButton,'Enable','On');
        appdata.data{appdata.control.spectra.active}.blc.area.addPoint2 = ...
            get(handles.additionalFitPoint2Slider,'Value');
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

if_fitPoints_Refresh(handles.figure1);


% --- Executes on button press in additionalFitPoint1PickButton.
function additionalFitPoint1PickButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.control.point = 'addPoint1';
set(handles.figure1,'WindowButtonMotionFcn',@if_trackPointer);
set(handles.figure1,'WindowButtonDownFcn',@if_switchMeasurementPoint);

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


% --- Executes on button press in additionalFitPoint2PickButton.
function additionalFitPoint2PickButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.control.point = 'addPoint2';
set(handles.figure1,'WindowButtonMotionFcn',@if_trackPointer);
set(handles.figure1,'WindowButtonDownFcn',@if_switchMeasurementPoint);

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


% --- Executes on button press in reloadButton.
function reloadButton_Callback(hObject, eventdata, handles)
% hObject    handle to reloadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in correctionGoButton.
function correctionGoButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

methods = get(handles.correctionMethodPopupmenu,'String');
switch methods{get(handles.correctionMethodPopupmenu,'Value')}
    case '0th polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '0poly';
    case '1st polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '1poly';
    case '2nd polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '2poly';
    case '3rd polynomial'
        appdata.data{appdata.control.spectra.active}.blc.method = '3poly';
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

if_axis_Refresh(handles.figure1);
if_fitArea_Refresh(handles.figure1);
if_fitPoints_Refresh(handles.figure1);


% --- Executes on button press in correctionResetButton.
function correctionResetButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Reset struct containing the parameters of the correction
if isfield(appdata.data{appdata.control.spectra.active}.blc,'method')
    appdata.data{appdata.control.spectra.active}.blc = ...
        rmfield(appdata.data{appdata.control.spectra.active}.blc,'method');
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

if_axis_Refresh(handles.figure1);
if_fitArea_Refresh(handles.figure1);
if_fitPoints_Refresh(handles.figure1);


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

if_axis_Refresh(handles.figure1);
if_fitArea_Refresh(handles.figure1);
if_fitPoints_Refresh(handles.figure1);


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

% handle variable input arguments, because the 'CloseRequestFcn' does not
% accept to get additional parameters passed by the function call
if nargin == 3
    hObject = varargin{1};
    eventdata = varargin{2};
    handles = varargin{3};
else
    handles = guidata(gcbo);
end

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

modified = [];
for k = 1 : length(appdata.data)
    if isfield(appdata.data{k},'blc') && ...
            isfield(appdata.data{k}.blc,'method')
        modified(end+1) = k;
    end
end

if ~isempty(modified)
    selection = questdlg(...
        sprintf('%s %s\n - %s\n - %s\n - %s',...
        'There exist modified spectra in the GUI.',...
        'Do you want to',...
        'discard the modifications,',...
        'cancel the closing of the GUI, or do you want to ',...
        'apply the changes and close?'),...
        'Modifications exist. Really quit?',...
        'Discard',...
        'Cancel',...
        'Apply & Close',...
        'Apply & Close');

    switch selection,
        case 'Cancel',
            return;
        case 'Apply & Close'
            % Get appdata from parent window necessary for BLC
            if isfield(handles,'callerFunction') && ...
                    isfield(handles,'callerHandle')
                callerHandles = guidata(handles.callerHandle);
                if isfield(callerHandles,mfilename)
                    % Get appdata of the parent GUI
                    parentAppdata = getappdata(callerHandles.figure1);
                    for k = 1:length(modified)
                        [x y] = size(appdata.data{modified(k)}.data);
                        for l = 1:y
                            appdata.data{modified(k)}.data(:,l) = ...
                                appdata.data{modified(k)}.data(:,l) - ...
                                appdata.control.fit{modified(k)};
                        end
                        parentAppdata.data{modified(k)} = ...
                            appdata.data{modified(k)};
                    end
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
                    % Refresh axes in main GUI
                    %trEPR_GUI_main('if_axis_Refresh',handles.callerHandle);
                end
            end
        case 'Discard'
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
    set(handles.positionInTimePointsEdit,'Enable','Off');
    set(handles.positionInTimeValueEdit,'Enable','Off');
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

set(handles.leftFitAreaSlider,'Min',1);
set(handles.leftFitAreaSlider,'Max',...
    floor(length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2));
set(handles.leftFitAreaSlider,'Value',...
    10);
set(handles.leftFitAreaSlider,'SliderStep',...
    [1/(get(handles.leftFitAreaSlider,'Max')-1)...
    10/(get(handles.leftFitAreaSlider,'Max')-1)]);
set(handles.rightFitAreaSlider,'Min',1);
set(handles.rightFitAreaSlider,'Max',...
    floor(length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2));
set(handles.rightFitAreaSlider,'Value',...
    10);
set(handles.rightFitAreaSlider,'SliderStep',...
    [1/(get(handles.rightFitAreaSlider,'Max')-1)...
    10/(get(handles.rightFitAreaSlider,'Max')-1)]);
set(handles.additionalFitPoint1Slider,'Min',1);
set(handles.additionalFitPoint1Slider,'Max',...
    length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values));
set(handles.additionalFitPoint1Slider,'Value',...
    floor(length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2)...
    );
set(handles.additionalFitPoint1Slider,'SliderStep',...
    [1/(get(handles.additionalFitPoint1Slider,'Max')-1)...
    10/(get(handles.additionalFitPoint1Slider,'Max')-1)]);
set(handles.additionalFitPoint1Position,'String',...
    num2str(floor(length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2)...
    ));
set(handles.additionalFitPoint2Slider,'Min',1);
set(handles.additionalFitPoint2Slider,'Max',...
    length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values));
set(handles.additionalFitPoint2Slider,'Value',...
    floor(length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2)...
    );
set(handles.additionalFitPoint2Slider,'SliderStep',...
    [1/(get(handles.additionalFitPoint2Slider,'Max')-1)...
    10/(get(handles.additionalFitPoint2Slider,'Max')-1)]);
set(handles.additionalFitPoint2Position,'String',...
    num2str(floor(length(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2)...
    ));

if isempty(appdata.data{appdata.control.spectra.active}.blc.area.addPoint1)
    set(handles.additionalFitPoint1Checkbox,'Value',0)
    set(handles.additionalFitPoint1Slider,'Enable','Off');
    set(handles.additionalFitPoint1Position,'Enable','Off');
    set(handles.additionalFitPoint1PickButton,'Enable','Off');
end
if isempty(appdata.data{appdata.control.spectra.active}.blc.area.addPoint2)
    set(handles.additionalFitPoint2Checkbox,'Value',0)
    set(handles.additionalFitPoint2Slider,'Enable','Off');
    set(handles.additionalFitPoint2Position,'Enable','Off');
    set(handles.additionalFitPoint2PickButton,'Enable','Off');
end

if isfield(appdata.data{appdata.control.spectra.active}.blc,'method')
    if ~isempty(strfind(...
            appdata.data{appdata.control.spectra.active}.blc.method,...
            'poly'))
        set(handles.correctionMethodPopupmenu,'Value',...
            str2num(...
            appdata.data{appdata.control.spectra.active}.blc.method(1))+1);
    end
else
    set(handles.correctionMethodPopupmenu,'Value',1);
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
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
%cla(handles.axes1,'reset');
%cla(handles.axes2,'reset');
appdata.handles = struct();
% Convert G -> mT
if strcmp(appdata.data{appdata.control.spectra.active}.axes.yaxis.unit,'G')
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values / 10;
else
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values;
end
endOfSpectrum = mean(...
    appdata.data{appdata.control.spectra.active}.data(...
    :,length(xaxis)-10:length(xaxis)...
    ),...
    2);
if isfield(appdata.data{appdata.control.spectra.active}.blc,'method')
    if ~isempty(strfind(...
            appdata.data{appdata.control.spectra.active}.blc.method,...
            'poly'))
        degree = str2num(...
            appdata.data{appdata.control.spectra.active}.blc.method(1));
        [f,p,delta,mu,S] = polyFit(...
            [yaxis' endOfSpectrum], ...
            degree, ...
            appdata.data{appdata.control.spectra.active}.blc.area.left, ...
            appdata.data{appdata.control.spectra.active}.blc.area.right);
        % Assign fit parameters to respective structures of currently
        % displayed spectrum (will be retransferred to main GUI)
        appdata.data{appdata.control.spectra.active}.blc.coefficients = p;
        appdata.data{appdata.control.spectra.active}.blc.statistics.S = S;
        appdata.data{appdata.control.spectra.active}.blc.statistics.mu = mu;
        appdata.data{appdata.control.spectra.active}.blc.statistics.delta = delta;
        % Assign fit to control structure of the BLC GUI (used for the
        % final regression before the data are retransferred to the main
        % GUI)
        appdata.control.fit{appdata.control.spectra.active} = f;
        plot(...
            handles.axes2,...
            yaxis,...
            endOfSpectrum,...
            yaxis,...
            f...
            );
    end
else
    plot(...
        handles.axes2,...
        yaxis,...
        endOfSpectrum...
        );
end
if exist('f','var')
    plot(...
        handles.axes1,...
        yaxis,...
        appdata.data{appdata.control.spectra.active}.data(...
        :,floor(appdata.data{appdata.control.spectra.active}.t)...
        )-f...
        );
else
    plot(...
        handles.axes1,...
        yaxis,...
        appdata.data{appdata.control.spectra.active}.data(...
        :,floor(appdata.data{appdata.control.spectra.active}.t)...
        )...
        );
end
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
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end


% --- Refresh fit areas (axis)
function if_fitArea_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Get y axis (field axis) and convert G -> mT
if strcmp(appdata.data{appdata.control.spectra.active}.axes.yaxis.unit,'G')
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values / 10;
else
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values;
end
left = appdata.data{appdata.control.spectra.active}.blc.area.left;
right = appdata.data{appdata.control.spectra.active}.blc.area.right;

% Refresh sliders and edit fields
set(handles.leftFitAreaSlider,'Value',...
    appdata.data{appdata.control.spectra.active}.blc.area.left);
set(handles.rightFitAreaSlider,'Value',...
    appdata.data{appdata.control.spectra.active}.blc.area.right);
set(handles.leftFitAreaEdit,'String',num2str(...
    appdata.data{appdata.control.spectra.active}.blc.area.left));
set(handles.rightFitAreaEdit,'String',num2str(...
    appdata.data{appdata.control.spectra.active}.blc.area.right));


if isfield(appdata.handles,'axes1Left') && isfield(appdata.handles,'axes1Right') && ...
        isfield(appdata.handles,'axes2Left') && isfield(appdata.handles,'axes2Right')
    set(appdata.handles.axes1Left,...
        'XData',...
        [yaxis(1) yaxis(1+left)]);
    set(appdata.handles.axes1Right,...
        'XData',...
        [yaxis(end-right) yaxis(end)]);
    set(appdata.handles.axes2Left,...
        'XData',...
        [yaxis(1) yaxis(1+left)]);
    set(appdata.handles.axes2Right,...
        'XData',...
        [yaxis(end-right) yaxis(end)]);
    refreshdata(handles.figure1);
else
    axes(handles.axes1);
    yval = get(handles.axes1,'YLim');
    appdata.handles.axes1Left = line(...
        [yaxis(1) yaxis(1+left)],...
        [yval(1) yval(1)],...
        'Color','r','LineWidth',6);
    appdata.handles.axes1Right = line(...
        [yaxis(end-right) yaxis(end)],...
        [yval(1) yval(1)],...
        'Color','r','LineWidth',6);
    axes(handles.axes2);
    yval = get(handles.axes2,'YLim');
    appdata.handles.axes2Left = line(...
        [yaxis(1) yaxis(1+left)],...
        [yval(1) yval(1)],...
        'Color','r','LineWidth',6);
    appdata.handles.axes2Right = line(...
        [yaxis(end-right) yaxis(end)],...
        [yval(1) yval(1)],...
        'Color','r','LineWidth',6);
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end


% --- Refresh display of additional fit points
function if_fitPoints_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Get y axis (field axis) and convert G -> mT
if strcmp(appdata.data{appdata.control.spectra.active}.axes.yaxis.unit,'G')
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values / 10;
else
    yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values;
end

% Set values for additional points
if isempty(appdata.data{appdata.control.spectra.active}.blc.area.addPoint1)
    addPoint1 = floor(length(...
        appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2);
else
    addPoint1 = appdata.data{appdata.control.spectra.active}.blc.area.addPoint1;
    set(handles.additionalFitPoint1Checkbox,'Value',1)
    set(handles.additionalFitPoint1Slider,'Value',addPoint1)
    set(handles.additionalFitPoint1Slider,'Enable','On');
    set(handles.additionalFitPoint1Position,'Enable','On');
    set(handles.additionalFitPoint1Position,'String',num2str(addPoint1))
    set(handles.additionalFitPoint1PickButton,'Enable','On');
end
if isempty(appdata.data{appdata.control.spectra.active}.blc.area.addPoint2)
    addPoint2 = floor(length(...
        appdata.data{appdata.control.spectra.active}.axes.yaxis.values)/2);
else
    addPoint2 = appdata.data{appdata.control.spectra.active}.blc.area.addPoint2;
    set(handles.additionalFitPoint2Checkbox,'Value',1)
    set(handles.additionalFitPoint2Slider,'Value',addPoint2)
    set(handles.additionalFitPoint2Slider,'Enable','On');
    set(handles.additionalFitPoint2Position,'Enable','On');
    set(handles.additionalFitPoint2Position,'String',num2str(addPoint2))
    set(handles.additionalFitPoint2PickButton,'Enable','On');
end

if get(handles.additionalFitPoint1Checkbox,'Value')
    if isfield(appdata.handles,'axes1Point1') && ...
            isfield(appdata.handles,'axes2Point1')
        set(appdata.handles.axes1Point1,...
            'XData',...
            [yaxis(addPoint1) yaxis(addPoint1)]);
        set(appdata.handles.axes2Point1,...
            'XData',...
            [yaxis(addPoint1) yaxis(addPoint1)]);
    else
        axes(handles.axes1);
        yval = get(handles.axes1,'YLim');
        appdata.handles.axes1Point1 = line(...
            [yaxis(addPoint1) yaxis(addPoint1)],...
            [yval(1) yval(end)],...
            'Color','r','LineWidth',1);
        axes(handles.axes2);
        yval = get(handles.axes2,'YLim');
        appdata.handles.axes2Point1 = line(...
            [yaxis(addPoint1) yaxis(addPoint1)],...
            [yval(1) yval(end)],...
            'Color','r','LineWidth',1);
    end
    if isfield(appdata.handles,'axes1Point1') && ...
            isfield(appdata.handles,'axes2Point1')
        set(appdata.handles.axes1Point1,'Visible','On');
        set(appdata.handles.axes2Point1,'Visible','On');
    end
else
    if isfield(appdata.handles,'axes1Point1') && ...
            isfield(appdata.handles,'axes2Point1')
        set(appdata.handles.axes1Point1,'Visible','Off');
        set(appdata.handles.axes2Point1,'Visible','Off');
    end
end
if get(handles.additionalFitPoint2Checkbox,'Value')
    if isfield(appdata.handles,'axes1Point2') && ...
            isfield(appdata.handles,'axes2Point2')
        set(appdata.handles.axes1Point2,...
            'XData',...
            [yaxis(addPoint2) yaxis(addPoint2)]);
        set(appdata.handles.axes2Point2,...
            'XData',...
            [yaxis(addPoint2) yaxis(addPoint2)]);
    else
        axes(handles.axes1);
        yval = get(handles.axes1,'YLim');
        appdata.handles.axes1Point2 = line(...
            [yaxis(addPoint2) yaxis(addPoint2)],...
            [yval(1) yval(end)],...
            'Color','r','LineWidth',1);
        axes(handles.axes2);
        yval = get(handles.axes2,'YLim');
        appdata.handles.axes2Point2 = line(...
            [yaxis(addPoint2) yaxis(addPoint2)],...
            [yval(1) yval(end)],...
            'Color','r','LineWidth',1);
    end
    if isfield(appdata.handles,'axes1Point2') && ...
            isfield(appdata.handles,'axes2Point2')
        set(appdata.handles.axes1Point2,'Visible','On');
        set(appdata.handles.axes2Point2,'Visible','On');
    end
else
    if isfield(appdata.handles,'axes1Point2') && ...
            isfield(appdata.handles,'axes2Point2')
        set(appdata.handles.axes1Point2,'Visible','Off');
        set(appdata.handles.axes2Point2,'Visible','Off');
    end
end

% Refresh handles and appdata of the current GUI
guidata(handles.figure1,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end


% --- Get pointer position in current axis
function if_trackPointer(hObject,event)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

cp = get(hObject,'CurrentPoint');
axis1Position = get(handles.axes1,'Position');
ac1 = [...
    axis1Position(1)...
    axis1Position(2)...
    axis1Position(1)+axis1Position(3)...
    axis1Position(2)+axis1Position(4)];
axis2Position = get(handles.axes2,'Position');
ac2 = [...
    axis2Position(1)...
    axis2Position(2)...
    axis2Position(1)+axis2Position(3)...
    axis2Position(2)+axis2Position(4)];

if (cp(1)>ac1(1) && cp(1)<=ac1(3) && cp(2)>ac1(2) && cp(2)<=ac1(4)) || ...
        (cp(1)>ac2(1) && cp(1)<=ac2(3) && cp(2)>ac2(2) && cp(2)<=ac2(4))
    set(hObject,'Pointer','fullcrosshair');
else
    set(hObject,'Pointer','arrow');
end


% --- Get pointer position in current axis
function if_switchMeasurementPoint(hObject,event)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

cp = get(hObject,'CurrentPoint');
axis1Position = get(handles.axes1,'Position');
ac1 = [...
    axis1Position(1)...
    axis1Position(2)...
    axis1Position(1)+axis1Position(3)...
    axis1Position(2)+axis1Position(4)];

if ~isempty(get(handles.axes1,'Children'))
    % if there are some data displayed
    xdata = get(get(handles.axes1,'Children'),'XData');
    ydata = get(get(handles.axes1,'Children'),'YData');
    
    value=interp1(...
        linspace(1,axis1Position(3),length(xdata{end})),...
        1:length(xdata{end}),...
        cp(1)-ac1(1),'nearest');
    
    switch appdata.control.point
        case 'left'
            if value < get(handles.leftFitAreaSlider,'Min')
                appdata.data{appdata.control.spectra.active}.blc.area.left = ...
                    get(handles.leftFitAreaSlider,'Min');
                set(handles.leftFitAreaSlider,'Value',...
                    get(handles.leftFitAreaSlider,'Min'));
                set(handles.leftFitAreaEdit,'String',...
                    num2str(get(handles.leftFitAreaSlider,'Min')));
            elseif value > get(handles.leftFitAreaSlider,'Max')
                appdata.data{appdata.control.spectra.active}.blc.area.left = ...
                    get(handles.leftFitAreaSlider,'Max');
                set(handles.leftFitAreaSlider,'Value',...
                    get(handles.leftFitAreaSlider,'Max'));
                set(handles.leftFitAreaEdit,'String',...
                    num2str(get(handles.leftFitAreaSlider,'Max')));
            else
                appdata.data{appdata.control.spectra.active}.blc.area.left = value;
                set(handles.leftFitAreaSlider,'Value',value);
                set(handles.leftFitAreaEdit,'String',num2str(value));
            end
        case 'right'
            value = length(...
                appdata.data{appdata.control.spectra.active}.axes.yaxis.values) - value;
            if value < get(handles.rightFitAreaSlider,'Min')
                appdata.data{appdata.control.spectra.active}.blc.area.right = ...
                    get(handles.rightFitAreaSlider,'Min');
                set(handles.rightFitAreaSlider,'Value',...
                    get(handles.rightFitAreaSlider,'Min'));
                set(handles.rightFitAreaEdit,'String',...
                    num2str(get(handles.rightFitAreaSlider,'Min')));
            elseif value > get(handles.rightFitAreaSlider,'Max')
                appdata.data{appdata.control.spectra.active}.blc.area.right = ...
                    get(handles.rightFitAreaSlider,'Max');
                set(handles.rightFitAreaSlider,'Value',...
                    get(handles.rightFitAreaSlider,'Max'));
                set(handles.rightFitAreaEdit,'String',...
                    num2str(get(handles.rightFitAreaSlider,'Max')));
            else
                appdata.data{appdata.control.spectra.active}.blc.area.right = value;
                set(handles.rightFitAreaSlider,'Value',value);
                set(handles.rightFitAreaEdit,'String',num2str(value));
            end
        case 'addPoint1'
            appdata.data{appdata.control.spectra.active}.blc.area.addPoint1 = value;
            set(handles.additionalFitPoint1Slider,'Value',value);
            set(handles.additionalFitPoint1Position,'String',num2str(value));
        case 'addPoint2'
            appdata.data{appdata.control.spectra.active}.blc.area.addPoint2 = value;
            set(handles.additionalFitPoint2Slider,'Value',value);
            set(handles.additionalFitPoint2Position,'String',num2str(value));
    end
end

set(handles.figure1,'WindowButtonMotionFcn','');
set(handles.figure1,'WindowButtonDownFcn','');
set(handles.figure1,'Pointer','arrow');
refresh;

% Refresh appdata of the current GUI
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_fitArea_Refresh(handles.figure1);
if_fitPoints_Refresh(handles.figure1);
