function varargout = trEPR_GUI_export(varargin)
% TREPR_GUI_EXPORT M-file for trEPR_GUI_export.fig
%      TREPR_GUI_EXPORT, by itself, creates a new TREPR_GUI_EXPORT or raises the existing
%      singleton*.
%
%      H = TREPR_GUI_EXPORT returns the handle to a new TREPR_GUI_EXPORT or the handle to
%      the existing singleton*.
%
%      TREPR_GUI_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREPR_GUI_EXPORT.M with the given input arguments.
%
%      TREPR_GUI_EXPORT('Property','Value',...) creates a new TREPR_GUI_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trEPR_GUI_export_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trEPR_GUI_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_export

% Last Modified by GUIDE v2.5 04-Jun-2010 18:27:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trEPR_GUI_export_OpeningFcn, ...
                   'gui_OutputFcn',  @trEPR_GUI_export_OutputFcn, ...
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


% --- Executes just before trEPR_GUI_export is made visible.
function trEPR_GUI_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trEPR_GUI_export (see VARARGIN)

% Choose default command line output for trEPR_GUI_export
handles.output = hObject;

% set window title
set(hObject,'Name','trEPR toolbox : export plot');

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

        for k = 1 : length(control.spectra.visible)
            % Assign filenames (basename) to control.filenames cell array
            [path name ext] = fileparts(...
                data{control.spectra.visible{k}}.filename);
            filenames{k} = name;
            clear path name ext;
        end

        % Set suggestion for filename of accumulated spectra
        set(handles.fileNameEdit,'String',...
            sprintf('%s',commonString(filenames,1)));
    end
    guidata(handles.callerHandle,callerHandles);
end

% Create invisible figure (with handle)
handles.invFH = figure('Visible','Off');
handles.invAH = gca;

% Update handles structure
guidata(hObject, handles);

if_plot(hObject);

% UIWAIT makes trEPR_GUI_export wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trEPR_GUI_export_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --- Executes on button press in fileSelectorPushbutton.
function fileSelectorPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to fileSelectorPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileName,PathName,FilterIndex] = uiputfile(...
    '',...
    'Select file basename to save figure(s) to');
if isequal(FileName,0) || isequal(PathName,0)
else
    set(handles.fileNameEdit,'String',FileName);
end

% --- Executes on button press in fileFormatEPSCheckbox.
function fileFormatEPSCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileFormatEPSCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fileFormatEPSCheckbox


% --- Executes on button press in fileFormatPDFCheckbox.
function fileFormatPDFCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileFormatPDFCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fileFormatPDFCheckbox


% --- Executes on button press in fileFormatFIGCheckbox.
function fileFormatFIGCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileFormatFIGCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fileFormatFIGCheckbox


% --- Executes on button press in fileFormatJPGCheckbox.
function fileFormatJPGCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to fileFormatJPGCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fileFormatJPGCheckbox


% --- Executes on button press in exportPushbutton.
function exportPushbutton_Callback(hObject, eventdata, handles)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

if get(handles.fileFormatPDFCheckbox,'Value')
    sizes = get(handles.sizePopupmenu,'String');
    switch sizes{get(handles.sizePopupmenu,'Value')}
        case 'LaTeX full width'
            saveParam.outputFormat = 'LaTeXfullWidth';
        case 'LaTeX full width small height'
            saveParam.outputFormat = 'LaTeXfullWidthSmallHeight';
        case 'LaTeX half width'
            saveParam.outputFormat = 'LaTeXhalfWidth';
        case 'LaTeX half width small height'
            saveParam.outputFormat = 'LaTeXhalfWidthSmallHeight';
        case 'LaTeX full page'
            saveParam.outputFormat = 'LaTeXfullPage';
        case 'LaTeX Beamer Slide'
            saveParam.outputFormat = 'LaTeXbeamerSlide';
    end
    save_figure(...
        get(handles.fileNameEdit,'String'),...
        saveParam,...
        handles.invFH);
end


h = msgbox(...
    sprintf(...
    'The currently displayed spectra have been exported to the file\n%s',...
    get(handles.fileNameEdit,'String')...
    ),...
    'Exported currently displayed spectra');

closeGUI;


% --- Executes on button press in abortPushbutton.
function abortPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to abortPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closeGUI(hObject, eventdata, handles);


% --- Executes on selection change in sizePopupmenu.
function sizePopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to sizePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sizePopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sizePopupmenu


% --- Executes during object creation, after setting all properties.
function sizePopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sizePopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in modificationsForAiCheckbox.
function modificationsForAiCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to modificationsForAiCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of modificationsForAiCheckbox


% --- Executes on button press in bwCheckbox.
function bwCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to bwCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bwCheckbox


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7



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

close(handles.invFH);

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


% --- Executes on button press in optionsHorizontalLineCheckbox.
function optionsHorizontalLineCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to optionsHorizontalLineCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optionsHorizontalLineCheckbox


% --- Executes on button press in optionsBoxCheckbox.
function optionsBoxCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to optionsBoxCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optionsBoxCheckbox



% --- Plot spectra
function if_plot(hObject)

% Get handles and appdata of the current GUI
handles = guidata(hObject);
appdata = getappdata(handles.figure1);

% Get current display type
currentDisplayType = appdata.control.axis.displayType;

% Plot visible spectra
data = appdata.data{appdata.control.spectra.active}.data;
[ yDim, xDim ] = size(data);
xaxis = appdata.data{appdata.control.spectra.active}.axes.xaxis.values;
yaxis = appdata.data{appdata.control.spectra.active}.axes.yaxis.values;

switch currentDisplayType
    case '2D plot'
        % Get currently active spectrum
        
        % Plot with imagesc (in this case, 2D plot, only active one...)
        set(handles.invAH,'XTick',[],'YTick',[]);     % default if no plot

        imagesc(...
            appdata.data{appdata.control.spectra.active}.axes.xaxis.values,...
            appdata.data{appdata.control.spectra.active}.axes.yaxis.values,...
            appdata.data{appdata.control.spectra.active}.data,...
            'hittest','off'...
            );
        set(handles.invAH,'YDir','normal');
        set(...
            handles.invAH,...
            'XLim',...
            [appdata.control.axis.limits.x.min, ...
            appdata.control.axis.limits.x.max]...
            );
        set(...
            handles.invAH,...
            'YLim',...
            [appdata.control.axis.limits.y.min, ...
            appdata.control.axis.limits.y.max]...
            );

        xlabel(handles.invAH,sprintf('{\\it %s} / %s',...
            appdata.control.axis.labels.x.measure,...
            appdata.control.axis.labels.x.unit));
        ylabel(handles.invAH,sprintf('{\\it %s} / %s',...
            appdata.control.axis.labels.y.measure,...
            appdata.control.axis.labels.y.unit));

    case 'B0 spectra'        
        % Reset current axis
        cla(handles.invAH,'reset');
        hold on;
        for k = 1 : length(appdata.control.spectra.visible)
            Db0 = appdata.data{appdata.control.spectra.visible{k}}.Db0;
            Sb0 = appdata.data{appdata.control.spectra.visible{k}}.Sb0;
            plot(...
                handles.invAH,...
                ((yaxis-(max(yaxis)-((max(yaxis)-min(yaxis))/2)))*Sb0)+...
                (max(yaxis)-((max(yaxis)-min(yaxis))/2)) + Db0,...
                appdata.data{appdata.control.spectra.visible{k}}.data(...
                :,floor(appdata.data{appdata.control.spectra.visible{k}}.t)...
                )*...
                appdata.data{appdata.control.spectra.visible{k}}.Sy+...
                appdata.data{appdata.control.spectra.visible{k}}.Dy,...
                'Color',appdata.data{appdata.control.spectra.visible{k}}.line.color,...
                'LineStyle',appdata.data{appdata.control.spectra.visible{k}}.line.style,...
                'Marker',appdata.data{appdata.control.spectra.visible{k}}.line.marker,...
                'LineWidth',appdata.data{appdata.control.spectra.visible{k}}.line.width...
                );
        end
        hold off;
        set(...
            handles.invAH,...
            'XLim',...
            [appdata.control.axis.limits.y.min, ...
            appdata.control.axis.limits.y.max]...
            );
        set(...
            handles.invAH,...
            'YLim',...
            [appdata.control.axis.limits.z.min, ...
            appdata.control.axis.limits.z.max]...
            );
        
        xlabel(handles.invAH,sprintf('{\\it %s} / %s',...
            appdata.control.axis.labels.y.measure,...
            appdata.control.axis.labels.y.unit));
        ylabel(handles.invAH,sprintf('{\\it %s} / %s',...
            appdata.control.axis.labels.z.measure,...
            appdata.control.axis.labels.z.unit));
        
        % Add horizontal line at position 0 in upper axis
        if appdata.control.axis.grid.zero
            line([appdata.control.axis.limits.y.min, ...
                appdata.control.axis.limits.y.max],[0 0],...
                'Color',[0.75 0.75 0.75],...
                'LineWidth',1,...
                'LineStyle','--');
        end

    case 'transients'
        set(handles.invAH,'XTick',[],'YTick',[]);     % default if no plot        
        % Reset current axis
        cla(handles.invAH,'reset');
        hold on;
        for k = 1 : length(appdata.control.spectra.visible)
            % Set plot style of currently active spectrum
            xaxis = appdata.data{...
                appdata.control.spectra.visible{k}}.axes.xaxis.values;
            Dt = appdata.data{appdata.control.spectra.visible{k}}.Dt;
            St = appdata.data{appdata.control.spectra.visible{k}}.St;
            plot(...
                handles.invAH,...
                ((xaxis-(max(xaxis)-((max(xaxis)-min(xaxis))/2)))*St)+...
                (max(xaxis)-((max(xaxis)-min(xaxis))/2)) + Dt,...
                appdata.data{appdata.control.spectra.visible{k}}.data(...
                floor(appdata.data{appdata.control.spectra.visible{k}}.b0),:...
                )*...
                appdata.data{appdata.control.spectra.visible{k}}.Sy+...
                appdata.data{appdata.control.spectra.visible{k}}.Dy,...
                'Color',appdata.data{appdata.control.spectra.visible{k}}.line.color,...
                'LineStyle',appdata.data{appdata.control.spectra.visible{k}}.line.style,...
                'Marker',appdata.data{appdata.control.spectra.visible{k}}.line.marker,...
                'LineWidth',appdata.data{appdata.control.spectra.visible{k}}.line.width...
                );
        end
        hold off;
        set(...
            handles.invAH,...
            'XLim',...
            [appdata.control.axis.limits.x.min, ...
            appdata.control.axis.limits.x.max]...
            );
        set(...
            handles.invAH,...
            'YLim',...
            [appdata.control.axis.limits.z.min, ...
            appdata.control.axis.limits.z.max]...
            );

        xlabel(handles.invAH,sprintf('{\\it %s} / %s',...
            appdata.control.axis.labels.x.measure,...
            appdata.control.axis.labels.x.unit));
        ylabel(handles.invAH,sprintf('{\\it %s} / %s',...
            appdata.control.axis.labels.z.measure,...
            appdata.control.axis.labels.z.unit));

        % Add horizontal line at position 0 in upper axis
        if appdata.control.axis.grid.zero
            line([appdata.control.axis.limits.x.min, ...
            	appdata.control.axis.limits.x.max],[0 0],...
                'Color',[0.75 0.75 0.75],...
                'LineWidth',1,...
                'LineStyle','--');
        end
end

% Display grid
switch appdata.control.axis.grid.x
    case 'major'
        set(handles.invAH,'XGrid','on');
    case 'minor'
        set(handles.invAH,'XGrid','on');
        set(handles.invAH,'XMinorGrid','on');
    otherwise
        set(handles.invAH,'XGrid','off');
        set(handles.invAH,'XMinorGrid','off');
end
switch appdata.control.axis.grid.y
    case 'major'
        set(handles.invAH,'YGrid','on');
    case 'minor'
        set(handles.invAH,'YGrid','on');
        set(handles.invAH,'YMinorGrid','on');
    otherwise
        set(handles.invAH,'YGrid','off');
        set(handles.invAH,'YMinorGrid','off');
end

% Display legend
switch appdata.control.axis.legend.location
    case 'off'
        legend(handles.invAH,'off');
    otherwise
        legendStrings = cell(1);
        for k=1:length(appdata.control.spectra.visible)
            legendStrings{k} = ...
                strrep(...
                appdata.data{appdata.control.spectra.visible{k}}.label,...
                '_',...
                '\_');
        end
        legend(...
            handles.invAH,...
            legendStrings,...
            'Location',appdata.control.axis.legend.location);
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


% --- Executes on button press in optionsYAxisLabelsCheckbox.
function optionsYAxisLabelsCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to optionsYAxisLabelsCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optionsYAxisLabelsCheckbox


