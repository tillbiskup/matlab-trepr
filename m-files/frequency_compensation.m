% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* core_routines/frequency_compensation.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/11/21
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(R), GNU Octave, transient EPR, fsc2, compensate frequency
%
% SYNOPSIS
%	[ spectrum1, spectrum2, field_params1, field_params2 ] = frequency_compensation ( spectrum1, spectrum2, field_params1, field_params2, t1, t2 )
%
% DESCRIPTION
%
%	FREQUENCY_COMPENSATION gets two spectra (either 1D or 2D), plots them together in one
%	graphics window and gives the user the possibility to shift them so that they match
%	one the other.
%
%	After this the spectra are cut at their overlapping ends and the field parameters compensated
%	as well. Both spectra and field parameter vectors are returned by the function.
%
% INPUT
%	spectrum1, spectrum2				1D or 2D
%	field_params1, field_params2		each consisting of three values
%	t1, t2							REMARK: in the moment the old spectrum is just
%									plotted with t from the new one...
% OUTPUT
%	spectrum1, spectrum2				1D or 2D
%	field_params1, field_params2		each consisting of three values
%
% TASKS
%	- Get it work with either 1D or 2D data
%
%
% SOURCE

function [ spectrum1, spectrum2, field_params1, field_params2 ] = frequency_compensation ( spectrum1, spectrum2, field_params1, field_params2, t1, t2 )

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$' );


  % here has to go some evaluation of the input parameters:
  % are both spectra either 1D or 2D? Mixing is not allowed at the moment...


  global DEBUGGING;
  
  global program;


  % First, evaluate difference in signal amplitude of both spectra and compensate for it
  % to improve the overlay of the B_0 spectra

  max_amplitude_spectrum1 = abs((max(max(spectrum1))-(min(min(spectrum1)))));
  max_amplitude_spectrum2 = abs((max(max(spectrum2))-(min(min(spectrum2)))));

  amplitude_difference = max_amplitude_spectrum1 / max_amplitude_spectrum2;

  % if input spectra are 2D get 1D B_0 spectrum
  
  if ( ( isvector(spectrum1) == 0 ) && ( isvector(spectrum2) == 0 ) ) 
  
  	% if both spectra are no vectors, that means that they are matrices
  	% or, more exactly, not 1D - cause a simple scalar is as well a vector
	
	% evaluate the 1D B_0 spectrum at position t1 or t2 respectively
  								
	[ spectrum1_1D, max_index1 ] = B0_spectrum ( spectrum1, 2, t1 );
	[ spectrum2_1D, max_index2 ] = B0_spectrum ( spectrum2, 2, t2 );
	
	% evaluate the dimensions of the spectra
		
    [ r1, c1 ] = size ( spectrum1 );
    [ r2, c2 ] = size ( spectrum2 );
	  
  else
  
  	% if both spectra are just vectors
  
  	% fill 1D variables with 1D spectra
  	
  	spectrum1_1D = spectrum1;
  	spectrum2_1D = spectrum2;
	
	% evaluate the dimensions of the spectra
		
    [ r1, c1 ] = size ( spectrum1' );
    [ r2, c2 ] = size ( spectrum2' );
  
  end;
  
  % compensate for the different signal amplitude
  
  spectrum2_1D = spectrum2_1D * amplitude_difference;


  % Second, plot overlay of both B_0 spectra and give the user the possibility
  % to shift one spectrum against the other

  fprintf('\nPrinting B_0 spectra for frequency compensation...\n')
						% Telling the user what's going to happen
  
  figure;				% opens new graphic window

  exit_freq_comp = 0;		% set while loop exit condition to default value;

  offset1 = 0;			% set offset1 to default value;
  offset2 = 0;			% set offset2 to default value;

  while ( exit_freq_comp == 0 )
  
    x1 = [ 1 + offset1 : 1 : length( spectrum1_1D ) + offset1 ];
    x2 = [ 1 + offset2 : 1 : length( spectrum2_1D ) + offset2 ];

    % to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT

    x1 = x1 / 10;
    x2 = x2 / 10;
  

	if program == 'Octave'			% clear graphics window contents
	  clg;							% this is especially necessary with GNU Octave
	else
	  clf;
	end;

    hold on;

    title('Both B_0 spectra for frequency alignment')
    xlabel('B / mT');
    ylabel('I');

    plot(x1,spectrum1_1D','-',x2,spectrum2_1D','-',x1,zeros(1,length(x1)),'-')

	if program == 'Octave'
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

    % DEBUGGING OUTPUT
    if ( DEBUGGING )
      fprintf('\nDEBUGGING OUTPUT:\n');
      fprintf('\tr1, c1:\t%i, %i\n', r1, c1);
      fprintf('\tr2, c2:\t%i, %i\n', r2, c2);
    end;
    
    if ( isvector(spectrum1) )

      spectrum1 = spectrum1( : , 1+abs(startcut1-endcut2) : r1-abs(endcut1-startcut2) );
    
    else
  
      spectrum1 = spectrum1( 1+abs(startcut1-endcut2) : r1-abs(endcut1-startcut2) , : );
      
    end;

    if ( field_params1(1) < field_params1(2))
  						% if spectrum recorded from low to high field

      field_params1 = [ field_params1(1)+(abs((startcut1-endcut2)*field_params1(3))), field_params1(2)-(abs((endcut1-startcut2)*field_params1(3))), field_params1(3) ];

    else
  						% if spectrum recorded from high to low field

      field_params1 = [ field_params1(1)-(abs((startcut2-endcut1)*field_params1(3))), field_params1(2)+(abs((startcut1-endcut2)*field_params1(3))), field_params1(3) ];

    end;

    
    if ( isvector(spectrum2) )

      spectrum2 = spectrum2( : , 1+abs(startcut2-endcut1) : r2-abs(endcut2-startcut1) );
    
    else
  
      spectrum2 = spectrum2( 1+abs(startcut2-endcut1) : r2-abs(endcut2-startcut1) , :);
      
    end;

    if ( field_params2(1) < field_params2(2))
  						% if spectrum recorded from low to high field

      field_params2 = [ field_params2(1)+(abs((endcut2-startcut1)*field_params2(3))), field_params2(2)-(abs((startcut2-endcut1)*field_params2(3))), field_params2(3) ];
    

    else
  						% if spectrum recorded from high to low field

      field_params2 = [ field_params2(1)-(abs((startcut2-endcut1)*field_params2(3))), field_params2(2)+(abs((endcut2-startcut1)*field_params2(3))), field_params2(3) ];

    end;

    fprintf('\nSpectrum 1 and spectrum 2 are cut to fit to each other.\n');
    fprintf('\tNew dimensions of both spectra: %i rows, %i cols.\n', size(spectrum1));

    fprintf('\n\tNew field parameter for both spectra:.\n');
    fprintf('\t\tfield borders:\t\t%4.2f G - %4.2f G\n\t\tfield step width:\t%2.2f G\n', field_params1);

  end;					% end if offset1 or offset 2 ~= 0


  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tSize of spectrum1:\t%i %i\n', size(spectrum1));
    fprintf('\tSize of spectrum2:\t%i %i\n', size(spectrum2));
    fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
    fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
  end;

  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nEND OF $RCSfile$\n');
  end;


%*******