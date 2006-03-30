% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* global_scripts/svd-analysis.m
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
%	svd-analysis
%
% DESCRIPTION
%
%	SVD_ANALYSIS performs a SVD of the given data and plots afterwards
%	the data together with the S values.
%
%	Before performing the SVD the input data are read from an fsc2 file
%	and compensated in the same way as fsc2 does for displaying.
%
% COMPATIBILITY
%
%	The file is written initially for MATLAB(TM) and designed to meet
%	the special needs for MATLAB(TM) plot and print functionality.



function svd_analysis ( filename )

	% test for calling program
	
	if exist('discriminate_matlab_octave')
	
		if (exist('program') == 0)

		    program = discriminate_matlab_octave;
	    
		end
		
	else
	
		fprintf('\nSorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\nThis function will behave as if it is called within MATLAB(TM)...\n');
		
		program = 'Matlab';
	
	end;


	if program == 'Octave'	% if we're called by GNU Octave (as determined above)

		error('Sorry, but this routine cannot be used with GNU Octave at the moment...');
		
	end;
	
	
	% read base filename from filename
	
	file_basename = get_file_basename ( filename );
	
	
	% start logging
	
	logfile_name = sprintf( '%s-SVD.log', file_basename );

	if (exist(logfile_name) == 2)
	
		delete ( logfile_name );
		
	end;
	
	diary ( 'off' );
	diary ( logfile_name );


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


	% perform SVD

	SVD_input = bl_oc_data(:,[50 : 10 : 500]);

	s = svd(SVD_input)


	% plot data and s vector

	subplot(2,1,1);
	imagesc ( time, b_field, bl_oc_data );

	fig_title = sprintf ( 'filename: %s', strrep ( file_basename, '_', '\_' ) );
	title ( fig_title );
	xlabel ( 'time / \mus' );
	ylabel ( 'magnetic field / mT' );

	subplot(2,1,2);
	plot(s,'x');

	title ( 'Singular Value Decomposition of the spectrum above' );
	xlabel ( 'index of the s vector' );
	ylabel ( 'values of the s vector' );

	% save figure to file

	fig_filename = sprintf( '%s-SVD.fig', file_basename );
	ps_filename = sprintf( '%s-SVD.ps', file_basename );

	set(gcf,'PaperType','A4');
	set(gcf,'PaperOrientation','portrait');
	set(gcf,'PaperUnits','centimeters');
	rect=[1.5,1.5,18,26];
	set(gcf,'PaperPosition',rect);

	% save figure as MATLAB(TM) fig file

	saveas ( gcf, fig_filename )

	% print figure to a PS file

%	saveas ( gcf, ps_filename, 'eps' );
	
	print( gcf, '-dpsc2', ps_filename )
	
	
	% stop logging
	
	diary ( 'off' );
  
%******
