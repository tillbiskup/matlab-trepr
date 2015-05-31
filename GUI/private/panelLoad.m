function handle = panelLoad(parentHandle,position)
% PANELLOAD Add a panel for loading files to a gui
%       Should only be called from within a GUI defining function.
%
%       Arguments: parent Handle and position vector.
%
%       Returns the handle of the added panel.

% Copyright (c) 2011-15, Till Biskup
% 2015-05-31

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultBackground = get(parentHandle,'Color');

handle = uipanel('Tag','load_panel',...
    'parent',parentHandle,...
    'Title','Load data',...
    'FontWeight','bold',...
    'BackgroundColor',defaultBackground,...
    'Visible','off',...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','pixels','Position',position);

% Create the "Load data" panel
handle_size = get(handle,'Position');
uicontrol('Tag','load_description',...
    'Style','text',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'FontUnit','Pixel','Fontsize',12,...
    'FontAngle','oblique',...
    'Position',[10 handle_size(4)-60 handle_size(3)-20 30],...
    'String',{'Load data from file(s)' 'Import data from diverse sources'}...
    );

p1 = uipanel('Tag','load_filetype_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-120 handle_size(3)-20 50],...
    'Title','File type'...
    );
hFiletypesMenu = uicontrol('Tag','load_filetype_popupmenu',...
    'Style','popupmenu',...
    'Parent',p1,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String','Automatic',...
    'Callback', {@popupmenu_Callback}...
    );

p2 = uipanel('Tag','load_files_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-220 handle_size(3)-20 90],...
    'FontUnit','Pixel','Fontsize',12,...
    'Title','Files to load'...
    );
uicontrol('Tag','load_combine_checkbox',...
    'Style','checkbox',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 50 handle_size(3)-40 20],...
    'String',' Combine multiple files',...
    'TooltipString',sprintf('%s\n%s\n%s',...
    'If a dataset consists of several files',...
    '(e.g., time traces), combine them.','Use carefully.'),...
    'Callback', {@checkbox_Callback,'combine'} ...
    );
uicontrol('Tag','load_loadDir_checkbox',...
    'Style','checkbox',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 30 handle_size(3)-40 20],...
    'String',' Load whole directory',...
    'TooltipString',sprintf('%s\n%s','Load all readable files of a directory.',...
    'Use carefully.'),...
    'Callback', {@checkbox_Callback,'loadDir'} ...
    );
uicontrol('Tag','load_loadInfoFile_checkbox',...
    'Style','checkbox',...
    'Parent',p2,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'TooltipString','Try to find, load and apply info file',...
    'String',' Load info file',...
    'Callback', {@checkbox_Callback,'loadInfoFile'} ...
    );

p3 = uipanel('Tag','load_preprocessing_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-300 handle_size(3)-20 70],...
    'Title','Preprocessing on load'...
    );
uicontrol('Tag','load_POC_checkbox',...
    'Style','checkbox',...
    'Parent',p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 30 handle_size(3)-40 20],...
    'String',' Offset compensation',...
    'TooltipString',sprintf('%s\n%s','Perform offset compensation',...
    '(average of pretrigger offset for each time trace set to zero)'),...
    'Callback', {@checkbox_Callback,'POC'} ...
    );
uicontrol('Tag','load_BGC_checkbox',...
    'Style','checkbox',...
    'Parent',p3,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'String',' Background subtraction',...
    'TooltipString',sprintf('%s\n%s','Perform background subtraction',...
    '(subtract average of the first n time traces from each time trace)'),...
    'Callback', {@checkbox_Callback,'BGC'} ...
    );

p4 = uipanel('Tag','load_display_panel',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 handle_size(4)-400 handle_size(3)-20 90],...
    'Title','Display options'...
    );
uicontrol('Tag','load_determineAxisLabels_checkbox',...
    'Style','checkbox',...
    'Parent',p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 50 handle_size(3)-40 20],...
    'TooltipString','Try to determine axis labels from (last loaded) file',...
    'String',' Determine axis labels',...
    'Callback', {@checkbox_Callback,'determineAxisLabels'} ...
    );
uicontrol('Tag','load_visibleUponLoad_checkbox',...
    'Style','checkbox',...
    'Parent',p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 30 handle_size(3)-40 20],...
    'TooltipString','Make dataset immediately visible after loading',...
    'String',' Visible upon load',...
    'Callback', {@checkbox_Callback,'visibleUponLoad'} ...
    );
uicontrol('Tag','load_convertUnits_checkbox',...
    'Style','checkbox',...
    'Parent',p4,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[10 10 handle_size(3)-40 20],...
    'TooltipString','Convert units according to configuration',...
    'String',' Convert units',...
    'Callback', {@checkbox_Callback,'convertUnits'} ...
    );

uicontrol('Tag','load_load_pushbutton',...
    'Style','pushbutton',...
    'Parent',handle,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[handle_size(3)-70 handle_size(4)-470 60 40],...
    'String','Load',...
    'TooltipString',['<html>Open the file selection dialogue<br>',...
    'Key: <tt>Ctrl + o</tt>'],...
    'Callback', {@pushbutton_Callback}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mainWindow = trEPRguiGetWindowHandle;
ad = getappdata(mainWindow);

% Load fileTypes config file
fileTypes = trEPRguiConfigLoad('trEPRgui_load_fileTypes');
if ~isempty(fileTypes)
    fileTypesStruct = ad.control.panels.load.fileTypes(1);
    types = fieldnames(fileTypes);
    for type = 1:length(types)
        try
            ad.control.panels.load.fileTypes(end+1) = ...
                commonStructCopy(fileTypesStruct,fileTypes.(types{type}));
            fields = fieldnames(ad.control.panels.load.fileTypes);
            for field = 1:length(fields)
                if isscalar(ad.control.panels.load.fileTypes(end).(fields{field}))
                    ad.control.panels.load.fileTypes(end).(fields{field}) = ...
                        logical(ad.control.panels.load.fileTypes(end).(fields{field}));
                end
            end
        catch exception
            trEPRmsg(getReport(exception,'extended','hyperlinks','off'),...
                'warn');
        end
    end
    setappdata(mainWindow,'control',ad.control);
    update_loadPanel();
end

% Set fileTypes popupmenu
fileTypesCell = struct2cell(ad.control.panels.load.fileTypes);
set(hFiletypesMenu,'String',fileTypesCell(1,1,:));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function popupmenu_Callback(source,~)
try
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    ad.control.panels.load.fileType = get(source,'Value');
    setappdata(mainWindow,'control',ad.control);
    update_loadPanel();
catch exception
    trEPRexceptionHandling(exception)
end
end

function checkbox_Callback(source,~,action)
try
    mainWindow = trEPRguiGetWindowHandle;
    ad = getappdata(mainWindow);
    ad.control.panels.load.fileTypes(ad.control.panels.load.fileType).(...
        action) = get(source,'Value');
    setappdata(mainWindow,'control',ad.control);
    update_loadPanel();
catch exception
    trEPRexceptionHandling(exception)
end
end

function pushbutton_Callback(~,~)
try
    cmdLoad(trEPRguiGetWindowHandle);
catch exception
    trEPRexceptionHandling(exception)
end
end
