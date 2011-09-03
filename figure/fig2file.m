% FIG2FILE Save Matlab figure window to file
%
% Usage
%   fig2file(figHandle,fileName,fileType);
%   status = fig2file(figHandle,fileName,fileType);
%
% figHandle - handle
%             Handle of the Matlab figure to be saved
% fileName  - string
%             Name of the file the figure should be saved to
%             Should at least be a filename with extension
% fileType  - string
%             currently one out of: fig|eps|pdf|png
%
% status    - string
%             Empty string if everything is fine
%             Otherwise it contains an error description
%

% (c) 2011, Till Biskup
% 2011-08-31

function status = fig2file(figHandle,fileName,fileType)

try
    switch fileType
        case 'fig'
            set(figHandle,'Visible','On');
            saveas(figHandle,fileName,'fig');
        case 'eps'
            print(figHandle,'-depsc2',fileName);
        case 'pdf'
            print(figHandle,'-dpdf',fileName);
        case 'png'
            saveas(figHandle,fileName,'png');
        otherwise
            % That shall never happen...
            status = sprintf('File type %s currently unsupported',fileType);
            return;
    end
    
    % Set status to empty string
    status = '';
catch exception
    throw(exception);
end

end