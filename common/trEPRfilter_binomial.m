function data = trEPRfilter_binomial(data,width)
% TREPRFILTER_BINOMIAL Filter 1D data weighted with a binomial filter with
% given width. The weighting factors are the (2*m+1)-th row from the Pascal
% triangle.
%
% Usage
%   data = trEPRfilter_binomial(data,width)
%
%   data  - data to filter
%
%   width - filter window width (actual filter window is 2*width+1)
%
% See also: trEPRfilter_SavitzkyGolay, trEPRfilter_boxcar

% Copyright (c) 2014, Till Biskup
% 2014-07-24

[x,y] = size(data);
filter = diag(rot90(pascal(width*2+1)))/sum(diag(rot90(pascal(width*2+1))));

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
