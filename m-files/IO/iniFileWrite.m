% INIFILEWRITE Write metadata from a cascaded struct structure in a
% dsc-file in a way that conforms to the metaGen file format. 
%
% INPUT PARAMETERS
%	filename (STRING)
%		string containing the name of the file to read the key:value
%		pairs from
%
%	metadata (STRUCT)
%		cascaded structure containing the parameters from the file read
%		ordered by the blocks contained in the metaGen file
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
%		params.metaGenFormatVersion (STRING)
%			version number of the metaGenFormat
%
%			If not provided, the following value will be used:
%
%				0.1.0
%
%		params.headerFirstLine (STRING)
%			First line of the comment header starting the file
%
%			If not provided, the following line will be used:
%
%				% metaGen description file v.<metaGenFormatVersion>
%
%			with <metaGenFormatVersion> replaced by the respective value,
%			see above.
%
%		params.headerCreationDate (STRING)
%			Creation date of the metaGen file, if it gets modified by the current
%			write
%
%			The string should be of the form
%
%				yyyy-mm-dd hh:mm:ss
%
%			If not provided, the evaluation of the following statement will be used:
%
%				datestr(now,31);
%
%
% OUTPUT PARAMETERS
%	status (INTEGER, OPTIONAL)
%		status of the program after finishing
%
%		According to the UNIX philosophy, this status is "0" if everything
%		is in proper status, and different from "0" else.
%
% EXAMPLE
%	Suppose you have a cascaded structure "metadata" that contains several cascaded
%	"key:value" pairs - e.g. parameters written with the function readMetaGenFile -
%	that you want to store in a file and be able to read it automatically back 
%	to matlab or import to other systems.
%
%	Suppose further you want to save your parameters to the file "out.dsc".
%
%	In this case, simply write
%
%		iniFileWrite ( 'out.dsc', metadata );
%
%	If you want to add an additional parameter, something that you're supposed
%	to do, at least for adding a short description of what we have there,
%	use the optional parameter "commentHeader", a cell array:
%
%		commentHeader = {'These data are from my simulation'};
%		iniFileWrite ( 'out.dsc', metadata, commentHeader );
%
%	Suppose you want to automatically save the file name of the file you got
%	the data from you simulated. To get the filename into the cell array
%	used for the comment, use something as the following, supposing that the
%	variable "specFilename" contains the filename of the file the recorded
%	spectrum came from:
%
%		% creating an empty cell array
%		commentHeader = {[]};
%		% adding a first field to the array
%		commentHeader(1) = cellstr('These parameters refer to the data saved in the file')
%		commentHeader(2) = cellstr(filename);
%
%	Then you can use the same command as above:
%
%		iniFileWrite ( 'out.dsc', metadata, commentHeader );
%

%    Copyright (C) 2008 Till Biskup
%    $Revision: 559 $  $Date: 2008-02-29 09:01:47 +0100 (Fr, 29 Feb 2008) $

function [ varargout ] = iniFileWrite ( filename, metadata, varargin )

	fprintf('\n%% FUNCTION CALL: $Id: iniFileWrite.m 559 2008-02-29 08:01:47Z till $\n%%\n');

	% check for the right number of input and output parameters

	if ( nargin < 2 ) || ( nargin > 3 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help iniFileWrite" to get help.',nargin);

	end

	if ( nargout > 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help iniFileWrite" to get help.',nargout);

	end


	% check for correct format of the input parameters


	% Uncomment the following lines if necessary

	if ( ~isstr(filename) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','filename');

	end

	if ( length(filename) == 0 )

		error('\n\tThe function is called with an empty string for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','filename');

	end

	if ( nargin == 3 )
	
		if (isstruct(varargin{1}))
	
			params = varargin{1};
			
		elseif (iscell(varargin{1}))
		
			commentHeader = varargin{1};
		
		else

			error('\n\tThe function is called with the wrong format for %s.\n\tPlease use "help iniFileWrite" to get help.','one optional input argument');
				% get error if function is called with the wrong format of
				% one optional input parameter
			
		end
		
	end

	if ( nargin == 4 )
	
		if (isstruct(varargin{1}))
	
			params = varargin{1};
			
		elseif (iscell(varargin{1}))
		
			commentHeader = varargin{1};
		
		else

			error('\n\tThe function is called with the wrong format for %s.\n\tPlease use "help iniFileWrite" to get help.','the first optional input argument');
				% get error if function is called with the wrong format of
				% the first optional input parameter
			
		end
	
		if (isstruct(varargin{2}))
	
			params = varargin{2};
			
		elseif (iscell(varargin{2}))
		
			commentHeader = varargin{2};
		
		else

			error('\n\tThe function is called with the wrong format for %s.\n\tPlease use "help iniFileWrite" to get help.','the second optional input argument');
				% get error if function is called with the wrong format of
				% the second optional input parameter
			
		end
		
	end
	
	if ( ismember({'params'},who) )
	
		if ~isstruct(params)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','params');
				% get error if function is called with the wrong format of the
				% input parameter 'params'

		end

		if ( isfield(params,'commentChar') && ~isstr(params.commentChar) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','params.commentChar');

		end

		if ( isfield(params,'assignmentChar') && ~isstr(params.assignmentChar) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','params.assignmentChar');

		end

		if ( isfield(params,'blockStartChar') && ~isstr(params.blockStartChar) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','params.blockStartChar');

		end

		if ( isfield(params,'headerFirstLine') && ~isstr(params.headerFirstLine) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','params.headerFirstLine');

		end

		if ( isfield(params,'headerCreationDate') && ~isstr(params.headerCreationDate) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','params.headerCreationDate');

		end

		if ( isfield(params,'metaGenFormatVersion') && ~isstr(params.metaGenFormatVersion) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help iniFileWrite" to get help.','params.headerFirstLine');

		end
		
	end

	% ...and here the 'real' stuff goes in
	
	% Set output status to "0"
	% meaning that every error has to change that status.
	% The assignment of the "status" variable to the (optional) output
	% parameter is done as last step of the function.
	
	status = 0;

	
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
	
	if ( ismember({'params'},who) && isfield(params,'metaGenFormatVersion') && length(params.metaGenFormatVersion) > 0 )
	
		metaGenFormatVersion = params.metaGenFormatVersion;

	else

		metaGenFormatVersion = sprintf('0.1.1');
		
	end
	
	if ( ismember({'params'},who) && isfield(params,'headerFirstLine') && length(params.headerFirstLine) > 0 )
	
		headerFirstLine = params.headerFirstLine;

	else

		headerFirstLine = sprintf('%s metaGen description file v.%s', commentChar,metaGenFormatVersion);
		
	end
	
	if ( ismember({'params'},who) && isfield(params,'headerCreationDate') && length(params.headerCreationDate) > 0 )
	
		headerCreationDate = params.headerCreationDate;

	else

		headerCreationDate = datestr(now,31);
		
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

	% write parameters to file

	% First, write some header lines:
	% 1st line: reference to metaGen format
	% 2nd line: reference to this function
	% 3rd line: Date of writing the file
	% 4th line: Date of modifying the file

	headerSecondLine = sprintf('%s written with $Id: iniFileWrite.m 559 2008-02-29 08:01:47Z till $', commentChar);
	
	fprintf(fid,'%s\n',headerFirstLine);
	fprintf(fid,'%s\n',headerSecondLine);
	fprintf(fid,'%s Created: %s\n',commentChar,headerCreationDate);
	fprintf(fid,'%s Modified: %s\n',commentChar,datestr(now,31));
	
	% Check whether there exists a commentHeader cell array
	% and in that case, print it at the beginning of the file.

	if ( ismember({'commentHeader'},who) )
	
		for k = 1 : length(commentHeader)
		
			fprintf(fid,'%s %s\n',commentChar, char(commentHeader(k)));
			
		end
	
	end
	
	% Next, print the key:value pairs for each key in the structure
	
	blockNames = fieldnames(metadata);
	
	for k = 1 : length(blockNames)
	
		fprintf(fid,'\n[%s]\n',char(blockNames(k)));
	
		evalString = sprintf('fieldNames = fieldnames(metadata.%s);',char(blockNames(k)));
		eval(evalString);

		for l = 1 : length(fieldNames)
	
			evalString = sprintf('fieldValue = getfield(metadata.%s,char(fieldNames(l)));',char(blockNames(k)));
			eval(evalString);
				
			% in case the value is not a string, but numeric
			if (isnumeric(fieldValue))
				fieldValue = num2str(fieldValue);
			end
			evalString = sprintf('fprintf(fid,''%s%s %s\\n'');',char(fieldNames(l)),assignmentChar,fieldValue);
			eval(evalString);
	
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

	% Assign the status parameter to the (optional) output parameter.
	
	if (nargout > 1)
		varargout{1} = status;
	end


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
