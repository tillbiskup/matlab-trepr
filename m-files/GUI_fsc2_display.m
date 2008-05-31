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
%	This function appeared in version > 0.1.0 of the trEPR toolbox.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured data
%
%	field_params
%		a 3x1 vector containing of three values, the "field parameters"
%
%		These field parameters are:
%
%			start_field
%				the start position of the field sweep given in Gauss (G)
%			end_field
%				the stop position of the field sweep given in Gauss (G)
%			field_step_width
%				the step width by which the field is swept given in Gauss (G)
%
%	time_params
%		a 3x1 vector containing of three values, the "time parameters"
%	
%		These time parameters are:
%
%			no_points
%				number of points of the time slice
%			trig_pos
%				position of the trigger pulse
%			length_ts
%				length of the time slice in microseconds
%
%	titlestring
%		a string that is used to set the title
%
% OUTPUT PARAMETERS
%	no output parameters yet
%
% DEPENDS ON
%	pretrigger_offset.m
%	baseline_subtraction_fsc2.m
%
% EXAMPLE
%	Normally, GUI_fsc2_display is called with the function fsc2_display, but
%	one can call it directly like this:
%
%		GUI_fsc2_display (data, field_params, time_params, titlestring)
%
%	DATA, FIELD_PARAMS, and TIME_PARAMS are best read from an fsc2 file with the
%	function trEPR_read_fsc2_file, TITLESTRING is a simple string that is used to
%	display in the GUI what data are shown, normally the file name of the data file.
%
% SOURCE

function GUI_fsc2_display (data, field_params, time_params, titlestring)
 
	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 4 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help GUI_fsc2_display" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help GUI_fsc2_display" to get help.',nargout);

	end


	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help GUI_fsc2_display" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help GUI_fsc2_display" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help GUI_fsc2_display" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help GUI_fsc2_display" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'


	% TIME_PARAMS

	elseif ~isnumeric(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help GUI_fsc2_display" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help GUI_fsc2_display" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help GUI_fsc2_display" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'
			
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
	global slider_val_time;
	global slider_val_timestep;
	global slider_val_field;
	
	% set some of the globals to defined values	
	disp_style = '2D display';
	slider_val_time = time_params(2);
	slider_val_field = 1;
	GUItitle = 'fsc2-like display of transient EPR spectra';

	% Derive some additional parameters from the input parameters
	field_min = min([field_params(1) field_params(2)]);
	field_max = max([field_params(1) field_params(2)]);
	field = [field_min : abs(field_params(3)) : field_max];
	time_min = time_params(3)/time_params(1)*(time_params(2)-1);
	time_max = time_params(3)-(time_params(3)/time_params(1)*time_params(2));
	time = [ -time_min : time_params(3)/time_params(1) : time_max];
	timestep_min = 1;
	timestep_max = time_params(1);
	timestep = 1;

	orig_data = (data);
	
	% generate offset compensated and drift compensated data similar to fsc2
	oc_data = pretrigger_offset ( orig_data, time_params(3) );
	bl_oc_data = baseline_subtraction_fsc2 ( oc_data, 10 );
	
	% set the displayed data and field variables
	disp_data = orig_data;
	disp_field = field;
	
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
		'pos',[10 125 100 30],'parent',h_togglebutton_disp,'HandleVisibility','off');
	u1 = uicontrol('Style','Toggle','String','time slice',...
		'TooltipString','display time slice',...
		'pos',[10 75 100 30],'parent',h_togglebutton_disp,'HandleVisibility','off');
	u2 = uicontrol('Style','Toggle','String','B_0 slice',...
		'TooltipString','display B_0 spectrum',...
		'pos',[10 25 100 30],'parent',h_togglebutton_disp,'HandleVisibility','off');
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

	% TEXT FIELD for the title
	htext_title = uicontrol('Style','text','String',titlestring,...
		'FontSize',14,...
		'Position',[200,475,400,15]);
	set(htext_title,'BackgroundColor',get(f,'Color'));

	% GRAPHICS WINDOW, called "axes" in MATLAB(TM), for displaying the data
	ha = axes('Units','Pixels','Position',[200,50,400,400]); 
   
	% STEP 3: Initialize the GUI.
	% Change units to normalized so components resize automatically.
	set([f,ha,hslider,htext_slider_value,htext_slider_value2,h_togglebutton_comp,h_togglebutton_disp,htext_title,htext_slider_measure,htext_slider_measure2],'Units','normalized');
	% Create a plot in the axes.
	display_data ( time, disp_field/10, disp_data );
	% Assign the GUI a name to appear in the window title.
	set(f,'Name',GUItitle)
	% Disable the builtin menus in the menu bar.
	set(f,'MenuBar','none');
	% Move the GUI to the center of the screen.
	movegui(f,'center')
	% Set the slider to inactive
	set(hslider,'Enable','inactive');
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
				set(hslider,'Enable','on');
				set(htext_slider_measure,'String','B_0 / mT');
				set(hslider,'Min',0);
				set(hslider,'Max',length(field)-1);
				set(hslider,'SliderStep',[1/(length(field)-1),(1/(length(field)-1))*10]);
				set(hslider,'Value',slider_val_field-1);
				set(htext_slider_value,'String',num2str(field(slider_val_field)/10));
				display_data ( time, disp_field/10, disp_data );
			case {'B_0 slice'}
				set(hslider,'Enable','on');
				set(htext_slider_measure,'String','time / us');
				set(htext_slider_measure2,'String','timestep');
				set(hslider,'Min',0);
				set(hslider,'Max',length(time)-1);
				set(hslider,'SliderStep',[1/(length(time)-1),(1/(length(time)-1))*10]);
				set(hslider,'Value',slider_val_time-1);
				set(htext_slider_value,'String',num2str(time(slider_val_time)));
				set(htext_slider_value2,'String',num2str(slider_val_time));
				display_data ( time, disp_field/10, disp_data );
			case {'2D display'}
				set(hslider,'Enable','inactive');
				set(htext_slider_measure,'String','');
				set(htext_slider_value,'String','');
				display_data ( time, disp_field/10, disp_data );
		end
	end
	
	% FUNCTION FOR DISPLAYING THE DATA
	% Cause the display depends on the display style (2D, B_0, time slice) but the
	% user should be able to toggle between these display modes without any problem
	% this general display function is used to display the data dependend on the
	% actual display style.
	
	function display_data(dtime,dfield,ddata)

		switch disp_style
			case {'time slice'}
				plot(dtime,ddata(slider_val_field,:));
				ylim([min(min(ddata)) max(max(ddata))]);
				xlim([min(dtime) max(dtime)]);
				xlabel('time / us');ylabel('intensity / a.u.');
			case {'B_0 slice'}
				plot(dfield,ddata(:,slider_val_time));
				ylim([min(min(ddata)) max(max(ddata))]);
				xlim([min(dfield) max(dfield)]);
				xlabel('B_0 field / mT');ylabel('intensity / a.u.');
			case {'2D display'}
				mesh(dtime,dfield,ddata);
				view(2);
				xlim([min(dtime) max(dtime)]);
				ylim([min(dfield) max(dfield)]);
				xlabel('time / us');ylabel('B_0 field / mT');
		end
	
	end

end

%*******
