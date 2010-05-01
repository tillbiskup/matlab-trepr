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

% Last Modified by GUIDE v2.5 22-Apr-2010 09:26:37

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
setappdata(handles.figure1,'olddata',data);
setappdata(handles.figure1,'acc',acc);
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
        end
        control.spectra = parentAppdata.control.spectra;
        control.spectra.accumulated = ...
            parentAppdata.control.spectra.visible;
        control.spectra.notaccumulated = cell(1);
        setappdata(handles.figure1,'data',data);
        setappdata(handles.figure1,'olddata',data);
        setappdata(handles.figure1,'control',control);

        for k = 1 : length(control.spectra.accumulated)
            % Assign filenames (basename) to control.filenames cell array
            [path name ext] = fileparts(...
                data{control.spectra.accumulated{k}}.filename);
            filenames{k} = name;
            clear path name ext;
        end

        % Set suggestion for filename of accumulated spectra
        set(handles.filenameEdit,'String',...
            sprintf('%sacc',commonString(filenames,1)));
    end
    guidata(handles.callerHandle,callerHandles);
end

% Set reload button inactive
set(handles.resizeButton,'Enable','Off');

% Update handles structure
guidata(hObject, handles);

% Update listbox with spectra names
if ~isempty(control.spectra.accumulated)
    if_spectraAccumulatedListbox_Refresh(hObject);
    if_axis_Refresh(hObject);
end

if ~isempty(control.spectra.notaccumulated)
    if_spectraNotAccumulatedListbox_Refresh(hObject);
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
set(handles.positionInTimeValueEdit,'String',...
    appdata.data{appdata.control.spectra.active}.axes.xaxis.values(...
    floor(get(handles.spectraScrollSlider,'Value'))));

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

% Get appdata of the current GUI
appdata = getappdata(handles.figure1);

% Set currently active spectrum
if ~isempty(appdata.control.spectra.notaccumulated)
    appdata.control.spectra.active = appdata.control.spectra.notaccumulated{...
        get(handles.spectraNotAccumulatedListbox,'Value')...
        };
    if_spectraNotAccumulatedListbox_Refresh(hObject);
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
function spectraNotAccumulatedListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraNotAccumulatedListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in spectraRemoveButton.
function spectraRemoveButton_Callback(hObject, eventdata, handles)
% --- Move currently selected spectrum to not accumulated spectra

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Return immediately if there is no accumulated spectrum
if isempty(appdata.control.spectra.accumulated)
    return
elseif isempty(appdata.control.spectra.accumulated{1})
    return
end

% Get value of currently selected item
iSelected = appdata.control.spectra.accumulated{...
    get(handles.spectraAccumulatedListbox,'Value')...
    };

% Add selected to not accumulated
naccSpectra = length(appdata.control.spectra.notaccumulated);
if naccSpectra == 1 && isempty(appdata.control.spectra.notaccumulated{1})
    appdata.control.spectra.notaccumulated{1} = iSelected;
else
    appdata.control.spectra.notaccumulated{naccSpectra+1} = iSelected;
end

% Remove selected from accumulated
accSpectra = length(appdata.control.spectra.accumulated);
for k=1:accSpectra
    if appdata.control.spectra.accumulated{k} == iSelected
        appdata.control.spectra.accumulated(k) = [];
        break;  % !!! above statement manipulates cell array length
    end
end
% Prevent empty cell array
if isempty(appdata.control.spectra.accumulated)
    appdata.control.spectra.accumulated{1} = [];
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

% Call to internal function refreshing the spectra listboxes and axes
%     => important to do it after refreshing handles and appdata!
if_spectraNotAccumulatedListbox_Refresh(handles.figure1);
if_spectraAccumulatedListbox_Refresh(handles.figure1);

if_axis_Refresh(handles.figure1);


% --- Executes on button press in spectraAddButton.
function spectraAddButton_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Return immediately if there is no not accumulated spectrum
if isempty(appdata.control.spectra.notaccumulated)
    return
elseif isempty(appdata.control.spectra.notaccumulated{1})
    return
end

% Get value of currently selected item
iSelected = appdata.control.spectra.notaccumulated{...
    get(handles.spectraNotAccumulatedListbox,'Value')...
    };

% Add selected to accumulated
accSpectra = length(appdata.control.spectra.accumulated);
if accSpectra == 1 && isempty(appdata.control.spectra.accumulated{1})
    appdata.control.spectra.accumulated{1} = iSelected;
else
    appdata.control.spectra.accumulated{accSpectra+1} = iSelected;
end

% Remove selected from not accumulated
naccSpectra = length(appdata.control.spectra.notaccumulated);
for k=1:naccSpectra
    if appdata.control.spectra.notaccumulated{k} == iSelected
        appdata.control.spectra.notaccumulated(k) = [];
        break;  % !!! above statement manipulates cell array length
    end
end
% Prevent empty cell array
if isempty(appdata.control.spectra.notaccumulated)
    appdata.control.spectra.notaccumulated{1} = [];
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

% Call to internal function refreshing the spectra listboxes and axes
%     => important to do it after refreshing handles and appdata!
if_spectraNotAccumulatedListbox_Refresh(handles.figure1);
if_spectraAccumulatedListbox_Refresh(handles.figure1);

if_axis_Refresh(handles.figure1);



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
if ~isempty(appdata.control.spectra.accumulated)
    appdata.control.spectra.active = appdata.control.spectra.accumulated{...
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


% --- Executes on button press in restoreButton.
function restoreButton_Callback(hObject, eventdata, handles)
% hObject    handle to restoreButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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

if ~isempty(appdata.acc)
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
            % Refresh filename
            appdata.acc.filename = get(handles.filenameEdit,'String');
            % Get appdata from parent window necessary for ACC
            if isfield(handles,'callerFunction') && ...
                    isfield(handles,'callerHandle')
                callerHandles = guidata(handles.callerHandle);
                if isfield(callerHandles,mfilename)
                    % Get appdata of the parent GUI
                    parentAppdata = getappdata(callerHandles.figure1);
                    parentAppdata.data{end+1} = appdata.acc;
                    parentAppdata.control.spectra.visible{end+1} = ...
                        length(parentAppdata.data);
                    parentAppdata.control.spectra.modified{end+1} = ...
                        length(parentAppdata.data);
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
                    trEPR_GUI_main('if_spectraVisibleListbox_Refresh',handles.callerHandle);
                end
            end
        case 'Discard'
    end
end

% Close warning dialogs if still open
if isfield(appdata.handles,'dimensionMismatchWarndlg')
    if ishandle(appdata.handles.dimensionMismatchWarndlg)
        close(appdata.handles.dimensionMismatchWarndlg);
    end
end
if isfield(appdata.handles,'parameterMismatchWarndlg')
    if ishandle(appdata.handles.parameterMismatchWarndlg)
        close(appdata.handles.parameterMismatchWarndlg);
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



% --- Refresh accumulated spectra listbox
function if_spectraAccumulatedListbox_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Extract names of visible Spectra from appdata
accSpectraNames = cell(1);
if isempty(appdata.control.spectra.accumulated{1})
    accSpectraNames = cell(1);
    appdata.control.spectra.active = 0;
    set(handles.spectraAccumulatedListbox,'Enable','Inactive');
    cla(handles.axes1,'reset');
    set(handles.positionInTimePointsEdit,'Enable','Inactive');
    set(handles.positionInTimeValueEdit,'Enable','Inactive');
    set(handles.spectraRemoveButton,'Enable','Off');
else
    set(handles.spectraAccumulatedListbox,'Enable','On');
    set(handles.positionInTimePointsEdit,'Enable','On');
    set(handles.positionInTimeValueEdit,'Enable','On');
    set(handles.spectraRemoveButton,'Enable','On');
    for k=1:length(appdata.control.spectra.accumulated)
        [pathstr, name, ext, versn] = fileparts(...
            appdata.data{...
            appdata.control.spectra.accumulated{k}}.filename...
            );
        accSpectraNames{k} = [name ext];
    end
end

% Fix problem with currently selected item
maxValue = length(accSpectraNames);
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
    appdata.control.spectra.active = appdata.control.spectra.accumulated{...
        get(handles.spectraAccumulatedListbox,'Value')...
        };
end

% Set listbox display
set(handles.spectraAccumulatedListbox,'String',accSpectraNames);

% Set suggestion for filename of accumulated spectra
set(handles.filenameEdit,'String',...
	sprintf('%sacc',commonString(accSpectraNames,1)));

% If there are no visible spectra any more, set appdata, turn off elements
% and return 
if isempty(appdata.control.spectra.active)
    appdata.control.spectra.active = 0;
    set(handles.spectraAccumulatedListbox,'Enable','Inactive');
    cla(handles.axes1,'reset');
    set(handles.positionInTimePointsEdit,'Enable','Off');
    set(handles.positionInTimeValueEdit,'Enable','Off');
    set(handles.spectraScrollSlider,'Enable','Off');
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
    set(handles.spectraAccumulatedListbox,'Enable','On');
    set(handles.positionInTimePointsEdit,'Enable','On');
    set(handles.positionInTimeValueEdit,'Enable','On');
    set(handles.spectraScrollSlider,'Enable','On');
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

if_infoPanels_Refresh(hObject);


% --- Refresh not accumulated spectra listbox
function if_spectraNotAccumulatedListbox_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Extract names of not accumulated spectra from appdata
invSpectraNames = cell(1);
if isempty(appdata.control.spectra.notaccumulated{1})
    naccSpectraNames = cell(1);
    set(handles.spectraAddButton,'Enable','Off');
    set(handles.spectraNotAccumulatedListbox,'Enable','Inactive');
else
    set(handles.spectraAddButton,'Enable','On');
    set(handles.spectraNotAccumulatedListbox,'Enable','On');
    for k=1:length(appdata.control.spectra.notaccumulated)
        [pathstr, name, ext, versn] = fileparts(...
            appdata.data{...
            appdata.control.spectra.notaccumulated{k}}.filename...
            );
        naccSpectraNames{k} = [name ext];
    end
end

% Fix problem with currently selected item
maxValue = length(naccSpectraNames);
selectedValue = get(handles.spectraNotAccumulatedListbox,'Value');
if selectedValue > maxValue
    set(handles.spectraNotAccumulatedListbox,'Value',maxValue);
end

% Set listbox display
set(handles.spectraNotAccumulatedListbox,'String',naccSpectraNames);

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

if_infoPanels_Refresh(hObject);

% --- Refresh info and resize panels
function if_infoPanels_Refresh(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Set Infobox fields
set(handles.infoFieldStepsizeEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.parameters.field.step));
set(handles.infoFieldStartEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values(1)));
set(handles.infoFieldStopEdit,'String',...
    num2str(...
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values(end)));
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
    appdata.data{appdata.control.spectra.active}.axes.yaxis.values(1)));
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

if ~if_checkDimensions(handles.figure1)
    cla(handles.axes1,'reset');
    return
end

if isempty(appdata.control.spectra.accumulated{1})
    cla(handles.axes1,'reset');
    return
end

% If there are less than two spectra to accumulate, reset axes and return
if length(appdata.control.spectra.accumulated) < 2
    cla(handles.axes1,'reset');

    appdata.acc = struct();
    
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
    
    return
end

% Accumulate spectra

if_accumulateSpectra(handles.figure1);
appdata = getappdata(handles.figure1);

% Plot accumulated spectra
[ yDim, xDim ] = size(appdata.acc.data);
xaxis = appdata.acc.axes.xaxis.values;
yaxis = appdata.acc.axes.yaxis.values;
% Convert G -> mT
if strcmp(appdata.acc.axes.yaxis.unit,'G')
    yaxis = yaxis / 10;
end

set(handles.spectraScrollSlider,'Enable','On');
set(handles.spectraScrollSlider,'Min',1);
set(handles.spectraScrollSlider,'Max',xDim);
set(handles.spectraScrollSlider,'SliderStep',[1/xDim, 10/xDim]);

if get(handles.spectraScrollSlider,'Value') < get(handles.spectraScrollSlider,'Min')
    set(handles.spectraScrollSlider,'Value',get(handles.spectraScrollSlider,'Min'));
    set(handles.positionInTimePointsEdit,'String',...
        num2str(floor(get(handles.spectraScrollSlider,'Value')))...
        );
    set(handles.positionInTimeValueEdit,'String',...
        appdata.acc.axes.xaxis.values(...
        floor(get(handles.spectraScrollSlider,'Value'))));
end

plot(...
    handles.axes1,...
    yaxis,...
    appdata.acc.data(...
    :,floor(get(handles.spectraScrollSlider,'Value'))...
    )...
    );
set(...
    handles.axes1,...
    'XLim',...
    [yaxis(1) yaxis(end)]...
    );
set(...
    handles.axes1,...
    'YLim',...
    [...
    min(min(appdata.acc.data))*1.05 ...
    max(max(appdata.acc.data))*1.05 ...                
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


% --- Check dimensions of spectra to be accumulated (axis)
function TF = if_checkDimensions(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% The following parameters have to be checked:
%   - x Dimension (time): 
%     - npts, length, unit
%   - step widths (time, field)
%   - field unit

if isempty(appdata.control.spectra.accumulated{1})
    TF = logical(false);
    return
end

for k = 1 : length(appdata.control.spectra.accumulated)
    % Sum time parameters to compare
    time.npts(k) = length(...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.xaxis.values);
    time.length(k) = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.parameters.transient.length;
    time.unit{k} = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.xaxis.unit;
    time.step(k) = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.xaxis.values(2)-...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.xaxis.values(1);
    % Bug fix for some very weird MATLAB problems with accuracy
    time.step(k) = round(time.step(k)*1e10)/1e10;
    % Sum field parameters to compare
    field.start(k) = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values(1);
    field.stop(k) = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values(end);
    field.step(k) = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.parameters.field.step;
    field.unit{k} = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.unit;
end

warnings = cell(1);

% Check time dimensions
if min(time.npts)~=max(time.npts)
    warnings{end+1} = 'time dimension mismatch';
end
if min(time.length)~=max(time.length)
    warnings{end+1} = 'time profiles with different lengths';
end
if min(time.step)~=max(time.step)
    warnings{end+1} = 'time profiles with different step width';
end
if length(strmatch(time.unit{1},time.unit))~=length(time.unit)
    warnings{end+1} = 'time profiles with different time units';
end
% Check field dimensions
if max(field.start)>min(field.stop)
    warnings{end+1} = 'field axes of some spectra do not overlap';
end
if min(field.step)~=max(field.step)
    warnings{end+1} = 'spectra with different step width';
end
if length(strmatch(field.unit{1},field.unit))~=length(field.unit)
    warnings{end+1} = 'spectra with different field units';
end

if length(warnings) == 1 && isempty(warnings{1})
    TF = logical(true);
    if isfield(appdata.handles,'dimensionMismatchWarndlg')
        close(appdata.handles.dimensionMismatchWarndlg);
        appdata.handles = ...
            rmfield(appdata.handles,'dimensionMismatchWarndlg');
    end
else
    warningText = 'Dimension mismatch occurred:';
    for k = 2:length(warnings)
        warningText = sprintf('%s\n- %s',warningText,warnings{k});
    end
    warningText = sprintf(...
        '%s\n%s\n%s\n%s',...
        warningText,...
        ' ',...
        'Note: The dialog will close automatically',...
        'as soon as you solved the problem.'...
        );
    dimensionMismatchWarndlg = warndlg(...
        warningText,'Dimension Mismatch','replace');
    position = get(dimensionMismatchWarndlg,'Position');
    set(dimensionMismatchWarndlg,'Position',[231 441 position(3) position(4)]);
    appdata.handles = setfield(...
        appdata.handles,...
        'dimensionMismatchWarndlg',...
        dimensionMismatchWarndlg);
    TF = logical(false);
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


% --- Accumulate spectra
function if_accumulateSpectra(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Adjust field axes
for k = 1 : length(appdata.control.spectra.accumulated)
    field.start(k) = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values(1);
    field.stop(k) = ...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values(end);
end
yaxis = [...
    max(field.start) : ...
    appdata.data{appdata.control.spectra.accumulated{1}}.parameters.field.step : ...
    min(field.stop)...
    ];

% Preassign matrix to speed up
acc = zeros(...
    length(yaxis),...
    length(appdata.data{appdata.control.spectra.accumulated{1}}.axes.xaxis.values));
filenames = cell(length(appdata.control.spectra.accumulated));

for k = 1 : length(appdata.control.spectra.accumulated)
    if isfield(appdata.data{appdata.control.spectra.accumulated{k}}.parameters,'recorder')
        scans(k) = appdata.data{appdata.control.spectra.accumulated{k}}.parameters.recorder.averages;
    else
        scans(k) = 1;
    end
    acc = acc + ...
        appdata.data{appdata.control.spectra.accumulated{k}}.data(...
        interp1(...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values,...
        [1:length(...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values)],...
        max(field.start)) : ...
        interp1(...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values,...
        [1:length(...
        appdata.data{appdata.control.spectra.accumulated{k}}.axes.yaxis.values)],...
        min(field.stop)), ...
        :) * scans(k);
    % Extract data necessary for the acc structure
    % NOTE: The "isempty" is necessary due to the fact that MATLAB uses
    % assigning an empty vector, "[]", to remove the element, and thus
    % produces errors in case the element is empty.
    filenames{k} = appdata.data{appdata.control.spectra.accumulated{k}}.filename;
    if isempty(appdata.data{appdata.control.spectra.accumulated{k}}.parameters.bridge.MWfrequency)
        MWfrequencies(k) = 0;
    else
        MWfrequencies(k) = ...
           appdata.data{appdata.control.spectra.accumulated{k}}.parameters.bridge.MWfrequency;
    end
    if isempty(appdata.data{appdata.control.spectra.accumulated{k}}.parameters.bridge.attenuation)
        attenuations(k) = 0;
    else
        attenuations(k) = ...
            appdata.data{appdata.control.spectra.accumulated{k}}.parameters.bridge.attenuation;
    end
    if isempty(appdata.data{appdata.control.spectra.accumulated{k}}.parameters.temperature)
        temperatures(k) = 0;
    else
        temperatures(k) = ...
            appdata.data{appdata.control.spectra.accumulated{k}}.parameters.temperature;
    end
    if isempty(appdata.data{appdata.control.spectra.accumulated{k}}.parameters.laser.wavelength)
        wavelengths(k) = 0;
    else
        wavelengths(k) = ...
            appdata.data{appdata.control.spectra.accumulated{k}}.parameters.laser.wavelength;
    end
    if isempty(appdata.data{appdata.control.spectra.accumulated{k}}.parameters.laser.repetitionRate)
        repetitionRates(k) = 0;
    else
        repetitionRates(k) = ...
            appdata.data{appdata.control.spectra.accumulated{k}}.parameters.laser.repetitionRate;
    end
end

% Check identity of additional parameters to be stored in acc structure
warnings = cell(1);

if min(MWfrequencies)~=max(MWfrequencies)
    warnings{end+1} = sprintf(...
        'different frequencies: \n    %s\n    %s',...
        num2str(MWfrequencies),...
        'mean value will be used.');
    % Average frequencies and cut to fourth digit
    MWfrequency = mean(MWfrequencies);
    MWfrequency = floor(MWfrequency*1e4)/1e4;
    appdata.acc.acc.MWfrequency = MWfrequencies;
elseif MWfrequencies(1) == 0
    MWfrequency = [];
else
    MWfrequency = MWfrequencies(1);
end
if min(attenuations)~=max(attenuations)
    warnings{end+1} = sprintf(...
        'different attenuations: \n    %s',...
        num2str(attenuations));
    attenuation = attenuations(1);
    appdata.acc.acc.attenuation = attenuations;
elseif attenuations(1) == 0
    attenuation = [];
else
    attenuation = attenuations(1);
end
if min(temperatures)~=max(temperatures)
    warnings{end+1} = sprintf(...
        'different temperatures: \n    %s',...
        num2str(temperatures));
    temperature = temperatures(1);
    appdata.acc.acc.temperature = temperatures;
elseif temperatures(1) == 0
    temperature = [];
else
    temperature = temperatures(1);
end
if min(wavelengths)~=max(wavelengths)
    warnings{end+1} = sprintf(...
        'different laser wavelengths: \n    %s',...
        num2str(wavelengths));
    wavelength = wavelengths(1);
    appdata.acc.acc.wavelength = wavelengths;
elseif wavelengths(1) == 0
    wavelength = [];
else
    wavelength = wavelengths(1);
end
if min(repetitionRates)~=max(repetitionRates)
    warnings{end+1} = sprintf(...
        'different laser repetition rates: \n    %s',...
        num2str(repetitionRates));
    repetitionRate = repetitionRates(1);
    appdata.acc.acc.repetitionRate = repetitionRates;
elseif repetitionRates(1) == 0
    repetitionRate = [];
else
    repetitionRate = repetitionRates(1);
end

if length(warnings) == 1 && isempty(warnings{1})
    if isfield(appdata.handles,'parameterMismatchWarndlg')
        close(appdata.handles.parameterMismatchWarndlg);
    end
else
    warningText = 'Parameter mismatch occurred:';
    for k = 2:length(warnings)
        warningText = sprintf('%s\n- %s',warningText,warnings{k});
    end
    parameterMismatchWarndlg = warndlg(...
        warningText,'Parameter Mismatch','replace');
    set(parameterMismatchWarndlg,'Position',[231 441 263 89.2]);
    appdata.handles = setfield(...
        appdata.handles,...
        'parameterMismatchWarndlg',...
        parameterMismatchWarndlg);
end

% "Normalize" accumulated spectra
acc = acc / sum(scans);

% Assign accumulated data to structure of ACC GUI
appdata.acc.header = cell(1);
appdata.acc.parameters = struct(...
    'field', struct(...
    'start', max(field.start),...
    'stop', min(field.stop),...
    'step', appdata.data{appdata.control.spectra.accumulated{1}}.parameters.field.step ...
    ),...
    'transient', struct(...
    'points',appdata.data{appdata.control.spectra.accumulated{1}}.parameters.transient.points,...
    'triggerPosition',appdata.data{appdata.control.spectra.accumulated{1}}.parameters.transient.triggerPosition,...
    'length',appdata.data{appdata.control.spectra.accumulated{1}}.parameters.transient.length...
    ),...
    'bridge', struct(...
    'MWfrequency',MWfrequency,...
    'attenuation',attenuation ...
    ),...
    'temperature',temperature,...
    'laser', struct(...
    'wavelength',wavelength,...
    'repetitionRate',repetitionRate ...
    )...
    );
appdata.acc.data = acc;
appdata.acc.axes = struct(...
    'xaxis',struct(...
    'values',appdata.data{appdata.control.spectra.accumulated{1}}.axes.xaxis.values,...
    'measure',appdata.data{appdata.control.spectra.accumulated{1}}.axes.xaxis.measure,...
    'unit',appdata.data{appdata.control.spectra.accumulated{1}}.axes.xaxis.unit...
    ),...
    'yaxis',struct(...
    'values',yaxis,...
    'measure',appdata.data{appdata.control.spectra.accumulated{1}}.axes.yaxis.measure,...
    'unit',appdata.data{appdata.control.spectra.accumulated{1}}.axes.yaxis.unit...
    )...
    );
appdata.acc.filename = get(handles.filenameEdit,'String');
appdata.acc.Db0 = 0;
appdata.acc.Dt = 0;
appdata.acc.Dy = 0;
appdata.acc.Sx = 1;
appdata.acc.Sy = 1;
appdata.acc.t = floor(get(handles.spectraScrollSlider,'Value'));
if appdata.acc.t == 0
    appdata.acc.t = 1;
end
appdata.acc.b0 = 1;
appdata.acc.acc = struct(...
    'filenames',filenames...
    );

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
