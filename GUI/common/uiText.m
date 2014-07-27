function uiText(text,varargin)
% UITEXT Display text as ui element in figure window.
%
% Please note: The function makes use of the underlying Java functionality
%              in Matlab(r) and therefore allows for extended formatting
%              using HTML.
%
% Usage:
%   uiText(text)
%   uiText(text,<parameter>,<value>)
%
%   text - string
%          text to display
%          Note: May contain HTML tags
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
%                     If only two values are given, a default will be used.
%
%   backgroundColor - vector (3x1)
%                     background color for the text
%                     If not provided, background color of the parent will
%                     be used.
%
% See also: image, uiText

% Copyright (c) 2014, Till Biskup
% 2014-07-27

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('text', @(x)ischar(x));
    p.addParamValue('Parent',[],@ishandle);
    p.addParamValue('Position',[0 0],...
        @(x)isvector(x) && (length(x) == 2 || length(x) == 4));
    p.addParamValue('backgroundColor',[],...
        @(x)isvector(x) && length(x) == 3);
    p.parse(text,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Is there a figure window?
if isempty(findobj('Type','figure'))
    figure();
end

parent = p.Results.Parent;
if isempty(p.Results.Parent)
    parent = gcf;
end

position = p.Results.Position;
if length(position) == 2
    position = [position 100 30];
end

if isempty(text)
    text = 'Lorem ipsum';
end

backgroundColor = p.Results.backgroundColor;
if isempty(backgroundColor)
    backgroundColor = get(parent,'Color');
end
bgColor = num2cell(backgroundColor);

try
    text = ['<html>' text '<html>'];
    jTextLabel = javaObjectEDT('javax.swing.JLabel',text);
    javacomponent(jTextLabel,position,parent);
    jTextLabel.setBackground(java.awt.Color(bgColor{:}));
catch exception
    throw(exception);
end