function guiClose()

% TODO: Check whether there is anything that is not saved...

% Get the main window handle
mainWindow = findobj('Tag','trepr_gui_mainwindow');

% Close GUI
delete(mainWindow);

end