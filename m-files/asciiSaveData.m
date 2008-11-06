% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/asciiSaveData.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/10/18
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	ASCII data, save, comments, description
%
% SYNOPSIS
%	[ filename ] = asciiSaveData ( filename, data, params );
%
% DESCRIPTION
%	The function provides the user with the possibility to save data to ASCII files 
%	together with arbitrary parameters and description.
%
% INPUT PARAMETERS
%	filename (STRING, OPTIONAL)
%		string containing the filename the data should be saved to
%
%		In case no filename is provided at the function call, the user will be
%		asked interactively to provide one.
%
%	data (MATRIX)
%		(numerical) data that should be saved in ASCII format to a file
%
%	params (STRUCT, OPTIONAL)
%		optional parameters, only strings
%
%		Each key-value pair of the struct is saved in the comment header of the
%		ASCII file as follows:
%
%		% <key1>: <value1>
%		% <key2>: <value2>
%
%	If the function is called with only one input parameter, this will be used as
%	data.
%
%	If the function is called with two input parameters, the type of the first
%	parameter is checked and used either as filename in case it is a string or as
%	data in case it is numeric.
%
%	In the first case the second parameter has to be numeric and holds the data
%	that are saved to the file in ASCII format.
%
%	In the second case the second parameter has to be a structure and is treated
%	as parameter params containing the key-value pairs that are saved in the header.
%
%	If the function is called with three parameters, they have to be provided in
%	the order "filename", "data", "params".
%
% OUTPUT PARAMETERS
%	filename (STRING, OPTIONAL)
%		string containing the name of the ASCII file the data have been saved to.
%
%		Useful especially if the function is called without "filename" as an
%		input parameter and the filename provided by the user during the runtime
%		of the program is needed later on.
%
% EXAMPLE
%	
%
%
% SOURCE

function [ varargout ] = asciiSaveData ( varargin )

	fprintf('%% FUNCTION CALL: $Id$\n');

	% check for the right number of input and output parameters

	if ( nargin < 1 ) || ( nargin > 3 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help asciiSaveData" to get help.',nargin);

	end

	if ( nargout > 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help asciiSaveData" to get help.',nargout);

	end


	% check for correct format of the input parameters
	% For details about the behaviour depending on the number and type of input
	% parameters see the help in the commentary header of this function.

	if ( nargin == 1 )
	
		data = varargin{1};
		
	elseif ( nargin == 2 )
	
		if ( isstr(varargin{1}) )
		
			filename = varargin{1};
			
			if ( isnumeric(varargin{2}) )
			
				data = varargin{2};
			
			else
			
				error('\n\tThe function is called with the wrong format for the %s input argument.\n\tPlease use "help asciiSaveData" to get help.','second');
			
			end
			
		elseif ( isnumeric(varargin{1}) )
		
			data = varargin{1};
			
			if ( isstruct(varargin{2}) )
			
				params = varargin{2};
			
			else
			
				error('\n\tThe function is called with the wrong format for the %s input argument.\n\tPlease use "help asciiSaveData" to get help.','second');
			
			end
		
		else
		
			error('\n\tThe function is called with the wrong format for the %s input argument.\n\tPlease use "help asciiSaveData" to get help.','first');
		
		end
		
	else % if ( nargin == 3 )
	
		if ( isstr(varargin{1}) )
		
			filename = varargin{1};
			
		else
	
			error('\n\tThe function is called with the wrong format for the %s input argument.\n\tPlease use "help asciiSaveData" to get help.','first');

		end
	
		if ( isnumeric(varargin{2}) )
		
			data = varargin{2};
			
		else
	
			error('\n\tThe function is called with the wrong format for the %s input argument.\n\tPlease use "help asciiSaveData" to get help.','second');

		end
	
		if ( isstruct(varargin{3}) )
		
			params = varargin{3};
			
		else
	
			error('\n\tThe function is called with the wrong format for the %s input argument.\n\tPlease use "help asciiSaveData" to get help.','third');

		end
		
	end

	% Uncomment the following lines if necessary

%	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )
%
%		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help asciiSaveData" to get help.','data');
%
%	end


	% check for the availability of the routines we depend on

	% Uncomment the following lines if necessary

%	if ( exist('trEPR_read_fsc2_file.m') ~= 2 )
%		error('\n\tThe function %s this function critically depends on is not available.\n','trEPR_read_fsc2_file');
%	end

	% ...and here the 'real' stuff goes in

	% if no filename was provided, ask the user for it

	if ( ismember({'filename'},who) == 0 )
	
		filename = '';
		
		while ( length(filename) == 0 )
		
			filename = input ( '\n% Please enter a filename for the data to save to:\n   ', 's' );
		
		end
	
	end

	% check whether the output file already exists

	filename = checkFileExistence (filename);
	
	
	% open file given by filename for write access
	
	fid=0;				% set file identifier to standard value
	
	while fid < 1 		% while file not opened
	
		[fid,message] = fopen(filename, 'wt');
						% try to open file 'filename' and return fid and message
		if fid == -1		% if there are any errors while trying to open the file
		
			error('\n\tFile %s could not be opened for write:\n\t%s', filename, message);
						% display the message from fopen
						
		end				% end "if fid"
		
	end					% end while loop


	% write header

	comment_char = '%';

	fprintf(fid, '%s This file has been written by the routine $Id$\n', comment_char);
	fprintf(fid, '%s\n', comment_char);

	if ( ismember({'params'},who) )

		fprintf(fid, '%s The following additional parameters have been provided by the operator:\n', comment_char);
		
		keys = fieldnames (params);
		
		for k = 1 : length(keys)
            
            val = getfield(params,char(keys(k)));
            if (isnumeric(val))
                val = num2str(val);
    			fprintf(fid, '%s%s %s: %s\n', comment_char, comment_char, char(keys(k)), val);
            elseif (isstruct(val))
                kkeys = fieldnames(val);
                for l = 1 : length(kkeys)
                    vval = getfield(val,char(kkeys(l)));
                    fprintf(fid, '%s%s %s.%s: %s\n', comment_char, comment_char, char(keys(k)), char(kkeys(l)), char(vval));
                end
            else
    			fprintf(fid, '%s%s %s: %s\n', comment_char, comment_char, char(keys(k)), val);
            end

		end

	end	

	% write data
	
	[ datarows, datacols ] = size(data);
	
	for i = 1 : datarows

		fprintf(fid, '%+016.12f\t',data(i,1:datacols-1));
		fprintf(fid, '%+016.12f',data(i,datacols));
		fprintf(fid,'\n');
	
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


function filename = checkFileExistence (filename)

	% check whether output file already exists
	
	% if the filename exists than the user will be asked whether he wants
	% to overwrite the file. Otherwise he has the possibility to typein a
	% different filename that will be checked as well for existence.
	
	if ( exist( filename ) == 2 )
		% if the file still exists
	
		menutext = sprintf('The file you provided to save the ASCII data to\n(%s) seems to exist.\nDo You really want to overwrite? Otherwise you can choose another file name.',filename);
	
		answer = menu(menutext,'Yes','No');
			% ask the user what to do now
	  
		if answer == 1
			% if user chose to proceed anyway
	  
			delete ( filename );
	  
		else					% in the other case
	  
	  		filename = '';
	  
			while ( length(filename) == 0)
				% as long as the user had not provided
				% a filename
  
			    filename = input ( 'Please enter another filename for the ASCII data to be saved in:\n   ', 's' );
    					% prompt the user for a filename for the log file

			    if length( filename ) > 0	
					% If the user provided a filename
							
					if exist( filename )
	  					% if the file still exists
	
						menutext = sprintf('The file you provided (%s) seems to exist.\nDo You really want to overwrite? Otherwise you can choose another file name.',filename);
	
						answer = menu(menutext,'Yes','No');
		   					% ask the user what to do now
	  
						if answer == 1
							% if user chose to proceed anyway
	  
							delete ( filename );
          
						else
							% in the other case
	  
							filename = '';
							% set filename to the empty string
							% thus going through the while-loop once again
						
						end
							% end if answer
	
					else	
						% if the file doesn't exist yet
	  
					end		% end if exist(filename)
					
				end		% end if length(filename) > 0
				
			end		% end while loop
			% here should go in some functionality that allows the user
			% to typein another file name, perhaps with displaying the
			% filename that still exists...

		end		% end if answer
	
	end		% end if exist(filename)

end		% end subfunction

%******
