function handle = guiAnalysisPanel(parentHandle,position)
% GUIHELPPANEL Add a panel displaying some help elements to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%       TODO: Add guidata and appdata to list of arguments
%
%       Returns the handle of the added panel.

% (Leave a blank line following the help.)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','analysis_panel',...
    'parent',parentHandle,...
    'Title','Data analysis',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'Units','pixels','Position',position);

% Create the "Help" panel
handle_size = get(handle,'Position');
uicontrol('Tag','analysis_panel_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Diverse analysis tools such as data fitting, simulations, deconvolution (SVD), ...'}...
    );

handle_p1 = uipanel('Tag','analysis_panel_xxx_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-210 handle_size(3)-20 140],...
    'Title','First point',...
    'Visible','off'...
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set setslider checkbox
% Get appdata of main window
mainWindow = findobj('Tag','trepr_gui_mainwindow');
ad = getappdata(mainWindow);

% Get guihandles of main window
gh = guihandles(mainWindow);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function analysis_setslider_checkbox_Callback(source,~)
    % Get appdata of main window
    mainWindow = findobj('Tag','trepr_gui_mainwindow');
    ad = getappdata(mainWindow);

    ad.control.help.setslider = get(source,'Value');
    
    % Update appdata of main window
    setappdata(mainWindow,'control',ad.control);  
    
    % Update slider panel
    update_sliderPanel();

    %Update main axis
    update_mainAxis();    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end