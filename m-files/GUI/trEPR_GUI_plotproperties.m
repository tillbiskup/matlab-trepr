function varargout = trEPR_GUI_plotproperties(varargin)
% TREPR_GUI_PLOTPROPERTIES M-file for trEPR_GUI_plotproperties.fig
%      TREPR_GUI_PLOTPROPERTIES, by itself, creates a new TREPR_GUI_PLOTPROPERTIES or raises the existing
%      singleton*.
%
%      H = TREPR_GUI_PLOTPROPERTIES returns the handle to a new TREPR_GUI_PLOTPROPERTIES or the handle to
%      the existing singleton*.
%
%      TREPR_GUI_PLOTPROPERTIES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREPR_GUI_PLOTPROPERTIES.M with the given input arguments.
%
%      TREPR_GUI_PLOTPROPERTIES('Property','Value',...) creates a new TREPR_GUI_PLOTPROPERTIES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trEPR_GUI_plotproperties_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trEPR_GUI_plotproperties_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_plotproperties

% Last Modified by GUIDE v2.5 15-Jun-2010 18:24:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trEPR_GUI_plotproperties_OpeningFcn, ...
                   'gui_OutputFcn',  @trEPR_GUI_plotproperties_OutputFcn, ...
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


% --- Executes just before trEPR_GUI_plotproperties is made visible.
function trEPR_GUI_plotproperties_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trEPR_GUI_plotproperties (see VARARGIN)

% Choose default command line output for trEPR_GUI_plotproperties
handles.output = hObject;

% set window title
set(hObject,'Name','trEPR : plot properties');

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

% Set application data (at this stage only empty structures)
data = cell(1); % store the data (spectra) together with their information
olddata = cell(1); % store a copy of the data (spectra)
acc = struct(); % store the accumulated spectra together with their information
configuration = struct(); % store the configuration information for the GUI
% --- store important control values, such as the currently active spectrum etc.
control = struct(...
    'spectra', struct(...
    'active',0,...
    'visible',cell(1),...
    'accumulated',cell(1),...
    'notaccumulated',cell(1),...
    'filenames',cell(1)...
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

% Get appdata from parent window
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')    
    callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)        

        % Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);
        
        data = parentAppdata.data;
        control = parentAppdata.control;
        setappdata(handles.figure1,'data',data);
        setappdata(handles.figure1,'control',control);
    end
    guidata(handles.callerHandle,callerHandles);
end

% Fill elements with correct values
switch control.axis.displayType
    case '2D plot'
        set(handles.xLabelMeasureEdit,'String',...
            data{control.spectra.active}.axes.xaxis.measure);
        set(handles.xLabelUnitEdit,'String',...
            data{control.spectra.active}.axes.xaxis.unit);
        set(handles.yLabelMeasureEdit,'String',...
            data{control.spectra.active}.axes.yaxis.measure);
        set(handles.yLabelUnitEdit,'String',...
            data{control.spectra.active}.axes.yaxis.unit);
    case 'B0 spectra'
        set(handles.xLabelMeasureEdit,'String',...
            data{control.spectra.active}.axes.yaxis.measure);
        set(handles.xLabelUnitEdit,'String',...
            data{control.spectra.active}.axes.yaxis.unit);
        set(handles.yLabelMeasureEdit,'String','intensity');
        set(handles.yLabelUnitEdit,'String','a.u.');
    case 'transients'
        set(handles.xLabelMeasureEdit,'String',...
            data{control.spectra.active}.axes.xaxis.measure);
        set(handles.xLabelUnitEdit,'String',...
            data{control.spectra.active}.axes.xaxis.unit);
        set(handles.yLabelMeasureEdit,'String','intensity');
        set(handles.yLabelUnitEdit,'String','a.u.');
end
xlimits = get(callerHandles.axes1,'XLim');
ylimits = get(callerHandles.axes1,'YLim');
set(handles.xMinEdit,'String',num2str(xlimits(1)));
set(handles.yMinEdit,'String',num2str(ylimits(1)));
set(handles.xMaxEdit,'String',num2str(xlimits(2)));
set(handles.yMaxEdit,'String',num2str(ylimits(2)));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trEPR_GUI_plotproperties wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trEPR_GUI_plotproperties_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closeGUI(hObject, eventdata, handles);


% --- Executes on button press in applyButton.
function applyButton_Callback(hObject, eventdata, handles)
%handles = guidata(gcbo);
trEPR_GUI_main('if_axis_Refresh',handles.callerHandle);


% --- Executes on selection change in lineColorPopupmenu.
function lineColorPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to lineColorPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lineColorPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lineColorPopupmenu


% --- Executes during object creation, after setting all properties.
function lineColorPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineColorPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lineWidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to lineWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lineWidthEdit as text
%        str2double(get(hObject,'String')) returns contents of lineWidthEdit as a double


% --- Executes during object creation, after setting all properties.
function lineWidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineWidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lineStylePopupmenu.
function lineStylePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to lineStylePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lineStylePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lineStylePopupmenu


% --- Executes during object creation, after setting all properties.
function lineStylePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineStylePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xLabelMeasureEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xLabelMeasureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xLabelMeasureEdit as text
%        str2double(get(hObject,'String')) returns contents of xLabelMeasureEdit as a double


% --- Executes during object creation, after setting all properties.
function xLabelMeasureEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xLabelMeasureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yLabelMeasureEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yLabelMeasureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yLabelMeasureEdit as text
%        str2double(get(hObject,'String')) returns contents of yLabelMeasureEdit as a double


% --- Executes during object creation, after setting all properties.
function yLabelMeasureEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLabelMeasureEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xLabelUnitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xLabelUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xLabelUnitEdit as text
%        str2double(get(hObject,'String')) returns contents of xLabelUnitEdit as a double


% --- Executes during object creation, after setting all properties.
function xLabelUnitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xLabelUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yLabelUnitEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yLabelUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yLabelUnitEdit as text
%        str2double(get(hObject,'String')) returns contents of yLabelUnitEdit as a double


% --- Executes during object creation, after setting all properties.
function yLabelUnitEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yLabelUnitEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in colorPalettePushbutton.
function colorPalettePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to colorPalettePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_colorpalette;

% --- Executes on selection change in lineMarkersPopupmenu.
function lineMarkersPopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to lineMarkersPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lineMarkersPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lineMarkersPopupmenu


% --- Executes during object creation, after setting all properties.
function lineMarkersPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineMarkersPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in normalizePkPkCheckbox.
function normalizePkPkCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to normalizePkPkCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normalizePkPkCheckbox


% --- Executes on button press in normalizeCheckbox.
function normalizeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to normalizeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normalizeCheckbox


% --- Executes on button press in convertG2mTCheckbox.
function convertG2mTCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to convertG2mTCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of convertG2mTCheckbox



function xMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMinEdit as text
%        str2double(get(hObject,'String')) returns contents of xMinEdit as a double


% --- Executes during object creation, after setting all properties.
function xMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMinEdit as text
%        str2double(get(hObject,'String')) returns contents of yMinEdit as a double


% --- Executes during object creation, after setting all properties.
function yMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to xMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of xMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function xMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of yMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function yMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Checkbox.
function Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Checkbox


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
        guidata(handles.callerHandle,callerHandles);
        delete(ownHandle);
    end
elseif isfield(handles,'mfilename') && strcmpi(handles.mfilename,mfilename)
    delete(gcf);
else
    delete(getfield(handles,mfilename));
    handles = rmfield(handles,mfilename);
    guidata(hObject,handles);
end


% --- Executes on selection change in spectraVisibleListbox.
function spectraVisibleListbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraVisibleListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns spectraVisibleListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectraVisibleListbox


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


% --- Executes on button press in spectraPrevButton.
function spectraPrevButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraPrevButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraNextButton.
function spectraNextButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraNextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraResetButton.
function spectraResetButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraResetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in gridXButton.
function gridXButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    if get(handles.gridMinorButton,'Value')
        appdata.control.axis.grid.x = 'minor';
    else
        appdata.control.axis.grid.x = 'major';
    end
else
    appdata.control.axis.grid.x = 'off';
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

% --- Executes on button press in gridYButton.
function gridYButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    if get(handles.gridMinorButton,'Value')
        appdata.control.axis.grid.y = 'minor';
    else
        appdata.control.axis.grid.y = 'major';
    end
else
    appdata.control.axis.grid.y = 'off';
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


% --- Executes on button press in gridMinorButton.
function gridMinorButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    if get(handles.gridXButton,'Value')
        appdata.control.axis.grid.x = 'minor';
    end
    if get(handles.gridYButton,'Value')
        appdata.control.axis.grid.y = 'minor';
    end
else
    if get(handles.gridXButton,'Value')
        appdata.control.axis.grid.x = 'major';
    end
    if get(handles.gridYButton,'Value')
        appdata.control.axis.grid.y = 'major';
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

if_parentAppdataRefresh(hObject);


% --- Executes on button press in gridZeroLine.
function gridZeroLine_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
appdata.control.axis.grid.zero = get(hObject,'Value');

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

% --- Executes on selection change in plotHighlightMethodPopupmenu.
function plotHighlightMethodPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hints: contents = get(hObject,'String') returns plotHighlightMethodPopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotHighlightMethodPopupmenu
contents = get(hObject,'String');
switch contents{get(hObject,'Value')}
    case 'Color'
        set(handles.plotHighlightValuePopupmenu,'String',...
            {'blue','green','red',...
            'cyan','magenta','yellow','black',...
            '<other>'});
    case 'Width'
        set(handles.plotHighlightValuePopupmenu,'String',...
            {'1 px','2 px','3 px','4 px','5 px'});
    case 'Marker'
        set(handles.plotHighlightValuePopupmenu,'String',...
            {'solid','dashed','dotted','dash-dotted'});
    case 'Style'
        set(handles.plotHighlightValuePopupmenu,'String',...
            {'plus','circle','asterisk','point','cross','square',...
            'diamond','Upwd-png triangle','Dnwd-png triangle',...
            'Right-png triangle','Left-png triangle',...
            'pentragram','hexagram'});
end
set(handles.plotHighlightValuePopupmenu,'Value',1);

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
function plotHighlightMethodPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotHighlightMethodPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in plotHighlightValuePopupmenu.
function plotHighlightValuePopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

contents = get(hObject,'String');
methodContents = get(handles.plotHighlightMethodPopupmenu,'String');
switch methodContents{get(handles.plotHighlightMethodPopupmenu,'Value')}
    case 'Color'
        appdata.control.axis.highlight.method = 'Color';
        switch contents{get(hObject,'Value')}
            case 'blue'
                appdata.control.axis.highlight.value = 'b';
            case 'green'
                appdata.control.axis.highlight.value = 'g';
            case 'red'
                appdata.control.axis.highlight.value = 'r';
            case 'cyan'
                appdata.control.axis.highlight.value = 'c';
            case 'magenta'
                appdata.control.axis.highlight.value = 'm';
            case 'yellow'
                appdata.control.axis.highlight.value = 'y';
            case 'black'
                appdata.control.axis.highlight.value = 'k';
        end
    case 'Width'
        appdata.control.axis.highlight.method = 'LineWidth';
        appdata.control.axis.highlight.value = ...
            str2double(...
            contents{get(handles.plotHighlightValuePopupmenu,'Value')}(1));
    case 'Marker'
    case 'Style'
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
function plotHighlightValuePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotHighlightValuePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plotHighlightColorPaletteButton.
function plotHighlightColorPaletteButton_Callback(hObject, eventdata, handles)
% hObject    handle to plotHighlightColorPaletteButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function legendLabelEdit_Callback(hObject, eventdata, handles)
% hObject    handle to legendLabelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of legendLabelEdit as text
%        str2double(get(hObject,'String')) returns contents of legendLabelEdit as a double


% --- Executes during object creation, after setting all properties.
function legendLabelEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to legendLabelEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in legendBestButton.
function legendBestButton_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    set(handles.legendNWbutton,'Value',0);
    set(handles.legendNEbutton,'Value',0);
    set(handles.legendSWbutton,'Value',0);
    set(handles.legendSEbutton,'Value',0);
    appdata.control.axis.legend.location = 'Best';
else
    appdata.control.axis.legend.location = 'off';
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


% --- Executes on button press in legendNWbutton.
function legendNWbutton_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    set(handles.legendBestButton,'Value',0);
    set(handles.legendNEbutton,'Value',0);
    set(handles.legendSWbutton,'Value',0);
    set(handles.legendSEbutton,'Value',0);
    appdata.control.axis.legend.location = 'NorthWest';
else
    appdata.control.axis.legend.location = 'off';
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


% --- Executes on button press in legendNEbutton.
function legendNEbutton_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    set(handles.legendBestButton,'Value',0);
    set(handles.legendNWbutton,'Value',0);
    set(handles.legendSWbutton,'Value',0);
    set(handles.legendSEbutton,'Value',0);
    appdata.control.axis.legend.location = 'NorthEast';
else
    appdata.control.axis.legend.location = 'off';
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


% --- Executes on button press in legendSWbutton.
function legendSWbutton_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    set(handles.legendBestButton,'Value',0);
    set(handles.legendNWbutton,'Value',0);
    set(handles.legendNEbutton,'Value',0);
    set(handles.legendSEbutton,'Value',0);
    appdata.control.axis.legend.location = 'SouthWest';
else
    appdata.control.axis.legend.location = 'off';
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


% --- Executes on button press in legendSEbutton.
function legendSEbutton_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hint: get(hObject,'Value') returns toggle state of gridZeroLine
if get(hObject,'Value')
    set(handles.legendBestButton,'Value',0);
    set(handles.legendNWbutton,'Value',0);
    set(handles.legendNEbutton,'Value',0);
    set(handles.legendSWbutton,'Value',0);
    appdata.control.axis.legend.location = 'SouthEast';
else
    appdata.control.axis.legend.location = 'off';
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
        parentAppdata.control.axis.grid = appdata.control.axis.grid;
        parentAppdata.control.axis.legend = appdata.control.axis.legend;
        parentAppdata.control.axis.highlight = appdata.control.axis.highlight;
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
        trEPR_GUI_main('if_axis_Refresh',handles.callerHandle);
    end
end