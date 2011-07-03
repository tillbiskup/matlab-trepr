% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****f* data_processing.2D/trEPR_integrated_bl_comp.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/06/13
% VERSION
%	$Revision: 247 $
% MODIFICATION DATE
%	$Date: 2006-06-14 10:53:20 +0100 (Mi, 14 Jun 2006) $
% KEYWORDS
%	integration, pseudomodulation, polyfit
%
% SYNOPSIS
%	[ data, polyvals, polynomial ] = trEPR_integrated_bl_comp ( data, field_params )
%
%	[ data, polyvals, polynomial ] = trEPR_integrated_bl_comp ( data, field_params, region )
%
%	[ data, polyvals, polynomial ] = trEPR_integrated_bl_comp ( data, field_params, region, polynum )
%
% DESCRIPTION
%	The function takes a whole 2D spectrum as an input, integrates every
%	B_0 spectrum, fits the baseline with a polynomial fit and differentiates
%	it afterwards via pseudomodulation.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured data
%
%	field_params
%		a 3x1 vector containing of three values, the "field parameters"
%
%		These field parameters are:
%
%			start_field
%				the start position of the field sweep given in Gauss (G)
%			end_field
%				the stop position of the field sweep given in Gauss (G)
%			field_step_width
%				the step width by which the field is swept given in Gauss (G)
%
%		Normally this parameter is returned by the function trEPR_read_fsc2_file.
%
%	time_params
%		a 3x1 vector containing of three values, the "time parameters"
%	
%		These time parameters are:
%
%			no_points
%				number of points of the time slice
%			trig_pos
%				position of the trigger pulse
%			length_ts
%				length of the time slice in microseconds
%
%		Normally this parameter is returned by the function trEPR_read_fsc2_file.
%
%	region (OPTIONAL)
%		scalar or 1x2 vector defining the number of points of the B_0 spectrum
%		that will be used to fit the baseline to the integrated spectrum.
%
%		If region is a scalar it will be used as the number of data points for
%		both the lower and the upper part, if it is a vector its first value is used
%		for the lower, its second value for the upper part of the B_0 spectrum.
%
%		If no value is given the lower and upper 10 data points are used.
%
%	options (OPTIONAL)
%		scalar or 1x3 vector containing additional options.
%
%		If options is a scalar it is taken as the order of the polynomial that
%		should be used to fit the baseline of the integrated B_0 spectrum.
%
%		If it is a vector the three values are taken as the order of the polynomial,
%		the modulation amplitude of the pseudomodulation and the order of the
%		harmonics of the pseudomodulation, respectively.
%
%		For more information about the parameters for the pseudomodulation typein
%		'help pseudomodulation'.
%
%		If no value is given the third order polynomial is used for the baseline fit
%		and the parameters for the pseudomodulation are 0.2 for the modulation
%		amplitude and 1 for the harmonic respectively.
%
% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the baseline compensated data
%
%	polyvals (OPTIONAL)
%		NxM matrix containing the polynomial fits of the drift for each B_0 spectrum
%
%	polynomial (OPTIONAL)
%		nxM matrix containing the polynomial coefficients for each performed
%		polynomial fit, with the order 'n' of the polynomial used to fit.
%
% EXAMPLE
%	Suppose you want just to compensate the baseline in the integrated spectrum of
%	the recorded data 'data' and the field parameters 'fp' and the 
%	time parameters 'tp'
%
%		[ data ] = trEPR_integrated_bl_comp ( data, fp, tp )
%
% SOURCE

function [ data, varargout ] = trEPR_integrated_bl_comp ( data, field_params, time_params, varargin )

	fprintf('\nFUNCTION CALL: $Id: trEPR_integrated_bl_comp.m 247 2006-06-14 09:53:20Z web8 $\n\n');

	% check for the right number of input and output parameters

	if ( nargin < 3 ) || ( nargin > 5 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.',nargin);

	end

	if ( nargout < 1 ) || ( nargout > 3 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.',nargout);

	end
	

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	% TIME_PARAMS

	elseif ~isnumeric(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'
			
	end

	% OPTIONAL input parameters
	
	% REGION
	
	if ( nargin >= 4 )
	
		region = varargin{1};
	
		if ( ~isnumeric(region) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','region');
				% get error if function is called with the wrong format of the
				% input parameter 'region'
			
		elseif ( ~isscalar(region) && ~isvector(region) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','region');
				% get error if function is called with the wrong format of the
				% input parameter 'region'

		elseif ( ~isscalar(region) && ( length(region) ~= 2) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','region');
				% get error if function is called with the wrong format of the
				% input parameter 'region'

		end

	else
		% if there is no parameter 'options' given at the function call
		% set all necessary parameters for the further operation to default values

		region = 10;
		
	end

	% OPTIONS
	
	if ( nargin == 5 )
	
		options = varargin{2};
	
		if ( ~isnumeric(options) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','options');
				% get error if function is called with the wrong format of the
				% input parameter 'options'
				
		end
		
		if ( isscalar(options) )
		
			polynum = options;
	
			% set parameters for the pseudomodulation

			ModAmpl = 0.2;
			Harmonic = 1;
		
		elseif ( isvector(options) && length(options) ~= 3 )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','options');
				% get error if function is called with the wrong format of the
				% input parameter 'options'
				
		elseif ( isvector(options) && length(options) == 3 )
		

			polynum = options(1)

			% set parameters for the pseudomodulation
	
			ModAmpl = options(2);
			Harmonic = options(3);
	
		end

	else
		% if there is no parameter 'options' given at the function call
		% set all necessary parameters for the further operation to default values
		
		% set order of polynomial to fit the baseline
		
		polynum = 3;
	
		% set parameters for the pseudomodulation

		ModAmpl = 0.2;
		Harmonic = 1;
	
	end
	
	% check for the availability of the routines we depend on

	if ( exist('pseudomodulation.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'pseudomodulation');

	end
	
	if ( ~isscalar(region) )
	
		lower_region = region(1);
		upper_region = region(2);
	
	else
	
		lower_region = region;
		upper_region = region;
	
	end

	
	% here the real stuff takes place	

	% Integrate the 2D spectrum and correct for integral (total integral should 
	% be zero; i.e., absorptive = emissive).

	b_axis = [ 1 : 1 : ( abs ( ( field_params(1)-field_params(2) ) / field_params(3) ) ) + 1 ];
	% b_axis = [ field_params(1) : field_params(3) : field_params(2) ];

	for i= 1 : time_params(1)
	
	    % Integrate the spectrum.
	    
	    idata = cumtrapz ( b_axis, data(:,i) );

	    % Perform a polynomial fit.
	    
	    x = b_axis(1:lower_region);
	    x2 = b_axis(length(b_axis)-upper_region+1 : length(b_axis));
	    x = [ x x2 ];
	    
	    y = idata(1:lower_region);
	    y2 = idata(length(b_axis)-upper_region+1 : length(b_axis));
	    y = [ y ; y2 ]';
	    
	    p = polyfit(x, y, polynum);
	    yn = polyval(p, b_axis);
	    clear p;

	    % Subtract polynomial.
	    idata = idata - yn';

	    % Calculate 1st derivative using pseudomodulation.
	    data(:,i) = pseudomodulation(b_axis, idata, ModAmpl, Harmonic);
	    
	end
	
	% assign the optional output parameters depending on the number of output
	% parameters we're called with
	
	if ( nargout >= 2 )
	
		polyvals = varargout{1}
		
	end
		
	if ( nargout == 3 )
	
		polynomial = varargout{2}
		
	end


%******
