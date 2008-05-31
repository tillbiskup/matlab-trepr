% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* interactive_programs.trEPR/make_compensated_2D_plot.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/03/16
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2, 2D plots
%
% SYNOPSIS
%	make_compensated_2D_plot ( filename )
%
% DESCRIPTION
%	This program takes a filename, reads this fsc2 file, performs compensation
%	for the pretrigger offset and for the baseline (in the same way the standard
%	fsc2 programs for transient EPR triplet measurements do) and finally plots the
%	2D dataset as well in the same manner as the fsc2 program will do.
%
%	This figure is finally saved as a MATLAB(TM) fig file with the same file 
%	basename as the input file and file extension '.fig'.
%
% NOTE
%	This program will run properly only with MATLAB(TM).
%
%	If called by MATLAB(TM), it saves the result to a MATLAB(TM) fig file.
%	If called by GNU Octave, it saves the result to an EPS file.
%
%	Problems with GNU Octave:
%	* axis tics are not set properly (bug in gsplot command)
%	* figure title is not set properly (bug with "_" character)
%
% INPUT
%	filename
%		the name of the file the compensated 2D plot should be generated for
%
% OUTPUT
%	In the moment there are no output parameters
%
% DEPENDS ON
%	* read_fsc2_data
%	* pretrigger_offset
%	* baseline_subtraction_fsc2
%
% EXAMPLE
%	If you want to see the fsc2-style 2D plot of recorded data of the file
%	with the name filename than just typein:
%
%		make_compensated_2D_plot ( filename )
%
%	That will perform some data processing automatically as well as displaying
%	and saving (to a MATLAB(TM) fig file) the result.
%
% SOURCE

function make_compensated_2D_plot ( filename )

	fprintf ( '\nFUNCTION CALL: $Id$\n' );
	
	% check for right number of input and output parameters

	if ( nargin ~= 1)
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help make_compensated_2D_plot" to get help.',nargin);
			% get error if function is called with other than
			% one input parameter
	end

	if nargout ~= 0
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help make_compensated_2D_plot" to get help.',nargout);
			% get error if function is called with other than
			% zero output parameters
	end
	
	% check for correct format of the input parameters
	
	% FILENAME
	
	if ~isstr(filename)
	
		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help make_compensated_2D_plot" to get help.','filename');
			% get error if function is called with the wrong format of the
			% input parameter 'filename'
	
	elseif length(filename) == 0

		error('\n\tThe function is called with an empty string as the filename %s.\n\tPlease use "help make_compensated_2D_plot" to get help.','filename');
			% get error if function is called with an empty 'filename'

	end


	% check for the availability of the routines we depend on

	if ( exist('read_fsc2_data.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'read_fsc2_data');

	elseif ( exist('pretrigger_offset.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'pretrigger_offset');

	elseif ( exist('baseline_subtraction_fsc2.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'baseline_subtraction_fsc2');

	end


	% test for calling program
	
	if exist('discriminate_matlab_octave')
	
		if (exist('program') == 0)

		    program = discriminate_matlab_octave;
	    
		end
		
	else
	
		fprintf('\nSorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\nThis function will behave as if it is called within MATLAB(TM)...\n');
		
		program = 'Matlab';
	
	end;
	

	% read fsc2 data file

	[ data, f, fp, sp, tp ] = read_fsc2_data ( filename );

	% compensate for pretrigger offset

	oc_data = pretrigger_offset ( data, tp(3) );

	% compensate for baseline (simple way)

	bl_oc_data = baseline_subtraction_fsc2 ( oc_data, 10 );

	% compute values for axes labels

	b_field=[fp(1):fp(3):fp(2)]/10;
	time=[-(tp(3)/tp(1)*tp(2)):tp(3)/tp(1):tp(3)-(tp(3)/tp(1))-(tp(3)/tp(1)*tp(2))];

	if ( fp(3) < 0 )
		bl_oc_data = flipud(bl_oc_data);
	end;


	if program == 'Octave'	% if we're called by GNU Octave (as determined above)

		% set colormap to "jet"

		jet_colormap;

		% print some warning message telling the difficulties that occur
		% with GNU Octave while using the imagesc function and saving coloured
		% images.
		
		fprintf('\nWARNING: Function called with GNU Octave.\n         GNU Octave handles imagesc in another way as MATLAB(TM).\n         Additionally it cannot save coloured PS files.\n         Therefore the output is saved as a PPM file that can be\n         converted to ps via \"pnmtops ppmfile > psfile\".\n');
		
	end;

	% From MATLAB(TM) help:
	% The imagesc function scales image data to the full range of the current
	% colormap and displays the image.

	imagesc ( time, b_field, bl_oc_data );

	% set filename to save the figure

	file_basename = get_file_basename ( filename );
	fig_filename = sprintf( '%s-2Dimagesc.fig', file_basename );
	eps_filename = sprintf( '%s-2Dimagesc.eps', file_basename );
	ppm_filename = sprintf( '%s-2Dimagesc.ppm', file_basename );


	% set figure title and axes labels

	fig_title = sprintf ( 'filename: %s', strrep ( file_basename, '_', '\_' ) );
	title ( fig_title );
	xlabel ( 'time / \mus' );
	ylabel ( 'magnetic field / mT' );

	if program == 'Octave'	% if we're called by GNU Octave (as determined above)

		% set some gnuplot parameters

		graw('set pm3d transparent;');
		graw('set pm3d map;');
		graw('set palette rgbformulae 33,13,10;');
		
		% make 2D plot of the data
		
		gsplot ( bl_oc_data' );
		
		% save plot as eps file
		
		print ( eps_filename, '-depsc2');
		
		% save color scaled image to variable

		% scaled_image = imagesc( bl_oc_data );

		% save figure as ppm file
		% cause GNU OCTAVE cannot handle coloured ps files
		
		% saveimage ( ppm_filename, scaled_image, 'ppm' );
		
	else					% otherwise we assume that we're called by MATLAB(R)

		% save figure as MATLAB(TM) fig file

		saveas ( gcf, fig_filename );

	end					% end of "if program" clause
  
%******
