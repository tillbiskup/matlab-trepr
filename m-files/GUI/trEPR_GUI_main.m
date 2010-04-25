function varargout = trEPR_GUI_main(varargin)
% TREPR_GUI_MAIN M-file for trEPR_GUI_main.fig
%      TREPR_GUI_MAIN, by itself, creates a new TREPR_GUI_MAIN or raises
%      the existing singleton*.
%
%      H = TREPR_GUI_MAIN returns the handle to a new TREPR_GUI_MAIN or the
%      handle to the existing singleton*.
%
%      TREPR_GUI_MAIN('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in TREPR_GUI_MAIN.M with the given
%      input arguments.
%
%      TREPR_GUI_MAIN('Property','Value',...) creates a new TREPR_GUI_MAIN
%      or raises the existing singleton*.  Starting from the left, property
%      value pairs are applied to the GUI before
%      trEPR_GUI_main_OpeningFunction gets called.  An unrecognized
%      property name or invalid value makes property application stop.  All
%      inputs are passed to trEPR_GUI_main_OpeningFcn via varargin. 
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_main

% Last Modified by GUIDE v2.5 20-Apr-2010 22:41:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trEPR_GUI_main_OpeningFcn, ...
                   'gui_OutputFcn',  @trEPR_GUI_main_OutputFcn, ...
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


% --- Executes just before trEPR_GUI_main is made visible.
function trEPR_GUI_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trEPR_GUI_main (see VARARGIN)

set(hObject,'Name','trEPR toolbox : main window');

set(handles.figure1,'CloseRequestFcn',@closeGUI);

% Choose default command line output for trEPR_GUI_main
handles.output = hObject;

% set handle to the own main figure, named as the mfile
handles = setfield(handles,mfilename,hObject);

% Update handles structure
guidata(hObject, handles);

% Some initialization of the axes
set(handles.axes1,'XTick',[]);
set(handles.axes1,'YTick',[]);

% UIWAIT makes trEPR_GUI_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Set application data (at this stage only empty structures)
data = cell(1); % store the data (spectra) together with their information
configuration = struct(); % store the configuration information for the GUI
% --- store important control values, such as the currently active spectrum etc.
control = struct(...
    'spectra', struct(...
    'active',0,...
    'visible',cell(1),...
    'invisible',cell(1),...
    'modified',cell(1)...
    ),...
    'measure', struct(...
    'point',1,...
    'x1val',1,...
    'y1val',1,...
    'x1ind',1,...
    'y1ind',1 ...
    ));

displayTypes = get(handles.displayTypePopupmenu,'String');
control.axis.displayType = char(...
    displayTypes{get(handles.displayTypePopupmenu,'Value')});

setappdata(handles.figure1,'data',data);
setappdata(handles.figure1,'configuration',configuration);
setappdata(handles.figure1,'control',control);

% --- Outputs from this function are returned to the command line.
function varargout = trEPR_GUI_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menuFileExit_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closeGUI(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuHelp_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in spectraInvisibleListbox.
function spectraInvisibleListbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraInvisibleListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns spectraInvisibleListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectraInvisibleListbox


% --- Executes during object creation, after setting all properties.
function spectraInvisibleListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraInvisibleListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
    if_spectraVisibleListbox_Refresh(handles.figure1);
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


% --- Executes on button press in spectraShowButton.
function spectraShowButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraShowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if_spectraShow;


% --- Executes on button press in spectraHideButton.
function spectraHideButton_Callback(hObject, eventdata, handles)

if_spectraHide;


% --- Executes on button press in spectraOffsetCorrectionCheckbox.
function spectraOffsetCorrectionCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraOffsetCorrectionCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectraOffsetCorrectionCheckbox


% --- Executes on button press in loadDirectoryCheckbox.
function loadDirectoryCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to loadDirectoryCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadDirectoryCheckbox


% --- Executes on button press in spectraDriftCorrectionCheckbox.
function spectraDriftCorrectionCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraDriftCorrectionCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectraDriftCorrectionCheckbox


% --- Executes on slider movement.
function spectraScrollSlider_Callback(hObject, eventdata, handles)
% hObject    handle to spectraScrollSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType;
    case 'B0 spectra'
        set(handles.timeEditIndex,'String',...
            num2str(floor(get(handles.spectraScrollSlider,'Value')))...
            );
        appdata.data{appdata.control.spectra.active}.t = ...
            floor(get(handles.spectraScrollSlider,'Value'));
        set(handles.timeEditValue,'String',...
            appdata.data{appdata.control.spectra.active}.axes.xaxis.values(...
            appdata.data{appdata.control.spectra.active}.t));
    case 'transients'
        set(handles.b0EditIndex,'String',...
            num2str(floor(get(handles.spectraScrollSlider,'Value')))...
            );
        appdata.data{appdata.control.spectra.active}.b0 = ...
            floor(get(handles.spectraScrollSlider,'Value'));
        set(handles.b0EditValue,'String',...
            appdata.data{appdata.control.spectra.active}.axes.yaxis.values(...
            appdata.data{appdata.control.spectra.active}.b0));
end


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

if_axis_Refresh(handles.figure1);

% --- Executes during object creation, after setting all properties.
function spectraScrollSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraScrollSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function scaleXSlider_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

if get(gcbo,'Value') < 0
    value = 1/abs(get(gcbo,'Value')-1);
else
    value = get(gcbo,'Value')+1;
end

switch appdata.control.axis.displayType
    case 'B0 spectra'
        appdata.data{appdata.control.spectra.active}.Sb0 = value;
        set(handles.sb0Edit,'String',num2str(value));
    case 'transients'
        appdata.data{appdata.control.spectra.active}.St = value;
        set(handles.stEdit,'String',num2str(value));
end

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function scaleXSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function scaleYSlider_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

if get(gcbo,'Value') < 0
    value = 1/abs(get(gcbo,'Value')-1);
else
    value = get(gcbo,'Value')+1;
end

appdata.data{appdata.control.spectra.active}.Sy = value;
set(handles.syEdit,'String',num2str(value));

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function scaleYSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function displaceYSlider_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.Dy = ...
	get(gcbo,'Value');
set(handles.dyEdit,'String',...
	get(gcbo,'Value'));

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function displaceYSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displaceYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function displaceXSlider_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case 'B0 spectra'
        appdata.data{appdata.control.spectra.active}.Db0 = ...
        	get(gcbo,'Value');
        set(handles.db0Edit,'String',...
        	get(gcbo,'Value'));
    case 'transients'
        appdata.data{appdata.control.spectra.active}.Dt = ...
        	get(gcbo,'Value');
        set(handles.dtEdit,'String',...
        	get(gcbo,'Value'));
end

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function displaceXSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displaceXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in spectraSaveButton.
function spectraSaveButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraSaveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraRemoveButton.
function spectraRemoveButton_Callback(hObject, eventdata, handles)

if_spectraRemove(hObject)


% --- Executes on button press in spectraSaveAsButton.
function spectraSaveAsButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraSaveAsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraInfoButton.
function spectraInfoButton_Callback(hObject, eventdata, handles)

trEPR_GUI_info(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --- Executes on selection change in displayTypePopupmenu.
function displayTypePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to displayTypePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

contents = get(hObject,'String');
appdata.control.axis.displayType = char(contents{get(hObject,'Value')});

switch appdata.control.axis.displayType
    case 'B0 spectra'
        set(handles.spectraScrollSlider,'Value',...
            appdata.data{...
            appdata.control.spectra.active}.t);

        centerXaxisValue = ...
            (appdata.data{appdata.control.spectra.active}.axes.yaxis.values(end)-...
            appdata.data{appdata.control.spectra.active}.axes.yaxis.values(1))/2;

        set(handles.displaceXSlider,'Value',...
            appdata.data{...
            appdata.control.spectra.active}.Db0);
        set(handles.displaceXSlider,'Min',-centerXaxisValue);
        set(handles.displaceXSlider,'Max',centerXaxisValue);
        if get(handles.displaceXSlider,'Value') < -centerXaxisValue
            set(handles.displaceXSlider,'Value',-centerXaxisValue);
        elseif get(handles.displaceXSlider,'Value') > centerXaxisValue
            set(handles.displaceXSlider,'Value',centerXaxisValue);
        end
    case 'transients'
        set(handles.spectraScrollSlider,'Value',...
            appdata.data{...
            appdata.control.spectra.active}.b0);

        centerXaxisValue = ...
            (appdata.data{appdata.control.spectra.active}.axes.xaxis.values(end)-...
            appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1))/2;

        set(handles.displaceXSlider,'Value',...
            appdata.data{...
            appdata.control.spectra.active}.Dt);
        set(handles.displaceXSlider,'Min',-centerXaxisValue);
        set(handles.displaceXSlider,'Max',centerXaxisValue);
        if get(handles.displaceXSlider,'Value') < -centerXaxisValue
            set(handles.displaceXSlider,'Value',-centerXaxisValue);
        elseif get(handles.displaceXSlider,'Value') > centerXaxisValue
            set(handles.displaceXSlider,'Value',centerXaxisValue);
        end
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


% --- Executes during object creation, after setting all properties.
function displayTypePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displayTypePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in infobox.
function infobox_Callback(hObject, eventdata, handles)
% hObject    handle to infobox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns infobox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from infobox


% --- Executes during object creation, after setting all properties.
function infobox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infobox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuFileLoad_Callback(hObject, eventdata, handles)
if if_checkCompensationMethods
    return;
end

if get(handles.spectraLoadDirectoryCheckbox,'Value');
    FileName = uigetdir(...
        '',...
        'Select directory to load the files from');
else %if multiple
    [FileName,PathName,FilterIndex] = uigetfile(...
        '*.*',...
        'Select files to load',...
        'MultiSelect','on');
    if iscell(FileName)
        for k=1:length(FileName)
            FileName{k} = fullfile(PathName,FileName{k});
        end
    elseif ~isnumeric(FileName)
        FileName = fullfile(PathName,FileName);
    end
end

if ~isnumeric(FileName)            % uigetfile returns 0 if cancelled
    if_loadSpectra(FileName);
end


% --------------------------------------------------------------------
function menuHelpAbout_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelpAbout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_help_about(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --------------------------------------------------------------------
function menuFileSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileSaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function db0Edit_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

value = str2double(get(hObject,'String'));
min = get(handles.displaceXSlider,'Min');
max = get(handles.displaceXSlider,'Max');

switch appdata.control.axis.displayType
    case 'B0 spectra'
        if value>=min && value<=max
            set(handles.displaceXSlider,'Value',value);
            appdata.data{appdata.control.spectra.active}.Db0 = ...
                get(gcbo,'Value');
        elseif value<min
            set(handles.displaceXSlider,'Value',min);
            appdata.data{appdata.control.spectra.active}.Db0 = min;
        else
            set(handles.displaceXSlider,'Value',max);
            appdata.data{appdata.control.spectra.active}.Db0 = max;
        end    
    case 'transients'
        if value>=min && value<=max
            set(handles.displaceXSlider,'Value',value);
            appdata.data{appdata.control.spectra.active}.Dt = ...
                get(gcbo,'Value');
        elseif value<min
            set(handles.displaceXSlider,'Value',min);
            appdata.data{appdata.control.spectra.active}.Dt = min;
        else
            set(handles.displaceXSlider,'Value',max);
            appdata.data{appdata.control.spectra.active}.Dt = max;
        end    
end

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function db0Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to db0Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dtEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dtEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dtEdit as text
%        str2double(get(hObject,'String')) returns contents of dtEdit as a double


% --- Executes during object creation, after setting all properties.
function dtEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dtEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dyEdit_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

value = str2double(get(hObject,'String'));
min = get(handles.displaceYSlider,'Min');
max = get(handles.displaceYSlider,'Max');

if value>=min && value<=max
    set(handles.displaceYSlider,'Value',value);
    appdata.data{appdata.control.spectra.active}.Dy = ...
        get(gcbo,'Value');
elseif value<min
    set(handles.displaceYSlider,'Value',min);
    appdata.data{appdata.control.spectra.active}.Dy = min;
else
    set(handles.displaceYSlider,'Value',max);
    appdata.data{appdata.control.spectra.active}.Dy = max;
end    

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function dyEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sb0Edit_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

min = 1/abs(get(handles.scaleXSlider,'Min')-1);
max = get(handles.scaleXSlider,'Max')+1;

value = str2double(get(hObject,'String'));

if value>=min && value<=max
    if value < 1
        sliderValue = -(1/value)+1;
    else
        sliderValue = value-1;
    end
    set(handles.scaleXSlider,'Value',sliderValue);
    appdata.data{appdata.control.spectra.active}.Sx = ...
        value;
elseif value<min
    set(handles.scaleXSlider,'Value',get(handles.scaleXSlider,'Min'));
    appdata.data{appdata.control.spectra.active}.Sx = min;
else
    set(handles.scaleXSlider,'Value',get(handles.scaleXSlider,'Max'));
    appdata.data{appdata.control.spectra.active}.Sx = max;
end    

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function sb0Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sb0Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function stEdit_Callback(hObject, eventdata, handles)
% hObject    handle to stEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stEdit as text
%        str2double(get(hObject,'String')) returns contents of stEdit as a double


% --- Executes during object creation, after setting all properties.
function stEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function syEdit_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

min = 1/abs(get(handles.scaleYSlider,'Min')-1);
max = get(handles.scaleYSlider,'Max')+1;

value = str2double(get(hObject,'String'));

if value>=min && value<=max
    if value < 1
        sliderValue = -(1/value)+1;
    else
        sliderValue = value-1;
    end
    set(handles.scaleYSlider,'Value',sliderValue);
    appdata.data{appdata.control.spectra.active}.Sy = ...
        value;
elseif value<min
    set(handles.scaleYSlider,'Value',get(handles.scaleYSlider,'Min'));
    appdata.data{appdata.control.spectra.active}.Sy = min;
else
    set(handles.scaleYSlider,'Value',get(handles.scaleYSlider,'Max'));
    appdata.data{appdata.control.spectra.active}.Sy = max;
end    

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function syEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to syEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function twodimEdit_Callback(hObject, eventdata, handles)
% hObject    handle to twodimEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of twodimEdit as text
%        str2double(get(hObject,'String')) returns contents of twodimEdit as a double


% --- Executes during object creation, after setting all properties.
function twodimEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to twodimEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in spectraLoadButton.
function spectraLoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraLoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if if_checkCompensationMethods
    return;
end

if get(handles.spectraLoadDirectoryCheckbox,'Value');
    FileName = uigetdir(...
        '',...
        'Select directory to load the files from');
else %if multiple
    [FileName,PathName,FilterIndex] = uigetfile(...
        '*.*',...
        'Select files to load',...
        'MultiSelect','on');
    if iscell(FileName)
        for k=1:length(FileName)
            FileName{k} = fullfile(PathName,FileName{k});
        end
    elseif ~isnumeric(FileName)
        FileName = fullfile(PathName,FileName);
    end
end

if ~isnumeric(FileName)            % uigetfile returns 0 if cancelled
    if_loadSpectra(FileName);
end


% --- Executes on button press in spectraLoadPretriggerOffsetCorrectionCheckbox.
function spectraLoadPretriggerOffsetCorrectionCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraLoadPretriggerOffsetCorrectionCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectraLoadPretriggerOffsetCorrectionCheckbox


% --- Executes on button press in spectraLoadDirectoryCheckbox.
function spectraLoadDirectoryCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraLoadDirectoryCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectraLoadDirectoryCheckbox


% --- Executes on button press in spectraCombineFilesCheckbox.
function spectraCombineFilesCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraCombineFilesCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectraCombineFilesCheckbox


% --- Executes on button press in spectraLoadBackgroundCorrectionCheckbox.
function spectraLoadBackgroundCorrectionCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraLoadBackgroundCorrectionCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spectraLoadBackgroundCorrectionCheckbox


function timeEditIndex_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

value = str2double(get(hObject,'String'));
min = get(handles.spectraScrollSlider,'Min');
max = get(handles.spectraScrollSlider,'Max');

if value>=min && value<=max
    set(handles.spectraScrollSlider,'Value',value);
elseif value<min
    set(handles.spectraScrollSlider,'Value',min);
else
    set(handles.spectraScrollSlider,'Value',max);
end    
set(handles.timeEditIndex,'String',...
    num2str(floor(get(handles.spectraScrollSlider,'Value')))...
    );
appdata.data{appdata.control.spectra.active}.t = ...
    floor(get(handles.spectraScrollSlider,'Value'));

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function timeEditIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeEditIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function b0EditIndex_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

value = str2double(get(hObject,'String'));
min = get(handles.spectraScrollSlider,'Min');
max = get(handles.spectraScrollSlider,'Max');

if value>=min && value<=max
    set(handles.spectraScrollSlider,'Value',value);
elseif value<min
    set(handles.spectraScrollSlider,'Value',min);
else
    set(handles.spectraScrollSlider,'Value',max);
end    

set(handles.b0EditIndex,'String',...
    num2str(floor(get(handles.spectraScrollSlider,'Value')))...
    );
appdata.data{appdata.control.spectra.active}.b0 = ...
    floor(get(handles.spectraScrollSlider,'Value'));

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function b0EditIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b0EditIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToolsAccumulate_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsAccumulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_ACC(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --------------------------------------------------------------------
function menuToolsCorrections_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToolsPreferences_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsPreferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToolsCorrectionsPretriggerOffset_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsPretriggerOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

% Call functions only if there is something to compensate
if appdata.control.spectra.active > 0
    if_POC;
    if_axis_Refresh(handles.figure1);
end

% --------------------------------------------------------------------
function menuToolsCorrectionsBackground_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

% Call functions only if there is something to compensate
if appdata.control.spectra.active > 0
    if_BGC;
    if_axis_Refresh(handles.figure1);
end

% --------------------------------------------------------------------
function menuToolsCorrectionsDrift_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

% Call functions only if there is something to compensate
if appdata.control.spectra.active > 0
%    if_POC;
%    if_axis_Refresh(handles.figure1);
end

% --------------------------------------------------------------------
function menuToolsCorrectionsBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_BLC(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


function measureX1editIndex_Callback(hObject, eventdata, handles)
% hObject    handle to measureX1editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureX1editIndex as text
%        str2double(get(hObject,'String')) returns contents of measureX1editIndex as a double


% --- Executes during object creation, after setting all properties.
function measureX1editIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureX1editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureX2editIndex_Callback(hObject, eventdata, handles)
% hObject    handle to measureX2editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureX2editIndex as text
%        str2double(get(hObject,'String')) returns contents of measureX2editIndex as a double


% --- Executes during object creation, after setting all properties.
function measureX2editIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureX2editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureY2editIndex_Callback(hObject, eventdata, handles)
% hObject    handle to measureY2editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureY2editIndex as text
%        str2double(get(hObject,'String')) returns contents of measureY2editIndex as a double


% --- Executes during object creation, after setting all properties.
function measureY2editIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureY2editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureDeltaXeditIndex_Callback(hObject, eventdata, handles)
% hObject    handle to measureDeltaXeditIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureDeltaXeditIndex as text
%        str2double(get(hObject,'String')) returns contents of measureDeltaXeditIndex as a double


% --- Executes during object creation, after setting all properties.
function measureDeltaXeditIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureDeltaXeditIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureDeltaYeditIndex_Callback(hObject, eventdata, handles)
% hObject    handle to measureDeltaYeditIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureDeltaYeditIndex as text
%        str2double(get(hObject,'String')) returns contents of measureDeltaYeditIndex as a double


% --- Executes during object creation, after setting all properties.
function measureDeltaYeditIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureDeltaYeditIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureY1editIndex_Callback(hObject, eventdata, handles)
% hObject    handle to measureY1editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureY1editIndex as text
%        str2double(get(hObject,'String')) returns contents of measureY1editIndex as a double


% --- Executes during object creation, after setting all properties.
function measureY1editIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureY1editIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in measurePickButton.
function measurePickButton_Callback(hObject, eventdata, handles)
% hObject    handle to measurePickButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get handles and appdata of the current GUI
guidata(hObject, handles);
appdata = getappdata(handles.figure1);

appdata.control.measure.point = 1;
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

% --- Executes on button press in measureClearButton.
function measureClearButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

set(handles.figure1,'WindowButtonMotionFcn','');
set(handles.figure1,'WindowButtonDownFcn','');

set(handles.measureX1editIndex,'String','1');
set(handles.measureY1editIndex,'String','1');
set(handles.measureX2editIndex,'String','1');
set(handles.measureY2editIndex,'String','1');
set(handles.measureDeltaXeditIndex,'String','0');
set(handles.measureDeltaYeditIndex,'String','0');

set(handles.measureX1editValue,'String','1');
set(handles.measureY1editValue,'String','1');
set(handles.measureX2editValue,'String','1');
set(handles.measureY2editValue,'String','1');
set(handles.measureDeltaXeditValue,'String','0');
set(handles.measureDeltaYeditValue,'String','0');

appdata.control.measure.x1val = 1;
appdata.control.measure.x1ind = 1;
appdata.control.measure.y1val = 1;
appdata.control.measure.y1ind = 1;

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


% --- Executes on button press in spectraAccumulateButton.
function spectraAccumulateButton_Callback(hObject, eventdata, handles)

trEPR_GUI_ACC(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --- Executes on button press in axisExportButton.
function axisExportButton_Callback(hObject, eventdata, handles)

trEPR_GUI_export(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);

% --- Executes on button press in axisResetButton.
function axisResetButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

set(handles.db0Edit,'String','0');
set(handles.dtEdit,'String','0');
set(handles.dyEdit,'String','0');
%set(handles.sb0Edit,'String','1');
%set(handles.stEdit,'String','1');
set(handles.syEdit,'String','1');

appdata.data{appdata.control.spectra.active}.Db0 = 0;
appdata.data{appdata.control.spectra.active}.Dt = 0;
appdata.data{appdata.control.spectra.active}.Dy = 0;
%appdata.data{appdata.control.spectra.active}.Sb0 = 0;
%appdata.data{appdata.control.spectra.active}.St = 0;
appdata.data{appdata.control.spectra.active}.Sy = 1;

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

% --------------------------------------------------------------------
function menuView_Callback(hObject, eventdata, handles)
% hObject    handle to menuView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Conditionals to check whether the respective windows are open or not
% to toggle the 'Checked' property of the respective menu item

if isfield(handles,'trEPR_GUI_accumulate')
    set(handles.menuViewAccumulate, 'Checked', 'on');
else
    set(handles.menuViewAccumulate, 'Checked', 'off');
end    

if isfield(handles,'trEPR_GUI_BLC')
    set(handles.menuViewBaselineCorrection, 'Checked', 'on');
else
    set(handles.menuViewBaselineCorrection, 'Checked', 'off');
end

if isfield(handles,'trEPR_GUI_export')
    set(handles.menuViewExportPlot, 'Checked', 'on');
else
    set(handles.menuViewExportPlot, 'Checked', 'off');
end

if isfield(handles,'trEPR_GUI_plotproperties')
    set(handles.menuViewPlotProperties, 'Checked', 'on');
else
    set(handles.menuViewPlotProperties, 'Checked', 'off');
end

if isfield(handles,'trEPR_GUI_info')
    set(handles.menuViewInformation, 'Checked', 'on');
else
    set(handles.menuViewInformation, 'Checked', 'off');
end


% --------------------------------------------------------------------
function menuViewAccumulate_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewAccumulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
else 
    set(gcbo, 'Checked', 'on');
    handles
end

% --------------------------------------------------------------------
function menuViewBaselineCorrection_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewBaselineCorrection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    
    trEPR_GUI_BLC('closeGUI',hObject, eventdata, handles);
else 
    set(gcbo, 'Checked', 'on');

    trEPR_GUI_BLC(...
        'callerFunction',mfilename,...
        'callerHandle',hObject);
end


% --------------------------------------------------------------------
function menuViewPlotProperties_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewPlotProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    
    trEPR_GUI_plotproperties('closeGUI',hObject, eventdata, handles);
else 
    set(gcbo, 'Checked', 'on');

    trEPR_GUI_plotproperties(...
        'callerFunction',mfilename,...
        'callerHandle',hObject);
end

% --------------------------------------------------------------------
function menuViewInformation_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewInformation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    
    trEPR_GUI_info('closeGUI',hObject, eventdata, handles);
else 
    set(gcbo, 'Checked', 'on');

    trEPR_GUI_info(...
        'callerFunction',mfilename,...
        'callerHandle',hObject);
end

% --------------------------------------------------------------------
function displayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to displayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function plotPropertiesDisplayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to plotPropertiesDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_plotproperties(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --------------------------------------------------------------------
function showDisplayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to showDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if_spectraShow;

% --------------------------------------------------------------------
function hideDisplayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to hideDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if_spectraHide;

% --------------------------------------------------------------------
function removeDisplayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to removeDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function infoDisplayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to infoDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function axisToolsContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to axisToolsContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function zoomInAxisContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to zoomInAxisContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function zoomOutAxisContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to zoomOutAxisContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function exportAxisContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to exportAxisContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_export(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --------------------------------------------------------------------
function resetAxisContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to resetAxisContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function plotPropertiesAxisContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to plotPropertiesAxisContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_plotproperties(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --------------------------------------------------------------------
function menuViewExportPlot_Callback(hObject, eventdata, handles)
% hObject    handle to menuViewExportPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(gcbo, 'Checked'),'on')
    set(gcbo, 'Checked', 'off');
    
    trEPR_GUI_export('closeGUI',hObject, eventdata, handles);
else 
    set(gcbo, 'Checked', 'on');

    trEPR_GUI_export(...
        'callerFunction',mfilename,...
        'callerHandle',hObject);
end


% --------------------------------------------------------------------
function showAllDisplayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to showAllDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hideAllDisplayContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to hideAllDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function closeGUI(hObject, eventdata, handles)
% hObject    handle to hideAllDisplayContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg(...
    'Do you really want to quit the trEPR toolbox?',...
    'Really quit?',...
    'Yes',...
    'No',...
    'No');

switch selection,
    case 'Yes',
        delete(gcf);
    case 'No'
        return
end


% --------------------------------------------------------------------
function menuHelpWebsite_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelpWebsite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

stat = web('http://www.till-biskup.de/','-browser');


% --------------------------------------------------------------------
function menuHelpDocumentation_Callback(hObject, eventdata, handles)
% hObject    handle to menuHelpDocumentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileLoadDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileLoadDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_export(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --------------------------------------------------------------------
function menuFileSaveState_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileSaveState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileSaveStateAs_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileSaveStateAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuFileLoadState_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileLoadState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
% INTERNAL FUNCTIONS FOR THE ACTIONS OF THE GUI
% --------------------------------------------------------------------

% --- Load spectra and refresh all GUI elements and structures affected
function if_loadSpectra(filename)
% filename   name(s) of the files to load, cell array if multiple

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Load spectra using the wrapper function trEPRload
%if get(handles.spectraCombineFilesCheckbox,'Value')
%    spectra = trEPRload(filename,'combine',logical(true));
%else
%    spectra = trEPRload(filename);
%end
spectra = trEPRload(...
    filename,...
    'combine',...
    logical(get(handles.spectraCombineFilesCheckbox,'Value'))...
    );

% Compensate as set
if get(handles.spectraLoadPretriggerOffsetCorrectionCheckbox,'Value')
    if iscell(spectra)         % Multiple spectra loaded
        for k=1:length(spectra)
            spectra{k}.data = trEPRPOC(...
                spectra{k}.data,...
                spectra{k}.parameters.transient.triggerPosition...
                );
        end
    else                       % Single spectrum loaded
        spectra.data = trEPRPOC(...
            spectra.data,...
            spectra.parameters.transient.triggerPosition...
            );
    end
end

if get(handles.spectraLoadBackgroundCorrectionCheckbox,'Value')
    if iscell(spectra)         % Multiple spectra loaded
        for k=1:length(spectra)
            spectra{k}.data = trEPRBGC(spectra{k}.data);
        end
    else                       % Single spectrum loaded
        spectra.data = trEPRBGC(spectra.data);
    end
end

iLoadedSpectra = [];   % index of loaded spectra in data cell array;
% Assign the data to the appdata field 'data'
if isempty(appdata.data{1})    % No data loaded to the GUI yet
    if iscell(spectra)         % Multiple spectra loaded
        for k=1:length(spectra)
            appdata.data{k} = spectra{k};
            appdata.data{k}.Db0 = 0;
            appdata.data{k}.Dt = 0;
            appdata.data{k}.Dy = 0;
            appdata.data{k}.Sx = 1;
            appdata.data{k}.Sy = 1;
            appdata.data{k}.t = 1;
            appdata.data{k}.b0 = 1;
        end
        iLoadedSpectra = [ 1:1:length(spectra) ];
    else                       % Single spectrum loaded
        appdata.data{1} = spectra;
        appdata.data{1}.Db0 = 0;
        appdata.data{1}.Dt = 0;
        appdata.data{1}.Dy = 0;
        appdata.data{1}.Sx = 1;
        appdata.data{1}.Sy = 1;
        appdata.data{1}.t = 1;
        appdata.data{1}.b0 = 1;
        iLoadedSpectra = [ 1 ];
    end
else                           % GUI contains already data
    nSpectra = length(appdata.data);
    if iscell(spectra)         % Multiple spectra loaded
        for k=nSpectra+1:nSpectra+length(spectra)
            appdata.data{k} = spectra{k-nSpectra};
            appdata.data{k}.Db0 = 0;
            appdata.data{k}.Dt = 0;
            appdata.data{k}.Dy = 0;
            appdata.data{k}.Sx = 1;
            appdata.data{k}.Sy = 1;
            appdata.data{k}.t = 1;
            appdata.data{k}.b0 = 1;
        end
        iLoadedSpectra = [nSpectra+1:1:nSpectra+length(spectra)];
    else                       % Single spectrum loaded
        appdata.data{nSpectra+1} = spectra;
        appdata.data{nSpectra+1}.Db0 = 0;
        appdata.data{nSpectra+1}.Dt = 0;
        appdata.data{nSpectra+1}.Dy = 0;
        appdata.data{nSpectra+1}.Sx = 1;
        appdata.data{nSpectra+1}.Sy = 1;
        appdata.data{nSpectra+1}.t = 1;
        appdata.data{nSpectra+1}.b0 = 1;
        iLoadedSpectra = [ nSpectra+1 ];
    end
end

% Refresh the appdata field 'control.spectra'
%   => It's only necessary to update the field control.spectra.invisible
invSpectra = [...
   cell2mat(appdata.control.spectra.invisible), ...
   iLoadedSpectra
   ];
invSpectraCell = cell(1,length(invSpectra));
for k=1:length(invSpectra)
    invSpectraCell{k} = invSpectra(k);
end
appdata.control.spectra.invisible = invSpectraCell;

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

% Call to internal function refreshing the invisible spectra listbox
%     => important to do it after refreshing handles and appdata!
if_spectraInvisibleListbox_Refresh


% --- Refresh invisible spectra listbox
function if_spectraInvisibleListbox_Refresh

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Extract names of invisible Spectra from appdata
invSpectraNames = cell(1);
if isempty(appdata.control.spectra.invisible{1})
    invSpectraNames = cell(1);
    set(handles.spectraShowButton,'Enable','Off');
    set(handles.spectraInvisibleListbox,'Enable','Inactive');
else
    set(handles.spectraShowButton,'Enable','On');
    set(handles.spectraInvisibleListbox,'Enable','On');
    for k=1:length(appdata.control.spectra.invisible)
        [pathstr, name, ext, versn] = fileparts(...
            appdata.data{...
            appdata.control.spectra.invisible{k}}.filename...
            );
        invSpectraNames{k} = [name ext];
    end
end

% Fix problem with currently selected item
maxValue = length(invSpectraNames);
selectedValue = get(handles.spectraInvisibleListbox,'Value');
if selectedValue > maxValue
    set(handles.spectraInvisibleListbox,'Value',maxValue);
end

% Set listbox display
set(handles.spectraInvisibleListbox,'String',invSpectraNames);

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
    set(handles.spectraHideButton,'Enable','Off');
    set(handles.displayTypePopupmenu,'Enable','Inactive');
    set(handles.spectraVisibleListbox,'Enable','Inactive');
    cla(handles.axes1,'reset');
    set(handles.db0Edit,'Enable','Inactive');
    set(handles.dtEdit,'Enable','Inactive');
    set(handles.dyEdit,'Enable','Inactive');
    set(handles.sb0Edit,'Enable','Inactive');
    set(handles.stEdit,'Enable','Inactive');
    set(handles.syEdit,'Enable','Inactive');
    set(handles.timeEditIndex,'Enable','Inactive');
    set(handles.b0EditIndex,'Enable','Inactive');
    set(handles.spectraInfoButton,'Enable','Off');
    set(handles.spectraRemoveButton,'Enable','Off');
    set(handles.spectraAccumulateButton,'Enable','Off');
    set(handles.axisResetButton,'Enable','Off');
    set(handles.axisExportButton,'Enable','Off');
    set(handles.measureClearButton,'Enable','Off');
    set(handles.measurePickButton,'Enable','Off');
else
    set(handles.spectraHideButton,'Enable','On');
    set(handles.displayTypePopupmenu,'Enable','On');
    set(handles.spectraVisibleListbox,'Enable','On');
    set(handles.db0Edit,'Enable','On');
    set(handles.dyEdit,'Enable','On');
    set(handles.sb0Edit,'Enable','On');
    set(handles.syEdit,'Enable','On');
    set(handles.timeEditIndex,'Enable','On');
    set(handles.b0EditIndex,'Enable','On');
    set(handles.spectraInfoButton,'Enable','On');
    set(handles.spectraRemoveButton,'Enable','On');
    if length(appdata.control.spectra.visible) > 1
        set(handles.spectraAccumulateButton,'Enable','On');
    else
        set(handles.spectraAccumulateButton,'Enable','Off');
    end    
    set(handles.axisResetButton,'Enable','On');
    set(handles.axisExportButton,'Enable','On');
    set(handles.measureClearButton,'Enable','On');
    set(handles.measurePickButton,'Enable','On');
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
appdata.control.spectra.active = appdata.control.spectra.visible{...
    get(handles.spectraVisibleListbox,'Value')...
    };

% Set listbox display
set(handles.spectraVisibleListbox,'String',visSpectraNames);

% If there are no visible spectra any more, set appdata, turn off elements
% and return 
if isempty(appdata.control.spectra.active)
    appdata.control.spectra.active = 0;
    set(handles.spectraHideButton,'Enable','Off');
    set(handles.displayTypePopupmenu,'Enable','Inactive');
    set(handles.spectraVisibleListbox,'Enable','Inactive');
    cla(handles.axes1,'reset');
    set(handles.db0Edit,'Enable','Inactive');
    set(handles.dtEdit,'Enable','Inactive');
    set(handles.dyEdit,'Enable','Inactive');
    set(handles.sb0Edit,'Enable','Inactive');
    set(handles.stEdit,'Enable','Inactive');
    set(handles.syEdit,'Enable','Inactive');
    set(handles.timeEditIndex,'Enable','Inactive');
    set(handles.b0EditIndex,'Enable','Inactive');
    set(handles.spectraScrollSlider,'Enable','Off');
    set(handles.scaleYSlider,'Enable','Off');
    set(handles.displaceYSlider,'Enable','Off');
    set(handles.scaleXSlider,'Enable','Off');
    set(handles.displaceXSlider,'Enable','Off');
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
    return;
else
    set(handles.spectraHideButton,'Enable','On');
    set(handles.displayTypePopupmenu,'Enable','On');
    set(handles.spectraVisibleListbox,'Enable','On');
    set(handles.db0Edit,'Enable','On');
    set(handles.dtEdit,'Enable','On');
    set(handles.dyEdit,'Enable','On');
    set(handles.sb0Edit,'Enable','On');
    set(handles.stEdit,'Enable','On');
    set(handles.syEdit,'Enable','On');
    set(handles.timeEditIndex,'Enable','On');
    set(handles.b0EditIndex,'Enable','On');
    set(handles.spectraScrollSlider,'Enable','On');
    set(handles.scaleYSlider,'Enable','On');
    set(handles.displaceYSlider,'Enable','On');
    set(handles.scaleXSlider,'Enable','On');
    set(handles.displaceXSlider,'Enable','On');
end

% Set slider values and display of these values accordingly for the
% currently active spectrum
set(handles.timeEditIndex,'String',...
    appdata.data{appdata.control.spectra.active}.t);
set(handles.b0EditIndex,'String',...
    appdata.data{appdata.control.spectra.active}.b0);
set(handles.timeEditValue,'String',...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values(...
    appdata.data{appdata.control.spectra.active}.t));
set(handles.b0EditValue,'String',...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values(...
    appdata.data{appdata.control.spectra.active}.b0));
switch appdata.control.axis.displayType;
    case 'B0 spectra'
        set(handles.spectraScrollSlider,'Value',...
            appdata.data{appdata.control.spectra.active}.t);
        set(handles.displaceXSlider,'Value',...
            appdata.data{appdata.control.spectra.active}.Db0);
        set(handles.db0Edit,'String',...
            appdata.data{appdata.control.spectra.active}.Db0);
    case 'transients'
        set(handles.spectraScrollSlider,'Value',...
            appdata.data{appdata.control.spectra.active}.b0);
        set(handles.displaceXSlider,'Value',...
            appdata.data{appdata.control.spectra.active}.Dt);
        set(handles.dtEdit,'String',...
            appdata.data{appdata.control.spectra.active}.Dt);
end

set(handles.displaceYSlider,'Value',...
    appdata.data{appdata.control.spectra.active}.Dy);
set(handles.dyEdit,'String',...
    appdata.data{appdata.control.spectra.active}.Dy);

if appdata.data{appdata.control.spectra.active}.Sx < 1
    set(handles.scaleXSlider,'Value',...
        -(1/appdata.data{appdata.control.spectra.active}.Sx)+1);
else
    set(handles.scaleXSlider,'Value',...
        appdata.data{appdata.control.spectra.active}.Sx-1);
end
if appdata.data{appdata.control.spectra.active}.Sy < 1
    set(handles.scaleYSlider,'Value',...
        -(1/appdata.data{appdata.control.spectra.active}.Sy)+1);
else
    set(handles.scaleYSlider,'Value',...
        appdata.data{appdata.control.spectra.active}.Sy-1);
end
set(handles.sb0Edit,'String',...
    appdata.data{appdata.control.spectra.active}.Sx);
set(handles.syEdit,'String',...
    appdata.data{appdata.control.spectra.active}.Sy);

switch appdata.control.axis.displayType;
    case 'B0 spectra'
        centerXaxisValue = ...
            (appdata.data{appdata.control.spectra.active}.axes.yaxis.values(end)-...
            appdata.data{appdata.control.spectra.active}.axes.yaxis.values(1))/2;

        set(handles.displaceXSlider,'Min',-centerXaxisValue);
        set(handles.displaceXSlider,'Max',centerXaxisValue);
        if get(handles.displaceXSlider,'Value') < -centerXaxisValue
            set(handles.displaceXSlider,'Value',-centerXaxisValue);
        elseif get(handles.displaceXSlider,'Value') > centerXaxisValue
            set(handles.displaceXSlider,'Value',centerXaxisValue);
        end
    case 'transients'
        centerXaxisValue = ...
            (appdata.data{appdata.control.spectra.active}.axes.xaxis.values(end)-...
            appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1))/2;

        set(handles.displaceXSlider,'Min',-centerXaxisValue);
        set(handles.displaceXSlider,'Max',centerXaxisValue);
        if get(handles.displaceXSlider,'Value') < -centerXaxisValue
            set(handles.displaceXSlider,'Value',-centerXaxisValue);
        elseif get(handles.displaceXSlider,'Value') > centerXaxisValue
            set(handles.displaceXSlider,'Value',centerXaxisValue);
        end
end

set(handles.displaceYSlider,'Min',...
    min(min(appdata.data{appdata.control.spectra.active}.data)));
set(handles.displaceYSlider,'Max',...
    max(max(appdata.data{appdata.control.spectra.active}.data)));
if get(handles.displaceYSlider,'Value') < min(min(...
        appdata.data{appdata.control.spectra.active}.data))
    set(handles.displaceYSlider,'Value',...
        min(min(appdata.data{appdata.control.spectra.active}.data)));
elseif get(handles.displaceYSlider,'Value') > max(max(...
        appdata.data{appdata.control.spectra.active}.data))
    set(handles.displaceYSlider,'Value',...
        max(max(appdata.data{appdata.control.spectra.active}.data)));
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


% --- Move currently selected spectrum to visible spectra
function if_spectraShow

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Return immediately if there is no invisible spectrum
if isempty(appdata.control.spectra.invisible)
    return
elseif isempty(appdata.control.spectra.invisible{1})
    return
end

% Get value of currently selected item
iSelected = appdata.control.spectra.invisible{...
    get(handles.spectraInvisibleListbox,'Value')...
    };

% Add selected to visible
nVisSpectra = length(appdata.control.spectra.visible);
if nVisSpectra == 1 && isempty(appdata.control.spectra.visible{1})
    appdata.control.spectra.visible{1} = iSelected;
else
    appdata.control.spectra.visible{nVisSpectra+1} = iSelected;
end

% Remove selected from invisible
nInvSpectra = length(appdata.control.spectra.invisible);
for k=1:nInvSpectra
    if appdata.control.spectra.invisible{k} == iSelected
        appdata.control.spectra.invisible(k) = [];
        break;  % !!! above statement manipulates cell array length
    end
end
% Prevent empty cell array
if isempty(appdata.control.spectra.invisible)
    appdata.control.spectra.invisible{1} = [];
end

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

% Call to internal function refreshing the invisible spectra listbox
%     => important to do it after refreshing handles and appdata!
if_spectraInvisibleListbox_Refresh;
if_spectraVisibleListbox_Refresh(handles.figure1);

if_axis_Refresh(handles.figure1);


% --- Move currently selected spectrum to invisible spectra
function if_spectraHide

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Return immediately if there is no visible spectrum
if isempty(appdata.control.spectra.visible)
    return
elseif isempty(appdata.control.spectra.visible{1})
    return
end

% Get value of currently selected item
iSelected = appdata.control.spectra.visible{...
    get(handles.spectraVisibleListbox,'Value')...
    };

% Add selected to invisible
nInvSpectra = length(appdata.control.spectra.invisible);
if nInvSpectra == 1 && isempty(appdata.control.spectra.invisible{1})
    appdata.control.spectra.invisible{1} = iSelected;
else
    appdata.control.spectra.invisible{nInvSpectra+1} = iSelected;
end

% Remove selected from visible
nVisSpectra = length(appdata.control.spectra.visible);
for k=1:nVisSpectra
    if appdata.control.spectra.visible{k} == iSelected
        appdata.control.spectra.visible(k) = [];
        break;  % !!! above statement manipulates cell array length
    end
end
% Prevent empty cell array
if isempty(appdata.control.spectra.visible)
    appdata.control.spectra.visible{1} = [];
end

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

% Call to internal function refreshing the invisible spectra listbox
%     => important to do it after refreshing handles and appdata!
if_spectraInvisibleListbox_Refresh;
if_spectraVisibleListbox_Refresh(handles.figure1);

if_axis_Refresh(handles.figure1);


% --- Remove currently selected spectrum from GUI
function if_spectraRemove(hObject, varargin)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if nargin > 1
    iSelected = varargin{1};
else
    iSelected = appdata.control.spectra.active;
end

% Return immediately if there are no spectra or selected spectrum is "0"
if isempty(appdata.data{1}) || iSelected == 0
    return
end

% Check whether spectrum to be removed was modified before

modSpectra = length(appdata.control.spectra.modified);
for k=1:modSpectra
    if appdata.control.spectra.modified{k} == iSelected
        selection = questdlg(...
            sprintf('%s\n%s\n%s\n%s',...
            'The spectrum you are about to remove from the GUI was modified.',...
            'Do you really want to remove the modified spectrum without saving?',...
            ' ',...
            'NOTE: In this case all modifications are lost!'),...
            'Modifications exist. Really remove?',...
            'Cancel',...
            'Remove',...
            'Cancel');

        switch selection,
            case 'Cancel',
                return;
            case 'Remove'
        end
    end
end


% Remove selected from data
appdata.data(iSelected) = [];
if isempty(appdata.data)
    appdata.data = cell(1);
end

% Remove selected from visible
visSpectra = length(appdata.control.spectra.visible);
for k=1:visSpectra
    if appdata.control.spectra.visible{k} == iSelected
        appdata.control.spectra.visible(k) = [];
        break;  % !!! above statement manipulates cell array length
    end
end
% Prevent empty cell array
if isempty(appdata.control.spectra.visible)
    appdata.control.spectra.visible{1} = [];
end

% Remove selected from visible
visSpectra = length(appdata.control.spectra.visible);
for k=1:visSpectra
    if appdata.control.spectra.visible{k} == iSelected
        appdata.control.spectra.visible(k) = [];
        break;  % !!! above statement manipulates cell array length
    end
end
% Prevent empty cell array
if isempty(appdata.control.spectra.visible)
    appdata.control.spectra.visible{1} = [];
end

% Remove selected from modified
modSpectra = length(appdata.control.spectra.modified);
for k=1:modSpectra
    if appdata.control.spectra.modified{k} == iSelected
        appdata.control.spectra.modified(k) = [];
        break;  % !!! above statement manipulates cell array length
    end
end
% Prevent empty cell array
if isempty(appdata.control.spectra.modified)
    appdata.control.spectra.modified{1} = [];
end

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

% Call to internal function refreshing the invisible spectra listbox
%     => important to do it after refreshing handles and appdata!
if_spectraInvisibleListbox_Refresh;
if_spectraVisibleListbox_Refresh(handles.figure1);

if_axis_Refresh(handles.figure1);


% --- Refresh plot window (axis)
function if_axis_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Get current display type
currentDisplayType = appdata.control.axis.displayType;

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

switch currentDisplayType
    case '2D plot'
        % Get currently active spectrum
        
        % Plot with imagesc (in this case, 2D plot, only active one...)
        set(handles.axes1,'XTick',[],'YTick',[]);     % default if no plot
        set(handles.spectraScrollSlider,'Enable','Off');
        set(handles.scaleYSlider,'Enable','Off');
        set(handles.displaceYSlider,'Enable','Off');
        set(handles.scaleXSlider,'Enable','Off');
        set(handles.displaceXSlider,'Enable','Off');

        imagesc(...
            appdata.data{appdata.control.spectra.active}.axes.xaxis.values,...
            appdata.data{appdata.control.spectra.active}.axes.yaxis.values,...
            appdata.data{appdata.control.spectra.active}.data...
            );
        set(handles.axes1,'YDir','normal');

        xlabel(handles.axes1,sprintf('{\\it time} / s'));
        ylabel(handles.axes1,sprintf('{\\it magnetic field} / mT'));
    case 'B0 spectra'        
        set(handles.spectraScrollSlider,'Enable','On');
        set(handles.spectraScrollSlider,'Min',1);
        set(handles.spectraScrollSlider,'Max',xDim);
        set(handles.spectraScrollSlider,'SliderStep',[1/xDim, 10/xDim]);
        set(handles.scaleYSlider,'Enable','On');
        set(handles.displaceYSlider,'Enable','On');
        set(handles.scaleXSlider,'Enable','On');
        set(handles.displaceXSlider,'Enable','On');

        % Reset current axis
        cla(handles.axes1,'reset');
        hold on;
        for k = 1 : length(appdata.control.spectra.visible)
            % Set plot style of currently active spectrum
            if appdata.control.spectra.visible{k} == appdata.control.spectra.active
                plotStyle = 'b-';
            else
                plotStyle = 'k-';
            end
            % Convert G -> mT
            if strcmp(appdata.data{appdata.control.spectra.visible{k}}.axes.yaxis.unit,'G')
                yaxis = appdata.data{appdata.control.spectra.visible{k}}.axes.yaxis.values / 10;
                Db0 = appdata.data{appdata.control.spectra.visible{k}}.Db0 / 10;
            else
                yaxis = appdata.data{appdata.control.spectra.visible{k}}.axes.yaxis.values;
                Db0 = appdata.data{appdata.control.spectra.visible{k}}.Db0;
            end
            plot(...
                handles.axes1,...
                yaxis + Db0,...
                appdata.data{appdata.control.spectra.visible{k}}.data(...
                :,floor(appdata.data{appdata.control.spectra.visible{k}}.t)...
                )*...
                appdata.data{appdata.control.spectra.visible{k}}.Sy+...
                appdata.data{appdata.control.spectra.visible{k}}.Dy,...
                plotStyle...
                );
            xLimits(k,:) = [...
                yaxis(1) ...
                yaxis(end) ...                
                ];
            yLimits(k,:) = [...
                min(min(appdata.data{appdata.control.spectra.visible{k}}.data)) ...
                max(max(appdata.data{appdata.control.spectra.visible{k}}.data)) ...                
                ];
        end
        hold off;
        set(...
            handles.axes1,...
            'XLim',...
            [min(min(xLimits)) max(max(xLimits))]...
            );
        set(...
            handles.axes1,...
            'YLim',...
            [min(min(yLimits))*1.05 max(max(yLimits))*1.05]...
            );
        
        xlabel(handles.axes1,sprintf('{\\it magnetic field} / mT'));
        ylabel(handles.axes1,sprintf('{\\it intensity} / a.u.'));
    case 'transients'
        set(handles.axes1,'XTick',[],'YTick',[]);     % default if no plot
        set(handles.spectraScrollSlider,'Enable','On');
        set(handles.spectraScrollSlider,'Min',1);
        set(handles.spectraScrollSlider,'Max',yDim);
        set(handles.spectraScrollSlider,'SliderStep',[1/yDim, 10/yDim]);

        set(handles.scaleYSlider,'Enable','On');
        set(handles.displaceYSlider,'Enable','On');
        set(handles.scaleXSlider,'Enable','On');
        set(handles.displaceXSlider,'Enable','On');
        
        % Reset current axis
        cla(handles.axes1,'reset');
        hold on;
        for k = 1 : length(appdata.control.spectra.visible)
            % Set plot style of currently active spectrum
            if appdata.control.spectra.visible{k} == appdata.control.spectra.active
                plotStyle = 'b-';
            else
                plotStyle = 'k-';
            end
            plot(...
                handles.axes1,...
                appdata.data{appdata.control.spectra.visible{k}}.axes.xaxis.values,...
                appdata.data{appdata.control.spectra.visible{k}}.data(...
                floor(appdata.data{appdata.control.spectra.visible{k}}.b0),:...
                )*...
                appdata.data{appdata.control.spectra.visible{k}}.Sy+...
                appdata.data{appdata.control.spectra.visible{k}}.Dy,...
                plotStyle...
                );
            xLimits(k,:) = [...
                appdata.data{appdata.control.spectra.visible{k}}.axes.xaxis.values(1) ...
                appdata.data{appdata.control.spectra.visible{k}}.axes.xaxis.values(end) ...                
                ];
            yLimits(k,:) = [...
                min(min(appdata.data{appdata.control.spectra.visible{k}}.data)) ...
                max(max(appdata.data{appdata.control.spectra.visible{k}}.data)) ...                
                ];
        end
        hold off;
        set(...
            handles.axes1,...
            'XLim',...
            [min(min(xLimits)) max(max(xLimits))]...
            );
        set(...
            handles.axes1,...
            'YLim',...
            [min(min(yLimits))*1.05 max(max(yLimits))*1.05]...
            );

        xlabel(handles.axes1,sprintf('{\\it time} / s'));
        ylabel(handles.axes1,sprintf('{\\it intensity} / a.u.'));
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


% --- Get pointer position in current axis
function if_switchMeasurementPoint(hObject,event)

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Get current point to measure (1 or 2)
currentPoint = appdata.control.measure.point;

% Get x and y values
xind = str2num(get(handles.measureX1editIndex,'String'));
yind = str2num(get(handles.measureY1editIndex,'String'));
xval = str2num(get(handles.measureX1editValue,'String'));
yval = str2num(get(handles.measureY1editValue,'String'));

switch currentPoint
    case 1
        appdata.control.measure.point = 2;
        appdata.control.measure.x1val = xval(1);
        appdata.control.measure.y1val = yval(1);
        appdata.control.measure.x1ind = xind(1);
        appdata.control.measure.y1ind = yind(1);
    case 2
        appdata.control.measure.point = 1;
        set(handles.figure1,'WindowButtonMotionFcn','');
        set(handles.figure1,'WindowButtonDownFcn','');
        set(handles.figure1,'Pointer','arrow');
        refresh;
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


% --- Get pointer position in current axis
function if_trackPointer(hObject,event)

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Get current display type
currentDisplayType = appdata.control.axis.displayType;

% Get current point to measure (1 or 2)
currentPoint = appdata.control.measure.point;

% Get values of first point if any
if currentPoint == 2
    x1val = appdata.control.measure.x1val;
    y1val = appdata.control.measure.y1val;
    x1ind = appdata.control.measure.x1ind;
    y1ind = appdata.control.measure.y1ind;
end

cp = get(hObject,'CurrentPoint');
axisPosition = get(handles.axes1,'Position');
ac = [...
    axisPosition(1)...
    axisPosition(2)...
    axisPosition(1)+axisPosition(3)...
    axisPosition(2)+axisPosition(4)];

if cp(1)>ac(1) && cp(1)<=ac(3) && cp(2)>ac(2) && cp(2)<=ac(4)
    set(hObject,'Pointer','fullcrosshair');
    if ~isempty(get(handles.axes1,'Children'))
        % if there are some data displayed

        % Get X and Y data vector
        % TODO: Get this from the appdata, not from the axes handle due to
        %       problems once having more then one plot there!
        xdata = get(get(handles.axes1,'Children'),'XData');
        ydata = get(get(handles.axes1,'Children'),'YData');
        
        indx=interp1(...
            linspace(1,axisPosition(3),length(xdata)),...
            1:length(xdata),...
            cp(1)-ac(1),'nearest');
        indy=interp1(...
            linspace(1,axisPosition(4),length(ydata)),...
            1:length(ydata),...
            cp(2)-ac(2),'nearest');
        valx=interp1(...
            linspace(1,axisPosition(3),length(xdata)),...
            xdata,...
            cp(1)-ac(1),'nearest');
        valy=interp1(...
            linspace(1,axisPosition(4),length(ydata)),...
            ydata,...
            cp(2)-ac(2),'nearest');
                
        switch currentDisplayType
            case '2D plot'
                % Set display of value
                switch currentPoint
                    case 1
                        set(handles.measureX1editIndex,'String',...
                            sprintf('%s',num2str(indx)));
                        set(handles.measureY1editIndex,'String',...
                            sprintf('%s',num2str(indy)));
                        set(handles.measureX1editValue,'String',...
                            sprintf('%s',num2str(valx)));
                        set(handles.measureY1editValue,'String',...
                            sprintf('%s',num2str(valy)));
                    case 2
                        set(handles.measureX2editIndex,'String',...
                            sprintf('%s',num2str(indx)));
                        set(handles.measureY2editIndex,'String',...
                            sprintf('%s',num2str(indy)));
                        set(handles.measureDeltaXeditIndex,'String',...
                            sprintf('%s',num2str(indx-x1ind)));
                        set(handles.measureDeltaYeditIndex,'String',...
                            sprintf('%s',num2str(indy-y1ind)));
                        set(handles.measureX2editValue,'String',...
                            sprintf('%s',num2str(valx)));
                        set(handles.measureY2editValue,'String',...
                            sprintf('%s',num2str(valy)));
                        set(handles.measureDeltaXeditValue,'String',...
                            sprintf('%s',num2str(valx-x1val)));
                        set(handles.measureDeltaYeditValue,'String',...
                            sprintf('%s',num2str(valy-y1val)));
                end
            case 'B0 spectra'
                switch currentPoint
                    case 1
                        set(handles.measureX1editIndex,'String',...
                            sprintf('%s',num2str(indx)));
                        set(handles.measureY1editIndex,'String',...
                            sprintf('%s',num2str(indy)));
                        set(handles.measureX1editValue,'String',...
                            sprintf('%s',num2str(valx)));
                        set(handles.measureY1editValue,'String',...
                            sprintf('%5.2f',valy));
                    case 2
                        set(handles.measureX2editIndex,'String',...
                            sprintf('%s',num2str(indx)));
                        set(handles.measureY2editIndex,'String',...
                            sprintf('%s',num2str(indy)));
                        set(handles.measureDeltaXeditIndex,'String',...
                            sprintf('%s',num2str(indx-x1ind)));
                        set(handles.measureDeltaYeditIndex,'String',...
                            sprintf('%s',num2str(indy-y1ind)));
                        set(handles.measureX2editValue,'String',...
                            sprintf('%s',num2str(valx)));
                        set(handles.measureY2editValue,'String',...
                            sprintf('%5.2f',valy));
                        set(handles.measureDeltaXeditValue,'String',...
                            sprintf('%s',num2str(valx-x1val)));
                        set(handles.measureDeltaYeditValue,'String',...
                            sprintf('%5.2f',valy-y1val));
                end
            case 'transients'
                switch currentPoint
                    case 1
                        set(handles.measureX1editIndex,'String',...
                            sprintf('%s',num2str(indx)));
                        set(handles.measureY1editIndex,'String',...
                            sprintf('%s',num2str(indy)));
                        set(handles.measureX1editValue,'String',...
                            sprintf('%s',num2str(valx)));
                        set(handles.measureY1editValue,'String',...
                            sprintf('%5.2f',valy));
                    case 2
                        set(handles.measureX2editIndex,'String',...
                            sprintf('%s',num2str(indx)));
                        set(handles.measureY2editIndex,'String',...
                            sprintf('%s',num2str(indy)));
                        set(handles.measureDeltaXeditIndex,'String',...
                            sprintf('%s',num2str(indx-x1ind)));
                        set(handles.measureDeltaYeditIndex,'String',...
                            sprintf('%s',num2str(indy-y1ind)));
                        set(handles.measureX2editValue,'String',...
                            sprintf('%s',num2str(valx)));
                        set(handles.measureY2editValue,'String',...
                            sprintf('%5.2f',valy));
                        set(handles.measureDeltaXeditValue,'String',...
                            sprintf('%s',num2str(valx-x1val)));
                        set(handles.measureDeltaYeditValue,'String',...
                            sprintf('%5.2f',valy-y1val));
                end                
        end
    end
else
    set(hObject,'Pointer','arrow');
end

% --- Pretrigger Offset Compensation (POC)
function if_POC

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

if appdata.control.spectra.active > 0
    appdata.data{appdata.control.spectra.active}.data = ...
        trEPRPOC(...
        appdata.data{appdata.control.spectra.active}.data,...
        appdata.data{appdata.control.spectra.active}.parameters.transient.triggerPosition...
        );
end

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

% --- Background Compensation (BGC)
function if_BGC

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.data = ...
    trEPRBGC(...
    appdata.data{appdata.control.spectra.active}.data...
    );

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


% --- Check Order of Compensation Methods
function TF = if_checkCompensationMethods

% Get handles of the current GUI
handles = guidata(gcbo);

% Set warning message
warningMessage = sprintf(...
    '%s\n%s',...
    'Warning: It is not a good idea to perform only BGC, but not POC.',...
    'Proceed to load files and compensate only for the background?'...
    );

% If BGC is set, but not POC, display warning dialogue
if get(handles.spectraLoadBackgroundCorrectionCheckbox,'Value') && ...
    ~get(handles.spectraLoadPretriggerOffsetCorrectionCheckbox,'Value')
    selection = questdlg(...
        warningMessage,...
        'Problem with Order of Corrections',...
        'Yes',...
        'No',...
        'No');

    switch selection,
        case 'Yes',
            TF = logical(false);
        case 'No'
            TF = logical(true);
    end
else
    TF = logical(false);
end



function timeEditValue_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

value = str2double(get(hObject,'String'));
min = appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1);
max = appdata.data{appdata.control.spectra.active}.axes.xaxis.values(end);
    
if value>=min && value<=max
    if strcmp(appdata.control.axis.displayType,'B0 spectra')
        set(handles.spectraScrollSlider,'Value',...
            interp1(...
            appdata.data{appdata.control.spectra.active}.axes.xaxis.values,...
            1:length(...
            appdata.data{appdata.control.spectra.active}.axes.xaxis.values),...
            value,'nearest'));
    end
    set(handles.timeEditValue,'String',...
        num2str(interp1(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values,...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values,...
        value,'nearest')));
    appdata.data{appdata.control.spectra.active}.t = ...
        interp1(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values,...
        1:length(appdata.data{appdata.control.spectra.active}.axes.xaxis.values),...
        value,'nearest');
elseif value<min
    if strcmp(appdata.control.axis.displayType,'B0 spectra')
        set(handles.spectraScrollSlider,'Value',...
            get(handles.spectraScrollSlider,'Min'));
    end
    set(handles.timeEditValue,'String',num2str(min));
    appdata.data{appdata.control.spectra.active}.t = 1;
else
    if strcmp(appdata.control.axis.displayType,'B0 spectra')
        set(handles.spectraScrollSlider,'Value',...
            get(handles.spectraScrollSlider,'Max'));
    end
    set(handles.timeEditValue,'String',num2str(max));
    appdata.data{appdata.control.spectra.active}.t = length(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values);
end    

set(handles.timeEditIndex,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.t)...
    );

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function timeEditValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeEditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function b0EditValue_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

value = str2double(get(hObject,'String'));
min = appdata.data{appdata.control.spectra.active}.axes.yaxis.values(1);
max = appdata.data{appdata.control.spectra.active}.axes.yaxis.values(end);
    
if value>=min && value<=max
    if strcmp(appdata.control.axis.displayType,'transients')
        set(handles.spectraScrollSlider,'Value',...
            interp1(...
            appdata.data{appdata.control.spectra.active}.axes.yaxis.values,...
            1:length(...
            appdata.data{appdata.control.spectra.active}.axes.yaxis.values),...
            value,'nearest'));
    end
    set(handles.b0EditValue,'String',...
        num2str(interp1(...
        appdata.data{appdata.control.spectra.active}.axes.yaxis.values,...
        appdata.data{appdata.control.spectra.active}.axes.yaxis.values,...
        value,'nearest')));
    appdata.data{appdata.control.spectra.active}.b0 = ...
        interp1(...
        appdata.data{appdata.control.spectra.active}.axes.yaxis.values,...
        1:length(appdata.data{appdata.control.spectra.active}.axes.yaxis.values),...
        value,'nearest');
elseif value<min
    if strcmp(appdata.control.axis.displayType,'transients')
        set(handles.spectraScrollSlider,'Value',...
            get(handles.spectraScrollSlider,'Min'));
    end
    set(handles.b0EditValue,'String',num2str(min));
    appdata.data{appdata.control.spectra.active}.b0 = 1;
else
    if strcmp(appdata.control.axis.displayType,'transients')
        set(handles.spectraScrollSlider,'Value',...
            get(handles.spectraScrollSlider,'Max'));
    end
    set(handles.b0EditValue,'String',num2str(max));
    appdata.data{appdata.control.spectra.active}.b0 = length(...
        appdata.data{appdata.control.spectra.active}.axes.yaxis.values);
end    

set(handles.b0EditIndex,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.b0)...
    );

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

if_axis_Refresh(handles.figure1);


% --- Executes during object creation, after setting all properties.
function b0EditValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b0EditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureDeltaYeditValue_Callback(hObject, eventdata, handles)
% hObject    handle to measureDeltaYeditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureDeltaYeditValue as text
%        str2double(get(hObject,'String')) returns contents of measureDeltaYeditValue as a double


% --- Executes during object creation, after setting all properties.
function measureDeltaYeditValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureDeltaYeditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureDeltaXeditValue_Callback(hObject, eventdata, handles)
% hObject    handle to measureDeltaXeditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureDeltaXeditValue as text
%        str2double(get(hObject,'String')) returns contents of measureDeltaXeditValue as a double


% --- Executes during object creation, after setting all properties.
function measureDeltaXeditValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureDeltaXeditValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureY2editValue_Callback(hObject, eventdata, handles)
% hObject    handle to measureY2editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureY2editValue as text
%        str2double(get(hObject,'String')) returns contents of measureY2editValue as a double


% --- Executes during object creation, after setting all properties.
function measureY2editValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureY2editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureX2editValue_Callback(hObject, eventdata, handles)
% hObject    handle to measureX2editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureX2editValue as text
%        str2double(get(hObject,'String')) returns contents of measureX2editValue as a double


% --- Executes during object creation, after setting all properties.
function measureX2editValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureX2editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureY1editValue_Callback(hObject, eventdata, handles)
% hObject    handle to measureY1editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureY1editValue as text
%        str2double(get(hObject,'String')) returns contents of measureY1editValue as a double


% --- Executes during object creation, after setting all properties.
function measureY1editValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureY1editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureX1editValue_Callback(hObject, eventdata, handles)
% hObject    handle to measureX1editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureX1editValue as text
%        str2double(get(hObject,'String')) returns contents of measureX1editValue as a double


% --- Executes during object creation, after setting all properties.
function measureX1editValue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureX1editValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



