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
%	2006/04/04
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% DERIVED FROM
%	script_compensate_frequency.m
% KEYWORDS
%	MATLAB(R), GNU Octave, transient EPR, fsc2, compensate frequency, accumulate
%
% SYNOPSIS
%	[ data1, data2, field_params1, field_params2 ] = trEPR_compensate_frequency ( data1, data2, field_params1, field_params2, t1, t2 )
%
% DESCRIPTION
%
% GNU Octave COMPATIBILITY
% This file works perfectly with GNU Octave
%
% INPUT
%	data1, data2						1D or 2D
%	field_params1, field_params2		row vectors each consisting of three values
%	t1, t2							integers specifying the time position for the amplitude maximum of the spectra
%
% OUTPUT
%	data1, data2						1D or 2D
%	field_params1, field_params2		row vectors each consisting of three values
%
% SOURCE

function [ data1, data2, field_params1, field_params2 ] = trEPR_compensate_frequency ( data1, data2, field_params1, field_params2, t1, t2 )

	fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n' );

	% check for right number of input and output parameters

	if nargin ~= 6
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.',nargin);
			% get error if function is called with other than
			% six input parameters
	end

	if nargout ~= 4
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.',nargout);
			% get error if function is called with other than
			% four output parameters
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

	% First, evaluate difference in signal amplitude of both spectra and compensate for it
	% to improve the overlay of the B_0 spectra

	max_amplitude_spectrum1 = abs((max(max(data1))-(min(min(data1)))));
	max_amplitude_spectrum2 = abs((max(max(data2))-(min(min(data2)))));

	amplitude_difference = max_amplitude_spectrum1 / max_amplitude_spectrum2;

	% Second, plot overlay of both B_0 spectra


	fprintf('\nPrinting B_0 spectra for frequency compensation...\n')
								% Telling the user what's going to happen
								
	[ spectrum1, max_index1 ] = B0_spectrum ( data1, 2, t1 );
  
	[ spectrum2, max_index2 ] = B0_spectrum ( (data2*amplitude_difference), 2, t2 );
  
	exit_freq_comp = 0;			% set while loop exit condition to default value;

	offset1 = 0;					% set offset1 to default value;
	offset2 = 0;					% set offset2 to default value;

	while ( exit_freq_comp == 0 )
  
		x1 = [ 1+offset1 : 1 : size( data1( :, max_index1 ))+offset1 ];
		x2 = [ 1+offset2 : 1 : size( data1( :, max_index1 ))+offset2 ];

		% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT

		x1 = x1 / 10;
		x2 = x2 / 10;
		
		if ( program == 'Octave' )
			clg;
		else
			clf;
		end;
  
		hold on;

		title('Both B_0 spectra for frequency alignment')
		xlabel('B / mT');
		ylabel('I');

		plot(x1,spectrum1','-',x2,spectrum2','-',x1,zeros(1,length(x1)),'-')

   
		if ( program == 'Octave' )

		else
			legend( {'Spectrum 1','Spectrum 2'} )
		end;
  
		hold off;
  
		freq_comp_option = menu ( 'What would you want to do?', '< spectrum1', 'spectrum1 >', '< spectrum2', 'spectrum2 >', 'Exit');
  
		if ( freq_comp_option == 1)
  
			offset1 = offset1 - 1;
  
		elseif ( freq_comp_option == 2)
  
			offset1 = offset1 + 1;
  
		elseif ( freq_comp_option == 3)
  
			offset2 = offset2 - 1;
  
		elseif ( freq_comp_option == 4)
  
			offset2 = offset2 + 1;
  
		elseif ( freq_comp_option == 5)
  
			exit_freq_comp = 1;
    					% set exit condition for while loop true
  
		end
  
	end;							% end of while loop


	% DEBUGGING OUTPUT
	if ( DEBUGGING )
		fprintf('\nOffset1: %i; Offset2: %i\n',offset1, offset2);
	end;


	if ( ( offset1 ~= 0 ) | ( offset2 ~= 0 ) )

		startcut1 = 0;
		endcut1 = 0;
		startcut2 = 0;
		endcut2 = 0;

		if ( offset1 > 0 )
  
			endcut1 = offset1;

			fprintf('\nSpectrum 1 shifted %i Gauss to the right\n', endcut1);
    
		end

		if ( offset1 < 0 )
  
			startcut1 = abs(offset1);

			fprintf('\nSpectrum 1 shifted %i Gauss to the left\n', startcut1);
    
		end

		if ( offset2 > 0 )
  
			endcut2 = offset2;

			fprintf('\nSpectrum 2 shifted %i Gauss to the right\n', endcut2);
    
		end

		if ( offset2 < 0 )
  
			startcut2 = abs(offset2);

			fprintf('\nSpectrum 2 shifted %i Gauss to the left\n', startcut2);
    
		end

		% DEBUGGING OUTPUT
		if ( DEBUGGING )
			fprintf('\nDEBUGGING OUTPUT:\n');
			fprintf('\tstartcut1:\t%i\n', startcut1);
			fprintf('\tendcut1:\t%i\n', endcut1);
			fprintf('\tstartcut2:\t%i\n', startcut2);
			fprintf('\tendcut2:\t%i\n', endcut2);
			fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
			fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
		end;

		[ r1, c1 ] = size ( data1 );
		[ r2, c2 ] = size ( data2 );
  
		data1 = data1( 1+abs(startcut1-endcut2) : r1-abs(endcut1-startcut2) , : );

		if ( field_params1(1) < field_params1(2))
  						% if spectrum recorded from low to high field

			field_params1 = [ field_params1(1)+(abs((startcut1-endcut2)*field_params1(3))), field_params1(2)-(abs((endcut1-startcut2)*field_params1(3))), field_params1(3) ];

		else
  						% if spectrum recorded from high to low field

			field_params1 = [ field_params1(1)-(abs((startcut2-endcut1)*field_params1(3))), field_params1(2)+(abs((startcut1-endcut2)*field_params1(3))), field_params1(3) ];

		end;

		data2 = data2( 1+abs(startcut2-endcut1) : r2-abs(endcut2-startcut1) , :);

		if ( field_params2(1) < field_params2(2))
  						% if spectrum recorded from low to high field

			field_params2 = [ field_params2(1)+(abs((endcut2-startcut1)*field_params2(3))), field_params2(2)-(abs((startcut2-endcut1)*field_params2(3))), field_params2(3) ];
    

		else
  						% if spectrum recorded from high to low field

			field_params2 = [ field_params2(1)-(abs((startcut2-endcut1)*field_params2(3))), field_params2(2)+(abs((endcut2-startcut1)*field_params2(3))), field_params2(3) ];

		end;

		fprintf('\nSpectrum 1 and spectrum 2 are cut to fit to each other.\n');
		fprintf('\tNew dimensions of both spectra: %i rows, %i cols.\n', size(data1));

		fprintf('\n\tNew field parameter for both spectra:.\n');
		fprintf('\t\tfield borders:\t\t%4.2f G - %4.2f G\n\t\tfield step width:\t%2.2f G\n', field_params1);

	end;					% end if offset1 or offset 2 ~= 0


	field_params = field_params1;


		% DEBUGGING OUTPUT
		if ( DEBUGGING )
			fprintf('\nDEBUGGING OUTPUT:\n');
			fprintf('\tSize of data1:\t%i %i\n', size(data1));
			fprintf('\tSize of data2:\t%i %i\n', size(data2));
			fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
			fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
			fprintf('\tfield_params:\t\t\t%4.2f %4.2f %2.2f\n', field_params);
		end;

%******
