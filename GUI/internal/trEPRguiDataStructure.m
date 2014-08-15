function varargout = trEPRguiDataStructure(varargin)
% TREPRGUIDATASTRUCTURE Return data structure for trEPR toolbox data, or
% test compliance of given structure with the data structure of the
% toolbox.
%
% Usage
%   structure = trEPRguiDataStructure;
%   structure = trEPRguiDataStructure(<command>)
%   [missingFields,wrongType] = trEPRguiDataStructure(<command>,structure)
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

% Copyright (c) 2011-14, Till Biskup
% 2014-08-15

% Version string of appdata
versionString = '1.12';

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
            'setslider',1, ...
            'setcharacteristics',1 ...
            )...
        ),...
    'control',struct(...
        'measure',struct(...
            'point',0,...
            'nPoints',0,...
            'setslider',1, ...
            'setcharacteristics',1 ...
            ),...
        'data',struct(...
            'invisible',[],...
            'visible',[],...
            'modified',[],...
            'missing',[],...
            'active',0, ...
            'temporary',struct(...
                'visible',false,...
                'function','',...
                'parameters',struct() ...
                ) ...
            ),...
        'axis',struct(...
            'displayType','2D plot',...
            'grid',struct(...
                'x','off',...
                'y','off',...
                'minor','off',...
                'zero',struct(...
                    'visible',true,...
                    'color',[0.5 0.5 0.5],...
                    'width',1,...
                    'style','--'...
                    )...
                ),...
            'highlight',struct(...
                'method','color',...
                'value','b'...
                ),...
            'legend',struct(...
                'handle',[],...
                'location','none',...
                'box',true,...
                'FontName','Helvetica',...
                'FontWeight','normal',...
                'FontAngle','normal',...
                'FontSize',12 ...
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
            'normalisation',struct(...
                'enable',false, ...
                'dimension','2D',...
                'type','pkpk' ...
                ),...
            'stdev',false, ...
            'onlyActive',false, ...
            'characteristics',false, ...
            'BGpositions',struct(...
                'enable',false, ...
                'shift',0),...
            'zoom',struct(...
                'enable',false, ...
                'x',[0 0], ...
                'y',[0 0], ...
                'z',[0 0] ...
                ), ...
            'sim',false, ...
            'colormap',struct(...
                'symmetric',false, ...
                'individual',true, ...
                'colorbar',false ...
                ), ...
            'lines', struct(...
                'temporary',struct(...
                    'color','r',...
                    'style','-',...
                    'marker',struct(...
                        'type','none',...
                        'edgeColor','auto',...
                        'faceColor','none',...
                        'size',6 ...
                        ),...
                    'width',1 ...
                    ) ...
                ), ...
            'vis3d',struct(...
                'type','surf', ...
                'reduction',struct( ...
                    'x',1, ...
                    'y',1 ...
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
            ),...
        'system',struct(...
            'username','',...
            'platform',deblank(platform),...
            'matlab',version,...
            'trEPR',trEPRinfo('version')...
            ),...
        'dirs',struct(...
            'lastLoad','', ...
            'lastSave','', ...
            'lastFigSave','', ...
            'lastExport','', ...
            'lastSnapshot','', ...
            'lastScript','' ...
            ),...
        'messages',struct(...
            'debug',struct(...
                'level','all' ...
                ),...
            'display',struct(...
                'level','all' ...
                ) ...
            ),...
        'mode','None',...
        'panels',struct(...
            'active','load',...
            'load',struct(...
                'fileType',1,...
                'fileTypes',struct(...
                    'name','Automatic',...
                    'extensions','*.*',...
                    'loadFunction','trEPRload',...
                    'combine',false,...
                    'loadDir',false,...
                    'loadInfoFile',false,...
                    'POC',false,...
                    'BGC',false,...
                    'determineAxisLabels',true,...
                    'visibleUponLoad',true,...
                    'convertUnits',false ...
                    )...
                ),...
            'datasets',struct(),...
            'slider',struct(),...
            'measure',struct(),...
            'display',struct(),...
            'processing',struct(),...
            'analysis',struct(),...
            'internal',struct(),...
            'configure',struct() ...
            ),...
        'cmd',struct(...
            'historypos',0, ...
            'historysave',false, ...
            'historyfile','', ...
            'variables',struct() ...
            )...
        ),...
    'format',struct(...
        'name','trEPR toolbox',...
        'version',versionString ...
        )...
    );
guiAppdataStructure.data = cell(0);
guiAppdataStructure.origdata = cell(0);
guiAppdataStructure.control.status = cell(0);
guiAppdataStructure.control.data.temporary.datasets = cell(0);
guiAppdataStructure.control.cmd.history = cell(0);
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
            'setslider','islogical', ...
            'setcharacteristics','islogical' ...
            )...
        ),...
    'control',struct(...
        'measure',struct(...
            'point','isscalar',...
            'nPoints','isscalar',...
            'setslider','islogical', ...
            'setcharacteristics','islogical' ...
            ),...
        'data',struct(...
            'invisible','isscalar',...
            'visible','isscalar',...
            'modified','isscalar',...
            'missing','isscalar',...
            'active','isscalar', ...
            'temporary',struct(...
                'visible','islogical',...
                'function','ischar',...
                'datasets','iscell',...
                'parameters','isstruct' ...
                ) ...
            ),...
        'axis',struct(...
            'displayType','ischar',...
            'grid',struct(...
                'x','ischar',...
                'y','ischar',...
                'minor','ischar',...
                'zero',struct(...
                    'visible','islogical',...
                    'color','isnumeric',...
                    'width','isnumeric',...
                    'style','ischar'...
                    )...
                ),...
            'highlight',struct(...
                'method','ischar',...
                'value','ischar'...
                ),...
            'legend',struct(...
                'handle','isscalar',...
                'location','ischar',...
                'box','islogical',...
                'FontName','ischar',...
                'FontWeight','ischar',...
                'FontAngle','ischar',...
                'FontSize','isscalar'...
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
            'normalisation',struct(...
                'enable','islogical', ...
                'dimension','ischar',...
                'type','ischar' ...
                ), ...
            'stdev','islogical', ...
            'onlyActive','islogical', ...
            'characteristics','islogical', ...
            'BGpositions',struct(...
                'enable','islogical', ...
                'shift','isscalar'),...
            'zoom',struct(...
                'enable','islogical', ...
                'x','isnumeric', ...
                'y','isnumeric', ...
                'z','isnumeric' ...
                ), ...
            'sim','islogical', ...
            'colormap',struct(...
                'symmetric','islogical', ...
                'individual','islogical', ...
                'colorbar','islogical' ...
                ), ...
            'lines', struct(...
                'temporary',struct(...
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
            'vis3d',struct( ...
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
            ),...
        'system',struct(...
            'username','ischar',...
            'platform','ischar',...
            'matlab','ischar',...
            'trEPR','ischar'...
            ),...
        'dirs',struct(...
            'lastLoad','ischar', ...
            'lastSave','ischar', ...
            'lastFigSave','ischar', ...
            'lastExport','ischar', ...
            'lastSnapshot','ischar', ...
            'lastScript','ischar' ...
            ),...
        'messages',struct(...
            'debug',struct(...
                'level','ischar' ...
                ),...
            'display',struct(...
                'level','ischar' ...
                ) ...
            ),...
        'mode','ischar',...
        'panels',struct(...
            'active','ischar',...
            'load',struct(...
                'fileType','isscalar',...
                'fileTypes',struct(...
                    'name','ischar',...
                    'extensions','ischar',...
                    'loadFunction','ischar',...
                    'combine','islogical',...
                    'loadDir','islogical',...
                    'loadInfoFile','islogical',...
                    'POC','islogical',...
                    'BGC','islogical',...
                    'determineAxisLabels','islogical',...
                    'visibleUponLoad','islogical',...
                    'convertUnits','islogical' ...
                    ) ...
                ), ...
            'datasets','isstruct',...
            'slider','isstruct',...
            'measure','isstruct',...
            'display','isstruct',...
            'processing','isstruct',...
            'analysis','isstruct',...
            'internal','isstruct',...
            'configure','isstruct' ...
            ),...
        'cmd',struct(...
            'historypos','isnumeric', ...
            'historysave','islogical', ...
            'historyfile','ischar', ...
            'variables','isstruct' ...
            )...
        ),...
    'format',struct(...
        'name','ischar',...
        'version','ischar' ...
        )...
    );
guiAppdataModel.data = cell(0);
guiAppdataModel.origdata = cell(0);
guiAppdataModel.control.status = cell(0);
guiAppdataModel.control.cmd.history = cell(0);

if nargin && ischar(varargin{1})
    switch lower(varargin{1})
        case {'structure','guiappdatastructure'}
            if nargout
                varargout{1} = guiAppdataStructure;
            end
        case {'model','guiappdatamodel'}
            if nargout
                varargout{1} = guiAppdataModel;
            end
        case {'check','datacheck'}
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
        varargout{1} = guiAppdataStructure;
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

