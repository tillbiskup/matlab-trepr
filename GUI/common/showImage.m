function fHandle = showImage(img,varargin)
% SHOWIMAGE Display image in figure window
%
% Usage
%   showImage(img)
%   showImage(img,map)
%   fh = showImage(...)
%
%   img - image
%         Image to display
%         Usually just a matrix
%
%   map - colormap
%         Colormap used to display the image
%
%   fh  - graphics handle
%         Handle of the graphics window

% Copyright (c) 2015, Till Biskup
% 2015-10-18

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('img', @isnumeric);
    p.addOptional('map',[],@isnumeric);
    p.addParamValue('Name','',@ischar);
    p.parse(img,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

fHandle = figure();
image(img); 

if ~isempty(p.Results.map)
    colormap(p.Results.map);
end

axis off; 
axis image; 
imgSize = size(img);
screenSize = get(0,'ScreenSize');
set(gcf,'unit','pixels','position',[(screenSize(3)-imgSize(2))/2 ...
    (screenSize(4)-imgSize(1))/2 imgSize(2)-3 imgSize(1)-1],...
    'MenuBar','none','NumberTitle','off',...
    'Name',p.Results.Name); 
set(gca,'unit','pixels','position',[0 1 imgSize(2)-1 imgSize(1)-1]);

end