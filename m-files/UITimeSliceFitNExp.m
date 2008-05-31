% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* interactive_programs.trEPR/UITimeSliceFitNExp.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/06/13
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	fit function to data
%
% SYNOPSIS
%	UITimeSliceFitNExp
%
% DESCRIPTION
%	fit function to data
%
% INPUT PARAMETERS
%	
%
% OUTPUT PARAMETERS
%	
%
% EXAMPLE
%	
%
%
% DEPENDS ON
%	* trEPR toolbox v0.1.0 or higher
%	* timeSliceFunNExp.m
%	* MATLAB(TM)
%	* fminsearch
%
% SOURCE

function UITimeSliceFitNExp

	fprintf('\n%% FUNCTION CALL: $Id$\n%%');
	
	% check for the availability of routines we depend on
	
	% Find out whether we are called by MATLAB(TM) or GNU Octave

	if ( exist('discriminate_matlab_octave') == 2 )
		% let's check whether the routine performing the discrimination
		% is available...

		program = discriminate_matlab_octave;
		
		if ( program ~= 'Matlab' )
		
			error('\n  Sorry, it seems that you run this function with %s instead of MATLAB(TM).\n  This function makes heavy use of MATLAB(TM)''s handling of graphics\n  Therefore the further processing of this function will stop now...',program);
		
		end
	    
	else
		% that means if the variable "program" isn't set yet and the routine
		% performing the discrimination isn't available...
	
		fprintf('\nSorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\nThis function will behave as if it is called within MATLAB(TM)...\nBe aware: In the case that is not true you can run into problems!');
		
		program = 'Matlab';
			
		% set variable to default value
	
	end;

	if ( exist('timeSliceFunNExp') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'timeSliceFunNExp');

	elseif ( exist('read_fsc2_data') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'read_fsc2_data');

	elseif ( exist('pretrigger_offset') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'pretrigger_offset');

	elseif ( exist('fminsearch') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'fminsearch');
	
	end

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help fitRoutine" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help fitRoutine" to get help.',nargout);

	end


	% ...and here the 'real' stuff goes in
	
	description = [ ...
		'%% -------------------------------------------------------------------------------------\n'...
		'%% SHORT DESCRPTION OF THE PROGRAM\n'...
		'%% ===============================\n%%\n'...
		'%% This program is intended to be used to simulate the time slices of transient EPR,\n'...
		'%% measurements with a multi-exponential approach of the form:\n'...
		'%% \n'...
		'%%     y = C(1)*exp(-t/tau(1)) + ... + C(n)*exp(-t/tau(n))\n'...
		'%% \n'...
		'%% The program asks first for two data files, one with the "signal" time slice,\n'...
		'%% another with the "off-resonant" time slice.\n'...
		'%% \n'...
		'%% The off-resonant time slice will be subtracted from the signal time slice.\n'...
		'%% \n'...
		'%% Next, the program asks for the number of fit parameters and afterwards for\n'...
		'%% the values of these parameters to use as a first guess to start with.\n'...
		'%% \n'...
		'%% Dependend on the number of fit parameters an n-exponential function will be used\n'...
		'%% to simulate the time slice and to fit this simulation to the recorded data.\n'...
		'%% \n'...
		'%% (WW) IMPORTANT NOTICE:\n'...
		'%% (WW) -----------------\n'...
		'%% (WW) In the moment this program is capable\n'...
		'%% (WW) of handling ABSORPTIVE time slices only!\n'...
		'%% \n'...
		'%% -------------------------------------------------------------------------------------\n%%'...
	];
	
	fprintf('\n');
	fprintf(description);
	
%-% start_logging;
	
	% First, ask for the file with the recorded data the simulation should be fitted to
	% and the file for the off-resonant time slice to compensate the time slice
	% and as well for the number and starting guess of the fit parameters

	global datafilename
%-%	datafilename = '/Users/till/Data/transient/XLDC/H2O/XlDC_080K_20070620-TS/XlDC-080K-45dB-TS-3517G.dat';
%-%	datafilename = '/Users/till/Data/transient/XLDC/H2O/XlDC_080K_20070620-TS/XlDC-080K-45dB-TS-3498G.dat';

	helpTextDataFileName = [...
		'\n%% 1. RECORDED TIME SLICE (SIGNAL)'...
		'\n%% -------------------------------'...
		'\n%%'...
	];

	fprintf(helpTextDataFileName);

	datafilename = UIAskForExistingFileName;

	if (length(datafilename) == 0)
		return
	end

%-%	offresfilename = '/Users/till/Data/transient/XLDC/H2O/XlDC_080K_20070620-TS/XlDC-080K-45dB-TS-3390G.dat';

	helpTextOffResFileName = [...
		'\n%% 2. RECORDED TIME SLICE (OFFRES)'...
		'\n%% -------------------------------'...
		'\n%%'...
	];

	fprintf(helpTextOffResFileName);

	offresfilename = UIAskForExistingFileName;

	if (length(offresfilename) == 0)
		return
	end

    start = UIAskForFitParameters;
	
	% Then, read in the recorded data the simulation should be fitted to
	% and the file for the off-resonant time slice to compensate the time slice

	% read time slice from fsc2 file
%%%	[ ts,f,fp,sp,tp ] = read_fsc2_data ( datafilename );
%%%	[ orts,orf,orfp,orsp,ortp ] = read_fsc2_data ( offresfilename );

    [ data, params, fileFormat ] = trEPR_read( datafilename );
    f = params.frequency;
    fp = [ params.field_start : params.field_stepwidth : params.field_stop ];
    tp = [ params.points params.trig_pos params.length_ts ];
    ts = data(:,1)'
    
    [ ordata, orparams, orfileFormat ] = trEPR_read( offresfilename );
    orf = params.frequency;
    orfp = [ params.field_start : params.field_stepwidth : params.field_stop ];
    ortp = [ params.points params.trig_pos params.length_ts ];
    orts = ordata(:,1)';

	% test whether the signal time slice is absorptively or emissively polarized
	% and in the latter case abort further processing

	if ( max(max(ts)) < abs(min(min(ts))) )
		% max ( max ( <matrix> ) ) gives a scalar, max ( <matrix> ) a vector
		% thus, here we need the former...
		
		stringErrorMessageEmissiveTimeSlice = [ ...
			'\n%% -------------------------------------------------------------------------------------\n%%'...
			'\n%% (EE) ERROR:'...
			'\n%% (EE) ------'...
			'\n%% (EE) You provided an emissively polarized time slice for the fit.'...
			'\n%% (EE) Currently, the program is not able to handle those time slices.'...
			'\n%% (EE) Aborting...'...
			'\n%% \n'...
		];
		
		fprintf(stringErrorMessageEmissiveTimeSlice);
		
		return;
	end

	% compensate fluctuations via pretrigger offset	
	ts = pretrigger_offset (ts, tp(2));
	orts = pretrigger_offset (orts, ortp(2));

	% get single vector from recorded spectra
	% and omit the pretrigger part of the time slice
	y = ts(:,tp(2):length(ts(1,:)));
	[ yrows, ycols ] = size(y);
	if ( yrows > 1 ) 
	   y = mean(y);
	end
	
	ory = orts(:,ortp(2):length(orts(1,:)));
    [ oryrows, orycols ] = size(ory);
    if ( oryrows > 1 ) 
       ory = mean(ory);
    end
	
	dy = y - ory;
    
    % Just to avoid stupid mistakes because the user applied two times the same file
    % (for signal and off-resonant time slice), check for the maximum of y

    [ maxValueDy ] = max(dy);

    if ( maxValueDy == 0 )
    
        disp('foo!')
        y = y;
    
    else
    
        y = dy;
    
    end

	% "smart" normalization to a maximum around 1
	% This is used to take into account that we have some noise on the experimental
	% data that we can account for in this way.
	%
	% IMPORTANT: This works in the moment only for absorptive time slices...
	[maxValue,maxIndex] = max(y);
	
	normalizationRange = 5;
	normalizationFactor = mean(y(1,maxIndex-normalizationRange:1:maxIndex+normalizationRange));
	y = y*(1/normalizationFactor);
	
	% create time axis from time parameters of the recorded file
	t = 0 : tp(3)/tp(1) : tp(3)-(tp(3)/tp(1)*tp(2));

	% plot the recorded data and set up the graphics window for
	% continuous display of the simulation to be fitted to the recorded data
	plot(t,y,'r');
	hold on;
	h = plot(t,y,'b');
	hold off;

	title('Recorded data'); ylim([0 1.2])

	% Invoke FMINSEARCH. It minimizes the error returned from FITFUN
	% by adjusting the parameters.
	% It returns the final value of the parameters.
	% Use an output function to plot intermediate fits.
	% We use an anonymous function to pass additional parameters t, y, h to the
	% output function. 
	outputFcn = @(x,optimvalues,state) fitoutputfun(x,optimvalues,state,t,y,h);
	options = optimset('OutputFcn',outputFcn,'TolX',1e1,'MaxFunEvals',1e3,'MaxIter',1e3);
	estimated_parameters = fminsearch(@(x)fitfun(x,t,y),start,options);
	
	
	% Plot results of the fit as a nice table
	estimated_parameters_size = size(estimated_parameters);
	estimated_parameters_rows = estimated_parameters_size(1);
	estimated_parameters_cols = estimated_parameters_size(2);

	% create string containing the fitted function
	string_fitted_fun = createFittedFunString(estimated_parameters);
      
	fprintf('\n%% -------------------------------------------------------------------------------------\n');
	fprintf('%% Parameters fitted\n');
	fprintf('%% =================\n%%\n');
	fprintf('%%     START                   FITTED\n');
	fprintf('%% n   C_n         tau_n       C_n         tau_n\n');
	
	for j = 1:estimated_parameters_rows
	    fprintf('%s %i   %+09.4f   %+08.4f    %+09.4f   %+07.4f\n','%',j,start(j,1),start(j,2),estimated_parameters(j,1),estimated_parameters(j,2));
	end

	fprintf('%%\n%% fitted function\n%%\n');
	fprintf('%%    %s\n%%\n',string_fitted_fun);
	fprintf('%% -------------------------------------------------------------------------------------\n%%');

	
	% Save figure to a file
	% The filename used is the file basename from the time slice fitted
	% Therefore, first get file path and file basename of the time slice fitted
	GraphicsSaveFilenamePath = get_file_path(datafilename);
	GraphicsSaveFileBasename = get_file_basename(datafilename);
	GraphicsSaveFilename = [ GraphicsSaveFilenamePath GraphicsSaveFileBasename ];

	save_figure(GraphicsSaveFilename);
	
%-%	stop_logging;

	% For starting the prompt in a new line...
	fprintf('\n');

return

function parameters = UIAskForFitParameters
%	UIAskForFitParameters asks the user to type in the number and values of the
%	fit parameters used as starting guess for the simulation and fit and returns 
%	the parameters typed in

	explanation = [...
		'\n%% 3. FIT PARAMETERS'...
		'\n%% -----------------'...
		'\n%% '...
		'\n%% Now you''re asked for the number of exponentials used to fit the function'...
		'\n%% and the values of the parameters used as starting guess for the fit.'...
		'\n%% '...
		'\n%% Please note: For each exponential there are two parameters: C and tau'...
		'\n%% '...
		'\n%%   C * exp ( -t / tau )'...
		'\n%% '...
		'\n%% For two exponentials a good starting guess for the four parameters is'...
		'\n%% '...
		'\n%%   C_1 =  10, tau_1 = 1'...
		'\n%%   C_2 = -10, tau_2 = 5'...
		'\n%% '...
	];
	
	fprintf(explanation);
	
	nFitParameters = '';
	while (length(nFitParameters)==0)
		nFitParameters = input('\n% How many exponentials do you want to use for the fit? (Minimum is 2)\n     ','s');
		nFitParameters = str2num (nFitParameters);
		if (nFitParameters < 2)
		  nFitParameters = '';
		end
	end;
	
	for j = 1 : nFitParameters
	
		outputTextParameterC = sprintf('\n%% Please typein the value for the parameter C_%i\n     ',j);
		outputTextParameterTau = sprintf('\n%% Please typein the value for the parameter tau_%i\n     ',j);
	
		parameterC = '';
		while (length(parameterC)==0)
			parameterC = input(outputTextParameterC,'s');
			parameterC = str2num (parameterC);
		end;
		parameterTau = '';
		while (length(parameterTau)==0)
			parameterTau = input(outputTextParameterTau,'s');
			parameterTau = str2num (parameterTau);
		end;
		
		parameters(j,1) = parameterC;
		parameters(j,2) = parameterTau;
	
	end

	fprintf('\n%% -------------------------------------------------------------------------------------\n%%');

return

function string_fitted_fun = createFittedFunString(parameters)
%	createFittedFunString(parameters) returns the function simulating the time slice
%	with the parameters fitted to the recorded data set.

	parameters_size = size(parameters);
	parameters_rows = parameters_size(1);
	parameters_cols = parameters_size(2);

	string_fitted_fun = 'y = 1-(';
	for j = 1:parameters_rows
	    string_fitted_fun = sprintf('%s%+6.4f*exp(-t/%6.4f)',string_fitted_fun,parameters(j,1),parameters(j,2));
	end
	string_fitted_fun = sprintf('%s)',string_fitted_fun);

return

function err = fitfun(parameters,t,y)
%FITFUN Used by FITROUTINE.
%   FITFUN(parameters,t,y) returns the error between the data and the values
%   computed by the current function of the parameters.
%
%   FITFUN assumes a function of the form
%
%     y =  C(1)*exp(-t/tau(1)) + ... + C(n)*exp(-t/tau(n))
%
%   with n coefficients C and n time constants tau as parameters.
%
%	Depends on the external simulation function timeSliceFunNExp
%	for multi-exponential fit of the data

	z = timeSliceFunNExp(t,parameters);
	err = norm(z-y);

return


function stop = fitoutputfun(parameters,optimvalues,state,t,y,handle)
%FITOUTPUT Output function used by FITROUTINE
%	FITOUTPUTFUN(parameters,optimvalues,state,t,y,handle) is used to plot
%	intermediate fits of the simulation.
%
%	This function is based on an idea realized within the MATLAB(TM)
%	set of examples.

	global datafilename;

	stop = false;
	
	% Obtain new values of fitted function at 't'
	z = timeSliceFunNExp(t,parameters);

	switch state
	    case 'init'
	        set(handle,'ydata',z)
	        drawnow
	        title('Recorded data and fitted function');

	    case 'iter'
	        set(handle,'ydata',z)
	        drawnow

	    case 'done'

			string_fitted_fun = createFittedFunString(parameters);

			datafilebasename = get_file_basename (datafilename);
			titlestring = sprintf('%s: recorded data and fitted function\nfun: %s',datafilebasename,string_fitted_fun);
			title(titlestring);
			xlabel('time / us');
			set(gca,'XGrid','on');
			set(gca,'YGrid','on');
			
			% draw vertical line at max position of simulation
			hold on;
			ylimits = get (gca,'YLim');
			[maxvalue, maxindex] = max(z);
			xpos_max = [ t(maxindex) t(maxindex) ];
			yvalues_vertical_line = [ ylimits(1) ylimits(2) ];
			plot(xpos_max, yvalues_vertical_line,'m--');

			% draw horizontal line at 1/e intensity of simulation
			xlimits = get (gca,'XLim');
			xpos_1e = [ xlimits(1) xlimits(2) ];
			yvalues_1e_line = [ (maxvalue/exp(1)) (maxvalue/exp(1)) ];
			plot(xpos_1e, yvalues_1e_line,'m-.');

			legend('recorded data','fitted values','maximum','1/e');
			
			hold off;
	end

return
%******
