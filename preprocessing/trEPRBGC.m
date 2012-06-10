function varargout = trEPRBGC (data, varargin)
% TREPRBGC Compensating laser background of a transient EPR time profile:
% Subtract the average of the first n time profiles from the complete 2D
% dataset. 
% 
% Should always be applied to a dataset whose pretrigger offset has been
% compensated for, see trEPRPOC for more detais.
%
% Usage:
%   data = trEPRBGC(data)
%   data = trEPRBGC(data,numBGprofiles)
%
% data          - matrix
%                 dataset to operate on
% numBGprofiles - scalar
%                 number of time profiles averaged over and used as
%                 background subtracted from data
%                 Default: 5
%
% See also: trEPRPOC

% (c) 2010-12, Till Biskup
% 2012-06-10

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)isnumeric(x) && ~isscalar(x));
%p.addOptional('parameters','',@isstruct);
p.addParamValue('numBGprofiles',5,@isvector);
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
if (length(p.Results.numBGprofiles) == 2) && ...
        (p.Results.numBGprofiles(1) == 0)
    bg = mean(data(end-p.Results.numBGprofiles(2):end,:));
elseif (length(p.Results.numBGprofiles) == 1)
    bg = mean(data(1:p.Results.numBGprofiles,:));
end

if exist('bg','var');
    for k = 1 : rows
        data(k,:) = data(k,:) - bg;
    end
else
    nTrans = size(data,1);
    low = mean(data(1:p.Results.numBGprofiles(1),:));
    high = mean(data(nTrans-p.Results.numBGprofiles(2):nTrans,:));
    slope = (high-low) / nTrans;
    for i = 1:nTrans
        data(i,:) = data(i,:) - (low + slope*(i-1));
    end
end
    
% Assign output parameter
varargout{1} = data;
