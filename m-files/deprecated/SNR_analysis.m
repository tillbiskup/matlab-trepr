% Copyright (C) 2008 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/SNR_analysis.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2008 Till Biskup
%	This file is free software
% CREATION DATE
%	2008/02/07
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	SNR, EPR, trEPR
%
% SYNOPSIS
%	SNR_analysis
%
% DESCRIPTION
%	Complete SNR analysis of a set of (transient) EPR spectra
%
%	The aim of this function is to get the SNR data from many scans of one sample
%	at one temperature so that one can sum them up in one point of a plot showing
%	either the temperature dependence of the signal amplitude or the amplitudes
%	for different mutants.
%
%	One problem is still that the concentration is not saved in the files in a way
%	that is machine-readable in a failsave way. Therefore this parameter has to be
%	provided per hand at least in some cases.
%
%	The function reads in a complete 2D dataset of transient EPR data, creates the
%	B_0 plot at a distinct position at the time axis, determines the signal to noise
%	for that B_0 spectrum and saves it to a vector.
%
%	As for a statistical analysis one should have at least three values and the scans
%	are (always) 2n scans (because of the low->high->low field sweep to get rid of
%	drifts due to magnetic field effects) normally one should provide at least four
%	scans for one SNR analysis.
%
%	At least in further versions of this function the user should have the possibility
%	to interact with the analysing process, such as to set manually the point in the
%	time domain the B_0 spectrum is taken at, the region of the B_0 spectrum that
%	counts as noise et cetera.
%
%	For controlling reasons a plot showing the taken B_0 spectrum together with a
%	marker for the region taken as noise and the point where the signal amplitude
%	is taken would be helpful that will be saved together with the data.
%
%	All data that are written should be saved in an own subdirectory.
%
% INPUT PARAMETERS
%	filenames (CELL ARRAY)
%		cell array of strings containing the names of the files
%		the SNR analysis should be performed for
%	
%	concentration (FLOAT)
%		concentration (in mM) of the sample
%
%		Used to normalize the signal amplitude to a standard value of 1 mM
%
%	params (STRUCT, OPTIONAL)
%		structure containing optional additional parameters
%
%		params.tpos (INTEGER)
%			time position the B_0 spectra are taken at
%
%			NOTE: This is not the time in us, but the position within the vector
%
%			If not provided, it defaults to 75 (being 1 us with "standard" settings)
%
%		params.B0halfwidth (INTEGER)
%			halfwidth of the integration window used for creating the B_0 spectra
%
%			If not provided, it defaults to 2, meaning that totally 5 spectra are
%			averaged to yield one B_0 spectrum
%
%		params.saveFileSuffix (STRING)
%			suffix for the ASCII data files holding the data from the B_0 spectra
%
%			If not provided, it defaults to "B0plot".
%
%		params.safeFileExtension (STRING)
%			file extension for the ASCII data files holding the data
%			from the B_0 spectra
%
%			If not provided, it defaults to "dat".
%
%		params.summaryFilename (STRING)
%			file name for the file used to save the summary in
%
%			If not provided, it defaults to "SNRanalysisResults.dat".
%
%		params.subdir (STRING)
%			directory name for the directory created to save all the files
%			that are created during running this function
%
%			If not provided, it defaults to the evaluated expression of
%			"sprintf('SNR-%s',datestr(now,'yyyymmdd'))".
%
%	
% OUTPUT PARAMETERS
%	sigAmpl (VECTOR, OPTIONAL)
%		vector containing the signal amplitudes for every file analyzed
%
%	sigAmplNorm (VECTOR, OPTIONAL)
%		vector containing the normalized signal amplitudes for every file analyzed
%
%		"Normalized" means in this context that they are divided by the
%		sample concentration given as second (obligatory) input parameter
%
%	statistics (2x2 MATRIX, OPTIONAL)
%		2x2 matrix containing the mean and std values for sigAmpl and sigAmplNorm
%
%		The first column contains the mean values, the second column the std values.
%
%	If only one (optional) output parameter is provided at the function call, it is
%	used as "sigAmpl" parameter, given two output parameters they are used as
%	"sigAmpl" and "sigAmplNorm" parameters. Thus, if one wants to have the statistics
%	one needs to provide all three (optional) output parameters
%
% EXAMPLE
%
%	First of all, we have to create a cell array containing of the file names.
%	This can be done in several ways, e.g.
%	
%		filenames = cell(4,1);
%		filenames(1) = {'SsDC_WT_240K-ns-01.dat'}
%		filenames(2) = {'SsDC_WT_240K-ns-02.dat'}
%		filenames(3) = {'SsDC_WT_240K-ns-03.dat'}
%		filenames(4) = {'SsDC_WT_240K-ns-04.dat'}
%
%	Now, we can invoke our function:
%
%		SNR_analysis ( filenames, concentration );
%
%	where 'concentration' is a float number providing the sample concentration in mM.
%
% SOURCE

function [ varargout ] = SNR_analysis ( filenames, concentration, varargin )

	fprintf('\n%% FUNCTION CALL: $Id$\n%%\n');

	% check for the right number of input and output parameters

	if ( nargin < 2 ) || ( nargin > 3 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help SNR_analysis" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 3 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help SNR_analysis" to get help.',nargout);

	end


	% check for correct format of the input parameters

	% FILENAMES

	if ( ~iscell(filenames) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help SNR_analysis" to get help.','filenames');

	end

	% CONCENTRATION

	if ( ~isnumeric(concentration) || ~isvector(concentration) || ~isscalar(concentration) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help SNR_analysis" to get help.','concentration');

	end

	% PARAMS
	
	if nargin > 2
	
		params = varargin{1};
	
		if ~isstruct(params)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help LaTeXtable" to get help.','params');
				% get error if function is called with the wrong format of the
				% input parameter 'params'
	
		end

		if ( isfield(params,'tpos') && ~isscalar(params.tpos) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help LaTeXtable" to get help.','params.tpos');

		end

		if ( isfield(params,'B0halfwidth') && ~isscalar(params.B0halfwidth) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help LaTeXtable" to get help.','params.B0halfwidth');

		end

		if ( isfield(params,'saveFileSuffix') && ~isstr(params.saveFileSuffix) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help LaTeXtable" to get help.','params.saveFileSuffix');

		end

		if ( isfield(params,'safeFileExtension') && ~isstr(params.saveFileSuffix) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help LaTeXtable" to get help.','params.saveFileSuffix');

		end

		if ( isfield(params,'summaryFilename') && ~isstr(params.summaryFilename) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help LaTeXtable" to get help.','params.summaryFilename');

		end

		if ( isfield(params,'subdir') && ~isstr(params.subdir) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help LaTeXtable" to get help.','params.subdir');

		end

	end

	% check for the availability of the routines we depend on

	% Uncomment the following lines if necessary

	if ( exist('trEPR_read.m') ~= 2 )
		error('\n\tThe function %s this function critically depends on is not available.\n','trEPR_read');
	end

	if ( exist('B0_spectrum.m') ~= 2 )
		error('\n\tThe function %s this function critically depends on is not available.\n','B0_spectrum');
	end

	if ( exist('get_file_basename.m') ~= 2 )
		error('\n\tThe function %s this function critically depends on is not available.\n','get_file_basename');
	end

	if ( exist('ascii_save_spectrum.m') ~= 2 )
		error('\n\tThe function %s this function critically depends on is not available.\n','ascii_save_spectrum');
	end

	if ( exist('trEPR_timeAxis.m') ~= 2 )
		error('\n\tThe function %s this function critically depends on is not available.\n','trEPR_timeAxis');
	end
	
	if ( exist('trEPR_snr.m') ~= 2 )
		error('\n\tThe function %s this function critically depends on is not available.\n','trEPR_snr');
	end

	% ...and here the 'real' stuff goes in

	% check for the existence of the filenames provided in the argument filenames
	
	for files = 1:length(filenames)
	
		if ( exist(char(filenames(files,1))) ~= 2 )
		
			error('The file %s seem not to exist', char(filenames(files,1)) )
		
		end
	
	end

	% For convenience and a better overview of the data,
	% create a new subdirectory where all files generated by this function
	% get stored in

	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'subdir') ) )
	
		subdirname = params.subdir;

	else
	
		subdirname = sprintf('SNR-%s',datestr(now,'yyyymmdd'));

	end
	
	[mkdirstat, mkdirmess, mkdirmessid] = mkdir (subdirname);
	
	if (~mkdirstat)
	
		fprintf('\nProblems occurred while trying to create the subdirectory %s:',subdirname);
		fprintf('\n\t%s\n\t%s\n',mkdirmess,mkdirmessid);

	elseif (length(mkdirmess) > 0)

		fprintf('\nThere were some warnings while creating the subdirectory %s:',subdirname);
		fprintf('\n\t%s\n\t%s\n',mkdirmess,mkdirmessid);
		
	end
	
	% set some basic parameters (should be done in the future by an optional parameter)

	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'tpos') ) )
	
		tpos = params.tpos;

	else
	
		tpos = 75;

	end

	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'B0halfwidth') ) )
	
		B0halfwidth = params.B0halfwidth;

	else
	
		B0halfwidth = 2;

	end

	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'saveFileSuffix') ) )
	
		saveFileSuffix = params.saveFileSuffix;

	else
	
		saveFileSuffix = 'B0plot';

	end

	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'saveFileExtension') ) )
	
		saveFileExtension = params.saveFileExtension;

	else
	
		saveFileExtension = 'dat';

	end

	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'summaryFilename') ) )
	
		summaryFilename = params.summaryFilename;

	else
	
		summaryFilename = 'SNRanalysisResults.dat';

	end
		
	% Start of main loop: 
	% Perform the following tasks for every file its name is given in the argument
	% filenames
	
	for filenum = 1:length(filenames)

		filename = char(filenames(filenum,1));

		fprintf('%% Starting with file %s\n', filename );
		
		% read file
		
		[ data, params ] = trEPR_read (filename);
		
		% compensate for fluctuations in the pretrigger signal level
		
		[ data ] = pretrigger_offset ( data, params.trig_pos );
		
		% generate B_0 spectrum from 2D data

		[ spectrum, maxIndex ] = B0_spectrum ( data, B0halfwidth, tpos );
		
		% create filenames for saving the ASCII data of the B_0 spectrum
		% and later the plotted figure
		
		fileBasename = get_file_basename( filename );
		saveFilename = sprintf('%s/%s-%s.%s',subdirname, fileBasename, saveFileSuffix, saveFileExtension );
		saveFigFilename = sprintf('%s/%s-%s',subdirname, fileBasename, saveFileSuffix );

		% save B_0 spectrum

		fieldParams = [ min([params.field_start params.field_stop]) max([params.field_start params.field_stop]) abs(params.field_stepwidth) ];
		timeParams = [ params.points params.trig_pos params.length_ts ];
		ascii_save_spectrum ( saveFilename, spectrum, fieldParams, timeParams, params.frequency );

		% plot and save B_0 spectrum

		baxis = [ fieldParams(1) : fieldParams(3) : fieldParams(2) ] / 10;
		taxis = trEPR_timeAxis ( timeParams );

		figure(filenum);
		plot(baxis,spectrum);
		xlabel('magnetic field / mT');
		titlestring = sprintf('%s @ %3.1f us\n as used for SNR analysis',strrep(filename,'_','\_'),taxis(tpos));
		title(titlestring);
		
		save_figure( saveFigFilename );
		
		close(filenum);

		% perform SNR analysis
		
		% As it is better to use not the first but the LAST RECORDED (off-resonant) 
		% PART of the B_0 spectrum to COMPUTE THE NOISE AMPLITUDE
		% and the function B0_spectrum always returns spectra in direction 
		% from low to high field, regardless in which direction the data were
		% recorded, it is crucial to distinguish between these two cases:
		
		if ( params.field_stepwidth > 0 )
		
			noiseRange = [ length(spectrum)-40 length(spectrum) ];
		
		else
		
			noiseRange = [ 1 40 ];
		
		end;
		
		[ snr(filenum), sigAmpl(filenum) ] = trEPR_snr ( spectrum, noiseRange );
	
	end

	% normalize sigAmpl for concentration
	
	sigAmplNorm = sigAmpl./concentration;
	
	
	% print results to an ASCII summary file

	summaryFilename = sprintf('%s/%s', subdirname, summaryFilename);	

	% check whether the output file already exists

	summaryFilename = checkFileExistence (summaryFilename);
	
	
	% open file given by summaryFilename for write access
	
	fid=0;				% set file identifier to standard value
	
	while fid < 1 		% while file not opened
	
		[fid,message] = fopen(summaryFilename, 'wt');
						% try to open file 'filename' and return fid and message
		if fid == -1		% if there are any errors while trying to open the file
		
			error('\n\tFile %s could not be opened for write:\n\t%s', summaryFilename, message);
						% display the message from fopen
						
		end				% end "if fid"
		
	end					% end while loop


	% print table with the data to the summary file

	fprintf(fid, '\n# filename, SNR, signal amplitude, normalized signal amplitude\n');

	for files = 1:length(filenames)

		fprintf(fid, '# %s  %7.4f  %7.4f  %7.4f\n',char(filenames(files,1)),snr(files),sigAmpl(files),sigAmplNorm(files));

	end
	
	% create mean and std of sigAmpl and sigAmplNorm
	
	meanSigAmpl = mean(sigAmpl);
	stdSigAmpl = std(sigAmpl);

	meanSigAmplNorm = mean(sigAmplNorm);
	stdSigAmplNorm = std(sigAmplNorm);
	
	% print key:value pairs for meanSigAmpl, stdSigAmpl, meanSigAmplNorm, stdSigAmplNorm
	
	fprintf(fid, '\nmeanSigAmpl = %7.4f',meanSigAmpl);
	fprintf(fid, '\nstdSigAmpl = %7.4f',stdSigAmpl);
	fprintf(fid, '\nmeanSigAmplNorm = %7.4f',meanSigAmplNorm);
	fprintf(fid, '\nmeanSigAmplNorm = %7.4f',stdSigAmplNorm);
	
	% save close file

	while fid > 2
		% the fids 0, 1 and 2 are reserved for special purposes (input, output, error)
		% that's why every other file identifier (file handle) has a number > 2
	
		% try to close the file
		status = fclose(fid);

		% test whether the closing was successful
		if status == -1
			% if there are any errors while trying to close the file
		
			error('\n\tFile %s could not be closed:\n\t%s', summaryFilename, status);
						% display the message from fclose
						
		elseif status == 0
		
			% set file identifier to exit while loop
			fid = -1;
						
		end				% end "if fid"
		
	end					% end while loop

	fprintf('The results have been saved to the file ./%s\n', summaryFilename);

	% assign output parameters if necessary
	
	if ( nargout > 0)
	
		varargout{1} = sigAmpl;
	
	end
	
	if ( nargout > 1 )
	
		varargout{2} = sigAmplNorm;
		
	end
	
	if ( nargout > 2 )
	
		varargout{3} = [ meanSigAmpl, stdSigAmpl; meanSigAmplNorm, stdSigAmplNorm ];

	end

	fprintf('\n%% <END>\n');

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
