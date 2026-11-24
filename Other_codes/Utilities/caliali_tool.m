function out = caliali_tool(name)
%% caliali_tool: Path to FFmpeg or Java; downloads it the first time it is needed.
%
% CaliAli needs two programs that MATLAB does not always have:
%   'ffmpeg' - reads the videos MATLAB's VideoReader cannot: GREY and FFV1 from
%              the Miniscope software on a Mac, FFV1, Xvid and H.264 on a
%              Linux without extra GStreamer plugins, most AVI on a Windows
%              without a codec pack. CaliAli_downsample asks for it only when
%              VideoReader fails.
%   'java'   - MATLAB R2026b and later no longer include Java, and the file
%              picker (uipickfiles) needs it. caliali_require_java asks for it
%              and sets MATLAB to use it.
%
% FFmpeg is looked for in this order, and downloaded only when none works:
%   1. the one set with setpref('CaliAli', 'ffmpeg', '/path/to/ffmpeg')
%   2. one installed on the system: on the PATH, or in Homebrew's folders on a
%      Mac, which MATLAB's PATH usually lacks when it is opened from the Dock
%   3. the copy CaliAli downloaded before
%   4. a new download
% Each candidate must run (ffmpeg -version) before it is used: on Linux,
% MATLAB's own library path can stop a system FFmpeg from starting, and an
% Intel build will not run on an Apple Silicon Mac without Rosetta.
%
% WHERE DOWNLOADS GO. A folder of the user's own (tools_folder below), not the
% CaliAli folder: that one may be shared or read-only, and it is added to the
% MATLAB path with all its subfolders, which a Java runtime should not be.
%   Windows: %LOCALAPPDATA%\CaliAli
%   macOS:   ~/Library/Application Support/CaliAli
%   Linux:   ~/.local/share/CaliAli (or $XDG_DATA_HOME/CaliAli)
% setpref('CaliAli', 'tools_folder', '/some/folder') moves it.
%
% WHAT IS DOWNLOADED. A fixed version of each, from GitHub releases, and its
% SHA-256 checksum is compared with the one written below before it is used:
% a changed or damaged file is deleted and refused.
%   FFmpeg 6.1.1, static builds (github.com/eugeneware/ffmpeg-static, release
%     b6.1.1): one self-contained program, 19 to 30 MB.
%   Java: Eclipse Temurin 21.0.9 runtime (github.com/adoptium), 42 to 52 MB.
%     MathWorks supports Temurin, versions 8, 11, 17, 21 and 25.
% The build follows MATLAB's architecture (computer('arch')), not the
% machine's: an Intel MATLAB on an Apple Silicon Mac needs Intel Java.
%
% Machines without internet: see "Machines without internet" in
% docs/Installation.md.
%
% Inputs:
%   name - 'ffmpeg' or 'java'.
%
% Outputs:
%   out - 'ffmpeg': full path of the ffmpeg program.
%         'java':   the Java home folder (the one that holds bin/java).
%
% Usage:
%   ffmpeg = caliali_tool('ffmpeg');
%   home = caliali_tool('java');
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

switch lower(name)
    case 'ffmpeg'
        out = find_ffmpeg();
    case 'java'
        out = get_java();
    otherwise
        error('CaliAli:tool:unknown', 'Unknown tool "%s": use ''ffmpeg'' or ''java''.', name);
end
end


%% ---- FFmpeg ---------------------------------------------------------------

function p = find_ffmpeg()
% Found once per MATLAB session; `clear caliali_tool` looks again.
persistent found
if ~isempty(found) && isfile(found)
    p = found;
    return
end

if ispref('CaliAli', 'ffmpeg')
    p = getpref('CaliAli', 'ffmpeg');
    if runs(p)
        found = p;
        return
    end
    warning('CaliAli:tool:ffmpegPref', ['The FFmpeg set with setpref(''CaliAli'', ' ...
        '''ffmpeg'', ...) does not run: %s. Looking for another.'], p);
end

S = ffmpeg_build();
own = fullfile(tools_folder(), 'ffmpeg', S.version, S.exe);
cands = [system_ffmpeg(), {own}];
for k = 1:numel(cands)
    if runs(cands{k})
        found = cands{k};
        p = found;
        return
    end
end

p = download_ffmpeg(S, own);
found = p;
end


function c = system_ffmpeg()
% Every ffmpeg the system knows of, first on the PATH first.
if ispc
    [st, txt] = system('where ffmpeg');
else
    [st, txt] = system('command -v ffmpeg');
end
c = {};
if st == 0
    c = strtrim(splitlines(txt))';
    c = c(~cellfun(@isempty, c) & cellfun(@isfile, c));
end
if ismac
    c = [c, {'/opt/homebrew/bin/ffmpeg', '/usr/local/bin/ffmpeg'}];
end
end


function ok = runs(p)
ok = ~isempty(p) && isfile(p) && run_quoted(p, '-hide_banner -version') == 0;
end


function p = download_ffmpeg(S, p)
dest = fileparts(p);
say(['CaliAli needs FFmpeg and found none on this computer. Downloading ' ...
    'FFmpeg %s (%d MB, only this once) into %s\n'], S.version, S.mb, dest);
gz = fetch(S, dest);
tmp = tempname(dest);
mkdir(tmp);
c = onCleanup(@() remove_folder(tmp));
gunzip(gz, tmp);
delete(gz);
movefile(fullfile(tmp, erase(S.file, '.gz')), p);
make_runnable(p);
if ~runs(p)
    error('CaliAli:tool:ffmpegBroken', ['FFmpeg was downloaded to %s but does ' ...
        'not run on this computer. Install FFmpeg on the system instead (see ' ...
        '"Machines without internet" in the installation docs).'], p);
end
say('FFmpeg is ready.\n');
end


function S = ffmpeg_build()
base = 'https://github.com/eugeneware/ffmpeg-static/releases/download/b6.1.1/';
S.version = '6.1.1';
S.exe = 'ffmpeg';
switch computer('arch')
    case 'win64'
        S.file = 'ffmpeg-win32-x64.gz';     S.mb = 30;
        S.sha256 = '8883a3dffbd0a16cf4ef95206ea05283f78908dbfb118f73c83f4951dcc06d77';
        S.exe = 'ffmpeg.exe';
    case 'glnxa64'
        S.file = 'ffmpeg-linux-x64.gz';     S.mb = 29;
        S.sha256 = 'bfe8a8fc511530457b528c48d77b5737527b504a3797a9bc4866aeca69c2dffa';
    case 'maci64'
        S.file = 'ffmpeg-darwin-x64.gz';    S.mb = 25;
        S.sha256 = '929b375c1182d956c51f7ac25e0b2b0411fb01f6f407aa15c9758efeb4242106';
    case 'maca64'
        S.file = 'ffmpeg-darwin-arm64.gz';  S.mb = 19;
        S.sha256 = '8923876afa8db5585022d7860ec7e589af192f441c56793971276d450ed3bbfa';
    otherwise
        error('CaliAli:tool:arch', 'No FFmpeg download for %s. Install FFmpeg on the system.', computer('arch'));
end
S.url = [base S.file];
end


%% ---- Java -----------------------------------------------------------------

function home = get_java()
S = java_build();
dest = fullfile(tools_folder(), 'java');
home = java_home(fullfile(dest, S.folder));
if ~isempty(home)
    return
end
say(['MATLAB %s has no Java, and a CaliAli function needs it. Downloading ' ...
    'Java %s (%d MB, only this once) into %s\n'], version('-release'), S.version, S.mb, dest);
arc = fetch(S, dest);
if endsWith(arc, '.zip')
    unzip(arc, dest);
else
    % The system's tar, not MATLAB's untar: it keeps the runtime's file
    % permissions and links.
    st = run_quoted('tar', sprintf('-xzf "%s" -C "%s"', arc, dest));
    if st ~= 0
        error('CaliAli:tool:untar', 'Could not unpack %s.', arc);
    end
end
delete(arc);
home = java_home(fullfile(dest, S.folder));
if isempty(home)
    error('CaliAli:tool:javaBroken', 'Java was unpacked into %s, but bin/java is not where expected.', dest);
end
end


function home = java_home(top)
% A Mac runtime keeps its home inside an app-style bundle.
if ismac
    home = fullfile(top, 'Contents', 'Home');
else
    home = top;
end
if ispc
    exe = 'java.exe';
else
    exe = 'java';
end
if ~isfile(fullfile(home, 'bin', exe))
    home = '';
end
end


function S = java_build()
tag = 'jdk-21.0.9+10';
base = 'https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.9%2B10/';
S.version = '21.0.9 (Eclipse Temurin)';
S.folder = [tag '-jre'];
switch computer('arch')
    case 'win64'
        S.file = 'OpenJDK21U-jre_x64_windows_hotspot_21.0.9_10.zip';      S.mb = 49;
        S.sha256 = '39c5e23f3ce4d420663afba8ffde28034b72e2b3e240943dc2321bc1f912eef9';
    case 'glnxa64'
        S.file = 'OpenJDK21U-jre_x64_linux_hotspot_21.0.9_10.tar.gz';     S.mb = 52;
        S.sha256 = 'aeab55d064a1a27a3744b0880b9b414077b4ed2b1790817eea3df60aec946431';
    case 'maci64'
        S.file = 'OpenJDK21U-jre_x64_mac_hotspot_21.0.9_10.tar.gz';       S.mb = 42;
        S.sha256 = '945abc49249f1e89a2a6a008d70d63dc42b25bbe5e1711ff97aeec70063008d2';
    case 'maca64'
        S.file = 'OpenJDK21U-jre_aarch64_mac_hotspot_21.0.9_10.tar.gz';   S.mb = 48;
        S.sha256 = '1f7f6506b598e85d7d8ff8b36563d98657d2d81b16bfca3cd242d7906cfbd11b';
    otherwise
        error('CaliAli:tool:arch', 'No Java download for %s.', computer('arch'));
end
S.url = [base S.file];
end


%% ---- shared ---------------------------------------------------------------

function d = tools_folder()
if ispref('CaliAli', 'tools_folder')
    d = getpref('CaliAli', 'tools_folder');
    return
end
if ispc
    base = getenv('LOCALAPPDATA');
    if isempty(base), base = getenv('APPDATA'); end
elseif ismac
    base = fullfile(getenv('HOME'), 'Library', 'Application Support');
else
    base = getenv('XDG_DATA_HOME');
    if isempty(base), base = fullfile(getenv('HOME'), '.local', 'share'); end
end
d = fullfile(base, 'CaliAli');
end


function f = fetch(S, dest)
%% Download S.url into dest and check it against S.sha256.
if ~isfolder(dest), mkdir(dest); end
f = fullfile(dest, S.file);
try
    websave(f, S.url, weboptions('Timeout', 60));
catch ME
    % MATLAB's own download can fail behind some proxies where curl, which
    % Windows 10 and later, macOS and Linux all have, gets through.
    if run_quoted('curl', sprintf('-fsSL -o "%s" "%s"', f, S.url)) ~= 0
        if isfile(f), delete(f); end
        error('CaliAli:tool:download', ['Could not download %s\n(%s)\nWithout ' ...
            'internet, see "Machines without internet" in the installation docs.'], ...
            S.url, ME.message);
    end
end
h = sha256_of(f);
if ~strcmpi(h, S.sha256)
    delete(f);
    error('CaliAli:tool:checksum', ['The download of %s is not the expected file ' ...
        '(SHA-256 %s, expected %s), so it was deleted. Try again; if it keeps ' ...
        'happening, the download is being altered on the way.'], S.url, h, S.sha256);
end
end


function h = sha256_of(f)
% The system's own tool, so this works without Java.
if ispc
    [st, txt] = system(sprintf('certutil -hashfile "%s" SHA256', f));
elseif ismac
    [st, txt] = system(sprintf('shasum -a 256 "%s"', f));
else
    [st, txt] = system(sprintf('sha256sum "%s"', f));
end
h = '';
if st ~= 0, return, end
for line = splitlines(txt)'
    % certutil prints the hash alone on a line (with spaces between the bytes
    % on older Windows); shasum and sha256sum print it first, then the name.
    s = strtrim(line{1});
    if ispc, s = strrep(s, ' ', ''); end
    t = regexp(s, '^[0-9a-fA-F]{64}', 'match', 'once');
    if ~isempty(t)
        h = lower(t);
        return
    end
end
end


function make_runnable(p)
if isunix
    fileattrib(p, '+x', 'a');
end
if ismac
    % A file MATLAB downloads is not normally quarantined, but if anything
    % marked it, macOS would refuse to run it.
    system(sprintf('xattr -d com.apple.quarantine "%s" 2>/dev/null', p));
end
end


function st = run_quoted(program, args)
cmd = sprintf('"%s" %s', program, args);
if ispc
    % cmd.exe drops the first and last quote of a line that starts with one,
    % which breaks a quoted program followed by quoted arguments.
    cmd = ['"' cmd '"'];
end
[st, ~] = system(cmd);
end


function remove_folder(d)
if isfolder(d)
    rmdir(d, 's');
end
end


function say(varargin)
% Green, so the download stands out from CaliAli's other messages.
if exist('cprintf', 'file')
    cprintf([0, 0.55, 0], varargin{:});
else
    fprintf(1, varargin{:});
end
end
