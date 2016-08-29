function table = trEPRdatasetMappingTableV0_1_6
% TREPRDATASETMAPPINGTABLEV0_1_6 Mapping table for mapping trEPR info
% file (v. 0.1.6) contents to dataset.
%
% Usage
%   table = trEPRdatasetMappingTableV0_1_6
%
%   table - cell (nx3)
%           1st column: field of info structure returned by
%           commonInfofileLoad
%
%           2nd column: corresponding field in dataset structure as
%           returned by commonDatasetCreate
%
%           3rd column: modifier telling dataasetMapInfo how to modify the
%           field from the info file to fit into the dataset
%
%           Currently allowed (case insensitive) modifiers contain:
%           join, joinWithSpace, splitValueUnit, str2double
%
%           See the source code of commonDatasetMapInfo for more info
%
% NOTE FOR TOOLBOX DEVELOPERS:
% Use commonInfofileMappingTableHelper to create the basic structure of the
% cell array "table" to create your own PREFIXdatasetMappingTable.
%
% SEE ALSO: commonDatasetMapInfo, commonDatasetCreate, commonInfofileLoad,
% commonInfofileMappingTableHelper

% Copyright (c) 2016, Till Biskup
% 2016-08-29

table = [ ...
    trEPRdatasetMappingTableV0_1_5; ...
    {'sample.id','sample.id',''} ...
    ];
