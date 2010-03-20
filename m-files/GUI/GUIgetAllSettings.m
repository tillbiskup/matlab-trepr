function GUIgetAllSettings(hObject)
% hObject    handle to the graphics object

    handles = guidata(hObject);
    fields = fieldnames(handles);
    for k=1:length(fields)
        fprintf('\n[%s]\n',char(fields(k)));
        get(getfield(handles,char(fields(k))))
    end
  
end