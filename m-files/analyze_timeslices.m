% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****h* global_scripts/analyze_timeslice.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/05/09
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	trEPR, fsc2, time slice, exponential decay
%
% SYNOPSIS
%	analyze_timeslice
%
% DESCRIPTION
%	This global script helps the user to compensate and analyze
%	time slices recorded with the fsc2 program at a transient ESR
%	spectrometer.
%
%	Therefore it makes use of several routines written for this
%	special purpose and provides some additional features such as
%	to save all relevant data to a file thus making the parameters
%	of interest easily accessible.
%
% INPUT PARAMETERS
%	In the moment there are no input parameters
%
% OUTPUT PARAMETERS
%	In the moment there are no output parameters
%
% SOURCE


% check for the availability of the routines we depend on

if ( exist('trEPR_compensate_timeslice.m') ~= 2 )

	error('\n\tThe function %s this function critically depends on is not available.\n', 'trEPR_compensate_timeslice');
	
elseif ( exist('trEPR_expfit_timeslice.m') ~= 2 )

	error('\n\tThe function %s this function critically depends on is not available.\n', 'trEPR_expfit_timeslice');
	
elseif ( exist('discriminate_matlab_octave.m') ~= 2 )

	error('\n\tThe function %s this function critically depends on is not available.\n', 'discriminate_matlab_octave');
	
elseif ( exist('start_logging.m') ~= 2 )

	error('\n\tThe function %s this function critically depends on is not available.\n', 'start_logging');
	
elseif ( exist('stop_logging.m') ~= 2 )

	error('\n\tThe function %s this function critically depends on is not available.\n', 'stop_logging');
	
end;


tic;
	% set starting point for calculation of used time, just for fun...

% Just to tell the user what's going on...
% This message is not logged, thus it will be repeated after the start of logging

fprintf( '\nThis is the file $RCSfile$,\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to analyze time slices of transient ESR spectra\nrecorded with the fsc2 software.\n\nThe whole analyzing process is being logged in a file that''s name he user is\nasked to provide at the very beginning of the processing of this script.\n');

% First of all start logging

logfilename = start_logging;


% Then print some nice message

dateandtime = [datestr(now, 31), ' @ ', computer];

disp ( dateandtime )	% print current date and time and system

fprintf( '\nThis is the file $RCSfile$,\n\t$Revision$ from $Date$\n' );
fprintf( '\nFor a short description of what this program does\nplease type in ''help analyze_timeslices''.\n' );


% Find out whether we are called by MATLAB(R) or GNU Octave

global program;

[ program, prog_version ] = discriminate_matlab_octave;




exit_main_loop = 1;				% set exit condition for while loop

while exit_main_loop > 0			% main while loop
								% responsible for the possibility to analyze
								% more than one time_slice


	% here the main part of the functionality takes place

	% compensate the time slice

	[ts,t,field_position] = trEPR_compensate_timeslice;
	
	% exponential fit of compensated time slice

	[fp,tmax,t1e,dt1e,ff] = trEPR_expfit_timeslice ([t' ts']);
	
	% plot of fit results
	
	plot(ff(:,1),ff(:,2),t,ts);
	
	xlabel('time / \mus');
	ylabel('intensity / mV');
	
	title_string = sprintf('time slice at %06.2f mT B_0 field position',field_position/10);
	title(title_string);
	
	legend('exponential fit','measured time slice');
	

	% save and display values of interest

	summary(exit_main_loop,:) = [field_position/10, tmax, t1e, dt1e];
	
	fprintf('\n field position / mT   t_max / us   t_1/e / us   dt_1/e / us\n');
	fprintf('-------------------------------------------------------------\n');
	fprintf(' %06.2f                %07.4f      %07.4f      %07.4f\n',summary(exit_main_loop,:));
	
	% ask user what to do next: continue with another time slice or abort

	exit_answer = menu ( 'What do you want to do now?', 'Analyze another time slice', 'Exit program');
		% make menu that lets the user choose whether he wants to continue
		% with analyzing another time slice or to quit the program.

	if exit_answer == 1

		exit_main_loop = exit_main_loop + 1;
			% increase the while loop exit condition by 1
			% thus representing the current round of the loop

	elseif exit_answer == 2

		exit_main_loop = 0;
			% set the while loop exit condition

	end		% end of "if exit_answer" clause

end			% end of main while loop


% here some additional functionality such as the writing of the table
% with the results takes place...

% The information that should be placed at the end of the log file
% or otherwise in an additional file is as follows:
%
%	* name of the sample (ask user to type it in)
%	* table with values of interest:
%
%		field position | t_max | t_1/e | dt_1/e
%
%	* name of the files the figures have been saved to

fprintf('\n---------------------------------------------------------------------------\n');
fprintf('\nSUMMARY\n')

% ask the user for the name of the sample that should go into the log file

sample_name = input ('\nPlease type in the name of the sample and the other data relevant to this measurement\nsuch as the temperature at which the measurement took place, but not the B_0 field.\nThis will show up at the end of the log file in the summary.\n      ', 's');

fprintf('\nSample: %s\n', sample_name);

% write table with values of interest

fprintf('\n field position / mT   t_max / us   t_1/e / us   dt_1/e / us\n');
fprintf('-------------------------------------------------------------\n');

[rows_summary,cols_summary] = size(summary);

for m = 1:rows_summary

	fprintf(' %06.2f                %07.4f      %07.4f      %07.4f\n',summary(m,:));

end;

fprintf('-------------------------------------------------------------\n');


% At the very end stop logging...

stop_logging;


% print total time used;

total_time_used = toc;
fprintf ('\nThe total time used is %4.2f seconds\n', total_time_used);


% end of script

%*******