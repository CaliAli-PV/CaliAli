% CPRINTF displays styled formatted text in the Command Window
%
% Syntax:
%    count = cprintf(style,format,...)
%
% Description:
%    CPRINTF processes the specified text using the exact same FORMAT
%    arguments accepted by the built-in SPRINTF and FPRINTF functions.
%
%    CPRINTF then displays the text in the Command Window using the
%    specified STYLE argument. The accepted styles are those used for
%    Matlab's syntax highlighting (see: File / Preferences / Colors / 
%    M-file Syntax Highlighting Colors), and also user-defined colors.
%
%    The possible pre-defined STYLE names are:
%
%      'Text'                - default (based on Preferences): black
%      'Keywords'            - default (based on Preferences): blue
%      'Comments'            - default (based on Preferences): green
%      'Strings'             - default (based on Preferences): purple
%      'UnterminatedStrings' - default (based on Preferences): dark red
%      'SystemCommands'      - default (based on Preferences): orange
%      'Errors'              - default (based on Preferences): light red
%      'Hyperlinks'          - default (based on Preferences): blue (underlined)
%
%       'Black','Cyan','Magenta','Blue','Green','Red','Yellow','White'
%
%    STYLE beginning with '-' or '_' will be underlined. For example:
%          '-Blue' is underlined blue, like 'Hyperlinks';
%          '_Comments' is underlined green etc.
%
%    STYLE beginning with '*' will be bold (R2011b+ only). For example:
%          '*Blue' is bold blue;
%          '*Comments' is bold green etc.
%    Note: Matlab does not currently support both bold and underline,
%          only one of them can be used in a single cprintf command. But of
%          course bold and underline can be mixed by using separate commands.
%
%    STYLE colors can be specified in 3 variants:
%        [0.1, 0.7, 0.3] - standard Matlab RGB color format in the range 0.0-1.0
%        [26, 178, 76]   - numeric RGB values in the range 0-255
%        '#1ab34d'       - Hexadecimal format in the range '00'-'FF' (case insensitive)
%                          3-digit HTML RGB format also accepted: 'a5f'='aa55ff'
%
%    STYLE can be underlined by prefixing - :  -[0,1,1]  or '-#0FF' is underlined cyan
%    STYLE can be made bold  by prefixing * : '*[1,0,0]' or '*#F00' is bold red
%
%    STYLE is case-insensitive and accepts unique (non-ambiguous) partial strings
%    for example: 'cy' [instead of 'cyan'], 'system', 'err'.
%
%    CPRINTF by itself, without any input parameters, displays a demo
%
% Example:
%    cprintf;   % displays the demo
%    cprintf('text',   'regular black text');
%    cprintf('hyper',  'followed %s','by');
%    cprintf('key',    '%d colored', 4);
%    cprintf('-comment','& underlined');
%    cprintf('err',    'elements\n');
%    cprintf('cyan',   'cyan');
%    cprintf('_green', 'underlined green');
%    cprintf(-[1,0,1], 'underlined magenta');
%    cprintf([1,0.5,0],'and multi-\nline orange\n');
%    cprintf('*blue',  'and *bold* (R2011b+ only)\n');
%    cprintf('string');  % same as fprintf('string') and cprintf('text','string')
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab
%    functionality. It works on Matlab 7+, but use at your own risk!
%
%    A technical description of the implementation can be found at:
%    <a href="http://undocumentedmatlab.com/articles/cprintf">http://UndocumentedMatlab.com/articles/cprintf</a>
%
% Limitations:
%    1. In R2011a and earlier, a single space char is inserted at the
%       beginning of each CPRINTF text segment (this is ok in R2011b+).
%
%    2. In R2011a and earlier, consecutive differently-colored multi-line
%       CPRINTFs sometimes display incorrectly on the bottom line.
%       As far as I could tell this is due to a Matlab bug. Examples:
%         >> cprintf('-str','under\nline'); cprintf('err','red\n'); % hidden 'red', non-hidden '_'
%         >> cprintf('str','regu\nlar'); cprintf('err','red\n'); % underline red (not purple) 'lar'
%
%    3. Sometimes, non newline ('\n')-terminated segments display unstyled
%       (black) when the command prompt chevron ('>>') regains focus on the
%       continuation of that line (I can't pinpoint when this happens). 
%       To fix this, simply newline-terminate all command-prompt messages.
%
%    4. In R2011b and later, the above errors appear to be fixed. However,
%       the last character of an underlined segment is not underlined for
%       some unknown reason (add an extra space character to make it look better)
%
%    5. In old Matlab versions (e.g., Matlab 7.1 R14), multi-line styles
%       only affect the first line. Single-line styles work as expected.
%       R14 also appends a single space after underlined segments.
%
%    6. Bold style is only supported on R2011b+, and before R2025a cannot also
%       be underlined i.e., the style can be bold or underline, but not both.
%       On R2025a or newer, style can be both bold and underline.
%
%    7. CPRINTF is not supported in Matlab mobile, Live Editor, deployed, diary,
%       and terminal (no desktop) modes; The new web-based (JavaScript) desktop
%       is only supported in R2025a or newer. This limitation depends on internal
%       Matlab limitations that may possibly be lifted in future Matlab releases.
%
% Change log:
%    2009-05-13: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>
%    2009-05-28: corrected nargout behavior suggested by Andreas Gäb
%    2009-09-28: Fixed edge-case problem reported by Swagat K
%    2010-06-27: Fix for R2010a/b; fixed edge case reported by Sharron; CPRINTF with no args runs the demo
%    2011-03-04: Performance improvement
%    2011-08-29: Fix by Danilo (FEX comment) for non-default text colors
%    2011-11-27: Fixes for R2011b
%    2012-08-06: Fixes for R2012b; added bold style; accept RGB string (non-numeric) style
%    2012-08-09: Graceful degradation support for deployed (compiled) and non-desktop applications; minor bug fixes
%    2015-03-20: Fix: if command window isn't defined yet (startup) use standard fprintf as suggested by John Marozas
%    2015-06-24: Fixed a few discoloration issues (some other issues still remain)
%    2020-01-20: Fix by T. Hosman for embedded hyperlinks
%    2021-04-07: Enabled specifying color as #RGB (hexa codes), [.1,.7,.3], [26,178,76]
%    2022-01-04: Fixed cases of invalid colors (especially bad on R2021b onward)
%    2022-03-26: Fixed cases of using string (not char) inputs
%    2025-02-12: Support R2025a (web-based desktop)
%    2025-03-05: Output to STDERR if style is 'error','red' or [1,0,0] (non-Desktop modes only)
%    2025-09-07: Fixed auto-hyperlink in R2025a+; empty style now means 'text'
%
% See also:
%    sprintf, fprintf

% License to use and modify this code is granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.

% Programmed and Copyright by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.17 $  $Date: 2025/09/07 20:27:00 $
