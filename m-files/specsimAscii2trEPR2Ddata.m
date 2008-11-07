% : Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%
%****f* global_scripts/specsimAscii2trEPR2Ddata.m
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
%	specsimAscii2trEPR2Ddata
%
% DESCRIPTION
%	This program converts the multiple ASCII files from SPEMAN to a single file
%	readable with the ascii_read_2Dspectrum function.
%
%   The SPEMAN format is a format used in Freiburg to handle data measured at the
%   transient EPR spectrometer. In principle the SPEMAN files are text files that
%   have a three line comment with leading hashes (#) and the data itself saved as
%   two long columns of ASCII numbers.
%
%   Every single slice is saved in a single SPEMAN file. Thus SPEMAN files have
%   a file basename and as extension a number running from one up to the number of
%   slides.
%
% COMPATIBILITY
%	Due to some major changes the program now works on MATLAB(TM) and should do so
%   as well with GNU Octave, but is still untested with the latter.
%
% INPUT PARAMETERS
%	filebasename (STRING)
%       the basename of the SPEMAN files that should be read in
%
%       WARNING: Currently, the program suggests that the file extension
%                consists of exactly THREE digits.
%
%	noSlices (optional)
%       the number of slices (thus, the number of files)
%
% OUTPUT PARAMETERS
%	filename (optional)
%       the filename the data have been saved to
%
%       This file has the same basename as the files read in and the file
%       extension 'dat'.
%
% EXAMPLE
%	
%   Suppose you are in a directory with multiple SPEMAN files in whose basename
%   is 'Samplecczc'. To convert these files you simply type
%
%       specsimAscii2trEPR2Ddata ( 'Samplecczc' );
%
%   and then you will get the data read in and saved to a file with the same
%   basename and the file extension 'dat'.
%
% SOURCE

function [ varargout ] = specsimAscii2trEPR2Ddata ( filebasename, varargin )

	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin < 1 ) || ( nargin > 2 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help specsimAscii2trEPR2Ddata" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help specsimAscii2trEPR2Ddata" to get help.',nargout);

	end

	if ( nargin == 2 )
	
	  noSlices = varargin{1};
	  
	else 
	
	   noSlices = 0;
	
	end

	% check for correct format of the input parameters


	% ...and here the 'real' stuff goes in
	
	% if the user has not provided the optional parameter "noSlices"
	% try to get the number of slices by reading the directory
	
	if ( noSlices == 0 )
	
	   files = sprintf('%s*', filebasename);
	   filelist = dir(files);
	   noSlices = length(filelist);
	   
	   fprintf('\nTrying to read in %i files. That will take a while...\n', noSlices);
	
	end
	
	% PROBLEM:
	% The program suggests for the moment that there are only up to 999
	% single SPEMAN files and that the extensions consist of three numerical
	% digits.
	%
	% This has to be changed at some time.
	%
	% A possible solution would be to get one filename from the directory,
	% such as
	%
	%    filelist(1).name
	%
	% and then to extract the file extension (via get_file_extension) and to
	% check for the length of that file extension:
	%
	%    ext = get_file_extension ( filelist(1).name );
	%    extlength = length(ext);
	%
	% So far things are easy. But then one has to use the eval command to
	% create a command that adjusts the format parameter of the sprintf line...
	
	tempFirstFileName = sprintf('%s.%03.0f',filebasename,1);
	fprintf('\nReading file %s',tempFirstFileName);

    [timeSlice, header] = readDataOfspecsimAsciiFile (tempFirstFileName);

	timeAxis = timeSlice(:,1);
	
	% generate timeParameters vector from time axis
	
	timeAxisNoPoints = length(timeSlice);
	[valueMinTimeAxis,indexMinTimeAxis] = min(abs(timeAxis));
	timeAxisTrigPos = indexMinTimeAxis;
	timeAxisStepWidth = (timeAxis(length(timeAxis))-timeAxis(1))/(length(timeAxis)-1);
	timeAxisLengthMicroseconds = ( timeAxis(length(timeAxis))-timeAxis(1) + timeAxisStepWidth ) * 10e5;
	
	timeParams = [ timeAxisNoPoints, timeAxisTrigPos, timeAxisLengthMicroseconds ];
	
	twoDimData(1,:) = timeSlice(:,1)';
	
	if ( noSlices > 1 )
	
		for j = 2:noSlices
	
			tempLastFileName = sprintf('%s.%03.0f',filebasename,j);

            if ( exist(tempLastFileName) == 2 )

                fprintf('\nReading file %s',tempLastFileName);
                [timeSlice, lastheader] = readDataOfspecsimAsciiFile (tempLastFileName);
		
                twoDimData(j,:) = timeSlice(:,1)'; 

            else
            
                tempLastFileName = sprintf('%s.%03.0f',filebasename,j-1);
                [timeSlice, lastheader] = readDataOfspecsimAsciiFile (tempLastFileName);
              
            end 
	
		end
		
	else
	
		tempLastFileName = sprintf('%s.%03.0f',filebasename,1);
        [timeSlice, lastheader] = readDataOfspecsimAsciiFile (tempLastFileName);
		
	end
	
	twoDimFileName = sprintf('%s.dat',filebasename);

	% read out leading comment of the first and the last file for filling the fieldParams values
    
	[ B0Start, frequencyStart] = readLeadingCommentOfSpecsimAsciiFile ( header );
	[ B0Stop, frequencyStop] = readLeadingCommentOfSpecsimAsciiFile ( lastheader );
	
	if ( (frequencyStart ~= 0) && (frequencyStop ~= 0) )
	
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

    end


function [ data, header ] = readDataOfspecsimAsciiFile ( filename );

    numHeaderLines = 5;
    
    data = [];

    fid = saveOpeningFile ( filename );

    if ( fid > 2 ) 

    i = 1;
    
        for k = 1 : numHeaderLines
    
            header{k} = fgetl ( fid );
  
        end
    
    while feof(fid) == 0
            
        if (feof(fid) == 0)
        
            tline = fgetl ( fid );
        
            numbers = sscanf( tline, '%f%f%f%f' );

            data = [data numbers'];

        end
    
    end
    
    fclose ( fid );

    end
    
    data = data';

    end

function [ B0, frequency ] = readLeadingCommentOfSpecsimAsciiFile ( header );
	
    B0 = 0;
    frequency = 0;
									
	is_right_file = 0;				% initialize variable with default value;
		
    for k = 1 : length(header)
		
		read = header{k};
		
		% check for the corrent file format
		% This is done by the criterium that the first line of such a file would
		% contain a string "Source : transient"
 	
		file_marker = findstr ( read, 'Source : transient' );
	
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

%	if ( is_right_file == 0 )
		% in the case the file read is not written with the function
		% ascii_save_spectrum

		% assign empty values to all output parameters
%		B0=[];frequency=[];	

		% display an error message and abort further operation
%		error('\n\tHmmm... %s does not look like a file\n\twritten with the function ascii_save_spectrum...\n\tAbort further operation...', filename);
	
%	end
    
    end


function fid = saveOpeningFile ( filename )

    % save opening of the file that's name is provided by the variable 'filename'

    if ( exist( filename )  == 2 )
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
        warning('\n\tFile %s not found\n\tThat may influence the further processing...', filename);
        fid = -1;
        
    end;

    end


%******
