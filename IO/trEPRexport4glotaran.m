function status = trEPRexport4glotaran(dataset,filename,varargin)
% TREPREXPORT4GLOTARAN exports a dataset in a format glotaran can read.
%
% Usage
%   trEPRexport4glotaran(dataset)
%
%   dataset - struct
%             dataset in TA toolbox format
%

% Original file: glotaran.m
% Copyright (c) 2011, Bernd Paulus

% Copyright (c) 2011-12, Till Biskup
% 2012-06-10

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
% Add required input argument "dataset"
p.addRequired('dataset', @(x)isstruct(x));
p.addRequired('filename', @(x)ischar(x));
% Add a few optional parameters, with default values
%p.addParamValue('verbose',logical(true),@islogical);
% Parse input arguments
p.parse(dataset,filename,varargin{:});

status = '';

if isempty(filename)
    return;
end

try
    header{1} = dataset.label;
    header{2} = datestr(now);
    header{3} = 'wavelength explicit';
    header{4} = sprintf('Intervalnr %s',int2str(size(dataset.data,1)));
    
    % Write header to output file
    dlmwrite(filename,header{1},'delimiter','');
    for k=2:length(header)
        dlmwrite(filename,header{k},'delimiter','','-append');
    end
    
    % Write data to output file
    % Write column headers
    dlmwrite (filename,dataset.axes.y.values,...
        'delimiter','\t','-append','coffset',1);
    % Add row headers to data
    matrix(:,1) = dataset.axes.x.values;
    matrix(:,2:size(dataset.data,1)+1) = dataset.data';
    % Write data
    dlmwrite(filename,matrix,...
        'delimiter','\t','precision','%.4f' ,'-append');
catch exception
    status = getReport(exception, 'extended', 'hyperlinks', 'off');
end

end
