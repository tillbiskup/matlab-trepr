% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* user_routines/trEPR_compensate_frequency.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/04/05
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% DERIVED FROM
%	script_compensate_baseline.m
% KEYWORDS
%	MATLAB(R), GNU Octave, transient EPR, fsc2, compensate baseline
%
% SYNOPSIS
%	[ data ] = trEPR_compensate_baseline ( data, field_params, no_points, t )
%
% DESCRIPTION
%
% INPUT
%	* data (1D or 2D)
%	* field_params
%	* no_points -- number of data points that are used from the start and the end of the spectrum
%	* t -- optional, positition in time of the 2D data for maximum signal amplitude
%
% OUTPUT
%	* data - compensated spectrum (1D)
%
% DEPENDS ON
%	* program
%
% TASKS
%	* Allow user to select the regions at the ends of the spectrum that are used to fit
%	  the baseline
%	* Allow user to choose between several different polynoms for fitting the baseline
%
% SOURCE

function [ data ] = trEPR_compensate_baseline ( data, field_params, no_points, varargin )

	fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n' );

	% check for right number of input and output parameters

	if ( ( nargin < 3 ) || ( nargin > 4 ) )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.',nargin);
			% get error if function is called with less than
			% three or more than four input parameters
	end
	
	if nargin == 4
	
		t = varargin{1};
	
	end

	if nargout ~= 1
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter
	end

	% set some global variables

	global program;
	global DEBUGGING;
	
	if (length(program) == 0)
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

	% Set the number of data points that are used from the start and the end of the spectrum
	% to perform the fit

	fprintf('\nThe first and the last %i data points of the B_0 spectrum together with\none data point at the center of the spectrum - this one can be moved by the user - \nare taken to perform a quadratic fit.\n', no_points);

	% Plot B_0 spectrum and fit baseline from the first and last 20 data points

	exit_baseline_comp = 0;		% set while loop exit condition to default value;


	% set the correct values for the x axis (B_0 field) in mT
	x = [ min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]) ];
	x = x / 10;				% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT


	if ~isvector ( data )

		% evaluate the spectrum at given time position "t"
		spectrum = B0_spectrum ( data, 2, t );
		
	else
	
		spectrum = data;

	end

	% set starting point for vertical line in the middle of the spectrum
	vert_x = x(round(length(x)/2));
	spectrum_center = round(length(spectrum)/2);

	% get the first and last no_points data points from the spectrum
	spectrum_first_part = spectrum ( 1:no_points );
	spectrum_last_part = spectrum ( (length(spectrum)-no_points+1):(length(spectrum)) );

	baseline_comp = [ spectrum_first_part' ; spectrum(spectrum_center) ; spectrum_last_part' ];

	% create a vector containing the B_0 field values according to the above gotten data points from the spectrum
	index1_baseline_comp = [(min([field_params(1) field_params(2)])) : abs(field_params(3)) : (min([field_params(1) field_params(2)])+(no_points*abs(field_params(3)))-abs(field_params(3)))];
	index2_baseline_comp = [(max([field_params(1) field_params(2)])-(no_points*abs(field_params(3)))+abs(field_params(3))) : abs(field_params(3)) : (max([field_params(1) field_params(2)]))];

	index_baseline_comp = [ index1_baseline_comp' ; vert_x*10 ; index2_baseline_comp' ] / 10;


	% after all this start with main while loop and give the user the possibility
	% to compensate for the baseline.
	% Therefore the spectrum, the fitted baseline, a horizontal line at y=0 and
	% a vertical line at the half width of the spectrum is plotted
	% The vertical line displays the point in the spectrum where the single value
	% at the center of the whole spectrum is taken that is considered for the fit of the baseline. 

	while ( exit_baseline_comp == 0 )

	% compute 2nd order polynomial fit using the first and last no_points data points of the
	% spectrum and a single point in the center of the spectrum.
	% polyfit finds the coefficients of a polynomial,

	polynom_2nd_order = polyfit( index_baseline_comp, baseline_comp, 2 );

	% polyval, given these coefficients and a new vector for x calculates a curve from the fit
	% that can be plotted

	baseline = polyval(polynom_2nd_order,x);
 
	% clear the graphics window
	if program == 'Octave'
		clg;
	else
		clf;
	end;

	hold on;				% add anything to the actual graphics window

	% set graphics title and axis labels
 
	graph_title = [ 'B_0 at maximum signal amplitude for baseline compensation' ];

	title(graph_title);
	xlabel('B / mT');
	ylabel('I');

	% set axis properties so that the axes will not be rescaled
	[ max_values, max_index ] = max( max( data ));
	[ min_values, min_index ] = min( min( data ));
	axis([ (min([field_params(1) field_params(2)])/10) (max([field_params(1) field_params(2)])/10) min_values max_values]);

	% plot spectrum, horizontal line and baseline
	plot(x,spectrum',x,zeros(1,length(x)),x,baseline);
	
	% plot vertical line
	y = [ min(spectrum) : ((max(spectrum)-min(spectrum))*0.01) : max(spectrum) ];
	plot(vert_x*ones(length(y)),y);
	
	% stop plotting all things in the actual graphics window
	hold off;
	
	% start with user menu that gives the user the possibility to move the data point
	% taken for baseline compensation in the center of the spectrum
	
	baseline_comp_option = menu ( 'What would you want to do?', 'move center: 1 >', 'move center: 1 <', 'move center: 10 >', 'move center: 10 <', 'proceed with chosen compensation');
	
	if ( baseline_comp_option == 1)
	
		% that is, if the user chose to move the data point in the center of the spectrum
		% one point to the right

		vert_x = vert_x + abs(field_params(3)/10);
						% set new x value for the vertical line display
						% as well as for the baseline drift compensation
		spectrum_center = spectrum_center + 1;
						% set new index for the data point that is taken from
						% the center of the spectrum to compensate the baseline
	
		baseline_comp = [ spectrum_first_part' ; spectrum(spectrum_center) ; spectrum_last_part' ];
						% get new data points from the spectrum that are used
						% for compensation via polyfit
		index_baseline_comp = [ index1_baseline_comp' ; vert_x*10 ; index2_baseline_comp' ] / 10;
						% set the corresponding x values for the polyfit call
		
	elseif ( baseline_comp_option == 2)
	
		% that is, if the user chose to move the data point in the center of the spectrum
		% one point to the left

		vert_x = vert_x - abs(field_params(3)/10);
		spectrum_center = spectrum_center - 1;
	
		baseline_comp = [ spectrum_first_part' ; spectrum(spectrum_center) ; spectrum_last_part' ];
		index_baseline_comp = [ index1_baseline_comp' ; vert_x*10 ; index2_baseline_comp' ] / 10;

	elseif ( baseline_comp_option == 3)
	
		% that is, if the user chose to move the data point in the center of the spectrum
		% ten points to the right

		vert_x = vert_x + 10*abs(field_params(3)/10);
		spectrum_center = spectrum_center + 10;
	
		baseline_comp = [ spectrum_first_part' ; spectrum(spectrum_center) ; spectrum_last_part' ];
		index_baseline_comp = [ index1_baseline_comp' ; vert_x*10 ; index2_baseline_comp' ] / 10;

	elseif ( baseline_comp_option == 4)
	
		% that is, if the user chose to move the data point in the center of the spectrum
		% ten points to the left

		vert_x = vert_x - 10*abs(field_params(3)/10);
 		spectrum_center = spectrum_center - 10;
	
		baseline_comp = [ spectrum_first_part' ; spectrum(spectrum_center) ; spectrum_last_part' ];
		index_baseline_comp = [ index1_baseline_comp' ; vert_x*10 ; index2_baseline_comp' ] / 10;
	
	elseif ( baseline_comp_option == 5)
	
		exit_baseline_comp = 1;
							% set exit condition for while loop true
	
	end				% end of if loop that checks for the menu

	
	end;							% end of while loop


	% In the end after manually compensating the baseline fit just do the compensation
	% and plot the result
 
	% clear the graphics window
	if program == 'Octave'
		clg;
	else
		clf;
	end;

	hold on;					% add anything to the actual graphics window
	
	% set graphics title and axis labels	

	graph_title = [ 'baseline compensated spectrum' ];

	title(graph_title);
	xlabel('B / mT');
	ylabel('I');


	fprintf('\nThe polynom used for fitting the baseline is as follows:\n\n\t%2.8f x^2 + %2.8f x + %2.8f\n\n', polynom_2nd_order);

	% perform the compensation itself by simple subtraction of the calculated baseline
	% from the original spectrum

	compensated_spectrum = spectrum - baseline;

	% plot the compensated spectrum
	% again together with a horizontal line at y = 0

	plot(x,compensated_spectrum',x,zeros(1,length(x)));

	% stop plotting all things in the actual graphics window
	hold off;

	data = compensated_spectrum;

%******