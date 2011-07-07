function [data,message] = trEPRbrukerBES3Tload(filename)
% TREPRBRUKERBES3TLOAD Read Bruker Xepr ASCII export of transient spectra
%
% Usage
%   data = trEPRbrukerBES3Tload(filename)
%   [data,warning] = trEPRbrukerBES3Tload(filename)
%
% filename - string
%            name of a valid filename (of a Bruker BES3T file)
% data     - struct
%            structure containing data and additional fields
%
% warning  - cell array of strings
%            empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.

% (c) 2011, Till Biskup
% 2011-07-07

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.parse(filename);

try
    % If there is no filename specified, return
    if isempty(filename)
        data = struct();
        message = {'No filename or file does not exist'};
        return;
    end
    % If filename does not exist, try to add extension
    if  ~exist(filename,'file')
        [fpath,fname,fext] = fileparts(filename);
        if exist(fullfile(fpath,[fname '.DTA']),'file')
            filename = fullfile(fpath,[fname '.DTA']);
        else
            data = struct();
            message = {'No filename or file does not exist'};
            return;
        end
    end
    
    % Read Bruker DSC file and get minimum set of parameters
    % First, create filename for DSC file
    [fpath,fname,fext] = fileparts(filename);
    dscFilename = fullfile(fpath,[fname,'.DSC']);
    
    % Open DSC file and read line by line
    [fid,msg] = fopen(dscFilename);
    % If fopen was successful, fid > 2, otherwise fid == -1
    if fid > 2
        % Read first line of file
        tline = fgetl(fid);
        % Do some very basic input checking, compare to what is the first
        % line of a Bruker BES3T description file and if that does not fit,
        % complain and exit
        if ~strfind(tline,'#DESC	1.2 * DESCRIPTOR INFORMATION')
            fclose(fid);
            data = struct();
            message = {...
                sprintf('Problems reading file %s',filename)...
                'Seems not to be a proper Bruker BES3T file.'...
                'Could not understand DSC file.'...
                };
            return;        
        end
        % Read whole DSC file in one pass into cell array
        k=1;
        while ischar(tline)
            DSC{k,1} = tline;
            % Do some very basic assignment of necessary parameters already
            % while reading file (saves doing another looping through the
            % cell array later on
            %
            % Get dimensions of data, XPTS, YPTS (used later when reading
            % binary data)
            if (strfind(tline,'XPTS'))
                XPTS = str2double(...
                    regexp(tline,'XPTS[^\d\c](\d+)','tokens','once'));
            end
            if (strfind(tline,'YPTS'))
                YPTS = str2double(...
                    regexp(tline,'YPTS[^\d\c](\d+)','tokens','once'));
            end
            % Try to get parameters for x axis
            if (strfind(tline,'XMIN'))
                XMIN = str2double(...
                    regexp(tline,'XMIN[^\d\c](.+)','tokens','once'));
            end
            if (strfind(tline,'XWID'))
                XWID = str2double(...
                    regexp(tline,'XWID[^\d\c](.+)','tokens','once'));
            end
            if (strfind(tline,'XNAM'))
                data.axes.x.measure = char(...
                    regexp(tline,'XNAM[^\d\c]''(.*)''','tokens','once'));
            end
            if (strfind(tline,'XUNI'))
                data.axes.x.unit = char(...
                    regexp(tline,'XUNI[^\d\c]''(.*)''','tokens','once'));
            end
            % Try to get parameters for y axis
            if (strfind(tline,'YMIN'))
                YMIN = str2double(...
                    regexp(tline,'YMIN[^\d\c](.+)','tokens','once'));
            end
            if (strfind(tline,'YWID'))
                YWID = str2double(...
                    regexp(tline,'YWID[^\d\c](.+)','tokens','once'));
            end
            if (strfind(tline,'YNAM'))
                data.axes.y.measure = char(...
                    regexp(tline,'YNAM[^\d\c]''(.*)''','tokens','once'));
            end
            if (strfind(tline,'YUNI'))
                data.axes.y.unit = char(...
                    regexp(tline,'YUNI[^\d\c]''(.*)''','tokens','once'));
            end
            
            if (strfind(tline,'AVGS'))
                data.parameters.recorder.averages = str2double(...
                    regexp(tline,'AVGS[^\d\c]*(.+)','tokens','once'));
            end
            
            if (strfind(tline,'TITL'))
                data.label = char(...
                    regexp(tline,'TITL[^\d\c]''(.*)''','tokens','once'));
            end
            
            if (strfind(tline,'FrequencyMon'))
                data.parameters.bridge.MWfrequency = str2double(regexp(...
                    tline,'FrequencyMon[^\d\c]*([0-9.]+)[^\d\c]*',...
                    'tokens','once'));
            end
            tline = fgetl(fid);
            k=k+1;
        end
        % Close file
        fclose(fid);
    else % meaning: file could not be opened
        data = struct();
        message = {...
            sprintf('Problems reading file %s',filename)...
            msg...
            };
        return;
    end
    
    % Create axes vectors
    data.axes.x.values = linspace(XMIN,XMIN+XWID,XPTS);
    data.axes.y.values = linspace(YMIN,YMIN+YWID,YPTS);
    
    % Read Bruker BES3T binary data
    [fid,msg] = fopen(filename);
    % If fopen was successful, fid > 2, otherwise fid == -1
    if fid > 2
        % Data are binary, big endian, double precision
        data.data = fread(fid,inf,'double',0,'b');
        fclose(fid);
    else
        data = struct();
        message = {...
            sprintf('Problems reading file %s',filename)...
            msg...
            };
        return;
    end
    
    % Reshape data according to what we read from DSC file
    data.data = reshape(data.data,XPTS,[])';
    
    % Do a very rough checking of dimensions, using XPTS and YPTS from the
    % DSC file
    [y,x] = size(data.data);
    if ~(y==YPTS && x==XPTS)
        disp('WARNING: data seem to have wrong dimensions!');
    end
    
    % Set other fields of data structure
    data.filename = filename;

    % Append complete DSC file to data structure
    data.header = DSC;
    
    % Write parameters structure, partly filled with values
    % Details of the structure can be found at the toolbox homepage, look
    % for description of the trEPRload return argument format
    data.parameters.runs = 1;
    data.parameters.field.start = data.axes.y.values(1);
    data.parameters.field.stop = data.axes.y.values(end);
    data.parameters.field.step = ...
        data.axes.y.values(2)-data.axes.y.values(1);
    data.parameters.recorder.sensitivity.value = [];
    data.parameters.recorder.sensitivity.unit = '';
    data.parameters.recorder.timeBase = [];
    data.parameters.transient.points = length(data.axes.x.values);
    data.parameters.transient.triggerPosition = [];
    data.parameters.transient.length = ...
        data.axes.x.values(end)-data.axes.x.values(1);
    data.parameters.temperature = [];
    data.parameters.laser.wavelength = [];
    data.parameters.laser.repetitionRate = [];
    
    % Assinging empty cell array to warning
    message = cell(0);
catch exception
    throw(exception);
end

end