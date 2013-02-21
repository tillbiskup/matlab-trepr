% Script (NOT a function!) including the assignment of GUI command line
% commands to Matlab(tm) functions

% (c) 2013, Till Biskup
% 2013-02-21

% PLEASE NOTE: All variables from within the context of the calling
% function (normally, this should be "trEPRguiCommand") are accessible
% within this script. On the other hand, all variables assigned within this
% script will be accessible within the scope of the calling function.
% Therefore, the last task of this script is to tidy up a bit, such as not
% to leave any additional variables that might lead to confusion later on.
    
% Some additional stuff
if ~active
    label = '';
else
    label = ad.data{active}.label;
end

% Extended version: cell array allowing for optional arguments
% column 1: string; command as entered on the command line
% column 2: string; actual Matlab command issued
% column 3: additional argument(s) (in case of more than one, cell array)
% column 4: logical; condition (important: set to true by default)
cmdMatch = {...
    'info',   'trEPRgui_infowindow',             '', true; ...
    'acc',    'trEPRgui_ACCwindow',              '', true; ...
    'avg',    'trEPRgui_AVGwindow',              '', true; ...
    'blc',    'trEPRgui_BLCwindow',              '', true; ...
    'sim',    'trEPRgui_SIMwindow',              '', true; ...
    'status', 'trEPRgui_statuswindow',           '', true; ...
    'combine','trEPRgui_combinewindow',          '', true; ...
    'netpol', 'trEPRgui_NetPolarisationwindow',  '', true; ...
    'mwfreq', 'trEPRgui_MWfrequencyDriftwindow', '', true; ...
    'label',  'trEPRgui_setLabelWindow',         label, active; ...
    };

% Tidy up
clear label;