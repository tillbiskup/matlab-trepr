% Copyright (C) 2008 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/gAxisPlot.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2008 Till Biskup
%	This file is free software
% CREATION DATE
%	2008/02/25
% VERSION
%	$Revision: 537 $
% MODIFICATION DATE
%	$Date: 2008-02-26 15:38:25 +0000 (Di, 26 Feb 2008) $
% KEYWORDS
%	g values, axis, plot
%
% SYNOPSIS
%	gAxisPlot
%
% DESCRIPTION
%	This function plots a g axis into the current MATLAB(R) figure.
%
% INPUT PARAMETERS
%	nu (FLOAT)
%		MW Frequency (in Hz)
%
%	B0 (VECTOR)
%		magnetic field (in mT)
%
%	params (STRUCT, OPTIONAL)
%		optional parameters
%
%		params.accuracy (FLOAT)
%			accuracy of the g values computed
%
%			For convenience you can give a value in exponential notation:
%
%				params.accuracy = 5e-3
%
%			A good value for a 100 G field range would be 1e-3.
%
%			The default value for the accuracy is 1e-3 if not set by
%			this optional parameter.
%
%		params.tickHeightFractionTotalHeight (FLOAT)
%			height of the tics in percent of the total height of the current
%			viewport in y direction
%
%			A typical value is 0.01 (meaning one percent of the y height).
%
%			The default value for the tick height is 0.01 if not set by
%			this optional parameter.
%
%		params.gEqualsTwoTickColor (STRING)
%			color of the tick for g = 2
%
%			May be one of the color names (short, long name) allowed in MATLAB(R):
%
%				y, yellow
%				m, magenta
%				c, cyan
%				r, red
%				g, green
%				b, blue
%				w,white
%				k,black
%
%			The default value for the color is 'green' if not set by
%			this optional parameter.
%
% OUTPUT PARAMETERS
%	ba (VECTOR)
%		vector containing the B0 values of the calculated g values
%		a tick is drawn for
%
%	ga (VECTOR)
%		vector containing the calculated g values 	a tick is drawn for
%
% EXAMPLE
%	
%
%
% SOURCE

function [ ba, ga ] = gAxisPlot ( nu, B0 )

	fprintf('\n%% FUNCTION CALL: $Id: gAxisPlot.m 537 2008-02-26 15:38:25Z till $\n%%\n');

	% check for the right number of input and output parameters

	if ( nargin < 2 ) || ( nargin > 3 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help gAxisPlot" to get help.',nargin);

	end

	if ( nargout ~= 2 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help gAxisPlot" to get help.',nargout);

	end


	% check for correct format of the input parameters


	% Uncomment the following lines if necessary

	if ( ~isnumeric(nu) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help gAxisPlot" to get help.','nu');

	end

	if ( ~isnumeric(B0) || isscalar(B0) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help gAxisPlot" to get help.','B0');

	end
	
	% PARAMETERS (OPTIONAL)
	
	if nargin > 2
	
		params = varargin{1};
	
		if ~isstruct(params)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help axisLabels" to get help.','params');
				% get error if function is called with the wrong format of the
				% input parameter 'params'
	
		end

		if ( isfield(params,'accuracy') && ( ~isnumeric(params.accuracy) || ~isscalar(params.accuracy) ))
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help axisLabels" to get help.','params.accuracy');

		end

		if ( isfield(params,'tickHeightFractionTotalHeight') && ( ~isnumeric(params.tickHeightFractionTotalHeight) || ~isscalar(params.tickHeightFractionTotalHeight) ))
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help axisLabels" to get help.','params.tickHeightFractionTotalHeight');

		end

		if ( isfield(params,'gEqualsTwoTickColor') && ( ~isstr(params.gEqualsTwoTickColor) ))
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help axisLabels" to get help.','params.gEqualsTwoTickColor');

		end

%		if ( isfield(params,'###') && ~isstr(params.###) )
%	
%			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help axisLabels" to get help.','params.###');
%
%		end
	
	end


	% check for the availability of the routines we depend on

	% Uncomment the following lines if necessary

%	if ( exist('trEPR_read_fsc2_file.m') ~= 2 )
%		error('\n\tThe function %s this function critically depends on is not available.\n','trEPR_read_fsc2_file');
%	end
	
	% ...and here the 'real' stuff goes in

	% set constants
	hPlanck = 6.626068e-34;
	bohrMagneton = 9.27400949e-24;

	% set some variables
	
	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'tickHeightFractionTotalHeight') ) )
	
		tickHeightFractionTotalHeight = params.tickHeightFractionTotalHeight;

	else
	
		tickHeightFractionTotalHeight = 0.01;

	end
	
	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'accuracy') ) )
	
		accuracy = params.accuracy;

	else
	
		accuracy = 1e-3;

	end
	
	if ( ( ismember({'params'},who) ~= 0 ) && ( isfield(params,'gEqualsTwoTickColor') ) )
	
		gEqualsTwoTickColor = params.gEqualsTwoTickColor;

	else
	
		gEqualsTwoTickColor = 'green';

	end
	
	% calculate g values for each point of the field axis

	gvalues = gValue(B0, nu);

	% calculate min and max g value according to the accuracy set

	gmin = floor(max(gvalues*(1/accuracy)))/(1/accuracy);
	gmax = ceil(min(gvalues*(1/accuracy)))/(1/accuracy);

	% set spacing between g values of the axis for linspace parameter

	spacing = ((gmin-gmax)/(accuracy))+1;

	% convert spacing to integer value (otherwise linspace runs in trouble)

	spacing = int8(spacing);

	points = linspace(gmax,gmin,spacing);

	% calculate min and max B0 values for corresponding g values

	bmin = bValue(gmin, nu);
	bmax = bValue(gmax, nu);

	% create B0 column of the [ B0 g ] vector for producing the tics

	bpoints = bValue(points,nu);
	
	% get XLim and YLim values
	xlimits = get(gca,'XLim');
	ylimits = get(gca,'YLim');

	ticksLowerEnd = ylimits(1) + ((ylimits(2)-ylimits(1))*tickHeightFractionTotalHeight)*3;
	ticksUpperEnd = ylimits(1) + ((ylimits(2)-ylimits(1))*tickHeightFractionTotalHeight)*4;

	ticks = ones(spacing,2);

	ticks(:,1) = (ticksLowerEnd);
	ticks(:,2) = (ticksUpperEnd);

	tickpos = [ bpoints ; bpoints ];

	% start plotting of the ticks

	hold on;

	plot(tickpos,ticks','black');

	plot([ min(B0) max(B0) ],[ ticksUpperEnd ticksUpperEnd ],'black');
	plot([ bValue(2,nu) bValue(2,nu) ],[ ticksLowerEnd ticksUpperEnd ],gEqualsTwoTickColor);

	hold off;

	% reset ylimits to the original values

	ylim ( [ ylimits(1) ylimits(2) ] );

	% set return values

	ba = bpoints;
	ga = gValue(bpoints, nu);
	
	% prepare vector for printing
	
	B0g = flipud([ba;ga]');
	
	% print B0 and corresponding g values
	
	fprintf('%%   mT        g\n%% ---------------\n');
	
	for i=1:length(B0g(:,1))
		% length(B0g(:,1)) returns one in case of only one row while
		% length(B0g) would return the number of cols in such a case
	
		fprintf('%% %6.2f   %6.4f\n',B0g(i,1)*1000,B0g(i,2));
	
	end

end % end of main function


function bField = bValue ( g, nu )

	% hPlanck * nu = g * bohrMagneton * B_0
	% B_0 = ( hPlanck * nu ) / ( g * bohrMagneton )

    % set constants
    hPlanck = 6.626068e-34;
    bohrMagneton = 9.27400949e-24;

    bField = ( hPlanck * nu ) ./ ( g .* bohrMagneton );
    
end


function g = gValue ( B0, nu )

	% hPlanck * nu = g * bohrMagneton * B_0
	% g = ( hPlanck * nu ) / ( bohrMagneton * B_0 )

    % set constants
    hPlanck = 6.626068e-34;
    bohrMagneton = 9.27400949e-24;

    g = ( hPlanck * nu ) ./ ( bohrMagneton .* B0 );
    
end

%******
