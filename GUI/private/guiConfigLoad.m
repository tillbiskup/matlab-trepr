function conf = guiConfigLoad(inifile)

% (c) 2011-12, Till Biskup
% 2012-01-26

conf = trEPRiniFileRead(inifile);

% Parse config values
blockNames = fieldnames(conf);
for k=1:length(blockNames)
    fieldNames = fieldnames(conf.(blockNames{k}));
    for m=1:length(fieldNames)
        if ~isnan(str2double(conf.(blockNames{k}).(fieldNames{m})))
            conf.(blockNames{k}).(fieldNames{m}) = ...
                str2double(conf.(blockNames{k}).(fieldNames{m}));
        end
    end
end
