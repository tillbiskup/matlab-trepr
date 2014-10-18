function axesResize
% AXESRESIZE Handle resizing of main axis and display of projection and
% residuals axes.
%
% Usage
%   axesResize

% Copyright (c) 2014, Till Biskup
% 2014-10-18

% Get appdata and handles from main figure
ad = getappdata(trEPRguiGetWindowHandle);
gh = ad.UsedByGUIData_m;

% TODO: Need to handle this differently!
mainAxisPosition = [70 95 500 500];

if strcmpi(ad.control.axis.displayType,'2d plot')
    set(gh.residualsAxis,'Visible','off');
    if ad.control.axis.projectionAxes.enable
        set(gh.mainAxis,'Position',[...
            mainAxisPosition(1) + ad.control.axis.projectionAxes.vertical.height ...
            mainAxisPosition(2) + ad.control.axis.projectionAxes.horizontal.height ...
            mainAxisPosition(3) - ad.control.axis.projectionAxes.vertical.height ...
            mainAxisPosition(4) - ad.control.axis.projectionAxes.horizontal.height]);
        set(gh.horizontalAxis,'Position',[...
            mainAxisPosition(1) + ad.control.axis.projectionAxes.vertical.height ...
            mainAxisPosition(2) ...
            mainAxisPosition(3) - ad.control.axis.projectionAxes.vertical.height ...
            ad.control.axis.projectionAxes.horizontal.height]);
        set(gh.verticalAxis,'Position',[...
            mainAxisPosition(1) ...
            mainAxisPosition(2) + ad.control.axis.projectionAxes.horizontal.height ...
            ad.control.axis.projectionAxes.vertical.height ...
            mainAxisPosition(4) - ad.control.axis.projectionAxes.horizontal.height]);
    else
        set(gh.mainAxis,'Position',mainAxisPosition);
        set(gh.horizontalAxis,'Visible','off');
        set(gh.verticalAxis,'Visible','off');
        set(gh.mainAxis,'XTickLabelMode','auto');
    end
    return;
end

if strfind(ad.control.axis.displayType,'1D')
    cla(gh.horizontalAxis,'reset');
    cla(gh.verticalAxis,'reset');
    set(gh.horizontalAxis,'Visible','off');
    set(gh.verticalAxis,'Visible','off');
    if ad.control.axis.residualsAxes.enable
        set(gh.mainAxis,'Position',[...
            mainAxisPosition(1) ...
            mainAxisPosition(2)+ad.control.axis.residualsAxes.gap+...
            ad.control.axis.residualsAxes.height ...
            mainAxisPosition(3) ...
            mainAxisPosition(4)-ad.control.axis.residualsAxes.gap-...
            ad.control.axis.residualsAxes.height]);
        set(gh.residualsAxis,'Position',[...
            mainAxisPosition(1:3) ad.control.axis.residualsAxes.height]);
        set(gh.residualsAxis,'Visible','on');
    else
        set(gh.mainAxis,'Position',mainAxisPosition);
        set(gh.residualsAxis,'Visible','off');
        set(gh.mainAxis,'XTickLabelMode','auto');
    end
    return;
end

end