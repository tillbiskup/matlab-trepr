function status = fig2file(figHandle,fileName,varargin)
% FIG2FILE Save Matlab figure window to file
%
% Usage
%   fig2file(figHandle,fileName);
%   status = fig2file(figHandle,fileName);
%   status = fig2file(figHandle,fileName,...);
%
% figHandle    - handle
%                Handle of the Matlab figure to be saved
% fileName     - string
%                Name of the file the figure should be saved to
%                Should at least be a filename with extension
%
% status       - string
%                Empty string if everything is fine
%                Otherwise it contains an error description
%
% You can pass optional parameters. For details see below.
%
% Parameters
%
% fileType     - string
%                Setting the file type used to save the figure to
%                Currently one out of: fig|eps|pdf|png
%                Fefault: fig
%
% exportFormat - string
%                Paper format (and font settings) for exporting the figure
%                Does not get applied in case of export as MATLAB(r) fig
%                Default: default
%
%                You can set all details and additional formats in the file
%                'fig2file.ini' that is in the same directory as fig2file.m
%

% Copyright (c) 2011-13, Till Biskup
% 2013-05-15

% If called without arguments, print help and list of formats
if ~nargin
    help fig2file;
    try
        % Read configuration for export formats (geometries) from ini file
        exportFormatsConfigFile = [mfilename('full') '.ini'];
        exportFormats = ...
            trEPRiniFileRead(exportFormatsConfigFile,'typeConversion',false);
        fprintf('  Export formats (from "%s")\n\n',[mfilename '.ini']);
        formats = fieldnames(exportFormats);
        cellfun(@(x)fprintf('\t%s\n',x),formats);
    catch exception
        disp('An error occurred when trying to read the INI file:');
        throw(exception);
    end
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input arguments
p.addRequired('figHandle', @(x)ishandle(x));
p.addRequired('fileName', @(x)ischar(x));
% Add a few optional parameters, with default values
p.addParamValue('fileType','fig',@ischar);
p.addParamValue('exportFormat','default',@ischar);
% Parse input arguments
p.parse(figHandle,fileName,varargin{:});

% Assign parameters from parser
fileType = p.Results.fileType;
exportFormat = p.Results.exportFormat;

try
    % Read configuration for export formats (geometries) from ini file
    exportFormatsConfigFile = [mfilename('full') '.ini'];
    exportFormats = ...
        trEPRiniFileRead(exportFormatsConfigFile,'typeConversion',false);

    % Set export format only in case of not having "fig" as fileType
    if ~strcmpi(fileType,'fig')
        oldParams = struct();
        fieldNames = fieldnames(exportFormats.(exportFormat));
        for k=1:length(fieldNames)
            % First of all, need to convert numeric parts of config file to
            % real numeric types
            % NOTE: As textscan returns a cell array, we need to use
            % cell2mat to convert that into a proper vector
            switch lower(fieldNames{k})
                case 'papersize'
                    exportFormats.(exportFormat).(fieldNames{k}) = ...
                        cell2mat(textscan(...
                        exportFormats.(exportFormat).(fieldNames{k}),...
                        '%f %f'));
                case 'paperposition'
                    exportFormats.(exportFormat).(fieldNames{k}) = ...
                        cell2mat(textscan(...
                        exportFormats.(exportFormat).(fieldNames{k}),...
                        '%f %f %f %f'));
                case 'fontsize'
                    exportFormats.(exportFormat).(fieldNames{k}) = ...
                        str2double(...
                        exportFormats.(exportFormat).(fieldNames{k}));
                case 'axesposition'
                    exportFormats.(exportFormat).(fieldNames{k}) = ...
                        cell2mat(textscan(...
                        exportFormats.(exportFormat).(fieldNames{k}),...
                        '%f %f %f %f'));
            end
            % Problem arising here: "Paper" options are figure properties,
            % "Font" options not. Therefore, need to discriminate between
            % both.
            if strcmpi(fieldNames{k}(1:5),'paper')
                oldParams.(fieldNames{k}) = get(figHandle,fieldNames{k});
                set(figHandle,fieldNames{k},...
                    exportFormats.(exportFormat).(fieldNames{k}));
            end
            if strcmpi(fieldNames{k}(1:4),'font')
                % Try to get axis handle, and if there is one, set
                % properties
                % NOTE: We're a bit cheating here, getting the original
                % font settings just from the axis handle, not caring about
                % different settings for labels. That means that
                % afterwards, all the font settings are those from the axis
                % handle, even if there were different settings for the
                % labels.
                axisHandle = findobj(allchild(figHandle),'type','axes',...
                    '-not','tag','legend');
                if ~isempty(axisHandle)
                    for m=1:length(axisHandle)
                        oldParams.(fieldNames{k}) = get(axisHandle(m),fieldNames{k});
                        set(axisHandle(m),fieldNames{k},...
                            exportFormats.(exportFormat).(fieldNames{k}));
                    end
                end
                % Try to get text handles that are child of axes
                for hidx=1:length(axisHandle)
                    textHandles = findobj(allchild(axisHandle(hidx)),...
                        'type','text');
                    % If there are any, set their text properties
                    if ~isempty(textHandles)
                        set(textHandles,fieldNames{k},...
                            exportFormats.(exportFormat).(fieldNames{k}));
                    end
                end
            end
        end
        
        % Try to set axis such that it fills the paper position
        % rectangle, but taking care of tick marks, labels, and title
        % Therefore, try to get axis handle, and if there is one, set
        % properties.
        axisHandle = findobj(allchild(figHandle),'type','axes',...
            '-not','tag','legend');
        if ~isempty(axisHandle)
            if length(axisHandle) == 1
                oldAxisUnits = get(axisHandle,'Unit');
                oldAxisPosition = get(axisHandle,'Position');
                set(axisHandle,'Unit',exportFormats.(exportFormat).PaperUnits);
                tightInset = get(axisHandle,'TightInset');
                axisPosition = exportFormats.(exportFormat).PaperPosition;
                axisPosition(1:2) = tightInset(1:2);
                axisPosition(3) = axisPosition(3)-sum(tightInset([1,3]));
                axisPosition(4) = axisPosition(4)-sum(tightInset([2,4]));
                set(axisHandle,'Position',axisPosition);
            else
                oldAxisPosition = cell(length(axisHandle));
                for k=1:length(axisHandle)
                    oldAxisUnits = get(axisHandle(k),'Unit');
                    oldAxisPosition{k} = get(axisHandle(k),'Position');
                    set(axisHandle(k),'Unit',exportFormats.(exportFormat).PaperUnits);
                end
                % TODO: Handle subplots properly
                axis(axisHandle,'auto','fill');
            end
        end
    end
    
    % Do actual figure export, depending on the fileType
    switch lower(fileType)
        case 'fig'
            set(figHandle,'Visible','On');
            saveas(figHandle,fileName,'fig');
        case 'eps'
            print(figHandle,'-depsc2','-painters',fileName);
        case 'pdf'
            print(figHandle,'-dpdf',fileName);
        case 'png'
            saveas(figHandle,fileName,'png');
        otherwise
            % That shall never happen...
            status = sprintf('File type %s currently unsupported',fileType);
            return;
    end
    
    % Set values back to their previous values
    % That's good practice according to MATLAB(r) help. And as we want this
    % function to work properly will all types of figures, not just from
    % the GUI where we plot a new figure in the background...
    if ~strcmpi(fileType,'fig')
        fieldNames = fieldnames(exportFormats.(exportFormat));
        for k=1:length(fieldNames)
            if strcmpi(fieldNames{k}(1:5),'paper')
                set(figHandle,fieldNames{k},oldParams.(fieldNames{k}));
            end
            if strcmpi(fieldNames{k}(1:4),'font')
                % NOTE: We're a bit cheating here, using the original font
                % settings only from the axis handle, not caring about 
                % different settings for labels. That means that
                % afterwards, all the font settings are those from the axis
                % handle, even if there were different settings for the
                % labels.
                % Try to get axis handle
                axisHandle = findobj(allchild(figHandle),'type','axes',...
                    '-not','tag','legend');
                if ~isempty(axisHandle)
                    for m=1:length(axisHandle)
                        set(axisHandle(m),fieldNames{k},...
                            oldParams.(fieldNames{k}));
                    end
                end                    
                % Try to get text handles that are child of axes
                for hidx=1:length(axisHandle)
                    textHandles = findobj(allchild(axisHandle(hidx)),...
                        'type','text');
                    % If there are any, set their text properties
                    if ~isempty(textHandles)
                        set(textHandles,fieldNames{k},...
                            oldParams.(fieldNames{k}));
                    end
                end
            end    
        end
        % Reset axis units
        axisHandle = findobj(allchild(figHandle),'type','axes',...
            '-not','tag','legend');
        if ~isempty(axisHandle)
            if length(axisHandle) == 1
                set(axisHandle,'Unit',oldAxisUnits);
                set(axisHandle,'Position',oldAxisPosition);
            else
                for k=1:length(axisHandle)
                    set(axisHandle(k),'Unit',oldAxisUnits);
                    set(axisHandle(k),'Position',oldAxisPosition{k});
                end
            end
        end
    end
    
    % Set status to empty string
    status = '';
catch exception
    throw(exception);
end

end
