% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* GUI/trEPR_fsc2_display.m
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
%	trEPR_fsc2_display
%
% DESCRIPTION
%	This function provides a fsc2-like display with the possibility
%	to select time and B_0 slices. It makes use of the MATLAB(TM)
%	GUI possibilities.
%
%	This function appeared in version > 0.1.0 of the trEPR toolbox.
%
% INPUT PARAMETERS
%	no input parameters yet
%
% OUTPUT PARAMETERS
%	no output parameters yet
%
% DEPENDS ON
%	trEPR_read_fsc2_file.m
%	GUI_fsc2_display.m
%
% EXAMPLE
%	To display the 2D transient EPR data measured with fsc2, simply typein
%
%		trEPR_fsc2_display
%
%	and follow the instructions.
%
% SOURCE

function trEPR_fsc2_display

	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_fsc2_display" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_fsc2_display" to get help.',nargout);

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

	if ( exist('trEPR_read_fsc2_file.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'trEPR_read_fsc2_file');


	elseif ( exist('GUI_fsc2_display.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'GUI_fsc2_display');

	end
	

	% ...and here the 'real' stuff goes in

%%	[ data,frequency,field_params,scope_params,time_params,filename,trigger_pos ] = trEPR_read_fsc2_file;
	

    % Ask the user for a file name to read and if file name is valid, read data

    filename = ' ' ;                % set filename to empty value
                                % the space is necessary not to confuse GNU Octave

    while (exist(filename) == 0)    % while there is no valid filename specified
                                % This would be better done with a do...until loop
                                % but silly MATLAB(R) doesn't support this...

        filename = input ( '\n% Please enter a filename of a fsc2 data file:\n   ', 's' );

        if (length( filename ) > 0) % If the user provided a filename

            if program == 'Octave'      % if we're called by GNU Octave (as determined above)
  
                filename = tilde_expand ( filename );
                                % expand filenames with tilde
    
            end                     % end if program == 'Octave'
  
            if (exist(filename) == 0)
  
                fprintf ( 'File not found!' );
    
            end

        else                            % In case the user didn't provide a filename

            fprintf ( 'You have not entered any file name!\n\n' );
                                % just print a short message and return to main loop
            filename = 'foo.bar';
                                    % set a default filename for the 'exist(filename)' test
                                    % needs a filename and cannot work with an empty string
  
        end

    end     % end of while exist(filename) loop
	
	% read data
	
	[ data, params, fileFormat ] = trEPR_read ( filename );
	
    % assigning parameters
    
    if ( ismember({'params'},who) && isfield(params,'field_start') && length(params.field_start) > 0 )
    
        fieldParams(1) = params.field_start;

    else

        error('No value for %s found in the file %s.','field_start',filename);
        
    end
    
    if ( ismember({'params'},who) && isfield(params,'field_stop') && length(params.field_stop) > 0 )
    
        fieldParams(2) = params.field_stop;

    else

        error('No value for %s found in the file %s.','field_stop',filename);
        
    end
    
    if ( ismember({'params'},who) && isfield(params,'field_stepwidth') && length(params.field_stepwidth) > 0 )
    
        fieldParams(3) = params.field_stepwidth;

    else

        error('No value for %s found in the file %s.','field_stepwidth',filename);
        
    end
    
    if ( ismember({'params'},who) && isfield(params,'points') && length(params.points) > 0 )
    
        timeParams(1) = params.points;

    else

        error('No value for %s found in the file %s.','points',filename);
        
    end
    
    if ( ismember({'params'},who) && isfield(params,'trig_pos') && length(params.trig_pos) > 0 )
    
        timeParams(2) = params.trig_pos;

    else

        error('No value for %s found in the file %s.','trig_pos',filename);
        
    end
    
    if ( ismember({'params'},who) && isfield(params,'length_ts') && length(params.length_ts) > 0 )
    
        timeParams(3) = params.length_ts;

    else

        error('No value for %s found in the file %s.','length_ts',filename);
        
    end
	
	
	titlestring = filename;
	
	GUI_fsc2_display (data, fieldParams, timeParams, titlestring);

%******
