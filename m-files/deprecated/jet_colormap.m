% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
%
%****h* auxilliary_routines/jet_colormap.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/03/29
% VERSION
%	$Revision: 130 $
% MODIFICATION DATE
%	$Date: 2006-03-29 14:38:19 +0100 (Mi, 29 Mär 2006) $
% KEYWORDS
%	colormap, jet
%
% SYNOPSIS
%	jet_colormap
% 
% DESCRIPTION
%
%	This file provides the MATLAB(TM) "jet" colormap for GNU OCTAVE.
%
%	Calling this command without any parameter sets the current colormap
%	to the "jet" colormap as provided by MATLAB(TM).
%
%	From the MATLAB(TM) documentation of "colormap":
%
%	jet ranges from blue to red, and passes through the colors cyan,
%	yellow, and orange. It is a variation of the hsv colormap.
%	The jet colormap is associated with an astrophysical fluid jet
%	simulation from the National Center for Supercomputer Applications.
%
% SOURCE

jet = [
   0.0000000e+00   0.0000000e+00   5.6250000e-01
   0.0000000e+00   0.0000000e+00   6.2500000e-01
   0.0000000e+00   0.0000000e+00   6.8750000e-01
   0.0000000e+00   0.0000000e+00   7.5000000e-01
   0.0000000e+00   0.0000000e+00   8.1250000e-01
   0.0000000e+00   0.0000000e+00   8.7500000e-01
   0.0000000e+00   0.0000000e+00   9.3750000e-01
   0.0000000e+00   0.0000000e+00   1.0000000e+00
   0.0000000e+00   6.2500000e-02   1.0000000e+00
   0.0000000e+00   1.2500000e-01   1.0000000e+00
   0.0000000e+00   1.8750000e-01   1.0000000e+00
   0.0000000e+00   2.5000000e-01   1.0000000e+00
   0.0000000e+00   3.1250000e-01   1.0000000e+00
   0.0000000e+00   3.7500000e-01   1.0000000e+00
   0.0000000e+00   4.3750000e-01   1.0000000e+00
   0.0000000e+00   5.0000000e-01   1.0000000e+00
   0.0000000e+00   5.6250000e-01   1.0000000e+00
   0.0000000e+00   6.2500000e-01   1.0000000e+00
   0.0000000e+00   6.8750000e-01   1.0000000e+00
   0.0000000e+00   7.5000000e-01   1.0000000e+00
   0.0000000e+00   8.1250000e-01   1.0000000e+00
   0.0000000e+00   8.7500000e-01   1.0000000e+00
   0.0000000e+00   9.3750000e-01   1.0000000e+00
   0.0000000e+00   1.0000000e+00   1.0000000e+00
   6.2500000e-02   1.0000000e+00   9.3750000e-01
   1.2500000e-01   1.0000000e+00   8.7500000e-01
   1.8750000e-01   1.0000000e+00   8.1250000e-01
   2.5000000e-01   1.0000000e+00   7.5000000e-01
   3.1250000e-01   1.0000000e+00   6.8750000e-01
   3.7500000e-01   1.0000000e+00   6.2500000e-01
   4.3750000e-01   1.0000000e+00   5.6250000e-01
   5.0000000e-01   1.0000000e+00   5.0000000e-01
   5.6250000e-01   1.0000000e+00   4.3750000e-01
   6.2500000e-01   1.0000000e+00   3.7500000e-01
   6.8750000e-01   1.0000000e+00   3.1250000e-01
   7.5000000e-01   1.0000000e+00   2.5000000e-01
   8.1250000e-01   1.0000000e+00   1.8750000e-01
   8.7500000e-01   1.0000000e+00   1.2500000e-01
   9.3750000e-01   1.0000000e+00   6.2500000e-02
   1.0000000e+00   1.0000000e+00   0.0000000e+00
   1.0000000e+00   9.3750000e-01   0.0000000e+00
   1.0000000e+00   8.7500000e-01   0.0000000e+00
   1.0000000e+00   8.1250000e-01   0.0000000e+00
   1.0000000e+00   7.5000000e-01   0.0000000e+00
   1.0000000e+00   6.8750000e-01   0.0000000e+00
   1.0000000e+00   6.2500000e-01   0.0000000e+00
   1.0000000e+00   5.6250000e-01   0.0000000e+00
   1.0000000e+00   5.0000000e-01   0.0000000e+00
   1.0000000e+00   4.3750000e-01   0.0000000e+00
   1.0000000e+00   3.7500000e-01   0.0000000e+00
   1.0000000e+00   3.1250000e-01   0.0000000e+00
   1.0000000e+00   2.5000000e-01   0.0000000e+00
   1.0000000e+00   1.8750000e-01   0.0000000e+00
   1.0000000e+00   1.2500000e-01   0.0000000e+00
   1.0000000e+00   6.2500000e-02   0.0000000e+00
   1.0000000e+00   0.0000000e+00   0.0000000e+00
   9.3750000e-01   0.0000000e+00   0.0000000e+00
   8.7500000e-01   0.0000000e+00   0.0000000e+00
   8.1250000e-01   0.0000000e+00   0.0000000e+00
   7.5000000e-01   0.0000000e+00   0.0000000e+00
   6.8750000e-01   0.0000000e+00   0.0000000e+00
   6.2500000e-01   0.0000000e+00   0.0000000e+00
   5.6250000e-01   0.0000000e+00   0.0000000e+00
   5.0000000e-01   0.0000000e+00   0.0000000e+00
];

colormap( jet );

%******
