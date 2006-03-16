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
% SOURCE

function make_compensated_2D_plot ( filename )

	[ data, f, fp, sp, tp ] = read_fsc2_data ( filename );

	oc_data = pretrigger_offset ( data, tp(3) );

	bl_oc_data = baseline_subtraction_fsc2 ( oc_data, 10 );

	% axis labels

	b_field=[fp(1):fp(3):fp(2)]/10;
	time=[-(tp(3)/tp(1)*tp(2)):tp(3)/tp(1):tp(3)-(tp(3)/tp(1))-(tp(3)/tp(1)*tp(2))];

	mesh ( time, b_field, bl_oc_data );

	view ( 2 );

	file_basename = get_file_basename ( filename );
	fig_filename = sprintf( '%s-2Dmesh.fig', file_basename );

	fig_title = sprintf ( 'filename: %s', strrep ( file_basename, '_', '\_' ) );
	title ( fig_title );
	xlabel ( 'time / \mus' );
	ylabel ( 'magnetic field / mT' );

	saveas ( gcf, fig_filename );

%******
