function [B,ndx,dbg] = natsortfiles(A,rgx,varargin)
% Natural-order / alphanumeric sort of filenames or foldernames.
%
% (c) 2014-2024 Stephen Cobeldick
%
% Sorts text by character code and by number value. File/folder names, file
% extensions, and path directories (if supplied) are sorted separately to
% ensure that shorter names sort before longer names. For names without
% file extensions (i.e. foldernames, or filenames without extensions) use
% the 'noext' option. Use the 'xpath' option to ignore the filepath. Use
% the 'rmdot' option to remove the folder names "." and ".." from the array.
%
%%% Example:
% P = 'C:\SomeDir\SubDir';
% S = dir(fullfile(P,'*.txt'));
% S = natsortfiles(S);
% for k = 1:numel(S)
%     F = fullfile(S(k).folder,S(k).name)
% end
%
%%% Syntax:
%  B = natsortfiles(A)
%  B = natsortfiles(A,rgx)
%  B = natsortfiles(A,rgx,<options>)
% [B,ndx,dbg] = natsortfiles(A,...)
%
% To sort the elements of a string/cell array use NATSORT (File Exchange 34464)
% To sort the rows of a string/cell/table use NATSORTROWS (File Exchange 47433)
% To sort string/cells using custom sequences use ARBSORT (File Exchange 132263)
%
%% File Dependency %%
%
% NATSORTFILES requires the function NATSORT (File Exchange 34464). Extra
% optional arguments are passed directly to NATSORT. See NATSORT for case-
% sensitivity, sort direction, number format matching, and other options.
%
%% Explanation %%
%
% Using SORT on filenames will sort any of char(0:45), including the
% printing characters ' !"#$%&''()*+,-', before the file extension
% separator character '.'. Therefore NATSORTFILES splits the file-name
% from the file-extension and sorts them separately. This ensures that
% shorter names come before longer names (just like a dictionary):
%
% >> Af = {'test_new.m'; 'test-old.m'; 'test.m'};
% >> sort(Af) % Note '-' sorts before '.':
% ans =
%     'test-old.m'
%     'test.m'
%     'test_new.m'
% >> natsortfiles(Af) % Shorter names before longer:
% ans =
%     'test.m'
%     'test-old.m'
%     'test_new.m'
%
% Similarly the path separator character within filepaths can cause longer
% directory names to sort before shorter ones, as char(0:46)<'/' and
% char(0:91)<'\'. This example on a PC demonstrates why this matters:
%
% >> Ad = {'A1\B', 'A+/B', 'A/B1', 'A=/B', 'A\B0'};
% >> sort(Ad)
% ans =   'A+/B'  'A/B1'  'A1\B'  'A=/B'  'A\B0'
% >> natsortfiles(Ad)
% ans =   'A\B0'  'A/B1'  'A1\B'  'A+/B'  'A=/B'
%
% NATSORTFILES splits filepaths at each path separator character and sorts
% every level of the directory hierarchy separately, ensuring that shorter
% directory names sort before longer, regardless of the characters in the names.
% On a PC separators are '/' and '\' characters, on Mac and Linux '/' only.
%
%% Examples %%
%
% >> Aa = {'a2.txt', 'a10.txt', 'a1.txt'}
% >> sort(Aa)
% ans = 'a1.txt'  'a10.txt'  'a2.txt'
% >> natsortfiles(Aa)
% ans = 'a1.txt'  'a2.txt'  'a10.txt'
%
% >> Ab = {'test2.m'; 'test10-old.m'; 'test.m'; 'test10.m'; 'test1.m'};
% >> sort(Ab) % Wrong number order:
% ans =
%    'test.m'
%    'test1.m'
%    'test10-old.m'
%    'test10.m'
%    'test2.m'
% >> natsortfiles(Ab) % Shorter names before longer:
% ans =
%    'test.m'
%    'test1.m'
%    'test2.m'
%    'test10.m'
%    'test10-old.m'
%
%%% Directory Names:
% >> Ac = {'A2-old\test.m';'A10\test.m';'A2\test.m';'A1\test.m';'A1-archive.zip'};
% >> sort(Ac) % Wrong number order, and '-' sorts before '\':
% ans =
%    'A1-archive.zip'
%    'A10\test.m'
%    'A1\test.m'
%    'A2-old\test.m'
%    'A2\test.m'
% >> natsortfiles(Ac) % Shorter names before longer:
% ans =
%    'A1\test.m'
%    'A1-archive.zip'
%    'A2\test.m'
%    'A2-old\test.m'
%    'A10\test.m'
%
%% Input and Output Arguments %%
%
%%% Inputs (**=default):
% A   = Array to be sorted. Can be the structure array returned by DIR,
%       or a string array, or a cell array of character row vectors.
% rgx = Optional regular expression to match number substrings.
%     = []** uses the default regular expression (see NATSORT).
% <options> can be supplied in any order:
%     = 'rmdot' removes the dot directory names "." and ".." from the output.
%     = 'noext' for foldernames, or filenames without filename extensions.
%     = 'xpath' sorts by name only, excluding any preceding filepath.
% Any remaining <options> are passed directly to NATSORT.
%
%%% Outputs:
% B   = Array <A> sorted into natural sort order.      The same size as <A>.
% ndx = NumericMatrix, generally such that B = A(ndx). The same size as <A>.
% dbg = CellArray, each cell contains the debug cell array of one level
%       of the filename/path parts, i.e. directory names, or filenames, or
%       file extensions. Helps debug the regular expression (see NATSORT).
%
% See also SORT NATSORTFILES_TEST NATSORT NATSORTROWS ARBSORT IREGEXP
% REGEXP DIR FILEPARTS FULLFILE NEXTNAME STRING CELLSTR SSCANF

%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if isstruct(A)
	assert(isfield(A,'name'),...
		'SC:natsortfiles:A:StructMissingNameField',...
		'If first input <A> is a struct then it must have field <name>.')
	nmx = {A.name};
	assert(all(fnh(nmx)),...
		'SC:natsortfiles:A:NameFieldInvalidType',...
		'First input <A> field <name> must contain only character row vectors.')
	[fpt,fnm,fxt] = cellfun(@fileparts, nmx, 'UniformOutput',false);
	if isfield(A,'folder')
		fpt(:) = {A.folder};
		assert(all(fnh(fpt)),...
			'SC:natsortfiles:A:FolderFieldInvalidType',...
			'First input <A> field <folder> must contain only character row vectors.')
	end
elseif iscell(A)
	assert(all(fnh(A(:))),...
		'SC:natsortfiles:A:CellContentInvalidType',...
		'First input <A> cell array must contain only character row vectors.')
	[fpt,fnm,fxt] = cellfun(@fileparts, A(:), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
elseif ischar(A)
	assert(ndims(A)<3,...
		'SC:natsortfiles:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	[fpt,fnm,fxt] = cellfun(@fileparts, num2cell(A,2), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
else
	assert(isa(A,'string'),...
		'SC:natsortfiles:A:InvalidType',...
		'First input <A> must be a structure, a cell array, or a string array.');
	[fpt,fnm,fxt] = cellfun(@fileparts, cellstr(A(:)), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
end
%
varargin = cellfun(@nsf1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
trd = strcmpi(txt,'rmdot');
tnx = strcmpi(txt,'noext');
txp = strcmpi(txt,'xpath');
%
nsfAssert(txt, trd, 'rmdot', '"." and ".." folder')
nsfAssert(txt, tnx, 'noext', 'file-extension')
nsfAssert(txt, txp, 'xpath', 'file-path')
%
chk = '(no|rm|x)(dot|ext|path)';
%
if nargin>1
	nsfChkRgx(rgx,chk)
	txt = [{rgx},txt(~(trd|tnx|txp))];
end
%
%% Path and Extension %%
%
% Path separator regular expression:
if ispc()
	psr = '[^/\\]+';
else % Mac & Linux
	psr = '[^/]+';
end
%
if any(trd) % Remove "." and ".." dot directory names
	ddx = strcmp(nmx,'.') | strcmp(nmx,'..');
	fxt(ddx) = [];
	fnm(ddx) = [];
	fpt(ddx) = [];
	nmx(ddx) = [];
end
%
if any(tnx) % No file-extension
	fnm = nmx;
	fxt = [];
end
%
if any(txp) % No file-path
	mat = reshape(fnm,1,[]);
else % Split path into {dir,subdir,subsubdir,...}:
	spl = regexp(fpt(:),psr,'match');
	nmn = 1+cellfun('length',spl(:));
	mxn = max(nmn);
	vec = 1:mxn;
	mat = cell(mxn,numel(nmn));
	mat(:) = {''};
	%mat(mxn,:) = fnm(:); % old behavior
	mat(permute(bsxfun(@eq,vec,nmn),[2,1])) =  fnm(:);  % TRANSPOSE bug loses type (R2013b)
	mat(permute(bsxfun(@lt,vec,nmn),[2,1])) = [spl{:}]; % TRANSPOSE bug loses type (R2013b)
end
%
if numel(fxt) % File-extension
	mat(end+1,:) = fxt(:);
end
%
%% Sort Matrices %%
%
nmr = size(mat,1)*all(size(mat));
dbg = cell(1,nmr);
ndx = 1:numel(fnm);
%
for ii = nmr:-1:1
	if nargout<3 % faster:
		[~,idx] = natsort(mat(ii,ndx),txt{:},xtx{:});
	else % for debugging:
		[~,idx,gbd] = natsort(mat(ii,ndx),txt{:},xtx{:});
		[~,idb] = sort(ndx);
		dbg{ii} = gbd(idb,:);
	end
	ndx = ndx(idx);
end
%
% Return the sorted input array and corresponding indices:
%
if any(trd)
	tmp = find(~ddx);
	ndx = tmp(ndx);
end
%
ndx = ndx(:);
%
if ischar(A)
	B = A(ndx,:);
elseif any(trd)
	xsz = size(A);
	nsd = xsz~=1;
	if nnz(nsd)==1 % vector
		xsz(nsd) = numel(ndx);
		ndx = reshape(ndx,xsz);
	end
	B = A(ndx);
else
	ndx = reshape(ndx,size(A));
	B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortfiles
function nsfChkRgx(rgx,chk)
chk = sprintf('^(%s)$',chk);
assert(~ischar(rgx)||isempty(regexpi(rgx,chk,'once')),...
	'SC:natsortfiles:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided expression "%s" looks like an optional argument (inputs 3+).'],rgx)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfChkRgx
function nsfAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:natsortfiles:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfAssert
function arr = nsf1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsf1s2c