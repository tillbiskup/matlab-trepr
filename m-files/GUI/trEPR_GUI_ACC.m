function varargout = trEPR_GUI_ACC(varargin)
% TREPR_GUI_ACC M-file for trEPR_GUI_ACC.fig
%      TREPR_GUI_ACC, by itself, creates a new TREPR_GUI_ACC or raises the existing
%      singleton*.
%
%      H = TREPR_GUI_ACC returns the handle to a new TREPR_GUI_ACC or the handle to
%      the existing singleton*.
%
%      TREPR_GUI_ACC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREPR_GUI_ACC.M with the given input arguments.
%
%      TREPR_GUI_ACC('Property','Value',...) creates a new TREPR_GUI_ACC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trEPR_GUI_ACC_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trEPR_GUI_ACC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_ACC

% Last Modified by GUIDE v2.5 21-Apr-2010 23:49:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trEPR_GUI_ACC_OpeningFcn, ...
                   'gui_OutputFcn',  @trEPR_GUI_ACC_OutputFcn, ...
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


% --- Executes just before trEPR_GUI_ACC is made visible.
function trEPR_GUI_ACC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trEPR_GUI_ACC (see VARARGIN)

% Choose default command line output for trEPR_GUI_ACC
handles.output = hObject;

set(hObject,'Name','trEPR toolbox : accumulation');

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

% Get appdata from parent window necessary for ACC
if isfield(handles,'callerFunction') && isfield(handles,'callerHandle')
    callerHandles = guidata(handles.callerHandle);
    if isfield(callerHandles,mfilename)

        % Get appdata of the parent GUI
        parentAppdata = getappdata(callerHandles.figure1);
        
        data = parentAppdata.data;
        % Assign necessary control parameters to data structure
        for k = 1:length(data)
            % Adjust displacement in field direction: Apply to field axis
            if data{k}.Db0
                data{k}.axes.yaxis.values = [...
                    data{k}.axes.yaxis.values(1) + (...
                    data{k}.parameters.field.step * data{k}.Db0) : ...
                    data{k}.parameters.field.step : ...
                    data{k}.axes.yaxis.values(end) + (...
                    data{k}.parameters.field.step * data{k}.Db0)];
                data{k}.parameters.field.start = ...
                    data{k}.axes.yaxis.values(1) + (...
                    data{k}.parameters.field.step * data{k}.Db0);
                data{k}.parameters.field.stop = ...
                    data{k}.axes.yaxis.values(1) + (...
                    data{k}.parameters.field.step * data{k}.Db0);
            end
            % Assign filenames (basename) to control.filenames cell array
            [path name ext] = fileparts(data{k}.filename);
            filenames{k} = name;
            clear path name ext;
            % Assign field parameters to control structure
            control.spectra.field.start(k) = data{k}.parameters.field.start;
            control.spectra.field.stop(k) = data{k}.parameters.field.stop;
            control.spectra.field.step(k) = data{k}.parameters.field.step;
        end
        control.spectra = parentAppdata.control.spectra;
        control.spectra.filenames = filenames;
        setappdata(handles.figure1,'data',data);
        setappdata(handles.figure1,'control',control);
    
        % Set suggestion for filename of accumulated spectra
        set(handles.filenameEdit,'String',...
            sprintf('%sacc.dat',commonString(control.spectra.filenames,1)));
    end
    guidata(handles.callerHandle,callerHandles);
end

% Set reload button inactive
set(handles.resizeButton,'Enable','Off');

% Update handles structure
guidata(hObject, handles);

% Update listbox with spectra names
if ~isempty(control.spectra.visible)
    if_spectraAccumulatedListbox_Refresh(hObject);
    if_axis_Refresh(hObject);
end

% UIWAIT makes trEPR_GUI_ACC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trEPR_GUI_ACC_OutputFcn(hObject, eventdata, handles) 
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


% --- Executes during object creation, after setting all properties.
function spectraScrollSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraScrollSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
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
        num2str(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1)));
    set(handles.spectraScrollSlider,'Value',...
        get(handles.spectraScrollSlider,'Min'));
elseif value > length(appdata.data{appdata.control.spectra.active}.axes.xaxis.values)
    appdata.data{appdata.control.spectra.active}.t = ...
        length(appdata.data{appdata.control.spectra.active}.axes.xaxis.values);
    set(handles.positionInTimePointsEdit,'String',...
        num2str(...
        length(appdata.data{appdata.control.spectra.active}.axes.xaxis.values)));
    set(handles.positionInTimeValueEdit,'String',...
        num2str(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values(end)));
    set(handles.spectraScrollSlider,'Value',...
        get(handles.spectraScrollSlider,'Max'));
else
    appdata.data{appdata.control.spectra.active}.t = value;
    set(handles.positionInTimePointsEdit,'String',num2str(value));
    set(handles.positionInTimeValueEdit,'String',...
        num2str(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values(...
        value)));
    set(handles.spectraScrollSlider,'Value',value);
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


function positionInTimeValueEdit_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

value = str2double(get(hObject,'String'));
min = appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1);
max = appdata.data{appdata.control.spectra.active}.axes.xaxis.values(end);
    
if value>=min && value<=max
    set(handles.spectraScrollSlider,'Value',...
        interp1(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values,...
        1:length(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values),...
        value,'nearest'));
    set(handles.positionInTimeValueEdit,'String',...
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
    set(handles.spectraScrollSlider,'Value',...
        get(handles.spectraScrollSlider,'Min'));
    set(handles.positionInTimeValueEdit,'String',num2str(min));
    appdata.data{appdata.control.spectra.active}.t = 1;
else
    set(handles.spectraScrollSlider,'Value',...
        get(handles.spectraScrollSlider,'Max'));
    set(handles.positionInTimeValueEdit,'String',num2str(max));
    appdata.data{appdata.control.spectra.active}.t = length(...
        appdata.data{appdata.control.spectra.active}.axes.xaxis.values);
end    

set(handles.positionInTimePointsEdit,'String',...
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


% --- Executes on button press in resizeButton.
function resizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to resizeButton (see GCBO)
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


% --- Executes on selection change in spectraNotAccumulatedListbox.
function spectraNotAccumulatedListbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectraNotAccumulatedListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function spectraNotAccumulatedListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraNotAccumulatedListbox (see GCBO)
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
            % Get appdata from parent window necessary for ACC
            if isfield(handles,'callerFunction') && ...
                    isfield(handles,'callerHandle')
                callerHandles = guidata(handles.callerHandle);
                if isfield(callerHandles,mfilename)
                    % Get appdata of the parent GUI
                    parentAppdata = getappdata(callerHandles.figure1);
                    for k = 1:length(modified)
                        [x y] = size(appdata.data{modified(k)}.data);
                        for l = appdata.data{modified(k)}.parameters.transient.triggerPosition:y
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
                    trEPR_GUI_main('if_axis_Refresh',handles.callerHandle);
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
function if_spectraAccumulatedListbox_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Extract names of visible Spectra from appdata
visSpectraNames = cell(1);
if isempty(appdata.control.spectra.visible{1})
    visSpectraNames = cell(1);
    appdata.control.spectra.active = 0;
    set(handles.spectraAccumulatedListbox,'Enable','Inactive');
    cla(handles.axes1,'reset');
    cla(handles.axes2,'reset');
    set(handles.timeEditIndex,'Enable','Inactive');
else
    set(handles.spectraAccumulatedListbox,'Enable','On');
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
selectedValue = get(handles.spectraAccumulatedListbox,'Value');
if selectedValue > maxValue
    set(handles.spectraAccumulatedListbox,'Value',maxValue);
end

% Set currently active spectrum
% Use a trick to determine whether it is the first load
if isempty(get(handles.spectraAccumulatedListbox,'String'))
    set(handles.spectraAccumulatedListbox,...
        'Value',...
        appdata.control.spectra.active);
else
    appdata.control.spectra.active = appdata.control.spectra.visible{...
        get(handles.spectraAccumulatedListbox,'Value')...
        };
end

% Set listbox display
set(handles.spectraAccumulatedListbox,'String',visSpectraNames);

% If there are no visible spectra any more, set appdata, turn off elements
% and return 
if isempty(appdata.control.spectra.active)
    appdata.control.spectra.active = 0;
    set(handles.spectraAccumulatedListbox,'Enable','Inactive');
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
    set(handles.spectraAccumulatedListbox,'Enable','On');
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

% Set Infobox fields
set(handles.infoFieldStepsizeEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.field.step));
set(handles.infoFieldStartEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.field.start));
set(handles.infoFieldStopEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.field.stop));
set(handles.infoFieldMeasureText,'String',...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.unit);
set(handles.infoTimeLengthValueEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.transient.length));
set(handles.infoTimeLengthPointsEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.transient.points));
set(handles.infoTimeMeasureText,'String',...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.unit);
if isfield(appdata.data{appdata.control.spectra.active}.parameters,'recorder')
    set(handles.infoNoScansEdit,'String',...
        num2str(...
        appdata.data{appdata.control.spectra.active}.parameters.recorder.averages));
else
    set(handles.infoNoScansEdit,'String','N/A');
end

% Set current values for resize fields
set(handles.resizeFieldStepsizeEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.field.step));
set(handles.resizeFieldStartEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.field.start));
set(handles.resizeFieldMeasureText,'String',...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.unit);
set(handles.resizeTimeStartEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1)));
set(handles.resizeTimeStepsizeEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values(2)-...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values(1)));
set(handles.resizeTimeLengthValueEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.transient.length));
set(handles.resizeTimeLengthPointsEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.transient.points));
set(handles.resizeTimeMeasureText1,'String',...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.unit);
set(handles.resizeTimeMeasureText2,'String',...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.unit);

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

plot(...
    handles.axes1,...
    yaxis,...
    appdata.data{appdata.control.spectra.active}.data(...
    :,floor(appdata.data{appdata.control.spectra.active}.t)...
    )...
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
    handles.axes1,...
    'YLim',...
    [...
    min(min(appdata.data{appdata.control.spectra.active}.data))*1.05 ...
    max(max(appdata.data{appdata.control.spectra.active}.data))*1.05 ...                
    ]...
    );

% Add horizontal line at position 0 in upper axis
axes(handles.axes1)
line([yaxis(1) yaxis(end)],[0 0],...
    'Color',[0.75 0.75 0.75],...
    'LineWidth',1,...
    'LineStyle','--');

xlabel(handles.axes1,sprintf('{\\it magnetic field} / mT'));
ylabel(handles.axes1,sprintf('{\\it intensity} / a.u.'));
    
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


% --- Executes on button press in spectraRemoveButton.
function spectraRemoveButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraRemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spectraAddButton.
function spectraAddButton_Callback(hObject, eventdata, handles)
% hObject    handle to spectraAddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function filenameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to filenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenameEdit as text
%        str2double(get(hObject,'String')) returns contents of filenameEdit as a double


% --- Executes during object creation, after setting all properties.
function filenameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in spectraAccumulatedListbox.
function spectraAccumulatedListbox_Callback(hObject, eventdata, handles)

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

% Set currently active spectrum
if ~isempty(appdata.control.spectra.visible)
    appdata.control.spectra.active = appdata.control.spectra.visible{...
        get(handles.spectraAccumulatedListbox,'Value')...
        };
    if_spectraAccumulatedListbox_Refresh(hObject);
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
function spectraAccumulatedListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraAccumulatedListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in normalizeCheckbox.
function normalizeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to normalizeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of normalizeCheckbox



function infoNoScansEdit_Callback(hObject, eventdata, handles)
% hObject    handle to infoNoScansEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of infoNoScansEdit as text
%        str2double(get(hObject,'String')) returns contents of infoNoScansEdit as a double


% --- Executes during object creation, after setting all properties.
function infoNoScansEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infoNoScansEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function infoFieldStepsizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to infoFieldStepsizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of infoFieldStepsizeEdit as text
%        str2double(get(hObject,'String')) returns contents of infoFieldStepsizeEdit as a double


% --- Executes during object creation, after setting all properties.
function infoFieldStepsizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infoFieldStepsizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function infoFieldStartEdit_Callback(hObject, eventdata, handles)
% hObject    handle to infoFieldStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of infoFieldStartEdit as text
%        str2double(get(hObject,'String')) returns contents of infoFieldStartEdit as a double


% --- Executes during object creation, after setting all properties.
function infoFieldStartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infoFieldStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function infoFieldStopEdit_Callback(hObject, eventdata, handles)
% hObject    handle to infoFieldStopEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of infoFieldStopEdit as text
%        str2double(get(hObject,'String')) returns contents of infoFieldStopEdit as a double


% --- Executes during object creation, after setting all properties.
function infoFieldStopEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infoFieldStopEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function infoTimeLengthValueEdit_Callback(hObject, eventdata, handles)
% hObject    handle to infoTimeLengthValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of infoTimeLengthValueEdit as text
%        str2double(get(hObject,'String')) returns contents of infoTimeLengthValueEdit as a double


% --- Executes during object creation, after setting all properties.
function infoTimeLengthValueEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infoTimeLengthValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function infoTimeLengthPointsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to infoTimeLengthPointsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of infoTimeLengthPointsEdit as text
%        str2double(get(hObject,'String')) returns contents of infoTimeLengthPointsEdit as a double


% --- Executes during object creation, after setting all properties.
function infoTimeLengthPointsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infoTimeLengthPointsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resizeFieldStepsizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resizeFieldStepsizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeFieldStepsizeEdit as text
%        str2double(get(hObject,'String')) returns contents of resizeFieldStepsizeEdit as a double


% --- Executes during object creation, after setting all properties.
function resizeFieldStepsizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeFieldStepsizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resizeFieldStartEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resizeFieldStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeFieldStartEdit as text
%        str2double(get(hObject,'String')) returns contents of resizeFieldStartEdit as a double


% --- Executes during object creation, after setting all properties.
function resizeFieldStartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeFieldStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resizeTimeLengthValueEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resizeTimeLengthValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeTimeLengthValueEdit as text
%        str2double(get(hObject,'String')) returns contents of resizeTimeLengthValueEdit as a double


% --- Executes during object creation, after setting all properties.
function resizeTimeLengthValueEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeTimeLengthValueEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resizeTimeLengthPointsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resizeTimeLengthPointsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeTimeLengthPointsEdit as text
%        str2double(get(hObject,'String')) returns contents of resizeTimeLengthPointsEdit as a double


% --- Executes during object creation, after setting all properties.
function resizeTimeLengthPointsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeTimeLengthPointsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resizeTimeStepsizeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resizeTimeStepsizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeTimeStepsizeEdit as text
%        str2double(get(hObject,'String')) returns contents of resizeTimeStepsizeEdit as a double


% --- Executes during object creation, after setting all properties.
function resizeTimeStepsizeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeTimeStepsizeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function resizeTimeStartEdit_Callback(hObject, eventdata, handles)
% hObject    handle to resizeTimeStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resizeTimeStartEdit as text
%        str2double(get(hObject,'String')) returns contents of resizeTimeStartEdit as a double


% --- Executes during object creation, after setting all properties.
function resizeTimeStartEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resizeTimeStartEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


