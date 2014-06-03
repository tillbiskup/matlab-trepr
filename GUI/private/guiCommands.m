function cmdMatch = guiCommands
% GUICOMMANDS Helper function dealing with the command line of the trEPR
% GUI and providing assignments of GUI command line commands to Matlab(tm)
% functions.
%
% Usage:
%   cmdMatch = guiCommands

% (c) 2013-14, Till Biskup
% 2014-06-03

% PLEASE NOTE: All variables from within the context of the calling
% function (normally, this should be "trEPRguiCommand") are accessible
% within this script. On the other hand, all variables assigned within this
% script will be accessible within the scope of the calling function.
% Therefore, the last task of this script is to tidy up a bit, such as not
% to leave any additional variables that might lead to confusion later on.

% Extended version: cell array allowing for optional arguments
% column 1: string; command as entered on the command line
% column 2: string; actual Matlab command issued
% column 3: additional argument(s) (in case of more than one, cell array)
% column 4: logical; condition (important: set to true by default)
cmdMatch = {...
    'info',   'trEPRgui_infowindow',             '', true; ...
    'acc',    'trEPRgui_ACCwindow',              '', true; ...
    'blc',    'trEPRgui_BLCwindow',              '', true; ...
    'sim',    'trEPRgui_SIMwindow',              '', true; ...
    'status', 'trEPRgui_statuswindow',           '', true; ...
    'combine','trEPRgui_combinewindow',          '', true; ...
    'netpol', 'trEPRgui_NetPolarisationwindow',  '', true; ...
    'mwfreq', 'trEPRgui_MWfrequencyDriftwindow', '', true; ...
    };

% Tidy up
clear label;