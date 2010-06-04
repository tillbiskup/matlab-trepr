% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/save_figure.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/05/24
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(TM), figure, save, MATLAB(TM) figure format, EPS
%
% SYNOPSIS
%	save_figure
%
% DESCRIPTION
%	This small routine is intended to save the current figure window
%	to an EPS as well as to a MATLAB(TM) fig file.
%
%	Therefore the user will be asked interactively for a file basename.
%	In case this filename still exists the user has the choice between
%	overwriting and choosing another filename.
%
%	If we're running with MATLAB(TM) this program can get out whether
%	there is currently any open figure window or not. In the latter case
%	it will print out an error message and abort.
%
%	If we're running with a different platform than MATLAB(TM), e.g.
%	GNU Octave, this will alter a little bit the behaviour: There is no
%	check whether there are any open figure windows at the time of the call
%	of this function and the figure is saved only as an EPS file.
%
% INPUT PARAMETERS
%	filename (STRING, OPTIONAL)
%		string containing the file BASENAME that is used to save the files to
%
%		IMPORTANT: You may only typein the file BASENAME because the figure is
%		saved in different formats with different file extensions that are
%		automatically added to the file basename given here.
%
%		NOTE: If no filename is given as input parameter, the user will be asked
%		therefore interactively.
%
%		NOTE: If only one additional parameter is provided with the function call
%		and this parameter is of the type "struct", it will be used as parameter
%		"params" (see below).
%
%	params (STRUCT, OPTIONAL)
%		structure containing optional additional parameters
%
%		params.outputFormat (STRING)
%			string defining the file format the figure will be saved to
%
%			This is a convenient way to set the output format for different
%			situations without having to think of how each parameter has to be
%			set. 'outputFormat' can get one of the following values:
%
%			LaTeXhalfWidth
%			PDF file with the size 4x3 inches for use with pdfLaTeX and with two
%			figures side by side.
%
%			LaTeXhalfWidthSmallHeight
%			PDF file with the size 4x2.5 inches for use with pdfLaTeX and with two
%			figures side by side and four figures stacked vertically.
%
%			LaTeXfullWidth
%			PDF file with the size 8x6 inches for use with pdfLaTeX and with one
%			figure covering the whole width of the page.
%
%			LaTeXfullWidthSmallHeight
%			PDF file with the size 6.25x2.8 inches for use with pdfLaTeX and with one
%			figure covering the whole width of the page, but with reduced height.
%
%			LaTeXfullPage
%			PDF file with the size 7x9 inches for use with pdfLaTeX and with one
%			figure that fills a complete DIN A4 page.
%
%           LaTeXbeamerSlide
%           PDF file with the size 8.5x5 inches for use with pdfLaTeX and with one
%           figure that fills a complete slide in the beamer class. To further
%           process, load it with GIMP, render with 300 dpi, rescale by 50 percent
%           and save as indexed png file (16-64 colours, usually)
%
%			NOTE: If this parameter is not set, fig and eps files with default
%			geometry will be used to save the figure to. This corresponds to the
%			prior behaviour of this function and is done this way due to
%			compatibility reasons.
%
%		params.PaperUnits
%
%
%		params.PaperWidth
%
%
%		params.PaperHeight
%
%
%		params.PaperPosition
%
%
%		params.PaperPositionMode
%
%
%		params.PrinterDriver
%
%
%		NOTE: If only one additional parameter is provided with the function call
%		and this parameter is of the type "string", it will be used as parameter
%		"filename" (see above).
%
% OUTPUT PARAMETERS
%	currently there are no output parameters
%
% DEPENDS ON
%	The routine depends on several other routines from the trEPR toolbox:
%	* discriminate_matlab_octave.m
%
% EXAMPLE
%	For full interactive use just typein
%
%		save_figure
%
%	For noninteractive use you may typein
%
%		save_figure ( '<file basename>' );
%
% SOURCE

function save_figure ( varargin )

	fprintf('%% FUNCTION CALL: $Id$\n');

	% check for the right number of input and output parameters

	if ( nargin > 3 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help save_figure" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help save_figure" to get help.',nargout);

	end

	if ( nargin == 1 )

		if ( (nargin == 1) && isstr(varargin{1}) )

			filename = varargin{1};
			
			if length(filename) == 0

				error('\n\tThe function is called with an empty string as the filename.\n\tPlease use "help save_figure" to get help.','filename');
					% get error if function is called with an empty 'filename'

			end
			
		elseif ( (nargin == 1) && isstruct(varargin{1}) )
		
			params = varargin{1};
			
		else
		
			error('\n\tThe function is called with the wrong format for %s input argument.\n\tPlease use "help save_figure" to get help.','only one');
				% get error if function is called with the wrong format of the
				% input argument

		end
	
	elseif ( nargin == 2 )
	
		filename = varargin{1};
		params = varargin{2};

		% check for correct format of the input parameters
	
		% FILENAME
	
		if ~isstr(filename)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help save_figure" to get help.','filename');
				% get error if function is called with the wrong format of the
				% input parameter 'filename'
	
		elseif length(filename) == 0

			error('\n\tThe function is called with an empty string as the filename %s.\n\tPlease use "help save_figure" to get help.','filename');
				% get error if function is called with an empty 'filename'

		end
		
		% PARAMS

		if ~isstruct(params)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help save_figure" to get help.','params');
				% get error if function is called with the wrong format of the
				% input parameter 'params'
	
		end

		if ( isfield(params,'outputFormat') && ~isstr(params.outputFormat) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help save_figure" to get help.','params.outputFormat');

		end

	elseif ( nargin == 3 )
	
		filename = varargin{1};
		params = varargin{2};
        figureHandle = varargin{3};

		% check for correct format of the input parameters
	
		% FILENAME
	
		if ~isstr(filename)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help save_figure" to get help.','filename');
				% get error if function is called with the wrong format of the
				% input parameter 'filename'
	
		elseif length(filename) == 0

			error('\n\tThe function is called with an empty string as the filename %s.\n\tPlease use "help save_figure" to get help.','filename');
				% get error if function is called with an empty 'filename'

		end
		
		% PARAMS

		if ~isstruct(params)
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help save_figure" to get help.','params');
				% get error if function is called with the wrong format of the
				% input parameter 'params'
	
		end

		if ( isfield(params,'outputFormat') && ~isstr(params.outputFormat) )
	
			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help save_figure" to get help.','params.outputFormat');

		end

	end 


	% check for the availability of the routines we depend on
	
	% Find out whether we are called by MATLAB(TM) or GNU Octave

	if ( exist('discriminate_matlab_octave') == 2 )
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
    
    % Check for figureHandle
    
    if ~exist('figureHandle','var')
        figureHandle = gcf;
    end
	
	% Find out whether a figure window is open
	% and abort further operation in case no figure window is open
	
	if program == 'Matlab'	% if we're called by GNU Octave (as determined above)

		if ( length ( get(0,'CurrentFigure') ) == 0 )
		
			error('\n\tThere seems to be no open figure window in the moment.\n\tABORTING...\n',program);
		
		end

	else					% otherwise we assume that we're called by MATLAB(R)

		fprintf('\nWARNING: We''re currently running under %s.\nThat means that we cannot get out whether there are currently\nsome open figure windows...\nIf not you''re fully responsible for any strange behaviour...',program);

	end					% end of "if program" clause
	

	% In case no file basename is provided as input parameter
	% ask user for a file basename to save the figure to.

	if ( ismember({'filename'},who) == 0 ) 
	
		proceed = 0;
			% set variable for while condition to default value
	
		while (proceed == 0)
			% while proceed is set to zero
	
			filename = input ( 'Please enter a file BASEname (without extension) for the figure to save to:\n	 ', 's' );
				% prompt the user for a filename for the figure file

			if length( filename ) > 0	
				% If the user provided a filename

				existing_fig_file = sprintf('%s.fig',filename);
				existing_eps_file = sprintf('%s.eps',filename);
							
				if ( exist( existing_fig_file ) || exist( existing_eps_file ) )
					% if the file still exists
	
					answer = menu('The provided file exists and will be overwritten. Do You really want to proceed?','Yes','No');
		 				% ask the user what to do now
		
					if answer == 1
						% if user chose to proceed anyway
		
						delete ( existing_fig_file );
						delete ( existing_eps_file );
					
						proceed = 1;		% set condition for while loop so that the while loop will not
										% passed through once again
		
					else	
						% in the other case
		
						proceed = 0;
							% go through the while loop once again

					end
						% end if answer
	
				else	
					% if the file doesn't exist yet
		
					proceed = 1;
						% set condition for while loop so that the while loop will not
						% passed through once again
	
				end
					% end if exists
	
			else	
				% In case the user didn't provide a filename
								
				proceed = 0;
	
			end
				% end of if length(filename) condition
		
		end
			% end while loop
								
	end
		% end if ismember condition

	if ( ismember({'params'},who) == 0 ) 

		% save figure as fig and EPS file

		fig_filename = sprintf ('%s.fig',filename);
		eps_filename = sprintf ('%s.eps',filename);

		% save figure as MATLAB(TM) fig file
	
		% NOTE: This will lead to problems when called with another program than MATLAB(TM).

		if program == 'Matlab'	% if we're called by GNU Octave (as determined above)

			saveas ( figureHandle, fig_filename )

		else					% otherwise we assume that we're called by MATLAB(R)

			fprintf('\n%% WARNING: You tried to save the file to a MATLAB(TM) fig file.\n\tThis will work only with MATLAB(TM), but you''re using %s...\n',program);

		end					% end of "if program" clause
	

		% save figure as EPS file

		if program == 'Octave'	% if we're called by GNU Octave (as determined above)

			print ( eps_filename, '-depsc2' );

		else					% otherwise we assume that we're called by MATLAB(R)

			printFigureHandle = sprintf('-f%i',figureHandle);
            print ( printFigureHandle , '-depsc2' , eps_filename );

		end					% end of "if program" clause
	
	elseif( isfield(params,'outputFormat') )
	
	  if ( strcmp(params.outputFormat,'LaTeXhalfWidth') )

		% save figure as PDF file

		pdf_filename = sprintf ('%s.pdf',filename);

		if program == 'Octave'	% if we're called by GNU Octave (as determined above)

%			print ( eps_filename, '-depsc2' );

		else					% otherwise we assume that we're called by MATLAB(R)

			% get original values that will be changed (to reset them at the end)
			OldPaperUnits = get(figureHandle,'PaperUnits');
			OldPaperSize = get(figureHandle,'PaperSize');
			OldPaperPosition = get(figureHandle,'PaperPosition');
			OldPaperPositionMode = get(figureHandle,'PaperPositionMode');

			set(figureHandle,'PaperUnits','inches');
			PaperWidth = 4;
			PaperHeight = 3;
			set(figureHandle,'PaperSize',[PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPosition',[0.1,0.1,PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPositionMode','manual');
		
			printFigureHandle = sprintf('-f%i',figureHandle);
            print ( printFigureHandle ,'-dpdf' , pdf_filename );

			% set changed values back to original values
			set(figureHandle,'PaperUnits',OldPaperUnits);
			set(figureHandle,'PaperSize',OldPaperSize);
			set(figureHandle,'PaperPosition',OldPaperPosition);
			set(figureHandle,'PaperPositionMode',OldPaperPositionMode);

		end					% end of "if program" clause
		
	  elseif ( strcmp(params.outputFormat,'LaTeXhalfWidthSmallHeight') )

		% save figure as PDF file

		pdf_filename = sprintf ('%s.pdf',filename);

		if program == 'Octave'	% if we're called by GNU Octave (as determined above)

%			print ( eps_filename, '-depsc2' );

		else					% otherwise we assume that we're called by MATLAB(R)

			% get original values that will be changed (to reset them at the end)
			OldPaperUnits = get(figureHandle,'PaperUnits');
			OldPaperSize = get(figureHandle,'PaperSize');
			OldPaperPosition = get(figureHandle,'PaperPosition');
			OldPaperPositionMode = get(figureHandle,'PaperPositionMode');

			set(figureHandle,'PaperUnits','inches');
			PaperWidth = 4;
			PaperHeight = 2.5;
			set(figureHandle,'PaperSize',[PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPosition',[0.1,0.1,PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPositionMode','manual');
		
			printFigureHandle = sprintf('-f%i',figureHandle);
            print ( printFigureHandle ,'-dpdf' , pdf_filename );

			% set changed values back to original values
			set(figureHandle,'PaperUnits',OldPaperUnits);
			set(figureHandle,'PaperSize',OldPaperSize);
			set(figureHandle,'PaperPosition',OldPaperPosition);
			set(figureHandle,'PaperPositionMode',OldPaperPositionMode);

		end					% end of "if program" clause
	
	  elseif ( strcmp(params.outputFormat,'LaTeXfullWidth') )

		% save figure as PDF file

		pdf_filename = sprintf ('%s.pdf',filename);

		if program == 'Octave'	% if we're called by GNU Octave (as determined above)

%			print ( eps_filename, '-depsc2' );

		else					% otherwise we assume that we're called by MATLAB(R)

			% get original values that will be changed (to reset them at the end)
			OldPaperUnits = get(figureHandle,'PaperUnits');
			OldPaperSize = get(figureHandle,'PaperSize');
			OldPaperPosition = get(figureHandle,'PaperPosition');
			OldPaperPositionMode = get(figureHandle,'PaperPositionMode');

			set(figureHandle,'PaperUnits','inches');
			PaperWidth = 8;
			PaperHeight = 6;
			set(figureHandle,'PaperSize',[PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPosition',[0.05,0.05,PaperWidth-0.05, PaperHeight-0.05]);
			set(figureHandle,'PaperPositionMode','manual');
            
			printFigureHandle = sprintf('-f%i',figureHandle);
            print ( printFigureHandle ,'-dpdf' , pdf_filename );

			% set changed values back to original values
			set(figureHandle,'PaperUnits',OldPaperUnits);
			set(figureHandle,'PaperSize',OldPaperSize);
			set(figureHandle,'PaperPosition',OldPaperPosition);
			set(figureHandle,'PaperPositionMode',OldPaperPositionMode);

		end					% end of "if program" clause
	
	  elseif ( strcmp(params.outputFormat,'LaTeXfullWidthSmallHeight') )

		% save figure as PDF file

		pdf_filename = sprintf ('%s.pdf',filename);

		if program == 'Octave'	% if we're called by GNU Octave (as determined above)

%			print ( eps_filename, '-depsc2' );

		else					% otherwise we assume that we're called by MATLAB(R)

			% get original values that will be changed (to reset them at the end)
			OldPaperUnits = get(figureHandle,'PaperUnits');
			OldPaperSize = get(figureHandle,'PaperSize');
			OldPaperPosition = get(figureHandle,'PaperPosition');
			OldPaperPositionMode = get(figureHandle,'PaperPositionMode');

			set(figureHandle,'PaperUnits','inches');
			PaperWidth = 6.25;
			PaperHeight = 2.8;
			set(figureHandle,'PaperSize',[PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPosition',[0,0.05,PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPositionMode','manual');
		
			printFigureHandle = sprintf('-f%i',figureHandle);
            print ( printFigureHandle ,'-dpdf' , pdf_filename );

			% set changed values back to original values
			set(figureHandle,'PaperUnits',OldPaperUnits);
			set(figureHandle,'PaperSize',OldPaperSize);
			set(figureHandle,'PaperPosition',OldPaperPosition);
			set(figureHandle,'PaperPositionMode',OldPaperPositionMode);

		end					% end of "if program" clause
    
      elseif ( strcmp(params.outputFormat,'LaTeXbeamerSlide') )

        % save figure as PDF file

        pdf_filename = sprintf ('%s.pdf',filename);

        if program == 'Octave'  % if we're called by GNU Octave (as determined above)

%           print ( eps_filename, '-depsc2' );

        else                    % otherwise we assume that we're called by MATLAB(R)

            % get original values that will be changed (to reset them at the end)
            OldPaperUnits = get(figureHandle,'PaperUnits');
            OldPaperSize = get(figureHandle,'PaperSize');
            OldPaperPosition = get(figureHandle,'PaperPosition');
            OldPaperPositionMode = get(figureHandle,'PaperPositionMode');

            set(figureHandle,'PaperUnits','inches');
            PaperWidth = 8.5;
            PaperHeight = 5;
            set(figureHandle,'PaperSize',[PaperWidth, PaperHeight]);
            set(figureHandle,'PaperPosition',[-0.4,0.05,PaperWidth+0.7, PaperHeight-0.05]);
            set(figureHandle,'PaperPositionMode','manual');
        
            printFigureHandle = sprintf('-f%i',figureHandle);
            print ( printFigureHandle ,'-dpdf' , pdf_filename );

            % set changed values back to original values
            set(figureHandle,'PaperUnits',OldPaperUnits);
            set(figureHandle,'PaperSize',OldPaperSize);
            set(figureHandle,'PaperPosition',OldPaperPosition);
            set(figureHandle,'PaperPositionMode',OldPaperPositionMode);

        end                 % end of "if program" clause
		
	  elseif ( strcmp(params.outputFormat,'LaTeXfullPage') )

		% save figure as PDF file

		pdf_filename = sprintf ('%s.pdf',filename);

		if program == 'Octave'	% if we're called by GNU Octave (as determined above)

%			print ( eps_filename, '-depsc2' );

		else					% otherwise we assume that we're called by MATLAB(R)

			% get original values that will be changed (to reset them at the end)
			OldPaperUnits = get(figureHandle,'PaperUnits');
			OldPaperSize = get(figureHandle,'PaperSize');
			OldPaperPosition = get(figureHandle,'PaperPosition');
			OldPaperPositionMode = get(figureHandle,'PaperPositionMode');

			set(figureHandle,'PaperUnits','inches');
			PaperWidth = 8;
			PaperHeight = 11;
			set(figureHandle,'PaperSize',[PaperWidth, PaperHeight]);
			set(figureHandle,'PaperPosition',[-0.5,-0.5,1.1*PaperWidth, 1.1*PaperHeight]);
			set(figureHandle,'PaperPositionMode','manual');
		
			printFigureHandle = sprintf('-f%i',figureHandle);
            print ( printFigureHandle ,'-dpdf' , pdf_filename );

			% set changed values back to original values
			set(figureHandle,'PaperUnits',OldPaperUnits);
			set(figureHandle,'PaperSize',OldPaperSize);
			set(figureHandle,'PaperPosition',OldPaperPosition);
			set(figureHandle,'PaperPositionMode',OldPaperPositionMode);

		end					% end of "if program" clause
		
	  end
		
	else
	
		if ( isfield(params,'PaperWidth') )
		
			PaperWidth = params.PaperWidth;
			
		else
		
			set(figureHandle,'PaperUnits','inches');
			PaperWidth = 8.5;
		
		end
	
		if ( isfield(params,'PaperHeight') )
		
			PaperHeight = params.PaperHeight;
			
		else
		
			set(figureHandle,'PaperUnits','inches');
			PaperHeight = 11;
		
		end
	
		if ( isfield(params,'PaperUnits') )
		
			PaperUnits = params.PaperUnits;
			set(figureHandle,'PaperUnits',PaperUnits);
			
		else
		
			set(figureHandle,'PaperUnits','inches');
		
		end
	
		if ( isfield(params,'PrinterDriver') )
		
			if ( strcmpi(params.PrinterDriver,'pdf') )
			
				PrinterDriver = '-dpdf'
				print_filename = sprintf ('%s.pdf',filename);
				
			elseif ( strcmpi(params.PrinterDriver,'ps') )
			
				PrinterDriver = '-depsc2'
				print_filename = sprintf ('%s.eps',filename);
				
			end 
			
		end
		
		% get original values that will be changed (to reset them at the end)
		OldPaperUnits = get(figureHandle,'PaperUnits');
		OldPaperSize = get(figureHandle,'PaperSize');
		OldPaperPosition = get(figureHandle,'PaperPosition');
		OldPaperPositionMode = get(figureHandle,'PaperPositionMode');

		%set(figureHandle,'PaperUnits','inches');
		%PaperWidth = 8;
		%PaperHeight = 11;
		
		set(figureHandle,'PaperSize',[PaperWidth, PaperHeight]);
		set(figureHandle,'PaperPosition',[0,0,PaperWidth, PaperHeight]);
		set(figureHandle,'PaperPositionMode','manual');
		
        printFigureHandle = sprintf('-f%i',figureHandle);
        
		print ( printFigureHandle, PrinterDriver , print_filename );

		% set changed values back to original values
		set(figureHandle,'PaperUnits',OldPaperUnits);
		set(figureHandle,'PaperSize',OldPaperSize);
		set(figureHandle,'PaperPosition',OldPaperPosition);
		set(figureHandle,'PaperPositionMode',OldPaperPositionMode);
		
	
	end

%******
