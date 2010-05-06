% Copyright (C) 2008 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/readMetaGenFile.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2008 Till Biskup
%	This file is free software
% CREATION DATE
%	2008/02/22
% VERSION
%	$Revision: 528 $
% MODIFICATION DATE
%	$Date: 2008-02-22 16:26:56 +0100 (Fr, 22 Feb 2008) $
% KEYWORDS
%	metaGen, metadata
%
% SYNOPSIS
%	metadata = readMetaGenFile ( filename )
%	metadata = readMetaGenFile ( filename, params )
%
% DESCRIPTION
%	readMetaGenFile reads in a dsc-file containing metadata in a way that conforms
%	to the metaGen file format and puts them into a cascaded struct structure.
%
% INPUT PARAMETERS
%	filename (STRING)
%		string containing the name of the file to read the key:value
%		pairs from
%
%	params (STRUCT, OPTIONAL)
%		structure containing additional parameters
%
%		params.commentChar (STRING)
%			character used for comment lines
%
%			If not provided, the "%" character will be used as default value.
%
%		params.assignmentChar (STRING)
%			character used for the assignment of values to keys
%
%			If not provided, the "=" character will be used as default value.
%
%		params.blockStartChar (STRING)
%			character used for starting a block
%
%			If not provided, the "[" character will be used as default value.
%
% OUTPUT PARAMETERS
%	metadata (STRUCT)
%		cascaded structure containing the parameters from the file read
%		ordered by the blocks contained in the metaGen file
%
% EXAMPLE
%	Suppose you have a file "sample.dsc" containing some parameters:
%
%		% This is a sample file containing parameters
%		[general]
%		experiment: transient EPR
%		temperature: 274 K
%
%	The structure of this file (concerning comment and assignment characters)
%	conforms to the metaGen format and to the default settings of this function.
%
%	To read these parameters with the readMetaGenFile function, use
%
%		metadata = readMetaGenFile ( 'sample.dsc' );
%
%	and you will get the parameters in the structure named metadata.
%
%	In case you want to change the comment and/or the assignment character,
%	use the optional parameter params (of type STRUCT) as follows:
%
%		params.commentChar = '#';
%		params.assignmentChar = ':';
%		params.blockStartChar = ':';
%
%	That will make the function readMetaGenFile use the respective
%	characters for the comments and the assignments.
%
%	PLEASE NOTE that this does no longer conform to the metaGen format.
%
%	The call of the function together with the optional parameter would
%	look like the following:
%
%		metadata = readMetaGenFile ( 'sample2.conf', params );
%
%	suggesting that the file "sample2.conf" is of the format specified via
%	the additional parameter "params".
%
% TODO
%	* Change handling of whitespace characters (subfunctions) thus that it is really
%	  all kinds of whitespace that is dealt with, not only spaces.
%
% SOURCE

function [ metadata ] = readMetaGenFile ( filename, varargin )

	fprintf('\n%% FUNCTION CALL: $Id: readMetaGenFile.m 528 2008-02-22 15:26:56Z till $\n%%\n');

	% check for the right number of input and output parameters

	if ( nargin < 1 ) || ( nargin > 2 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help readMetaGenFile" to get help.',nargin);

	end

	if ( nargout ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help readMetaGenFile" to get help.',nargout);

	end


	% check for correct format of the input parameters


	% Uncomment the following lines if necessary

	if ( ~isstr(filename) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help readMetaGenFile" to get help.','filename');

	end

	if ( length(filename) == 0 )

		error('\n\tThe function is called with an empty string for the input argument %s.\n\tPlease use "help CatalogueOfSpectraPage" to get help.','filename');

	end

	if ( nargin == 2 )
	
		params = varargin{1};
	
		if ~isstruct(params)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help readParametersFromFile" to get help.','params');
				% get error if function is called with the wrong format of the
				% input parameter 'params'

		end

		if ( isfield(params,'commentChar') && ~isstr(params.commentChar) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help readParametersFromFile" to get help.','params.commentChar');

		end

		if ( isfield(params,'assignmentChar') && ~isstr(params.assignmentChar) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help readParametersFromFile" to get help.','params.assignmentChar');

		end

		if ( isfield(params,'blockStartChar') && ~isstr(params.blockStartChar) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help writeMetaGenFile" to get help.','params.blockStartChar');

		end
		
	end


	% check for the availability of the routines we depend on

	% Uncomment the following lines if necessary

%	if ( exist('trEPR_read_fsc2_file.m') ~= 2 )
%		error('\n\tThe function %s this function critically depends on is not available.\n','trEPR_read_fsc2_file');
%	end

	% ...and here the 'real' stuff goes in

	
	% defining some parameters

	if ( ismember({'params'},who) && isfield(params,'commentChar') && length(params.commentChar) > 0 )
	
		commentChar = params.commentChar;

	else

		commentChar = '%';
		
	end
	
	if ( ismember({'params'},who) && isfield(params,'assignmentChar') && length(params.assignmentChar) > 0 )
	
		assignmentChar = params.assignmentChar;

	else

		assignmentChar = ':';
		
	end
	
	if ( ismember({'params'},who) && isfield(params,'blockStartChar') && length(params.blockStartChar) > 0 )
	
		blockStartChar = params.blockStartChar;

	else

		blockStartChar = '[';
		
	end

	% open file

	% save opening of the file that's name is provided by the variable 'filename'

	if ( exist( filename ) == 2 )
		% if the provided file exists

		% set file identifier to standard value
		fid=0;				

		while fid < 1
			% while file not opened

			% try to open file 'filename' and return fid and message
			[fid,message] = fopen(filename, 'r');

			if fid == -1
				% if there are any errors while trying to open the file

				% display the message from fopen
				disp(message)
				
			end
			% end "if fid"
		end
		% end while loop
		
	else	
		% If the file provided by filename does not exist

		% assign empty values to all output parameters
		metadata = [];

		% display an error message and abort further operation
		error('\n\tFile %s not found\n\tAbort further operation...', filename);
	
	end;

	% read parameters to structure
	
	blockname = '';
	
	while ( ~feof(fid) )
	
		readLine = fgetl(fid);
		
		if ( isstr(readLine) && ( index(readLine, commentChar ) ~= 1 ) && ( length(readLine ) ~= 0 ) )
		
			if ( index(readLine, blockStartChar ) == 1 )
			
				% set blockname
				% assume thereby that blockname resides within brackets
			    blockname = readLine(2:length(readLine)-1);
			
			else

                [names] = regexp(readLine,...
                    '(?<key>[a-zA-Z0-9._-]+)\s*=\s*(?<val>.*)',...
                    'names');

                if ( ismember({'metadata'},who)  && isfield(metadata,blockname) )
					evalString = sprintf('fieldExists = isfield(metadata.%s,''%s'');',blockname,names.key);
					eval(evalString);
					if ( fieldExists )
						% get value from that field
						evalString = sprintf('oldFieldValue = metadata.%s.%s;',blockname,names.key);
						eval(evalString);
					
						% print warning message telling the user that the field gets overwritten
						% and printing the old and the new field value for comparison
						fprintf('\n%% WARNING: Field ''%s.%s'' still existed and will be overwritten.\n%%          original value: ''%s''\n%%          new value     : ''%s''\n',blockname,key,oldFieldValue,val);
					end
				end
				
				evalString = sprintf('metadata.%s.%s=''%s'';',blockname,names.key,names.val);
				eval(evalString);
				
			end
		
		end
	
	end
	
	
	% save close file

	while fid > 2
		% the fids 0, 1 and 2 are reserved for special purposes (input, output, error)
		% that's why every other file identifier (file handle) has a number > 2
	
		% try to close the file
		status = fclose(fid);

		% test whether the closing was successful
		if status == -1
			% if there are any errors while trying to close the file
		
			error('\n\tFile %s could not be closed:\n\t%s', filename, status);
						% display the message from fclose
						
		elseif status == 0
		
			% set file identifier to exit while loop
			fid = -1;
						
		end				% end "if fid"
		
	end					% end while loop


end % end of main function


function str = removeTrailingWhiteSpace ( str )

	if ( length(str) > 1 )

		while (str(length(str)) == ' ')
	
			str = str(1:length(str)-1);
	
		end
		
	elseif ( ( length(str) == 1 ) && ( strcmp(str,' ') == 1 ) )
		% if str is only a whitespace character
		% set str to empty string

		str = '';
	
	end

end % end of subfunction


function str = removeLeadingWhiteSpace ( str )
	
	if ( length(str) > 1 )

		while (str(1) == ' ')
	
			str = str(2:length(str));
	
		end
		
	elseif ( ( length(str) == 1 ) && ( strcmp(str,' ') == 1 ) )
		% if str is only a whitespace character
		% set str to empty string
		
		str = '';
	
	end

end % end of subfunction

%******
