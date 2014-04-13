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

% (c) 2014, Till Biskup
% 2014-03-01

% Set status
status = 0;

% Currently, no support for Windows platform
if ispc
    disp('Sorry, currently not available for the Windows platform.');
    return;
end

% Check whether PDF file exists
if ~exist(pdfFile,'file')
    [pdfFilePath,pdfFileName,~] = fileparts(pdfFile);
    pdfFile = fullfile(pdfFilePath,[pdfFileName '.pdf']);
    if ~exist(pdfFile);
        disp(['File ' pdfFile ' seems not to exist.']);
        return;
    end
end

if ~imageMagickInstalled
    disp('Looks like you don''t have ImageMagick installed on your system.');
    return;
end

convertCommand = fullfile(locateConvertTool,'convert');



end


function status = imageMagickInstalled

status = false;

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

% Take last path
[pathToConvert,~,~] = fileparts(paths{end});


end