% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/make_reduced_2D_plot.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/06/14
% VERSION
%	$Revision: 665 $
% MODIFICATION DATE
%	$Date: 2008-06-26 10:00:38 +0100 (Do, 26 Jun 2008) $
% KEYWORDS
%	2D spectra, mesh, reduced grid, EPR
%
% SYNOPSIS
%	data = make_reduced_2D_plot ( data, fp, tp )
%
%	data = make_reduced_2D_plot ( data, fp, tp, 50 )
%
%	data = make_reduced_2D_plot ( data, fp, tp, [50,50] )
%
%	[ data, fp, tp ] = make_reduced_2D_plot ( data, fp, tp, [50,50] )
%
% DESCRIPTION
%	This function takes a compensated 2D spectrum as input and reduces
%	the data points to create a nice-looking 2D mesh plot, e.g. for publications
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
%	reduction (OPTIONAL)
%		scalar or 1x2 vector containing the number of points for both dimensions.
%
%		If reduction is a scalar the value is used for both dimensions,
%		if it is a vector, the first value counts for the B_0 field axis, the second
%		for the time dimension.
%
%		In case of no value provided while calling the function the default of
%		50 points for both dimensions is used.
%
% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the measured data with reduced data points
%
%	field_params
%		a 3x1 vector containing of three values, the "field parameters"
%
%	time_params
%		a 3x1 vector containing of three values, the "time parameters"
%
% EXAMPLE
%	If you just want to reduce the compensated 2D data set 'data' with the field
%	parameters 'fp' and the time parameters 'tp' to the default of 50 points in both
%	dimensions typein:
%
%		data = make_reduced_2D_plot ( data, fp, tp )
%
%
% SOURCE

function [ data, varargout ] = make_reduced_2D_plot ( data, field_params, time_params, varargin )

	fprintf('\n%% FUNCTION CALL: $Id: make_reduced_2D_plot.m 665 2008-06-26 09:00:38Z till $\n\n');

	% check for the right number of input and output parameters

	if ( nargin < 3 ) || ( nargin > 4 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help make_reduced_2D_plot" to get help.',nargin);

	end

	if ( nargout < 1 ) || ( nargout > 3 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help make_reduced_2D_plot" to get help.',nargout);

	end


	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	% TIME_PARAMS

	elseif ~isnumeric(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'
	
	end

	% OPTIONAL input parameters

	% REDUCTION
	
	if ( nargin == 4 )
	
		reduction = varargin{1};
	
		if ( ~isnumeric(reduction) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','reduction');
				% get error if function is called with the wrong format of the
				% input parameter 'reduction'
				
		end
		
		if ( isscalar(reduction) )
		
			b_reduction = reduction;
			t_reduction = reduction;
		
		elseif ( isvector(reduction) && length(reduction) ~= 2 )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_integrated_bl_comp" to get help.','reduction');
				% get error if function is called with the wrong format of the
				% input parameter 'reduction'
				
		elseif ( isvector(reduction) && length(reduction) == 2 )
		
			b_reduction = reduction(1);
			t_reduction = reduction(2);
	
		end

	else
		% if there is no parameter 'reduction' given at the function call
		% set all necessary parameters for the further operation to default values

		b_reduction = 50;
		t_reduction = 50;
	
	end
	
	% print info to what number of points the data are reduced
	
	fprintf('%% INFO: Reducing data to %i points in magnetic field dimension\n%%                    and %i points in time dimension...\n\n', b_reduction, t_reduction);
	
	[ baxis, taxis ] = size ( data );
	
	t_reduction_stepwidth = floor ( taxis / t_reduction );
	b_reduction_stepwidth = floor ( baxis / b_reduction );
	
	% Reduce the number of data points per time profile from 500 to 50.
	for i=1:baxis
		for j=1:t_reduction
			sum = 0.0;
			for k=1:t_reduction_stepwidth
				sum = sum + data(i, k + (j-1)*t_reduction_stepwidth);
			end
			tred_data(i, j) = sum/t_reduction_stepwidth;
		end
	end
	
	fp = field_params;
	bOffset = floor((((fp(2)-(b_reduction_stepwidth*b_reduction*fp(3)))-fp(1))/fp(3))/2);
    if (bOffset < 0)
        bOffset = 0
    end
    
	% Reduce the number of data points per B_0 profile from 151 to 50.
	for i=1:t_reduction
		for j=1:b_reduction
			sum = 0.0;
			for k=1:b_reduction_stepwidth
                sum = sum + tred_data(k+((j-1)*b_reduction_stepwidth)+bOffset, i);
			end
			btred_data(j, i) = sum/b_reduction_stepwidth;
		end
	end
	
	% generate new field parameters

	if ( nargout >= 2 )

		if field_params(3) > 0
		
			field_params(1) = field_params(1) + (b_reduction_stepwidth*field_params(3)/2);
			field_params(2) = field_params(1) + (b_reduction_stepwidth*(b_reduction))*abs(field_params(3))-b_reduction_stepwidth*field_params(3);
	
			field_params(3) = b_reduction_stepwidth*field_params(3);
	
		else
		
			field_params(2) = field_params(2) - (b_reduction_stepwidth*field_params(3)/2);
			field_params(1) = field_params(2) + (b_reduction_stepwidth*(b_reduction))*abs(field_params(3))-b_reduction_stepwidth*field_params(3);

			field_params(3) = b_reduction_stepwidth*field_params(3);
	
		end

		varargout{1} = field_params;
		
	end

	% generate new time parameters

	if ( nargout == 3 )
	
		time_params(1) = t_reduction;
		time_params(2) = time_params(2) / t_reduction_stepwidth;
		time_params(3) = time_params(3)/t_reduction*(t_reduction-1);
	
		varargout{2} = time_params;
		
	end

	data = btred_data;

%******
