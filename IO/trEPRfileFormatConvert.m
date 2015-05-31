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

% Copyright (c) 2012-15, Till Biskup
% 2015-05-31

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

if commonVersionLessThan(version,'1.1')
    if ~isstruct(data.parameters.recorder.timeBase)
        data.parameters.recorder.timeBase.value = data.parameters.recorder.timeBase;
        data.parameters.recorder.timeBase.unit = '';
    end
    if ~isstruct(data.parameters.bridge.MWfrequency)
        data.parameters.bridge.MWfrequency.value = data.parameters.bridge.MWfrequency;
        data.parameters.bridge.MWfrequency.unit = 'GHz';
    end
    if ~isstruct(data.parameters.bridge.attenuation)
        data.parameters.bridge.attenuation.value = data.parameters.bridge.attenuation;
        data.parameters.bridge.attenuation.unit = 'dB';
    end
    if ~isstruct(data.parameters.temperature)
        data.parameters.temperature.value = data.parameters.temperature;
        data.parameters.temperature.unit = 'K';
    end
    if ~isstruct(data.parameters.laser.wavelength)
        data.parameters.laser.wavelength.value = data.parameters.laser.wavelength;
        data.parameters.laser.wavelength.unit = 'nm';
    end
    if ~isstruct(data.parameters.laser.repetitionRate)
        data.parameters.laser.repetitionRate.value = data.parameters.laser.repetitionRate;
        data.parameters.laser.repetitionRate.unit = 'Hz';
    end
    data.parameters.bridge.probehead = '';
    data.parameters.date = '';
    data.parameters.bridge.calibration = '';
    data.parameters.laser.opoDye = '';
    data.axes.z = struct('measure','','unit','');
end

if commonVersionLessThan(version,'1.2')
    data.parameters.probehead.model = data.parameters.bridge.probehead;
    data.parameters.bridge = rmfield(data.parameters.bridge,'probehead');
    if isfield(data,'version')
        data = rmfield(data,'version');
    end
end

if commonVersionLessThan(version,'1.3')
    data.parameters.laser.tunable.model = data.parameters.laser.opoDye;
    data.parameters.laser = rmfield(data.parameters.laser,'opoDye');
end

if commonVersionLessThan(version,'1.4')
    data.parameters.date.start = data.parameters.date;
    if ~isempty(data.parameters.bridge.calibration)
        if length(data.parameters.bridge.calibration) > 1
            data.parameters.bridge.calibration.start.value = ...
                data.parameters.bridge.calibration.values(1);
            data.parameters.bridge.calibration.end.value = ...
                data.parameters.bridge.calibration.values(end);
        end
        data.parameters.bridge.calibration.start.unit = ...
            data.parameters.bridge.calibration.unit;
        data.parameters.bridge.calibration.end.unit = ...
            data.parameters.bridge.calibration.unit;
        data.parameters.bridge.calibration = ...
            rmfield(data.parameters.bridge.calibration,'values');
        data.parameters.bridge.calibration = ...
            rmfield(data.parameters.bridge.calibration,'unit');
    end
end

if commonVersionLessThan(version,'1.5')
    if isnumeric(data.parameters.field.start)
        data.parameters.field.start.value = data.parameters.field.start;
        data.parameters.field.start.unit = data.axes.y.unit;
        data.parameters.field.stop.value = data.parameters.field.stop;
        data.parameters.field.stop.unit = data.axes.y.unit;
        data.parameters.field.step.value = data.parameters.field.step;
        data.parameters.field.step.unit = data.axes.y.unit;
    end
    if isnumeric(data.parameters.transient.length)
        data.parameters.transient.length.value = data.parameters.transient.length;
        data.parameters.transient.length.unit = data.axes.x.unit;
    end
    if ~isempty(data.parameters.bridge.calibration)
        if length(data.parameters.bridge.calibration) > 1
            data.parameters.bridge.calibration.start.value = ...
                data.parameters.bridge.calibration.values(1);
            data.parameters.bridge.calibration.end.value = ...
                data.parameters.bridge.calibration.values(end);
        end
        if ~isfield(data.parameters.bridge.calibration,'start')
            data.parameters.bridge.calibration.start.unit = ...
                data.parameters.bridge.calibration.unit;
            data.parameters.bridge.calibration.end.unit = ...
                data.parameters.bridge.calibration.unit;
            data.parameters.bridge.calibration = ...
                rmfield(data.parameters.bridge.calibration,'values');
            data.parameters.bridge.calibration = ...
                rmfield(data.parameters.bridge.calibration,'unit');
        end
    end
end

if commonVersionLessThan(version,'1.6')
    data.parameters.purpose = {''};
    data.sample.buffer = {''};
end

if commonVersionLessThan(version,'1.9')
    if isfield(data,'display') && isfield(data.display,'averaging')
        data.display.averaging.data = data.display.averaging;
        data.display.averaging = rmfield(data.display.averaging,{'x','y'});
    end
    data.display.smoothing.x.filterfun = '';
    data.display.smoothing.y.filterfun = '';
    data.display.smoothing.x.value = 1;
    data.display.smoothing.y.value = 1;
end

if commonVersionLessThan(version,'1.10')
    if isfield(data,'line')
        data.display.lines.data = data.line;
    end
    if isfield(data.display,'displacement')
        data.display.displacement.data.x = data.display.displacement.x;
        data.display.displacement.data.y = data.display.displacement.y;
        data.display.displacement.data.z = data.display.displacement.z;
        % Remove old fields
        data.display.displacement = ...
            rmfield(data.display.displacement,{'x','y','z'});
    end
    if isfield(data.display,'scaling')
        data.display.scaling.data.x = data.display.scaling.x;
        data.display.scaling.data.y = data.display.scaling.y;
        data.display.scaling.data.z = data.display.scaling.z;
        % Remove old fields
        data.display.scaling = ...
            rmfield(data.display.scaling,{'x','y','z'});
    end
    if isfield(data.display,'smoothing')
        data.display.smoothing.data.x.filterfun = ...
            data.display.smoothing.x.filterfun;
        data.display.smoothing.data.x.parameters.width = ...
            data.display.smoothing.x.value;
        data.display.smoothing.data.y.filterfun = ...
            data.display.smoothing.y.filterfun;
        data.display.smoothing.data.y.parameters.width = ...
            data.display.smoothing.y.value;
        if isfield(data.display.smoothing,'calculated')
            data.display.smoothing.calculated.x.parameters.width = ...
                data.display.smoothing.calculated.x.value;
            data.display.smoothing.calculated.y.parameters.width = ...
                data.display.smoothing.calculated.y.value;
            % Remove old fields
            data.display.smoothing.calculated.x = ...
                rmfield(data.display.smoothing.calculated.x,'value');
            data.display.smoothing.calculated.y = ...
                rmfield(data.display.smoothing.calculated.y,'value');
        end
        data.display.smoothing = ...
            rmfield(data.display.smoothing,{'x','y'});
        % Change value of filter width
        data.display.smoothing.data.x.parameters.width = floor(...
            (data.display.smoothing.data.x.parameters.width-1)/2);
        data.display.smoothing.data.y.parameters.width = floor(...
            (data.display.smoothing.data.y.parameters.width-1)/2);
    end
    if isfield(data,'line')
        data = rmfield(data,'line');
    end
    % Check for wrong field types (was problem with old format)
    if isfield(data.parameters,'purpose') && ischar(data.parameters.purpose)
        purpose = data.parameters.purpose;
        data.parameters = rmfield(data.parameters,'purpose');
        data.parameters.purpose{1} = purpose;
    end
    sampleFieldNames = {'description','buffer','preparation'};
    for k = 1:length(sampleFieldNames)
        if isfield(data.sample,sampleFieldNames{k}) ...
                && ischar(data.sample.(sampleFieldNames{k}))
            value = data.sample.(sampleFieldNames{k});
            data.sample = ...
                rmfield(data.sample,(sampleFieldNames{k}));
            data.sample.(sampleFieldNames{k}) = value;
        end
    end
end

if commonVersionLessThan(version,'1.11')
    % Main change: characteristics (POI, DOI, SOI, VOI)
    % Need to iterate over all characteristics of each type
    % SOI
    if isfield(data,'characteristics')
        for soi = 1:length(data.characteristics.soi);
            data.characteristics.soi(soi).parameters.coordinates = ...
                data.characteristics.soi(soi).coordinates;
            data.characteristics.soi(soi).parameters.direction = ...
                data.characteristics.soi(soi).direction;
            data.characteristics.soi(soi).parameters.avgWindow = ...
                data.characteristics.soi(soi).avgWindow;
            if isfield(data.characteristics.soi(soi),'line')
                data.characteristics.soi(soi).line.color = ...
                    data.characteristics.soi(soi).color;
                data.characteristics.soi(soi).line.style = ...
                    data.characteristics.soi(soi).style;
                data.characteristics.soi(soi).line.marker = ...
                    data.characteristics.soi(soi).marker;
                data.characteristics.soi(soi).line.width = ...
                    data.characteristics.soi(soi).width;
            end
        end
        % POI
        for poi = 1:length(data.characteristics.poi);
            data.characteristics.poi(poi).parameters.coordinates = ...
                data.characteristics.poi(poi).coordinates;
        end
        % DOI
        for doi = 1:length(data.characteristics.doi)
            data.characteristics.doi(doi).parameters.coordinates = ...
                data.characteristics.doi(doi).coordinates;
            data.characteristics.doi(doi).parameters.distance = ...
                data.characteristics.doi(doi).distance;
            if isfield(data.characteristics.soi(soi),'line')
                data.characteristics.doi(doi).line.color = ...
                    data.characteristics.doi(doi).color;
                data.characteristics.doi(doi).line.style = ...
                    data.characteristics.doi(doi).style;
                data.characteristics.doi(doi).line.marker = ...
                    data.characteristics.doi(doi).marker;
                data.characteristics.doi(doi).line.width = ...
                    data.characteristics.doi(doi).width;
            end
        end
        % VOI
        if isfield(data.characteristics,'voi')
            for voi = 1:length(data.characteristics.voi)
                data.characteristics.voi(voi).parameters.type = ...
                    data.characteristics.voi(voi).type;
                data.characteristics.voi(voi).parameters.offset = ...
                    data.characteristics.voi(voi).offset;
                if strcmpi(data.characteristics.voi(voi).offset.type,'none')
                    newdata.characteristics.voi(voi).parameters.offset.type = ...
                        'auto';
                end
                data.characteristics.voi(voi).parameters.surface.edgeColor = ...
                    data.characteristics.voi(voi).surface.EdgeColor;
                data.characteristics.voi(voi).parameters.surface.meshStyle = ...
                    data.characteristics.voi(voi).surface.MeshStyle;
                data.characteristics.voi(voi).parameters.surface.lineStyle = ...
                    data.characteristics.voi(voi).surface.LineStyle;
                data.characteristics.voi(voi).parameters.view = ...
                    data.characteristics.voi(voi).view;
            end
        end
    end
end

% Change axes for version < 1.13
if commonVersionLessThan(version,'1.13')
    % Main change: Axes renamed
    % Remove unnecessary field in old y axis
    if isfield(data.axes.y,'calibratedValues') && ...
            isempty(data.axes.y.calibratedValues)
        data.axes.y = rmfield(data.axes.y,'calibratedValues');
    end
    data.axes.data(1) = data.axes.x;
    data.axes.data(2) = data.axes.y;
    data.axes.data(3) = ...
        commonStructCopy(newdata.axes.data(3),data.axes.z);
    % Remove old fields
    data.axes = rmfield(data.axes,{'x','y','z'});
    % Display fields were reorganised as well
    if isfield(data.display,'position')
        data.display.position.data = ...
            [data.display.position.x data.display.position.y];
        data.display.position = ...
            rmfield(data.display.position,{'x','y'});
    end
    fields = {'displacement','scaling'};
    if all(isfield(data.display,fields))
        for field = 1:length(fields)
            if isfield(data.display,fields{field})
                data.display.(fields{field}).data = [ ...
                    data.display.(fields{field}).data.x ...
                    data.display.(fields{field}).data.y ...
                    data.display.(fields{field}).data.z ];
                if isfield(data.display.(fields{field}),'calculated')
                    data.display.(fields{field}).calculated = [ ...
                        data.display.(fields{field}).calculated.x ...
                        data.display.(fields{field}).calculated.y ...
                        data.display.(fields{field}).calculated.z ];
                end
            end
        end
    end
    if isfield(data.display,'averaging')
        if isfield(data.display.averaging,'data')
            data.display.averaging.data = [ ...
                data.display.averaging.data.x ...
                data.display.averaging.data.y ];
        end
        if isfield(data.display.averaging,'calculated')
            data.display.averaging.calculated = [ ...
                data.display.averaging.calculated.x ...
                data.display.averaging.calculated.y ];
        end
    end
    if isfield(data.display,'smoothing')
        data.display.smoothing.data = [...
            data.display.smoothing.data.x, data.display.smoothing.data.y];
        if isfield(data.display.smoothing,'calculated')
            data.display.smoothing.calculated = [...
                data.display.smoothing.calculated.x, ...
                data.display.smoothing.calculated.y];
        end
    end
end

% Handle situation with reversed field axis
if data.parameters.field.start.value > data.parameters.field.stop.value
    data.parameters.field.start.value = data.axes.data(2).values(1);
    data.parameters.field.stop.value = data.axes.data(2).values(end);
    data.parameters.field.sequence = 'down';
end

% Get empty data structure and copy fields if possible
newdata = commonStructCopy(newdata,data);

if nargout == 2
    varargout{1} = warning;
end

newdata.format.version = newVersion;

data = newdata;

end
