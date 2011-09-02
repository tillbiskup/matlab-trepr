% THREEDREPRESENTATION Generate 3D representation of given 2D data
%
% Usage
%   threeDrepresentation(data,parameters);
%   figHandle = threeDrepresentation(data,parameters);
%
% data       - struct
%              data to plot
% parameters - struct
%              parameters controlling the type of 3D representation
%
% figHandle  - handle
%              Handle of the Matlab figure
%              0 if some problems occurred
%

% (c) 2011, Till Biskup
% 2011-09-02

function figHandle = threeDrepresentation(data,parameters)

try
    % Check for a minimum set of fields in parameters struct
    if ~isfield(parameters,'type') || isempty(parameters.type)
        figHandle = 0;
        return;
    end
    if ~isfield(data,'data') || isempty(data.data)
        figHandle = 0;
        return;
    end

    % Reduce data points if necessary
    if isfield(parameters,'size') && ~isempty(parameters.size)
        % If size is too small, return
        if (parameters.size.x < 10) || (parameters.size.y < 10)
            figHandle = 0;
            return;
        end
        % Handle offset
        if isfield(parameters,'offset') ...
                && isfield(parameters.offset,'type')
            switch parameters.offset.type
                case 'left'
                    % Handle situation that offset is too large
                    [dimx,dimy] = size(data.data);
                    if (parameters.offset.x > dimx-parameters.size.x)
                        parameters.offset.x = dimx-parameters.size.x;
                    end
                    if (parameters.offset.y > dimx-parameters.size.y)
                        parameters.offset.y = dimx-parameters.size.y;
                    end
                    [dimx,dimy] = size(data.data(...
                        1+parameters.offset.x:end,...
                        1+parameters.offset.y:end));
                    stepx = floor(dimx/parameters.size.x);
                    stepy = floor(dimy/parameters.size.y);
                    offsetx = parameters.offset.x;
                    offsety = parameters.offset.y;
                case 'right'
                    % Handle situation that offset is too large
                    [dimx,dimy] = size(data.data);
                    if (parameters.offset.x > dimx-parameters.size.x)
                        parameters.offset.x = dimx-parameters.size.x;
                    end
                    if (parameters.offset.y > dimx-parameters.size.y)
                        parameters.offset.y = dimx-parameters.size.y;
                    end
                    [dimx,dimy] = size(data.data(...
                        1:end-parameters.offset.x,...
                        1:end-parameters.offset.y));
                    stepx = floor(dimx/parameters.size.x);
                    stepy = floor(dimy/parameters.size.y);
                    offsetx = mod(dimx,parameters.size.x);
                    offsety = mod(dimy,parameters.size.y);
                otherwise
                    [dimx,dimy] = size(data.data);
                    stepx = floor(dimx/parameters.size.x);
                    stepy = floor(dimy/parameters.size.y);
                    offsetx = floor(mod(dimx,parameters.size.x)/2);
                    offsety = floor(mod(dimy,parameters.size.y)/2);
            end
        else
            offsetx = 1;
            offsety = 1;
        end
        x = data.axes.x.values(offsety+1:stepy:end);
        y = data.axes.y.values(offsetx+1:stepx:end);
        z = data.data(offsetx+1:stepx:end,offsety+1:stepy:end);
    else
        x = data.axes.x.values;
        y = data.axes.y.values;
        z = data.data;
    end
    
    % Set default parameters for display
    if isfield(parameters,'surface')
        if ~isfield(parameters.surface,'FaceAlpha')
            parameters.surface.FaceAlpha = 0.7;
        end
        if ~isfield(parameters.surface,'EdgeColor')
            parameters.surface.EdgeColor = [0.7 0.7 0.7];
        end
        if ~isfield(parameters.surface,'MeshStyle')
            switch parameters.type
                case 'surf'
                    parameters.surface.MeshStyle = 'row';
                case 'mesh'
                    parameters.surface.MeshStyle = 'both';
            end
        end
        if ~isfield(parameters.surface,'LineStyle')
            switch parameters.type
                case 'surf'
                    parameters.surface.LineStyle = '-';
                case 'trisurf'
                    parameters.surface.LineStyle = 'none';
            end
        end
    else
        parameters.surface.FaceAlpha = 0.7;
        parameters.surface.EdgeColor = [0.7 0.7 0.7];
        switch parameters.type
            case 'surf'
                parameters.surface.MeshStyle = 'row';
                parameters.surface.LineStyle = '-';
            case 'mesh'
                parameters.surface.MeshStyle = 'both';
            case 'trisurf'
                parameters.surface.LineStyle = 'none';
        end
    end
    
    % Open new figure window
    figHandle = figure();
    hAxes = newplot(figHandle);
    
    switch parameters.type
        case 'surf'
            hSurf = surf(hAxes,x,y,z);
            set(hSurf,'FaceAlpha',parameters.surface.FaceAlpha);
            set(hSurf,'EdgeColor',parameters.surface.EdgeColor);
            set(hSurf,'MeshStyle',parameters.surface.MeshStyle);
            set(hSurf,'LineStyle',parameters.surface.LineStyle);
        case 'mesh'
            hMesh = mesh(hAxes,x,y,z);
            set(hMesh,'MeshStyle',parameters.surface.MeshStyle);
        case 'trisurf'
            [xx,yy]=meshgrid(x,y);
            tri = delaunay(xx,yy);
            hSurf = trisurf(tri,xx,yy,z);
            set(hSurf,'FaceAlpha',parameters.surface.FaceAlpha);
            set(hSurf,'LineStyle',parameters.surface.LineStyle);
        case 'trimesh'
            [xx,yy]=meshgrid(x,y);
            tri = delaunay(xx,yy);
            hMesh = trimesh(tri,xx,yy,z);
        otherwise
            % That shall not happen
    end

    % Set viewport
    view(hAxes,[75 15]);
    
    % Set axes limits
    set(hAxes,'XLim',[x(1) x(end)]);
    set(hAxes,'YLim',[y(1) y(end)]);
    
    % Disable z axis
    set(hAxes,'ZTick',[]);
    
catch exception
    throw(exception);
end

end