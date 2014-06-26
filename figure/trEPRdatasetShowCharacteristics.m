function trEPRdatasetShowCharacteristics(varargin)
% TREPRDATASETSHOWCHARACTERISTICS Display characteristic slices (SOI),
% distances (DOI), and points (POI) for given dataset.
%
% Usage:
%   trEPRdatasetShowCharacteristics(dataset)
%   trEPRdatasetShowCharacteristics(axisHandle,dataset)
%
%   dataset    - struct
%                Dataset to show characteristic slices, distances, points
%                for.
%
%   axisHandle - handle (OPTIONAL)
%                Handle of axis to plot into

% (c) 2014, Till Biskup
% 2014-06-26

% Manual check for input arguments, as first argument is optional
if nargin < 1
    help trEPRdatasetShowCharacteristics;
    return;
end

% Check first argument for being axis handle
if ishghandle(varargin{1}) && strcmpi(get(varargin{1},'Type'),'axes')
    axisHandle = varargin{1};
    varargin(1) = [];
end

% Get dataset
if isstruct(varargin{1}) && isfield(varargin{1},'characteristics')
    dataset = varargin{1};
else
    warning('trEPRdatasetShowCharacteristics:DatasetProblems',...
        'Problem with dataset...');
    return;
end

% If there is no axisHandle, make 2D plot
if ~exist('axisHandle','var')
    figureHandle = figure();
    imagesc(dataset.axes.x.values,dataset.axes.y.values,dataset.data);
    axisHandle = findobj(allchild(figureHandle),'Type','axes');
    set(axisHandle,'YDir','normal');
    xlabel(axisHandle,sprintf('{\\it %s} / %s',...
        dataset.axes.x.measure,dataset.axes.x.unit));
    ylabel(axisHandle,sprintf('{\\it %s} / %s',...
        dataset.axes.y.measure,dataset.axes.y.unit));
end

% Get x and y limits of axis
xlim = get(axisHandle,'XLim');
ylim = get(axisHandle,'YLim');

% Display SOIs
if ~isempty(dataset.characteristics.soi(1).coordinates)
    hold on;
    for idx = 1:length(dataset.characteristics.soi)
        switch dataset.characteristics.soi(idx).direction
            case 'x'
                xcoord = xlim;
                ycoord = dataset.axes.y.values(...
                    dataset.characteristics.soi(idx).coordinates);
                ycoord = repmat(ycoord,1,2);
            case 'y'
                xcoord = dataset.axes.x.values(...
                    dataset.characteristics.soi(idx).coordinates);
                xcoord = repmat(xcoord,1,2);
                ycoord = ylim;
        end
        plot(axisHandle,xcoord,ycoord,'k-');
    end
    hold off;
end

end
