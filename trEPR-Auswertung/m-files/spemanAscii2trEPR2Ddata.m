% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/spemanAscii2trEPR2Ddata.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/07/06
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	SPEMAN, ASCII, trEPR toolbox, 2D ASCII
%
% SYNOPSIS
%	spemanAscii2trEPR2Ddata
%
% DESCRIPTION
%	This program converts the multiple ASCII files from SPEMAN to a single file
%	readable with the ascii_read_2Dspectrum function.
%
% COMPATIBILITY
%	In the very moment this program is designed to be used with GNU Octave only
%	due to the nasty behaviour of MATLAB(TM) not to accept the "#" character
%	as starting a comment.
%
% INPUT PARAMETERS
%	filebasename
%
%	noSlices (optional)
%
%
% OUTPUT PARAMETERS
%	filename (optional)
%
% EXAMPLE
%	
%
%
% SOURCE

function [ varargout ] = spemanAscii2trEPR2Ddata ( filebasename, varargin )

	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin < 1 ) || ( nargin > 2 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help spemanAscii2trEPR2Ddata" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help spemanAscii2trEPR2Ddata" to get help.',nargout);

	end

	if ( nargin == 2 )
	
	  noSlices = varargin{1};
	
	end

	% check for correct format of the input parameters


	% ...and here the 'real' stuff goes in
	
	tempFirstFileName = sprintf('%s.%03.0f',filebasename,1);
	fprintf('\nReading file %s',tempFirstFileName);
	timeSlice = load(tempFirstFileName);

	timeAxis = timeSlice(:,1);
	
	% generate timeParameters vector from time axis
	
	timeAxisNoPoints = length(timeSlice);
	[valueMinTimeAxis,indexMinTimeAxis] = min(abs(timeAxis));
	timeAxisTrigPos = indexMinTimeAxis;
	timeAxisStepWidth = (timeAxis(length(timeAxis))-timeAxis(1))/(length(timeAxis)-1);
	timeAxisLengthMicroseconds = ( timeAxis(length(timeAxis))-timeAxis(1) + timeAxisStepWidth ) * 10e5;
	
	timeParams = [ timeAxisNoPoints, timeAxisTrigPos, timeAxisLengthMicroseconds ];
	
	twoDimData(1,:) = timeSlice(:,2)';
	
	if ( noSlices > 1 )
	
		for j = 2:noSlices
	
			tempLastFileName = sprintf('%s.%03.0f',filebasename,j);
			fprintf('\nReading file %s',tempLastFileName);
			timeSlice = load(tempLastFileName);
		
			twoDimData(j,:) = timeSlice(:,2)';
	
		end
		
	else
	
		tempLastFileName = sprintf('%s.%03.0f',filebasename,1);
		
	end
	
	twoDimFileName = sprintf('%s.dat',filebasename);

	% read out leading comment of the first and the last file for filling the fieldParams values

	[ B0Start, frequencyStart] = readLeadingCommentOfSpemanAsciiFile ( tempFirstFileName );
	[ B0Stop, frequencyStop] = readLeadingCommentOfSpemanAsciiFile ( tempLastFileName );
	
	if ( (frequencyStart ~= '') && (frequencyStop ~= '') )
	
		mwFrequency = ( frequencyStart + frequencyStop ) / 2;
		
	else
	
		mwFrequency = 0;
	
	end
	
	if ( noSlices > 1 )
	
		fieldAxisStepWidth = abs(B0Start - B0Stop) / (noSlices - 1);
		fieldParams = [ B0Start, B0Stop, fieldAxisStepWidth ];
		ascii_save_2Dspectrum ( twoDimFileName, twoDimData, fieldParams, timeParams, mwFrequency );
		
	else
	
		fieldAxisStepWidth = 0;
		fieldParams = [ B0Start, B0Stop, fieldAxisStepWidth ];
		ascii_save_timeslice ( twoDimFileName, twoDimData, fieldParams, timeParams, mwFrequency );
		
	end

	if ( nargout > 0 )
	
		varargout{1} = twoDimFileName;
	
	end
	
	
function [ B0, frequency ] = readLeadingCommentOfSpemanAsciiFile ( filename );

	% save opening of the file that's name is provided by the variable 'filename'

	if ( exist( filename )	== 2 )
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
		spectrum=[];field_params=[];time_params=[];frequency=[];

		% display an error message and abort further operation
		error('\n\tFile %s not found\n\tAbort further operation...', filename);
	
	end;
	
	% read the leading commentary of the fsc2 file line by line
	% and extract the necessary parameters:
	
	read = '#';					% variable 'read' set to '%' to initially
									% match the while loop condition
									
	is_right_file = 0;				% initialize variable with default value;
	
	while index (read, '#' ) == 1	% while read line starts with '#'
	
		read = fgetl ( fid );			% linewise read of file
		
		
		% check for the file whether it is written with the function
		% ascii_save_spectrum or not.
		% This is done by the criterium that the first line of such a file would
		% contain the SVN ID tag of the version of the function, starting with
		% "$ID: ascii_save_2Dspectrum"
 	
		file_marker = findstr ( read, '# Source : ' );
	
		if ( length(file_marker) > 0 )
	
			is_right_file = 1;
	
		end

		if index(read,'B0 = ') > 0
		
			indRead = index(read,'B0 = ');
			tempString = substr( read, indRead+5, length(read) );
			B0 = str2num( substr( tempString, 1, index(tempString,' ') ) );
		
		end
		
		if index(read,'mw = ') > 0
		
			indRead = index(read,'mw = ');
			tempString = substr( read, indRead+5, length(read) );
			frequency = str2num( substr( tempString, 1, index(tempString,' ') ) );

		end
	
	end								% end of while loop

	fclose( fid );					% calling internal function (see below) to close the file

%	if ( is_right_file == 0 )
		% in the case the file read is not written with the function
		% ascii_save_spectrum

		% assign empty values to all output parameters
%		B0=[];frequency=[];	

		% display an error message and abort further operation
%		error('\n\tHmmm... %s does not look like a file\n\twritten with the function ascii_save_spectrum...\n\tAbort further operation...', filename);
	
%	end

%******
