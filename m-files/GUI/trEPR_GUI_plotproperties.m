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

% Last Modified by GUIDE v2.5 17-Jun-2010 11:48:23

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
configuration = struct(); % store the configuration information for the GUI
% --- store important control values, such as the currently active spectrum etc.
control = struct(...
    'spectra', struct(...
    'active',0,...
    'visible',cell(1),...
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

% Set appdata specific for this GUI
% NOTE: Due to the nasty restrictions for struct fieldnames (starting with
% [A-Za-z], no other characters than [A-Za-z0-9_]) there are a few
% conventions applying to the naming of the fields: "_" = "-", "0" = " ".
control.highlight = struct(...
    'Color',struct(...
    'blue','b',...
    'green','g',...
    'red','r',...
    'cyan','c',...
    'magenta','m',...
    'yellow','y',...
    'black','k'...
    ),...
    'Style',struct(...
    'solid','-',...
    'dashed','--',...
    'dotted',':',...
    'dash_dotted','-.'...
    ),...
    'Marker',struct(...
    'plus','+',...
    'circle','o',...
    'asterisk','*',...
    'point','.',...
    'cross','x',...
    'square','s',...
    'diamond','d',...
    'triangle0up','^',...
    'triangle0down','v',...
    'triangle0right','>',...
    'triangle0left','<',...
    'pentagram','p',...
    'hexagram','h'...
    )...
    );
setappdata(handles.figure1,'control',control);

% Fill elements with correct values
switch control.axis.displayType
    case '2D plot'
        set(handles.xLabelMeasureEdit,'String',...
            control.axis.labels.x.measure);
        set(handles.xLabelUnitEdit,'String',...
            control.axis.labels.x.unit);
        set(handles.yLabelMeasureEdit,'String',...
            control.axis.labels.y.measure);
        set(handles.yLabelUnitEdit,'String',...
            control.axis.labels.y.unit);
        % Switch off legend buttons, because legend does not work with
        % image "plot"
        set(handles.legendBestButton,'Enable','Off');
        set(handles.legendNWbutton,'Enable','Off');
        set(handles.legendNEbutton,'Enable','Off');
        set(handles.legendSWbutton,'Enable','Off');
        set(handles.legendSEbutton,'Enable','Off');
    case 'B0 spectra'
        set(handles.xLabelMeasureEdit,'String',...
            control.axis.labels.y.measure);
        set(handles.xLabelUnitEdit,'String',...
            control.axis.labels.y.unit);
        set(handles.yLabelMeasureEdit,'String',...
            control.axis.labels.z.measure);
        set(handles.yLabelUnitEdit,'String',...
            control.axis.labels.z.unit);
        % Switch on legend buttons
        set(handles.legendBestButton,'Enable','On');
        set(handles.legendNWbutton,'Enable','On');
        set(handles.legendNEbutton,'Enable','On');
        set(handles.legendSWbutton,'Enable','On');
        set(handles.legendSEbutton,'Enable','On');
    case 'transients'
        set(handles.xLabelMeasureEdit,'String',...
            control.axis.labels.x.measure);
        set(handles.xLabelUnitEdit,'String',...
            control.axis.labels.x.unit);
        set(handles.yLabelMeasureEdit,'String',...
            control.axis.labels.z.measure);
        set(handles.yLabelUnitEdit,'String',...
            control.axis.labels.z.unit);
        % Switch on legend buttons
        set(handles.legendBestButton,'Enable','On');
        set(handles.legendNWbutton,'Enable','On');
        set(handles.legendNEbutton,'Enable','On');
        set(handles.legendSWbutton,'Enable','On');
        set(handles.legendSEbutton,'Enable','On');
end
xlimits = get(callerHandles.axes1,'XLim');
ylimits = get(callerHandles.axes1,'YLim');
set(handles.xMinEdit,'String',num2str(xlimits(1)));
set(handles.yMinEdit,'String',num2str(ylimits(1)));
set(handles.xMaxEdit,'String',num2str(xlimits(2)));
set(handles.yMaxEdit,'String',num2str(ylimits(2)));
% Set grid options
switch control.axis.grid.x
    case 'off'
        set(handles.gridXButton,'Value',0);
    case 'major'
        set(handles.gridXButton,'Value',1);
    case 'minor'
        set(handles.gridXButton,'Value',1);
        set(handles.gridMinorButton,'Value',1);
end
switch control.axis.grid.y
    case 'off'
        set(handles.gridYButton,'Value',0);
    case 'major'
        set(handles.gridYButton,'Value',1);
    case 'minor'
        set(handles.gridYButton,'Value',1);
        set(handles.gridMinorButton,'Value',1);
end
set(handles.gridZeroLine,'Value',control.axis.grid.zero);
% Set legend options
switch control.axis.legend.location
    case 'Best'
        set(handles.legendBestButton,'Value',1);
    case 'NorthWest'
        set(handles.legendNWbutton,'Value',1);
    case 'NorthEast'
        set(handles.legendNEbutton,'Value',1);
    case 'SouthWest'
        set(handles.legendSWbutton,'Value',1);
    case 'SouthEast'
        set(handles.legendSEbutton,'Value',1);
end        

% Set highlighting method of active plot
highlightMethods = {'Color','LineWidth','LineStyle','Marker','none'};
set(...
    handles.plotHighlightMethodPopupmenu,...
    'Value',...
    ind(highlightMethods,control.axis.highlight.method));
switch control.axis.highlight.method
    case 'LineWidth'
        set(...
            handles.plotHighlightValuePopupmenu,...
            'String',...
            {'1 px','2 px','3 px','4 px','5 px'});
        set(...
            handles.plotHighlightValuePopupmenu,...
            'Value',...
            control.axis.highlight.value);
    case 'Color'
        highlightValueNames = fieldnames(...
            getfield(...
            control.highlight,...
            strrep(control.axis.highlight.method,'Line','')));
        set(handles.plotHighlightValuePopupmenu,'String',...
            highlightValueNames...
            );
        highlightValues = cell(1,length(highlightValueNames));
        for k = 1:length(highlightValueNames)
            highlightValues{k} = getfield(...
                getfield(...
                control.highlight,...
                strrep(control.axis.highlight.method,'Line','')),...
                highlightValueNames{k});
        end
        if isnumeric(control.axis.highlight.value)
            set(...
                handles.plotHighlightValuePopupmenu,...
                'Value',...
                8);
        else
            set(...
                handles.plotHighlightValuePopupmenu,...
                'Value',...
                ind(highlightValues,control.axis.highlight.value));
        end
    case 'none'
        set(...
            handles.plotHighlightValuePopupmenu,...
            'String',...
            {''});
        set(...
            handles.plotHighlightValuePopupmenu,...
            'Value',...
            1);        
        set(...
            handles.plotHighlightValuePopupmenu,...
            'Enable',...
            'Inactive');        
    otherwise
        highlightValueNames = fieldnames(...
            getfield(...
            control.highlight,...
            strrep(control.axis.highlight.method,'Line','')));
        set(handles.plotHighlightValuePopupmenu,'String',...
            highlightValueNames...
            );
        highlightValues = cell(1,length(highlightValueNames));
        for k = 1:length(highlightValueNames)
            highlightValues{k} = getfield(...
                getfield(...
                control.highlight,...
                strrep(control.axis.highlight.method,'Line','')),...
                highlightValueNames{k});
        end
        set(...
            handles.plotHighlightValuePopupmenu,...
            'Value',...
            ind(highlightValues,control.axis.highlight.value));
end

if_spectraVisibleListboxRefresh(hObject);

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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

lineColors = struct(...
    'blue','b',...
    'green','g',...
    'red','r',...
    'cyan','c',...
    'magenta','m',...
    'yellow','y',...
    'black','k',...
    'other',''...
    );

contents = get(hObject,'String');
if strcmp(contents{get(hObject,'Value')},'other')
    % TODO: Handle color palette output
    % For now, set to gray
    appdata.data{appdata.control.spectra.active}.line.color = ...
        [0.6 0.6 0.6];
else
    appdata.data{appdata.control.spectra.active}.line.color = ...
        getfield(lineColors,contents{get(hObject,'Value')});
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hints: get(hObject,'String') returns contents of lineWidthEdit as text
%        str2double(get(hObject,'String')) returns contents of lineWidthEdit as a double
if isnan(str2double(get(handles.lineWidthEdit,'String')))
    set(handles.lineWidthEdit,'String',...
        num2str(appdata.data{appdata.control.spectra.active}.line.width));
else
    appdata.data{appdata.control.spectra.active}.line.width = ...
        round(str2double(get(handles.lineWidthEdit,'String')));
    set(handles.lineWidthEdit,'String',...
        num2str(round(str2double(get(handles.lineWidthEdit,'String')))));
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

lineStyles = struct(...
    'solid','-',...
    'dashed','--',...
    'dotted',':',...
    'dash_dotted','-.'...
    );
contents = get(hObject,'String');
for k=1:length(contents)
    contents{k} = strrep(contents{k},' ','0');
    contents{k} = strrep(contents{k},'-','_');
end
appdata.data{appdata.control.spectra.active}.line.style = ...
    getfield(lineStyles,contents{get(hObject,'Value')});

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
function lineStylePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineStylePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lineMarkersPopupmenu.
function lineMarkersPopupmenu_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

lineMarkers = struct(...
    'none','none',...
    'plus','+',...
    'circle','o',...
    'asterisk','*',...
    'point','.',...
    'cross','x',...
    'square','s',...
    'diamond','d',...
    'triangle0up','^',...
    'triangle0down','v',...
    'triangle0right','>',...
    'triangle0left','<',...
    'pentagram','p',...
    'hexagram','h'...
    );

contents = get(hObject,'String');
for k=1:length(contents)
    contents{k} = strrep(contents{k},' ','0');
    contents{k} = strrep(contents{k},'-','_');
end
appdata.data{appdata.control.spectra.active}.line.marker = ...
    getfield(lineMarkers,contents{get(hObject,'Value')});

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
function lineMarkersPopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineMarkersPopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function xLabelMeasureEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        appdata.control.axis.labels.x.measure = get(hObject,'String');
    case 'B0 spectra'
        appdata.control.axis.labels.y.measure = get(hObject,'String');
    case 'transients'
        appdata.control.axis.labels.x.measure = get(hObject,'String');
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        appdata.control.axis.labels.y.measure = get(hObject,'String');
    case 'B0 spectra'
        appdata.control.axis.labels.z.measure = get(hObject,'String');
    case 'transients'
        appdata.control.axis.labels.z.measure = get(hObject,'String');
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        appdata.control.axis.labels.x.unit = get(hObject,'String');
    case 'B0 spectra'
        appdata.control.axis.labels.y.unit = get(hObject,'String');
    case 'transients'
        appdata.control.axis.labels.x.unit = get(hObject,'String');
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        appdata.control.axis.labels.y.unit = get(hObject,'String');
    case 'B0 spectra'
        appdata.control.axis.labels.z.unit = get(hObject,'String');
    case 'transients'
        appdata.control.axis.labels.z.unit = get(hObject,'String');
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


function xMinEdit_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        if isnan(str2double(get(handles.xMinEdit,'String')))
            set(handles.xMinEdit,'String',...
                num2str(control.axis.limits.x.min));
        else
            appdata.control.axis.limits.x.min = ...
                str2double(get(handles.xMinEdit,'String'));
        end
    case 'B0 spectra'
        if isnan(str2double(get(handles.xMinEdit,'String')))
            set(handles.xMinEdit,'String',...
                num2str(control.axis.limits.y.min));
        else
            appdata.control.axis.limits.y.min = ...
                str2double(get(handles.xMinEdit,'String'));
        end
    case 'transients'
        if isnan(str2double(get(handles.xMinEdit,'String')))
            set(handles.xMinEdit,'String',...
                num2str(control.axis.limits.x.min));
        else
            appdata.control.axis.limits.x.min = ...
                str2double(get(handles.xMinEdit,'String'));
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        if isnan(str2double(get(handles.yMinEdit,'String')))
            set(handles.xMinEdit,'String',...
                num2str(control.axis.limits.y.min));
        else
            appdata.control.axis.limits.y.min = ...
                str2double(get(handles.yMinEdit,'String'));
        end
    case 'B0 spectra'
        if isnan(str2double(get(handles.yMinEdit,'String')))
            set(handles.yMinEdit,'String',...
                num2str(control.axis.limits.z.min));
        else
            appdata.control.axis.limits.z.min = ...
                str2double(get(handles.yMinEdit,'String'));
        end
    case 'transients'
        if isnan(str2double(get(handles.yMinEdit,'String')))
            set(handles.yMinEdit,'String',...
                num2str(control.axis.limits.z.min));
        else
            appdata.control.axis.limits.z.min = ...
                str2double(get(handles.yMinEdit,'String'));
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        if isnan(str2double(get(handles.xMaxEdit,'String')))
            set(handles.xMaxEdit,'String',...
                num2str(control.axis.limits.x.max));
        else
            appdata.control.axis.limits.x.max = ...
                str2double(get(handles.xMaxEdit,'String'));
        end
    case 'B0 spectra'
        if isnan(str2double(get(handles.xMaxEdit,'String')))
            set(handles.xMaxEdit,'String',...
                num2str(control.axis.limits.y.max));
        else
            appdata.control.axis.limits.y.max = ...
                str2double(get(handles.xMaxEdit,'String'));
        end
    case 'transients'
        if isnan(str2double(get(handles.xMaxEdit,'String')))
            set(handles.xMaxEdit,'String',...
                num2str(control.axis.limits.x.max));
        else
            appdata.control.axis.limits.x.max = ...
                str2double(get(handles.xMaxEdit,'String'));
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

switch appdata.control.axis.displayType
    case '2D plot'
        if isnan(str2double(get(handles.yMaxEdit,'String')))
            set(handles.yMaxEdit,'String',...
                num2str(control.axis.limits.y.max));
        else
            appdata.control.axis.limits.y.max = ...
                str2double(get(handles.yMaxEdit,'String'));
        end
    case 'B0 spectra'
        if isnan(str2double(get(handles.yMaxEdit,'String')))
            set(handles.yMaxEdit,'String',...
                num2str(control.axis.limits.z.max));
        else
            appdata.control.axis.limits.z.max = ...
                str2double(get(handles.yMaxEdit,'String'));
        end
    case 'transients'
        if isnan(str2double(get(handles.yMaxEdit,'String')))
            set(handles.yMaxEdit,'String',...
                num2str(control.axis.limits.z.max));
        else
            appdata.control.axis.limits.z.max = ...
                str2double(get(handles.yMaxEdit,'String'));
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Hints: contents = get(hObject,'String') returns spectraVisibleListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectraVisibleListbox
% Refresh handles and appdata of the current GUI

appdata.control.spectra.active = ...
    appdata.control.spectra.visible{get(hObject,'Value')};

guidata(hObject,handles);
appdataFieldnames = fieldnames(appdata);
for k=1:length(appdataFieldnames)
  setappdata(...
      handles.figure1,...
      appdataFieldnames{k},...
      getfield(appdata,appdataFieldnames{k})...
      );
end

if_spectraVisibleListboxRefresh(hObject);


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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if appdata.control.spectra.active == appdata.control.spectra.visible{1}
    appdata.control.spectra.active = appdata.control.spectra.visible{end};
else
    appdata.control.spectra.active = appdata.control.spectra.visible{...
        appdata.control.spectra.active-1};
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

if_spectraVisibleListboxRefresh(hObject);


% --- Executes on button press in spectraNextButton.
function spectraNextButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if appdata.control.spectra.active == appdata.control.spectra.visible{end}
    appdata.control.spectra.active = appdata.control.spectra.visible{1};
else
    appdata.control.spectra.active = appdata.control.spectra.visible{...
        appdata.control.spectra.active+1};
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

if_spectraVisibleListboxRefresh(hObject);


% --- Executes on button press in spectraResetButton.
function spectraResetButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.line.color = 'k';
set(handles.lineColorPopupmenu,'Value',7);
appdata.data{appdata.control.spectra.active}.line.style = '-';
set(handles.lineStylePopupmenu,'Value',1);
appdata.data{appdata.control.spectra.active}.line.marker = 'none';
set(handles.lineMarkersPopupmenu,'Value',1);
appdata.data{appdata.control.spectra.active}.line.width = 1;
set(handles.lineWidthEdit,'String','1');

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
            fieldnames(appdata.control.highlight.Color));
        set(handles.plotHighlightValuePopupmenu,'Enable','on');        
    case 'Width'
        set(handles.plotHighlightValuePopupmenu,'String',...
            {'1 px','2 px','3 px','4 px','5 px'});
        set(handles.plotHighlightValuePopupmenu,'Enable','on');        
    case 'Style'
        values = fieldnames(appdata.control.highlight.Style);
        for k=1:length(values)
            values{k} = strrep(values{k},'_','-');
            values{k} = strrep(values{k},'0',' ');
        end
        set(handles.plotHighlightValuePopupmenu,'String',values);
        set(handles.plotHighlightValuePopupmenu,'Enable','on');        
    case 'Marker'
        values = fieldnames(appdata.control.highlight.Marker);
        for k=1:length(values)
            values{k} = strrep(values{k},'_','-');
            values{k} = strrep(values{k},'0',' ');
        end
        set(handles.plotHighlightValuePopupmenu,'String',values);
        set(handles.plotHighlightValuePopupmenu,'Enable','on');        
    case 'none'
        set(handles.plotHighlightValuePopupmenu,'String',{''});
        set(handles.plotHighlightValuePopupmenu,'Enable','inactive');        
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

plotHighlightValuePopupmenu_Callback(hObject, eventdata, handles);
if_parentAppdataRefresh(hObject);


% --- Executes during object creation, after setting all properties.
function plotHighlightMethodPopupmenu_CreateFcn(hObject, eventdata, handles)

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

contents = get(handles.plotHighlightValuePopupmenu,'String');
methodContents = get(handles.plotHighlightMethodPopupmenu,'String');
valueContents = get(handles.plotHighlightValuePopupmenu,'String');
for k=1:length(valueContents)
    valueContents{k} = strrep(valueContents{k},'-','_');
    valueContents{k} = strrep(valueContents{k},' ','0');
end
switch methodContents{get(handles.plotHighlightMethodPopupmenu,'Value')}
    case 'Color'
        appdata.control.axis.highlight.method = 'Color';
        appdata.control.axis.highlight.value = ...
            getfield(appdata.control.highlight.Color,...
            valueContents{get(handles.plotHighlightValuePopupmenu,'Value')});
    case 'Width'
        appdata.control.axis.highlight.method = 'LineWidth';
        appdata.control.axis.highlight.value = ...
            str2double(...
            contents{get(handles.plotHighlightValuePopupmenu,'Value')}(1));
    case 'Style'
        appdata.control.axis.highlight.method = 'LineStyle';
        appdata.control.axis.highlight.value = ...
            getfield(appdata.control.highlight.Style,...
            valueContents{get(handles.plotHighlightValuePopupmenu,'Value')});
    case 'Marker'
        appdata.control.axis.highlight.method = 'Marker';
        appdata.control.axis.highlight.value = ...
            getfield(appdata.control.highlight.Marker,...
            valueContents{get(handles.plotHighlightValuePopupmenu,'Value')});
    case 'none'
        appdata.control.axis.highlight.method = 'none';
        appdata.control.axis.highlight.value = '';
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
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

appdata.data{appdata.control.spectra.active}.label = get(hObject,'String');

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
if_spectraVisibleListboxRefresh(hObject);


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


% --- Executes on button press in axesConvert2mT.
function axesConvert2mT_Callback(hObject, eventdata, handles)
% hObject    handle to axesConvert2mT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axesConvert2mT


% --- Executes on button press in axesConvert2G.
function axesConvert2G_Callback(hObject, eventdata, handles)
% hObject    handle to axesConvert2G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axesConvert2G


% --- Executes on button press in axesLimOptButton.
function axesLimOptButton_Callback(hObject, eventdata, handles)
% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

for k=1:length(appdata.control.spectra.visible)
    xLimits(k,:) = [...
       min(appdata.data{appdata.control.spectra.visible{k}}.axes.xaxis.values) ...
       max(appdata.data{appdata.control.spectra.visible{k}}.axes.xaxis.values) ...                
       ];    
    yLimits(k,:) = [...
       min(appdata.data{appdata.control.spectra.visible{k}}.axes.yaxis.values) ...
       max(appdata.data{appdata.control.spectra.visible{k}}.axes.yaxis.values) ...                
       ];    
    zLimits(k,:) = [...
       min(min(appdata.data{appdata.control.spectra.visible{k}}.data)) ...
       max(max(appdata.data{appdata.control.spectra.visible{k}}.data)) ...                
       ];    
end
appdata.control.axis.limits.x.min = min(min(xLimits));
appdata.control.axis.limits.x.max = max(max(xLimits));
appdata.control.axis.limits.y.min = min(min(yLimits));
appdata.control.axis.limits.y.max = max(max(yLimits));
appdata.control.axis.limits.z.min = min(min(zLimits))*1.05;
appdata.control.axis.limits.z.max = max(max(zLimits))*1.05;

% Set values in limits edit fields to new values
switch appdata.control.axis.displayType
    case '2D plot'
        set(handles.xMinEdit,'String',...
            num2str(appdata.control.axis.limits.x.min));
        set(handles.xMaxEdit,'String',...
            num2str(appdata.control.axis.limits.x.max));
        set(handles.yMinEdit,'String',...
            num2str(appdata.control.axis.limits.y.min));
        set(handles.yMaxEdit,'String',...
            num2str(appdata.control.axis.limits.y.max));
    case 'B0 spectra'
        set(handles.xMinEdit,'String',...
            num2str(appdata.control.axis.limits.y.min));
        set(handles.xMaxEdit,'String',...
            num2str(appdata.control.axis.limits.y.max));
        set(handles.yMinEdit,'String',...
            num2str(appdata.control.axis.limits.z.min));
        set(handles.yMaxEdit,'String',...
            num2str(appdata.control.axis.limits.z.max));
    case 'transients'
        set(handles.xMinEdit,'String',...
            num2str(appdata.control.axis.limits.x.min));
        set(handles.xMaxEdit,'String',...
            num2str(appdata.control.axis.limits.x.max));
        set(handles.yMinEdit,'String',...
            num2str(appdata.control.axis.limits.z.min));
        set(handles.yMaxEdit,'String',...
            num2str(appdata.control.axis.limits.z.max));
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


% --- Executes on button press in functionsGAxisShowButton.
function functionsGAxisShowButton_Callback(hObject, eventdata, handles)
% hObject    handle to functionsGAxisShowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of functionsGAxisShowButton


% --- Executes on button press in functionsGAxisConvertButton.
function functionsGAxisConvertButton_Callback(hObject, eventdata, handles)
% hObject    handle to functionsGAxisConvertButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of functionsGAxisConvertButton


% --- Executes on button press in functionsNormalize01Button.
function functionsNormalize01Button_Callback(hObject, eventdata, handles)
% hObject    handle to functionsNormalize01Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of functionsNormalize01Button


% --- Executes on button press in functionsNormalizePkPkButton.
function functionsNormalizePkPkButton_Callback(hObject, eventdata, handles)
% hObject    handle to functionsNormalizePkPkButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of functionsNormalizePkPkButton


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
        parentAppdata.control.axis.labels = appdata.control.axis.labels;
        parentAppdata.control.axis.limits = appdata.control.axis.limits;
        parentAppdata.control.axis.highlight = appdata.control.axis.highlight;
        for k=1:length(appdata.control.spectra.visible)
            parentAppdata.data{appdata.control.spectra.visible{k}}.line = ...
                appdata.data{appdata.control.spectra.visible{k}}.line;
            parentAppdata.data{appdata.control.spectra.visible{k}}.label = ...
                appdata.data{appdata.control.spectra.visible{k}}.label;
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
        trEPR_GUI_main('if_axis_Refresh',handles.callerHandle);
    end
end

function if_spectraVisibleListboxRefresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

visibleSpectraNames = cell(1,length(appdata.control.spectra.visible));
for k=1:length(appdata.control.spectra.visible)
    visibleSpectraNames{k} = ...
        appdata.data{appdata.control.spectra.visible{k}}.label;
end
set(handles.spectraVisibleListbox,'String',visibleSpectraNames);
set(handles.spectraVisibleListbox,'Value',appdata.control.spectra.active);

% Set values of Line Style panel
% Color, Style, Markers
colorValues = {'b','g','r','c','m','y','k'};
styleValues = {'-','--',':','-.'};
markerValues = {'none','+','o','*','.','x','s','d','^','v','>','<','p','h'};
if isnumeric(appdata.data{appdata.control.spectra.active}.line.color)
    set(...
        handles.lineColorPopupmenu,...
        'Value',...
        length(colorValues)+1);
else
    set(...
        handles.lineColorPopupmenu,...
        'Value',...
        ind(colorValues,appdata.data{appdata.control.spectra.active}.line.color));
end
set(...
    handles.lineStylePopupmenu,...
    'Value',...
    ind(styleValues,appdata.data{appdata.control.spectra.active}.line.style));
set(...
    handles.lineMarkersPopupmenu,...
    'Value',...
    ind(markerValues,appdata.data{appdata.control.spectra.active}.line.marker));
% Label, LineWidth
set(handles.lineWidthEdit,'String',num2str(...
    appdata.data{appdata.control.spectra.active}.line.width));
set(handles.legendLabelEdit,'String',...
    appdata.data{appdata.control.spectra.active}.label);

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
