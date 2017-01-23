function s = tdfread_Modi(filename,delimiter,displayopt,readvarnames,treatAsEmpty)
%TDFREAD Read in text and numeric data from tab-delimited file.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/05/07 18:27:39 $

tab = sprintf('\t');
lf = sprintf('\n');

% set the delimiter
if nargin < 2 || isempty(delimiter)
   delimiter = tab;
else
   switch delimiter
   case {'tab', '\t'}
      delimiter = tab;
   case {'space',' '}
      delimiter = ' ';
   case {'comma', ','}
      delimiter = ',';
   case {'semi', ';'}
      delimiter = ';';
   case {'bar', '|'}
      delimiter = '|';
   otherwise
      delimiter = delimiter(1);
      warning('stats:dataset:UnrecognizedDelimiter', ...
              ['TDFREAD does not support the character %c as a delimiter.  ' ...
               'This may give bad results.'],delimiter(1));
   end
end

if nargin < 4 || isempty(readvarnames)
    readvarnames = false;
elseif ~isscalar(readvarnames) || ...
                ~(islogical(readvarnames) || isnumeric(readvarnames))
    error('stats:dataset:InvalidReadVarNames', ...
          'READVARNAMES must be a scalar logical.');
end
% set the strings that will be converted to NaN
if nargin < 5 || isempty(treatAsEmpty)
    treatAsEmpty = {};
elseif ischar(treatAsEmpty) || iscellstr(treatAsEmpty)
    treatAsEmpty = strtrim(treatAsEmpty);
    if any(~isnan(str2double(treatAsEmpty))) || any(strcmpi('nan',treatAsEmpty))
        error('stats:dataset:NumericTreatAsEmpty', ...
              'TREATASEMPTY must not contain numeric literal strings.');
    end
else
    error('stats:dataset:UnrecognizedTreatAsEmpty', ...
          'TREATASEMPTY must be a string or a cell array of strings.');
end

%%% open file
fid = fopen(filename,'rt'); % text mode: CRLF -> LF

if fid == -1
   error('stats:dataset:OpenFailed', ...
         'Unable to open file ''%s''.', filename);
end

% now read in the data
[bigM,count] = fread(fid,Inf);
fclose(fid);
if count == 0
    s = struct;
    return
elseif bigM(count) ~= lf
   bigM = [bigM; lf];
end
bigM = char(bigM(:)');

% replace CRLF with LF (for reading DOS files on unix, where text mode is a
% no-op).  replace multiple embedded whitespace with a single whitespace,
% multiple underscores with one, and multiple line breaks with one (allows
% empty lines at the end).  remove insignificant whitespace before and after
% delimiters or line breaks.
if delimiter == tab
   matchexpr = {'\r\n' '([ _\n])\1+' ' *(\n|\t) *'};
elseif delimiter == ' '
   matchexpr = {'\r\n' '([\t_\n])\1+' '\t*(\n| )\t*'};
else
   matchexpr = {'\r\n' '[ \t]*([ \t])|([_\n])\1+' ['[ \t]*(\n|\' delimiter ')[ \t]*']};
end
replexpr = {'\n' '$1' '$1'};
bigM = regexprep(bigM,matchexpr,replexpr);

% find out how many lines are there.
newlines = find(bigM == lf);

% take the first line out from bigM, and put it to line1.
line1 = bigM(1:newlines(1)-1);
if readvarnames
   bigM(1:newlines(1)) = [];
   newlines(1) = [];
end

% add a delimiter to the beginning and end of the line
if line1(1) ~= delimiter
   line1 = [delimiter, line1];
end
if line1(end) ~= delimiter
   line1 = [line1, delimiter];
end

% determine varnames
idx = find(line1==delimiter);
nvars = length(idx)-1;
if readvarnames
   varnames = cell(1, nvars);
   for k = 1:nvars;
       vn = line1(idx(k)+1:idx(k+1)-1);
       if isempty(vn) % things like ', ,' are already reduced to ',,'
          varnames{k} = strcat('Var',num2str(k,'%d'));
       else
          vn = regexprep(vn, '[ \t]', '_');
          varnames{k} = vn;
       end
   end
   varnames = genvarname(varnames);
else
   varnames = strcat({'Var'},num2str((1:nvars)','%-d'));
end

nobs = length(newlines);

delimitidx = find(bigM == delimiter);

% check the size validation
if length(delimitidx) ~= nobs*(nvars-1)
   error('stats:dataset:BadFileFormat',...
         'Requires the same number of delimiters on each line.');
end
if nvars > 1
   delimitidx = (reshape(delimitidx,nvars-1,nobs))';
end

% now we need to re-find the newlines.
newlines = find(bigM(:) == lf);

startlines = [zeros(nobs>0,1); newlines(1:nobs-1)];
delimitidx = [startlines, delimitidx, newlines];
fieldlengths = diff(delimitidx,[],2) - 1; fieldlengths = fieldlengths(:);
if any(fieldlengths < 0)
   error('stats:dataset:BadFileFormat',...
         'Requires the same number of delimiters on each line.');
end
maxlength = max(fieldlengths);
if nargout > 0
    s = struct;
end
for vars = 1:nvars
   xstr = repmat(' ',nobs,maxlength);
   x = NaN(nobs,1);
   xNumeric = true;
   for k = 1:nobs
       str = bigM(delimitidx(k,vars)+1:delimitidx(k,vars+1)-1);
       xstr(k,1:length(str)) = str;
       if xNumeric % numeric so far, anyways
           num = str2double(str);
           if isnan(num)
               % If the result was NaN, figure out why.  Note that because we
               % leave xstr alone, TreatAsEmpty only works on numeric columns.
               % That is what textscan does.
               if isempty(str) || any(strcmpi(str,'nan')) || any(strcmp(str,treatAsEmpty))
                   % Leave x(k) alone, it has a NaN already.  We won't decide
                   % if this column is numeric or not based on this value.
               else
                   % NaN must have come from a failed conversion, treat this
                   % column as strings.
                   xNumeric = false;
               end
           else
               % Otherwise accept the numeric value.  Numeric literals in
               % TreatAsEmpty, such as "-99", have already been disallowed, so
               % it's OK to accept any numeric literal here.  Numeric literals
               % cannot be used with TreatAsEmpty.  That is what textscan
               % does.
               x(k) = num;
           end
       end
   end
   if ~xNumeric
       x = xstr;
   end
   vname = varnames{vars};
   try
      if nargout == 0
         assignin('base', vname, x);
      else
         s.(vname) = x;
      end
   catch
      warning('stats:dataset:VarCreateFailed', ...
              'Failed to create variable named %s, skipping column %d from file.', vname, vars);
   end
end
