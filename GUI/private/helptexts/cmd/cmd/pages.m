% PAGES List of pages for help window
%
% Format:
%   pageList - cell array (nx3)
%
%   1st column: Description as it should appear in the listbox
%
%   2nd column: filename of the file for the corresponding topic
%               (without extension, "html" is assumed)
%
%   3rd column: Lengthlier description (currently unused, might be empty)
%
% Important notes:
%
%   * The variable needs to be named "pageList".
%
%   * The sequence of the entries (rows) in the pageList cell array
%     determines the sequence of entries in the listbox.

% Copyright (c) 2014, Till Biskup
% 2014-09-22

pageList = {...
    '?','questionmark';...
    'acc','acc';...
    'avg','avg';...
    'blc','blc';...
    'combine','combine';...
    'convert','convert';...
    'define','define';...
    'detach','detach';...
    'dir','dir';...
    'disp','disp';...
    'doi','doi';...
    'duplicate','duplicate';...
    'env','env';...
    'export','export';...
    'get','get';...
    'help','help';...
    'hide','hide';...
    'history','history';...
    'info','info';...
    'input','input';...
    'label','label';...
    'load','load';...
    'make','make';...
    'mwfreq','mwfreq';...
    'netpol','netpol';...
    'panel','panel';...
    'pdf2bitmap','pdf2bitmap';...
    'pick','pick';...
    'poi','poi';...
    'proc','proc';...
    'remove','remove';...
    'reset','reset';...
    'run','run';...
    'save','save';...
    'set','set';...
    'show','show';...
    'sim','sim';...
    'soi','soi';...
    'spikeremove','spikeremove';...
    'stack','stack';...
    'status','status';...
    'unstack','unstack';...
    };