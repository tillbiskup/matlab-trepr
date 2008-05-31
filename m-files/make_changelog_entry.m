% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/make_changelog_entry.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/06/11
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	changelog
%
% SYNOPSIS
%	make_changelog_entry
%
% DESCRIPTION
%	Creates a changelog entry from the user input to copy and paste into the file
%	that is edited.
%
%	Such CHANGELOG entries that can be automatically extracted from the file are
%	a useful tool on the way to a more complete CHANGELOG file of the whole project.
%
%	The script can be invoked without parameters. In that case it will prompt the
%	user interactively for the comment and, if necessary, for an author string.
%
% INPUT PARAMETERS
%	textstring (optional)
%		used in the non-interactive mode
%		contains the string that is used as CHANGELOG item
%
%	authorstring (optional)
%		used in the non-interactive mode
%		contains the author information for the specific CHANGELOG entry
%
%		The format of this string should be something like the following:
%
%			Till Biskup <till.biskup@physik.fu-berlin.de>
%
% OUTPUT PARAMETERS
%	there are no output parameters in the moment
%
% CONFIGURATION FILE
%	make_changelog_entry makes use of a config file, named .make_changelog_entry.rc
%	that may be located either in the same directory as the make_changelog_entry file
%	or in the home directory of the user (the latter may not work with Microsoft OS).
%
%	This file consists of lines starting with a key in capital letters, followed by
%	a colon and afterwards by the value. For the moment there are only two keys
%	in use:
%		MARK: <marker>
%		AUTH: <author line>
%
%	The marker may be set to something like "% CHANGELOG" (not followed by any
%	whitespace characters), for the author line refer to the description of the
%	second (optional) input parameter.
%
% TODO
%	* CHANGELOG items spanning multiple lines
%
% EXAMPLE
%	For full interactive use just typein
%
%		make_changelog_entry
%
%	For noninteractive use you may typein
%
%		make_changelog_entry ( '<changelog item>' );
%
%	or, in case you have not specified a .make_changelog_entry.rc file (see above)
%
%		make_changelog_entry ( '<changelog item>', '<author line>' );
%
% SOURCE

function make_changelog_entry ( varargin )

	fprintf('\n% FUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin < 0 ) || ( nargin > 2 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help make_changelog_entry" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help make_changelog_entry" to get help.',nargout);

	end


	% check for correct format of the input parameters

	if ( nargin >= 1 )
	
		textstring = varargin {1};
	
		% TEXTSTRING
	
		if ~isstr(textstring)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help make_changelog_entry" to get help.','textstring');
				% get error if function is called with the wrong format of the
				% input parameter 'textstring'
	
		elseif length(textstring) == 0

			error('\n\tThe function is called with an empty string as the %s.\n\tPlease use "help make_changelog_entry" to get help.','textstring');
				% get error if function is called with an empty 'textstring'

		end
	
	elseif (nargin == 2 )
	
		authorstring = varargin {2};
	
		% AUTHORSTRING
	
		if ~isstr(authorstring)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help make_changelog_entry" to get help.','authorstring');
				% get error if function is called with the wrong format of the
				% input parameter 'authorstring'
	
		elseif length(textstring) == 0

			error('\n\tThe function is called with an empty string as the %s.\n\tPlease use "help make_changelog_entry" to get help.','authorstring');
				% get error if function is called with an empty 'authorstring'

		end
	
	end


	% ...and here the 'real' stuff goes in

	% predefine marker and authorline
	marker = '% CHANGELOG';
	authorstring = '';
	
	% get directory this file is located in
	installdir = strrep(which('make_changelog_entry.m'), 'make_changelog_entry.m', '');
	
	% check for .make_changelog_entry.rc file
	rcfile = '.make_changelog_entry.rc';
	
	installdir_rcfile = sprintf ('%s%s',installdir,rcfile);
	homedir_rcfile = sprintf ('~/%s',rcfile);

	if ( exist( installdir_rcfile ) == 2 )
	
		rcfile = installdir_rcfile;
	
	elseif ( exist( homedir_rcfile ) == 2 ) 
	
		rcfile = homedir_rcfile;
	
	end
	
	if ( exist( rcfile ) == 2 )

		% set file identifier to standard value
		fid=0;				

		while fid < 1
			% while file not opened

			% try to open file 'rcfile' and return fid and message
			[fid,message] = fopen(rcfile, 'r');

			if fid == -1
				% if there are any errors while trying to open the file

				% display the message from fopen
				disp(message)
				
			end
			% end "if fid"
		end
		% end while loop

		read = '1';
		while ( read ~= -1 )
			read = fgetl(fid);
			
			if (isstr(read))
			
				if (index (read, 'MARK' ) == 1)
			
					marker = substr ( read, 7, length(read));
			
				elseif (index (read, 'AUTH' ) == 1)
			
					authorstring = substr ( read, 7, length(read));
			
				end
			end
		end
	
		fclose( fid );					% calling internal function (see below) to close the file

	end

	% get current date in an RFC-822 coform format
	rfc822datestring = sprintf('%s, %s +02:00',datestr(now,'ddd'), datestr(now,'dd mmm yyyy HH:MM:SS'));

	% if called with no arguments, prompt for CHANGELOG item
	
	if ( nargin == 0 )
		% in case that no input argument is provided		
		% ask user for a CHANGELOG item

		proceed = 0;
			% set variable for while condition to default value
	
		while (proceed == 0)
			% while proceed is set to zero
	
			textstring = input ( 'Please enter a CHANGELOG item:\n	 ', 's' );
				% prompt the user for a CHANGELOG item

			if length( textstring ) == 0	

				proceed = 0;
					% go through the while loop once again
	
			else	
				% if the user has provided an item
		
				proceed = 1;
					% set condition for while loop so that the while loop will not
					% passed through once again
	
			end
				% end if
		
		end
			% end while loop
		
	end
		% end if nargin == 0
	
	if ( length(authorstring) == 0 )
		% in case no .make_changelog_entry.rc file exists
		% ask user for a author string

		proceed = 0;
			% set variable for while condition to default value
	
		while (proceed == 0)
			% while proceed is set to zero
	
			authorstring = input ( 'Please enter an author line:\n	 ', 's' );
				% prompt the user for an author line

			if length( authorstring ) == 0	

				proceed = 0;
					% go through the while loop once again
	
			else	
				% if the user has provided an item
		
				proceed = 1;
					% set condition for while loop so that the while loop will not
					% passed through once again
	
			end
				% end if
		
		end
			% end while loop
		
	end
		% end if nargin == 0
	
	% for testing: define strings
	
	% create CHANGELOG ENTRY
	fprintf('\n----------------------------------------------------------------------\n');
	fprintf('%s DATE: %s\n',marker,rfc822datestring);
	fprintf('%s ITEM: %s\n',marker,textstring);
	fprintf('%s AUTH: %s\n',marker,authorstring);
	fprintf('----------------------------------------------------------------------\n\n');

%******
