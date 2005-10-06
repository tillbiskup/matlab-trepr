% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* auxilliary_routines/discriminate_matlab_octave.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/06
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(R), GNU Octave
%
% SYNOPSIS
%	[ program, version ] = discriminate_matlab_octave
%
% DESCRIPTION
%	This function evaluates whether it is called within a MATLAB(R) or a GNU Octave
%	environment. Its two return values are the program name ('Matlab', 'Octave')
%	and the version of the program as printed with the command 'version'.
%
%******

function [ program, version ] = discriminate_matlab_octave

	Program = '';					% initially set variable to a default value.

	if exist('OCTAVE_VERSION') 		% test condition for GNU Octave
	
	% for Octave : LOADPATH, DEFAULT_LOADPATH, OCTAVE_HOME, OCTAVE_VERSION, EXEC_PATH

		Program = 'Octave';			% set variable to 'Octave'

	elseif exist('matlabroot')		% test condition for MATLAB(R)

		Program = 'Matlab';			% set variable to 'Matlab'

	end

	if isempty(Program)				% in case the test routine could not evaluate the program
									% display a warning and say what's going on
	
		disp('Warning: I do not recognize the Matlab/Octave program.');
		disp('         I will return the program name <unknown>.');
		
		Program = 'unknown';			% set variable to 'unknown'
	end
	
