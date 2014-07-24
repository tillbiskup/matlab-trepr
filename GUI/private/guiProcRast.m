function guiProcRast(varargin)
% GUIPROCRAST An very important internal GUI function with quite telling
% name.
%
% Usage
%   guiProcRast()
%   guiProcRast(value)
%
%   value - string
%           For valid values you need to dig a bit into the source code.
%
% PLEASE NOTE: This function is provided without any guarantee to work at
%              all. It makes use of some things that might break quite
%              easily in the future. Don't blame the author... ;-)

% Copyright (c) 2014, Till Biskup
% 2014-07-24

if ~nargin && ~ischar(varargin{1})
    return;
end

switch lower(varargin{1})
    case char([100 105 108 98 101 114 116])
        trEPRbusyWindow('start',['Your wish shall be granted...<br>'...
            '(retrieving necessary data).']);
        try
            [a,b] = getSomething;
        catch  %#ok<CTCH>
        end
        trEPRbusyWindow('delete');
        if exist('a','var')
            showSomething(a,b);
        end
    case char([120 107 99 100])
        trEPRbusyWindow('start',['Your wish is my command...<br>'...
            '(retrieving necessary data)']);
        try
            [c,d] = getSomethingElse;
        catch  %#ok<CTCH>
        end
        trEPRbusyWindow('delete');
        if exist('c','var')
            showSomethingElse(c,d);
        end
    otherwise
        return;
end

end


function [img,map] = getSomething

URL = ['http://' char([100 105 108 98 101 114 116]) '.com/'];
% Read URL - fooling the server a bit about the browser used (given that we
% have a recent enough Matlab, > 7.14 alias 2012a)
matlabVersion = ver('Matlab');
if str2double(matlabVersion.Version) > 7.14
    uriContent = urlread(URL,'UserAgent',...
        'Mozilla/5.0 (compatible)','Charset','UTF-8');
else
    uriContent = urlread(URL);
end
% Parse URL for link to strip
stripURLpart = regexp(uriContent,...
    '(/dyn/str_strip/[0-9/]*.strip.zoom.gif)','match');
stripURL = [ URL stripURLpart{1} ];
% Get image
[img,map] = imread(stripURL);

end

function showSomething(img,map)

figure();
image(img); 
colormap(map); 
axis off; 
axis image; 
imgSize = size(img);
screenSize = get(0,'ScreenSize');
set(gcf,'unit','pixels','position',[(screenSize(3)-imgSize(2))/2 ...
    (screenSize(4)-imgSize(1))/2 imgSize(2)-3 imgSize(1)-1],...
    'MenuBar','none','NumberTitle','off',...
    'Name',[ char([68 105 108 98 101 114 116]) ' ' ...
    char([67 111 109 105 99]) ' ' char([83 116 114 105 112]) ...
    'http://' char([100 105 108 98 101 114 116]) '.com/']); 
set(gca,'unit','pixels','position',[0 1 imgSize(2)-1 imgSize(1)-1]);

end

function [img,title] = getSomethingElse

URL = ['https://www.' char([120 107 99 100]) '.com/'];

% Read URL
uriContent = urlread(URL);
startMatch = ['<div id="' char([99 111 109 105 99]) '">'];
endMatch = '</div>';

% Parse URL for link to strip
startMatchPos = strfind(uriContent,startMatch);
startMatchPos = startMatchPos(1);
endMatchPos = strfind(uriContent(startMatchPos:end),endMatch);
endMatchPos = endMatchPos(1);

imgTag = uriContent(startMatchPos+length(startMatch):startMatchPos+endMatchPos-2);

imgUrl = regexp(imgTag,'src="([^"]*)"','tokens');
imgTitle = regexp(imgTag,'title="([^"]*)"','tokens');

% Get image
img = imread(imgUrl{1}{1});
title = imgTitle{1}{1};
end

function showSomethingElse(img,title)
fHandle = figure();

imgSize = size(img);
screenSize = get(0,'ScreenSize');

set(fHandle,'unit','pixels','position',[(screenSize(3)-imgSize(2))/2 ...
    (screenSize(4)-imgSize(1))/2 imgSize(2)-3 imgSize(1)-1],...
    'MenuBar','none','NumberTitle','off',...
    'Name',[char([120 107 99 100]) ' ' ...
    char([67 111 109 105 99]) ' ' char([83 116 114 105 112]) ...
    'https://www.' char([120 107 99 100]) '.com/']); 

uicontrol('Style','pushbutton','Parent',fHandle,...
    'Units','Pixels','Position',[0 1 imgSize(2)-1 imgSize(1)-1],...
    'CData',ind2rgb(img,gray),'TooltipString',['<html>' title], ...
    'Callback',{@closeFcn} ...
);

function closeFcn(~,~)
close(gcf)
end

end
