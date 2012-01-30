function varargout = guiDataStructure(varargin)
% GUIDATASTRUCTURE Return data structure for trEPR toolbox data, or test
% compliance of given structure with the data structure of the toolbox.
%
% Usage
%   structure = guiDataStructure;
%   structure = guiDataStructure(<command>)
%   [missingFields,wrongType] = guiDataStructure(<command>,structure)
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
% See also TREPRDATASTRUCTURE.

% (c) 2011-12, Till Biskup
% 2012-01-30

% Create empty trEPR toolbox data structure
%-%guiDataStructure = trEPRdataStructure('structure');
% Add GUI-specific fields with default values
guiDataStructure.display = struct(...
    'position',struct(...
        'x',1,...
        'y',1 ...
        ),...
    'displacement',struct(...
        'x',0,...
        'y',0,...
        'z',0 ...
        ),...
    'scaling',struct(...
        'x',1,...
        'y',1,...
        'z',1 ...
        ),...
    'smoothing',struct(...
        'x',struct(...
            'value',1, ...
            'filterfun','' ...
            ),...
        'y',struct(...
            'value',1, ...
            'filterfun','' ...
            ) ...
        ),...
    'averaging',struct(...
        'x',1,...
        'y',1 ...
        )...
    );
guiDataStructure.history = cell(0);
guiDataStructure.line = struct(...
    'color','k',...
    'style','-',...
    'marker','none',...
    'width',1 ...
    );

% Create trEPR toolbox data model (structure with field types as values)
%-%guiDataModel = trEPRdataStructure('model');
% Add GUI-specific fields
guiDataModel.display = struct(...
    'position',struct(...
        'x','isscalar',...
        'y','isscalar' ...
        ),...
    'displacement',struct(...
        'x','isscalar',...
        'y','isscalar',...
        'z','isscalar' ...
        ),...
    'scaling',struct(...
        'x','isscalar',...
        'y','isscalar',...
        'z','isscalar' ...
        ),...
    'smoothing',struct(...
        'x',struct(...
            'value','isscalar', ...
            'filterfun','ischar' ...
            ),...
        'y',struct(...
            'value','isscalar', ...
            'filterfun','ischar' ...
            ) ...
        ),...
    'averaging',struct(...
        'x','isscalar',...
        'y','isscalar' ...
        )...
    );
guiDataModel.history = cell(0);
guiDataModel.line = struct(...
    'color','ischar',...
    'style','ischar',...
    'marker','ischar',...
    'width','isscalar' ...
    );

% Create GUI appdata structure
guiAppdataStructure = struct(...
    'configuration',struct(...
        'display',struct(...
            'highlight',struct(...
                'method','color',...
                'value','b'...
                ),...
            'labels',struct(...
                'x',struct(...
                    'measure','index',...
                    'unit','points'...
                    ),...
                'y',struct(...
                    'measure','index',...
                    'unit','points'...
                    ),...
                'z',struct(...
                    'measure','index',...
                    'unit','points'...
                    )...
                )...
            ),...
        'measure',struct(...
            'setslider',1 ...
            )...
        ),...
    'control',struct(...
        'measure',struct(...
            'point',0,...
            'nPoints',0,...
            'setslider',1 ...
            ),...
        'spectra',struct(...
            'invisible',[],...
            'visible',[],...
            'modified',[],...
            'missing',[],...
            'active',0 ...
            ),...
        'axis',struct(...
            'displayType','2D plot',...
            'grid',struct(...
                'x','off',...
                'y','off',...
                'minor','off',...
                'zero',true...
                ),...
            'highlight',struct(...
                'method','color',...
                'value','b'...
                ),...
            'legend',struct(...
                'location','none'...
                ),...
            'labels',struct(...
                'x',struct(...
                    'measure','index',...
                    'unit','points'...
                    ),...
                'y',struct(...
                    'measure','index',...
                    'unit','points'...
                    ),...
                'z',struct(...
                    'measure','index',...
                    'unit','points'...
                    )...
                ),...
            'limits',struct(...
                'x',struct(...
                    'min',0,...
                    'max',1 ...
                    ),...
                'y',struct(...
                    'min',0,...
                    'max',1 ...
                    ),...
                'z',struct(...
                    'min',-0,...
                    'max',1 ...
                    ),...
                'auto',true ...
                ),...
            'normalisation','none', ...
            'stdev',false ...
            ),...
        'system',struct(...
            'username','',...
            'platform',deblank(platform),...
            'matlab',version,...
            'trEPR',trEPRinfo('version')...
            ),...
        'lastLoadDir','' ...
        )...
    );
guiAppdataStructure.control.status = cell(0);
guiAppdataStructure.data = cell(0);
guiAppdataStructure.origdata = cell(0);
% Get username of current user
% In worst case, username is an empty string. So nothing should really rely
% on it.
% Windows style
guiAppdataStructure.control.system.username = getenv('UserName');
% Unix style
if isempty(guiAppdataStructure.control.system.username)
    guiAppdataStructure.control.system.username = getenv('USER'); 
end

% Create GUI appdata model
guiAppdataModel = struct(...
    'configuration',struct(...
        'display',struct(...
            'highlight',struct(...
                'method','ischar',...
                'value','ischar'...
                ),...
            'labels',struct(...
                'x',struct(...
                    'measure','ischar',...
                    'unit','ischar'...
                    ),...
                'y',struct(...
                    'measure','ischar',...
                    'unit','ischar'...
                    ),...
                'z',struct(...
                    'measure','ischar',...
                    'unit','ischar'...
                    )...
                )...
            ),...
        'measure',struct(...
            'setslider','isscalar' ...
            )...
        ),...
    'control',struct(...
        'measure',struct(...
            'point','isscalar',...
            'nPoints','isscalar',...
            'setslider','isscalar' ...
            ),...
        'spectra',struct(...
            'invisible','isscalar',...
            'visible','isscalar',...
            'modified','isscalar',...
            'missing','isscalar',...
            'active','isscalar' ...
            ),...
        'axis',struct(...
            'displayType','ischar',...
            'grid',struct(...
                'x','ischar',...
                'y','ischar',...
                'minor','ischar',...
                'zero','islogical'...
                ),...
            'highlight',struct(...
                'method','ischar',...
                'value','ischar'...
                ),...
            'legend',struct(...
                'location','ischar'...
                ),...
            'labels',struct(...
                'x',struct(...
                    'measure','ischar',...
                    'unit','ischar'...
                    ),...
                'y',struct(...
                    'measure','ischar',...
                    'unit','ischar'...
                    ),...
                'z',struct(...
                    'measure','ischar',...
                    'unit','ischar'...
                    )...
                ),...
            'limits',struct(...
                'x',struct(...
                    'min','isscalar',...
                    'max','isscalar' ...
                    ),...
                'y',struct(...
                    'min','isscalar',...
                    'max','isscalar' ...
                    ),...
                'z',struct(...
                    'min','isscalar',...
                    'max','isscalar' ...
                    ),...
                'auto','islogical'...
                ),...
            'normalisation','ischar', ...
            'stdev','islogical' ...
            ),...
        'system',struct(...
            'username','ischar',...
            'platform','ischar',...
            'matlab','ischar',...
            'trEPR','ischar'...
            ),...
        'lastLoadDir','' ...
        )...
    );
guiAppdataModel.data = cell(0);
guiAppdataModel.origdata = cell(0);

if nargin && ischar(varargin{1})
    switch lower(varargin{1})
        case 'datastructure'
            if nargout
                varargout{1} = guiDataStructure;
            end
        case 'datamodel'
            if nargout
                varargout{1} = guiDataModel;
            end
        case 'guiappdatastructure'
            if nargout
                varargout{1} = guiAppdataStructure;
            end
        case 'guiappdatamodel'
            if nargout
                varargout{1} = guiAppdataModel;
            end
        case 'datacheck'
            if nargin < 2
                fprintf('No structure to check...\n');
                return;
            end
            if ~isstruct(varargin{2})
                fprintf('%s has wrong type',inputname(2));
                return;
            end
            
            [missingFields,wrongType] = ...
                checkStructure(guiDataModel,varargin{2},inputname(2));

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
            varargout{1} = [];
            return;
    end
else
    if nargout
        varargout{1} = guiDataStructure;
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

