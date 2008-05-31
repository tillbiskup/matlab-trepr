% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/accumulate_measurements.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/09/29
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2, accumulate measurements
%
% SYNOPSIS
%	DATA = accumulate_measurements ( MATRIX1, MATRIX2 )
%
% DESCRIPTION
%	This function gets two matrices and sums them up element-wise
%	thus accumulating the measurements to improve the signal to noise ratio.	
%
%	Before summarizing up the matrices the function will test for identical
%	dimensions of the matrices and otherwise return an error message
%
%	Instead of simply summarizing this function checks for the best possibility
%	to do this in a way the noise is minimized.
%
%	This is done by calculating a quality parameter (the ratio of the standard
%	deviation of the off-resonance noise to the maximum signal amplitude)
%	and a weighted addition of both spectra optimized in a way to yield
%	maximum quality measured by the quality parameter.
%
% INPUT PARAMETERS
%	matrix1
%		NxM matrix containing the first set of measured data
%
%	matrix2
%		NxM matrix containing the second set measured data
%
% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the accumulated data
%
% EXAMPLE
%	accumulation of two matrices representing two measurements
%
%		acc_data = accumulate_measurements ( measurement1, measurement2 )
%
% DEPENDS ON
%	quality_of_spectrum.m
%
% SOURCE

function data = accumulate_measurements ( matrix1, matrix2 )

	fprintf ( '\n%% FUNCTION CALL: $Id$\n%%' );

	% check for the right number of input and output parameters

	if ( nargin ~= 2 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help accumulate_measurements" to get help.',nargin);

	end

	if ( nargout ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help accumulate_measurements" to get help.',nargout);

	end

	% check for correct format of the input parameters
	
	% MATRIX1
	
	if ( ~isnumeric(matrix1) || isscalar(matrix1) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help accumulate_measurements" to get help.','matrix1');
			% get error if function is called with the wrong format of the
			% input parameter 'matrix1'
	
	% MATRIX2
	
	elseif ( ~isnumeric(matrix2) || isscalar(matrix2) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help accumulate_measurements" to get help.','matrix2');
			% get error if function is called with the wrong format of the
			% input parameter 'matrix2'
	
	end

	% check for the availability of the routines we depend on

	if ( exist('quality_of_spectrum.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'quality_of_spectrum');
	
	end
	
	% discriminate between matrix or vector as input
	
	if ( isvector(matrix1) && isvector(matrix2) )
	
		num_ts = 10;
	
	else
	
		num_ts = 10;
	
	end;
	

	global DEBUGGING;

	
	% scale both matrices to the same signal height
	% by using the ratio of the maximum signal amplitudes of both matrices
	
	[ quality_matrix1, amplitude_matrix1, std_noise_matrix1 ] = quality_of_spectrum ( matrix1, num_ts );

	[ quality_matrix2, amplitude_matrix2, std_noise_matrix2 ] = quality_of_spectrum ( matrix2, num_ts );

	matrix2 = amplitude_matrix1/amplitude_matrix2 * matrix2;
	
	
	% check for best sum

	sum_quality = ones(1,100);
	sum_amplitude = ones(1,100);
	sum_std_noise = ones(1,100);
							% for improved memory usage the vector is initialized at first

	for i = 1:100

		sum = summarize_matrices ( matrix1, matrix2, (i/10) );
							% sum up the two matrices
							
		[ quality, amplitude, std_noise ] = quality_of_spectrum ( sum, num_ts );
							% the quality is calculated with the first 10 off-resonance time slices
							% as the reference (the second input parameter for the quality_of_spectrum function)
							
		sum_quality (1,i) = quality;
							% the quality is written to the vector sum_quality for all passes
							% of the loop
							
		sum_amplitude (1,i) = amplitude;
							% the amplitude is written to the vector sum_amplitude for all passes
							% of the loop
							
		sum_std_noise (1,i) = std_noise;
							% the std_noise is written to the vector sum_std_noise for all passes
							% of the loop
		
	end
	
	[ best_quality, index_best_quality ] = max(sum_quality);
	
	data = summarize_matrices ( matrix1, matrix2, (index_best_quality/10) );
	
	[ quality_data, amplitude_data, std_noise_data ] = quality_of_spectrum ( data, num_ts );
	
	if ( DEBUGGING )
	
		figure;
		
		x = [1:1:100];

		plot(x,sum_quality',x,sum_amplitude',x,sum_std_noise');
		legend('Quality','Amplitude','Std Dev of Noise');
	
	end;
	
	
	fprintf('\n%% Overview of the quality of the spectra\n%%');
	fprintf('\n%% \t\tquality\t\tamplitude\tstd_noise\n%% ');
	fprintf('matrix 1:\t%2.4f\t\t%1.4f\t\t%f\n%% ',quality_matrix1, amplitude_matrix1, std_noise_matrix1);
	fprintf('matrix 2:\t%2.4f\t\t%1.4f\t\t%f\n%% ',quality_matrix2, amplitude_matrix2, std_noise_matrix2);
	fprintf('acc. data:\t%2.4f\t\t%1.4f\t\t%f\n%% ',quality_data, amplitude_data, std_noise_data);

	fprintf('\n%% Weight of the matrix summation: matrix1 + %i * matrix2\n%%\n%% ', index_best_quality/10);
	
	if nargin > 2			% if the function is called with more than two parameters

		for i = 3 : nargin	% as long as there are unused input parameters
	
			data = summarize_matrices ( data, va_arg () );
						% sum up the matrices
		
		end					% end for
	
	end					% end if
	
	
%******

%###############################################################
% SUBFUNCTIONS

%****if* accumulate_measurements/summarize_matrices

function summarized_matrix = summarize_matrices ( matrix1, matrix2, weight )

% SYNOPSIS
%
%	summarized_matrix = summarize_matrices ( matrix1, matrix 2, weight )
%
% DESCRIPTION
%
%	This function summarizes up two given matrices MATRIX1 and MATRIX2 and returns
%	the summarized matrix SUMMARIZED_MATRIX. The parameter WEIGHT is used to do a
%	weighted matrix sum in the form
%
%	SUMMARIZED_MATRIX = MATRIX1 + WEIGHT * MATRIX2
%
%	Before the sum operation it is checked whether both matrices are of the same size.
%	Otherwise a warning is printed and the matrix MATRIX1 is returned as result.
%
% SOURCE

	if size(matrix1) == size(matrix2)
							% if both matrices are of the same size

	summarized_matrix = matrix1 + (weight * matrix2);
							% sum up the matrices
							% and return summarized matrix
	else
	
		fprintf ( '\n%% WARNING:\n%%          Matrices are not of same size! MATRIX1 returned!\n%% ' )
							% print warning
							
		summarized_matrix = matrix1;
							% return MATRIX1
	
	end

%*****
