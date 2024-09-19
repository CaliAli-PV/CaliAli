%% |NATSORTFILES| Examples
% The function <https://www.mathworks.com/matlabcentral/fileexchange/47434
% |NATSORTFILES|> sorts filenames or filepaths in an array |A| (cell/string/struct)
% taking into account number values within the text. This is known as
% _natural order_ or _alphanumeric order_. Note that MATLAB's inbuilt
% <https://www.mathworks.com/help/matlab/ref/sort.html |SORT|> function
% sorts text by character code, as does |SORT| in most programming languages.
%
% |NATSORTFILES| does not just provide a naive alphanumeric sort, it also
% splits and sorts the file/folder names and file extensions separately,
% which means that shorter names come before longer ones. For the same reason
% filepaths are split at every path-separator character and each folder level
% is sorted separately. See the "Explanation" sections below for more details.
%
% Other useful text sorting functions:
%
% * Alphanumeric sort the rows of a string/cell/table/etc array:
% <https://www.mathworks.com/matlabcentral/fileexchange/47433 |NATSORTROWS|>
% * Alphanumeric sort of text in a string/cell/categorical array:
% <https://www.mathworks.com/matlabcentral/fileexchange/34464 |NATSORT|>
% * Sort text into the order of arbitrary/custom text sequences:
% <https://www.mathworks.com/matlabcentral/fileexchange/132263 |ARBSORT|>
%
% Note: |NATSORTFILES| calls |NATSORT| to provide the natural order text sort.
%% Basic Usage
% By default |NATSORTFILES| interprets consecutive digits as being part of
% a single integer, any remaining substrings are treated as text.
Aa = ["a2.txt", "a10.txt", "a1.txt"];
sort(Aa) % for comparison
natsortfiles(Aa)
%% Input 1: Array to Sort
% The first input |A| must be one of the following array types:
%
% * a cell array of character row vectors,
% * a <https://www.mathworks.com/help/matlab/ref/string.html string array>,
% * the structure array returned by
%   <https://www.mathworks.com/help/matlab/ref/dir.html |DIR|>.
%
% The sorted array is returned as the first output, making
% |NATSORTFILES| very simple to include with any code:
P = 'natsortfiles_test';
S = dir(fullfile('.',P,'A*.txt'));
S = natsortfiles(S);
for k = 1:numel(S)
    fprintf('%-13s%s\n',S(k).name,S(k).date)
end
%% Input 2: Regular Expression
% The optional second input argument |rgx| is a regular expression which
% specifies the number matching (see "Regular Expressions" section below):
Ab = ["1.3.txt", "1.10.txt", "1.2.txt"];
natsortfiles(Ab)   % by default match integers
natsortfiles(Ab, '\d+\.?\d*') % match decimal fractions
%% Input 3+: Remove "." and ".." Dot Directory Names
% The <https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-fscc/fccd0313-0364-45bd-b75c-924fd6a5662f
% dot directory names> "." and ".." can be removed using the |'rmdot'| option:
S = dir(fullfile('.','HTML','*'));
{S(1:4).name}
S = natsortfiles(S,[],'rmdot');
{S(1:3).name}
%% Input 3+: No File Extension
% For names that do not have file extensions (e.g. folder names, filenames
% without extensions) then the optional |'noext'| argument should be used:
Ac = ["1.9", "1.10", "1.2"]; % names without extensions
natsortfiles(Ac,'\d+\.?\d*') % by default the dot indicates the file extension
natsortfiles(Ac,'\d+\.?\d*','noext')
%% Input 3+: Ignore File Path
% By default the filepath (if provided) will be taken into account
% and sorted too (either split from the filename, or taken from the
% |folder| field). To ignore the path and sort by filename only
% simply specify the optional |'xpath'| argument:
Ad = ["B/3.txt", "A/1.txt", "B/100.txt", "A/20.txt"];
natsortfiles(Ad) % by default sorts the file path too
natsortfiles(Ad,[],'xpath')
%% Inputs 3+: Optional Arguments
% Further inputs are passed directly to |NATSORT|, thus giving control over
% the case sensitivity, sort direction, and other options. See the
% |NATSORT| help for explanations and examples of the supported options:
Ae = ["B.txt", "10.txt", "1.txt", "A.txt", "2.txt"];
natsortfiles(Ae, [], 'descend')
natsortfiles(Ae, [], 'char<num')
%% Output 2: Sort Index
% The second output |ndx| is a numeric array of the sort indices,
% in general such that |B = A(ndx)| where |B = natsortfiles(A,...)|.
% Note that |NATSORTFILES| provides a _stable sort:_
Af = ["abc2xyz.txt", "abc10xyz.txt", "abc2xyz.txt", "abc1xyz.txt"];
[out,ndx] = natsortfiles(Af)
%% Output 3: Debugging Array
% The third output |dbg| is a cell vector of cell arrays, the inner cell
% arrays correspond to foldernames, filenames, and file extensions in |A|.
% The cell arrays contain any matched numbers (after converting to
% numeric using the specified |SSCANF| format) and all non-number
% substrings of |A|. These cell arrays are useful for confirming that
% the numbers are being correctly identified by the regular expression.
[~,~,dbg] = natsortfiles(Af);
dbg{:}
%% Explanation: Short Before Long
% Filenames and file extensions are joined by the extension separator, the
% period character |'.'|. Using a normal |SORT| this period gets sorted
% _after_ all of the characters from 0 to 45 (including |!"#$%&'()*+,-|,
% the space character, and all of the control characters, e.g. newlines,
% tabs, etc). This means that a naive sort returns some shorter filenames
% _after_ longer filenames. To ensure that shorter filenames come first,
% |NATSORTFILES| splits filenames from file extensions and sorts them separately:
Ag = ["test_ccc.m"; "test-aaa.m"; "test.m"; "test.bbb.m"];
sort(Ag) % '-' sorts before '.'
natsort(Ag) % '-' sorts before '.'
natsortfiles(Ag) % short before long
%% Explanation: Filenames
% |NATSORTFILES| sorts the split name parts using an alphanumeric sort, so
% that the number values within the filenames are taken into consideration:
Ah = ["test2.m"; "test10-old.m"; "test.m"; "test10.m"; "test1.m"];
sort(Ah) % Wrong number order.
natsort(Ah) % Correct number order, but longer before shorter.
natsortfiles(Ah) % Correct number order and short before long.
%% Explanation: Filepaths
% For much the same reasons, filepaths are split at each file path
% separator character (note that for PCs both |'/'| and |'\'| are
% considered as path separators, for Linux and Mac only |'/'| is)
% and every level of the directory structure is sorted separately:
Ai = ["'A2-old/test.m"; "A10/test.m"; "A2/test.m"; "AXarchive.zip"; "A1/test.m"];
sort(Ai) % Wrong number order, and '-' sorts before '/'.
natsort(Ai) % Correct number order, but long before short.
natsortfiles(Ai) % Correct number order and short before long.
%% Regular Expression: Decimal Numbers, E-notation, +/- Sign
% |NATSORTFILES| number matching can be customized to detect numbers with
% a decimal fraction, E-notation, a +/- sign, binary/hexadecimal, or other
% required features. The number matching is specified using an
% appropriate regular expression, see |NATSORT| for details and examples.
Aj = ["1.23V.csv", "-1V.csv", "+1.csv" ,"010V.csv", "1.200V.csv"];
natsortfiles(Aj) % by default match integers.
natsortfiles(Aj,'(+|-)?\d+\.?\d*') % match decimal fractions.
%% Example: Decimal Comma and Decimal Point
% Many languages use a decimal comma instead of a decimal point.
% |NATSORTFILES| parses both the decimal comma and the decimal point, e.g.:
Ak = ["1,3.txt", "1,10.txt", "1,2.txt"];
natsortfiles(Ak, '\d+,?\d*') % match optional decimal comma
%% Bonus: Interactive Regular Expression Tool
% Regular expressions are powerful and compact, but getting them right is
% not always easy. One assistance is to download my interactive tool
% <https://www.mathworks.com/matlabcentral/fileexchange/48930 |IREGEXP|>,
% which lets you quickly try different regular expressions and see all of
% <https://www.mathworks.com/help/matlab/ref/regexp.html |REGEXP|>'s
% outputs displayed and updated as you type:
iregexp('x1.23y45.6789z','(\d+)\.?(\d*)') % download IREGEXP from FEX 48930.