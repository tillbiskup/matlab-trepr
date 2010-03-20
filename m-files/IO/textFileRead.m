function text = textFileRead(filename)

    text = '';
    fid = fopen(filename);
    if fid < 0
        return
    end
    
    while 1
        tline = fgets(fid);
        if ~ischar(tline)
            break
        end
        text = sprintf('%s%s',text,tline);
    end
    fclose(fid);