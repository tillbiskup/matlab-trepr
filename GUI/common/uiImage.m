function uiImage(image,varargin)
% UIIMAGE Display image as ui element in figure window.
%
% Please note: The function makes use of the underlying Java functionality
%              in Matlab(r). 
%
% Usage:
%   uiImage(image)
%   uiImage(image,<parameter>,<value>)
%
%   image - image
%           image to display
%
% Optional parameters that can be set:
%
%   Parent          - handle
%                     handle of the parent figure window
%                     If not specified, gcf will be used.
%                     If no figure window exists, a new one will be opened.
%
%   Position        - vector (2x1 or 4x1)
%                     position of the image relative to parent.
%                     If four values are given, the image dimensions will
%                     be overwritten and image potentially cut (therefore,
%                     handle with care!)
%
%   backgroundColor - vector (3x1)
%                     background color for the image
%                     If not provided, background color of the parent will
%                     be used.
%
% See also: image, uiText

% Copyright (c) 2014, Till Biskup
% 2014-07-26

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParse instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('image', @(x)ischar(x) && exist(x,'file'));
    p.addParamValue('Parent',[],@ishandle);
    p.addParamValue('Position',[0 0],...
        @(x)isvector(x) && (length(x) == 2 || length(x) == 4));
    p.addParamValue('backgroundColor',[],...
        @(x)isvector(x) && length(x) == 3);
    p.parse(image,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Is there a figure window?
if isempty(findobj('Type','figure'))
    figure();
end

if isempty(p.Results.Parent)
    parent = gcf;
end

if isempty(p.Results.backgroundColor)
    backgroundColor = get(parent,'Color');
end
bgColor = num2cell(backgroundColor);

try
    icon = javax.swing.ImageIcon(image);
    
    position = p.Results.Position;
    if length(position) == 2
        position = [position icon.getIconWidth icon.getIconHeight];
    end
    
    jIconLabel = javax.swing.JLabel('');
    jIconLabel.setIcon(icon);
    javacomponent(jIconLabel,position,parent);
    jIconLabel.setBackground(java.awt.Color(bgColor{:}));
catch exception
    throw(exception);
end

end