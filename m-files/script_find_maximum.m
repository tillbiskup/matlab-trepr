% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/28
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, frequency compensation
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...
%


% Plot B_0 spectrum and find signal maximum in t

figure;						% opens new graphic window

exit_find_max = 0;			% set while loop exit condition to default value;

t = trigger_pos;				% set time axis position to trigger position;

  
% set x vector for plotting

x = [ min([field_params(1) field_params(2)]) : field_params(3) : max([field_params(1) field_params(2)]) ];

x = x / 10;				% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT


while ( exit_find_max == 0 )

  spectrum = B0_spectrum ( offset_comp_data, 2, t );
  
  clf;
  hold on;
  
  graph_title = [ 'B_0 spectrum for evaluating the maximum signal amplitude depending on t with t=', num2str(t) ];

  title(graph_title);
  xlabel('B / mT');
  ylabel('I');

  plot(x,spectrum',x,zeros(1,length(x)))
  
  hold off;
  
  freq_comp_option = menu ( 'What would you want to do?', '< t (1 step)', 't (1 step) >', '< t (10 step)', 't (10 step) >', 'Exit');
  
  if ( freq_comp_option == 1)
  
    t = t - 1;
  
  elseif ( freq_comp_option == 2)
  
    t = t + 1;
  
  elseif ( freq_comp_option == 3)
  
    t = t - 10;
  
  elseif ( freq_comp_option == 4)
  
    t = t + 10;
  
  elseif ( freq_comp_option == 5)
  
    exit_find_max = 1;
    					% set exit condition for while loop true
  
  end
  
end;							% end of while loop
