function h = trEPR
% This function is a simple wrapper for calling the main trEPR toolbox GUI,
% namely the script trEPR_main.
%
% For more information about the trEPR toolbox GUI, type help trEPR_main
%
% See also: trEPR_main
if nargout
    h = trEPR_GUI_main;
else
    trEPR_GUI_main;
end
