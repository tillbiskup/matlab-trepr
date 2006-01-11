% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/28
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, accumulate 2D spectra
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...
%


  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nSTART OF $RCSfile$\n');
  end;

% Accumulate 2D spectra

  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tSize of drift_comp_data1:\t%i %i\n', size(drift_comp_data1));
    fprintf('\tSize of drift_comp_data2:\t%i %i\n', size(drift_comp_data2));
    fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
    fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
  end;

  fprintf('\nAccumulate measurements...\n')
								% Telling the user what's going to happen

  acc_meas = accumulate_measurements ( drift_comp_data1, drift_comp_data2 );
  								% accumulate the measurements compensated until here
  								
  field_params = field_params1;

  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tSize of drift_comp_data1:\t%i %i\n', size(drift_comp_data1));
    fprintf('\tSize of drift_comp_data2:\t%i %i\n', size(drift_comp_data2));
    fprintf('\tSize of acc_meas:\t\t%i %i\n', size(acc_meas));
    fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
    fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
    fprintf('\tfield_params:\t\t\t%4.2f %4.2f %2.2f\n', field_params);
  end;

  if ( PLOTTING3D )
  
	figure;						% opens new graphic window
  
	[X,Y] = meshgrid ( min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command
  
	if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	  title('accumulated and compensated data');
	  gsplot ( acc_meas' );
								% make simple 3D plot of the offset compensated data

	else							% otherwise we assume that we're called by MATLAB(R)

	  mesh ( X', Y', acc_meas );
								% make simple 3D plot of the offset compensated data
	  title('accumulated and compensated data');

	end
	
  end
  
  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nEND OF $RCSfile$\n');
  end;
  