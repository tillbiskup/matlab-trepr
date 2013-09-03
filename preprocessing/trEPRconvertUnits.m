function data = trEPRconvertUnits(data,conversion,varargin)
% TREPRCONVERTUNITS Convert units in dataset.
%
% Usage
%   data = trEPRconvertUnits(data,<conversion>)
%   [data,warnings] = trEPRconvertUnits(data,<conversion>);
%
% data       - struct
%              Dataset conforming the trEPR toolbox dataset format
% conversion - string
%              Conversion to be performed on the dataset.

% (c) 2013, Till Biskup
% 2013-09-03

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create inputParser instance
p.FunctionName = mfilename; % Function name for error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('data', @(x)isstruct(x));
p.addRequired('conversion', @(x)ischar(x));
p.parse(data,conversion);

[missing,wrong] = trEPRdataStructure('check',data);
if ~isempty(missing)
    trEPRmsg('Missing fields in the input dataset','e');
    return;
end

try
    switch lower(conversion)
        case 'g2mt'
            % Check axis labels
            if strcmpi(data.axes.y.unit,'g')
                data.axes.y.values = data.axes.y.values / 10;
                data.axes.y.unit = 'mT';
            end
            % Check parameters
            if strcmpi(data.parameters.field.start.unit,'g')
                data.parameters.field.start.value = ...
                    data.parameters.field.start.value / 10;
                data.parameters.field.start.unit = 'mT';
            end
            if strcmpi(data.parameters.field.stop.unit,'g')
                data.parameters.field.stop.value = ...
                    data.parameters.field.stop.value / 10;
                data.parameters.field.stop.unit = 'mT';
            end
            if strcmpi(data.parameters.field.step.unit,'g')
                data.parameters.field.step.value = ...
                    data.parameters.field.step.value / 10;
                data.parameters.field.step.unit = 'mT';
            end
        case 'mt2g'
            % Check axis labels
            if strcmpi(data.axes.y.unit,'mt')
                data.axes.y.values = data.axes.y.values * 10;
                data.axes.y.unit = 'G';
            end
            % Check parameters
            if strcmpi(data.parameters.field.start.unit,'mt')
                data.parameters.field.start.value = ...
                    data.parameters.field.start.value * 10;
                data.parameters.field.start.unit = 'G';
            end
            if strcmpi(data.parameters.field.stop.unit,'mt')
                data.parameters.field.stop.value = ...
                    data.parameters.field.stop.value * 10;
                data.parameters.field.stop.unit = 'G';
            end
            if strcmpi(data.parameters.field.step.unit,'mt')
                data.parameters.field.step.value = ...
                    data.parameters.field.step.value * 10;
                data.parameters.field.step.unit = 'G';
            end
        case 's2us'
            % Check axis labels
            if strcmpi(data.axes.x.unit,'s')
                data.axes.x.values = data.axes.x.values * 10e6;
                data.axes.x.unit = 'us';
            end
            % Check parameters
            if strcmpi(data.parameters.transient.length.unit,'s')
                data.parameters.transient.length.value = ...
                    data.parameters.transient.length.value * 10e6;
                data.parameters.transient.length.unit = 'us';
            end
        case 'us2s'
            % Check axis labels
            if strcmpi(data.axes.x.unit,'us')
                data.axes.x.values = data.axes.x.values * 10e-6;
                data.axes.x.unit = 's';
            end
            % Check parameters
            if strcmpi(data.parameters.transient.length.unit,'us')
                data.parameters.transient.length.value = ...
                    data.parameters.transient.length.value * 10e-6;
                data.parameters.transient.length.unit = 's';
            end
        otherwise
            trEPRmsg(['Conversion "' conversion '" not understood'],'w');
    end
catch exception
    throw(exception);
end

end