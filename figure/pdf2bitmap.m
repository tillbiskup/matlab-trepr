function status = pdf2bitmap(pdfFile,varargin)
% PDF2BITMAP Convert PDF file to bitmap file using ImageMagick, the command
% line graphics program.
%
% Usage
%   pdf2bitmap(pdfFile)
%
% LIMITATIONS: This function relies on ImageMagick installed on your OS and
% makes heavy use of the SYSTEM command. Currently, only Linux and Mac are
% supported.

% Copyright (c) 2014-20, Till Biskup
% 2020-11-08

% Set status
if nargout
    status = 0;
end

if ~nargin
    help pdf2bitmap
    return;
end

% Currently, no support for Windows platform
if ispc
    disp('Sorry, currently not available for the Windows platform.');
    return;
end

[pdfFilePath,pdfFileName,~] = fileparts(pdfFile);
% Check whether PDF file exists
if ~exist(pdfFile,'file')
    pdfFile = fullfile(pdfFilePath,[pdfFileName '.pdf']);
    if ~exist(pdfFile,'file');
        disp(['File ' pdfFile ' seems not to exist.']);
        return;
    end
else
    [pdfFilePath,pdfFileName,~] = fileparts(pdfFile);
end

if ~imageMagickInstalled
    disp('Looks like you don''t have ImageMagick installed on your system.');
    return;
end

% Add path of convert tool to PATH variable of MATLAB shell
setenv('PATH',[getenv('PATH') ':' locateConvertTool]);
%convertCommand = fullfile(locateConvertTool,'convert');
convertCommand = 'convert';

convertOptions1 = '-density 600x600 -quality 90 -alpha remove';
convertOptions2 = '-resize 680';

system([convertCommand ' ' convertOptions1 ' ' pdfFile ' ' ...
    convertOptions2 ' ' fullfile(pdfFilePath,[pdfFileName '.png']) ]);

end


function status = imageMagickInstalled

status = false;

% Hack around MATLAB: add "/usr/local/bin" to PATH
setenv('PATH', [getenv('PATH'), ':/usr/local/bin']);

% Call "convert" and get the bash exit code: 127 => "Command not found" 
[exitCode,~] = system('convert');

if exitCode == 127
    % Try to get path to convert tool
    [exitCode,~] = system(fullfile(locateConvertTool,'convert'));
    if exitCode == 127
        return;
    end
end

status = true;

end

function pathToConvert = locateConvertTool

pathToConvert = '';

% Check whether we have the "locate" command
[exitCode,~] = system('locate');
if exitCode == 127
    return;
end

% Get paths for "convert"
[~,message] = system('locate convert | grep "/convert$"');

% Split message into lines
% ("system" returns a string including newline characters)
paths = regexp(message(1:end-1),'\n','split');

% Take first path
[pathToConvert,~,~] = fileparts(paths{end});

end
