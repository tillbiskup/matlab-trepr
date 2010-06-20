% Split a string str by string delimiter.
%
% Returns a cellarray of strings, each of which is a substring of string
% str formed by splitting it on boundaries formed by the string delimiter.
%
% INPUT ARGUMENTS
%   delimiter - the boundary string
%   str       - the input string
%
% OUTPUT ARGUMENTS
%   strings   - array of strings, each of which is a substring of str
%               formed by splitting it on boundaries formed by the string
%               delimiter
%
% This function was inspired by PHP's explode function.

function strings = explode(delimiter,str)

if nargin == 0
    help explode
    return
end

delimiters = strfind(str,delimiter);
if isempty(delimiters)
    strings{1} = str;
    return
end
strings = cell(length(delimiters)+1,1);
strings{1} = str(1:delimiters(1)-1);
for k=2:length(delimiters)
    strings{k}=str(delimiters(k-1)+1:delimiters(k)-1);
end
strings{end} = str(delimiters(length(delimiters))+1:end);

end