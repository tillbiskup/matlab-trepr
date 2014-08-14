function properties = trEPRplotProperties()
% TREPRPLOTPROPERTIES Return plot properties used for trEPRplot and inside
% the trEPR GUI.
%
% Usage
%   properties = trEPRplotProperties
%
%   properties - struct
%                structure with plot properties (hierarchical)
%
% See also: trEPRplot

% Copyright (c) 2014, Till Biskup
% 2014-07-22

% Get GUI appdata structure
guiAppdataStructure = trEPRguiDataStructure('guiappdatastructure');
guiDataStructure = trEPRguiDataStructure('datastructure');

properties = guiAppdataStructure.control.axis;
properties.display = guiDataStructure.display;
properties.format = struct(...
    'name','trEPR toolbox plotproperties',...
    'version','1.0' ...
    );

end
