function caliali_require_java()
%% caliali_require_java: Make sure MATLAB has Java; set it up the first time if not.
%
% Call at the start of any function that needs Java. Up to R2026a, MATLAB
% includes its own Java, so this returns at once. From R2026b MATLAB ships
% without it, and a function that needs it fails. The first time that happens,
% this:
%   1. downloads a Java runtime (caliali_tool('java'), about 50 MB, checked
%      against a fixed checksum);
%   2. tells MATLAB to use it (jenv), which MATLAB remembers;
%   3. if MATLAB cannot load it at once, stops with a message to restart
%      MATLAB.
% After that, Java is there and this returns at once again.
%
% Without internet, install Java by hand: see "Machines without internet" in
% docs/Installation.md.
%
% Inputs:
%   None.
%
% Outputs:
%   None. Stops with an error when MATLAB must be restarted first.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

if usejava('jvm')
    return
end
if isMATLABReleaseOlderThan('R2026b')
    % This MATLAB has its own Java; it was started without it.
    error('CaliAli:java:off', ['This CaliAli function needs Java, and MATLAB ' ...
        'was started without it (matlab -nojvm). Start MATLAB normally.']);
end

home = caliali_tool('java');
try
    jenv(home);
catch ME
    error('CaliAli:java:jenv', ['Java was downloaded to %s, but MATLAB could ' ...
        'not be set to use it: %s\nRun jenv("%s") yourself, then restart MATLAB.'], ...
        home, ME.message, home);
end
if usejava('jvm')
    % MATLAB loaded it at once; no restart needed.
    say('Java is set up.');
    return
end
msg = 'Java is set up. Restart MATLAB, then run this again (only needed once).';
say(msg);
error('CaliAli:java:restart', '%s', msg);
end


function say(msg)
if exist('cprintf', 'file')
    cprintf([0, 0.55, 0], '%s\n', msg);
end
end
