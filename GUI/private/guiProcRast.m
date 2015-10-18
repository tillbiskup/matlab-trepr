function guiProcRast(varargin)
% GUIPROCRAST A very important internal GUI function with quite telling
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

% Copyright (c) 2014-15, Till Biskup
% 2015-10-18

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
    case char([112 104 100 99 111 109 105 99])
        trEPRbusyWindow('start',['Good choice...<br>'...
            '(retrieving necessary data)']);
        try
            [e,f] = getSomethingThird;
        catch  %#ok<CTCH>
        end
        trEPRbusyWindow('delete');
        if exist('e','var')
            showSomethingThird(e,f);
        end
    case char([110 105 99 104 116 108 117 115 116 105 103])
        trEPRbusyWindow('start',['Deutschsprachig?...<br>'...
            '(besser isses...)']);
        try
            [aa,bb] = getSomethingFourth;
        catch  %#ok<CTCH>
        end
        trEPRbusyWindow('delete');
        if exist('aa','var')
            showSomethingFourth(aa,bb);
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
stripURL = regexp(uriContent,...
    '(http://assets.amuniversal.com/[a-z0-9]*)','match');
% Get image
[img,map] = imread(stripURL{1});

end

function showSomething(img,map)

showImage(img,map,'title',[ char([68 105 108 98 101 114 116]) ' ' ...
    char([67 111 109 105 99]) ' ' char([83 116 114 105 112]) ' ' ...
    'http://' char([100 105 108 98 101 114 116]) '.com/']);

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
img = imread(['http:' imgUrl{1}{1}]);
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
    char([67 111 109 105 99]) ' ' char([83 116 114 105 112]) ' ' ...
    'https://www.' char([120 107 99 100]) '.com/']); 

try
    cdataImg = ind2rgb(img,gray);
catch  %#ok<CTCH>
    cdataImg = img;
end

uicontrol('Style','pushbutton','Parent',fHandle,...
    'Units','Pixels','Position',[0 1 imgSize(2)-1 imgSize(1)-1],...
    'CData',cdataImg,'TooltipString',['<html>' title], ...
    'Callback',{@closeFcn} ...
);

end

function [img,map] = getSomethingThird

URL = ['http://' char([112 104 100 99 111 109 105 99 115]) '.com/' ...
    char([99 111 109 105 99 115 46 112 104 112])];

% Read URL
uriContent = urlread(URL);
startMatch = ['id=' char([99 111 109 105 99]) ' name=' ...
    char([99 111 109 105 99]) ' src='];

% Parse URL for link to strip
startMatchPos = strfind(uriContent,startMatch);

imgUrl = strtrim(uriContent(startMatchPos+length(startMatch) : ...
    startMatchPos+length(startMatch)+54));

% Get image
[img,map] = imread(imgUrl);
end

function showSomethingThird(img,map)
showImage(img,map,...
    'Name',[ char([112 104 100 99 111 109 105 99 115]) ' ' ...
    char([67 111 109 105 99]) ' ' char([83 116 114 105 112]) ' ' ...
    'http://' char([112 104 100 99 111 109 105 99 115]) '.com/']); 

end

function [img,map] = getSomethingFourth

URL = ['http://' char([110 105 99 104 116 108 117 115 116 105 103]) '.de/' ...
    'main.html'];

% Read URL
uriContent = urlread(URL);
startMatch = '<link rel="image_src" href="';

% Parse URL for link to strip
startMatchPos = strfind(uriContent,startMatch);

imgUrl = strtrim(uriContent(startMatchPos+length(startMatch) : ...
    startMatchPos+length(startMatch)+50));

% Get image
[img,map] = imread(imgUrl);
end

function showSomethingFourth(img,map)
showImage(img,map,...
    'Title',[ char([110 105 99 104 116 108 117 115 116 105 103]) ' ' ...
    char([67 111 109 105 99]) ' ' char([83 116 114 105 112]) ' ' ...
    'http://' char([110 105 99 104 116 108 117 115 116 105 103]) '.de/']); 

end