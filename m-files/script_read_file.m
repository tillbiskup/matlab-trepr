% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/26
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, read data file
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...
%
% NOTE
% This script has been converted to a function residing in the file
%	trEPR_read_fsc2_file.m
%
% INPUT
%
% OUTPUT
%	data
%	frequency
%	field_params
%	scope_params
%	time_params
%
%	filename
%	trigger_pos
%

% print warning message saying that this script has been replaced by a regular function
fprintf('IMPORTANT NOTE: Please be aware that this script has been replaced by a function\ncalled "trEPR_read_fsc2_file". For further information just typein "help trEPR_read_fsc2_file".');


% Ask the user for a file name to read and if file name is valid, read data

filename = ' ';					% set filename to empty value
								% the space is necessary not to confuse GNU Octave

while (exist(filename) == 0)		% while there is no valid filename specified
								% This would be better done with a do...until loop
								% but silly MATLAB(R) doesn't support this...

  filename = input ( '\nPlease enter a filename of a fsc2 data file:\n   ', 's' );

  if (length( filename ) > 0)		% If the user provided a filename

    if program == 'Octave'		% if we're called by GNU Octave (as determined above)
  
  	  filename = tilde_expand ( filename );
  								% expand filenames with tilde
  	
    end							% end if program == 'Octave'
  
    if (exist(filename) == 0)
  
      fprintf ( 'File not found!' );
    
    end
  
  else							% In case the user didn't provide a filename

    fprintf ( 'You have not entered any file name!\n\n' );
								% just print a short message and return to main loop
    filename = 'foo.bar';
    								% set a default filename for the 'exist(filename)' test
    								% needs a filename and cannot work with an empty string
  
  end

end		% end of while exist(filename) loop


fprintf ( '\nFile\n\t%s\nwill be read...\n\n', filename );
  
[ data, frequency, field_params, scope_params, time_params ] = read_fsc2_data ( filename );
  								% open the file and read the data
trigger_pos = time_params(2);	% get trigger_pos out of time_params

