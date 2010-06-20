function strings = explode(str,separator)

separators = strfind(str,separator);
if isempty(separators)
    strings{1} = str;
    return
end
strings = cell(length(separators)+1,1);
strings{1} = str(1:separators(1)-1);
for k=2:length(separators)
    strings{k}=str(separators(k-1)+1:separators(k)-1);
end
strings{end} = str(separators(length(separators))+1:end);

end