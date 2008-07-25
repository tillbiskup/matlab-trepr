% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* GUI/GUI_fsc2_display.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/02/21
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	fsc2, 2D display, 1D slices, B_0 slice, time slice
%
% SYNOPSIS
%	fsc2_display
%
% DESCRIPTION
%	This function provides a fsc2-like display with the possibility
%	to select time and B_0 slices. It makes use of the MATLAB(TM)
%	GUI possibilities.
%
%	After improving a lot it is now possible to save the different kinds of
%	views (B_0 spectrum, time slice, 2D data) as ASCII data as well as to set
%	an integration window for the 1D views.
%
%	This function appeared in version > 0.1.0 of the trEPR toolbox.
%
% INPUT PARAMETERS
%	there are currently no input parameters
%
% OUTPUT PARAMETERS
%	no output parameters yet
%
% DEPENDS ON
%	pretrigger_offset.m
%	baseline_subtraction_fsc2.m
%
% EXAMPLE
%	To start the GUI, just type at the MATLAB(TM) command line:
%
%		GUI_fsc2_display
%
%	To open a fsc2 file, select "File > Open" or use the shortcut, "Ctrl+O", or
%	"Apple+O" on the Mac.
%
% SOURCE

function GUI_fsc2_display
 
	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help GUI_fsc2_display" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help GUI_fsc2_display" to get help.',nargout);

	end

	% test by which program we are called
	% this is because the function makes heavy use of MATLAB(TM) specific functionality
	
	if (exist('program') == 0)
		% if the variable "program" is not set, that means the routine isn't called
		% yet...

		if exist('discriminate_matlab_octave')
			% let's check whether the routine performing the discrimination
			% is available...

		    program = discriminate_matlab_octave;
	    
		else
			% that means if the variable "program" isn't set yet and the routine
			% performing the discrimination isn't available...
	
			fprintf('\nSorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\nThis function will behave as if it is called within MATLAB(TM)...\nBe aware: In the case that is not true you can run into problems!');
		
			program = 'Matlab';
			
			% set variable to default value
	
		end;
	
	end;


	if program == 'Octave'	% if we're called by GNU Octave (as determined above)

		error('Sorry, but this routine cannot be used with GNU Octave at the moment...');
		
		% If we're called by GNU Octave any further processing will be aborted due to
		% the problems described above.
		
	end;
 
	% check for the availability of the routines we depend on

	if ( exist('pretrigger_offset.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'pretrigger_offset');


	elseif ( exist('baseline_subtraction_fsc2.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'baseline_subtraction_fsc2');

	end
	
 
	% ...and here the 'real' stuff goes in
	
	% first of all, define some global variables used in the function and its
	% subfunctions
 	global disp_style;
	global disp_data;
	global disp_field;
	global orig_data;
	global oc_data;
	global bl_oc_data;
	global time;
	global field;
	global field_params;
	global time_params;
	global frequency;
	global slider_val_time;
	global slider_val_timestep;
	global slider_val_field;
	
	global time_integrationWindow;
	global field_integrationWindow
	
	% set some of the globals to defined values	
	disp_style = '2D display';
	field_integrationWindow = 1;
	time_integrationWindow = 1;
	
	% in case there is no data loaded, set default values for some variables
	% DIRTY TRICK - TO BE CHANGED!
	if ( length(disp_data) == 0 )
		time_params = [ 1 1 1 ];
	end

	slider_val_time = time_params(2);
	slider_val_field = 1;
	GUItitle = 'fsc2-like display of transient EPR spectra';
	
	titlestring = 'No file loaded, use "File > Open"...';

	
	% CREATING THE GUI
	%
	% This is done in several steps:
	%
	% 1. create and hide the GUI
	%
	% 2. construct the GUI components
	%
	% 3. initialize the GUI

	% STEP 1: Create and then hide the GUI as it is being constructed.
	% This is responsible only for the basic window containing all GUI elements.
	f = figure('Visible','off','Position',[360,500,700,500]);
 
	% STEP 2: Construct the GUI components
	% The GUI consists of two sets of toggle buttons, the graphics window and
	% a slider for going through the 2D set in the different 1D display modes
	% and some additional text fields.
	
	% TOGGLE BUTTON for switching between original, offset, and drift compensated data
	h_togglebutton_comp = uibuttongroup('visible','off','Position',[0 0 .18 1]);
	u0 = uicontrol('Style','Toggle','String','original data',...
		'pos',[10 450 100 30],'parent',h_togglebutton_comp,'HandleVisibility','off');
	u1 = uicontrol('Style','Toggle','String','offset comp.',...
		'pos',[10 400 100 30],'parent',h_togglebutton_comp,'HandleVisibility','off');
	u2 = uicontrol('Style','Toggle','String','drift comp.',...
		'pos',[10 350 100 30],'parent',h_togglebutton_comp,'HandleVisibility','off');
	set(h_togglebutton_comp,'SelectionChangeFcn',@selcompcbk);
	set(h_togglebutton_comp,'SelectedObject',u0);  % No selection
	set(h_togglebutton_comp,'Visible','on');

	% TOGGLE BUTTON for switching between the display styles (2D, B_0, time slice)
	h_togglebutton_disp = uibuttongroup('visible','off','Position',[0 0 .18 1]);
	u0 = uicontrol('Style','Toggle','String','2D display',...
		'TooltipString','display 2D data',...
		'pos',[10 175 100 30],'parent',h_togglebutton_disp,'HandleVisibility','off');
	u1 = uicontrol('Style','Toggle','String','time slice',...
		'TooltipString','display time slice',...
		'pos',[10 125 100 30],'parent',h_togglebutton_disp,'HandleVisibility','off');
	u2 = uicontrol('Style','Toggle','String','B_0 slice',...
		'TooltipString','display B_0 spectrum',...
		'pos',[10 75 100 30],'parent',h_togglebutton_disp,'HandleVisibility','off');
	set(h_togglebutton_disp,'SelectionChangeFcn',@seldispcbk);
	set(h_togglebutton_disp,'SelectedObject',u0);  % No selection
	set(h_togglebutton_disp,'Visible','on');

	% SLIDER for going through the 2D data set in the different 1D display modes
	% together with the text fields for the measure and the value
	hslider = uicontrol('Style','slider','Position',[650,25,20,400],...
		'String','vertical slider','TooltipString','slider',...
		'Min',0,'Max',time_params(1),'SliderStep',[1/time_params(1),(1/time_params(1))*10],...
		'Callback',{@slider_Callback});
	htext_slider_value = uicontrol('Style','text','String','',...
		'TooltipString','slider',...
		'Position',[655,450,35,13]);
	htext_slider_measure = uicontrol('Style','text','String','',...
		'TooltipString','measure of the slider',...
		'Position',[605,450,45,13]);
	htext_slider_value2 = uicontrol('Style','text','String','',...
		'TooltipString','slider',...
		'Position',[655,435,35,13]);
	htext_slider_measure2 = uicontrol('Style','text','String','',...
		'TooltipString','measure of the slider',...
		'Position',[605,435,45,13]);
	set(htext_slider_value,'BackgroundColor',get(f,'Color'));
	set(htext_slider_measure,'BackgroundColor',get(f,'Color'));
	set(htext_slider_value2,'BackgroundColor',get(f,'Color'));
	set(htext_slider_measure2,'BackgroundColor',get(f,'Color'));

	% TEXT FIELD AND INPUT FOR THE INTEGRATION WINDOW
	htext_integration_window_text = uicontrol( ...
	    'Style','text',...
	    'String','Integration window:',...
		'TooltipString','Integration window',...
		'Position',[10 35 100 15] ...
	);
	set(htext_integration_window_text,'BackgroundColor',get(f,'Color'));
	htext_integration_window = uicontrol( ...
	    'Style','edit',...
		'TooltipString','',...
		'Position',[10 20 100 15], ...
		'Callback',{@integrationWindow_Callback} ...
	);
	set(htext_integration_window,'BackgroundColor',get(f,'Color'));
	set([htext_integration_window_text, htext_integration_window],'Visible','off');
	
	% TEXT FIELD for the title
	htext_title = uicontrol('Style','text','String',titlestring,...
		'FontSize',14,...
		'Position',[200,475,400,15]);
	set(htext_title,'BackgroundColor',get(f,'Color'));

	% GRAPHICS WINDOW, called "axes" in MATLAB(TM), for displaying the data
	ha = axes('Units','Pixels','Position',[200,50,400,400]); 

    % MENU
	% Create menubar
	fmh = uimenu(f,'Label','File');
	efmh1 = uimenu(fmh,'Label','Open...','Accelerator','o','Callback',{@openSpectrum_Callback});
	efmh2 = uimenu(fmh,'Label','Save','Accelerator','s','Callback',{@saveSpectrum_Callback},'Enable','off');
%	efmh3 = uimenu(fmh,'Label','Save as...');
	efmh4 = uimenu(fmh,'Label','Close window','Accelerator','w','Callback','close');
	set(efmh2,'Separator','on');
	set(efmh4,'Separator','on');
    hHelpMenu = uimenu(f,'Label','Help');
    hHelpHelpMenu = uimenu(hHelpMenu,'Label','Help','Callback','doc GUI_fsc2_display');
    hHelpMatlabMenu = uimenu(hHelpMenu,'Label','MATLAB Help','Callback','doc');
    hHelpAboutMenu = uimenu(hHelpMenu,'Label','About','Callback',{@helpAbout_Callback},'Separator','on');
    
   
	% STEP 3: Initialize the GUI.
	% Change units to normalized so components resize automatically.
	set([f,ha,hslider,htext_slider_value,htext_slider_value2,h_togglebutton_comp,h_togglebutton_disp,htext_title,htext_slider_measure,htext_slider_measure2],'Units','normalized');
	% Create a plot in the axes.
	% display_data ( time, disp_field/10, disp_data );
	% Assign the GUI a name to appear in the window title.
	set(f,'Name',GUItitle)
	% Disable the builtin menus in the menu bar.
	set(f,'MenuBar','none');	
	% according to the MATLAB(TM) documentation,
	% set the "HandleVisibility" properties of all menus to "off"
	menuhandles = findall(f,'type','uimenu');
    set(menuhandles,'HandleVisibility','off');
    
	% Enable the builtin toolbar.
	% set(f,'Toolbar','figure');
	% Move the GUI to the center of the screen.
	movegui(f,'north');
	% Set the slider to inactive
	set(hslider,'Enable','inactive');
	% Set the buttons to inactive
	set([h_togglebutton_comp, h_togglebutton_disp, hslider],'Visible','Off');
	% Make the GUI visible.
	set(f,'Visible','on');
 
 	% DEFINE THE CALLBACKS FOR THE GUI COMPONENTS
 
	% These callbacks automatically have access to component handles
	% and initialized data because they are nested at a lower level.
   
	% SLIDER CALLBACK
	% Each callback plots the data at the point defined by the slider position
	% if we are in the 1D display modes, otherwise the slider is not accessible.
 
	function slider_Callback(source,eventdata) 
		val = get(hslider,'Value');
		
		switch disp_style
			case {'time slice'}
				set(htext_slider_value,'String',num2str(field(round(val)+1)/10));
				slider_val_field = round(val)+1;
				display_data ( time, disp_field/10, disp_data );
			case {'B_0 slice'}
				set(htext_slider_value,'String',num2str(time(round(val)+1)));
				set(htext_slider_value2,'String',num2str(round(val)+1));
				slider_val_time = round(val)+1;
				display_data ( time, disp_field/10, disp_data );
			case {'2D display'}
				set(htext_slider_value,'String','');
		end
      
	end
   
	% TOGGLE BUTTON CALLBACKS
	% There are two sets of toggle buttons: one for the choice between the original,
	% the offset compensated and the baseline compensated data, and the other for
	% the choice between the display modes. 

	function selcompcbk(source,eventdata)
		
		comp_style = get(get(source,'SelectedObject'),'String');
		
		switch comp_style
			case {'original data'}
				disp_data = orig_data;
				display_data ( time, disp_field/10, disp_data );
			case {'offset comp.'}
				disp_data = oc_data;
				display_data ( time, disp_field/10, disp_data );
			case {'drift comp.'}
				disp_data = bl_oc_data;
				display_data ( time, disp_field/10, disp_data );
		end
	end

	function seldispcbk(source,eventdata)
		
		disp_style = get(get(source,'SelectedObject'),'String');
		
		switch disp_style
			case {'time slice'}
				set(hslider,'Visible','on');
				set(hslider,'Enable','on');
				set([htext_integration_window_text, htext_integration_window], ...
				  'Visible','on');
				set(htext_slider_measure,'String','B_0 / mT');
				set(hslider,'Min',0);
				set(hslider,'Max',length(field)-1);
				set(hslider,'SliderStep',[1/(length(field)-1),(1/(length(field)-1))*10]);
				set(hslider,'Value',slider_val_field-1);
				set(htext_slider_value,'String',num2str(field(slider_val_field)/10));
				set([htext_slider_value2 htext_slider_measure2],'Visible','Off');
				set(htext_integration_window,'String',field_integrationWindow);
				display_data ( time, disp_field/10, disp_data );
			case {'B_0 slice'}
				set(hslider,'Visible','on');
				set(hslider,'Enable','on');
				set([htext_integration_window_text, htext_integration_window], ...
				  'Visible','on');
				set(htext_slider_measure,'String','time / us');
				set(htext_slider_measure2,'String','timestep');
				set(hslider,'Min',0);
				set(hslider,'Max',length(time)-1);
				set(hslider,'SliderStep',[1/(length(time)-1),(1/(length(time)-1))*10]);
				set(hslider,'Value',slider_val_time-1);
				set(htext_slider_value,'String',num2str(time(slider_val_time)));
				set([htext_slider_value2 htext_slider_measure2],'Visible','On');
				set(htext_slider_value2,'String',num2str(slider_val_time));
				set(htext_integration_window,'String',time_integrationWindow);
				display_data ( time, disp_field/10, disp_data );
			case {'2D display'}
				set(hslider,'Visible','off');
				set([htext_slider_value2 htext_slider_measure2],'Visible','Off');
				set([htext_integration_window_text, htext_integration_window], ...
				  'Visible','Off');
				set(hslider,'Enable','inactive');
				set(htext_slider_measure,'String','');
				set(htext_slider_value,'String','');
				display_data ( time, disp_field/10, disp_data );
		end
	end
   
	% INTEGRATION WINDOW CALLBACK
	% Each callback plots the data at the point defined by the slider position
	% if we are in the 1D display modes, otherwise the slider is not accessible.
 
	function integrationWindow_Callback(source,eventdata) 
		val = get(htext_integration_window,'String');
		
		switch disp_style
			case {'time slice'}
			  field_integrationWindow = str2num(val);
			  display_data ( time, disp_field/10, disp_data );
			case {'B_0 slice'}
			  time_integrationWindow = str2num(val);
			  display_data ( time, disp_field/10, disp_data );
		end
      
	end
    
    % OPEN SPECTRUM CALLBACK
    
    function openSpectrum_Callback(source,eventdata)
    		% open file selection dialog for reading file
		[filename, pathname,filterIndex] = uigetfile({'*.dat;*.txt;*.asc;*.ASC','ASCII files (*.dat,*.txt,*.asc,*.ASC)'}, 'Pick an M-file');
		% creating cell array with the different file formats
		% used as input for the (internal) loadSpectrum function
		fileFormat = {'ASCII'};
        
        fprintf('Filename: %s%s\n',pathname,filename);
		
		if isequal(filename,0)
			% in case the user doesn't choose a filename
			%disp('User selected Cancel')
			% do nothing loop :)
		else
			% load spectrum, use therefore an internal function
			% doing all the "real stuff"
			char(fileFormat(filterIndex));
            file = sprintf('%s%s',pathname,filename);
			[ spectrum, time, field ] = loadSpectrum(file,char(fileFormat(filterIndex)));

			if ( max(size(spectrum)) ~= 0 )
				% In case the loadSpectrum function got into troubles
				% cause of some file format problems, it will return an empty
				% matrix "spectrum". Thus perform the following steps only in case
				% that hasn't happen.

				orig_data = (spectrum);
	
				% generate offset compensated and drift compensated data similar to fsc2
				oc_data = pretrigger_offset ( orig_data, time_params(3) );
				bl_oc_data = baseline_subtraction_fsc2 ( oc_data, 10 );

				disp_field = field;
				disp_data = spectrum;
				
				% set title of the figure
				titlestring = sprintf('File currently displayed: %s',filename);
				set(htext_title,'String',titlestring);

				% make togglebuttons visible, enable "Save" menu
				set([h_togglebutton_comp, h_togglebutton_disp],'Visible','On');
				set(efmh2,'Enable','on');

				% plot spectrum
				display_data ( time, disp_field/10, disp_data );
				
			end
		end
		
    end

	% LOAD SPECTRUM
	
	function [ spectrum, time, field ] = loadSpectrum(filename,fileFormat)
        
		if strcmp(fileFormat,'BES3T')
			% Test for the existence of the function "eprload" in the MATLAB(R)
			% search path and depending on that load the Bruker file or display
			% an error message. 
			% NOTE: The easyspin toolbox stores all functions in so-called
			% "p files" (not m files) that have the code "6" when checked for 
			% via the "exist" function.
			if ( (exist('eprload') ~= 2) && (exist('eprload') ~= 6) )
				% Assign the empty matrix to the return value "spectrum".
				% NOTE: Therefore, the size of the returned "spectrum" matrix
				% has to be checked after the call of loadSpectrum to proceed
				% accordingly.
				spectrum = [];
				fprintf('\n WARNING: The function eprload from the easyspin toolbox that is used\n to load Bruker BES3T files could not be found.\n')
				return;
			else
				% Use "eprload" from the easyspin toolbox to load Bruker BES3T file
				[ data,pars,absc ] = eprload(filename);
				% Assign the abscissa to the first column of the matrix "spectrum"
				spectrum(:,1) = absc;
				% Assign the real part of the data to the second column of the
				% matrix "spectrum"
				spectrum(:,2) = real(data);
			end
		else
			% In all other cases (according the file format)
			% assume ASCII data that are loadable via the "trEPR_read" function.
			[ data, parameters, fileFormat ] = trEPR_read(filename);
			
			if strcmp(fileFormat,'fsc2 file')
			
				time_params = [ ...
				  parameters.points ...
				  parameters.trig_pos ...
				  parameters.length_ts ...
				];

				time = trEPR_timeAxis ( time_params );
				
				field = [ ...
				  min([parameters.field_start parameters.field_stop]) : ...
				  abs(parameters.field_stepwidth) : ...
				  max([parameters.field_start parameters.field_stop]) ...
				];
				
				field_params = [ ...
				  parameters.field_start ...
				  parameters.field_stop ...
				  parameters.field_stepwidth ...
				];
				
				frequency = parameters.frequency;
				
				spectrum = data;
				
				% Derive some additional parameters from the input parameters
				field_min = min([parameters.field_start parameters.field_stop]);
				field_max = max([parameters.field_start parameters.field_stop]);
				time_min = time_params(3)/time_params(1)*(time_params(2)-1);
				time_max = time_params(3)-(time_params(3)/time_params(1)*time_params(2));
				timestep_min = 1;
				timestep_max = time_params(1);
				timestep = 1;
			
			end
		end
	
	end
    
    % SAVE SPECTRUM CALLBACK
    
    function saveSpectrum_Callback(source,eventdata)

		switch disp_style
			case {'time slice'}
				SaveDialogTitle = sprintf('Save time slice to file');
			case {'B_0 slice'}
				SaveDialogTitle = sprintf('Save B_0 spectrum to file');
			case {'2D display'}
				SaveDialogTitle = sprintf('Save 2D spectrum to file');
		end
    
	    [FileName,PathName,FilterIndex] = uiputfile( ...
	      {'*.dat','ASCII data file (*.dat)'; ...
	       '*.*','All files (*.*)'}, ...
	      SaveDialogTitle...
	    );

		if ( isstr(FileName) )
		
			[ disp_data_rows, disp_data_cols ] = size(disp_data);
		
			switch disp_style
				case {'time slice'}
				    int_ub = slider_val_field + field_integrationWindow - 1;
					if ( (field_integrationWindow > 1) && (int_ub <= disp_data_rows) )
						saveData = mean(disp_data(slider_val_field : int_ub,:));
					else
						saveData = disp_data(slider_val_field,:);
					end
					ascii_save_timeslice ( ...
					  FileName, ...
					  saveData, ...
					  field_params, ...
					  time_params, ...
					  frequency ...
					);
				case {'B_0 slice'}
				    int_ub = slider_val_time + time_integrationWindow - 1;
					if ( (time_integrationWindow > 1) && (int_ub <= disp_data_rows) )
						saveData = mean(disp_data(:,slider_val_time : int_ub)');
					else
						saveData = disp_data(:,slider_val_time);
					end
					ascii_save_spectrum ( ...
					  FileName, ...
					  saveData, ...
					  field_params, ...
					  time_params, ...
					  frequency ...
					);
				case {'2D display'}
					ascii_save_2Dspectrum ( ...
					  FileName, ...
					  disp_data, ...
					  field_params, ...
					  time_params, ...
					  frequency ...
					);
			end

		end
						
    end


 	% HELP ABOUT callback
	
	function helpAbout_Callback(source, eventdata)
		rev = revision;
		aboutString = sprintf('This is revision %s of GUI_fsc2_display.\n\n(c) 2007/08, Till Biskup',rev);
		msgbox(aboutString,'About','modal');
	end
	
	% FUNCTION FOR DISPLAYING THE DATA
	% Cause the display depends on the display style (2D, B_0, time slice) but the
	% user should be able to toggle between these display modes without any problem
	% this general display function is used to display the data dependend on the
	% actual display style.
	
	function display_data(dtime,dfield,ddata)
	
		[ ddata_rows, ddata_cols ] = size(ddata);

		switch disp_style
			case {'time slice'}
			    int_ub = slider_val_field + field_integrationWindow - 1;
				if ( (field_integrationWindow > 1) && (int_ub <= ddata_rows) )
					plot( ...
					  dtime, ...
					  mean(ddata(slider_val_field : int_ub,:)) ...
					);
				else
					plot(dtime,ddata(slider_val_field,:));
				end
				ylim([min(min(ddata)) max(max(ddata))]);
				xlim([min(dtime) max(dtime)]);
				xlabel('{\it time} / \mus');ylabel('{\it intensity} / a.u.');
			case {'B_0 slice'}
			    int_ub = slider_val_time + time_integrationWindow - 1;
				if ((time_integrationWindow > 1) && (int_ub <= ddata_cols))
				    plot_data = mean(ddata(:, slider_val_time : int_ub)');
					plot( ...
					  dfield, ...
					  plot_data ...
					);
				else
					plot(dfield,ddata(:,slider_val_time));
				end
				ylim([min(min(ddata)) max(max(ddata))]);
				xlim([min(dfield) max(dfield)]);
				xlabel('{\it magnetic field} / mT');ylabel('{\it intensity} / a.u.');
			case {'2D display'}
				mesh(dtime,dfield,ddata);
				view(2);
				xlim([min(dtime) max(dtime)]);
				ylim([min(dfield) max(dfield)]);
				xlabel('{\it time} / \mus');ylabel('{\it magnetic field} / mT');
		end
	
	end
	
	function revision = revision
		revision = strrep(strrep('$Revision$','Revision: ',''),'$','');
		revision = revision(1:length(revision)-1);
	end

end

%*******
