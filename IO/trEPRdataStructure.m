function varargout = trEPRdataStructure(varargin)
% TREPRDATASTRUCTURE Return data structure for trEPR toolbox data, or test
% compliance of given structure with the data structure of the toolbox.
%
% Usage
%   structure = trEPRdataStructure;
%   structure = trEPRdataStructure(<command>)
%   [missingFields,wrongType] = trEPRdataStructure(<command>,structure)
%
%   <command> - string 
%               one of 'structure', 'model' or 'check'
%               'structure' - return (empty) trEPR toolbox data structure
%               'model' -     return trEPR toolbox data structure with
%                             field types as values
%               'check' -     check given structure for compliance with the
%                             toolbox data structure
%
%   structure - struct
%               either empty trEPR toolbox data structure or 
%               trEPR toolbox data structure with field types as values
%
%   missingFields - cell array
%                   List of fields missing in the structure with respect to
%                   the toolbox data structure
%
%   wrongType -     cell array
%                   List of fields in structure having the wrong type with
%                   respect to the toolbox data structure
%
% See also TREPRLOAD.

% (c) 2011, Till Biskup
% 2011-12-09

% If called without parameter, do something useful: display help
if ~nargin && ~nargout
    help trEPRdataStructure
end

% Create empty trEPR toolbox data structure
dataStructure = struct();
dataStructure.data = [];
dataStructure.axes = struct(...
    'x',struct(...
        'values',[], ...
        'measure','', ...
        'unit','' ...
        ), ...
    'y',struct(...
        'values',[], ...
        'calibratedValues',[], ...
        'measure','', ...
        'unit','' ...
        ), ...
    'z',struct(...
        'measure','', ...
        'unit','' ...
        ) ...
    );
dataStructure.parameters = struct(...
    'runs',[],...
    'operator','',...
    'date','',...
    'field',struct(...
        'start',[],...
        'stop',[],...
        'step',[],...
        'unit','',...
        'model','',...
        'calibration',struct(...
            'values',[],...
            'unit','',...
            'model',''...
            )...
        ),...
    'recorder',struct(...
        'sensitivity',struct(...
            'value',[],...
            'unit',''...
            ),...
        'averages',[],...
        'timeBase',struct(...
            'value',[],...
            'unit',''...
            ),...
        'bandwidth',struct(...
            'value',[],...
            'unit',''...
            ),...
        'coupling','',...
        'impedance',struct(...
            'value',[],...
            'unit',''...
            ),...
        'model',''...
        ),...
    'transient',struct(...
        'points',[],...
        'triggerPosition',[],...
        'length',[],...
        'unit',''...
        ),...
    'bridge',struct(...
        'MWfrequency',struct(...
            'value',[],...
            'unit',''...
            ),...
        'attenuation',struct(...
            'value',[],...
            'unit',''...
            ),...
        'bandwidth',struct(...
            'value',[],...
            'unit',''...
            ),...
        'amplification',struct(...
            'value',[],...
            'unit',''...
            ),...
        'calibration',struct(...
            'values',[],...
            'unit','',...
            'model',''...
            ),...
        'power',struct(...
            'value',[],...
            'unit',''...
            ),...
        'model','',...
        'probehead',''...
        ),...
    'laser',struct(...
        'wavelength',struct(...
            'value',[],...
            'unit',''...
            ),...
        'repetitionRate',struct(...
            'value',[],...
            'unit',''...
            ),...
        'power',struct(...
            'value',[],...
            'unit',''...
            ),...
        'model','',...
        'opoDye',''...
        ),...
    'temperature',struct(...
        'value',[],...
        'unit',''...
        )...
    );
dataStructure.sample = struct(...
    'name','',...
    'tube',''...
    );
dataStructure.sample.description = cell(0);
dataStructure.sample.preparation = cell(0);
dataStructure.header = cell(0);
dataStructure.comment = cell(0);
dataStructure.info = struct();
dataStructure.file = struct(...
    'name','', ...
    'format','' ...
    );
dataStructure.label = '';
dataStructure.format = struct(...
    'name','trEPR toolbox', ...
    'version','1.1' ...
    );

% Create trEPR toolbox data model (structure with field types as values)
dataModel = struct();
dataModel.data = 'ismatrix';
dataModel.axes = struct(...
    'x',struct(...
        'values','isvector', ...
        'measure','ischar', ...
        'unit','ischar' ...
        ), ...
    'y',struct(...
        'values','isvector', ...
        'calibratedValues','isscalar', ...
        'measure','ischar', ...
        'unit','ischar' ...
        ), ...
    'z',struct(...
        'measure','ischar', ...
        'unit','ischar' ...
        ) ...
    );
dataModel.parameters = struct(...
    'runs','isscalar',...
    'operator','ischar',...
    'date','ischar',...
    'field',struct(...
        'start','isscalar',...
        'stop','isscalar',...
        'step','isscalar',...
        'unit','ischar',...
        'model','ischar',...
        'calibration',struct(...
            'values','isvector',...
            'unit','ischar',...
            'model','ischar'...
            )...
        ),...
    'recorder',struct(...
        'sensitivity',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'averages','isscalar',...
        'timeBase',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'bandwidth',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'coupling','ischar',...
        'impedance',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'model','ischar'...
        ),...
    'transient',struct(...
        'points','isscalar',...
        'triggerPosition','isscalar',...
        'length','isscalar',...
        'unit','ischar'...
        ),...
    'bridge',struct(...
        'MWfrequency',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'attenuation',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'bandwidth',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'amplification',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'calibration',struct(...
            'values','isvector',...
            'unit','ischar',...
            'model','ischar'...
            ),...
        'power',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'model','ischar',...
        'probehead','ischar'...
        ),...
    'laser',struct(...
        'wavelength',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'repetitionRate',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'power',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'model','ischar',...
        'opoDye','ischar'...
        ),...
    'temperature',struct(...
        'value','isscalar',...
        'unit','ischar'...
        )...
    );
dataModel.sample = struct(...
    'name','ischar', ...
    'tube','ischar', ...
    'description','iscell', ...
    'preparation','iscell' ...
    );
dataModel.header = 'iscell';
dataModel.comment = 'iscell';
dataModel.info = 'isstruct';
dataModel.file = struct(...
    'name','ischar', ...
    'format','ischar' ...
    );
dataModel.label = 'ischar';
dataModel.format = struct(...
    'name','ischar', ...
    'version','ischar' ...
    );

if nargin && ischar(varargin{1})
    switch lower(varargin{1})
        case 'structure'
            if nargout
                varargout{1} = dataStructure;
            end
        case 'model'
            if nargout
                varargout{1} = dataModel;
            end
        case 'check'
            if nargin < 2
                fprintf('No structure to check...\n');
                return;
            end
            if ~isstruct(varargin{2})
                fprintf('%s has wrong type',inputname(2));
                return;
            end
            
            [missingFields,wrongType] = ...
                checkStructure(dataModel,varargin{2},inputname(2));

            if ~isempty(missingFields)
                fprintf('There are missing fields:\n');
                for k=1:length(missingFields)
                    fprintf('  %s\n',char(missingFields{k}));
                end
            end
            if ~isempty(wrongType)
                fprintf('There are fields with wrong type:\n');
                for k=1:length(wrongType)
                    fprintf('  %s\n',char(wrongType{k}));
                end
                return;
            end
            if isempty(missingFields) && isempty(wrongType)
                fprintf('Basic test passed! Structure seems fine...\n');
                return;
            end
        otherwise
            fprintf('Command ''%s'' unknown\n',varargin{1});
            return;
    end
else
    if nargout
        varargout{1} = dataStructure;
    end
end

end

function fieldNameList = getFieldNameList(structure)
fieldNameList = cell(0);
    function traverse(structure,parent)
        fieldNames = fieldnames(structure);
        for k=1:length(fieldNames)
            if isstruct(structure.(fieldNames{k})) && ...
                    ~isempty(fieldnames(structure.(fieldNames{k})))
                % It is important to check whether the struct is empty, as
                % it would not get added to the list of field names.
                traverse(structure.(fieldNames{k}),[parent '.' fieldNames{k}]);
            else
                fieldNameList{end+1} = sprintf('%s.%s',parent,fieldNames{k});
            end
        end
    end
traverse(structure,'structure');
end

function [missingFields,wrongType] = checkStructure(model,structure,name)
missingFields = cell(0);
wrongType = cell(0);
    function traverse(model,structure,parent)
        modelFieldNames = fieldnames(model);
        for k=1:length(modelFieldNames)
            if ~isfield(structure,modelFieldNames{k})
                missingFields{end+1} = ...
                    sprintf('%s.%s',parent,modelFieldNames{k});
            else
                if isstruct(model.(modelFieldNames{k}))
                    if ~isstruct(structure.(modelFieldNames{k}))
                        wrongType{end+1} = ...
                            sprintf('%s.%s',parent,modelFieldNames{k});
                    end
                    traverse(...
                        model.(modelFieldNames{k}),...
                        structure.(modelFieldNames{k}),...
                        [parent '.' modelFieldNames{k}]...
                        );
                else
                    functionHandle = str2func(model.(modelFieldNames{k}));
                    if ~functionHandle(structure.(modelFieldNames{k}))
                        if strcmp(model.(modelFieldNames{k}),'isscalar') || ...
                                strcmp(model.(modelFieldNames{k}),'isvector')
                            if isnumeric(structure.(modelFieldNames{k})) && ...
                                    isempty(structure.(modelFieldNames{k}))
                                return;
                            end
                        end
                        wrongType{end+1} = ...
                            sprintf('%s.%s',parent,modelFieldNames{k});
                    end
                end
            end
        end
    end
traverse(model,structure,name);
end
