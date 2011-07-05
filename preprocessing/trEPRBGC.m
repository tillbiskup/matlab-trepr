function varargout = trEPRBGC (data, varargin)
% Compensating laser background of a transient EPR time profile: Subtract
% the average of the first n time profiles from the complete 2D dataset.
% 
% Should always be applied to a dataset whose pretrigger offset has been
% compensated for, see trEPRPOC for more detais.

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)isnumeric(x) && ~isscalar(x));
%p.addOptional('parameters','',@isstruct);
p.addParamValue('numBGprofiles',5,@isscalar);
p.parse(data,varargin{:});

% Determine the dimensionality of the data (1D or 2D)
[rows, cols] = size(data);
if min([rows, cols]) == 1
    warning(...
        'trEPRBGC:wrongFormat',...
        'Cannot operate on 1D datasets (single time profiles). Aborted.'...
        );
    return;    
end

% Check for appropriate size of data matrix for the compensation
if rows <= p.Results.numBGprofiles
    warning(...
        'trEPRPOC:dataSize',...
        'The data matrix is too small for appropriate BGC. Aborted.'...
        );
    return;
end

% Compensate the laser background: Subtract mean value of the first n time
% profiles from each time profile of the complete 2D dataset.
bg = mean(data(1:p.Results.numBGprofiles,:));
for k = 1 : rows
    data(k,:) = data(k,:) - bg;
end
    
% Assign output parameter
varargout{1} = data;
    