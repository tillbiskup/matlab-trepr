function status = fig2file(figHandle,fileName,fileType)

try
    switch fileType
        case 'fig'
            set(figHandle,'Visible','On');
            saveas(figHandle,fileName,'fig');
        case 'eps'
            print(figHandle,'-depsc',fileName);
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