function varargout = trEPRgui_bugreportwindow(varargin)
% TREPRGUI Brief description of GUI.
%          Comments displayed at the command line in response 
%          to the help command. 

% (c) 2011-12, Till Biskup
% 2012-06-26

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Construct the components
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check whether we have been called with parameter and whether that has the
% right format
if nargin && isa(varargin{1},'MException')
    [status,report] = trEPRbugReportHelper(varargin{1});
    if status 
        trEPRmsg('Hm... Something went wrong generating the bug report.',...
            'error'); 
        return;
    end
else
    trEPRmsg('Obviously, we''re called with none or the wrong parameter.',...
        'error');
    return;
end

% Make GUI effectively a singleton
singleton = trEPRguiGetWindowHandle(mfilename);
if (singleton)
    figure(singleton);
    return;
end

% Set some basic variables
bugZillaUrl = 'https://r3c.de/bugs/till/';
bugZillaBugReportUrl = ...
    'https://r3c.de/bugs/till/enter_bug.cgi?product=trEPR%20toolbox';

% Try to get main GUI position
mainGUIHandle = trEPRguiGetWindowHandle();
if ishandle(mainGUIHandle)
    mainGUIPosition = get(mainGUIHandle,'Position');
    guiPosition = [mainGUIPosition(1)+30,mainGUIPosition(2)+110,750,530];
else
    guiPosition = [50,150,750,530];
end

%  Construct the components
hMainFigure = figure('Tag',mfilename,...
    'Visible','off',...
    'Name','trEPR GUI : Bug Report Window',...
    'Units','Pixels',...
    'Position',guiPosition,...
    'Resize','off',...
    'NumberTitle','off', ...
    'Color',[1 .8 .8],...
    'Menu','none','Toolbar','none');

defaultBackground = get(hMainFigure,'Color');

uicontrol('Tag','bugreportwindow_headline',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[20 guiPosition(4)-50 guiPosition(3)-40 30],...
    'FontWeight','bold',...
    'Enable','on',...
    'String','Bug report helper');

description = uicontrol('Tag','bugreportdescription_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[20 guiPosition(4)-260 guiPosition(3)-185 200],...
    'Enable','on',...
    'String','');

% Set icon (jLabel)
[path,~,~] = fileparts(mfilename('fullpath'));
icon = javax.swing.ImageIcon(fullfile(path,'bug.png'));
jLabel = javax.swing.JLabel('');
jLabel.setIcon(icon);
bgcolor = num2cell(get(hMainFigure, 'Color'));
jLabel.setBackground(java.awt.Color(bgcolor{:}));
javacomponent(jLabel,[guiPosition(3)-125-20 guiPosition(4)-89-60 125 89],hMainFigure);

% Create the report window
textdisplay = uicontrol('Tag','bugreport_edit',...
    'Style','edit',...
    'Parent',hMainFigure,...
    'BackgroundColor',[1 1 1],...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[20 70 guiPosition(3)-40 guiPosition(4)-300],...
    'Enable','on',...
    'Max',2,'Min',0,...
    'FontName','Monospaced',...
    'String','');

uicontrol('Tag','bugreportapologies_text',...
    'Style','text',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',14,...
    'Units','Pixels',...
    'HorizontalAlignment','Left',...
    'Position',[20 20 guiPosition(3)-40 25],...
    'FontWeight','bold',...
    'Enable','on',...
    'String','"Be seeing you..."');

uicontrol('Tag','bugreportwindow_refresh_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiPosition(3)-330 20 70 30],...
    'String','Reload',...
    'TooltipString','Reload bug report display',...
    'Callback',{@button_Callback,'refresh'}...
    );

uicontrol('Tag','bugreportwindow_bugzilla_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiPosition(3)-230 20 70 30],...
    'String','Report',...
    'TooltipString','Report bug via BugZilla (open BugZilla URL in system''s web browser)',...
    'Callback',{@button_Callback,'bugreporter'}...
    );

uicontrol('Tag','bugreportwindow_save_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiPosition(3)-160 20 70 30],...
    'String','Save',...
    'TooltipString','Save bug report to file (e.g., to attach to BugZilla bug report)',...
    'Callback',{@button_Callback,'save'}...
    );

uicontrol('Tag','bugreportwindow_close_pushbutton',...
    'Style','pushbutton',...
    'Parent',hMainFigure,...
    'BackgroundColor',defaultBackground,...
    'FontUnit','Pixel','Fontsize',12,...
    'Units','Pixels',...
    'Position',[guiPosition(3)-90 20 70 30],...
    'String','Close',...
    'TooltipString','Close bug report window',...
    'Callback',{@button_Callback,'close'}...
    );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialization tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Store handles in guidata
guidata(hMainFigure,guihandles);

% Make the GUI visible.
set(hMainFigure,'Visible','on');

% Set description text
descriptionText{1} = [...
    'It looks like an error occurred. Details are shown below. '...
    'You should be able to continue and at least save your work. '...
    'Nevertheless it might be wise to restart the GUI - and probably '...
    'Matlab(tm) - afterwards.'
    ];
descriptionText{end+1} = ' ';
descriptionText{end+1} = [...
    'Please report this bug to the toolbox author using the information '...
    'displayed below. Pressing the "Report" button below will open the '...
    'BugZilla URL in your system''s web browser. Attach the report '...
    'displayed below by saving it to a text file first using the '...
    '"Save" button.'
    ];
descriptionText{end+1} = ' ';
descriptionText{end+1} = [...
    'Thank you very much indeed for your cooperation and your patience. '...
    'I''ll try to fix the bug as soon as my time allows.'
    ];
set(description,'String',descriptionText);

% Set bugreport text
set(textdisplay,'String',report);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function button_Callback(varargin)
    if nargin == 3
        task = varargin{3};
    else
        return;
    end
    
    switch lower(task)
        case 'refresh'
            set(textdisplay,'String',report);
        case 'bugreporter'
            startBrowser(bugZillaBugReportUrl);
        case 'save'
            % Set default filename
            defaultFileName = sprintf('trepr-bug-%s.txt',datestr(now,30));
            % Open file selection dialogue
            [FileName,PathName] = uiputfile(...
                '*.txt','Select file to save the bug report to',...
                defaultFileName);
            % Check whether user hit "Cancel" and if so, return
            if isequal(FileName,0) || isequal(PathName,0)
                return;
            end
            % Save to text file
            fid = fopen(fullfile(PathName,FileName),'w+');
            if (fid == -1)
                msgText = [...
                    'Error while trying to save bug report. '...
                    'Cannot write to file '...
                    fullfile(PathName,FileName)...
                    ];
                msgbox(msgText,'Cannot write file','error'); 
                return;
            end
            for k=1:length(report)
                fprintf(fid,'%s\n',report{k});
            end
            fclose(fid);
        case 'close'
            try
                delete(hMainFigure);
            catch
            end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Utility functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function startBrowser(url)
    if any(strfind(platform,'Windows'))
        dos(['start ' url]);
    else
        web(url,'-browser');
    end
end

end
