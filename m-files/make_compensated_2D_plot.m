% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****h* global_scripts/make_compensated_2D_plot.m
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
%	This figure is finally saved to a file with same file basename as the input file.
%
% NOTE
%
%	This program will only run with MATLAB(TM) for several reasons: It makes use of
%	MATLAB(TM)-specific plot commands and saves the result to a MATLAB(TM) fig file.s
%
% SOURCE

function make_compensated_2D_plot ( filename )

	% read fsc2 data file

	[ data, f, fp, sp, tp ] = read_fsc2_data ( filename );

	% compensate for pretrigger offset

	oc_data = pretrigger_offset ( data, tp(3) );

	% compensate for baseline (simple way)

	bl_oc_data = baseline_subtraction_fsc2 ( oc_data, 10 );

	% compute values for axes labels

	b_field=[fp(1):fp(3):fp(2)]/10;
	time=[-(tp(3)/tp(1)*tp(2)):tp(3)/tp(1):tp(3)-(tp(3)/tp(1))-(tp(3)/tp(1)*tp(2))];

	% From MATLAB(TM) help:
	% The imagesc function scales image data to the full range of the current
	% colormap and displays the image.

	imagesc ( time, b_field, bl_oc_data );

	% set filename to save the figure

	file_basename = get_file_basename ( filename );
	fig_filename = sprintf( '%s-2Dimagesc.fig', file_basename );

	% set figure title and axes labels

	fig_title = sprintf ( 'filename: %s', strrep ( file_basename, '_', '\_' ) );
	title ( fig_title );
	xlabel ( 'time / \mus' );
	ylabel ( 'magnetic field / mT' );

	% save figure as MATLAB(TM) fig file

	saveas ( gcf, fig_filename );

%******
