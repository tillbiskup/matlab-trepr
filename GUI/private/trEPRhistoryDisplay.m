function display = trEPRhistoryDisplay(history)
% TREPRHISTORYDISPLAY Take a history structure of a trEPR toolbox dataset
% and transform the parameters in a format that can be nicely read and
% displayed.
%
% history - struct 
%           parameter structure of a trEPR toolbox dataset history entry
%
% display - cell array
%           human readable formatting of the parameters of the performed
%           action described in the given history struct

% Copyright (c) 2011-14, Till Biskup
% 2014-07-12

try
    display = cell(0);
    switch history.method
        case 'trEPRPOC'
            display{end+1} = sprintf('triggerPosition: %i',...
                history.parameters.triggerPosition);
        case 'trEPRBGC'
            display{end+1} = sprintf('numBGprofiles: %i %i',...
                history.parameters.numBGprofiles);
        case 'trEPRACC'
            display{end+1} = sprintf('master:        %i',...
                history.parameters.master);
            display{end+1} = sprintf('method:        ''%s''',...
                history.parameters.method);
            display{end+1} = 'weights:';
            display{end+1} = sprintf('          min: %f',...
                history.parameters.weights.min);
            display{end+1} = sprintf('          max: %f',...
                history.parameters.weights.max);
            display{end+1} = 'noise:';
            display{end+1} = '       x:';
            display{end+1} = sprintf('          min: %i',...
                history.parameters.noise.x.min);
            display{end+1} = sprintf('          max: %i',...
                history.parameters.noise.x.max);
            display{end+1} = '       y:';
            display{end+1} = sprintf('          min: %i',...
                history.parameters.noise.y.min);
            display{end+1} = sprintf('          max: %i',...
                history.parameters.noise.y.max);
            display{end+1} = sprintf('interpolation: ''%s''',...
                history.parameters.interpolation);
            display{end+1} = sprintf('label:         ''%s''',...
                history.parameters.label);
            display{end+1} = sprintf('\nDATASETS');
            for k = 1:length(history.parameters.datasets)
                display{end+1} = sprintf('\nDataset no. %i\n',k);
                display{end+1} = sprintf('label:         ''%s''',...
                    history.parameters.datasets{k}.label);
                display{end+1} = sprintf('filename:      ''%s''',...
                    history.parameters.datasets{k}.filename);
                display{end+1} = 'history:';
                if ~isempty(history.parameters.datasets{k}.history)
                    for l=1:length(history.parameters.datasets{k}.history)
                        display{end+1} = sprintf('       method: %s',...
                            history.parameters.datasets{k}.history{l}.method);
                        display{end+1} = sprintf('         date: %s',...
                            history.parameters.datasets{k}.history{l}.date);
                    end
                end
            end
        case 'trEPRAVG'
            display{end+1} = sprintf('dimension: ''%c''',...
                history.parameters.dimension);
            display{end+1} = sprintf('start:     %i (%i %s)',...
                history.parameters.start.index,...
                history.parameters.start.value,...
                history.parameters.start.unit);
            display{end+1} = sprintf('stop:      %i (%i %s)',...
                history.parameters.stop.index,...
                history.parameters.stop.value,...
                history.parameters.stop.unit);
            display{end+1} = sprintf('label:     ''%s''',...
                history.parameters.label);
        case 'trEPRBLC'
        otherwise
            % Get fieldnames of parameters
            paramFieldNames = fieldnames(history.parameters);
            if isempty(paramFieldNames)
                display{end+1} = 'No parameters to display currently';
            else
                for param = 1:length(paramFieldNames)
                    display{end+1} = sprintf('%s: %s',...
                        paramFieldNames{param},...
                        num2str(history.parameters.(paramFieldNames{param}))); %#ok<AGROW>
                end
            end
    end
catch exception
    throw(exception);
end

end
