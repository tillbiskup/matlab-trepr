function data = trEPRfilter_SavitzkyGolay(data,width,order,deriv)
% TREPRFILTER_SAVITZKYGOLAY Filter 1D data with a Savitzky-Golay filter (1)
% with given window length.
%
% Usage
%   data = trEPRfilter_boxcar(data,window,order,deriv)
%
%   data   - data to filter
%
%   window - filter window width (optional, default=15)
%
%   order  - polynomial order (optional, default=2)
%
%   deriv  - derivative order (optional, default=0)
%
% (1) Abraham. Savitzky, M. J. E. Golay: Smoothing and Differentiation of
%     Data by Simplified Least Squares Procedures. In: Analytical
%     Chemistry. 36, Nr. 8, 1. Juni 1964, S. 1627?1639,
%     doi:10.1021/ac60214a047
%
% See also: trEPRfilter_boxcar

% Copyright (c) 2014, Till Biskup
% 2014-07-23

% Based on code written by Cleiton A. Nunes, UFLA,MG,Brazil

[m,n]=size(data);
if m>n
    data = data';
    n=m;
end
if nargin<4
  deriv=0;
end
if nargin<3
  order=2; 
end
if nargin<2
  width=min(15,floor(n/2)); 
end

w=max( 3, 1+2*round((width-1)/2) );
o=min([max(0,round(order)),5,w-1]);
d=min(max(0,round(deriv)),o);
p=(w-1)/2;
xc=((-p:p)'*ones(1,1+o)).^(ones(size(1:w))'*(0:o));
we=xc\eye(w);
b=prod(ones(d,1)*(1:o+1-d)+(0:d-1)'*ones(1,o+1-d,1),1);
di=spdiags(ones(n,1)*we(d+1,:)*b(1),p:-1:-p,n,n);
w1=diag(b)*we(d+1:o+1,:);
di(1:w,1:p+1)=(xc(1:p+1,1:1+o-d)*w1)'; 
di(n-w+1:n,n-p:n)=(xc(p+1:w,1:1+o-d)*w1)';

data=data*di;

end
