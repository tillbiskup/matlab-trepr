% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/11/15
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, baseline compensation
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...

fprintf('\n---------------------------------------------------------------------------\n')
fprintf('\nGive user the possibility to manually compensate the baseline\n')

% Set the number of data points that are used from the start and the end of the spectrum
% to perform the fit

no_points = 20;

fprintf('\nThe first and the last %i data points of the B_0 spectrum together with\n one data point at the center of the spectrum - this one can be moved by the user - \nare taken to perform a quadratic fit.\n', no_points);

% Plot B_0 spectrum and fit baseline from the first and last 20 data points

grfhandle = figure;			% opens new graphic window
exit_baseline_comp = 0;		% set while loop exit condition to default value;


% set the correct values for the x axis (B_0 field) in mT
x = [ min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]) ];
x = x / 10;				% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT


% evaluate the spectrum at given time position "t"
spectrum = B0_spectrum ( drift_comp_data, 2, t );

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

  % settings for the plot window
  
  figure(grfhandle);
  						% set the current figure window to the window opened
  						% just before the while loop
  
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

  % set axis properties so that the axes will not be rescsaled
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

figure;					% open new graphics window

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

% end of script