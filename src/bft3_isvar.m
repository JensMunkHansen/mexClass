%function tf = bft3_isvar(name)
% determine if "name" is a variable in the caller's workspace
% $Id: bft3_isvar.m,v 1.1 2011-07-27 21:44:05 jmh Exp $
function tf = bft3_isvar(name)

  if nargin < 1, help(mfilename), error(mfilename), end
  
  tf = true;
  evalin('caller', [name ';'], 'tf=false;')
end
