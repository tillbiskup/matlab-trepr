function [warnings] = trEPRinfoFileWrite(filename,parameters,varargin)
% TREPRINFOFILEWRITE Write Info files of trEPR spectra.
%
% Usage
%   trEPRinfoFileWrite(filename,parameters)
%   [warnings] = trEPRinfoFileWrite(filename,parameters)
%
% filename   - string
%              Valid filename (for a trEPR Info file)
% parameters - struct
%              structure containing parameters to write to the trEPR Info file
%
%              Either a structure as read with trEPRinfoFileParse or the
%              parameters structure of a trEPR toolbox dataset
%
% warnings   - cell array of strings
%              empty if there are no warnings
%
% See also: TREPRINFOFILEPARSE, TREPRINFOFILECREATE

% Copyright (c) 2012, Till Biskup
% 2012-06-07

% If called without parameter, do something useful: display help
if ~nargin && ~nargout
    help trEPRinfoFileWrite
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.addRequired('parameters', @(x)isstruct(x));
p.addParameter('overwrite',logical(false),@islogical);
%p.addOptional('command','',@(x)ischar(x));
p.parse(filename,parameters,varargin{:});

warnings = cell(0);

try
    % If there is no filename specified, open file selection dialogue
    if isempty(filename)
        [FileName,PathName] = uiputfile('*.info',...
            'Select filename for info file');
        filename = fullfile(PathName,FileName);
    end
    % If filename exists and overwrite set to false, ask user to overwrite
    if  exist(filename,'file') && ~p.Results.overwrite
        while 1
            button = questdlg(...
                sprintf('File\n  %s\n exists already. Overwrite?',filename),...
                'File exists...',...
                'Yes','No','Cancel','No');
            switch lower(button)
                case 'no'
                    [FileName,PathName] = uiputfile('*.info',...
                        'Select filename for info file');
                    if ~isempty(FileName) && FileName ~= 0;
                        filename = fullfile(PathName,FileName);
                        break;
                    end
                case 'cancel'
                    return;
                otherwise
                    break;
            end
        end
    end
    
    % Get file contents
    [fileContents,warnings] = trEPRinfoFileCreate(parameters);

    % Write content of the cell array "fileContents" to file
    fh = fopen(filename,'w');
    cellfun(@(x)fprintf(fh,'%s\n',x),fileContents);
    fclose(fh);

catch exception
    throw(exception);
end

end
