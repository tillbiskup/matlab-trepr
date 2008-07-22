% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* interactive_programs.general/svd-analysis.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/03/30
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, SVD
%
% SYNOPSIS
%	svd_analysis ( filename )
%
% DESCRIPTION
%
%	SVD_ANALYSIS performs a SVD of the given data and plots afterwards
%	the data together with the S values.
%
%	Before performing the SVD the input data are read from an fsc2 file
%	and compensated in the same way as fsc2 does for displaying.
%
%	For a short and a more general introduction to SVD as a method together with
%	examples of the possibilities it provides see the following two articles:
%
%		Shrager, Richard I., and Hendler, Richard W.
%		Titration of Individual Components in a Mixture with Resolution of
%		Difference Spectra, pKs, and Redox Transitions
%		Anal Chem. 54(1982):1147-1152
%
%		Hendler, Richard W., and Shrager, Richard I.
%		Deconvolutions based on singular value decomposition and the pseudoinverse:
%		a guide for beginners
%		Journal of Biochemical and Biophysical Methods, 28(1994):1-33
%
%	Especially the second article is a very well written introduction to SVD
%	covering everything from the very basics of linear algebra up to examples
%	of SVD including noise in the spectra. Users not familiar with SVD are
%	recommended to read this article.
%
% INPUT
%	filename (STRING)
%		string containing the filename of the fsc2 file containing the data the
%		SVD shall be computed for
%
%	params (STRUCT, OPTIONAL)
%		structure containing optional additional parameters
%
%		params.numComponents (INTEGER)
%			number of components to show the U and V vectors for
%
%			This gives the user the possibility to make the function
%			noninteractively, e.g. for running within automated scripts
%			where most probably one knows the maximum number of components
%			that are useful to be displayed.
%
%       params.subdir (STRING)
%           directory to write all files to that are generated during the run
%           of this function
%
%           If not set, the subdir defaults to the evaluation of the statement
%
%               sprintf('SVN-%s',datestr(now,'yyyymmdd'));
%
%           where "SVN" means "singular value decomposition".
%
%		params.outputFormat (STRING)
%			format of the output of the analysis
%
%			May be one of the following:
%
%			'LaTeX'
%			Creates a LaTeX file as output that includes a short description
%			of SVD as method and the results as figures and and a table with
%			the singular values together with the autocorrelation coefficients
%			of the U and V vectors.
%
%           'LaTeXpart'
%           Creates a LaTeX file as output that can be included into another LaTeX
%           file (without header and \begin{document}-\end{document}). This file 
%           includes the results as figures and and a table with the singular values
%           together with the autocorrelation coefficients of the U and V vectors.
%
%       params.LaTeXfid (FID)
%           FID (file identifier) of a LaTeX file to write to
%
%           Only valid in combination with the params.outputFormat set to 'LaTeXpart'.
%           In this case instead of writing the LaTeX output to a separate file, it will
%           be written to the file specified with the 'FID'.
%
%		params.appendToLabels (STRING)
%			in case you use the 'LaTeXpart' output format, it might be useful
%			to be able to append a string to the labels used for referencing
%			tables and figures within LaTeX. This is especially useful if you
%			want to include two SVD analysis outputs in one LaTeX file. Otherwise
%			you'll run into troubles caused by "multiply defined labels".
%
% OUTPUT
%	U (MATRIX, OPTIONAL)
%		matrix containing the U vectors
%
%		The columns of the matrix U contain an orthonormal set of vectors
%		that lie in the column space of A (the matrix of the recorded data).
%
%	S (MATRIX, OPTIONAL)
%		matrix containing the singular values as diagonal elements
%
%		The scalar values on the diagonal of S are weights which corespond
%		to the columns of U and V. They are 'singular values' and they are
%		the square roots of the eigenvalues for the vectors in U and V,
%		which are eigenvectors of AA' and A'A, respectively.
%
%	V (MATRIX, OPTIONAL)
%		matrix containing the V vectors
%
%		The columns of the matrix V contain an orthonormal set of vectors
%		that lie in the row space of A (the matrix of the recorded data).
%
%	If only one output parameter is provided, it is treated as S matrix.
%
% DEPENDS ON
%	* the trEPR toolbox
%	* autocorr
%
% COMPATIBILITY
%	The file is written initially for MATLAB(TM) and designed to meet
%	the special needs for MATLAB(TM) plot and print functionality.
%
% EXAMPLE
%	To perform a SVD on the data contained in the file spectrum.dat just typein:
%
%		svd_analysis ( 'spectrum.dat' )
%
%	and you'll get a PS file called 'spectrum-SVD.ps' file as well as 
%	a MATLAB(TM) figure file called 'spectrum-SVD.fig' containing the figure with
%	both a 2D representation of the data and a plot of the S vector.
%
%	All steps that have been performed are logged in a file named 'spectrum-SVD.log'.
%
% SOURCE


function [ varargout ] = svd_analysis ( filename, varargin )

	fprintf ( '\n%% FUNCTION CALL: $Id$\n' );

	% check for input parameters

	if ( ( nargin < 1 ) && ( nargin > 2 ) )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help svd_analysis" to get help.',nargin);
			% get error if function is called with other than
			% one input parameter
	end

	% check for input parameters

	if ( ( nargout ~= 0 ) && ( nargout ~=  1 ) && ( nargout ~=  3 ) )
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help svd_analysis" to get help.',nargin);
			% get error if function is called with other than
			% zero or three output parameters
	end
	
	% check for correct format of the input parameters
	
	% FILENAME
	
	if ~isstr(filename)
	
		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help svd_analysis" to get help.','filename');
			% get error if function is called with the wrong format of the
			% input parameter 'filename'
	
	elseif length(filename) == 0

		error('\n\tThe function is called with an empty string as the filename %s.\n\tPlease use "help svd_analysis" to get help.','filename');
			% get error if function is called with an empty 'filename'

	end
	
	% PARAMETERS (OPTIONAL)
	
	if nargin > 1
	
		params = varargin{1};
	
		if ~isstruct(params)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help svd_analysis" to get help.','params');
				% get error if function is called with the wrong format of the
				% input parameter 'params'
	
		end

        if ( isfield(params,'numComponents') && ~isnumeric(params.numComponents) )
    
            error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help svd_analysis" to get help.','params.numComponents');

        end

		if ( isfield(params,'outputFormat') && ~isstr(params.outputFormat) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help svd_analysis" to get help.','params.outputFormat');

		end

        if ( isfield(params,'LaTeXfid') && ~isnumeric(params.LaTeXfid) )
    
            error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help svd_analysis" to get help.','params.LaTeXfid');

        end

		if ( isfield(params,'appendToLabels') && ~isstr(params.appendToLabels) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help svd_analysis" to get help.','params.appendToLabels');

		end

%		if ( isfield(params,'###') && ~isstr(params.###) )
%	
%			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help svd_analysis" to get help.','params.###');
%
%		end
	
	end

	% check for the availability of the routines we depend on

	if ( exist('trEPR_read.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'read_fsc2_data');

	elseif ( exist('pretrigger_offset.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'pretrigger_offset');

	elseif ( exist('baseline_subtraction_fsc2.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'baseline_subtraction_fsc2');

	elseif ( exist('B0_spectrum.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'B0_spectrum');

	elseif ( exist('save_figure.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'save_figure');

	elseif ( exist('get_file_basename.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'get_file_basename');

	elseif ( exist('autocorr.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'autocorr');

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
	

    % For convenience and a better overview of the data,
    % create a new subdirectory where all files generated by this function
    % get stored in

    if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'subdir') ) )
    
        subdirname = params.subdir;

    else
    
        subdirname = sprintf('SVD-%s',datestr(now,'yyyymmdd'));

    end
    
    [mkdirstat, mkdirmess, mkdirmessid] = mkdir (subdirname);
    
    if (~mkdirstat)
    
        fprintf('\nProblems occurred while trying to create the subdirectory %s:',subdirname);
        fprintf('\n\t%s\n\t%s\n',mkdirmess,mkdirmessid);

    elseif (length(mkdirmess) > 0)

        fprintf('\nThere were some warnings while creating the subdirectory %s:',subdirname);
        fprintf('\n\t%s\n\t%s\n',mkdirmess,mkdirmessid);
        
    end

    if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'printSValues') ) )
    
        printSValues = params.printSValues;

    else
    
        printSValues = 20;

    end
	

	% read base filename from filename
	
	file_basename = get_file_basename ( filename );
	
	% check which output format for the results was chosen
	
	if ( ( nargin > 1 ) && ( isfield(params,'outputFormat') ) && ( strcmp(params.outputFormat,'LaTeX') ) )
	
		outputFormat = 'LaTeX';
	
	elseif ( ( nargin > 1 ) && ( isfield(params,'outputFormat') ) && ( strcmp(params.outputFormat,'LaTeXpart') ) )
    
        outputFormat = 'LaTeXpart';
    
    else
	
		outputFormat = '';
	
	end
	

    if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'appendToLabels') ) )
    
        appendToLabels = params.appendToLabels;

    else
    
        appendToLabels = '';

    end
	
	
	% start logging

	% NOTE: Instead of using the routine "start_logging" we do this here manually
	% cause here we set the logfile name to a default value...
	
	logfile_name = sprintf( '%s/%s-SVD.log', subdirname, file_basename );

	if (exist(logfile_name) == 2)
	
		delete ( logfile_name );
		
	end;
	
	diary ( 'off' );
	diary ( logfile_name );


	% In case the LaTeX output option is set, print headers for the LaTeX file
	
	if ( strcmp(outputFormat,'LaTeX') )
	
		LaTeXfileName = sprintf('%s/%s-SVD', subdirname, file_basename);
	
		LaTeXheaderParams.titleString = sprintf('Preliminary singular value decomposition (SVD) analysis\\\\ of the file \\texttt{%s}',strrep(filename,'_','\_')); 
		LaTeXheaderParams.authorString = sprintf('%s\\thanks{%s "%s"}','Till Biskup','till.biskup@physik.fu-berlin.de, file generated with',strrep('$ $Id$ $','_','\_')); 
		LaTeXheaderParams.dateString = sprintf('%s', datestr(now, 29)); 

		LaTeXfid = LaTeXheader(LaTeXfileName,LaTeXheaderParams);
	
	end
    
    if ( strcmp(outputFormat,'LaTeXpart') )
    
        LaTeXfileName = sprintf('%s/%s-SVD.input.tex', subdirname, file_basename);

        if  ( ( nargin > 1 ) && ( isfield(params,'LaTeXfid') ) )
        
            LaTeXfid = params.LaTeXfid;
        
        else

            [LaTeXfid,message] = fopen(LaTeXfileName, 'wt');
            
        end
    
    end


	% In case the LaTeX output option is set,
	% include a short abstract
	
	if ( strcmp(outputFormat,'LaTeX') )
	
		LaTeXabstract = sprintf('Singular value decomposition (SVD) is a powerful tool to analyze spectra consisting of several components. Here, SVD is used to perform a basic analysis of 2D trEPR spectra: The singular values and the first few "spectra" from the U and V matrices are plotted. This gives a first hint of how many components the recorded spectrum consists of.');

		LaTeXenvironment(LaTeXfid,'abstract',LaTeXabstract);

	end


	% In case the LaTeX output option is set,
	% include a section named "Introduction"
	% with some introductory notes about SVD.
	
	if ( strcmp(outputFormat,'LaTeX') )

		LaTeXsection(LaTeXfid,'section','Introduction');
		fprintf(LaTeXfid,...
		  [ ...
		    'In some cases, in a spectrum recorded with trEPR a mixture of ' ...
		    'different species, or components is present. Thus the spectrum is ' ...
		    'the sum of the contributions of each component. As the individual ' ...
		    'spectra are oftenly not known, singular value decomposition (SVD) ' ...
		    'can be used to find these individual spectra together with the ' ...
		    'coefficients that specify how to mix them to yield the recorded ' ...
		    'spectrum. For the moment there is no fully featured SVD, but only ' ...
		    'the S values and the first few U and V vectors are plotted.' ...
		  ] ...
		);
        fprintf(LaTeXfid,'\n\n To perform a fully featured SVD you need to figure out a model of how the different components are related to each other (e.g. one component decays and leads to the formation of the second one, or two components are independent of each other, but with different kinetics).');
		fprintf(LaTeXfid,'\n\nFor an overview of that method and to get an idea of how to apply it to the data under investigation, the reader is referred to a very well written introduction to SVD: Hendler and Shrager, J Biochem Biophys Meth 28(1994):1--3.');
		
	end


	% read data file
	% Use therefore the generalized read function trEPR_read
	% that allows to read fsc2 files as well as compensated files from the
	% trEPR toolbox.

	[data, readParams, file_format] = trEPR_read ( filename );
	
	if (strcmp(file_format,'fsc2 file') == 0) && (strcmp(file_format,'trEPR ASCII 2Dspec file') == 0)
	
		error('\nThe file "%s" \nseems to have the wrong format as an input file for this routine. \nAbort further operation...', input_filename);
	
	end

	fp = [ readParams.field_start readParams.field_stop readParams.field_stepwidth ];
	tp = [ readParams.points readParams.trig_pos readParams.length_ts ];
	fq = readParams.frequency;

	% compensate for pretrigger offset
	% but only if the input file is a (non-compensated) fsc2 file

	if (strcmp(file_format,'fsc2 file') ~= 0)
	
		data = pretrigger_offset ( data, tp(3) );
		
	end;

	% compensate for baseline (simple way)
	% but only if the input file is a (non-compensated) fsc2 file

	if (strcmp(file_format,'fsc2 file') ~= 0)

		data = baseline_subtraction_fsc2 ( oc_data, 10 );
		
	end;

	% compute values for axes labels

	b_field=[fp(1):fp(3):fp(2)]/10;
	time=[-(tp(3)/tp(1)*tp(2)):tp(3)/tp(1):tp(3)-(tp(3)/tp(1))-(tp(3)/tp(1)*tp(2))];

	% if the spectrum was recorded from high to low field
	% flip dimensions of the data matrix

	if ( fp(3) < 0 )
		data = flipud(data);
	end;


	% perform SVD

	ordinal = {'first','second','third','fourth','fifth','sixth','seventh','eighth','nineth','tenth','eleventh','twelveth','thirteenth','fourteenth','fifteenth','sixteenth','seventeenth','eighteenth','nineteenth','twentieth'};

	timesteps = 5;

	% In case the LaTeX output option is set,
	% include a section named "Results"
    
    if ( strcmp(outputFormat,'LaTeX') )

        LaTeXsection(LaTeXfid,'section','Results');

    end
	
	if ( strcmp(outputFormat,'LaTeX') || strcmp(outputFormat,'LaTeXpart') )

		fprintf(LaTeXfid, [ ...
		  'The recorded 2D dataset of the TREPR spectrum stored in the file ' ...
		  '\\begin{center}%s\\end{center} has been read in. Starting with the ' ...
		  'trigger pulse (laser flash), every %s $B_0$ spectrum has been taken ' ...
		  'along the time axis and from that set of spectra the SVD has been ' ...
		  'computed.' ...
		  ], ...
		  strrep(filename,'_','\_'), ...
		  char(ordinal(timesteps)) ...
		);

	end
	
	tpos = [tp(2) : timesteps : tp(1)-timesteps];

	for k = 1 : length(tpos)
	
		SVD_input(:,k) = B0_spectrum( data, 2, tpos(k));
		
	end
	
	SVD_input = data;
	tpos = 1:tp(1);

	% From the MATLAB(TM) help:
	%
	%	[U,S,V] = svd(X,'econ') produces the "economy size" decomposition.
	%	If X is m-by-n with m >= n, it is equivalent to svd(X,0).
	%	For m < n, only the first m columns of V are computed and S is m-by-m.

	[U,S,V] = svd(SVD_input,'econ');
	
	% plot data and singular values

	% In case the LaTeX output option is set,
	% print first two figures and save as pdf files
	
	if ( strcmp(outputFormat,'LaTeX') || strcmp(outputFormat,'LaTeXpart') )
	
		saveFigureParams.outputFormat = 'LaTeXhalfWidth';
	
		figHandle = figure;
		imagesc ( time, b_field, data );
		set(gca,'YDir','normal'); % this reverts the reversed y axis
		xlabel ( 'time / \mus' );
		ylabel ( 'magnetic field / mT' );
		saveFileBaseName1 = sprintf( '%s-LaTeX-SVD01', file_basename );
        saveFileBaseNameWithPath1 = sprintf( '%s/%s', subdirname, saveFileBaseName1 );
		save_figure(saveFileBaseNameWithPath1,saveFigureParams);

        if ( length(diag(S)) > 50 )
        
            SValues = diag(S);
            SValues = SValues(1:50);
        
        else
        
            SValues = diag(S);
        
        end

		plot(SValues,'x');
		xlabel ( 'index of the singular values' );
		ylabel ( 'singular values' );
		saveFileBaseName2 = sprintf( '%s-LaTeX-SVD02', file_basename );
        saveFileBaseNameWithPath2 = sprintf( '%s/%s', subdirname, saveFileBaseName2 );
		save_figure(saveFileBaseNameWithPath2,saveFigureParams);
		
		if ( strcmp(outputFormat,'LaTeXpart') )
 		  LaTeXfigureParams.positioning = 'h';
 		else
 		  LaTeXfigureParams.positioning = 't';
 		end
 		LaTeXfigureParams.caption = 'Original data (left) and singular values (right). The singular values are the diagonal elements of the S matrix of the SVD. The plot of the singular values allows to roughly estimate the number of different components the spectra consist of.';
 		LaTeXfigureParams.shortCaption = 'Original data and singular values.';
 		LaTeXfigureParams.label = sprintf('origData_Svalues%s',appendToLabels);
 		
 		LaTeXfigNames = {[saveFileBaseName1 '.pdf'],'width=.49\textwidth','\hfill';[saveFileBaseName2 '.pdf'],'width=.49\textwidth',''};
 		
 		LaTeXfig1Label = LaTeXfigure (LaTeXfid,LaTeXfigNames,LaTeXfigureParams);
 		
 		fprintf(LaTeXfid, ...
 		  [ ...
 		    '\n\nFor the original data used to perform the SVD and for a plot ' ...
 		    'of the singular values refer to fig. \\ref{%s}, page ' ...
 		    '\\pageref{%s}.'
 		  ], ...
 		  LaTeXfig1Label, ...
 		  LaTeXfig1Label ...
 		);
 		
 	else

		figHandle = subplot(2,1,1);
		imagesc ( time, b_field, data );
		set(gca,'YDir','normal'); % this reverts the reversed y axis
	
		% NOTE: With GNU Octave we run here into problems cause imagesc is displayed
		% as tiff image and not generated using Gnuplot...

		fig_title = sprintf ( 'filename: %s', strrep ( file_basename, '_', '\_' ) );
		title ( fig_title );
		xlabel ( 'time / \mus' );
		ylabel ( 'magnetic field / mT' );

		subplot(2,1,2);
		plot(diag(S),'x');

		title ( 'Singular Value Decomposition of the spectrum above' );
		xlabel ( 'index of the singular values' );
		ylabel ( 'singular values' );

		% save figure to file

		saveFileBaseName = sprintf( '%s/%s-SVD01', subdirname, file_basename );
		saveFigureA4(saveFileBaseName);

	end
		
	% Compute autocorrelation coefficients of the U and V vectors
	% using the internal subfunction acc
	% and print them together with the singular values both at the command line
	% and - if specified - as LaTeX table.
	
	accU = acc(U(:,1:printSValues));
	accV = acc(V(:,1:printSValues));
	vecS = diag(S);
	
	fprintf('\n %s\t%s\t\t%s\t%s\n','i','S value','autocorr(U)','autocorr(V)');
	fprintf('====================================================\n');

	% Originally, the program printed the S values for all existing accV values.
	% Due to the fact that there should be never more than five to six components
	% in a spectrum, reduce that to plotSValues, that defaults to 20.
	% for k = 1 : length(accV)
	for k = 1 : printSValues
	
		fprintf(' %i\t%f\t%f\t%f\n',k,vecS(k),accU(k),accV(k));
	
	end
	
	% In case the LaTeX output option is set,
	% print a table with the singular values together with the autocorrelation
	% coefficients of the U and V matrices
	
	if ( strcmp(outputFormat,'LaTeX') || strcmp(outputFormat,'LaTeXpart') )
	
 		LaTeXtableParams.positioning = 'b';
		LaTeXtableParams.width = '\textwidth'; 		
 		LaTeXtableParams.caption = 'Output from SVD operation: Singular values and autocorrelations for the U and V vectors. The singular values (clearly non--zero) together with the autocorrelations of U and V (bigger than 0.5) give a hint of the rank (r) for the dataset.';
 		LaTeXtableParams.shortCaption = 'Singular values and autocorrelations for the U and V vectors.';
 		LaTeXtableParams.label = sprintf('Svalues_UVautocorrelations%s',appendToLabels);
 		
 		LaTeXtableHeader = {'Index','c';'Singular values','c';'U autocorrelations','c';'V autocorrelations','c'};
 		
		LaTeXtableData = [ [1:1:15]', vecS(1:15), accU(1:15)', accV(1:15)' ];
 		
 		LaTeXtab1Label = LaTeXtable (LaTeXfid,LaTeXtableData,'crrr',LaTeXtableHeader,LaTeXtableParams);
 		
 		fprintf(LaTeXfid, ...
 		  [ ...
 		    'The singular values itself together with the corresponding ' ...
 		    'autocorrelation coefficients of the U and V vectors can be looked ' ...
 		    'up in table \\ref{%s}, page \\pageref{%s}.'
 		  ], ...
 		  LaTeXtab1Label, ...
 		  LaTeXtab1Label ...
 		);
 		
 	end
	
	% plot U and S columns
	
	% first, decide how many columns to plot - ask the user for that
	% except of the parameter params.numComponents is set

    if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'numComponents') ) )
    
        num_values = params.numComponents;

    else
    
		num_values = input('\nHow many vectors should be shown? ','s');
		num_values = str2num(num_values);

    end


	% In case the LaTeX output option is set,
	% print first two figures and save as pdf files
	
	if ( strcmp(outputFormat,'LaTeX') || strcmp(outputFormat,'LaTeXpart') )

		plots_per_page = 4;

		plot_pages = ceil(num_values/plots_per_page);

		saveFigureParams.outputFormat = 'LaTeXhalfWidthSmallHeight';

		LaTeXfigNames = cell(num_values,3);

		for k = 1 : num_values
		
			plot(b_field,U(:,(k)));
			xlim([min(b_field) max(b_field)]);
			xlabel('magnetic field / mT');
			set(gca,'XMinorTick','on');
			XTicks = [min(b_field) : 1 : max(b_field)];
			set(gca,'XTick',XTicks);
			set(gca,'XGrid','on');
			saveFileBaseName1 = sprintf( '%s-LaTeX-SVD-U%02.0f', file_basename, k );
            saveFileBaseNameWithPath1 = sprintf( '%s/%s', subdirname, saveFileBaseName1 );
			save_figure(saveFileBaseNameWithPath1,saveFigureParams);

			plot(time(tpos),V(:,(k)));
			xlim([0 max(time(tpos))]);
			xlabel('time / us');
			set(gca,'XMinorTick','on');
			XTicks = [0 : 2 : max(time(tpos))];
			set(gca,'XTick',XTicks);
			set(gca,'XGrid','on');
			saveFileBaseName2 = sprintf( '%s-LaTeX-SVD-V%02.0f', file_basename, k );
            saveFileBaseNameWithPath2 = sprintf( '%s/%s', subdirname, saveFileBaseName2 );
			save_figure(saveFileBaseNameWithPath2,saveFigureParams);

	 		LaTeXfigNames([(k*2-1):(k*2)],:) = {[saveFileBaseName1 '.pdf'],'width=.49\textwidth','\hfill';[saveFileBaseName2 '.pdf'],'width=.49\textwidth',''};

        end

 		LaTeXfigureParams.positioning = 'p';
 		LaTeXfigureParams.caption = sprintf('The first %i U (left) and V (right) vectors that result from the SVD. Note: The U vectors correspond to the $B_0$ spectra and the V vectors correspond to the time slices, but \\emph{these spectra are not identical with the singular components} the spectra consist of. Nevertheless they can be used to fit a model that allows to compute the real singular components.',num_values);
 		LaTeXfigureParams.shortCaption = sprintf('The first %i U (left) and V (right) vectors that result from the SVD.', num_values);
 		LaTeXfigureParams.label = sprintf('U_Vvalues%s', appendToLabels);
 		
 		fprintf(LaTeXfid,'\n\\clearpage\n');
 		LaTeXfig2Label = LaTeXfigure (LaTeXfid,LaTeXfigNames,LaTeXfigureParams);

	else
	
		plots_per_page = 4;

		plot_pages = ceil(num_values/plots_per_page);
	
		for p = 1 : (plot_pages - 1)

			figure;

			for k = ((p*plots_per_page-plots_per_page)*2+2) : 2 : ((plots_per_page*2*p))

				indsubplot1 = k-((p*plots_per_page-plots_per_page)*2)-1;
				
				subplot(plots_per_page,2,indsubplot1);
				plot(b_field,U(:,(k/2)));
				xlim([min(b_field) max(b_field)]);
				xlabel('magnetic field / mT');
				titlestring = sprintf('U vector %i',k/2);
				title(titlestring);

				indsubplot2 = indsubplot1 + 1;
	
				subplot(plots_per_page,2,indsubplot2);
				plot(time(tpos),V(:,(k/2)));
				xlim([0 max(time(tpos))]);
				xlabel('time / us');
				titlestring = sprintf('V vector %i',k/2);
				title(titlestring);

			end

			saveFileBaseName = sprintf( '%s/%s-SVD%02.0f', subdirname, file_basename, p+1 );
			saveFigureA4(saveFileBaseName);
		
		end
		
		figure

		for k = (plot_pages*plots_per_page-plots_per_page)*2+2 : 2 : (num_values*2)

			indsubplot1 = k-((plot_pages*plots_per_page-plots_per_page)*2)-1;

			subplot(plots_per_page,2,indsubplot1);
			plot(b_field,U(:,(k/2)));
			xlim([min(b_field) max(b_field)]);
			xlabel('magnetic field / mT');
			titlestring = sprintf('U vector %i',k/2);
			title(titlestring);

			indsubplot2 = indsubplot1 + 1;

			subplot(plots_per_page,2,indsubplot2);
			plot(time(tpos),V(:,(k/2)));
			xlim([0 max(time(tpos))]);
			xlabel('time / us');
			titlestring = sprintf('V vector %i',k/2);
			title(titlestring);
	
		end
	
		saveFileBaseName = sprintf( '%s/%s-SVD%02.0f', subdirname, file_basename, plot_pages+1 );
		saveFigureA4(saveFileBaseName);

	end	
		
	% stop logging
	
	% NOTE: Instead of using here the routine "stop_logging" we do it manually
	% cause we started logging manually as well (see above).
	
	diary ( 'off' );
	
	% assign the (OPTIONAL) output parameters
	
	if (nargout == 1)
	
		varargout{1} = S;
	
	end
	
	if (nargout == 3)
	
		varargout{1} = U;
		varargout{2} = S;
		varargout{3} = V;
	
	end
	
	% Finish the LaTeX file
	
	if ( strcmp(outputFormat,'LaTeX') )

		LaTeXfooter(LaTeXfid);
		
		close(figHandle)
	
	end
	
	% Save the U, S, and V vectors each in one ASCII file
	
	saveUFileName = sprintf( '%s/%s-U.dat', subdirname, file_basename );
	saveSFileName = sprintf( '%s/%s-S.dat', subdirname, file_basename );
	saveVFileName = sprintf( '%s/%s-V.dat', subdirname, file_basename );
	
	saveASCIIparams.description = sprintf('%s vector from the SVD from the file %s.dat','U',file_basename);
	asciiSaveData ( saveUFileName, U, saveASCIIparams );

	saveASCIIparams.description = sprintf('%s vector from the SVD from the file %s.dat','S',file_basename);
	asciiSaveData ( saveSFileName, S, saveASCIIparams );

	saveASCIIparams.description = sprintf('%s vector from the SVD from the file %s.dat','V',file_basename);
	asciiSaveData ( saveVFileName, V, saveASCIIparams );
	
end
  
%******


function saveFigureA4 (FileBaseName)

	% save figure to file

	fig_filename = sprintf( '%s.fig', FileBaseName );
	ps_filename = sprintf( '%s.ps', FileBaseName );

	% NOTE: The following settings are specific for MATLAB(TM) to perform
	% a halfway useful output.
	% To adjust the settings for a paper type other than DIN A4 please change the
	% options "PaperType" and "rect" to the right values.

	set(gcf,'PaperType','A4');
	set(gcf,'PaperOrientation','portrait');
	set(gcf,'PaperUnits','centimeters');
	rect=[1.5,1.5,18,26];
		% sets the left and upper margin and width and height of the printable
		% area of the page
	set(gcf,'PaperPosition',rect);

	% save figure as MATLAB(TM) fig file
	
	% NOTE: This will lead to problems when called with another program than MATLAB(TM).

	saveas ( gcf, fig_filename )

	% print figure to a PS file
	
	print( gcf, '-dpsc2', ps_filename )

end


function C = acc ( matrix )

	% Compute the autocorrelation coefficient for each column of the input matrix.
	% Use therefore the self-written function autocorr.

	[ rows, cols ] = size ( matrix );

	for k = 1 : cols
	
		% compute autocorrelation coefficient for a lag k with k=1
		
		C(k) = autocorr(matrix(:,k),1);
	
	end

end