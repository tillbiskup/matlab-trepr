function data = trEPRfilter_boxcar(data,width)
% TREPRFILTER_BOXCAR Filter 1D data with a boxcar filter with given window
% length.
%
% Usage
%   data = trEPRfilter_boxcar(data,window)
%
%   data  - data to filter
%
%   width - filter window width (actual filter window is 2*width+1)
%
% PLEASE NOTE: Using this unweighted filter is strongly discouraged, as it
%              is known to broaden lines and distort line shapes. Use
%              binomial or Savitzky-Golay filtering instead.
%
% IMPORTANT:   Definition of width (window) has changed as of 2014-07-24.
%              Old definition was complete width of filter window, i.e.
%              width = 1 means no filtering.
%              New definition: actual filter window = 2*width+1, i.e.
%              width = 1 means filtering with a window of 3.
%
% See also: trEPRfilter_binomial, trEPRfilter_SavitzkyGolay

% Copyright (c) 2011-14, Till Biskup
% 2014-07-24

width = 2*width+1;
filter = ones(1,width)/width;

[x,y] = size(data);
if (x == 1) % data is column vector
    % padding data to avoid artefacts
    data = [...
        ones(1,width)*data(1) ...
        data ...
        ones(1,width)*data(end) ...
        ];
elseif (y == 1) % data is row vector
    % padding data to avoid artefacts
    data = [...
        ones(width,1)*data(1); ...
        data; ...
        ones(width,1)*data(end); ...
        ];
end

data = convn(data,filter,'same');
data = data(width+1:1:end-width);

end
