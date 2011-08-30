% TREPRTOOLBOXREVISION Return trEPR toolbox revision number and date
%
% Usage
%   trEPRtoolboxRevision
%   [revision] = trEPRtoolboxRevision;
%   [revision,date] = trEPRtoolboxRevision;
%
% revision - string
%            version number of the trEPR toolbox
% date     - string
%            date of the trEPR toolbox
%

% (c) 2007-11, Till Biskup
% 2011-07-30

function [ varargout ] = trEPRtoolboxRevision

%	fprintf('\nFUNCTION CALL: $Id: trEPRtoolboxRevision.m 1307 2011-06-22 05:48:31Z till $\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPRtoolboxRevision" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 2 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPRtoolboxRevision" to get help.',nargout);

	end


	% ...and here the 'real' stuff goes in
	
	% This is the place to centrally manage the revision number and date.
	%
	% THIS VALUES SHOULD ONLY BE CHANGED BY THE OFFICIAL MAINTAINER OF THE TOOLBOX!
	%
	% If you have questions, call the trEPRinfo routine at the command prompt and
	% contact the maintainer via the email address given there.
	
	trEPRtoolboxRevisionNumber = '0.3.0beta';
	trEPRtoolboxRevisionDate = '2011-07-30';
	
	if (nargout == 1)
		% in case the function is called with one output parameter
	
		varargout{1} = trEPRtoolboxRevisionNumber;
		
	elseif (nargout == 2)
		% in case the function is called with two output parameters

		varargout{1} = trEPRtoolboxRevisionNumber;
		varargout{2} = trEPRtoolboxRevisionDate;
	
	else
		% in case the function is called without output parameters
	
		fprintf('%s %s\n',trEPRtoolboxRevisionNumber,trEPRtoolboxRevisionDate)
	
	end
