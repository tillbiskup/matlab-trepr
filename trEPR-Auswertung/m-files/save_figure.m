% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/save_figure.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/05/24
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(TM), figure, save, MATLAB(TM) figure format, EPS
%
% SYNOPSIS
%	save_figure
%
% DESCRIPTION
%	This small routine is intended to save the current figure window
%	to an EPS as well as to a MATLAB(TM) fig file.
%
%	Therefore the user will be asked interactively for a file basename.
%	In case this filename still exists the user has the choice between
%	overwriting and choosing another filename.
%
%	If we're running with MATLAB(TM) this program can get out whether
%	there is currently any open figure window or not. In the latter case
%	it will print out an error message and abort.
%
%	If we're running with a different platform than MATLAB(TM), e.g.
%	GNU Octave, this will alter a little bit the behaviour: There is no
%	check whether there are any open figure windows at the time of the call
%	of this function and the figure is saved only as an EPS file.
%
% INPUT PARAMETERS
%	filename (optional)
%		string containing the file BASENAME that is used to save the files to
%
%		IMPORTANT: You may only typein the file BASENAME because the figure is
%		saved in different formats with different file extensions that are
%		automatically added to the file basename given here.
%
% OUTPUT PARAMETERS
%	currently there are no output parameters
%
% DEPENDS ON
%	The routine depends on several other routines from the trEPR toolbox:
%	* discriminate_matlab_octave.m
%
% EXAMPLE
%	For full interactive use just typein
%
%		save_figure
%
%	For noninteractive use you may typein
%
%		save_figure ( '<file basename>' );
%
% SOURCE

function save_figure ( varargin )

	fprintf('\n%% FUNCTION CALL: $Id$\n%%');

	% check for the right number of input and output parameters

	if ( nargin > 1 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help save_figure" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help save_figure" to get help.',nargout);

	end

	if ( nargin )

	filename = varargin {1};
	
	% check for correct format of the input parameters
	
	% FILENAME
	
	if ~isstr(filename)
	
		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help read_fsc2_data" to get help.','filename');
			% get error if function is called with the wrong format of the
			% input parameter 'filename'
	
	elseif length(filename) == 0

		error('\n\tThe function is called with an empty string as the filename.\n\tPlease use "help read_fsc2_data" to get help.','filename');
			% get error if function is called with an empty 'filename'

	end
	
	end 


	% check for the availability of the routines we depend on
	
	% Find out whether we are called by MATLAB(TM) or GNU Octave

	if ( exist('discriminate_matlab_octave') == 2 )
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
	
	% Find out whether a figure window is open
	% and abort further operation in case no figure window is open
	
	if program == 'Matlab'	% if we're called by GNU Octave (as determined above)

		if ( length ( get(0,'CurrentFigure') ) == 0 )
		
			error('\n\tThere seems to be no open figure window in the moment.\n\tABORTING...\n',program);
		
		end

	else					% otherwise we assume that we're called by MATLAB(R)

		fprintf('\nWARNING: We''re currently running under %s.\nThat means that we cannot get out whether there are currently\nsome open figure windows...\nIf not you''re fully responsible for any strange behaviour...',program);

	end					% end of "if program" clause
	

	if ( nargin ) 
		% in case a file basename is provided as input parameter
	
	else 
	
	% ask user for a file basename to save the figure to

	proceed = 0;
		% set variable for while condition to default value
	
	while (proceed == 0)
		% while proceed is set to zero
	
		filename = input ( 'Please enter a file BASEname (without extension) for the figure to save to:\n	 ', 's' );
			% prompt the user for a filename for the figure file

		if length( filename ) > 0	
			% If the user provided a filename

			existing_fig_file = sprintf('%s.fig',filename);
			existing_eps_file = sprintf('%s.eps',filename);
							
			if ( exist( existing_fig_file ) || exist( existing_eps_file ) )
				% if the file still exists
	
				answer = menu('The provided file exists and will be overwritten. Do You really want to proceed?','Yes','No');
		 			% ask the user what to do now
		
				if answer == 1
					% if user chose to proceed anyway
		
				delete ( existing_fig_file );
				delete ( existing_eps_file );
					
				proceed = 1;		% set condition for while loop so that the while loop will not
								% passed through once again
		
				else	
					% in the other case
		
					proceed = 0;
						% go through the while loop once again

				end
					% end if answer
	
			else	
				% if the file doesn't exist yet
		
				proceed = 1;
					% set condition for while loop so that the while loop will not
					% passed through once again
	
			end
				% end if exists
	
		else	
			% In case the user didn't provide a filename
								
			proceed = 0;
	
		end
			% end of if length(filename) condition
		
	end
		% end while loop
								
	end
		% end if nargin condition

	% save figure as fig and EPS file

	fig_filename = sprintf ('%s.fig',filename);
	eps_filename = sprintf ('%s.eps',filename);

	% save figure as MATLAB(TM) fig file
	
	% NOTE: This will lead to problems when called with another program than MATLAB(TM).

	if program == 'Matlab'	% if we're called by GNU Octave (as determined above)

		saveas ( gcf, fig_filename )

	else					% otherwise we assume that we're called by MATLAB(R)

		fprintf('\n%% WARNING: You tried to save the file to a MATLAB(TM) fig file.\n\tThis will work only with MATLAB(TM), but you''re using %s...\n',program);

	end					% end of "if program" clause
	

	% save figure as EPS file

	if program == 'Octave'	% if we're called by GNU Octave (as determined above)

		print ( eps_filename, '-depsc2' );

	else					% otherwise we assume that we're called by MATLAB(R)

		print ( '-depsc2' , eps_filename );

	end					% end of "if program" clause
	

% CHANGELOG DATE: Tue, 12 Jun 2007 13:12:45 +02:00
% CHANGELOG ITEM: added call with filename as input parameter
% CHANGELOG AUTH: Till Biskup <till.biskup@physik.fu-berlin.de>

% CHANGELOG DATE: Tue, 12 Jun 2007 13:17:08 +02:00
% CHANGELOG ITEM: updated and added documentation according to the optional input parameter
% CHANGELOG AUTH: Till Biskup <till.biskup@physik.fu-berlin.de>

%******
