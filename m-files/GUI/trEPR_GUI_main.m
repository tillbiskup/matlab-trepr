function varargout = trEPR_GUI_main(varargin)
% TREPR_GUI_MAIN M-file for trEPR_GUI_main.fig
%      TREPR_GUI_MAIN, by itself, creates a new TREPR_GUI_MAIN or raises the existing
%      singleton*.
%
%      H = TREPR_GUI_MAIN returns the handle to a new TREPR_GUI_MAIN or the handle to
%      the existing singleton*.
%
%      TREPR_GUI_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREPR_GUI_MAIN.M with the given input arguments.
%
%      TREPR_GUI_MAIN('Property','Value',...) creates a new TREPR_GUI_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trEPR_GUI_main_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trEPR_GUI_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_main

% Last Modified by GUIDE v2.5 21-Mar-2010 10:13:29

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

xLabelString = sprintf('{\\it time} / \\mus');
yLabelString = sprintf('{\\it magnetic field} / mT');
xlabel(handles.axes1,xLabelString);
ylabel(handles.axes1,yLabelString);

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
appdata.control.spectra.active = appdata.control.spectra.visible{...
    get(handles.spectraVisibleListbox,'Value')...
    };

% Refresh appdata of the current GUI
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_axis_Refresh;


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

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraHideButton.
function spectraHideButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraHideButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if_spectraHide;

% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function spectraToggleSlider_Callback(hObject, eventdata, handles)
% hObject    handle to spectraToggleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function spectraToggleSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraToggleSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function scaleXSlider_Callback(hObject, eventdata, handles)
% hObject    handle to scaleXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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
% hObject    handle to scaleYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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
% hObject    handle to displaceYSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


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
% hObject    handle to displaceXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function displaceXSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to displaceXSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
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
% hObject    handle to spectraRemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraSaveAsButton.
function spectraSaveAsButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraSaveAsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraInfoButton.
function spectraInfoButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraInfoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

% Refresh appdata of the current GUI
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

% Hints: contents = get(hObject,'String') returns displayTypePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from displayTypePopupmenu
contents = get(hObject,'String');
switch char(contents{get(hObject,'Value')})
    case '2D plot'
        xLabelString = sprintf('{\\it time} / s');
        yLabelString = sprintf('{\\it magnetic field} / mT');
        xlabel(handles.axes1,xLabelString);
        ylabel(handles.axes1,yLabelString);
        set(handles.axes1,'XLim',[-1.96e-6 18e-6],'YLim',[340 350]);
    case 'B0 spectra'
        xLabelString = sprintf('{\\it magnetic field} / mT');
        yLabelString = sprintf('{\\it intensity} / a.u.');
        xlabel(handles.axes1,xLabelString);
        ylabel(handles.axes1,yLabelString);
        set(handles.axes1,'XLim',[340 350],'YLim',[-1 1]);
    case 'transients'
        xLabelString = sprintf('{\\it time} / s');
        yLabelString = sprintf('{\\it intensity} / a.u.');
        xlabel(handles.axes1,xLabelString);
        ylabel(handles.axes1,yLabelString);
        set(handles.axes1,'XLim',[-1.96e-6 18e-6],'YLim',[-1e-6 1e-6]);
end


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
% hObject    handle to menuFileLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

function dxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dxEdit as text
%        str2double(get(hObject,'String')) returns contents of dxEdit as a double


% --- Executes during object creation, after setting all properties.
function dxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dyEdit_Callback(hObject, eventdata, handles)
% hObject    handle to dyEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dyEdit as text
%        str2double(get(hObject,'String')) returns contents of dyEdit as a double


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



function sxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sxEdit as text
%        str2double(get(hObject,'String')) returns contents of sxEdit as a double


% --- Executes during object creation, after setting all properties.
function sxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function syEdit_Callback(hObject, eventdata, handles)
% hObject    handle to syEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of syEdit as text
%        str2double(get(hObject,'String')) returns contents of syEdit as a double


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

directory = get(handles.spectraLoadDirectoryCheckbox,'Value');

if directory
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



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to sxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sxEdit as text
%        str2double(get(hObject,'String')) returns contents of sxEdit as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to syEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of syEdit as text
%        str2double(get(hObject,'String')) returns contents of syEdit as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to syEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function timeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to timeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeEdit as text
%        str2double(get(hObject,'String')) returns contents of timeEdit as a double


% --- Executes during object creation, after setting all properties.
function timeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function b0Edit_Callback(hObject, eventdata, handles)
% hObject    handle to b0Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b0Edit as text
%        str2double(get(hObject,'String')) returns contents of b0Edit as a double


% --- Executes during object creation, after setting all properties.
function b0Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b0Edit (see GCBO)
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
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToolsCorrectionsPretriggerOffset_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsPretriggerOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToolsCorrectionsDrift_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsDrift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuToolsCorrectionsBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_BC(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function measureFirstXedit_Callback(hObject, eventdata, handles)
% hObject    handle to measureFirstXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureFirstXedit as text
%        str2double(get(hObject,'String')) returns contents of measureFirstXedit as a double


% --- Executes during object creation, after setting all properties.
function measureFirstXedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureFirstXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureSecondXedit_Callback(hObject, eventdata, handles)
% hObject    handle to measureSecondXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureSecondXedit as text
%        str2double(get(hObject,'String')) returns contents of measureSecondXedit as a double


% --- Executes during object creation, after setting all properties.
function measureSecondXedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureSecondXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureSecondYedit_Callback(hObject, eventdata, handles)
% hObject    handle to measureSecondYedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureSecondYedit as text
%        str2double(get(hObject,'String')) returns contents of measureSecondYedit as a double


% --- Executes during object creation, after setting all properties.
function measureSecondYedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureSecondYedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureDeltaXedit_Callback(hObject, eventdata, handles)
% hObject    handle to measureDeltaXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureDeltaXedit as text
%        str2double(get(hObject,'String')) returns contents of measureDeltaXedit as a double


% --- Executes during object creation, after setting all properties.
function measureDeltaXedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureDeltaXedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureDeltaYedit_Callback(hObject, eventdata, handles)
% hObject    handle to measureDeltaYedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureDeltaYedit as text
%        str2double(get(hObject,'String')) returns contents of measureDeltaYedit as a double


% --- Executes during object creation, after setting all properties.
function measureDeltaYedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureDeltaYedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function measureFirstYedit_Callback(hObject, eventdata, handles)
% hObject    handle to measureFirstYedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of measureFirstYedit as text
%        str2double(get(hObject,'String')) returns contents of measureFirstYedit as a double


% --- Executes during object creation, after setting all properties.
function measureFirstYedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to measureFirstYedit (see GCBO)
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


% --- Executes on button press in measureClearButton.
function measureClearButton_Callback(hObject, eventdata, handles)
% hObject    handle to measureClearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraAccumulateButton.
function spectraAccumulateButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraAccumulateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in axisExportButton.
function axisExportButton_Callback(hObject, eventdata, handles)
% hObject    handle to axisExportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_export(...
    'callerFunction',mfilename,...
    'callerHandle',hObject);

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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

if isfield(handles,'trEPR_GUI_BC')
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
    
    trEPR_GUI_BC('closeGUI',hObject, eventdata, handles);
else 
    set(gcbo, 'Checked', 'on');

    trEPR_GUI_BC(...
        'callerFunction',mfilename,...
        'callerHandle',hObject);
end

function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
function menuToolsCorrectionsBackground_Callback(hObject, eventdata, handles)
% hObject    handle to menuToolsCorrectionsBackground (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
spectra = trEPRload(filename);

iLoadedSpectra = [];   % index of loaded spectra in data cell array;
% Assign the data to the appdata field 'data'
if isempty(appdata.data{1})    % No data loaded to the GUI yet
    if iscell(spectra)         % Multiple spectra loaded
        for k=1:length(spectra)
            appdata.data{k} = spectra{k};
        end
        iLoadedSpectra = [ 1:1:length(spectra) ];
    else                       % Single spectrum loaded
        appdata.data{1} = spectra;
        iLoadedSpectra = [ 1 ];
    end
else                           % GUI contains already data
    nSpectra = length(appdata.data);
    if iscell(spectra)         % Multiple spectra loaded
        for k=nSpectra+1:nSpectra+length(spectra)
            appdata.data{k} = spectra{k-nSpectra};
        end
        iLoadedSpectra = [nSpectra+1:1:nSpectra+length(spectra)];
    else                       % Single spectrum loaded
        appdata.data{nSpectra+1} = spectra;
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
else
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
function if_spectraVisibleListbox_Refresh

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Extract names of visible Spectra from appdata
visSpectraNames = cell(1);
if isempty(appdata.control.spectra.visible{1})
    visSpectraNames = cell(1);
    appdata.control.spectra.active = 0;
else
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
if_spectraVisibleListbox_Refresh;

if_axis_Refresh;


% --- Move currently selected spectrum to invisible spectra
function if_spectraHide

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Return immediately if there is no invisible spectrum
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
if_spectraVisibleListbox_Refresh;

if_axis_Refresh;


% --- Refresh visible spectra listbox
function if_axis_Refresh

% Get handles and appdata of the current GUI
handles = guidata(gcbo);
appdata = getappdata(handles.figure1);

% Get current display type
currentDisplayType = appdata.control.axis.displayType;

% Get visible spectra

% Plot visible spectra
switch currentDisplayType
    case '2D plot'
        % Get currently active spectrum
        
        % Plot with imagesc (in this case, 2D plot, only active one...)
        imagesc(...
            appdata.data{...
            appdata.control.spectra.active...
            }.data...
            );
        xLabelString = sprintf('{\\it time} / s');
        yLabelString = sprintf('{\\it magnetic field} / mT');
        xlabel(handles.axes1,xLabelString);
        ylabel(handles.axes1,yLabelString);
%        set(handles.axes1,'XLim',[-1.96e-6 18e-6],'YLim',[340 350]);
    case 'B0 spectra'
        xLabelString = sprintf('{\\it magnetic field} / mT');
        yLabelString = sprintf('{\\it intensity} / a.u.');
        xlabel(handles.axes1,xLabelString);
        ylabel(handles.axes1,yLabelString);
%        set(handles.axes1,'XLim',[340 350],'YLim',[-1 1]);
    case 'transients'
        xLabelString = sprintf('{\\it time} / s');
        yLabelString = sprintf('{\\it intensity} / a.u.');
        xlabel(handles.axes1,xLabelString);
        ylabel(handles.axes1,yLabelString);
%        set(handles.axes1,'XLim',[-1.96e-6 18e-6],'YLim',[-1e-6 1e-6]);
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


