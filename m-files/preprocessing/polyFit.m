% Compute a polynomial fit of the input data and return the polynomial.
%
% Input arguments
%   data      - nx2 matrix with x and y values in first and second column
%   degree    - degree of polynomial
%   left      - points on the left side to be used for fit
%   right     - points on the right side to be used for fit
%   addPoint1 - (optional) first additional point to be used for fit
%   addPoint2 - (optional) second additional point to be used for fit
%
% Output arguments
%   f     - values of the polynomial of degree n evaluated at x
%   p     - coefficients of a polynomial p(x) of degree n that fits the
%           data, p(x(i)) to y(i), in a least squares sense 
%   delta - error estimates, y±delta. If the errors in the data input to
%           polyfit are independent normal with constant variance, y±delta
%           contains at least 50% of the predictions 
%   mu    - two-element vector with mu1 = mean(x) and mu2 = std(x)
%   S     - Structure S contains fields R, df, and normr, for the
%           triangular factor from a QR decomposition of the Vandermonde
%           matrix of X, the degrees of freedom, and the norm of the
%           residuals, respectively.
function varargout = polyFit(data, degree, left, right, varargin)
    % Parse input arguments using the inputParser functionality
    p = inputParser;   % Create an instance of the inputParser class.
    p.FunctionName = mfilename; % Function name to be included in error messages
    p.KeepUnmatched = true; % Enable errors on unmatched arguments
    p.StructExpand = true; % Enable passing arguments in a structure

    p.addRequired('data', @(x)isnumeric(x) && ~isscalar(x));
    p.addRequired('degree', @(x)isnumeric(x) && isscalar(x));
    p.addRequired('left', @(x)isnumeric(x) && isscalar(x));
    p.addRequired('right', @(x)isnumeric(x) && isscalar(x));
    p.addOptional('addPoint1',1,@(x)isnumeric(x) && isscalar(x));
    p.addOptional('addPoint2',1,@(x)isnumeric(x) && isscalar(x));
    p.parse(data,degree,left,right,varargin{:});
    
    if ~exist('addPoint1','var')
        addPoint1 = 1;
    end
    if ~exist('addPoint2','var')
        addPoint2 = 1;
    end
    
    % Get coefficients of polynomial
    [p,S,mu] = polyfit(...
        data([1:left,addPoint1,addPoint2,end-right:end],1),...
        data([1:left,addPoint1,addPoint2,end-right:end],2),...
        degree);
    
    % Evaluate the polynomial p
    [f,delta] = polyval(p,data(:,1),S,mu);
    
    % Assign output arguments
    switch nargout
        case 1
            varargout{1} = f;
        case 2
            varargout{1} = f;
            varargout{2} = p;
        case 3
            varargout{1} = f;
            varargout{2} = p;
            varargout{3} = delta;
        case 4
            varargout{1} = f;
            varargout{2} = p;
            varargout{3} = delta;
            varargout{4} = mu;
        case 5
            varargout{1} = f;
            varargout{2} = p;
            varargout{3} = delta;
            varargout{4} = mu;
            varargout{5} = S;
    end
    
end
