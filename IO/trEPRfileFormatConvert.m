function [data,varargout] = trEPRfileFormatConvert(data,varargin)
% TREPRFILEFORMATCONVERT Convert older versions of the trEPR toolbox file
% format (and especially data structure) into the current one.
%
% Usage:
%   [data,warning] = trEPRfileFormatConvert(data);
%
%   data     - struct
%              dataset in trEPR toolbox format
%   warning  - cell array
%              Contains warnings if there are any, otherwise empty
%
% SEE ALSO TREPRLOAD, TREPRXMLZIPREAD

% Copyright (c) 2012-14, Till Biskup
% 2014-08-07

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('data', @(x)isstruct(x));
    % parser.addParamValue('checkFormat',logical(true),@islogical);
    p.parse(data);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

warning = '';

% Very basic test, no better idea to test for the right format
if ~isfield(data,'data')
    % Hm... looks like something serious went wrong
    data = [];
    warning = 'Most probably wrong format';
    if nargout == 2
        varargout{1} = warning;
    end
    return;
end

% First thing: Try to get the version of the file
if ~isfield(data,'version') && ~isfield(data,'format')
    % Looks like we're in version < 1.1
    version = '1.0';
elseif isfield(data,'format') && isfield(data.format,'version')
    version = data.format.version;
    if isfield(data,'version')
        data = rmfield(data,'version');
    end
else
    version = data.version;
end

newdata = trEPRdataStructure('structure');

newVersion = newdata.format.version;

% There is nothing to do for the most current version...
if strcmpi(version,newdata.format.version)
    if nargout == 2
        varargout{1} = warning;
    end
    return;
end

% Get empty data structure and copy fields if possible
newdata = structcopy(newdata,data);

switch version
    case '1.10'
        % Main change: characteristics (POI, DOI, SOI, VOI)
        % Need to iterate over all characteristics of each type
        % SOI
        for soi = 1:length(newdata.characteristics.soi);
            newdata.characteristics.soi(soi).parameters.coordinates = ...
                data.characteristics.soi(soi).coordinates;
            newdata.characteristics.soi(soi).parameters.direction = ...
                data.characteristics.soi(soi).direction;
            newdata.characteristics.soi(soi).parameters.avgWindow = ...
                data.characteristics.soi(soi).avgWindow;
            newdata.characteristics.soi(soi).line.color = ...
                data.characteristics.soi(soi).color;
            newdata.characteristics.soi(soi).line.style = ...
                data.characteristics.soi(soi).style;
            newdata.characteristics.soi(soi).line.marker = ...
                data.characteristics.soi(soi).marker;
            newdata.characteristics.soi(soi).line.width = ...
                data.characteristics.soi(soi).width;
        end
        % Remove old fields
        newdata.characteristics.soi = rmfield(...
            newdata.characteristics.soi,...
            {'coordinates','direction','avgWindow','color','style',...
            'marker','width'});
        % POI
        for poi = 1:length(newdata.characteristics.poi);
            newdata.characteristics.poi(poi).parameters.coordinates = ...
                data.characteristics.poi(poi).coordinates;
        end
        % Remove old fields
        newdata.characteristics.poi = rmfield(...
            newdata.characteristics.poi,'coordinates');
        % DOI
        for doi = 1:length(newdata.characteristics.doi)
            newdata.characteristics.doi(doi).parameters.coordinates = ...
                data.characteristics.doi(doi).coordinates;
            newdata.characteristics.doi(doi).parameters.distance = ...
                data.characteristics.doi(doi).distance;
            newdata.characteristics.doi(doi).line.color = ...
                data.characteristics.doi(doi).color;
            newdata.characteristics.doi(doi).line.style = ...
                data.characteristics.doi(doi).style;
            newdata.characteristics.doi(doi).line.marker = ...
                data.characteristics.doi(doi).marker;
            newdata.characteristics.doi(doi).line.width = ...
                data.characteristics.doi(doi).width;
        end
        % Remove old fields
        newdata.characteristics.doi = rmfield(...
            newdata.characteristics.doi,...
            {'coordinates','distance','color','style',...
            'marker','width'});
        % VOI
        for voi = 1:length(newdata.characteristics.voi)
            newdata.characteristics.voi(voi).parameters.type = ...
                data.characteristics.voi(voi).type;
            newdata.characteristics.voi(voi).parameters.offset = ...
                data.characteristics.voi(voi).offset;
            if strcmpi(data.characteristics.voi(voi).offset.type,'none')
                newdata.characteristics.voi(voi).parameters.offset.type = ...
                    'auto';
            end
            newdata.characteristics.voi(voi).parameters.surface = ...
                data.characteristics.voi(voi).surface;
            newdata.characteristics.voi(voi).parameters.view = ...
                data.characteristics.voi(voi).view;
        end
        % Remove old fields
        newdata.characteristics.voi = rmfield(...
            newdata.characteristics.voi,...
            {'type','offset','surface','view'});
    case '1.9'
        newdata.display.lines.data = data.line;
        newdata.display.displacement.data.x = data.display.displacement.x;
        newdata.display.displacement.data.y = data.display.displacement.y;
        newdata.display.displacement.data.z = data.display.displacement.z;
        newdata.display.scaling.data.x = data.display.scaling.x;
        newdata.display.scaling.data.y = data.display.scaling.y;
        newdata.display.scaling.data.z = data.display.scaling.z;
        newdata.display.smoothing.data.x.filterfun = ...
            data.display.smoothing.x.filterfun;
        newdata.display.smoothing.data.x.parameters.width = ...
            data.display.smoothing.x.value;
        newdata.display.smoothing.data.y.filterfun = ...
            data.display.smoothing.y.filterfun;
        newdata.display.smoothing.data.y.parameters.width = ...
            data.display.smoothing.y.value;
        newdata.display.smoothing.calculated.x.parameters.width = ...
            data.display.smoothing.calculated.x.value;
        newdata.display.smoothing.calculated.y.parameters.width = ...
            data.display.smoothing.calculated.y.value;
        % Remove old fields
        newdata.display.displacement = ...
            rmfield(newdata.display.displacement,{'x','y','z'});
        newdata.display.scaling = ...
            rmfield(newdata.display.scaling,{'x','y','z'});
        newdata.display.smoothing = ...
            rmfield(newdata.display.smoothing,{'x','y'});
        newdata.display.smoothing.calculated.x = ...
            rmfield(newdata.display.smoothing.calculated.x,'value');
        newdata.display.smoothing.calculated.y = ...
            rmfield(newdata.display.smoothing.calculated.y,'value');
        newdata = rmfield(newdata,'line');
        % Change value of filter width
        newdata.display.smoothing.data.x.parameters.width = floor(...
            (newdata.display.smoothing.data.x.parameters.width-1)/2);
        newdata.display.smoothing.data.y.parameters.width = floor(...
            (newdata.display.smoothing.data.y.parameters.width-1)/2);
        % Check for wrong field types (was problem with old format)
        if ischar(newdata.parameters.purpose)
            purpose = newdata.parameters.purpose;
            newdata.parameters = rmfield(newdata.parameters,'purpose');
            newdata.parameters.purpose{1} = purpose;
        end
        sampleFieldNames = {'description','buffer','preparation'};
        for k = 1:length(sampleFieldNames)
            if ischar(newdata.sample.(sampleFieldNames{k}))
                value = newdata.sample.(sampleFieldNames{k});
                newdata.sample = ...
                    rmfield(newdata.sample,(sampleFieldNames{k}));
                newdata.sample.(sampleFieldNames{k}) = value;
            end
        end
    case '1.8'
        newdata.display.lines.data = data.line;
        newdata.display.displacement.data.x = data.display.displacement.x;
        newdata.display.displacement.data.y = data.display.displacement.y;
        newdata.display.displacement.data.z = data.display.displacement.z;
        newdata.display.scaling.data.x = data.display.scaling.x;
        newdata.display.scaling.data.y = data.display.scaling.y;
        newdata.display.scaling.data.z = data.display.scaling.z;
        newdata.display.smoothing.data.x.filterfun = '';
        newdata.display.smoothing.data.x.parameters.width = ...
            data.display.smoothing.x.value;
        newdata.display.smoothing.data.y.filterfun = '';
        newdata.display.smoothing.data.y.parameters.width = ...
            data.display.smoothing.y.value;
        newdata.display.smoothing.calculated.x.parameters.width = 0;
        newdata.display.smoothing.calculated.y.parameters.width = 0;
        % Remove old fields
        newdata.display.displacement = ...
            rmfield(newdata.display.displacement,{'x','y','z'});
        newdata.display.scaling = ...
            rmfield(newdata.display.scaling,{'x','y','z'});
        newdata.display.smoothing = ...
            rmfield(newdata.display.smoothing,{'x','y'});
        newdata = rmfield(newdata,'line');
        % Change value of filter width
        newdata.display.smoothing.data.x.parameters.width = floor(...
            (newdata.display.smoothing.data.x.parameters.width-1)/2);
        newdata.display.smoothing.data.y.parameters.width = floor(...
            (newdata.display.smoothing.data.y.parameters.width-1)/2);
        % Check for wrong field types (was problem with old format)
        if ischar(newdata.parameters.purpose)
            purpose = newdata.parameters.purpose;
            newdata.parameters = rmfield(newdata.parameters,'purpose');
            newdata.parameters.purpose{1} = purpose;
        end
        sampleFieldNames = {'description','buffer','preparation'};
        for k = 1:length(sampleFieldNames)
            if ischar(newdata.sample.(sampleFieldNames{k}))
                value = newdata.sample.(sampleFieldNames{k});
                newdata.sample = ...
                    rmfield(newdata.sample,(sampleFieldNames{k}));
                newdata.sample.(sampleFieldNames{k}) = value;
            end
        end
    case '1.5'
        newdata.parameters.purpose = {''};
        newdata.sample.buffer = {''};
    case '1.4'
        if isnumeric(data.parameters.field.start)
            newdata.parameters.field.start.value = data.parameters.field.start;
            newdata.parameters.field.start.unit = data.axes.y.unit;
            newdata.parameters.field.stop.value = data.parameters.field.stop;
            newdata.parameters.field.stop.unit = data.axes.y.unit;
            newdata.parameters.field.step.value = data.parameters.field.step;
            newdata.parameters.field.step.unit = data.axes.y.unit;
        end
        if isnumeric(data.parameters.transient.length)
            newdata.parameters.transient.length.value = data.parameters.transient.length;
            newdata.parameters.transient.length.unit = data.axes.x.unit;
        end
        if ~isempty(data.parameters.bridge.calibration) ...
                && length(data.parameters.bridge.calibration) > 1
            newdata.parameters.bridge.calibration.start.value = data.parameters.bridge.calibration.values(1);
            newdata.parameters.bridge.calibration.end.value = data.parameters.bridge.calibration.values(end);
        end
        if ~isfield(data.parameters.bridge.calibration,'start')
            newdata.parameters.bridge.calibration.start.unit = data.parameters.bridge.calibration.unit;
            newdata.parameters.bridge.calibration.end.unit = data.parameters.bridge.calibration.unit;
            newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'values');
            newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'unit');
        end
    case '1.3'
        newdata.parameters.date.start = data.parameters.date;
        newdata.parameters.date.end = '';
        newdata.parameters.field.start.value = data.parameters.field.start;
        newdata.parameters.field.start.unit = data.axes.y.unit;
        newdata.parameters.field.stop.value = data.parameters.field.stop;
        newdata.parameters.field.stop.unit = data.axes.y.unit;
        newdata.parameters.field.step.value = data.parameters.field.step;        
        newdata.parameters.field.step.unit = data.axes.y.unit;
        newdata.parameters.transient.length.value = data.parameters.transient.length;
        newdata.parameters.transient.length.unit = data.axes.x.unit;
        if ~isempty(data.parameters.bridge.calibration) ...
                && length(data.parameters.bridge.calibration) > 1
            newdata.parameters.bridge.calibration.start.value = data.parameters.bridge.calibration.values(1);
            newdata.parameters.bridge.calibration.end.value = data.parameters.bridge.calibration.values(end);
        end
        newdata.parameters.bridge.calibration.start.unit = data.parameters.bridge.calibration.unit;
        newdata.parameters.bridge.calibration.end.unit = data.parameters.bridge.calibration.unit;
        newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'values');
        newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'unit');
    case '1.2'
        newdata.parameters.date.start = data.parameters.date;
        newdata.parameters.date.end = '';
        newdata.parameters.field.start.value = data.parameters.field.start;
        newdata.parameters.field.start.unit = data.axes.y.unit;
        newdata.parameters.field.stop.value = data.parameters.field.stop;
        newdata.parameters.field.stop.unit = data.axes.y.unit;
        newdata.parameters.field.step.value = data.parameters.field.step;        
        newdata.parameters.field.step.unit = data.axes.y.unit;
        newdata.parameters.transient.length.value = data.parameters.transient.length;
        newdata.parameters.transient.length.unit = data.axes.x.unit;
        if ~isempty(data.parameters.bridge.calibration) ...
                && length(data.parameters.bridge.calibration) > 1
            newdata.parameters.bridge.calibration.start.value = data.parameters.bridge.calibration.values(1);
            newdata.parameters.bridge.calibration.end.value = data.parameters.bridge.calibration.values(end);
        end
        newdata.parameters.bridge.calibration.start.unit = data.parameters.bridge.calibration.unit;
        newdata.parameters.bridge.calibration.end.unit = data.parameters.bridge.calibration.unit;
        newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'values');
        newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'unit');
        newdata.parameters.laser.tunable.model = data.parameters.laser.opoDye;
        newdata.parameters.laser = rmfield(newdata.parameters.laser,'opoDye');
    case '1.1'
        newdata.parameters.date.start = data.parameters.date;
        newdata.parameters.date.end = '';
        newdata.parameters.field.start.value = data.parameters.field.start;
        newdata.parameters.field.start.unit = data.axes.y.unit;
        newdata.parameters.field.stop.value = data.parameters.field.stop;
        newdata.parameters.field.stop.unit = data.axes.y.unit;
        newdata.parameters.field.step.value = data.parameters.field.step;        
        newdata.parameters.field.step.unit = data.axes.y.unit;
        newdata.parameters.transient.length.value = data.parameters.transient.length;
        newdata.parameters.transient.length.unit = data.axes.x.unit;
        newdata.parameters.probehead.model = data.parameters.bridge.probehead;
        newdata.parameters.bridge = rmfield(newdata.parameters.bridge,'probehead');
        if ~isempty(data.parameters.bridge.calibration) ...
                && length(data.parameters.bridge.calibration) > 1
            newdata.parameters.bridge.calibration.start.value = data.parameters.bridge.calibration.values(1);
            newdata.parameters.bridge.calibration.end.value = data.parameters.bridge.calibration.values(end);
        end
        newdata.parameters.bridge.calibration.start.unit = data.parameters.bridge.calibration.unit;
        newdata.parameters.bridge.calibration.end.unit = data.parameters.bridge.calibration.unit;
        newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'values');
        newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'unit');
        newdata.parameters.laser.tunable.model = data.parameters.laser.opoDye;
        newdata.parameters.laser = rmfield(newdata.parameters.laser,'opoDye');
    case '1.0'
        if ~isstruct(data.parameters.field.start)
        newdata.parameters.field.start.value = data.parameters.field.start;
        newdata.parameters.field.start.unit = data.axes.y.unit;
        end
        if ~isstruct(data.parameters.field.stop)
        newdata.parameters.field.stop.value = data.parameters.field.stop;
        newdata.parameters.field.stop.unit = data.axes.y.unit;
        end
        if ~isstruct(data.parameters.field.step)
        newdata.parameters.field.step.value = data.parameters.field.step;        
        newdata.parameters.field.step.unit = data.axes.y.unit;
        end
        if ~isstruct(data.parameters.recorder.timeBase)
        newdata.parameters.recorder.timeBase.value = data.parameters.recorder.timeBase;
        newdata.parameters.recorder.timeBase.unit = '';
        end
        if ~isstruct(data.parameters.transient.length)
        newdata.parameters.transient.length.value = data.parameters.transient.length;
        newdata.parameters.transient.length.unit = data.axes.x.unit;
        end
        if ~isstruct(data.parameters.bridge.MWfrequency)
            newdata.parameters.bridge.MWfrequency.value = data.parameters.bridge.MWfrequency;
            newdata.parameters.bridge.MWfrequency.unit = 'GHz';
        end
        if ~isstruct(data.parameters.bridge.attenuation)
            newdata.parameters.bridge.attenuation.value = data.parameters.bridge.attenuation;
            newdata.parameters.bridge.attenuation.unit = 'dB';
        end
        if isfield(data.parameters.bridge,'calibration')
            if ~isempty(data.parameters.bridge.calibration) ...
                    && length(data.parameters.bridge.calibration) > 1
                newdata.parameters.bridge.calibration.start.value = data.parameters.bridge.calibration.values(1);
                newdata.parameters.bridge.calibration.end.value = data.parameters.bridge.calibration.values(end);
            end
            newdata.parameters.bridge.calibration.start.unit = data.parameters.bridge.calibration.unit;
            newdata.parameters.bridge.calibration.end.unit = data.parameters.bridge.calibration.unit;
            newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'values');
            newdata.parameters.bridge.calibration = rmfield(newdata.parameters.bridge.calibration,'unit');
        end
        if ~isstruct(data.parameters.temperature)
            newdata.parameters.temperature.value = data.parameters.temperature;
            newdata.parameters.temperature.unit = 'K';
        end
        if ~isstruct(data.parameters.laser.wavelength)
            newdata.parameters.laser.wavelength.value = data.parameters.laser.wavelength;
            newdata.parameters.laser.wavelength.unit = 'nm';
        end
        if ~isstruct(data.parameters.laser.repetitionRate)
            newdata.parameters.laser.repetitionRate.value = data.parameters.laser.repetitionRate;
            newdata.parameters.laser.repetitionRate.unit = 'Hz';
        end
        % Finally, recopy to ensure to have all fields
        newdata = structcopy(trEPRdataStructure('structure'),newdata);
end

% Handle situation with reversed field axis
if newdata.parameters.field.start.value > newdata.parameters.field.stop.value
    newdata.parameters.field.start.value = newdata.axes.y.values(1);
    newdata.parameters.field.stop.value = newdata.axes.y.values(end);
    newdata.parameters.field.sequence = 'down';
end

if nargout == 2
    varargout{1} = warning;
end

newdata.format.version = newVersion;

data = newdata;

end
