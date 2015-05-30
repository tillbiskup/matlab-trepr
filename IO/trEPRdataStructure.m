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
%               'structure'    - return (empty) trEPR toolbox data
%                                structure
%               'model'        - return trEPR toolbox data structure with
%                                field types as values
%               'check'        - check given structure for compliance with
%                                the toolbox data structure
%               'history'      - return history structure for processing
%                                step of dataset
%               'historymodel' - return history structure with field types
%                                as values
%                                short: 'hmodel'
%               'historycheck' - check given structure for compliance with
%                                the toolbox history record structure
%                                short: 'hcheck'
%
%   structure - struct
%               either empty trEPR toolbox data structure or 
%               trEPR toolbox data structure with field types as values
%
%               In case of a history record, data structure complying with
%               the history record data structure
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

% Copyright (c) 2011-15, Till Biskup
% 2015-05-30

% Version string of data structure
versionString = '1.13';

if ~nargin && ~nargout
    help trEPRdataStructure
    return;
end

% Create empty trEPR toolbox data structure
dataStructure = struct();
dataStructure.data = [];
% TODO: Needs to be changed into cell array of matrices
%       for handling multiple simulations in one dataset
dataStructure.calculated = [];
for axisIdx = 1:3
    dataStructure.axes.data(axisIdx) = axisStructureCreate;
    dataStructure.axes.origdata(axisIdx) = axisStructureCreate;
    dataStructure.axes.calculated(axisIdx) = axisStructureCreate;
end
% TODO: Needs to be changed into cell array of structs
%       for handling multiple simulations in one dataset
% Default values for direction (2 => 'y') and position (1) are helpful for
% backwards compatibility with older datasets containing simulations.
dataStructure.calculation = struct(...
    'direction',2, ...
    'position',1, ...
    'scaling',1 ...
    );
dataStructure.parameters = struct(...
    'runs',[],...
    'operator','',...
    'date',struct(...
        'start','',...
        'end',''...
        ),...
    'shotRepetitionRate',struct(...
        'value',[],...
        'unit',''...
        ),...
    'spectrometer',struct(...
        'name','', ...
        'software','' ...
        ), ...
    'field',struct(...
        'start',struct(...
            'value',[],...
            'unit',''...
            ),...
        'stop',struct(...
            'value',[],...
            'unit',''...
            ),...
        'step',struct(...
            'value',[],...
            'unit',''...
            ),...
        'sequence','',...
        'model','',...
        'powersupply','',...
        'calibration',struct(...
            'method','',...
            'model','',...
            'standard','',...
            'signalField',struct(...
                'value',[],...
                'unit',''...
                ),...
            'MWfrequency',struct(...
                'value',[],...
                'unit',''...
                ),...
            'deviation',struct(...
                'value',[],...
                'unit',''...
                ),...
            'start',struct(...
                'value',[],...
                'unit',''...
                ),...
            'end',struct(...
                'value',[],...
                'unit',''...
                ),...
            'gaussMeter',struct(...
                'values',[], ...
                'unit',''...
                )...
            )...
        ),...
    'background',struct(...
        'field',struct(...
            'value',[],...
            'unit',''...
            ),...
        'occurrence',[], ...
        'polarisation','' ...
        ), ...
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
        'pretrigger',struct(...
            'value',[],...
            'unit',''...
            ),...
        'model',''...
        ),...
    'transient',struct(...
        'points',[],...
        'triggerPosition',[],...
        'length',struct(...
            'value',[],...
            'unit',''...
            )...
        ),...
    'bridge',struct(...
        'MWfrequency',struct(...
            'value',[],...
            'values',[],...
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
            'start',struct(...
                'value',[],...
                'unit',''...
                ),...
            'end',struct(...
                'value',[],...
                'unit',''...
                ),...
            'model',''...
            ),...
        'power',struct(...
            'value',[],...
            'unit',''...
            ),...
        'model','',...
        'controller','',...
        'detection',''...
        ),...
    'probehead',struct(...
        'type','',...
        'model','',...
        'coupling',''...
        ),...
    'laser',struct(...
        'type','',...
        'model','',...
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
        'tunable',struct(...
            'type','',...
            'model','',...
            'dye','',...
            'position',[]...
            ),...
        'filter','' ...
        ),...
    'temperature',struct(...
        'value',[],...
        'unit','',...
        'model','',...
        'cryostat','',...
        'cryogen',''...
        )...
    );
dataStructure.parameters.purpose = cell(0);
dataStructure.sample = struct(...
    'name','',...
    'tube',''...
    );
dataStructure.sample.description = cell(0);
dataStructure.sample.buffer = cell(0);
dataStructure.sample.preparation = cell(0);
dataStructure.header = cell(0);
dataStructure.comment = cell(0);
dataStructure.history = cell(0);
dataStructure.info = struct();
dataStructure.file = struct(...
    'name','', ...
    'format','' ...
    );
dataStructure.display = struct( ...
    'position',struct( ...
        'calculated',[1 1],...
        'data',[1 1] ...
        ),...
    'displacement',struct( ...
        'calculated',[0 0 0],...
        'data',[0 0 0] ...
        ),...
    'scaling',struct(...
        'calculated',[1 1 1],...
        'data',[1 1 1] ...
        ),...
    'averaging',struct(...
        'calculated',[1 1],...
        'data',[1 1] ...
        ), ...
    'lines', struct(...
        'calculated',struct(...
            'color','r',...
            'style','-',...
            'marker',struct(...
                'type','none',...
                'edgeColor','auto',...
                'faceColor','none',...
                'size',6 ...
                ),...
            'width',1 ...
            ),...
        'data',struct(...
            'color','k',...
            'style','-',...
            'marker',struct(...
                'type','none',...
                'edgeColor','auto',...
                'faceColor','none',...
                'size',6 ...
                ),...
            'width',1 ...
            )...
        ),...
    'measure',struct(...
        'point',struct(...
            'index',[],...
            'unit',[] ...
            ) ...
        ) ...
    );

for axisIdx = 1:2
    dataStructure.display.smoothing.data(axisIdx) = ...
        smoothingStructureCreate;
    dataStructure.display.smoothing.calculated(axisIdx) = ...
        smoothingStructureCreate;
end

dataStructure.characteristics = struct(...
    'soi',struct(...
        'label','', ...
        'display',true, ...
        'parameters',struct(...
            'coordinates',[], ...
            'direction','', ...
            'avgWindow',1 ...
            ),...
        'line',struct(...
            'color','k',...
            'style','-',...
            'marker',struct(...
                'type','none',...
                'edgeColor','auto',...
                'faceColor','none',...
                'size',6 ...
                ),...
            'width',1 ...
            )...
        ), ...
    'poi',struct(...
        'label','', ...
        'parameters',struct(...
            'coordinates',[] ...
            ),...
        'marker',struct( ...
            'type','none', ...
            'edgeColor','auto', ...
            'faceColor','none', ...
            'size',6 ...
            ) ...
        ), ...
    'doi',struct(...
        'label','', ...
        'parameters',struct(...
            'coordinates',[], ...
            'distance',[] ...
            ),...
        'line',struct(...
            'color','k',...
            'style','-',...
            'marker',struct(...
                'type','none',...
                'edgeColor','auto',...
                'faceColor','none',...
                'size',6 ...
                ),...
            'width',1 ...
            )...
        ), ...
    'voi',struct( ...
        'label','', ...
        'parameters',struct(...
            'type','surf', ...
            'reduction',struct( ...
                'x',0, ... % Must be zero to identify empty voi structure
                'y',0 ...
                ), ...
            'offset',struct( ...
                'type','auto', ...
                'x',0, ...
                'y',0 ...
                ), ...
            'surface',struct( ...
                'edgeColor',[0.7 0.7 0.7], ...
                'meshStyle','row', ...
                'lineStyle','-' ...
                ), ...
            'view',struct( ...
                'azimuth',75, ...
                'elevation',15 ...
                ) ...
            ) ...
        ) ...
    );
dataStructure.characteristics.soi.comment = cell(0);
dataStructure.characteristics.poi.comment = cell(0);
dataStructure.characteristics.doi.comment = cell(0);
dataStructure.characteristics.voi.comment = cell(0);
dataStructure.label = '';
dataStructure.format = struct(...
    'name','trEPR toolbox', ...
    'version',versionString ...
    );

% Create trEPR toolbox data model (structure with field types as values)
dataModel = struct();
dataModel.data = 'ismatrix';
dataModel.calculated = 'ismatrix';
dataModel.axes = struct(...
    'data',struct(...
        'values','isvector', ...
        'measure','ischar', ...
        'unit','ischar' ...
        ),...
    'origdata',struct(...
        'values','isvector', ...
        'measure','ischar', ...
        'unit','ischar' ...
        ),...
    'calculated',struct(...
        'values','isvector', ...
        'measure','ischar', ...
        'unit','ischar' ...
        )...
    );
dataModel.calculation = struct(...
    'direction','isscalar', ...
    'position','isscalar', ...
    'scaling','isscalar' ...
    );
dataModel.parameters = struct(...
    'runs','isscalar',...
    'operator','ischar',...
    'date',struct(...
        'start','ischar',...
        'end','ischar'...
        ),...
    'purpose','@(x)iscell(x) || ischar(x)',...
    'shotRepetitionRate',struct(...
        'value','isscalar',...
        'unit','ischar'...
        ),...
    'spectrometer',struct(...
        'name','ischar', ...
        'software','ischar' ...
        ), ...
    'field',struct(...
        'start',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'stop',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'step',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'sequence','ischar',...
        'model','ischar',...
        'powersupply','ischar',...
        'calibration',struct(...
            'method','ischar',...
            'model','ischar',...
            'standard','ischar',...
            'signalField',struct(...
                'value','isscalar',...
                'unit','ischar'...
                ),...
            'MWfrequency',struct(...
                'value','isscalar',...
                'unit','ischar'...
                ),...
            'deviation',struct(...
                'value','isscalar',...
                'unit','ischar'...
                ),...
            'start',struct(...
                'value','isscalar',...
                'unit','ischar'...
                ),...
            'end',struct(...
                'value','isscalar',...
                'unit','ischar'...
                ),...
            'gaussMeter',struct(...
                'values','isnumeric', ...
                'unit','ischar'...
                ) ...
            )...
        ),...
    'background',struct(...
        'field',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'occurrence','isscalar', ...
        'polarisation','ischar' ...
        ), ...
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
        'pretrigger',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'model','ischar'...
        ),...
    'transient',struct(...
        'points','isscalar',...
        'triggerPosition','isscalar',...
        'length',struct(...
            'value','isscalar',...
            'unit','ischar'...
            )...
        ),...
    'bridge',struct(...
        'MWfrequency',struct(...
            'value','isscalar',...
            'values','isnumeric',...
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
            'start',struct(...
                'value','isscalar',...
                'unit','ischar'...
                ),...
            'end',struct(...
                'value','isscalar',...
                'unit','ischar'...
                ),...
            'model','ischar'...
            ),...
        'power',struct(...
            'value','isscalar',...
            'unit','ischar'...
            ),...
        'model','ischar',...
        'controller','ischar',...
        'detection','ischar'...
        ),...
    'probehead',struct(...
        'type','ischar',...
        'model','ischar',...
        'coupling','ischar'...
        ),...
    'laser',struct(...
        'type','ischar',...
        'model','ischar',...
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
        'tunable',struct(...
            'type','ischar',...
            'model','ischar',...
            'dye','ischar',...
            'position','isscalar'...
            ),...
        'filter','ischar' ...
        ),...
    'temperature',struct(...
        'value','isscalar',...
        'unit','ischar',...
        'model','ischar',...
        'cryostat','ischar',...
        'cryogen','ischar'...
        )...
    );
dataModel.sample = struct(...
    'name','ischar', ...
    'tube','ischar', ...
    'description','@(x)iscell(x) || ischar(x)', ...
    'buffer','@(x)iscell(x) || ischar(x)', ...
    'preparation','@(x)iscell(x) || ischar(x)' ...
    );
dataModel.header = 'iscell';
dataModel.comment = 'iscell';
dataModel.history = 'iscell';
dataModel.info = 'isstruct';
dataModel.file = struct(...
    'name','ischar', ...
    'format','ischar' ...
    );
dataModel.display = struct(...
    'position','isvector',...
    'displacement',struct(...
        'calculated','isvector',...
        'data','isvector'...
        ),...
    'scaling',struct(...
        'calculated','isvector',...
        'data','isvector'...
        ),...
    'smoothing',struct(...
        'calculated',struct(...
            'filterfun','ischar', ...
            'parameters',struct(...
                'width','isscalar', ...
                'order','isscalar', ...
                'deriv','isscalar' ...
                ) ...
            ),...
        'data',struct(...
            'filterfun','ischar', ...
            'parameters',struct(...
                'width','isscalar', ...
                'order','isscalar', ...
                'deriv','isscalar' ...
                ) ...
            )...
        ),...
    'averaging',struct(...
        'calculated','isvector',...
        'data','isvector'...
        ),...
    'lines',struct(...
        'calculated',struct(...
            'color','ischar',...
            'style','ischar',...
            'marker',struct(...
                'type','ischar',...
                'edgeColor','ischar',...
                'faceColor','ischar',...
                'size','isscalar' ...
                ),...
            'width','isscalar' ...
            ),...
        'data',struct(...
            'color','ischar',...
            'style','ischar',...
            'marker',struct(...
                'type','ischar',...
                'edgeColor','ischar',...
                'faceColor','ischar',...
                'size','isscalar' ...
                ),...
            'width','isscalar' ...
            ) ...
        ),...
    'measure',struct(...
        'point',struct(...
            'index','isvector',...
            'unit','isvector' ...
            ) ...
        ) ...
    );
dataModel.characteristics = struct(...
    'soi',struct(...
        'label','ischar', ...
        'display','islogical', ...
        'parameters',struct( ...
            'coordinates','isnumeric', ...
            'direction','ischar', ...
            'avgWindow','isnumeric' ...
            ), ...
        'line',struct(...
            'color','ischar',...
            'style','ischar',...
            'marker',struct(...
                'type','ischar',...
                'edgeColor','ischar',...
                'faceColor','ischar',...
                'size','isscalar' ...
                ),...
            'width','isscalar' ...
            ) ...
        ), ...
    'poi',struct(...
        'label','ischar', ...
        'parameters',struct( ...
            'coordinates','isnumeric' ...
            ), ...
        'marker',struct( ...
            'type','ischar', ...
            'edgeColor','ischar', ...
            'faceColor','ischar', ...
            'size','isscalar' ...
            ) ...
        ), ...
    'doi',struct(...
        'label','ischar', ...
        'parameters',struct( ...
            'coordinates','isnumeric', ...
            'distance','isnumeric' ...
            ), ...
        'line',struct(...
            'color','ischar',...
            'style','ischar',...
            'marker',struct(...
                'type','ischar',...
                'edgeColor','ischar',...
                'faceColor','ischar',...
                'size','isscalar' ...
                ),...
            'width','isscalar' ...
            ) ...
        ), ...
    'voi',struct( ...
        'label','ischar', ...
        'parameters',struct( ...
            'reduction',struct( ...
                'x','isscalar', ...
                'y','isscalar' ...
                ), ...
            'offset',struct( ...
                'type','ischar', ...
                'x','isscalar', ...
                'y','isscalar' ...
                ), ...
            'surface',struct( ...
                'edgeColor','isvector', ...
                'meshStyle','ischar', ...
                'lineStyle','ischar' ...
                ), ...
            'view',struct( ...
                'azimuth','isscalar', ...
                'elevation','isscalar' ...
                ) ...
            ) ...
        ) ...
    );
dataModel.characteristics.soi.comment = 'iscell';
dataModel.characteristics.poi.comment = 'iscell';
dataModel.characteristics.doi.comment = 'iscell';
dataModel.characteristics.voi.comment = 'iscell';
dataModel.label = 'ischar';
dataModel.format = struct(...
    'name','ischar', ...
    'version','ischar' ...
    );

% Create history record
historyStructure = struct(...
    'date',datestr(now,31),...
    'method','',...
    'system',struct(...
        'username','',...
        'platform',deblank(platform),...
        'matlab',version,...
        'trEPR',trEPRinfo('version')...
        ),...
    'parameters',struct(...
        ),...
    'info',struct(...
        )...
    );
% Get username of current user
% In worst case, username is an empty string. So nothing should really rely
% on it.
% Windows style
historyStructure.system.username = getenv('UserName');
% Unix style
if isempty(historyStructure.system.username)
    historyStructure.system.username = getenv('USER'); 
end

% Create history record data model (structure with field types as values)
historyModel = struct(...
    'date','ischar',...
    'method','ischar',...
    'system',struct(...
        'username','ischar',...
        'platform','ischar',...
        'matlab','ischar',...
        'trEPR','ischar'...
        ),...
    'parameters','isstruct',...
    'info','isstruct'...
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
            end
            if isempty(missingFields) && isempty(wrongType)
                if nargin == 3 && ~strcmpi(varargin{3},'quiet')
                    fprintf('Basic test passed! Structure seems fine...\n');
                end
            end
            
            varargout{1} = missingFields;
            varargout{2} = wrongType;
            
        case {'history','historystructure','hstructure'}
            if nargout
                varargout{1} = historyStructure;
            end
        case {'historymodel','hmodel'}
            if nargout
                varargout{1} = historyModel;
            end
        case {'historycheck','hcheck'}
            if nargin < 2
                fprintf('No structure to check...\n');
                return;
            end
            if ~isstruct(varargin{2})
                fprintf('%s has wrong type',inputname(2));
                return;
            end
            
            [missingFields,wrongType] = ...
                checkStructure(historyModel,varargin{2},inputname(2));

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
            end
            if isempty(missingFields) && isempty(wrongType)
                if nargin == 3 && ~strcmpi(varargin{3},'quiet')
                    fprintf('Basic test passed! Structure seems fine...\n');
                end
            end
            
            varargout{1} = missingFields;
            varargout{2} = wrongType;
            
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

function [missingFields,wrongType] = checkStructure(model,structure,name)
missingFields = cell(0);
wrongType = cell(0);
    function traverse(model,structure,parent)
        modelFieldNames = fieldnames(model);
        for k=1:length(modelFieldNames)
            if ~isfield(structure,modelFieldNames{k})
                missingFields{end+1} = ...
                    sprintf('%s.%s',parent,modelFieldNames{k}); %#ok<AGROW>
            else
                for idx = 1:length(structure)
                    if isstruct(model.(modelFieldNames{k}))
                        if ~isstruct(structure(idx).(modelFieldNames{k}))
                            wrongType{end+1} = ...
                                sprintf('%s.%s',parent,modelFieldNames{k}); %#ok<AGROW>
                        end
                        traverse(...
                            model.(modelFieldNames{k}),...
                            structure(idx).(modelFieldNames{k}),...
                            [parent '.' modelFieldNames{k}]...
                            );
                    else
                        functionHandle = str2func(model.(modelFieldNames{k}));
                        if ~functionHandle(structure(idx).(modelFieldNames{k}))
                            if strcmp(model.(modelFieldNames{k}),'isscalar') || ...
                                    strcmp(model.(modelFieldNames{k}),'isvector')
                                if isnumeric(structure(idx).(modelFieldNames{k})) && ...
                                        isempty(structure(idx).(modelFieldNames{k}))
                                    return;
                                end
                            end
                            wrongType{end+1} = ...
                                sprintf('%s.%s',parent,modelFieldNames{k}); %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
traverse(model,structure,name);
end

function axisStruct = axisStructureCreate

axisStruct = struct(...
    'values',[],...
    'measure','',...
    'unit','' ...
    );

end

function smoothingStruct = smoothingStructureCreate

smoothingStruct = struct( ...
    'filterfun','', ...
    'parameters',struct(...
        'width',0, ...
        'order',2, ...
        'deriv',0 ...
        ) ...
    );
end