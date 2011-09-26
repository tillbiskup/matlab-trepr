function guiClose()

try
    % TODO: Check whether there is anything that is not saved...
    
    % Close all GUI windows currently open
    delete(findobj('-regexp','Tag','trepr_gui_*'));
    
catch exception
    % Hm... that should really not happen.
    disp('Sorry, but there were some problems closing the GUI.');
    disp('Try "delete(handle)" with "handle" corresponding to GUI');
    throw(exception);
end

end