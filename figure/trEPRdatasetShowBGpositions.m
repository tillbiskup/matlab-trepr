function trEPRdatasetShowBGpositions(varargin)
% TREPRDATASETSHOWBGPOSITIONS Display positions where background traces
% have been recorded that got automatically subtracted inside the transient
% recorder during measurement (only for those types of recordings where
% this has been done, as, e.g., the Freiburg setup).
%
% Usage:
%   trEPRdatasetShowBGpositions(dataset)
%   trEPRdatasetShowBGpositions(axisHandle,dataset)
%
%   dataset    - struct
%                Dataset to show characteristic slices, distances, points
%                for.
%
%   axisHandle - handle (OPTIONAL)
%                Handle of axis to plot into

% Copyright (c) 2014, Till Biskup
% 2014-07-18

% Manual check for input arguments, as first argument is optional
if nargin < 1
    help trEPRdatasetShowBGpositions;
    return;
end

% Check first argument for being axis handle
if ishghandle(varargin{1}) && strcmpi(get(varargin{1},'Type'),'axes')
    axisHandle = varargin{1};
    varargin(1) = [];
end

% Get dataset
if isstruct(varargin{1}) && isfield(varargin{1},'parameters') ...
        && isfield(varargin{1}.parameters,'background')
    dataset = varargin{1};
else
    warning('trEPRdatasetShowBGpositions:DatasetProblems',...
        'Problem with dataset...');
    return;
end

if nargin > 1
    % Parse input arguments using the inputParser functionality
    p = inputParser;   % Create an instance of the inputParser class.
    p.FunctionName = mfilename; % Function name included in error messages
    p.KeepUnmatched = true; % Enable errors on unmatched arguments
    p.StructExpand = true; % Enable passing arguments in a structure
    p.addParamValue('DisplayType','2D',@(x)ischar(x));
    p.addParamValue('Shift',0,@(x)isscalar(x));
    p.parse(varargin{2:end});
end

BGpositions = getBGpositions(dataset,p.Results.Shift);

if isempty(BGpositions)
    return;
end

% If there is no axisHandle, make plot
if ~exist('axisHandle','var')
    figureHandle = figure();
    switch p.Results.DisplayType
        case '2D'
            imagesc(dataset.axes.x.values,dataset.axes.y.values,dataset.data);
            axisHandle = findobj(allchild(figureHandle),'Type','axes');
            set(axisHandle,'YDir','normal');
            xlabel(axisHandle,sprintf('{\\it %s} / %s',...
                dataset.axes.x.measure,dataset.axes.x.unit));
            ylabel(axisHandle,sprintf('{\\it %s} / %s',...
                dataset.axes.y.measure,dataset.axes.y.unit));
        case '1D'
            if min(size(dataset.data)) > 1
                % Get time position of maximum
                [~,timePos] = max(max(dataset.data));
                plot(dataset.axes.y.values,...
                    dataset.data(:,timePos));
            else
                plot(dataset.axes.x.values,dataset.axes.y.values,...
                    dataset.data);
            end
            axisHandle = findobj(allchild(figureHandle),'Type','axes');
            xlabel(axisHandle,sprintf('{\\it %s} / %s',...
                dataset.axes.y.measure,dataset.axes.y.unit));
        otherwise
            return;
    end
end

% Get x and y limits of axis
xlim = get(axisHandle,'XLim');
ylim = get(axisHandle,'YLim');

% Check for field units
if ~strcmpi(dataset.parameters.field.start.unit,dataset.axes.y.unit)
    if strcmpi(dataset.parameters.field.start.unit,'mT') && ...
            strcmpi(dataset.axes.y.unit,'G')
        BGpositions = BGpositions * 10;
    end
end

% Display BG positions
hold on;
switch p.Results.DisplayType
    case '2D'
        for idx = 1:length(BGpositions)
            xcoord = xlim;
            ycoord = repmat(BGpositions(idx),1,2);
            plot(axisHandle,xcoord,ycoord,'k-');
        end
    case '1D'
        for idx = 1:length(BGpositions)
            xcoord = repmat(BGpositions(idx),1,2);
            ycoord = ylim;
            plot(axisHandle,xcoord,ycoord,'k-');
        end
end
hold off;

end

function BGpositions = getBGpositions(dataset,shift)

BGpositions = [];

try
    % Get field vector - create from the parameters in case dataset is not
    % yet complete
    field = ...
        dataset.parameters.field.start.value : ...
        dataset.parameters.field.step.value : ...
        dataset.parameters.field.stop.value;
    % For shorter lines
    occurrence = dataset.parameters.background.occurrence;
    switch lower(dataset.parameters.field.sequence)
        case {'inward','in','inwards'}
            BGpositions = field(end-ceil(occurrence/2):-ceil(occurrence/2):1);
            BGpositions = [ BGpositions ...
                 field(1+floor(occurrence/2):floor(occurrence/2):end) ] + ...
                dataset.parameters.field.step.value/2;
        case {'outward','out','outwards'}
            centerField = ceil(length(field)/2);
            BGpositions = ...
                field(centerField-ceil(occurrence/2):-ceil(occurrence/2):1);
            BGpositions = [ BGpositions ...
                field(centerField+floor(occurrence/2):floor(occurrence/2):end)] + ...
                dataset.parameters.field.step.value/2;
        case 'up'
            BGpositions = field(occurrence:occurrence:end) + ...
                dataset.parameters.field.step.value/2;
        case 'down'
            BGpositions = field(end:-occurrence:1) - ...
                dataset.parameters.field.step.value/2;
        otherwise
            return;
    end
    BGpositions = BGpositions + shift*dataset.parameters.field.step.value;
catch  %#ok<CTCH>
end

end