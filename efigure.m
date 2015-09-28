% EFIGURE - figure with export-fig toolbar buttons built in
%
%  Adds 2 toolbar icons which should be used for saving images
%   to clipboard or to file.
%
%   Function can be used in 2 ways:
%      1. Allow it to automatically add the toolbar items for EVERY future figure
%      2. Call it manually everytime you want to add the toolbar items to:
%           A figure
%           A toolbar
%
%  1. To set up for ALL future figures being created
%  -------------------------------------------------
%    You would put this is your startup.m
%      efigure ( 'setup' );
%    
%    When used for all figures a few methods to turn on/off and reset
%
%     Disable this feature (valid for each matlab session)
%      efigure ( '*disable*' ); 
%
%     Re-enable it by:
%      efigure ( '*enable*' ); 
%
%    Reset the default export_fig options in the filechooser dialog:
%      efigure ( '*reset*' ); 
%
%
%  2. Using it manually 
%  ----------------------
%    Use in EXACTLY the same was as you would figure:
%    This will insert it next to the save button in a standard toolbar
%      hFig = efigure;
%      hFig = efigure (gcf);
%      hFig = efigure (hFig);
%      hFig = efigure ( 'Name', 'My Figure', arg, val .... );
%
%     
%    Add it to a specific toolbar 
%      hFig = figure ( 'Toolbar', 'none' )
%      hToolbar = uitoolbar ( 'parent', hFig );
%      efigure(hToolbar)
%
%
%  Developer note: this used mlock
%
%  see also export_fig, mlock
%
% Author   : Robert Cumming
% Copyright: Matpi Ltd
%            Developers of Matlab GUI Toolbox 
%               - free download @www.matpi.com
%               -  contact @ matpi.com
%
% $Id$ 
function varargout = efigure ( primaryArg, varargin )
  persistent disable
  if isempty ( disable ); disable = false; end
  if nargin == 0
    hFig = builtin ( 'figure', varargin{:} );
  elseif nargin == 1 && ischar(primaryArg)
    if strcmp ( primaryArg, '*setup*' )
      if isempty ( getappdata ( 0, 'EFIGURE' ) )
        if ~verLessThan ( 'matlab', '8.4' ) % R2014b onwards
          h = addlistener ( groot, 'ObjectChildAdded', @setup_efigure);
          setappdata ( 0, 'EFIGUREADDED', h )
        else
          h = addlistener ( 0, 'ObjectChildAdded', @setup_efigure);
          setappdata ( 0, 'EFIGUREADDED', h )
        end
      end
    elseif strcmp ( primaryArg, '*reset*' )
      customExportFile();
    elseif strcmp ( primaryArg, '*enable*' );
      disable = false;
    elseif strcmp ( primaryArg, '*disable*' );
      disable = true;
    end
    return
  end
  if disable; return; end
%   mlock;

  % Check to see if the 1st arg is a toolbar
  isFigure = true;
  if nargin >= 1
    if ishandle ( primaryArg )
      hFig = ancestor ( primaryArg, 'figure' );
      isFigure = isequal ( primaryArg, hFig );
    end
  end

  hFig = handle(hFig);
  if isFigure
    hToolbar = getHToolbar(hFig);
  else
    hToolbar = primaryArg;
  end
  hButtons = handle(findall(hToolbar));
  % Check to see if the toolbar buttons have already been added
  if isFigure == false || ~isempty ( hButtons ) && ~any ( strcmp ( get ( hButtons, 'Tag' ), 'Matpi.Clipboard' ) )
    % Clipboard toolbar image
    cdataClip(:,:,1) = [NaN,NaN,NaN,0.95,0.96,0.95,0.96,0.71,0.71,0.95,0.95,0.96,0.96,NaN,NaN,NaN;NaN,NaN,0.70,0.68,0.65,0.79,0.81,0.77,0.76,0.81,0.80,0.65,0.68,0.68,0.98,NaN;NaN,0.89,0.65,0.72,0.98,0.79,0.79,0.79,0.79,0.79,0.77,0.99,0.73,0.66,0.86,NaN;NaN,0.89,0.62,0.81,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.85,0.62,0.85,NaN;NaN,0.88,0.60,0.79,NaN,NaN,0.00,0.00,0.00,NaN,0.98,NaN,0.84,0.59,0.84,NaN;NaN,0.87,0.58,0.78,0.99,0.00,0.97,0.97,0.98,0.00,0.98,NaN,0.83,0.56,0.84,NaN;NaN,0.87,0.54,0.76,0.98,0.00,0.96,0.97,0.96,0.96,0.97,0.99,0.81,0.55,0.82,NaN;NaN,0.86,0.52,0.74,0.98,0.00,0.96,0.96,0.96,0.96,0.96,0.98,0.80,0.52,0.82,NaN;NaN,0.85,0.50,0.72,0.96,0.00,0.94,0.95,0.95,0.00,0.96,0.98,0.78,0.49,0.81,NaN;NaN,0.85,0.47,0.70,0.93,NaN,0.00,0.00,0.00,NaN,0.94,0.97,0.77,0.47,0.80,NaN;NaN,0.84,0.45,0.69,0.94,0.82,0.91,0.91,0.91,0.91,0.92,0.95,0.75,0.45,0.79,NaN;NaN,0.83,0.44,0.56,0.70,0.67,0.71,0.86,0.92,0.90,0.90,0.93,0.73,0.43,0.78,NaN;NaN,0.82,0.43,0.46,0.45,0.45,0.48,0.51,0.62,0.81,0.92,0.95,0.67,0.41,0.77,NaN;NaN,0.81,0.39,0.44,0.44,0.44,0.44,0.44,0.42,0.40,0.41,0.51,0.42,0.40,0.75,NaN;NaN,0.98,0.32,0.34,0.35,0.35,0.35,0.36,0.36,0.35,0.35,0.34,0.35,0.30,0.94,NaN;0.96,0.88,0.81,0.68,0.67,0.66,0.65,0.64,0.64,0.65,0.65,0.67,0.67,0.78,0.86,0.94;];
    cdataClip(:,:,2) = [NaN,NaN,NaN,0.93,0.94,0.91,0.93,0.72,0.71,0.93,0.91,0.94,0.94,NaN,NaN,NaN;NaN,NaN,0.47,0.43,0.36,0.78,0.84,0.67,0.64,0.84,0.80,0.37,0.42,0.45,0.98,NaN;NaN,0.82,0.41,0.53,0.98,0.79,0.79,0.80,0.80,0.79,0.78,0.99,0.56,0.42,0.77,NaN;NaN,0.82,0.36,0.71,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.76,0.37,0.76,NaN;NaN,0.81,0.34,0.68,NaN,NaN,0.00,0.00,0.00,NaN,0.98,NaN,0.73,0.34,0.75,NaN;NaN,0.80,0.31,0.66,1.00,0.00,0.97,0.97,0.98,0.00,0.98,NaN,0.72,0.31,0.74,NaN;NaN,0.79,0.29,0.64,1.00,0.00,0.96,0.97,0.96,0.96,0.97,1.00,0.70,0.29,0.73,NaN;NaN,0.78,0.26,0.62,0.99,0.00,0.96,0.96,0.96,0.96,0.96,1.00,0.69,0.26,0.72,NaN;NaN,0.77,0.24,0.60,0.97,0.00,0.94,0.95,0.95,0.00,0.96,1.00,0.67,0.23,0.71,NaN;NaN,0.77,0.21,0.58,0.95,NaN,0.00,0.00,0.00,NaN,0.94,0.98,0.66,0.20,0.70,NaN;NaN,0.76,0.18,0.58,0.96,0.82,0.91,0.91,0.91,0.91,0.92,0.96,0.64,0.18,0.70,NaN;NaN,0.75,0.18,0.37,0.66,0.68,0.74,0.87,0.93,0.91,0.90,0.94,0.62,0.16,0.69,NaN;NaN,0.75,0.17,0.22,0.18,0.18,0.27,0.37,0.55,0.79,0.95,0.99,0.53,0.14,0.67,NaN;NaN,0.72,0.15,0.21,0.21,0.21,0.20,0.19,0.17,0.14,0.17,0.33,0.16,0.15,0.65,NaN;NaN,0.98,0.06,0.10,0.10,0.11,0.11,0.11,0.11,0.11,0.10,0.09,0.10,0.04,0.92,NaN;0.96,0.89,0.81,0.62,0.61,0.60,0.59,0.58,0.58,0.59,0.60,0.61,0.61,0.76,0.87,0.94;];
    cdataClip(:,:,3) = [NaN,NaN,NaN,0.88,0.89,0.84,0.87,0.73,0.71,0.87,0.83,0.89,0.89,NaN,NaN,NaN;NaN,NaN,0.12,0.05,0.00,0.75,0.87,0.51,0.44,0.88,0.82,0.00,0.05,0.08,0.96,NaN;NaN,0.71,0.05,0.24,0.96,0.81,0.79,0.82,0.83,0.79,0.79,0.96,0.30,0.06,0.62,NaN;NaN,0.71,0.02,0.53,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,0.62,0.02,0.62,NaN;NaN,0.70,0.01,0.49,NaN,NaN,0.00,0.00,0.00,NaN,0.98,NaN,0.59,0.00,0.62,NaN;NaN,0.70,0.00,0.49,1.00,0.00,0.97,0.97,0.98,0.00,0.98,NaN,0.58,0.00,0.61,NaN;NaN,0.70,0.00,0.48,1.00,0.00,0.96,0.97,0.96,0.96,0.97,1.00,0.57,0.00,0.61,NaN;NaN,0.70,0.00,0.47,1.00,0.00,0.96,0.96,0.96,0.96,0.96,1.00,0.57,0.00,0.60,NaN;NaN,0.69,0.00,0.45,0.98,0.00,0.94,0.95,0.95,0.00,0.96,1.00,0.56,0.00,0.59,NaN;NaN,0.69,0.00,0.45,0.96,NaN,0.00,0.00,0.00,NaN,0.94,1.00,0.55,0.00,0.59,NaN;NaN,0.69,0.00,0.45,0.99,0.82,0.91,0.91,0.91,0.91,0.92,0.98,0.53,0.00,0.59,NaN;NaN,0.69,0.00,0.18,0.64,0.70,0.77,0.89,0.94,0.91,0.90,0.95,0.53,0.00,0.59,NaN;NaN,0.68,0.00,0.00,0.00,0.00,0.07,0.24,0.48,0.78,0.97,1.00,0.43,0.00,0.59,NaN;NaN,0.67,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.15,0.00,0.00,0.57,NaN;NaN,0.98,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.91,NaN;0.96,0.89,0.81,0.59,0.58,0.57,0.56,0.56,0.56,0.56,0.57,0.58,0.58,0.77,0.88,0.94;];
    % export fig save toolbar image
    cdataSave(:,:,1) = [0.23,0.23,0.24,0.23,0.29,0.65,0.65,0.65,0.65,0.65,0.65,0.65,0.65,0.12,0.23,0.05;0.23,0.42,0.22,0.23,0.42,0.91,0.92,0.92,0.91,0.89,0.88,0.28,0.85,0.13,0.23,0.22;0.22,0.27,0.31,0.23,0.28,0.86,0.87,0.86,0.84,0.83,0.80,0.28,0.76,0.15,0.27,0.23;0.22,0.26,0.30,0.23,0.27,0.83,0.83,0.83,0.81,0.80,0.78,0.28,0.76,0.17,0.27,0.22;0.22,0.25,0.29,0.23,0.23,0.81,0.80,0.80,0.79,0.76,0.76,0.84,0.76,0.19,0.25,0.21;0.20,0.24,0.32,0.29,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0.22,0.21,0.24,0.20;0.20,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.20;0.18,0.60,0.85,0.84,0.84,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.85,0.59,0.19;0.18,0.87,0.00,0.86,0.00,0.00,0.87,0.00,0.00,0.86,0.00,0.00,0.00,0.00,0.87,0.18;0.17,0.84,0.00,0.84,0.00,0.84,0.00,0.84,0.00,0.84,0.00,0.84,0.84,0.84,0.85,0.17;0.16,0.86,0.00,0.86,0.00,0.86,0.00,0.86,0.00,0.86,0.00,0.86,0.00,0.00,0.86,0.16;0.15,0.84,0.00,0.84,0.00,0.84,0.84,0.84,0.00,0.84,0.00,0.84,0.84,0.00,0.84,0.15;0.14,0.83,0.00,0.86,0.00,0.86,0.86,0.86,0.00,0.86,0.00,0.00,0.00,0.00,0.84,0.14;0.13,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.13;0.12,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.93,0.13;0.07,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.79,0.07;];
    cdataSave(:,:,2) = [0.23,0.24,0.25,0.24,0.30,0.70,0.70,0.70,0.70,0.70,0.70,0.70,0.70,0.12,0.23,0.05;0.23,0.42,0.22,0.24,0.42,0.96,0.97,0.97,0.96,0.96,0.96,0.29,0.94,0.14,0.23,0.23;0.23,0.29,0.31,0.24,0.28,0.95,0.95,0.95,0.95,0.93,0.92,0.29,0.91,0.16,0.29,0.23;0.23,0.27,0.31,0.24,0.27,0.94,0.94,0.94,0.93,0.91,0.91,0.29,0.91,0.18,0.27,0.23;0.22,0.26,0.30,0.24,0.24,0.92,0.92,0.91,0.91,0.91,0.91,0.94,0.91,0.20,0.26,0.22;0.21,0.25,0.32,0.30,0.22,0.22,0.23,0.22,0.22,0.22,0.22,0.22,0.22,0.21,0.25,0.21;0.20,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.20;0.20,0.64,0.92,0.92,0.92,0.92,0.92,0.92,0.92,0.92,0.92,0.92,0.92,0.92,0.64,0.20;0.19,0.83,0.00,0.83,0.00,0.00,0.83,0.00,0.00,0.83,0.00,0.00,0.00,0.00,0.83,0.19;0.17,0.92,0.00,0.92,0.00,0.92,0.00,0.92,0.00,0.92,0.00,0.92,0.92,0.92,0.92,0.18;0.16,0.83,0.00,0.83,0.00,0.83,0.00,0.83,0.00,0.83,0.00,0.83,0.00,0.00,0.83,0.16;0.16,0.91,0.00,0.92,0.00,0.92,0.92,0.92,0.00,0.92,0.00,0.92,0.92,0.00,0.92,0.16;0.15,0.91,0.00,0.83,0.00,0.83,0.83,0.83,0.00,0.83,0.00,0.00,0.00,0.00,0.92,0.15;0.14,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.14;0.13,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.50,0.13;0.07,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.43,0.07;];
    cdataSave(:,:,3) = [0.25,0.25,0.26,0.25,0.32,0.70,0.70,0.70,0.70,0.70,0.70,0.70,0.70,0.13,0.25,0.05;0.25,0.43,0.23,0.25,0.43,0.96,0.97,0.97,0.96,0.96,0.96,0.30,0.94,0.14,0.25,0.24;0.24,0.30,0.32,0.25,0.30,0.95,0.95,0.95,0.95,0.93,0.92,0.30,0.91,0.16,0.30,0.24;0.24,0.29,0.32,0.25,0.29,0.94,0.94,0.94,0.93,0.91,0.91,0.30,0.91,0.18,0.29,0.24;0.23,0.27,0.31,0.25,0.25,0.92,0.92,0.91,0.91,0.91,0.91,0.94,0.91,0.21,0.27,0.23;0.22,0.26,0.33,0.31,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.23,0.22,0.26,0.22;0.22,0.24,0.24,0.25,0.24,0.25,0.25,0.24,0.24,0.25,0.25,0.25,0.25,0.25,0.24,0.22;0.21,0.69,0.99,0.99,0.99,0.99,0.99,0.99,0.99,0.99,0.99,0.99,0.99,0.99,0.69,0.21;0.20,0.77,0.00,0.77,0.00,0.00,0.77,0.00,0.00,0.77,0.00,0.00,0.00,0.00,0.77,0.19;0.18,0.99,0.00,0.99,0.00,0.99,0.00,0.99,0.00,0.99,0.00,0.99,0.99,0.99,0.99,0.18;0.17,0.77,0.00,0.77,0.00,0.77,0.00,0.77,0.00,0.77,0.00,0.77,0.00,0.00,0.77,0.18;0.16,0.98,0.00,0.99,0.00,0.99,0.99,0.99,0.00,0.99,0.00,0.99,0.99,0.00,0.99,0.16;0.15,0.99,0.00,0.77,0.00,0.77,0.77,0.77,0.00,0.77,0.00,0.00,0.00,0.00,0.98,0.15;0.14,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.14;0.13,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.13;0.08,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.07;];
    
    uipushtool('parent',hToolbar,'cdata',cdataClip, 'ToolTip', 'Copy Image To Clipboard', 'ClickedCallback', @(a,b)exportImage( hFig, '-clipboard' ), 'Tag', 'Matpi.Clipboard' );
    uipushtool('parent',hToolbar,'cdata',cdataSave, 'ToolTip', 'Export Image',            'ClickedCallback', @(a,b)exportImage( hFig, '-file' ),      'Tag', 'Matpi.Save' );
    % Extract all the buttons
    hButtons = handle(findall(hToolbar));
    % Rearrange the order of the buttons -> to put the 2 new ones near the start
    nButtons = length(hButtons);
    if isFigure && nButtons > 9
      if verLessThan ( 'matlab', '8.4' )
        rearrangeIndex = [5:nButtons-4, 2,3,4, nButtons-3:nButtons-1];
      else
        rearrangeIndex = [4:nButtons-3,2,3, nButtons-2:nButtons];
      end
      set(hToolbar,'children',hButtons(rearrangeIndex));
    end
  else
   %plot ( peaks(10) );
   %customExportFile ( hFig )
  end
  if nargout == 1
    varargout{1} = hFig;
  end
end
function hToolbar = getHToolbar ( hFig )
  hToolbar = findall ( hFig, 'tag', 'FigureToolBar' );
end
function setup_efigure ( obj, event ) %#ok<INUSL>
  fig = event.Child;
  if verLessThan ( 'matlab', '8.4' ) % pre r2014b
    efigure(fig)
  else
    % toolbar not yet created -> add listener to listen for it being created.
    h = addlistener ( fig, 'ObjectChildAdded', @efigure_child_listener );
    fig.ApplicationData.efigure = h;
  end
end
function efigure_child_listener( obj, event )
  switch class ( event.Child )
    case 'matlab.ui.container.Menu'
      % Look for a menu creation item -> this happens after the toolbar so 
      %  we can add our items the toolbar.
      if strcmp ( event.Child.Tag, 'figMenuHelp' )
        hFig = ancestor(obj,'figure');
        efigure(hFig);
        delete ( hFig.ApplicationData.efigure );
        hFig.ApplicationData = rmfield ( hFig.ApplicationData, 'efigure' );
      end
  end
end

function exportImage ( hFig, method )
  try
    switch method
      case '-clipboard'
        % I prefer not to crop by default -> but you can easily change that by removing the '-nocrop' command from here.
        export_fig ( hFig, '-clipboard', '-nocrop' )
      case '-file'
        customExportFile ( hFig )
    end
  catch le % catch error and check that export_fig exists.
    if isempty ( which ( 'export_fig' ) )
      errordlg ( sprintf ( 'This function requires export_fig\nWhich can be downloaded from the Mathworks FEX' ), 'User Error' );
    end   
    rethrow ( le );
  end
end
function customExportFile ( parentFig )
  persistent lastdir lastVals lastSelection
  if nargin == 0 % reset defaults
    lastdir = [];
    lastVals = [];
    lastSelection = [];
    return
  end
  if isempty ( lastdir ); lastdir = pwd; end
  if isempty ( lastSelection ); lastSelection = 'png'; end
  filters{1} = { 'PDF Files' 'pdf' };
  filters{2} = { 'EPS Files' 'eps' };
  filters{3} = { 'PNG Files' 'png' };
  filters{4} = { 'TIF Files' 'tif' };
  filters{5} = { 'JPG Files' 'jpg' };
  filters{6} = { 'BMP Files' 'bmp' };
  defaults.nocrop = false;
  defaults.transparent = false;
  defaults.magnify = '-m1';
  defaults.resolution = '-r864';
  defaults.native = false;
  defaults.antiAlias = 1;
  defaults.renderer = 1;
  defaults.colorspace = 1;
  defaults.quality = '-q95';
  defaults.padding = '-p0';
  defaults.append = false;
  defaults.bookmark = false;
  defaults.ghostscript = '';
  defaults.deps = 1;
  if isempty ( lastVals )
    lastVals = defaults;
    lastVals.filters = zeros(length(filters),1);
  end
  hFig = dialog('windowstyle', 'normal', 'position', [0 0 850 400], 'visible', 'off', 'Name', 'EFIGURE - Developed by Matpi Ltd - See www.matpi.com for Matlab GUI Toolbox' );
  % add a lisitener to delete this figure if the main one is destroyed
  hDelete = addlistener ( parentFig, 'ObjectBeingDestroyed', @(a,b)delete(hFig) );
  
  % JChooser width -> must be at least 700.
  pw = 0.8235;
  d = uipanel ( 'parent', hFig, 'position', [0 0 pw 1.0], 'BorderWidth', 0, 'units', 'normalized' );
  %
  [jPanel,hPanel] = javacomponent(javax.swing.JPanel, [], d);
  
  set(hPanel, 'units','normalized','position',[0 0 1.0 1.0]);
  %
  input.jChooser = javaObjectEDT('javax.swing.JFileChooser', lastdir );
  input.jChooser.setDialogTitle('Export')
  
  input.jChooser.setControlButtonsAreShown ( true );
  % These are the available file formats that can be saved from export_fig
  for ii=length(filters):-1:1
    if ~isempty ( lastSelection )
      if strcmp ( filters{ii}{2}, lastSelection )
        lastSelection = ii;
        continue
      end
    end
    fileFilter = com.mathworks.hg.util.dFilter;
    fileFilter.setDescription(sprintf ( '%s (%s)', filters{ii}{1}, filters{ii}{2}) );
    fileFilter.addExtension(filters{ii}{2}) ;
    fileFilter.setIdentifier(filters{ii}{2});
    input.jChooser.setFileFilter(fileFilter);
  end
  if ~isempty ( lastSelection ) && isnumeric ( lastSelection )
    fileFilter = com.mathworks.hg.util.dFilter;
    fileFilter.setDescription(sprintf ( '%s (%s)', filters{lastSelection}{1}, filters{lastSelection}{2}) );
    fileFilter.addExtension(filters{lastSelection}{2}) ;
    fileFilter.setIdentifier(filters{lastSelection}{2});
    input.jChooser.setFileFilter(fileFilter);
  end
  
  optPanel = uipanel ( 'parent', hFig, 'position', [pw 0 1-pw 1.0], 'BorderWidth', 0, 'units', 'normalized' );
  % Add the options for the multiple file filter saving
  count = 0;
  rCount = 1;
  uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 0.95 0.95 0.04], 'string', 'Select to save mulltiple files:', 'style', 'text', 'HorizontalAlignment', 'left' );
  while count < length(filters)
    for rr=1:2
      count = count + 1;
      input.filters{count} = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02+(rr-1)*0.5 0.95-0.05*rCount 0.44 0.04], 'string', filters{count}{2}, 'style', 'checkbox', 'value', lastVals.filters(count), 'TooltipString', sprintf ( 'export_fig can save multiple formats at the same time\ncheck each format to save in addition to the format\nselected in the main file type.' ) );
    end
    rCount = rCount + 1;
  end
  lastPos = 1-0.05*(rCount);
  % Add the other options
  % prepate tooltip -> extracted from export_fig help.
  tooltip.nocrop      = sprintf ( 'option indicating that the borders of the output are not to\nbe cropped.' );
  tooltip.transparent = sprintf ( 'option indicating that the figure background is to be\nmade transparent (png, pdf and eps output only).' );
  tooltip.magnify     = sprintf ( 'option where val indicates the factor to magnify the\non-screen figure pixel dimensions by when generating bitmap\noutputs (does not affect vector formats). Default: ''-m1''' );
  tooltip.resolution  = sprintf ( 'option val indicates the resolution (in pixels per inch) to\nexport bitmap and vector outputs at, keeping the dimensions\nof the on-screen figure. Default: ''-r864'' (for vector output\nonly). Note that the -m option overides the -r option for\nbitmap outputs only.' );
  tooltip.native      = sprintf ( 'option indicating that the output resolution (when outputting\na bitmap format) should be such that the vertical resolution\nof the first suitable image found in the figure is at the\nnative resolution of that image. To specify a particular\nimage to use, give it the tag ''export_fig_native''. Notes:\nThis overrides any value set with the -m and -r options. It\nalso assumes that the image is displayed front-to-parallel\nwith the screen. The output resolution is approximate and\nshould not be relied upon. Anti-aliasing can have adverse\neffects on image quality (disable with the -a1 option).' );
  tooltip.antiAlias   = sprintf ( 'option indicating the amount of anti-aliasing to\nuse for bitmap outputs. ''-a1'' means no anti-\naliasing; ''-a4'' is the maximum amount (default).' );
  tooltip.renderer    = sprintf ( 'option to force a particular renderer (painters, opengl or\nzbuffer). Default value: opengl for bitmap formats or\nfigures with patches and/or transparent annotations;\npainters for vector formats without patches/transparencies.' );
  tooltip.colorspace  = sprintf ( 'option indicating which colorspace color figures should\nbe saved in: RGB (default), CMYK or gray. CMYK is only\nsupported in pdf, eps and tiff output.' );
  tooltip.quality     = sprintf ( 'option to vary bitmap image quality (in pdf, eps and jpg\nfiles only).  Larger val, in the range 0-100, gives higher\nquality/lower compression. val > 100 gives lossless\ncompression. Default: ''-q95'' for jpg, ghostscript prepress\ndefault for pdf & eps. Note: lossless compression can\nsometimes give a smaller file size than the default lossy\ncompression, depending on the type of images.' );
  tooltip.padding     = sprintf ( 'option to pad a border of width val to exported files, where\nval is either a relative size with respect to cropped image\nsize (i.e. p=0.01 adds a 1%% border). For EPS & PDF formats,\nval can also be integer in units of 1/72" points (abs(val)>1).\nval can be positive (padding) or negative (extra cropping).\nIf used, the -nocrop flag will be ignored, i.e. the image will\nalways be cropped and then padded. Default: 0 (i.e. no padding).' );
  tooltip.append      = sprintf ( 'option indicating that if the file (pdfs only) already\nexists, the figure is to be appended as a new page, instead\nof being overwritten (default).' );
  tooltip.bookmark    = sprintf ( 'option to indicate that a bookmark with the name of the\nfigure is to be created in the output file (pdf only).' );
  tooltip.ghostscript = sprintf ( 'option to indicate a ghostscript setting. For example,\n-dMaxBitmap=0 or -dNoOutputFonts (Ghostscript 9.15+).' );
  tooltip.deps        = sprintf ( 'option to use EPS level-3 rather than the default level-2 print\ndevice. This solves some bugs with Matlab''s default -depsc2 device\nsuch as discolored subplot lines on images (vector formats only).' );
  
  % build uicontrol to allow runtime selection of options  
  input.nocrop      = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.100 0.88 0.04], 'string', 'No Crop', 'style', 'checkbox', 'value', lastVals.nocrop, 'tooltipstring', tooltip.nocrop );
  input.transparent = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.150 0.88 0.04], 'string', 'Transparent', 'style', 'checkbox', 'value', lastVals.transparent, 'tooltipstring', tooltip.transparent );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.200 0.45 0.04], 'string', 'Magnify:', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.magnify     = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.205 0.45 0.05], 'string', lastVals.magnify, 'style', 'edit', 'tooltipstring', tooltip.magnify );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.250 0.45 0.04], 'string', 'Resolution:', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.resolution  = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.255 0.45 0.05], 'string', lastVals.resolution, 'style', 'edit', 'tooltipstring', tooltip.resolution );
  input.native      = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.300 0.88 0.04], 'string', 'Native', 'style', 'checkbox', 'value', lastVals.native, 'tooltipstring', tooltip.native );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.360 0.45 0.04], 'string', 'AntiAlias', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.antialias   = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.350 0.45 0.04], 'string', {'-a1' '-a2' '-a3' '-a4'} , 'style', 'popupmenu', 'value', lastVals.antiAlias, 'tooltipstring', tooltip.antiAlias );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.410 0.45 0.04], 'string', 'Renderer', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.renderer    = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.400 0.45 0.04], 'string', {'default' '-painters' '-opengl' '-zbuffer'}, 'style', 'popupmenu', 'value', lastVals.renderer, 'tooltipstring', tooltip.renderer );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.460 0.45 0.04], 'string', 'Colorspace', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.colorspace  = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.450 0.45 0.04], 'string', {'-RGB' '-CMYK' '-gray'}, 'style', 'popupmenu', 'value', lastVals.colorspace, 'tooltipstring', tooltip.colorspace );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.500 0.45 0.04], 'string', 'Quality:', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.quality     = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.505 0.45 0.05], 'string', lastVals.quality, 'style', 'edit', 'tooltipstring', tooltip.quality );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.550 0.45 0.04], 'string', 'Padding:', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.padding     = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.555 0.45 0.05], 'string', lastVals.padding, 'style', 'edit', 'tooltipstring', tooltip.padding );
  input.append      = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.600 0.88 0.04], 'string', 'Append', 'style', 'checkbox', 'value', lastVals.append, 'tooltipstring', tooltip.append );
  input.bookmark    = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.650 0.88 0.04], 'string', 'Bookmark', 'style', 'checkbox', 'value', lastVals.bookmark, 'tooltipstring', tooltip.bookmark );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.700 0.45 0.04], 'string', 'GS options:', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.ghostscript = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.705 0.45 0.05], 'string', lastVals.ghostscript, 'style', 'edit', 'tooltipstring', tooltip.ghostscript );
                      uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.02 lastPos-0.760 0.45 0.04], 'string', 'DEPS', 'style', 'text', 'HorizontalAlignment', 'left' );
  input.deps        = uicontrol ( 'parent', optPanel, 'units', 'normalized', 'position', [0.50 lastPos-0.750 0.45 0.04], 'string', {'-depsc2' '-depsc3'} , 'style', 'popupmenu', 'value', lastVals.deps, 'tooltipstring', tooltip.deps );
  
  input.jChooser.setDialogType(javax.swing.JFileChooser.SAVE_DIALOG)
  %     % Show the actual dialog
  set ( hFig, 'visible', 'on' );
  centerfig ( hFig, parentFig );
  
  % set the callback to the user action of selecting Open/Save or cancel.
  set(handle(input.jChooser, 'callbackproperties'),'ActionPerformedCallback', {@UserAction});
  
  jPanel.add(input.jChooser);
%   input.runTimeOpts = input.runTimeOpts;
  uiwait ( hFig );
  % Delete the listener -> since this dialog will now be deleted
  delete(hDelete);
  function UserAction(obj,event) %#ok<INUSL>
    %%
    try
      % capture cancel
      if event.getActionCommand()~=javax.swing.JFileChooser.APPROVE_SELECTION
        delete(hFig); return;
      end
      ff = input.jChooser.getFileFilter;              
      lastSelection = char(ff.getIdentifier);
      lastVals.nocrop      = get ( input.nocrop, 'Value' );
      lastVals.transparent = get ( input.transparent, 'Value' );
      lastVals.magnify     = get ( input.magnify, 'String' );
      lastVals.resolution  = get ( input.resolution, 'String' );
      lastVals.native      = get ( input.native, 'Value' );
      lastVals.antiAlias   = get ( input.antialias, 'Value' );
      lastVals.renderer    = get ( input.renderer, 'Value' );
      lastVals.colorspace  = get ( input.colorspace, 'Value' );
      lastVals.quality     = get ( input.quality, 'String' );
      lastVals.padding     = get ( input.padding, 'string' );
      lastVals.append      = get ( input.append, 'Value' );
      lastVals.bookmark    = get ( input.bookmark, 'Value' );
      lastVals.ghostscript = get ( input.ghostscript, 'String' );
      lastVals.deps        = get ( input.deps, 'Value' );
      
      % Extract the file
      jFile = input.jChooser.getSelectedFile();
      % Get the filename
      filename = char(jFile.getPath());
      extras = cell(0);
      
      % add any extra formats to save
      for jj=1:length(input.filters)
        if get (input.filters{jj},'Value')
          extras{end+1} = sprintf ( '-%s', lower(get (input.filters{jj},'String'))); %#ok<AGROW>
          lastVals.filters(jj) = true;
        end
      end
      
      % Add the other runtime cusomisations
      if ~isequal ( defaults.nocrop, lastVals.nocrop           ); extras{end+1} = '-nocrop'; end
      if ~isequal ( defaults.transparent, lastVals.transparent ); extras{end+1} = '-transparent'; end
      if ~isequal ( defaults.magnify, lastVals.magnify         ); extras = checkString ( extras, defaults.magnify(1:2), input.magnify ); end
      if ~isequal ( defaults.resolution, lastVals.resolution   ); extras = checkString ( extras, defaults.resolution(1:2), input.resolution ); end
      if ~isequal ( defaults.native, lastVals.native           ); extras{end+1} = '-native'; end
      if ~isequal ( defaults.antiAlias, lastVals.antiAlias     ); str = get ( input.antialias, 'String' );  extras{end+1} = str{lastVals.antiAlias}; end
      if ~isequal ( defaults.renderer, lastVals.renderer       ); str = get ( input.renderer, 'String' );   extras{end+1} = str{lastVals.renderer}; end
      if ~isequal ( defaults.colorspace, lastVals.colorspace   ); str = get ( input.colorspace, 'String' ); extras{end+1} = str{lastVals.colorspace}; end
      if ~isequal ( defaults.quality, lastVals.quality         ); extras = checkString ( extras, defaults.quality(1:2), input.quality ); end
      if ~isequal ( defaults.padding, lastVals.padding         ); extras = checkString ( extras, defaults.padding(1:2), input.padding ); end
      if ~isequal ( defaults.append, lastVals.append           ); extras{end+1} = '-append'; end
      if ~isequal ( defaults.bookmark, lastVals.bookmark       ); extras{end+1} = '-bookmark'; end
      if ~isequal ( defaults.ghostscript, lastVals.ghostscript ); extras{end+1} = sprintf ( 'd%s', get ( input.ghostscript, 'String' ) ); end
      if ~isequal ( defaults.deps, lastVals.deps               ); str = get ( input.deps, 'String' ); extras{end+1} = str{lastVals.deps}; end
      
      delete(hFig);
      export_fig ( hFig, filename, extras{:} );
    catch le
      fprintf ( 2, 'command: exportFig ( hFig, filename, extras{:}\n' );
      try %#ok<TRYNC>
        disp ( extras )
      end
      errordlg ( 'Error processing see commandline', 'eFigure Error' );
      delete(hFig);
      rethrow(le);
    end
    
  end
  
end
% Check the extra inputs which are string input for the key letters
function extras = checkString ( extras, key, h )
  str = get(h,'String');
  if isempty(str); return; end
  if length(str)>=2 && strcmp ( str(1:2), key )
  else
    str = sprintf ( '%s%s', key, str );
  end
  extras{end+1} = str;
end
