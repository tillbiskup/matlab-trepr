function varargout = trEPR_GUI_filedisplay(varargin)
% TREPR_GUI_FILEDISPLAY M-file for trEPR_GUI_filedisplay.fig
%      TREPR_GUI_FILEDISPLAY, by itself, creates a new TREPR_GUI_FILEDISPLAY or raises the existing
%      singleton*.
%
%      H = TREPR_GUI_FILEDISPLAY returns the handle to a new TREPR_GUI_FILEDISPLAY or the handle to
%      the existing singleton*.
%
%      TREPR_GUI_FILEDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TREPR_GUI_FILEDISPLAY.M with the given input arguments.
%
%      TREPR_GUI_FILEDISPLAY('Property','Value',...) creates a new TREPR_GUI_FILEDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trEPR_GUI_filedisplay_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trEPR_GUI_filedisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trEPR_GUI_filedisplay

% Last Modified by GUIDE v2.5 19-Jun-2010 11:54:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trEPR_GUI_filedisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @trEPR_GUI_filedisplay_OutputFcn, ...
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


% --- Executes just before trEPR_GUI_filedisplay is made visible.
function trEPR_GUI_filedisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trEPR_GUI_filedisplay (see VARARGIN)

% Choose default command line output for trEPR_GUI_filedisplay
handles.output = hObject;

% set window title
set(hObject,'Name','trEPR toolbox : File display');

% Add command line arguments to the handles structure assuming that these
% are property value pairs. Used to get callerFunction and callerHandle.
if iscell(varargin)
    for k=2 : 2 : length(varargin)
        handles = setfield(handles,varargin{k-1},varargin{k});
    end
end

% Load contents of file
if isfield(handles,'File')
    set(handles.fileContentsEdit,'String',...
        textFileRead(handles.File,'LineNumbers',logical(true)));
    [path name ext] = fileparts(handles.File);
    set(handles.fileNameEdit,'String',[name ext]);
    set(handles.filePathEdit,'String',path);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trEPR_GUI_filedisplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trEPR_GUI_filedisplay_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function fileContentsEdit_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of fileContentsEdit as text
%        str2double(get(hObject,'String')) returns contents of fileContentsEdit as a double


% --- Executes during object creation, after setting all properties.
function fileContentsEdit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closeButton.
function closeButton_Callback(hObject, eventdata, handles)
close;


% --- Executes on button press in reloadButton.
function reloadButton_Callback(hObject, eventdata, handles)
if isfield(handles,'File')
    set(handles.fileContentsEdit,'String',...
        textFileRead(handles.File,'LineNumbers',logical(true)));
    [path name ext] = fileparts(handles.File);
    set(handles.fileNameEdit,'String',[name ext]);
    set(handles.filePathEdit,'String',path);
end


function fileNameEdit_Callback(hObject, eventdata, handles)
[path name ext] = fileparts(handles.File);
set(handles.fileNameEdit,'String',[name ext]);


% --- Executes during object creation, after setting all properties.
function fileNameEdit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function filePathEdit_Callback(hObject, eventdata, handles)
[path name ext] = fileparts(handles.File);
set(handles.filePathEdit,'String',path);


% --- Executes during object creation, after setting all properties.
function filePathEdit_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


