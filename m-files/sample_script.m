% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/09/28
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2
%
%	This file is a sample main script that uses all the implemented functions
%	for data analysis of trEPR data recorded with the program fsc2.
%	Therefore it depends on these functions that reside in the m-files in the 
%	same directory as this script.
%
%	The file serves as an example for own scripts.



% First of all print some nice message

disp ( ' ' );
disp ( 'Sample script for testing the routines implemented' );
disp ( 'to analyse trEPR data recorded with the program fsc2.' );
disp ( ' ' );
disp ( 'Version:        $Revision$ from $Date$' );
disp ( 'Maintained by:  Till Biskup <till.biskup@physik.fu-berlin.de>' );
disp ( '	        http://www.physik.fu-berlin.de/~biskup/auswertung' );
disp ( ' ' );


% Next ask for a file name to read

filename = input ( 'Please enter a filename of a fsc2 data file: ', 's' );

if length( filename ) > 0			% If the user provided a filename

  fprintf ( '\nFile %s will be read...\n\n', filename );
  data = read_fsc2_data ( filename );
  								% try to open the file and read the data
  
else								% In case the user didn't provide a filename

  error ( 'You have not entered any file name!' );
								% just print a short message and exit
  
end

% Just for testing purposes a simple menu...

choice = menu ( '\n\nWhat do you want to do next?', 'Plot data (only GNU Octave)', 'Nothing' );

if choice == 1					% if the user chose the first possibility

	gsplot ( data' );			% make simple 3D plot of the raw data

else								% otherwise

	disp ('All done!');			% print nonsense message

end								% end if

% end of script