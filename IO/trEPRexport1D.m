% TREPREXPORT1D Export 1D cross sections of 2D dataset
%
% Usage
%   trEPRexport1D(data,fileName,parameters);
%   status = trEPRexport1D(data,fileName,parameters);
%
% data       - struct
%              data to plot
%              The actual data are in the field 'data', as the data struct
%              is assumed to originate from the trEPR toolbox and the
%              respective importer (trEPRload) function.
% fileName   - string
%              Name of the file the figure should be saved to
%              Should at least be a filename with extension
% parameters - struct
%              parameters controlling the position and direction of the
%              cross section as well as other settings
%
% status     - string
%              Empty string if everything is fine
%              Otherwise it contains an error description
%

% Copyright (c) 2011-15, Till Biskup
% 2015-06-11

function status = trEPRexport1D(data,fileName,parameters)

try
    % Check whether we have data
    if ~isfield(data,'data') || isempty(data.data)
        status = 'No data';
        return;
    end
    
    % Check whether we have a file name
    if isempty(fileName) || ~ischar(fileName)
        status = 'No valid file name';
        return;
    end
    
    % Check for absolutely essential parameters
    if ~isfield(parameters,'crosssection') ...
            || ~isfield(parameters.crosssection,'direction') ...
            || ~isfield(parameters.crosssection,'position')
        status = 'Not enough parameters (cross section)';
        return;
    end
    
    % Check for nonsensical parameters
    if ~isnumeric(parameters.crosssection.position) ...
            || (parameters.crosssection.position < 1)
        status = 'Cross section position parameter nonsensical';
        return;
    end
    
    % If parameters are incomplete, set default values for missing
    if ~isfield(parameters,'header') ...
            || ~isfield(parameters.header,'character')
        parameters.header.character = '%';
    end
    if ~isfield(parameters,'axis') ...
            || ~isfield(parameters.axis,'include')
        parameters.axis.include = 1;
    end
    if ~isfield(parameters,'stdev') ...
            || ~isfield(parameters.stdev,'include')
        parameters.stdev.include = 0;
    end
    if ~isfield(parameters,'calculated') ...
            || ~isfield(parameters.calculated,'include')
        parameters.calculated.include = 0;
    end
    if ~isfield(parameters,'file') || ~isfield(parameters.file,'type')
        parameters.file.type = 'ASCII';
    end
    if ~isfield(parameters,'file') || ~isfield(parameters.file,'overwrite')
        parameters.file.overwrite = 0;
    end
    
    % Check whether file of given file name exists already and overwrite is
    % set to false
    if exist(fileName,'file') && ~parameters.file.overwrite
        status = sprintf('%s %s %s',...
            'Filename',fileName,...
            'exists already and overwrite is set to false.');
        return;
    end

    
    % Get dimensions of dataset
    [dimy,dimx] = size(data.data);
    
    % Get cross section and axis, depending on direction
    switch lower(parameters.crosssection.direction)
        case 'x'
            % Check whether position parameter is within dataset dimensions
            if parameters.crosssection.position > dimy
                status = sprintf('%s %s',...
                    'Cross section position parameter exceeds ',...
                    'dimensions of dataset');
                return;
            end
            crosssection = data.data(parameters.crosssection.position,:)';
            if ~isfield(data,'axes') || ~isfield(data.axes,'data') ... 
                    || ~isfield(data.axes.data(1),'values')
                axis = 1:dimx;
            else
                axis = data.axes.data(1).values';
            end
        case 'y'
            % Check whether position parameter is within dataset dimensions
            if parameters.crosssection.position > dimx
                status = sprintf('%s %s',...
                    'Cross section position parameter exceeds ',...
                    'dimensions of dataset');
                return;
            end
            crosssection = data.data(:,parameters.crosssection.position);
            if ~isfield(data,'axes') || ~isfield(data.axes,'data') ... 
                    || ~isfield(data.axes.data(2),'values')
                axis = 1:dimy;
            else
                axis = data.axes.data(2).values';
            end
        otherwise
            % That shall normally not happen...
            status = sprintf('Unknown direction of cross section: %s',...
                parameters.crosssection.direction);
            return;
    end
    
    % Perform all (temporary) operations such as displacement, scaling,
    % smoothing
    if isfield(data,'display')
        
        % Displacement
        if isfield(data.display,'displacement')
            if isfield(data.display.displacement,'z')
                crosssection = crosssection + data.display.displacement.z;
            end
            if strcmpi(parameters.crosssection.direction,'x') ...
                    && isfield(data.display.displacement,'x')
                axis = axis + data.display.displacement.x;
            end
            if strcmpi(parameters.crosssection.direction,'y') ...
                    && isfield(data.display.displacement,'y')
                axis = axis + data.display.displacement.y;
            end
        end
        
        % Scaling
        if isfield(data.display,'scaling')
            if isfield(data.display.scaling,'z')
                crosssection = crosssection * data.display.scaling.z;
            end
            if strcmpi(parameters.crosssection.direction,'x') ...
                    && isfield(data.display.scaling,'x')
                axis = linspace(...
                    (((axis(end)-axis(1))/2)+axis(1))-((axis(end)-axis(1))*data.display.scaling.x/2),...
                    (((axis(end)-axis(1))/2)+axis(1))+((axis(end)-axis(1))*data.display.scaling.x/2),...
                    length(axis));
            end
            if strcmpi(parameters.crosssection.direction,'y') ...
                    && isfield(data.display.scaling,'y')
                axis = linspace(...
                    (((axis(end)-axis(1))/2)+axis(1))-((axis(end)-axis(1))*data.display.scaling.y/2),...
                    (((axis(end)-axis(1))/2)+axis(1))+((axis(end)-axis(1))*data.display.scaling.y/2),...
                    length(axis));
            end            
        end
        
        disp('!')
        
        % Smoothing
        if isfield(data.display,'smoothing')
            if strcmpi(parameters.crosssection.direction,'x') ...
                    && (data.display.smoothing.data(1).parameters.width > 1)
                data = trEPRdatasetApplySmoothing(data);
            end
            if strcmpi(parameters.crosssection.direction,'y') ...
                    && (data.display.smoothing.data(2).parameters.width > 1)
                data = trEPRdatasetApplySmoothing(data);
            end
        end
    end
    
    % TODO: Generate header
    header = {};
    header{end+1} = sprintf('%s %s%s',parameters.header.character,...
        'Generated with: ',mfilename);
    
    % Save to file
    switch lower(parameters.file.type)
        case 'ascii'
            [fid,message] = fopen(fileName,'w+');
            if message
                status = message;
                return;
            end
            for k=1:length(header)
                fprintf(fid,'%s\n',header{k});
            end
            if parameters.axis.include && parameters.stdev.include && ...
                    isfield(data,'avg') && isfield(data.avg,'stdev') && ...
                    parameters.calculated.include && ~isempty(data.calculated)
                for l=1:length(crosssection)
                    fprintf(fid,'%20.12f %20.12f %20.12f %20.12f\n',...
                        axis(l),crosssection(l),data.avg.stdev(l),...
                        data.calculated(l));
                end
            elseif parameters.axis.include && parameters.stdev.include && ...
                    isfield(data,'avg') && isfield(data.avg,'stdev')
                for l=1:length(crosssection)
                    fprintf(fid,'%20.12f %20.12f %20.12f\n',axis(l),...
                        crosssection(l),data.avg.stdev(l));
                end
            elseif parameters.axis.include && parameters.calculated.include && ...
                    ~isempty(data.calculated)
                for l=1:length(crosssection)
                    fprintf(fid,'%20.12f %20.12f %20.12f\n',axis(l),...
                        crosssection(l),data.calculated(l));
                end
            elseif parameters.axis.include
                for l=1:length(crosssection)
                    fprintf(fid,'%20.12f %20.12f\n',axis(l),crosssection(l));
                end
            elseif parameters.stdev.include && ...
                    isfield(data,'avg') && isfield(data.avg,'stdev')
                for l=1:length(crosssection)
                    fprintf(fid,'%20.12f %20.12f\n',...
                        crosssection(l),data.avg.stdev(l));
                end
            elseif parameters.calculated.include && ~isempty(data.calculated)
                for l=1:length(crosssection)
                    fprintf(fid,'%20.12f %20.12f\n',...
                        crosssection(l),data.calculated(l));
                end
            else
                for l=1:length(crosssection)
                    fprintf(fid,'%20.12f\n',crosssection(l));
                end
            end
            fclose(fid);
        otherwise
            % Handle not supported file types
            status = sprintf('File type %s (currently) not supported',...
                parameters.file.type);
            return;
    end
    
    % Finally, set status to empty string
    status = '';
catch exception
    throw(exception);
end

end
