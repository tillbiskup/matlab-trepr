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

% Last Modified by GUIDE v2.5 15-Apr-2010 00:15:35

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
function spectraSlider_Callback(hObject, eventdata, handles)
% hObject    handle to spectraSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function spectraSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectraSlider (see GCBO)
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


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function positionInTimeEdit_Callback(hObject, eventdata, handles)
% hObject    handle to positionInTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of positionInTimeEdit as text
%        str2double(get(hObject,'String')) returns contents of positionInTimeEdit as a double


% --- Executes during object creation, after setting all properties.
function positionInTimeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positionInTimeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in correctPushbutton.
function correctPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to correctPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in resetPushbutton.
function resetPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to resetPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in prevPushbutton.
function prevPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to prevPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in nextPushbutton.
function nextPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in optionsPushbutton.
function optionsPushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to optionsPushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trEPR_GUI_BC_options;

% --- Executes on button press in closePushbutton.
function closePushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to closePushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

closeGUI(hObject, eventdata, handles);


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


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
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


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in additionalFitPoint2Checkbox.
function additionalFitPoint2Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to additionalFitPoint2Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of additionalFitPoint2Checkbox


