function [dataStructure,warning] = loadDatasetV1(archiveFilenames)
% LOADDATASETV1 Helper function for commonLoad reading ZIP-compressed XML
% file and data (if available). 
%
% Usage:
%   [dataStructure,warning] = loadDatasetV1(filenames)
%
%   archiveFilenames - cell array (of strings)
%                      Name of the files that are contained in the (already
%                      unzipped) archive.
%
%   dataStructure    - struct
%                      content of the XML file
%                      data.data holds the data read from the ZIP archive
%
%   warning          - cell array
%                      Contains warnings if there are any, otherwise empty
%
% Compatibility:
%
% This function aims at full compatibility with datasets saved with
% versions of the trEPR and TA toolboxes prior to introducing the
% implementation scheme described at the website referred to above. Loading
% datasets in previous formats should therefore never be a problem, as long
% as the toolboxes get developed...
%
% SEE ALSO commonLoad

% Copyright (c) 2015, Till Biskup
% 2015-05-31

dataStructure = [];
warning = cell(0);

% Read different files of the archive
try
    for k=1:length(archiveFilenames)
        [pathstr, name, ext] = fileparts(archiveFilenames{k});
        switch ext
            case '.xml'
                XMLfileSerialize(fullfile(pathstr,[name ext]));
                dataStructure = XML2struct(...
                    xmlread(fullfile(pathstr,[name ext])));
            case '.dat'
                try
                    data = load(fullfile(pathstr,[name ext]));
                    % Try to check whether we have read correct data - as
                    % we cannot rely to already have read the xml file, we
                    % need to check whether "length(data) == 1" and in this
                    % case try to read via binary and see what happens.
                    %
                    % This is to cope with the fact that some binary files
                    % might start with something load interprets as proper
                    % number - and therefore doesn't crash. There is no
                    % easy way to distinguish whether a file has binary
                    % content in Matlab. At least not that I know of...
                    if length(data) == 1
                        tmpData = commonBinaryFileRead(...
                            fullfile(pathstr,[name ext]),...
                            'real*4');
                        if length(tmpData) > length(data)
                            data = tmpData;
                        end
                        clear tmpData;
                    end
                catch exception
                    try
                        data = commonBinaryFileRead(...
                            fullfile(pathstr,[name ext]),...
                            'real*4');
                    catch exception2
                        exception = addCause(exception2, exception);
                        throw(exception);
                    end
                end
            otherwise
        end
    end
catch errmsg
    warning{end+1} = sprintf('%s\n%s\n"%s"\n',...
        errmsg.identifier,...
        'Problems with parsing XML in file:',...
        name);
    return;
end
if exist('data','var')
    % Check whether data have the right dimensions - in case that we read
    % from binary, most probably they have not - in this case, reshape
    xdim = length(dataStructure.axes.x.values);
    ydim = length(dataStructure.axes.y.values);
    [y,x] = size(data);
    if ((x ~= xdim) || (y ~= ydim))  && ~isempty(data)
        try
            data = reshape(data,ydim,xdim);
        catch exception
            warning{end+1} = sprintf('%s\n%s\n\nError was: %s',...
                'Something caused trouble trying to reshape...',...
                'Therefore, data might be corrupted. BE CAREFUL!',...
                getReport(exception, 'extended', 'hyperlinks', 'off'));
        end
    end
    dataStructure.data = data;
end

end
