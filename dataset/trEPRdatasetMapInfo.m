function dataset = trEPRdatasetMapInfo(dataset,info,format)
% TREPRDATASETMAPINFO Map info from info file to dataset structure.
%
% Usage
%   dataset = TREPRDATASETMAPINFO(dataset,info,format)
%
%   dataset - stucture
%             Dataset complying with specification of toolbox dataset
%             structure
%
%   info    - struct
%             Info structure as returned by commonInfofileLoad
%
%   format  - struct
%             Format of the info file as returned by commonInfofileLoad
%
% SEE ALSO: commonDatasetCreate, commonInfofileLoad

% Copyright (c) 2015, Till Biskup
% 2015-03-25

dataset = commonDatasetMapInfo(dataset,info,format);

end